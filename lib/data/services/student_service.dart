import '../models/attendance_model.dart';
import 'api_service.dart';

class StudentService {
  final _api = ApiService.instance.dio;

  Future<Map<String, dynamic>> getDashboard() async {
    final r = await _api.get('/student/dashboard');
    return r.data;
  }

  Future<List<StudentAttendanceRecord>> getMyAttendance(
      {String? subjectId, String? startDate, String? endDate}) async {
    final params = <String, dynamic>{};
    if (subjectId != null) params['subjectId'] = subjectId;
    if (startDate != null) params['startDate'] = startDate;
    if (endDate != null) params['endDate'] = endDate;

    final r = await _api.get('/student/attendance', queryParameters: params);
    return (r.data['records'] as List)
        .map((a) => StudentAttendanceRecord.fromJson(a))
        .toList();
  }

  Future<Map<String, dynamic>> getMyStats() async {
    final r = await _api.get('/student/stats');
    return r.data;
  }
}
