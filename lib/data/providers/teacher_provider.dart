import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/class_model.dart';
import '../models/attendance_model.dart';
import '../services/teacher_service.dart';

class TeacherProvider extends ChangeNotifier {
  final TeacherService _service = TeacherService();

  bool _isLoading = false;
  String? _error;

  Map<String, dynamic> _dashboard = {};
  List<ClassModel> _myClasses = [];
  List<UserModel> _selectedClassStudents = [];
  List<AttendanceSession> _classAttendance = [];
  Map<String, dynamic> _classReport = {};

  // Morning attendance state
  ClassModel? _selectedClass;
  DateTime _attendanceDate = DateTime.now();
  List<AttendanceRecord> _attendanceRecords = [];

  // Whether today's attendance is already submitted for the selected class
  bool _todayAlreadySubmitted = false;
  bool _checkingToday = false;

  // The currently logged-in user's ID (set from outside via setCurrentUserId)
  String? _currentUserId;

  bool get isLoading => _isLoading;
  bool get checkingToday => _checkingToday;
  String? get error => _error;
  Map<String, dynamic> get dashboard => _dashboard;
  List<ClassModel> get myClasses => _myClasses;
  List<UserModel> get selectedClassStudents => _selectedClassStudents;
  List<AttendanceSession> get classAttendance => _classAttendance;
  Map<String, dynamic> get classReport => _classReport;
  ClassModel? get selectedClass => _selectedClass;
  DateTime get attendanceDate => _attendanceDate;
  List<AttendanceRecord> get attendanceRecords => _attendanceRecords;
  bool get todayAlreadySubmitted => _todayAlreadySubmitted;

  /// Classes where this teacher is the designated class teacher
  List<ClassModel> get classTeacherClasses => _myClasses
      .where((c) => c.classTeacherId != null &&
          _currentUserId != null &&
          c.classTeacherId == _currentUserId)
      .toList();

  void setCurrentUserId(String? id) {
    _currentUserId = id;
  }

  bool isClassTeacherOf(ClassModel cls) {
    return cls.classTeacherId != null &&
        _currentUserId != null &&
        cls.classTeacherId == _currentUserId;
  }

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  void _setError(String? e) {
    _error = e;
    notifyListeners();
  }

  Future<void> fetchDashboard() async {
    _setLoading(true);
    try {
      _dashboard = await _service.getDashboard();
      _error = null;
    } catch (e) {
      _setError(e.toString());
    }
    _setLoading(false);
  }

  Future<void> fetchMyClasses() async {
    _setLoading(true);
    try {
      _myClasses = await _service.getMyClasses();
      _error = null;
    } catch (e) {
      _setError(e.toString());
    }
    _setLoading(false);
  }

  Future<void> selectClass(ClassModel cls) async {
    _selectedClass = cls;
    _selectedClassStudents = [];
    _attendanceRecords = [];
    _todayAlreadySubmitted = false;
    notifyListeners();

    // Fetch students and check today's attendance in parallel
    await Future.wait([
      _fetchStudents(cls.id),
      _checkTodayAttendance(cls.id),
    ]);
  }

  Future<void> _fetchStudents(String classId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _selectedClassStudents = await _service.getClassStudents(classId);
      // Default all students to 'present'
      _attendanceRecords = _selectedClassStudents
          .map((s) => AttendanceRecord(studentId: s.id, status: 'present'))
          .toList();
      _error = null;
    } catch (e) {
      _setError(e.toString());
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _checkTodayAttendance(String classId) async {
    _checkingToday = true;
    notifyListeners();
    try {
      final result = await _service.checkTodayAttendance(classId);
      _todayAlreadySubmitted = result['submitted'] == true;
    } catch (_) {
      _todayAlreadySubmitted = false;
    }
    _checkingToday = false;
    notifyListeners();
  }

  void updateStudentStatus(String studentId, String status) {
    final idx = _attendanceRecords.indexWhere((r) => r.studentId == studentId);
    if (idx != -1) {
      _attendanceRecords[idx].status = status;
      notifyListeners();
    }
  }

  Future<bool> submitAttendance() async {
    if (_selectedClass == null) return false;
    _setLoading(true);
    try {
      await _service.markAttendance(
        classId: _selectedClass!.id,
        date: _attendanceDate.toIso8601String().substring(0, 10),
        records: _attendanceRecords,
      );
      _todayAlreadySubmitted = true;
      _error = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<void> fetchClassAttendance(String classId) async {
    _setLoading(true);
    try {
      _classAttendance = await _service.getClassAttendance(classId);
      _error = null;
    } catch (e) {
      _setError(e.toString());
    }
    _setLoading(false);
  }

  Future<void> fetchClassReport(String classId) async {
    _setLoading(true);
    try {
      _classReport = await _service.getClassReport(classId);
      _error = null;
    } catch (e) {
      _setError(e.toString());
    }
    _setLoading(false);
  }

  void resetAttendanceForm() {
    _selectedClass = null;
    _selectedClassStudents = [];
    _attendanceRecords = [];
    _attendanceDate = DateTime.now();
    _todayAlreadySubmitted = false;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
