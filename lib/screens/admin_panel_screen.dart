import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_theme.dart';
import 'admin_services_tab.dart';
import 'admin_bookings_tab.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  int _currentIndex = 0;

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('remember_me');
      if (mounted) Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout failed: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.cream, AppColors.creamLight],
          ),
        ),
        child: Column(
          children: [
            // Custom app bar
            SafeArea(
              bottom: false,
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: NeuDecoration.raised(color: AppColors.cream, radius: 18, offset: 3, blur: 6),
                child: Row(
                  children: [
                    Container(
                      width: 36, height: 36,
                      decoration: NeuDecoration.pressed(color: AppColors.creamLight, radius: 10),
                      child: const Icon(Icons.admin_panel_settings_rounded, color: AppColors.sageDark, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _currentIndex == 0 ? 'Manage Services' : 'Manage Bookings',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        _logout();
                      },
                      child: Container(
                        width: 36, height: 36,
                        decoration: NeuDecoration.raised(color: AppColors.creamLight, radius: 10, offset: 2, blur: 4),
                        child: const Icon(Icons.logout_rounded, color: AppColors.error, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: const [
                  AdminServicesTab(),
                  AdminBookingsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.cream,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFBEB8AE).withValues(alpha: 0.3),
              offset: const Offset(0, -2),
              blurRadius: 8,
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            HapticFeedback.selectionClick();
            setState(() => _currentIndex = index);
          },
          items: [
            const BottomNavigationBarItem(icon: Icon(Icons.build_rounded), label: 'Services'),
            BottomNavigationBarItem(
              icon: _buildPendingBadge(),
              label: 'Bookings',
            ),
          ],
        ),
      ),
    );
  }

  // Badge showing pending booking count
  Widget _buildPendingBadge() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('bookings')
          .where('status', isEqualTo: 'pending')
          .snapshots(),
      builder: (context, snapshot) {
        int count = 0;
        if (snapshot.hasData) count = snapshot.data!.docs.length;

        return Badge(
          isLabelVisible: count > 0,
          label: Text('$count', style: const TextStyle(fontSize: 10)),
          backgroundColor: AppColors.accentWarm,
          child: const Icon(Icons.calendar_today_rounded),
        );
      },
    );
  }
}
