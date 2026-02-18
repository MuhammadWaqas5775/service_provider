import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? _userData;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (user == null) return;
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
      if (doc.exists && mounted) {
        setState(() {
          _userData = doc.data();
          _loading = false;
        });
      } else {
        if (mounted) setState(() => _loading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

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
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.sage));
    }

    final name = _userData?['name'] ?? user?.displayName ?? 'User';
    final email = user?.email ?? '';
    final initials = name.isNotEmpty ? name[0].toUpperCase() : 'U';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
      child: Column(
        children: [
          // Profile card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: NeuDecoration.raised(color: AppColors.cream, radius: 20, offset: 4, blur: 8),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: NeuDecoration.pressed(color: AppColors.creamLight, radius: 40),
                  child: Center(
                    child: Text(
                      initials,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: AppColors.sage,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  name,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(email, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.sage.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'CUSTOMER',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.sage, letterSpacing: 1),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Stats row
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('bookings')
                .where('userId', isEqualTo: user?.uid)
                .snapshots(),
            builder: (context, snapshot) {
              int total = 0, pending = 0, completed = 0;
              if (snapshot.hasData) {
                total = snapshot.data!.docs.length;
                for (var doc in snapshot.data!.docs) {
                  final status = (doc.data() as Map<String, dynamic>)['status'] ?? '';
                  if (status == 'pending') pending++;
                  if (status == 'completed') completed++;
                }
              }
              return Row(
                children: [
                  Expanded(child: _statCard('Total', '$total', Icons.calendar_today_rounded, AppColors.sage)),
                  const SizedBox(width: 12),
                  Expanded(child: _statCard('Pending', '$pending', Icons.hourglass_top_rounded, AppColors.warning)),
                  const SizedBox(width: 12),
                  Expanded(child: _statCard('Done', '$completed', Icons.check_circle_rounded, AppColors.success)),
                ],
              );
            },
          ),
          const SizedBox(height: 20),

          // Settings list
          Container(
            decoration: NeuDecoration.raised(color: AppColors.cream, radius: 18, offset: 3, blur: 6),
            child: Column(
              children: [
                _settingsTile(Icons.person_outline, 'Edit Profile', () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Coming soon!')),
                  );
                }),
                Divider(height: 1, indent: 56, color: AppColors.beige.withValues(alpha: 0.4)),
                _settingsTile(Icons.lock_outline, 'Change Password', () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Coming soon!')),
                  );
                }),
                Divider(height: 1, indent: 56, color: AppColors.beige.withValues(alpha: 0.4)),
                _settingsTile(Icons.notifications_outlined, 'Notifications', () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Coming soon!')),
                  );
                }),
                Divider(height: 1, indent: 56, color: AppColors.beige.withValues(alpha: 0.4)),
                _settingsTile(Icons.info_outline, 'About', () {
                  showAboutDialog(
                    context: context,
                    applicationName: 'Service Provider',
                    applicationVersion: '1.0.0',
                    applicationIcon: const Icon(Icons.handyman_rounded, size: 40, color: AppColors.sage),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Logout
          SizedBox(
            width: double.infinity,
            child: NeuButton(
              onPressed: _logout,
              label: 'Logout',
              icon: Icons.logout_rounded,
              color: AppColors.error,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: NeuDecoration.raised(color: AppColors.cream, radius: 14, offset: 2, blur: 4),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: color)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _settingsTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        width: 36, height: 36,
        decoration: NeuDecoration.pressed(color: AppColors.creamLight, radius: 10),
        child: Icon(icon, color: AppColors.sage, size: 18),
      ),
      title: Text(title, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textLight),
      onTap: onTap,
    );
  }
}
