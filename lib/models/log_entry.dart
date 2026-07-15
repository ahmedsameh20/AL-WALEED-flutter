class LogEntry {
  final String employeeName;
  final String action;
  final String timestamp;

  const LogEntry({required this.employeeName, required this.action, required this.timestamp});

  factory LogEntry.fromMap(Map<String, Object?> map) {
    return LogEntry(
      employeeName: map['name'] as String? ?? '',
      action: map['action'] as String? ?? '',
      timestamp: map['timestamp'] as String? ?? '',
    );
  }
}
