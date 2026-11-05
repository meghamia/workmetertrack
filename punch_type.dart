enum PunchType {
  punchIn,
  punchOut;

  String get label {
    switch (this) {
      case PunchType.punchIn:
        return 'Punch In';
      case PunchType.punchOut:
        return 'Punch Out';
    }
  }
}