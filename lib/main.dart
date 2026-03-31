import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'data/providers/auth_provider.dart';
import 'data/providers/admin_provider.dart';
import 'data/providers/teacher_provider.dart';
import 'data/providers/student_provider.dart';
import 'features/auth/login_screen.dart';
import 'features/admin/admin_shell.dart';
import 'features/teacher/teacher_shell.dart';
import 'features/student/student_shell.dart';

void main() {
  runApp(const SchoolAttendanceApp());
}

class SchoolAttendanceApp extends StatelessWidget {
  const SchoolAttendanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
        ChangeNotifierProvider(create: (_) => TeacherProvider()),
        ChangeNotifierProvider(create: (_) => StudentProvider()),
      ],
      child: MaterialApp(
        title: 'EduAttend',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const AppRouter(),
      ),
    );
  }
}

/// Root router — listens to AuthProvider and redirects accordingly
class AppRouter extends StatefulWidget {
  const AppRouter({super.key});

  @override
  State<AppRouter> createState() => _AppRouterState();
}

class _AppRouterState extends State<AppRouter> {
  @override
  void initState() {
    super.initState();
    // Try auto-login on app start
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().tryAutoLogin();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    switch (auth.status) {
      case AuthStatus.initial:
      case AuthStatus.loading:
        return const _SplashScreen();

      case AuthStatus.authenticated:
        final role = auth.currentUser?.role ?? '';
        switch (role) {
          case 'admin':
            return const AdminShell();
          case 'teacher':
            return const TeacherShell();
          case 'student':
            return const StudentShell();
          default:
            return const LoginScreen();
        }

      case AuthStatus.unauthenticated:
      case AuthStatus.error:
        return const LoginScreen();
    }
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.4),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(Icons.school_rounded,
                  color: Colors.white, size: 48),
            ),
            const SizedBox(height: 24),
            const Text(
              'EduAttend',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Smart School Attendance System',
              style: TextStyle(color: Colors.white38, fontSize: 13),
            ),
            const SizedBox(height: 40),
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
