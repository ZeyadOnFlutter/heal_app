import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/service/service_locator.dart';
import '../../../../core/utils/validator.dart';
import '../../../admin/view/admin_dashboard.dart';
import '../../../ai/view/doctor_dashboard.dart';
import '../../../ai/view/medical_nav_bar.dart';
import '../../domain/entities/user_entity.dart';
import '../cubit/auth_hydrated_cubit.dart';
import '../cubit/auth_state.dart';
import 'regsiter.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _emailController = TextEditingController();
  final _emailNode = FocusNode();
  final _passwordController = TextEditingController();
  final _passwordNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  bool _passwordHidden = true;
  late StreamSubscription<bool> _keyboardSub;

  @override
  void initState() {
    super.initState();
    _keyboardSub = KeyboardVisibilityController().onChange.listen((visible) {
      if (!visible) FocusManager.instance.primaryFocus?.unfocus();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _emailNode.dispose();
    _passwordController.dispose();
    _passwordNode.dispose();
    _keyboardSub.cancel();
    super.dispose();
  }

  void _onLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      await getIt<AuthCubit>().login(_emailController.text, _passwordController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthLoading) {
          _showLoading();
        } else if (state is AuthError) {
          if (Navigator.of(context, rootNavigator: true).canPop()) {
            Navigator.of(context, rootNavigator: true).pop();
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        } else if (state is Authenticated) {
          if (Navigator.of(context, rootNavigator: true).canPop()) {
            Navigator.of(context, rootNavigator: true).pop();
          }
          final destination = switch (state.user.role) {
            UserRole.admin  => const AdminDashboard(),
            UserRole.doctor => const DoctorDashboard(),
            _               => const MedicalNavBar(),
          };
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => destination),
            (r) => false,
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            children: [
              // ── Gradient Hero ──────────────────────────────────
              Container(
                height: 280.h,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1565C0), Color(0xFF7B1FA2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.all(28.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: Icon(Icons.health_and_safety_rounded, color: Colors.white, size: 32.sp),
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'Welcome Back',
                          style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Sign in to continue your health journey',
                          style: TextStyle(fontSize: 14.sp, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Form ───────────────────────────────────────────
              Padding(
                padding: EdgeInsets.all(24.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 8.h),
                      _AuthField(
                        controller: _emailController,
                        focusNode: _emailNode,
                        nextFocus: _passwordNode,
                        hint: 'Email address',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: Validator.validateEmail,
                      ),
                      SizedBox(height: 14.h),
                      _AuthField(
                        controller: _passwordController,
                        focusNode: _passwordNode,
                        hint: 'Password',
                        icon: Icons.lock_outline_rounded,
                        obscure: _passwordHidden,
                        inputFormatter: LengthLimitingTextInputFormatter(16),
                        validator: Validator.isValidPassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _passwordHidden ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: Colors.grey,
                            size: 20.sp,
                          ),
                          onPressed: () => setState(() => _passwordHidden = !_passwordHidden),
                        ),
                      ),
                      SizedBox(height: 32.h),
                      _GradientButton(label: 'Sign In', onTap: _onLogin),
                      SizedBox(height: 20.h),
                      _ToggleText(
                        label: "Don't have an account? ",
                        actionLabel: 'Register',
                        onTap: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const Register()),
                        ),
                      ),
                      SizedBox(height: 24.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLoading() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
  }
}

// ── Shared Auth Widgets ────────────────────────────────────────────────────

class _AuthField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final FocusNode? nextFocus;
  final String hint;
  final IconData icon;
  final bool obscure;
  final TextInputType? keyboardType;
  final TextInputFormatter? inputFormatter;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;

  const _AuthField({
    required this.controller,
    required this.focusNode,
    required this.hint,
    required this.icon,
    this.nextFocus,
    this.obscure = false,
    this.keyboardType,
    this.inputFormatter,
    this.validator,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscure,
      keyboardType: keyboardType,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      textInputAction: nextFocus != null ? TextInputAction.next : TextInputAction.done,
      inputFormatters: inputFormatter != null ? [inputFormatter!] : [],
      validator: validator,
      onEditingComplete: () {
        focusNode.unfocus();
        if (nextFocus != null) FocusScope.of(context).requestFocus(nextFocus);
      },
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14.sp),
        prefixIcon: Icon(icon, color: Colors.grey.shade400, size: 20.sp),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: const BorderSide(color: Color(0xFF1565C0), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _GradientButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF7B1FA2)],
        ),
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1565C0).withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          minimumSize: Size(double.infinity, 52.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}

class _ToggleText extends StatelessWidget {
  final String label;
  final String actionLabel;
  final VoidCallback onTap;
  const _ToggleText({required this.label, required this.actionLabel, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RichText(
        text: TextSpan(
          text: label,
          style: TextStyle(color: Colors.grey, fontSize: 14.sp),
          children: [
            WidgetSpan(
              child: GestureDetector(
                onTap: onTap,
                child: Text(
                  actionLabel,
                  style: TextStyle(
                    color: const Color(0xFF1565C0),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
