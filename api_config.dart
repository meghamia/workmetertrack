class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.0.53/attendance_api/api',
  );

  static const String apiKey = String.fromEnvironment('ATTENDANCE_API_KEY');

  static const String loginEndpoint = '/login';
  static const String logoutEndpoint = '/logout';
  static const String rolesEndpoint = '/roles';
  static const String attendanceEndpoint = '/attendance';

  static const String employeesEndpoint = '/employees/list';
  static const String employeeDetailsEndpoint = '/employee_details';

  static const String checkInEndpoint = '/attendance/check-in';
  static const String checkOutEndpoint = '/attendance/check-out';
  static String get addEmployeeUrl => '$baseUrl/employees/create';
  static const String updateEmployeeEndpoint = '/employees/update';


  static String get loginUrl => '$baseUrl$loginEndpoint';
  static String get logoutUrl => '$baseUrl$logoutEndpoint';
  static String get rolesUrl => '$baseUrl$rolesEndpoint';
  static String get attendanceUrl => '$baseUrl$attendanceEndpoint';
  static String get employeesUrl => '$baseUrl$employeesEndpoint';
  static String get checkInUrl => '$baseUrl$checkInEndpoint';
  static String get checkOutUrl => '$baseUrl$checkOutEndpoint';
  static String get employeeDetailsUrl => '$baseUrl$employeeDetailsEndpoint';
  static String get updateEmployeeUrl =>
      '$baseUrl$updateEmployeeEndpoint';
}