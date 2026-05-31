import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/resources/assets_manager.dart';
import '../../../../core/utils/validator.dart';
import '../../../../core/widgets/custom_elevated_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import 'auth_header.dart';
import 'auth_toggle_message.dart';

class RegisterForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final FocusNode nameNode;
  final TextEditingController phoneController;
  final FocusNode phoneNode;
  final TextEditingController emailController;
  final FocusNode emailNode;
  final TextEditingController passwordController;
  final FocusNode passwordNode;
  final TextEditingController confirmPasswordController;
  final FocusNode confirmPasswordNode;
  final VoidCallback onRegisterPressed;
  final VoidCallback onLoginPressed;
  final String selectedRole;
  final ValueChanged<String> onRoleChanged;

  const RegisterForm({
    required this.formKey,
    required this.nameController,
    required this.nameNode,
    required this.phoneController,
    required this.phoneNode,
    required this.emailController,
    required this.emailNode,
    required this.passwordController,
    required this.passwordNode,
    required this.confirmPasswordController,
    required this.confirmPasswordNode,
    required this.onRegisterPressed,
    required this.onLoginPressed,
    required this.selectedRole,
    required this.onRoleChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 10.h),
          const AuthHeader(label1: 'Sign Up Now', label2: 'Welcome'),
          SizedBox(height: 30.h),
          CustomTextField(
            controller: nameController,
            focusNode: nameNode,
            nextFocus: phoneNode,
            hintText: 'Full Name',
            textCapitalization: TextCapitalization.words,
            textInputFormatter: LengthLimitingTextInputFormatter(20),
            prefixIcon: SvgAssets.profile,
            textInputType: TextInputType.emailAddress,
            validator: Validator.validateUsername,
          ),
          SizedBox(height: 16.h),
          CustomTextField(
            controller: phoneController,
            focusNode: phoneNode,
            nextFocus: emailNode,
            hintText: 'Phone Number',
            prefixIcon: SvgAssets.phone,
            textInputType: TextInputType.emailAddress,
            validator: Validator.validateEgyptianPhoneNumber,
          ),
          SizedBox(height: 16.h),
          CustomTextField(
            controller: emailController,
            focusNode: emailNode,
            nextFocus: passwordNode,
            hintText: 'Email',
            prefixIcon: SvgAssets.sms,
            textInputType: TextInputType.emailAddress,
            validator: Validator.validateEmail,
          ),
          SizedBox(height: 16.h),
          CustomTextField(
            focusNode: passwordNode,
            controller: passwordController,
            nextFocus: confirmPasswordNode,
            hintText: 'Password',
            prefixIcon: SvgAssets.lock,
            isObscured: true,
            textInputType: TextInputType.text,
            textInputFormatter: LengthLimitingTextInputFormatter(16),
            validator: Validator.isValidPassword,
          ),
          SizedBox(height: 16.h),
          CustomTextField(
            focusNode: confirmPasswordNode,
            controller: confirmPasswordController,
            hintText: ' ConFirm Password',
            prefixIcon: SvgAssets.lock,
            isObscured: true,
            textInputType: TextInputType.text,
            textInputFormatter: LengthLimitingTextInputFormatter(16),
            validator: (value) => Validator.validateConfirmPassword(value, passwordController.text),
          ),
          SizedBox(height: 16.h),
          DropdownButtonFormField<String>(
            initialValue: selectedRole,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
            items: const [
              DropdownMenuItem(value: 'patient', child: Text('Patient')),
              DropdownMenuItem(value: 'doctor', child: Text('Doctor')),
              DropdownMenuItem(value: 'admin', child: Text('Admin')),
            ],
            onChanged: (v) => onRoleChanged(v!),
          ),
          SizedBox(height: 30.h),
          AuthToggleMessage(
            label1: 'Already have an account?',
            label2: 'Login',
            onTap: onLoginPressed,
          ),
          SizedBox(height: 24.h),
          CustomElevatedButton(label: 'Register', onTap: onRegisterPressed),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }
}
