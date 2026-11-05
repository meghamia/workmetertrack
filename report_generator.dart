import 'dart:io';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import '../controllers/records_controller.dart';

import 'package:excel/excel.dart';

import 'package:path_provider/path_provider.dart';

import '../models/auth/employee_model.dart';

enum ReportFormat { pdf, excel, csv }

class ReportGenerator {
  ReportGenerator._();

  static const String folderName = 'Track Attendance';

  // ============================================================
  // TABLE DEFINITION (used by both PDF and Excel)
  // ============================================================

  static const List<String> tableHeaders = <String>[
    'Date',
    'Login ID',
    'Punch IN',
    'Punch OUT',
    'Total Hours',
    'Status',
    'Location',
    'Latitude',
    'Longitude',
  ];

  static const List<double> excelColumnWidths = <double>[
    14,
    26,
    12,
    12,
    14,
    14,
    30,
    14,
    14,
  ];

  // Relative column weights, summing to 100.
  // FlexColumnWidth.flex is a double, so these must be double literals.
  static const Map<int, double> pdfColumnFlex = <int, double>{
    0: 11.0, // Date
    1: 18.0, // Login ID
    2: 8.0, // Punch IN
    3: 8.0, // Punch OUT
    4: 9.0, // Total Hours
    5: 9.0, // Status
    6: 19.0, // Location
    7: 9.0, // Latitude
    8: 9.0, // Longitude
  };

  // ============================================================
  // DIRECTORY RESOLUTION
  //
  // Tries each candidate and verifies it with a real write probe,
  // so it can never return a folder we cannot actually write to.
  // ============================================================

  static Future<Directory> getDownloadDirectory() async {
    final List<Directory> candidates = <Directory>[];

    // 1) Android public Downloads
    if (Platform.isAndroid) {
      candidates.add(
        Directory('/storage/emulated/0/Download/$folderName'),
      );
    }

    // 2) App external files directory - always writable, no permission
    try {
      final Directory? dir = await getExternalStorageDirectory();

      if (dir != null) {
        candidates.add(Directory('${dir.path}/$folderName'));
      }
    } catch (_) {
      // ignore and try the next candidate
    }

    // 3) App documents directory - iOS / desktop fallback
    try {
      final Directory dir = await getApplicationDocumentsDirectory();
      candidates.add(Directory('${dir.path}/$folderName'));
    } catch (_) {
      // ignore and try the next candidate
    }

    for (final Directory dir in candidates) {
      try {
        if (!await dir.exists()) {
          await dir.create(recursive: true);
        }

        final File probe = File('${dir.path}/.probe');
        await probe.writeAsString('ok');

        if (await probe.exists()) {
          await probe.delete();
        }

        return dir;
      } catch (_) {
        continue;
      }
    }

    throw Exception(
      'Could not find a writable folder to save the report.',
    );
  }

  // ============================================================
  // FILENAME
  //
  // Fixes the dd/MM/yyyy slash crash in the original version:
  // "attendance_ram@acme.com_05/10/2026.pdf" treated the slashes as
  // directories that do not exist.
  // ============================================================

  static String _sanitize(String value, {int maxLength = 40}) {
    String output = value.trim().replaceAll(RegExp(r'[^A-Za-z0-9._@-]'), '_');

    if (output.isEmpty) {
      output = 'record';
    }

    if (output.length > maxLength) {
      output = output.substring(0, maxLength);
    }

    return output;
  }

  static String _fileBaseName(PunchPair pair) {
    final String stamp = DateFormat(
      'yyyyMMdd_HHmmss',
    ).format(DateTime.now());

    final String user = _sanitize(
      pair.loginId.isEmpty ? 'record' : pair.loginId,
    );

    return 'attendance_${user}_$stamp';
  }

  // ============================================================
  // PDF TEXT SAFETY
  //
  // The built-in dart_pdf fonts (Helvetica, Courier, Times) only cover
  // U+0000-U+00FF and THROW on anything higher.
  //
  //   type1_font.dart:109
  //     PdfFontMetrics glyphMetrics(int charCode) {
  //       if (!isRuneSupported(charCode)) {
  //         throw Exception('Unable to display U+.. with $fontName');
  //
  // A geocoded address containing an accented or non-Latin character
  // would otherwise abort the entire export. Swap those runes for '?'.
  //
  // Applied only on the PDF path. XLSX uses real Unicode fonts.
  // ============================================================

  static String _pdfSafe(String value) {
    return value.runes.map<String>((int rune) {
      return rune <= 0xFF ? String.fromCharCode(rune) : '?';
    }).join();
  }


  static String _pdfCell(String value) {
    const int maxChars = 30;

    // ASCII only - no ellipsis glyph, it is not in the built-in fonts.
    final String safe = _pdfSafe(value.trim().isEmpty ? '-' : value);

    if (safe.length <= maxChars) {
      return safe;
    }

    return '${safe.substring(0, maxChars - 3)}...';
  }

  // ============================================================
  // DERIVED VALUES
  // ============================================================

  static double _hoursDouble(PunchPair pair) {
    final DateTime? inTs = pair.inRecord?.timestamp;
    final DateTime? outTs = pair.outRecord?.timestamp;

    if (inTs == null || outTs == null || !outTs.isAfter(inTs)) {
      return -1;
    }

    return outTs.difference(inTs).inMinutes / 60.0;
  }

  static String _totalHoursText(PunchPair pair) {
    final double hoursValue = _hoursDouble(pair);

    if (hoursValue < 0) {
      return '-';
    }

    final int hours = hoursValue.floor();
    final int minutes = ((hoursValue - hours) * 60).round();

    return '$hours h ${minutes.toString().padLeft(2, '0')} m';
  }

  static String _status(PunchPair pair) {
    final DateTime? inTs = pair.inRecord?.timestamp;
    final DateTime? outTs = pair.outRecord?.timestamp;

    if (inTs == null) {
      return outTs == null ? 'No punch' : 'Incomplete';
    }

    if (outTs == null) {
      return 'Incomplete';
    }

    if (outTs.isBefore(inTs)) {
      return 'Invalid';
    }

    return 'Complete';
  }

  static List<String> _rowFor(PunchPair pair) {
    return <String>[
      pair.formattedDate,
      pair.loginId.isEmpty ? '-' : pair.loginId,
      pair.inTime,
      pair.outTime,
      _totalHoursText(pair),
      _status(pair),
      pair.location.isEmpty ? '-' : pair.location,
      pair.latitude.toStringAsFixed(6),
      pair.longitude.toStringAsFixed(6),
    ];
  }

  // ============================================================
  // PDF - SINGLE RECORD (RecordDetailScreen)
  //
  // Only one data row, so it always fits on a single page.
  // ============================================================

  static Future<File> generateSingleRecordPdf(PunchPair pair) async {
    final pw.MemoryImage? inImage = await _loadImage(pair.inPhotoPath);
    final pw.MemoryImage? outImage = await _loadImage(pair.outPhotoPath);

    final String now = DateFormat(
      'dd MMM yyyy  hh:mm a',
    ).format(DateTime.now());

    final pw.Document pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.fromLTRB(24, 24, 24, 28),
        footer: (pw.Context context) {
          return pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              'Page ${context.pageNumber} of ${context.pagesCount}',
              style: const pw.TextStyle(
                fontSize: 9,
                color: PdfColors.grey700,
              ),
            ),
          );
        },
        build: (pw.Context context) {
          return <pw.Widget>[
            pw.Text(
              'Attendance Report',
              style: pw.TextStyle(
                fontSize: 22,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              _pdfSafe('Generated on $now'),
              style: const pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey700,
              ),
            ),
            pw.SizedBox(height: 16),
            _pdfTable(<List<String>>[_rowFor(pair)]),
            pw.SizedBox(height: 18),
            pw.Text(
              'Details',
              style: pw.TextStyle(
                fontSize: 13,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 8),
            _pdfSummary(pair),
            if (inImage != null || outImage != null) ...[
              pw.SizedBox(height: 18),
              pw.Text(
                'Photographs',
                style: pw.TextStyle(
                  fontSize: 13,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: <pw.Widget>[
                  if (inImage != null)
                    pw.Expanded(
                      child: _photoBlock(inImage, 'Punch IN Photo'),
                    ),
                  if (inImage != null && outImage != null)
                    pw.SizedBox(width: 16),
                  if (outImage != null)
                    pw.Expanded(
                      child: _photoBlock(outImage, 'Punch OUT Photo'),
                    ),
                ],
              ),
            ],
          ];
        },
      ),
    );

    final Directory dir = await getDownloadDirectory();

    final File file = File(
      '${dir.path}/${_fileBaseName(pair)}.pdf',
    );

    await file.writeAsBytes(await pdf.save());

    return file;
  }

  // ============================================================
  // PDF - ALL RECORDS (RecordsScreen)
  //
  // Paginated manually with pw.Page instead of pw.MultiPage, and the
  // row count per page is chosen so the table can never exceed the
  // printable height.
  //
  // NOTE: pw.Page.build returns a single Widget  // (BuildCallback, page.dart:31) whereas
  // pw.MultiPage.build returns List<Widget>. Hence the pw.Column.
  // ============================================================

  static Future<File> generateAllRecordsPdf(List<PunchPair> pairs) async {
    final String now = DateFormat(
      'dd MMM yyyy  hh:mm a',
    ).format(DateTime.now());

    final pw.Document pdf = pw.Document();

    final List<List<String>> rows = pairs.map<List<String>>(_rowFor).toList();

    // Height budget for landscape A4 (595pt) minus 24 top / 28 bottom
    // margins = 543pt printable:
    //   title block ~57pt  (first page only)
    //   header row ~24pt
    //   footer ~23pt
    //   data row    ~24pt each (single line, guaranteed by _pdfCell)
    //
    // 18 rows keeps the first page comfortably inside the limit.
    const int rowsPerPage = 18;

    final int pageCount =
        rows.isEmpty ? 1 : ((rows.length - 1) ~/ rowsPerPage) + 1;

    for (int pageIndex = 0; pageIndex < pageCount; pageIndex++) {
      final int start = pageIndex * rowsPerPage;

      final int end = (start + rowsPerPage < rows.length)
          ? start + rowsPerPage
          : rows.length;

      final List<List<String>> chunk = rows.sublist(start, end);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4.landscape,
          margin: const pw.EdgeInsets.fromLTRB(24, 24, 24, 28),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: <pw.Widget>[
                // Title block only on the first page
                if (pageIndex == 0) ...[
                  pw.Text(
                    'Attendance Records Report',
                    style: pw.TextStyle(
                      fontSize: 22,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 2),
                  // ASCII separator only. A bullet character would
                  // make dart_pdf throw and abort the whole export.
                  pw.Text(
                    '${pairs.length} record(s)   |   '
                    'Generated on ${_pdfSafe(now)}',
                    style: const pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey700,
                    ),
                  ),
                  pw.SizedBox(height: 16),
                ],

                _pdfTable(chunk),

                pw.SizedBox(height: 12),

                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text(
                    'Page ${pageIndex + 1} of $pageCount',
                    style: const pw.TextStyle(
                      fontSize: 9,
                      color: PdfColors.grey700,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      );
    }

    final Directory dir = await getDownloadDirectory();

    final String stamp = DateFormat(
      'yyyyMMdd_HHmmss',
    ).format(DateTime.now());

    final File file = File(
      '${dir.path}/attendance_records_$stamp.pdf',
    );

    await file.writeAsBytes(await pdf.save());

    return file;
  }

  // ============================================================
  // EXCEL STYLES
  //
  // excel 4.0.6 API. Note the exact names:
  //   fontColorHex / backgroundColorHex are ExcelColor, not Color
  //   fontSize is int
  //   HorizontalAlign / VerticalAlign, not HorizontalAlignment
  //
  // Styling is applied to the CELL via Data.cellStyle.
  // TextCellValue has no cellStyle constructor parameter.
  // ============================================================

  static final CellStyle _titleStyle = CellStyle(
    bold: true,
    fontSize: 14,
    fontColorHex: ExcelColor.fromInt(0xFF0D47A1),
  );

  static final CellStyle _subtitleStyle = CellStyle(
    fontSize: 10,
    fontColorHex: ExcelColor.fromInt(0xFF616161),
  );

  static final CellStyle _headerStyle = CellStyle(
    bold: true,
    fontSize: 11,
    fontColorHex: ExcelColor.fromInt(0xFFFFFFFF),
    backgroundColorHex: ExcelColor.fromInt(0xFF1E88E5),
    horizontalAlign: HorizontalAlign.Center,
    verticalAlign: VerticalAlign.Center,
  );

  static final CellStyle _cellStyle = CellStyle(
    fontSize: 11,
    verticalAlign: VerticalAlign.Center,
  );

  // ============================================================
  // EXCEL CELL HELPERS
  // ============================================================

  /// Writes one value plus style into a single cell.
  ///
  /// [style] is optional. Passing null leaves the cell unstyled.
  static void _put(
    Sheet sheet,
    int rowIndex,
    int colIndex,
    String value, [
    CellStyle? style,
  ]) {
    final Data cell = sheet.cell(
      CellIndex.indexByColumnRow(
        columnIndex: colIndex,
        rowIndex: rowIndex,
      ),
    );

    cell.value = TextCellValue(value);
    cell.cellStyle = style;
  }

  /// Writes a whole row of values, applying [style] to every cell.
  static void _putRow(
    Sheet sheet,
    int rowIndex,
    List<String> values,
    CellStyle? style,
  ) {
    for (int i = 0; i < values.length; i++) {
      _put(sheet, rowIndex, i, values[i], style);
    }
  }

  static void _applyExcelWidths(Sheet sheet) {
    for (int i = 0; i < excelColumnWidths.length; i++) {
      sheet.setColumnWidth(i, excelColumnWidths[i]);
    }
  }

  // ============================================================
  // EXCEL - SINGLE RECORD
  // ============================================================

  static Future<File> generateSingleRecordExcel(PunchPair pair) async {
    final Excel excel = Excel.createExcel();

    // operator [] CREATES the sheet if it is missing, so this must come
    // first - otherwise setDefaultSheet() silently fails.
    final Sheet sheet = excel['Report'];

    // now that 'Report' exists this actually sets the active tab
    excel.setDefaultSheet('Report');

    // now there are 2 sheets, so delete() will actually run
    if (excel.tables.containsKey('Sheet1')) {
      excel.delete('Sheet1');
    }

    final String now = DateFormat(
      'dd MMM yyyy  hh:mm a',
    ).format(DateTime.now());

    // row 0 - title
    _put(sheet, 0, 0, 'ATTENDANCE REPORT', _titleStyle);

    // row 1 - generated on
    _put(sheet, 1, 0, 'Generated on $now', _subtitleStyle);

    // row 2 - spacer
    _put(sheet, 2, 0, '');

    // row 3 - header
    _putRow(sheet, 3, tableHeaders, _headerStyle);

    // row 4 - data
    _putRow(sheet, 4, _rowFor(pair), _cellStyle);

    _applyExcelWidths(sheet);

    return _saveExcel(excel, _fileBaseName(pair));
  }

  // ============================================================
  // EXCEL - ALL RECORDS
  // ============================================================

  static Future<File> generateAllRecordsExcel(List<PunchPair> pairs) async {
    final Excel excel = Excel.createExcel();

    // operator [] CREATES the sheet if it is missing, so this must come
    // first - otherwise setDefaultSheet() silently fails.
    final Sheet sheet = excel['Records'];

    // now that 'Records' exists this actually sets the active tab
    excel.setDefaultSheet('Records');

    // now there are 2 sheets, so delete() will actually run
    if (excel.tables.containsKey('Sheet1')) {
      excel.delete('Sheet1');
    }

    final String now = DateFormat(
      'dd MMM yyyy  hh:mm a',
    ).format(DateTime.now());

    // row 0 - title
    _put(sheet, 0, 0, 'ATTENDANCE RECORDS', _titleStyle);

    // row 1 - subtitle
    _put(
      sheet,
      1,
      0,
      '${pairs.length} record(s)  -  Generated on $now',
      _subtitleStyle,
    );

    // row 2 - spacer
    _put(sheet, 2, 0, '');

    // row 3 - header
    _putRow(sheet, 3, tableHeaders, _headerStyle);

    // rows 4 onwards - data
    for (int i = 0; i < pairs.length; i++) {
      _putRow(sheet, 4 + i, _rowFor(pairs[i]), _cellStyle);
    }

    _applyExcelWidths(sheet);

    // ── Summary sheet ──
    final Sheet summary = excel['Summary'];

    _put(summary, 0, 0, 'SUMMARY', _titleStyle);
    _put(summary, 1, 0, '');
    _putRow(
      summary,
      2,
      const <String>['Metric', 'Value'],
      _headerStyle,
    );

    final int complete =
        pairs.where((PunchPair p) => _status(p) == 'Complete').length;

    final int incomplete =
        pairs.where((PunchPair p) => _status(p) == 'Incomplete').length;

    final double totalHours = pairs.fold<double>(
      0,
      (double sum, PunchPair p) {
        final double h = _hoursDouble(p);
        return h < 0 ? sum : sum + h;
      },
    );

    final List<String> labels = <String>[
      'Total days',
      'Complete days',
      'Incomplete days',
      'Total hours',
    ];

    final List<String> values = <String>[
      '${pairs.length}',
      '$complete',
      '$incomplete',
      '${totalHours.toStringAsFixed(2)} h',
    ];

    for (int i = 0; i < labels.length; i++) {
      _putRow(
        summary,
        3 + i,
        <String>[labels[i], values[i]],
        _cellStyle,
      );
    }

    summary.setColumnWidth(0, 22);
    summary.setColumnWidth(1, 20);

    return _saveExcel(excel, 'attendance_records_all');
  }

  // ============================================================
  // SAVE EXCEL FILE
  // ============================================================

  static Future<File> _saveExcel(Excel excel, String baseName) async {
    final Directory dir = await getDownloadDirectory();

    final String stamp = DateFormat(
      'yyyyMMdd_HHmmss',
    ).format(DateTime.now());

    final File file = File('${dir.path}/${baseName}_$stamp.xlsx');

    final List<int>? bytes = excel.encode();

    if (bytes == null) {
      throw Exception('Failed to encode the Excel file.');
    }

    await file.writeAsBytes(bytes);

    return file;
  }

  // ============================================================
  // PDF TABLE
  //
  // TableHelper.fromTextArray marks the header row with repeat: true so
  // it is reprinted on every page.
  // ============================================================

  static pw.Widget _pdfTable(List<List<String>> rows) {
    return pw.TableHelper.fromTextArray(
      headers: tableHeaders.map(_pdfCell).toList(),
      data: rows
          .map(
            (List<String> row) => row.map(_pdfCell).toList(),
          )
          .toList(),
      columnWidths: <int, pw.TableColumnWidth>{
        for (final MapEntry<int, double> entry in pdfColumnFlex.entries)
          entry.key: pw.FlexColumnWidth(entry.value),
      },
      headerDecoration: const pw.BoxDecoration(
        color: PdfColors.blueGrey800,
      ),
      headerStyle: pw.TextStyle(
        color: PdfColors.white,
        fontSize: 9,
        fontWeight: pw.FontWeight.bold,
      ),
      headerPadding: const pw.EdgeInsets.symmetric(
        horizontal: 5,
        vertical: 6,
      ),
      cellStyle: const pw.TextStyle(fontSize: 9),
      oddCellStyle: const pw.TextStyle(fontSize: 9),
      cellAlignment: pw.Alignment.centerLeft,
      cellPadding: const pw.EdgeInsets.symmetric(
        horizontal: 5,
        vertical: 6,
      ),
      border: pw.TableBorder.all(
        color: PdfColors.grey400,
        width: 0.6,
      ),
      oddRowDecoration: const pw.BoxDecoration(
        color: PdfColors.grey100,
      ),
    );
  }

  // ============================================================
  // PDF SUMMARY
  // ============================================================

  static pw.Widget _pdfSummary(PunchPair pair) {
    final List<List<String>> data = <List<String>>[
      <String>['Login ID', pair.loginId],
      <String>['Date', pair.formattedDate],
      <String>['Location', pair.location],
      <String>[
        'Coordinates',
        'Lat: ${pair.latitude.toStringAsFixed(6)}, '
            'Lng: ${pair.longitude.toStringAsFixed(6)}',
      ],
      <String>['Punch IN Time', pair.inTime],
      <String>['Punch OUT Time', pair.outTime],
      <String>['Total Hours', _totalHoursText(pair)],
      <String>['Status', _status(pair)],
      <String>['Punch IN Photo', pair.inPhotoPath ?? 'Not captured'],
      <String>['Punch OUT Photo', pair.outPhotoPath ?? 'Not captured'],
    ];

    return pw.TableHelper.fromTextArray(
      headers: const <String>['Field', 'Value'],
      data: data
          .map(
            (List<String> row) => row.map(_pdfSafe).toList(),
          )
          .toList(),
      headerDecoration: const pw.BoxDecoration(
        color: PdfColors.blueGrey800,
      ),
      headerStyle: pw.TextStyle(
        color: PdfColors.white,
        fontSize: 10,
        fontWeight: pw.FontWeight.bold,
      ),
      cellStyle: const pw.TextStyle(fontSize: 10),
      cellAlignment: pw.Alignment.centerLeft,
      cellPadding: const pw.EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 6,
      ),
      border: pw.TableBorder.all(
        color: PdfColors.grey400,
        width: 0.6,
      ),
      columnWidths: <int, pw.TableColumnWidth>{
        0: pw.FixedColumnWidth(140),
        1: pw.FlexColumnWidth(3),
      },
      oddRowDecoration: const pw.BoxDecoration(
        color: PdfColors.grey100,
      ),
    );
  }

  // ============================================================
  // PHOTO HANDLING
  // ============================================================

  static Future<pw.MemoryImage?> _loadImage(String? path) async {
    if (path == null || path.isEmpty) {
      return null;
    }

    try {
      final File file = File(path);

      if (!await file.exists()) {
        return null;
      }

      // Must stay Uint8List because pw.MemoryImage requires it.
      final bytes = await file.readAsBytes();

      if (bytes.isEmpty) {
        return null;
      }

      // The constructor throws when the bytes are not a decodable
      // image, which is why this whole block sits inside try/catch.
      return pw.MemoryImage(bytes);
    } catch (_) {
      return null;
    }
  }

  static pw.Widget _photoBlock(pw.MemoryImage image, String label) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: <pw.Widget>[
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 11,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.ClipRRect(
          horizontalRadius: 6,
          verticalRadius: 6,
          child: pw.Image(
            image,
            height: 120,
            fit: pw.BoxFit.cover,
          ),
        ),
      ],
    );
  }


  // ============================================================
  // ADMIN REPORT - All Employees (PDF)
  // ============================================================

  static Future<File> generateAdminReportPdf(
      List<Map<String, dynamic>> records,
      ) async {
    final String now = DateFormat('dd MMM yyyy  hh:mm a')
        .format(DateTime.now());

    final pw.Document pdf = pw.Document();
    final List<List<String>> rows = records.map(_adminRowFor).toList();

    const int rowsPerPage = 18;
    final int pageCount = rows.isEmpty
        ? 1
        : ((rows.length - 1) ~/ rowsPerPage) + 1;

    for (int pageIndex = 0; pageIndex < pageCount; pageIndex++) {
      final int start = pageIndex * rowsPerPage;
      final int end = (start + rowsPerPage < rows.length)
          ? start + rowsPerPage
          : rows.length;
      final List<List<String>> chunk = rows.sublist(start, end);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4.landscape,
          margin: const pw.EdgeInsets.fromLTRB(24, 24, 24, 28),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: <pw.Widget>[
                if (pageIndex == 0) ...[
                  pw.Text(
                    'Attendance Reports - Admin',
                    style: pw.TextStyle(
                      fontSize: 22,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    '${records.length} record(s)   |   Generated on ${_pdfSafe(now)}',
                    style: const pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey700,
                    ),
                  ),
                  pw.SizedBox(height: 16),
                ],
                _pdfTable(chunk),
                pw.SizedBox(height: 12),
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text(
                    'Page ${pageIndex + 1} of $pageCount',
                    style: const pw.TextStyle(
                      fontSize: 9,
                      color: PdfColors.grey700,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      );
    }

    final Directory dir = await getDownloadDirectory();
    final String stamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final File file = File('${dir.path}/admin_attendance_report_$stamp.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  static List<String> _adminRowFor(Map<String, dynamic> record) {
    return <String>[
      record['date']?.toString() ?? '--',
      record['id']?.toString() ?? '',
      record['name']?.toString() ?? 'Unknown',
      record['punchIn']?.toString() ?? '--',
      record['punchOut']?.toString() ?? '--',
      record['workHours']?.toString() ?? '--',
      record['status']?.toString() ?? 'Unknown',
      record['department']?.toString() ?? 'General',
      record['date']?.toString() ?? '--',
    ];
  }

  // ============================================================
  // ADMIN REPORT - All Employees (Excel)
  // ============================================================

  static Future<File> generateAdminReportExcel(
      List<Map<String, dynamic>> records,
      ) async {
    final Excel excel = Excel.createExcel();
    final Sheet sheet = excel['Reports'];
    excel.setDefaultSheet('Reports');
    if (excel.tables.containsKey('Sheet1')) {
      excel.delete('Sheet1');
    }

    final String now = DateFormat('dd MMM yyyy  hh:mm a').format(DateTime.now());

    final List<String> headers = <String>[
      'Date', 'Employee ID', 'Name', 'Punch IN', 'Punch OUT',
      'Work Hours', 'Status', 'Department', 'Attendance Date',
    ];

    _put(sheet, 0, 0, 'ADMIN ATTENDANCE REPORT', _titleStyle);
    _put(sheet, 1, 0, '${records.length} record(s) - Generated on $now',
        _subtitleStyle);
    _put(sheet, 2, 0, '');
    _putRow(sheet, 3, headers, _headerStyle);

    for (int i = 0; i < records.length; i++) {
      _putRow(sheet, 4 + i, _adminRowFor(records[i]), _cellStyle);
    }

    _applyExcelWidths(sheet);
    return _saveExcel(excel, 'admin_attendance_report');
  }


  // ============================================================
  // ALL RECORDS - CSV (RecordsScreen)
  // ============================================================

  static Future<File> generateAllRecordsCsv(List<PunchPair> pairs) async {
    final buffer = StringBuffer();
    buffer.writeln(tableHeaders.join(','));

    for (final pair in pairs) {
      buffer.writeln(_rowFor(pair).join(','));
    }

    final Directory dir = await getDownloadDirectory();
    final String stamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final File file = File('${dir.path}/attendance_records_all_$stamp.csv');
    await file.writeAsString(buffer.toString());
    return file;
  }

  // ============================================================
  // SINGLE RECORD - CSV (RecordDetailScreen)
  // ============================================================

  static Future<File> generateSingleRecordCsv(PunchPair pair) async {
    final buffer = StringBuffer();
    buffer.writeln(tableHeaders.join(','));
    buffer.writeln(_rowFor(pair).join(','));

    final Directory dir = await getDownloadDirectory();
    final String stamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final String baseName = _fileBaseName(pair);
    final File file = File('${dir.path}/$baseName.csv');
    await file.writeAsString(buffer.toString());
    return file;
  }
  static String _csvSafe(String value) => value.contains(',') ? '"$value"' : value;
}
