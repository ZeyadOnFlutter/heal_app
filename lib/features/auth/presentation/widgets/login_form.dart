import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/resources/assets_manager.dart';
import '../../../../core/resources/color_manager.dart';
import '../../../../core/resources/font_manager.dart';
import '../../../../core/resources/styles_manager.dart';
import '../../../../core/utils/validator.dart';
import '../../../../core/widgets/custom_elevated_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import 'auth_header.dart';
import 'auth_toggle_message.dart';

class LoginForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final FocusNode emailNode;
  final TextEditingController passwordController;
  final FocusNode passwordNode;
  final VoidCallback onLoginPressed;
  final VoidCallback onRegisterPressed;

  const LoginForm({
    required this.formKey,
    required this.emailController,
    required this.emailNode,
    required this.passwordController,
    required this.passwordNode,
    required this.onLoginPressed,
    required this.onRegisterPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 10.h),
              const AuthHeader(
                label1: 'Enter your email and password to log in ',
                label2: 'Sign In To Your Account',
              ),
              SizedBox(height: 30.h),
              CustomTextField(
                controller: emailController,
                focusNode: emailNode,
                nextFocus: passwordNode,
                hintText: 'Email',
                prefixIcon: SvgAssets.profile,
                textInputType: TextInputType.emailAddress,
                validator: Validator.validateEmail,
              ),
              SizedBox(height: 16.h),
              CustomTextField(
                focusNode: passwordNode,
                controller: passwordController,
                hintText: 'Password',
                prefixIcon: SvgAssets.lock,
                isObscured: true,
                textInputType: TextInputType.text,
                textInputFormatter: LengthLimitingTextInputFormatter(16),
                validator: Validator.isValidPassword,
              ),
              SizedBox(height: 40.h),
              AuthToggleMessage(
                label1: 'Don’t have an account?',
                label2: 'Register',
                onTap: onRegisterPressed,
              ),
              SizedBox(height: 24.h),
              CustomElevatedButton(label: 'Login', onTap: onLoginPressed),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}
