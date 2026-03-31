import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/providers/auth_provider.dart';
import '../widgets/role_badge.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    if (user == null) return const SizedBox();

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color(0xFF0F0F1A),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ── Avatar ──────────────────────────────────────────
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.getRoleColor(user.role),
                    AppTheme.getRoleColor(user.role).withOpacity(0.5),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  user.initials,
                  style: GoogleFonts.poppins(
                      fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(user.name,
                style: GoogleFonts.poppins(
                    fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)),
            const SizedBox(height: 6),
            RoleBadge(role: user.role),
            const SizedBox(height: 30),

            // ── Info Cards ────────────────────────────────────────
            _infoTile(Icons.email_outlined, 'Email', user.email),
            if (user.phone != null) _infoTile(Icons.phone_outlined, 'Phone', user.phone!),
            if (user.rollNumber != null)
              _infoTile(Icons.badge_outlined, 'Roll Number', user.rollNumber!),
            if (user.employeeId != null)
              _infoTile(Icons.work_outline, 'Employee ID', user.employeeId!),
            if (user.classInfo != null)
              _infoTile(Icons.class_outlined, 'Class', user.classInfo!.displayName),

            const SizedBox(height: 24),

            // ── Change Password ───────────────────────────────────
            _actionButton(
              context,
              icon: Icons.lock_outline,
              label: 'Change Password',
              color: AppTheme.primaryColor,
              onTap: () => _showChangePasswordDialog(context, auth),
            ),
            const SizedBox(height: 12),

            // ── Logout ────────────────────────────────────────────
            _actionButton(
              context,
              icon: Icons.logout,
              label: 'Logout',
              color: AppTheme.dangerColor,
              onTap: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    backgroundColor: AppTheme.cardColor,
                    title: Text('Logout',
                        style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
                    content: Text('Are you sure you want to logout?',
                        style: GoogleFonts.poppins(color: Colors.white70)),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel')),
                      TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text('Logout',
                              style: TextStyle(color: AppTheme.dangerColor))),
                    ],
                  ),
                );
                if (confirm == true) auth.logout();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 20),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: GoogleFonts.poppins(fontSize: 11, color: Colors.white38)),
              Text(value,
                  style:
                      GoogleFonts.poppins(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionButton(BuildContext context,
      {required IconData icon,
      required String label,
      required Color color,
      required VoidCallback onTap}) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: color),
        label: Text(label, style: GoogleFonts.poppins(color: color, fontWeight: FontWeight.w600)),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color.withOpacity(0.5)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context, AuthProvider auth) {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setState) {
          bool changing = false;
          return AlertDialog(
            backgroundColor: AppTheme.cardColor,
            title: Text('Change Password',
                style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: currentCtrl,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: 'Current Password'),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: newCtrl,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: 'New Password'),
                    validator: (v) =>
                        v!.length < 6 ? 'Min 6 characters' : null,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel')),
              ElevatedButton(
                onPressed: changing
                    ? null
                    : () async {
                        if (!formKey.currentState!.validate()) return;
                        setState(() => changing = true);
                        final err = await auth.changePassword(
                            currentCtrl.text, newCtrl.text);
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(err ?? 'Password changed successfully!'),
                          backgroundColor: err == null ? AppTheme.successColor : AppTheme.dangerColor,
                        ));
                      },
                child: const Text('Change'),
              ),
            ],
          );
        },
      ),
    );
  }
}
