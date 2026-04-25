class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? rollNumber;
  final String? employeeId;
  final String? phone;
  final ClassInfo? classInfo;
  final List<SubjectInfo> subjects;
  final bool isActive;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.rollNumber,
    this.employeeId,
    this.phone,
    this.classInfo,
    this.subjects = const [],
    this.isActive = true,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      rollNumber: json['rollNumber'],
      employeeId: json['employeeId'],
      phone: json['phone'],
      classInfo: json['class'] != null && json['class'] is Map
          ? ClassInfo.fromJson(json['class'])
          : null,
      subjects: (json['subjects'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map((s) => SubjectInfo.fromJson(s))
              .toList() ??
          [],
      isActive: json['isActive'] ?? true,
    );
  }

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}

class ClassInfo {
  final String id;
  final String name;
  final String section;
  final String grade;

  ClassInfo({required this.id, required this.name, required this.section, required this.grade});

  factory ClassInfo.fromJson(Map<String, dynamic> json) => ClassInfo(
        id: json['_id'] ?? '',
        name: json['name'] ?? '',
        section: json['section'] ?? '',
        grade: json['grade'] ?? '',
      );

  String get displayName => 'Grade $grade - $name ($section)';
}

class SubjectInfo {
  final String id;
  final String name;
  final String code;

  SubjectInfo({required this.id, required this.name, required this.code});

  factory SubjectInfo.fromJson(Map<String, dynamic> json) => SubjectInfo(
        id: json['_id'] ?? '',
        name: json['name'] ?? '',
        code: json['code'] ?? '',
      );
}
