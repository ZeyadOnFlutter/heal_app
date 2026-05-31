import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/validator.dart';
import '../../auth/data/models/user_model.dart';

const _bg = Color(0xFF0A0E1A);
const _card = Color(0xFF1A2235);
const _cyan = Color(0xFF00E5FF);
const _border = Color(0xFF1E2D45);

class UserFormDialog extends StatefulWidget {
  final UserModel? user;
  const UserFormDialog({super.key, this.user});

  @override
  State<UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<UserFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _password;
  late final TextEditingController _confirmPassword;
  late String _role;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  bool get _isEdit => widget.user != null;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.user?.name ?? '');
    _email = TextEditingController(text: widget.user?.email ?? '');
    _phone = TextEditingController(text: widget.user?.phone ?? '');
    _password = TextEditingController();
    _confirmPassword = TextEditingController();
    _role = widget.user?.role ?? 'patient';
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: _cyan.withOpacity(0.25)),
          boxShadow: [BoxShadow(color: _cyan.withOpacity(0.08), blurRadius: 24, spreadRadius: 2)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 24.h),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildField(
                        controller: _name,
                        label: 'Full Name',
                        icon: Icons.person_outline_rounded,
                        inputFormatters: [LengthLimitingTextInputFormatter(40)],
                        validator: Validator.validateUsername,
                      ),
                      SizedBox(height: 14.h),
                      _buildField(
                        controller: _email,
                        label: 'Email',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: Validator.validateEmail,
                      ),
                      SizedBox(height: 14.h),
                      _buildField(
                        controller: _phone,
                        label: 'Phone (+20...)',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator: Validator.validateEgyptianPhoneNumber,
                      ),
                      if (!_isEdit) ...[
                        SizedBox(height: 14.h),
                        _buildField(
                          controller: _password,
                          label: 'Password',
                          icon: Icons.lock_outline_rounded,
                          obscureText: _obscurePassword,
                          validator: Validator.isValidPassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: Colors.white38,
                              size: 18.sp,
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        SizedBox(height: 14.h),
                        _buildField(
                          controller: _confirmPassword,
                          label: 'Confirm Password',
                          icon: Icons.lock_outline_rounded,
                          obscureText: _obscureConfirm,
                          validator: (v) => Validator.validateConfirmPassword(v, _password.text),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: Colors.white38,
                              size: 18.sp,
                            ),
                            onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                          ),
                        ),
                      ],
                      SizedBox(height: 14.h),
                      _buildRoleSelector(),
                      SizedBox(height: 24.h),
                      _buildActions(context),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: _cyan.withOpacity(0.15))),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: _cyan.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: _cyan.withOpacity(0.3)),
            ),
            child: Icon(_isEdit ? Icons.edit_rounded : Icons.person_add_rounded, color: _cyan, size: 18.sp),
          ),
          SizedBox(width: 12.w),
          Text(
            _isEdit ? 'Edit User' : 'Create User',
            style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w700, letterSpacing: 0.5),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.all(6.r),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(Icons.close_rounded, color: Colors.white38, size: 18.sp),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      inputFormatters: inputFormatters,
      style: TextStyle(color: Colors.white, fontSize: 13.sp),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white38, fontSize: 12.sp),
        prefixIcon: Icon(icon, color: _cyan.withOpacity(0.7), size: 18.sp),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: _bg.withOpacity(0.6),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: _border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: _cyan.withOpacity(0.6)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        errorStyle: TextStyle(color: Colors.redAccent, fontSize: 10.sp),
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      ),
    );
  }

  Widget _buildRoleSelector() {
    final roles = [
      ('patient', _green, Icons.personal_injury_outlined),
      ('doctor', Colors.blueAccent, Icons.medical_services_outlined),
      ('admin', _purple, Icons.shield_outlined),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Role', style: TextStyle(color: Colors.white38, fontSize: 12.sp)),
        SizedBox(height: 8.h),
        Row(
          children: roles.map((r) {
            final selected = _role == r.$1;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _role = r.$1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: EdgeInsets.only(right: r.$1 != 'admin' ? 8.w : 0),
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  decoration: BoxDecoration(
                    color: selected ? r.$2.withOpacity(0.15) : _bg.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: selected ? r.$2 : _border),
                  ),
                  child: Column(
                    children: [
                      Icon(r.$3, color: selected ? r.$2 : Colors.white24, size: 18.sp),
                      SizedBox(height: 4.h),
                      Text(
                        '${r.$1[0].toUpperCase()}${r.$1.substring(1)}',
                        style: TextStyle(
                          color: selected ? r.$2 : Colors.white38,
                          fontSize: 11.sp,
                          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 13.h),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: _border),
              ),
              alignment: Alignment.center,
              child: Text('Cancel', style: TextStyle(color: Colors.white54, fontSize: 13.sp, fontWeight: FontWeight.w600)),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: GestureDetector(
            onTap: () {
              if (_formKey.currentState?.validate() ?? false) {
                final user = UserModel(
                  id: widget.user?.id ?? '',
                  name: _name.text.trim(),
                  email: _email.text.trim(),
                  phone: _phone.text.trim(),
                  role: _role,
                );
                Navigator.pop(context, {
                  'user': user,
                  'password': _password.text,
                  'oldRole': widget.user?.role ?? _role,
                });
              }
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 13.h),
              decoration: BoxDecoration(
                color: _cyan.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: _cyan.withOpacity(0.5)),
                boxShadow: [BoxShadow(color: _cyan.withOpacity(0.15), blurRadius: 8)],
              ),
              alignment: Alignment.center,
              child: Text(
                _isEdit ? 'Update' : 'Create',
                style: TextStyle(color: _cyan, fontSize: 13.sp, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

const _green = Color(0xFF00E676);
const _purple = Color(0xFF7C3AED);
