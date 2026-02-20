import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../app_theme.dart';

class AdminBookingsTab extends StatelessWidget {
  const AdminBookingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('bookings').orderBy('bookingDate', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildShimmerList();
        }
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: AppColors.error),
                const SizedBox(height: 16),
                Text('Error: ${snapshot.error}', textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textSecondary)),
              ],
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 90, height: 90,
                  decoration: NeuDecoration.raised(color: AppColors.cream, radius: 45, offset: 5, blur: 10),
                  child: const Icon(Icons.event_busy_rounded, size: 44, color: AppColors.sageLight),
                ),
                const SizedBox(height: 24),
                const Text('No Bookings Yet',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                const Text('Bookings will appear here when customers book services.',
                    style: TextStyle(color: AppColors.textLight, fontSize: 14), textAlign: TextAlign.center),
              ],
            ),
          );
        }

        return RefreshIndicator(
          color: AppColors.sage,
          onRefresh: () async => await Future.delayed(const Duration(milliseconds: 500)),
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final bookingDate = (data['bookingDate'] as Timestamp).toDate();
              final status = data['status'] ?? 'pending';

              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                decoration: NeuDecoration.raised(color: AppColors.cream, radius: 18, offset: 3, blur: 7),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 46, height: 46,
                            decoration: NeuDecoration.pressed(color: AppColors.creamLight, radius: 12),
                            child: const Icon(Icons.calendar_today_rounded, color: AppColors.sage, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(data['serviceName'] ?? 'Service',
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: AppColors.textPrimary)),
                                const SizedBox(height: 4),
                                Text(bookingDate.toString().substring(0, 16),
                                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                          _statusBadge(status),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // User info
                      FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance.collection('users').doc(data['userId']).get(),
                        builder: (context, userSnap) {
                          String userName = 'Loading...';
                          if (userSnap.hasData && userSnap.data!.exists) {
                            userName = (userSnap.data!.data() as Map<String, dynamic>)['name'] ?? 'Unknown';
                          }
                          return Row(
                            children: [
                              const Icon(Icons.person_outline_rounded, size: 14, color: AppColors.textLight),
                              const SizedBox(width: 6),
                              Text(userName, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                              const Spacer(),
                              const Icon(Icons.attach_money_rounded, size: 14, color: AppColors.textLight),
                              Text('\$${(data['price'] ?? 0.0).toStringAsFixed(2)}',
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.success)),
                            ],
                          );
                        },
                      ),
                      if (status == 'pending') ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () async {
                                  HapticFeedback.lightImpact();
                                  await FirebaseFirestore.instance.collection('bookings').doc(doc.id).update({'status': 'approved'});
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: NeuDecoration.raised(color: AppColors.success.withValues(alpha: 0.15), radius: 12, offset: 2, blur: 4),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.check_rounded, size: 18, color: AppColors.success),
                                      SizedBox(width: 6),
                                      Text('Approve', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w600, fontSize: 13)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: GestureDetector(
                                onTap: () async {
                                  HapticFeedback.lightImpact();
                                  await FirebaseFirestore.instance.collection('bookings').doc(doc.id).update({'status': 'cancelled'});
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: NeuDecoration.raised(color: AppColors.error.withValues(alpha: 0.15), radius: 12, offset: 2, blur: 4),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.close_rounded, size: 18, color: AppColors.error),
                                      SizedBox(width: 6),
                                      Text('Cancel', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600, fontSize: 13)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _statusBadge(String status) {
    final color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: NeuDecoration.raised(color: AppColors.cream, radius: 18, offset: 3, blur: 7),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _shimmerBox(46, 46, 12),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _shimmerBox(double.infinity, 14, 6),
                        const SizedBox(height: 8),
                        _shimmerBox(120, 10, 6),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _shimmerBox(double width, double height, double radius) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.3, end: 0.7),
      duration: const Duration(milliseconds: 800),
      builder: (context, value, child) {
        return Container(
          width: width, height: height,
          decoration: BoxDecoration(
            color: AppColors.beige.withValues(alpha: value),
            borderRadius: BorderRadius.circular(radius),
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed': return AppColors.success;
      case 'pending': return AppColors.warning;
      case 'confirmed':
      case 'approved': return AppColors.info;
      case 'cancelled': return AppColors.error;
      default: return AppColors.textLight;
    }
  }
}
