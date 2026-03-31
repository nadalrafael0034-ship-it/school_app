import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../../core/utils/storage_service.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthStatus _status = AuthStatus.initial;
  UserModel? _currentUser;
  String? _errorMessage;

  AuthStatus get status => _status;
  UserModel? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == AuthStatus.loading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  // ── Auto-login on app start ──────────────────────────────────
  Future<void> tryAutoLogin() async {
    final hasToken = await StorageService.hasToken();
    if (!hasToken) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }
    try {
      _status = AuthStatus.loading;
      notifyListeners();
      _currentUser = await _authService.getMe();
      _status = AuthStatus.authenticated;
    } catch (_) {
      await StorageService.deleteToken();
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  // ── Login ────────────────────────────────────────────────────
  Future<bool> login(String email, String password) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      final data = await _authService.login(email, password);
      await StorageService.saveToken(data['token']);
      _currentUser = UserModel.fromJson(data['user']);
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _errorMessage = e.response?.data?['message'] ?? 'Login failed. Check credentials.';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = 'An unexpected error occurred.';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  // ── Logout ───────────────────────────────────────────────────
  Future<void> logout() async {
    await StorageService.deleteToken();
    _currentUser = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  // ── Change Password ──────────────────────────────────────────
  Future<String?> changePassword(String current, String newPw) async {
    try {
      await _authService.changePassword(current, newPw);
      return null; // null = success
    } on DioException catch (e) {
      return e.response?.data?['message'] ?? 'Password change failed.';
    }
  }

  void clearError() {
    _errorMessage = null;
    if (_status == AuthStatus.error) _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
