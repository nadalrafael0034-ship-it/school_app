import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/providers/admin_provider.dart';

class AddUserScreen extends StatefulWidget {
  const AddUserScreen({super.key});

  @override
  State<AddUserScreen> createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _rollCtrl = TextEditingController();
  final _empIdCtrl = TextEditingController();

  String _selectedRole = 'student';
  String? _selectedClassId;
  bool _obscurePassword = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchClasses();
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _phoneCtrl.dispose();
    _rollCtrl.dispose();
    _empIdCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final data = <String, dynamic>{
      'name': _nameCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
      'password': _passwordCtrl.text,
      'role': _selectedRole,
      if (_phoneCtrl.text.isNotEmpty) 'phone': _phoneCtrl.text.trim(),
      if (_selectedRole == 'student' && _rollCtrl.text.isNotEmpty)
        'rollNumber': _rollCtrl.text.trim(),
      if (_selectedRole == 'student' && _selectedClassId != null)
        'class': _selectedClassId,
      if (_selectedRole == 'teacher' && _empIdCtrl.text.isNotEmpty)
        'employeeId': _empIdCtrl.text.trim(),
    };

    final provider = context.read<AdminProvider>();
    final success = await provider.createUser(data);

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('User created successfully!'),
              backgroundColor: AppTheme.successColor),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(provider.error ?? 'Failed to create user'),
              backgroundColor: AppTheme.dangerColor),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final classes = context.watch<AdminProvider>().classes;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        title: const Text('Add New User'),
        backgroundColor: const Color(0xFF0F0F1A),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Role selector
              _sectionTitle('Role'),
              const SizedBox(height: 10),
              Row(
                children: ['student', 'teacher', 'admin'].map((role) {
                  final isSelected = _selectedRole == role;
                  final color = AppTheme.getRoleColor(role);
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedRole = role),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? color.withOpacity(0.2)
                              : AppTheme.cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? color : AppTheme.dividerColor,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            role.toUpperCase(),
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? color : Colors.white38,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 22),

              _sectionTitle('Basic Info'),
              const SizedBox(height: 10),
              _field(_nameCtrl, 'Full Name', Icons.person_outline,
                  validator: (v) => v!.isEmpty ? 'Required' : null),
              const SizedBox(height: 12),
              _field(_emailCtrl, 'Email Address', Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) =>
                      v!.isEmpty || !v.contains('@') ? 'Valid email required' : null),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordCtrl,
                obscureText: _obscurePassword,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline,
                      color: AppTheme.primaryColor, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Colors.white38,
                        size: 20),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                validator: (v) =>
                    v!.length < 6 ? 'Min 6 characters' : null,
              ),
              const SizedBox(height: 12),
              _field(_phoneCtrl, 'Phone (optional)', Icons.phone_outlined),

              // Student-specific fields
              if (_selectedRole == 'student') ...[
                const SizedBox(height: 22),
                _sectionTitle('Student Details'),
                const SizedBox(height: 10),
                _field(_rollCtrl, 'Roll Number', Icons.badge_outlined),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedClassId,
                  dropdownColor: AppTheme.cardColor,
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                  decoration: const InputDecoration(
                    labelText: 'Assign Class',
                    prefixIcon: Icon(Icons.class_outlined,
                        color: AppTheme.primaryColor, size: 20),
                  ),
                  items: classes
                      .map((c) => DropdownMenuItem(
                            value: c.id,
                            child: Text(c.displayName,
                                style: GoogleFonts.poppins(
                                    color: Colors.white, fontSize: 13)),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedClassId = v),
                ),
              ],

              // Teacher-specific fields
              if (_selectedRole == 'teacher') ...[
                const SizedBox(height: 22),
                _sectionTitle('Teacher Details'),
                const SizedBox(height: 10),
                _field(_empIdCtrl, 'Employee ID', Icons.work_outline),
              ],

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : Text('Create User',
                          style: GoogleFonts.poppins(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) => Text(title,
      style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white38,
          letterSpacing: 0.8));

  Widget _field(TextEditingController ctrl, String label, IconData icon,
      {TextInputType? keyboardType, String? Function(String?)? validator}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.primaryColor, size: 20),
      ),
      validator: validator,
    );
  }
}
