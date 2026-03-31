import 'package:flutter/material.dart';
import '../models/attendance_model.dart';
import '../services/student_service.dart';

class StudentProvider extends ChangeNotifier {
  final StudentService _service = StudentService();

  bool _isLoading = false;
  String? _error;

  Map<String, dynamic> _dashboard = {};
  List<StudentAttendanceRecord> _attendanceRecords = [];
  Map<String, dynamic> _stats = {};

  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic> get dashboard => _dashboard;
  List<StudentAttendanceRecord> get attendanceRecords => _attendanceRecords;
  Map<String, dynamic> get stats => _stats;

  // Computed getters from dashboard
  int get overallTotal => (_dashboard['overall']?['totalSessions'] ?? 0) as int;
  int get overallPresent => (_dashboard['overall']?['present'] ?? 0) as int;
  int get overallAbsent => (_dashboard['overall']?['absent'] ?? 0) as int;
  int get overallPercentage => (_dashboard['overall']?['percentage'] ?? 0) as int;

  void _setLoading(bool v) { _isLoading = v; notifyListeners(); }
  void _setError(String? e) { _error = e; notifyListeners(); }

  Future<void> fetchDashboard() async {
    _setLoading(true);
    try {
      _dashboard = await _service.getDashboard();
      _error = null;
    } catch (e) { _setError(e.toString()); }
    _setLoading(false);
  }

  Future<void> fetchAttendance({String? subjectId, String? startDate, String? endDate}) async {
    _setLoading(true);
    try {
      _attendanceRecords = await _service.getMyAttendance(
        subjectId: subjectId,
        startDate: startDate,
        endDate: endDate,
      );
      _error = null;
    } catch (e) { _setError(e.toString()); }
    _setLoading(false);
  }

  Future<void> fetchStats() async {
    _setLoading(true);
    try {
      _stats = await _service.getMyStats();
      _error = null;
    } catch (e) { _setError(e.toString()); }
    _setLoading(false);
  }

  void clearError() { _error = null; notifyListeners(); }
}
