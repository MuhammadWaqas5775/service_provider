import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app_theme.dart';

class BookingConfirmationScreen extends StatefulWidget {
  final String serviceName;
  final String date;
  final String time;
  final double price;

  const BookingConfirmationScreen({
    super.key,
    required this.serviceName,
    required this.date,
    required this.time,
    required this.price,
  });

  @override
  State<BookingConfirmationScreen> createState() => _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen>
    with TickerProviderStateMixin {
  late AnimationController _checkController;
  late AnimationController _fadeController;
  late Animation<double> _checkAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    HapticFeedback.heavyImpact();

    _checkController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));

    _checkAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _checkController, curve: Curves.elasticOut),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);

    Future.delayed(const Duration(milliseconds: 200), () => _checkController.forward());
    Future.delayed(const Duration(milliseconds: 500), () => _fadeController.forward());
  }

  @override
  void dispose() {
    _checkController.dispose();
    _fadeController.dispose();
    super.dispose();
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
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated checkmark
                  ScaleTransition(
                    scale: _checkAnim,
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: NeuDecoration.raised(
                        color: AppColors.success.withValues(alpha: 0.15),
                        radius: 55,
                        offset: 5,
                        blur: 12,
                      ),
                      child: const Icon(
                        Icons.check_circle_rounded,
                        size: 60,
                        color: AppColors.success,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FadeTransition(
                    opacity: _fadeAnim,
                    child: Column(
                      children: [
                        const Text(
                          'Booking Confirmed!',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Your service has been booked successfully.',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),

                        // Booking details card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: NeuDecoration.raised(color: AppColors.cream, radius: 18, offset: 3, blur: 6),
                          child: Column(
                            children: [
                              _detailRow(Icons.build_rounded, 'Service', widget.serviceName),
                              Divider(height: 20, color: AppColors.beige.withValues(alpha: 0.4)),
                              _detailRow(Icons.calendar_today_rounded, 'Date', widget.date),
                              Divider(height: 20, color: AppColors.beige.withValues(alpha: 0.4)),
                              _detailRow(Icons.access_time_rounded, 'Time', widget.time),
                              Divider(height: 20, color: AppColors.beige.withValues(alpha: 0.4)),
                              _detailRow(Icons.attach_money_rounded, 'Price', '\$${widget.price.toStringAsFixed(2)}'),
                              Divider(height: 20, color: AppColors.beige.withValues(alpha: 0.4)),
                              _detailRow(Icons.info_outline_rounded, 'Status', 'Pending'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        SizedBox(
                          width: double.infinity,
                          child: NeuButton(
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              Navigator.pop(context, 'bookings');
                            },
                            label: 'View My Bookings',
                            icon: Icons.calendar_today_rounded,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Back to Services', style: TextStyle(fontSize: 15)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.sage),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        const Spacer(),
        Text(value, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
      ],
    );
  }
}
