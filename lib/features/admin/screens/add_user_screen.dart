import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/providers/admin_provider.dart';

class AddUserScreen extends StatefulWidget {
  /// Pass a UserModel-like map to pre-fill fields for editing.
  final Map<String, dynamic>? editUser;

  const AddUserScreen({super.key, this.editUser});

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
  String? _selectedClassId;       // For students: their class
  String? _classTeacherClassId;   // For teachers: class they are class teacher of
  bool _isClassTeacher = false;
  bool _obscurePassword = true;
  bool _isSubmitting = false;

  bool get _isEditing => widget.editUser != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchClasses();
    });

    // Pre-fill if editing
    if (_isEditing) {
      final u = widget.editUser!;
      _nameCtrl.text = u['name'] ?? '';
      _emailCtrl.text = u['email'] ?? '';
      _phoneCtrl.text = u['phone'] ?? '';
      _rollCtrl.text = u['rollNumber'] ?? '';
      _empIdCtrl.text = u['employeeId'] ?? '';
      _selectedRole = u['role'] ?? 'student';
      _selectedClassId = u['classId'];
      _classTeacherClassId = u['classTeacherClassId'];
      _isClassTeacher = _classTeacherClassId != null;
    }
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
      'role': _selectedRole,
      if (_phoneCtrl.text.isNotEmpty) 'phone': _phoneCtrl.text.trim(),
      if (_selectedRole == 'student' && _rollCtrl.text.isNotEmpty)
        'rollNumber': _rollCtrl.text.trim(),
      if (_selectedRole == 'student' && _selectedClassId != null)
        'class': _selectedClassId,
      if (_selectedRole == 'teacher' && _empIdCtrl.text.isNotEmpty)
        'employeeId': _empIdCtrl.text.trim(),
      // Class teacher assignment
      if (_selectedRole == 'teacher' && _isClassTeacher && _classTeacherClassId != null)
        'classTeacherId': _classTeacherClassId,
      if (_selectedRole == 'teacher' && !_isClassTeacher && _isEditing)
        'removeClassTeacher': true,
    };

    if (!_isEditing) {
      data['password'] = _passwordCtrl.text;
    }

    final provider = context.read<AdminProvider>();
    bool success;
    if (_isEditing) {
      success = await provider.updateUser(widget.editUser!['id'], data);
    } else {
      success = await provider.createUser(data);
    }

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(_isEditing
                  ? 'User updated successfully!'
                  : 'User created successfully!'),
              backgroundColor: AppTheme.successColor),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(provider.error ?? 'Operation failed'),
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
        title: Text(_isEditing ? 'Edit User' : 'Add New User'),
        backgroundColor: const Color(0xFF0F0F1A),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Role selector (locked when editing)
              _sectionTitle('Role'),
              const SizedBox(height: 10),
              Row(
                children: ['student', 'teacher', 'admin'].map((role) {
                  final isSelected = _selectedRole == role;
                  final color = AppTheme.getRoleColor(role);
                  return Expanded(
                    child: GestureDetector(
                      onTap: _isEditing
                          ? null
                          : () => setState(() {
                                _selectedRole = role;
                                _isClassTeacher = false;
                                _classTeacherClassId = null;
                              }),
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
              if (!_isEditing) ...[
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
              ],
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
                const SizedBox(height: 16),

                // ── Class Teacher Toggle ──────────────────────────
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _isClassTeacher
                        ? AppTheme.teacherColor.withOpacity(0.1)
                        : AppTheme.cardColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _isClassTeacher
                          ? AppTheme.teacherColor.withOpacity(0.5)
                          : AppTheme.dividerColor,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppTheme.teacherColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.stars_rounded,
                                color: AppTheme.teacherColor, size: 18),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Class Teacher',
                                    style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13)),
                                Text(
                                    'Can take daily morning roll call',
                                    style: GoogleFonts.poppins(
                                        color: Colors.white38, fontSize: 11)),
                              ],
                            ),
                          ),
                          Switch(
                            value: _isClassTeacher,
                            onChanged: (v) => setState(() {
                              _isClassTeacher = v;
                              if (!v) _classTeacherClassId = null;
                            }),
                            activeColor: AppTheme.teacherColor,
                            inactiveTrackColor: Colors.white12,
                          ),
                        ],
                      ),
                      if (_isClassTeacher) ...[
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _classTeacherClassId,
                          dropdownColor: AppTheme.cardColor,
                          style: GoogleFonts.poppins(
                              color: Colors.white, fontSize: 13),
                          decoration: InputDecoration(
                            labelText: 'Assign as Class Teacher of',
                            labelStyle: GoogleFonts.poppins(
                                color: Colors.white38, fontSize: 12),
                            prefixIcon: const Icon(Icons.class_outlined,
                                color: AppTheme.teacherColor, size: 18),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                          ),
                          items: classes
                              .map((c) => DropdownMenuItem(
                                    value: c.id,
                                    child: Text(c.displayName,
                                        style: GoogleFonts.poppins(
                                            color: Colors.white, fontSize: 13)),
                                  ))
                              .toList(),
                          validator: (v) => _isClassTeacher && v == null
                              ? 'Select a class'
                              : null,
                          onChanged: (v) =>
                              setState(() => _classTeacherClassId = v),
                        ),
                      ],
                    ],
                  ),
                ),
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
                      : Text(
                          _isEditing ? 'Save Changes' : 'Create User',
                          style: GoogleFonts.poppins(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 20),
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
