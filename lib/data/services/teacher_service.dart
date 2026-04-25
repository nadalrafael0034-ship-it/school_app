import '../models/user_model.dart';
import '../models/class_model.dart';
import '../models/attendance_model.dart';
import 'api_service.dart';

class TeacherService {
  final _api = ApiService.instance.dio;

  Future<Map<String, dynamic>> getDashboard() async {
    final r = await _api.get('/teacher/dashboard');
    return r.data;
  }

  Future<List<ClassModel>> getMyClasses() async {
    final r = await _api.get('/teacher/classes');
    return (r.data['classes'] as List)
        .map((c) => ClassModel.fromJson(c))
        .toList();
  }

  Future<List<UserModel>> getClassStudents(String classId) async {
    final r = await _api.get('/teacher/classes/$classId/students');
    return (r.data['students'] as List)
        .map((s) => UserModel.fromJson(s))
        .toList();
  }

  /// Check if morning attendance is already submitted for today
  Future<Map<String, dynamic>> checkTodayAttendance(String classId) async {
    final r = await _api.get('/teacher/attendance/$classId/today');
    return r.data;
  }

  /// Submit morning first-period attendance (no subject needed)
  Future<void> markAttendance({
    required String classId,
    required String date,
    required List<AttendanceRecord> records,
  }) async {
    await _api.post('/teacher/attendance', data: {
      'classId': classId,
      'date': date,
      'records': records.map((r) => r.toJson()).toList(),
    });
  }

  Future<List<AttendanceSession>> getClassAttendance(String classId) async {
    final r = await _api.get('/teacher/attendance/$classId');
    return (r.data['attendance'] as List)
        .map((a) => AttendanceSession.fromJson(a))
        .toList();
  }

  Future<Map<String, dynamic>> getClassReport(String classId) async {
    final r = await _api.get('/teacher/reports/$classId');
    return r.data;
  }
}
