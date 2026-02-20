import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/booking_model.dart';
import '../app_theme.dart';
import 'package:intl/intl.dart';

class MyBookingsPage extends StatelessWidget {
  const MyBookingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

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
            // Custom neumorphic app bar
            SafeArea(
              bottom: false,
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: NeuDecoration.raised(color: AppColors.cream, radius: 18, offset: 3, blur: 6),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 36, height: 36,
                        decoration: NeuDecoration.pressed(color: AppColors.creamLight, radius: 10),
                        child: const Icon(Icons.arrow_back_rounded, color: AppColors.sageDark, size: 20),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'My Bookings',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: user == null
                  ? const Center(child: Text('Please log in to see bookings', style: TextStyle(color: AppColors.textSecondary)))
                  : StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('bookings')
                          .where('userId', isEqualTo: user.uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator(color: AppColors.sage));
                        }
                        if (snapshot.hasError) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.error_outline, size: 64, color: AppColors.error),
                                const SizedBox(height: 16),
                                Text('Error: ${snapshot.error}', textAlign: TextAlign.center),
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
                                  width: 80, height: 80,
                                  decoration: NeuDecoration.raised(color: AppColors.cream, radius: 40),
                                  child: const Icon(Icons.event_busy_rounded, size: 40, color: AppColors.sageLight),
                                ),
                                const SizedBox(height: 20),
                                const Text('No Bookings Yet',
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                                const SizedBox(height: 8),
                                const Text('Browse services and book one!',
                                    style: TextStyle(color: AppColors.textLight)),
                              ],
                            ),
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            var doc = snapshot.data!.docs[index];
                            var booking = BookingModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: NeuDecoration.raised(color: AppColors.cream, radius: 16, offset: 3, blur: 6),
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 46, height: 46,
                                      decoration: NeuDecoration.pressed(color: AppColors.creamLight, radius: 12),
                                      child: const Icon(Icons.calendar_today_rounded, color: AppColors.sage, size: 22),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(booking.serviceName,
                                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: AppColors.textPrimary)),
                                          const SizedBox(height: 4),
                                          Text(DateFormat('yyyy-MM-dd – kk:mm').format(booking.bookingDate),
                                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                          const SizedBox(height: 4),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: _getStatusColor(booking.status).withOpacity(0.12),
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: _getStatusColor(booking.status).withOpacity(0.2)),
                                            ),
                                            child: Text(
                                              booking.status.toUpperCase(),
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w700,
                                                color: _getStatusColor(booking.status),
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text('\$${booking.price.toStringAsFixed(2)}',
                                        style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.success)),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
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
