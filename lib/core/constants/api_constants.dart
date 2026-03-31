import 'package:flutter/foundation.dart';

class ApiConstants {
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:5000/api';
    if (defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      return 'http://localhost:5000/api';
    }
    // Android emulator — change to your PC LAN IP for real device e.g. http://192.168.1.5:5000/api
    return 'http://10.0.2.2:5000/api';
  }

  // Auth
  static const String login = '/auth/login';
  static const String me = '/auth/me';
  static const String changePassword = '/auth/change-password';

  // Admin
  static const String adminDashboard = '/admin/dashboard';
  static const String adminUsers = '/admin/users';
  static const String adminClasses = '/admin/classes';
  static const String adminSubjects = '/admin/subjects';
  static const String adminReports = '/admin/reports';

  // Teacher
  static const String teacherDashboard = '/teacher/dashboard';
  static const String teacherClasses = '/teacher/classes';
  static const String teacherAttendance = '/teacher/attendance';
  static const String teacherReports = '/teacher/reports';

  // Student
  static const String studentDashboard = '/student/dashboard';
  static const String studentAttendance = '/student/attendance';
  static const String studentStats = '/student/stats';
}
