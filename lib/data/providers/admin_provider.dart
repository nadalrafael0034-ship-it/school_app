import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/class_model.dart';
import '../services/admin_service.dart';

class AdminProvider extends ChangeNotifier {
  final AdminService _service = AdminService();

  // ── State ──────────────────────────────────────────────────
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic> _dashboardStats = {};
  List<UserModel> _users = [];
  List<ClassModel> _classes = [];
  List<SubjectModel> _subjects = [];
  Map<String, dynamic> _reports = {};

  // ── Getters ────────────────────────────────────────────────
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic> get dashboardStats => _dashboardStats;
  List<UserModel> get users => _users;
  List<ClassModel> get classes => _classes;
  List<SubjectModel> get subjects => _subjects;
  Map<String, dynamic> get reports => _reports;

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  void _setError(String? e) {
    _error = e;
    notifyListeners();
  }

  // ── Dashboard ──────────────────────────────────────────────
  Future<void> fetchDashboard() async {
    _setLoading(true);
    try {
      _dashboardStats = await _service.getDashboardStats();
      _error = null;
    } catch (e) {
      _setError(e.toString());
    }
    _setLoading(false);
  }

  // ── Users ──────────────────────────────────────────────────
  Future<void> fetchUsers({String? role}) async {
    _setLoading(true);
    try {
      _users = await _service.getAllUsers(role: role);
      _error = null;
    } catch (e) {
      _setError(e.toString());
    }
    _setLoading(false);
  }

  Future<bool> createUser(Map<String, dynamic> data) async {
    try {
      final user = await _service.createUser(data);
      _users.insert(0, user);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> updateUser(String id, Map<String, dynamic> data) async {
    try {
      final updated = await _service.updateUser(id, data);
      final idx = _users.indexWhere((u) => u.id == id);
      if (idx != -1) _users[idx] = updated;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> deactivateUser(String id) async {
    try {
      await _service.deleteUser(id);
      _users.removeWhere((u) => u.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // ── Classes ────────────────────────────────────────────────
  Future<void> fetchClasses() async {
    _setLoading(true);
    try {
      _classes = await _service.getAllClasses();
      _error = null;
    } catch (e) {
      _setError(e.toString());
    }
    _setLoading(false);
  }

  Future<bool> createClass(Map<String, dynamic> data) async {
    try {
      final cls = await _service.createClass(data);
      _classes.add(cls);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> deleteClass(String id) async {
    try {
      await _service.deleteClass(id);
      _classes.removeWhere((c) => c.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // ── Subjects ───────────────────────────────────────────────
  Future<void> fetchSubjects() async {
    _setLoading(true);
    try {
      _subjects = await _service.getAllSubjects();
      _error = null;
    } catch (e) {
      _setError(e.toString());
    }
    _setLoading(false);
  }

  Future<bool> createSubject(Map<String, dynamic> data) async {
    try {
      await _service.createSubject(data);
      await fetchSubjects();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // ── Reports ────────────────────────────────────────────────
  Future<void> fetchReports({String? classId, String? startDate, String? endDate}) async {
    _setLoading(true);
    try {
      _reports = await _service.getOverallReport(
        classId: classId,
        startDate: startDate,
        endDate: endDate,
      );
      _error = null;
    } catch (e) {
      _setError(e.toString());
    }
    _setLoading(false);
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
