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

  // Attendance marking state
  ClassModel? _selectedClass;
  SubjectModel? _selectedSubject;
  DateTime _attendanceDate = DateTime.now();
  List<AttendanceRecord> _attendanceRecords = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic> get dashboard => _dashboard;
  List<ClassModel> get myClasses => _myClasses;
  List<UserModel> get selectedClassStudents => _selectedClassStudents;
  List<AttendanceSession> get classAttendance => _classAttendance;
  Map<String, dynamic> get classReport => _classReport;
  ClassModel? get selectedClass => _selectedClass;
  SubjectModel? get selectedSubject => _selectedSubject;
  DateTime get attendanceDate => _attendanceDate;
  List<AttendanceRecord> get attendanceRecords => _attendanceRecords;

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

  Future<void> fetchMyClasses() async {
    _setLoading(true);
    try {
      _myClasses = await _service.getMyClasses();
      _error = null;
    } catch (e) { _setError(e.toString()); }
    _setLoading(false);
  }

  Future<void> fetchClassStudents(String classId) async {
    _setLoading(true);
    try {
      _selectedClassStudents = await _service.getClassStudents(classId);
      // Initialize attendance records
      _attendanceRecords = _selectedClassStudents
          .map((s) => AttendanceRecord(studentId: s.id, status: 'present'))
          .toList();
      _error = null;
    } catch (e) { _setError(e.toString()); }
    _setLoading(false);
  }

  void selectClass(ClassModel? cls) {
    _selectedClass = cls;
    _selectedSubject = null;
    _selectedClassStudents = [];
    _attendanceRecords = [];
    notifyListeners();
  }

  void selectSubject(SubjectModel? subject) {
    _selectedSubject = subject;
    notifyListeners();
  }

  void setAttendanceDate(DateTime date) {
    _attendanceDate = date;
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
    if (_selectedClass == null || _selectedSubject == null) return false;
    _setLoading(true);
    try {
      await _service.markAttendance(
        classId: _selectedClass!.id,
        subjectId: _selectedSubject!.id,
        date: _attendanceDate.toIso8601String().substring(0, 10),
        records: _attendanceRecords,
      );
      _error = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<void> fetchClassAttendance(String classId, {String? subjectId}) async {
    _setLoading(true);
    try {
      _classAttendance = await _service.getClassAttendance(classId, subjectId: subjectId);
      _error = null;
    } catch (e) { _setError(e.toString()); }
    _setLoading(false);
  }

  Future<void> fetchClassReport(String classId) async {
    _setLoading(true);
    try {
      _classReport = await _service.getClassReport(classId);
      _error = null;
    } catch (e) { _setError(e.toString()); }
    _setLoading(false);
  }

  void resetAttendanceForm() {
    _selectedClass = null;
    _selectedSubject = null;
    _selectedClassStudents = [];
    _attendanceRecords = [];
    _attendanceDate = DateTime.now();
    notifyListeners();
  }

  void clearError() { _error = null; notifyListeners(); }
}
