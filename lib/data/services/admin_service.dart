import '../models/user_model.dart';
import '../models/class_model.dart';
import 'api_service.dart';

class AdminService {
  final _api = ApiService.instance.dio;

  // ── Dashboard ──────────────────────────────────────────────
  Future<Map<String, dynamic>> getDashboardStats() async {
    final r = await _api.get('/admin/dashboard');
    return r.data;
  }

  // ── Users ──────────────────────────────────────────────────
  Future<List<UserModel>> getAllUsers({String? role}) async {
    final r = await _api.get('/admin/users',
        queryParameters: role != null ? {'role': role} : null);
    return (r.data['users'] as List)
        .map((u) => UserModel.fromJson(u))
        .toList();
  }

  Future<UserModel> createUser(Map<String, dynamic> data) async {
    final r = await _api.post('/admin/users', data: data);
    return UserModel.fromJson(r.data['user']);
  }

  Future<UserModel> updateUser(String id, Map<String, dynamic> data) async {
    final r = await _api.put('/admin/users/$id', data: data);
    return UserModel.fromJson(r.data['user']);
  }

  Future<void> deleteUser(String id) async {
    await _api.delete('/admin/users/$id');
  }

  // ── Classes ────────────────────────────────────────────────
  Future<List<ClassModel>> getAllClasses() async {
    final r = await _api.get('/admin/classes');
    return (r.data['classes'] as List)
        .map((c) => ClassModel.fromJson(c))
        .toList();
  }

  Future<ClassModel> createClass(Map<String, dynamic> data) async {
    final r = await _api.post('/admin/classes', data: data);
    return ClassModel.fromJson(r.data['class']);
  }

  Future<void> deleteClass(String id) async {
    await _api.delete('/admin/classes/$id');
  }

  Future<void> assignTeacherToClass(
      String classId, String teacherId, String subjectId) async {
    await _api.put('/admin/classes/$classId/assign', data: {
      'teacherId': teacherId,
      'subjectId': subjectId,
    });
  }

  /// Set a teacher as class teacher of a specific class
  Future<void> setClassTeacher(
      String teacherId, String classId) async {
    await _api.put('/admin/users/$teacherId', data: {
      'classTeacherId': classId,
    });
  }

  /// Remove a teacher's class teacher role
  Future<void> removeClassTeacher(String teacherId) async {
    await _api.put('/admin/users/$teacherId', data: {
      'removeClassTeacher': true,
    });
  }


  // ── Subjects ───────────────────────────────────────────────
  Future<List<SubjectModel>> getAllSubjects() async {
    final r = await _api.get('/admin/subjects');
    return (r.data['subjects'] as List)
        .map((s) => SubjectModel.fromJson(s))
        .toList();
  }

  Future<void> createSubject(Map<String, dynamic> data) async {
    await _api.post('/admin/subjects', data: data);
  }

  // ── Reports ────────────────────────────────────────────────
  Future<Map<String, dynamic>> getOverallReport({
    String? classId,
    String? startDate,
    String? endDate,
  }) async {
    final params = <String, dynamic>{};
    if (classId != null) params['classId'] = classId;
    if (startDate != null) params['startDate'] = startDate;
    if (endDate != null) params['endDate'] = endDate;

    final r = await _api.get('/admin/reports', queryParameters: params);
    return r.data;
  }
}
