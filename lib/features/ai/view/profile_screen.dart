import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../features/auth/domain/entities/user_entity.dart';
import '../../../features/auth/presentation/cubit/auth_hydrated_cubit.dart';
import '../../../features/auth/presentation/cubit/auth_state.dart';
import '../../auth/presentation/view/login.dart';
import '../../chat/rating_widget.dart';
import 'consent_dialog.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          final user = state is Authenticated ? state.user : null;
          return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: Column(
            children: [
              // ── Gradient Header ──────────────────────────────────
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1565C0), Color(0xFF7B1FA2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 32.h),
                    child: Column(
                      children: [
                        // Avatar
                        Container(
                          padding: EdgeInsets.all(4.w),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withOpacity(0.6), width: 2.5),
                          ),
                          child: CircleAvatar(
                            radius: 44.r,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            child: Icon(Icons.person_rounded, size: 48.sp, color: Colors.white),
                          ),
                        ),
                        SizedBox(height: 14.h),
                        Text(
                          user?.name ?? '',
                          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        SizedBox(height: 4.h),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            (user?.role.name ?? 'patient').toUpperCase(),
                            style: TextStyle(fontSize: 11.sp, color: Colors.white, fontWeight: FontWeight.w600, letterSpacing: 1),
                          ),
                        ),
                        SizedBox(height: 10.h),
                        if (user != null)
                          RatingWidget(userId: user.id, color: Colors.amber),
                        SizedBox(height: 20.h),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Info Cards ───────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    children: [
                      SizedBox(height: 8.h),
                      _InfoCard(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        value: user?.email ?? '',
                        color: const Color(0xFF1565C0),
                      ),
                      SizedBox(height: 12.h),
                      _InfoCard(
                        icon: Icons.phone_outlined,
                        label: 'Phone',
                        value: user?.phone ?? '—',
                        color: const Color(0xFF7B1FA2),
                      ),
                      SizedBox(height: 12.h),
                      _InfoCard(
                        icon: Icons.shield_outlined,
                        label: 'Role',
                        value: (user?.role.name ?? 'patient')[0].toUpperCase() + (user?.role.name ?? 'patient').substring(1),
                        color: const Color(0xFF00897B),
                      ),

                      // ── Privacy & Consent (patients only) ───────
                      if (user != null && user.role == UserRole.patient) ...[
                        SizedBox(height: 12.h),
                        ConsentSettingsCard(uid: user.id),
                      ],

                      SizedBox(height: 32.h),

                      // ── Logout Button ────────────────────────────
                      GestureDetector(
                        onTap: () => _confirmLogout(context),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16.r),
                            gradient: const LinearGradient(
                              colors: [Color(0xFFE53935), Color(0xFFB71C1C)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFE53935).withOpacity(0.35),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.logout_rounded, color: Colors.white, size: 20.sp),
                              SizedBox(width: 10.w),
                              Text(
                                'Sign Out',
                                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 24.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
        },
      );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(Icons.logout_rounded, color: Colors.red, size: 20.sp),
            ),
            SizedBox(width: 12.w),
            Text('Sign Out', style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'Are you sure you want to sign out?',
          style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey, fontSize: 14.sp)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<AuthCubit>().logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const Login()),
                  (r) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
            ),
            child: Text('Sign Out', style: TextStyle(fontSize: 14.sp, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: color, size: 20.sp),
          ),
          SizedBox(width: 14.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 11.sp, color: Colors.grey, fontWeight: FontWeight.w500)),
              SizedBox(height: 2.h),
              Text(value, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.black87)),
            ],
          ),
        ],
      ),
    );
  }
}
