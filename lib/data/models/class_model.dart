class ClassModel {
  final String id;
  final String name;
  final String section;
  final String grade;
  final String? classTeacherId; // ID of the teacher who takes morning roll call
  final List<dynamic> teachers;
  final List<SubjectModel> subjects;
  final String academicYear;
  final bool isActive;

  ClassModel({
    required this.id,
    required this.name,
    required this.section,
    required this.grade,
    this.classTeacherId,
    this.teachers = const [],
    this.subjects = const [],
    this.academicYear = '',
    this.isActive = true,
  });

  factory ClassModel.fromJson(Map<String, dynamic> json) {
    // classTeacher may come back as a Map (populated) or plain String (id)
    String? classTeacherId;
    final ct = json['classTeacher'];
    if (ct is Map) {
      classTeacherId = ct['_id']?.toString();
    } else if (ct is String) {
      classTeacherId = ct;
    }

    return ClassModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      section: json['section'] ?? '',
      grade: json['grade'] ?? '',
      classTeacherId: classTeacherId,
      teachers: json['teachers'] ?? [],
      subjects: (json['subjects'] as List<dynamic>?)
              ?.where((s) => s is Map)
              .map((s) => SubjectModel.fromJson(s))
              .toList() ??
          [],
      academicYear: json['academicYear'] ?? '',
      isActive: json['isActive'] ?? true,
    );
  }

  String get displayName => 'Grade $grade - $name ($section)';
}

class SubjectModel {
  final String id;
  final String name;
  final String code;

  SubjectModel({required this.id, required this.name, required this.code});

  factory SubjectModel.fromJson(Map<String, dynamic> json) => SubjectModel(
        id: json['_id'] ?? '',
        name: json['name'] ?? '',
        code: json['code'] ?? '',
      );

  Map<String, dynamic> toJson() => {'name': name, 'code': code};
}
