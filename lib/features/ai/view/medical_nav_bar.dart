import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../chat/chat_list_screen.dart';
import 'analysis_screen.dart';
import 'consent_dialog.dart';
import 'home_screen.dart';
import 'profile_screen.dart';

class MedicalNavBar extends StatefulWidget {
  const MedicalNavBar({super.key});

  @override
  State<MedicalNavBar> createState() => _MedicalNavBarState();
}

class _MedicalNavBarState extends State<MedicalNavBar> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [HomeScreen(), AnalysisScreen(), ChatListScreen(), ProfileScreen()];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkConsent());
  }

  Future<void> _checkConsent() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || !mounted) return;
    final consent = await ConsentService.getConsent(uid);
    // Show dialog only if neither field has been set yet (null = first time)
    if (consent.modelTraining == null && mounted) {
      await ConsentDialog.show(context);
    }
  }

  static const _items = [
    (icon: Icons.home_rounded, label: 'Home'),
    (icon: Icons.bar_chart_rounded, label: 'Analysis'),
    (icon: Icons.chat_bubble_outline_rounded, label: 'Chat'),
    (icon: Icons.person_rounded, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(28.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_items.length, (i) {
            final selected = i == _selectedIndex;
            final item = _items[i];
            return GestureDetector(
              onTap: () => setState(() => _selectedIndex = i),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                padding: EdgeInsets.symmetric(horizontal: selected ? 18.w : 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: selected ? Colors.blue : Colors.transparent,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  children: [
                    Icon(item.icon, color: selected ? Colors.white : Colors.grey, size: 22.sp),
                    if (selected) ...[
                      SizedBox(width: 6.w),
                      Text(
                        item.label,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13.sp,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
