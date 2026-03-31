class AttendanceRecord {
  final String studentId;
  String status;
  String? remark;

  AttendanceRecord({required this.studentId, this.status = 'absent', this.remark});

  Map<String, dynamic> toJson() => {
        'student': studentId,
        'status': status,
        if (remark != null) 'remark': remark,
      };
}

class AttendanceSession {
  final String id;
  final Map<String, dynamic>? classInfo;
  final Map<String, dynamic>? subject;
  final String? teacherName;
  final DateTime date;
  final List<dynamic> records;
  final bool isFinalized;

  AttendanceSession({
    required this.id,
    this.classInfo,
    this.subject,
    this.teacherName,
    required this.date,
    this.records = const [],
    this.isFinalized = false,
  });

  factory AttendanceSession.fromJson(Map<String, dynamic> json) => AttendanceSession(
        id: json['_id'] ?? '',
        classInfo: json['class'] is Map ? json['class'] : null,
        subject: json['subject'] is Map ? json['subject'] : null,
        teacherName: json['teacher'] is Map ? json['teacher']['name'] : null,
        date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
        records: json['records'] ?? [],
        isFinalized: json['isFinalized'] ?? false,
      );

  int get presentCount => records.where((r) => r['status'] == 'present').length;
  int get absentCount  => records.where((r) => r['status'] == 'absent').length;
  int get lateCount    => records.where((r) => r['status'] == 'late').length;
  int get totalCount   => records.length;
}

class StudentAttendanceRecord {
  final String id;
  final Map<String, dynamic>? classInfo;
  final Map<String, dynamic>? subject;
  final String status;
  final DateTime date;

  StudentAttendanceRecord({
    required this.id,
    this.classInfo,
    this.subject,
    required this.status,
    required this.date,
  });

  factory StudentAttendanceRecord.fromJson(Map<String, dynamic> json) =>
      StudentAttendanceRecord(
        id: json['_id'] ?? '',
        classInfo: json['class'] is Map ? json['class'] : null,
        subject: json['subject'] is Map ? json['subject'] : null,
        status: json['status'] ?? 'absent',
        date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      );
}
