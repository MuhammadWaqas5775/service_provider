import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/service_model.dart';
import '../app_theme.dart';
import 'profile_screen.dart';
import 'booking_confirmation_screen.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  int _currentIndex = 0;
  String _searchQuery = '';
  String _selectedCategory = 'All';
  final _searchController = TextEditingController();

  static const List<String> _categories = [
    'All', 'Home', 'Repair', 'Beauty', 'Cleaning', 'Plumbing', 'Electrical', 'Other',
  ];

  @override
  void dispose() {
    _searchController.dispose();
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
                    Icon(
                      _currentIndex == 0
                          ? Icons.build_rounded
                          : _currentIndex == 1
                              ? Icons.calendar_today_rounded
                              : Icons.person_rounded,
                      color: AppColors.sage, size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _currentIndex == 0
                            ? 'Services'
                            : _currentIndex == 1
                                ? 'My Bookings'
                                : 'Profile',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: [
                  _buildServicesTab(),
                  _buildMyBookingsTab(),
                  const ProfileScreen(),
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
              icon: _buildBadgedIcon(Icons.calendar_today_rounded),
              label: 'Bookings',
            ),
            const BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
          ],
        ),
      ),
    );
  }

  // Badge on bookings icon
  Widget _buildBadgedIcon(IconData icon) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Icon(icon);

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('bookings')
          .where('userId', isEqualTo: user.uid)
          .where('status', isEqualTo: 'pending')
          .snapshots(),
      builder: (context, snapshot) {
        int count = 0;
        if (snapshot.hasData) count = snapshot.data!.docs.length;

        return Badge(
          isLabelVisible: count > 0,
          label: Text('$count', style: const TextStyle(fontSize: 10)),
          backgroundColor: AppColors.accentWarm,
          child: Icon(icon),
        );
      },
    );
  }

  Widget _buildServicesTab() {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Container(
            decoration: NeuDecoration.pressed(color: AppColors.creamLight, radius: 14),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
              decoration: InputDecoration(
                hintText: 'Search services...',
                hintStyle: const TextStyle(color: AppColors.textLight),
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.sage, size: 22),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18, color: AppColors.textLight),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
        ),

        // Category filter chips
        SizedBox(
          height: 44,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final cat = _categories[index];
              final isSelected = _selectedCategory == cat;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedCategory = cat);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: isSelected
                        ? NeuDecoration.pressed(color: AppColors.sage, radius: 10)
                        : NeuDecoration.raised(color: AppColors.cream, radius: 10, offset: 2, blur: 4),
                    child: Text(
                      cat,
                      style: TextStyle(
                        color: isSelected ? AppColors.white : AppColors.textSecondary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 4),

        // Service list
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('services').snapshots(),
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
                return _buildEmptyState(
                  icon: Icons.search_off_rounded,
                  title: 'No Services Available',
                  subtitle: 'Check back later for new services!',
                );
              }

              var services = snapshot.data!.docs.map((doc) {
                return ServiceModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
              }).toList();

              // Apply filters
              if (_selectedCategory != 'All') {
                services = services.where((s) => s.category == _selectedCategory).toList();
              }
              if (_searchQuery.isNotEmpty) {
                services = services.where((s) =>
                    s.name.toLowerCase().contains(_searchQuery) ||
                    s.description.toLowerCase().contains(_searchQuery) ||
                    s.category.toLowerCase().contains(_searchQuery)).toList();
              }

              if (services.isEmpty) {
                return _buildEmptyState(
                  icon: Icons.filter_list_off_rounded,
                  title: 'No Matching Services',
                  subtitle: 'Try adjusting your search or filter.',
                );
              }

              return RefreshIndicator(
                color: AppColors.sage,
                onRefresh: () async => await Future.delayed(const Duration(milliseconds: 500)),
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  itemCount: services.length,
                  itemBuilder: (context, index) => _buildServiceCard(services[index]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildServiceCard(ServiceModel service) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: NeuDecoration.raised(color: AppColors.cream, radius: 18, offset: 3, blur: 7),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            HapticFeedback.lightImpact();
            _showBookingDialog(context, service);
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50, height: 50,
                      decoration: NeuDecoration.pressed(color: AppColors.creamLight, radius: 14),
                      child: Icon(_getIconData(service.icon), color: AppColors.sage, size: 26),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(service.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: AppColors.textPrimary)),
                          const SizedBox(height: 3),
                          Text(service.description, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                              maxLines: 2, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('\$${service.price.toStringAsFixed(2)}',
                          style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.w700, fontSize: 15)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8, runSpacing: 6,
                  children: [
                    if (service.category.isNotEmpty)
                      _chip(Icons.category_rounded, service.category, AppColors.sageDark),
                    if (service.duration.isNotEmpty)
                      _chip(Icons.access_time_rounded, service.duration, AppColors.accentWarm),
                    if (service.phone.isNotEmpty)
                      _chip(Icons.phone_rounded, service.phone, AppColors.info),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: Container(
                    decoration: NeuDecoration.raised(color: AppColors.sage, radius: 12, offset: 2, blur: 4),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          HapticFeedback.lightImpact();
                          _showBookingDialog(context, service);
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.white),
                              SizedBox(width: 8),
                              Text('Book Now', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildMyBookingsTab() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text('Please log in to see bookings', style: TextStyle(color: AppColors.textSecondary)));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('bookings')
          .where('userId', isEqualTo: user.uid)
          .snapshots(),
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
                Text('Error: ${snapshot.error}', textAlign: TextAlign.center),
              ],
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState(
            icon: Icons.event_busy_rounded,
            title: 'No Bookings Yet',
            subtitle: 'Browse services and book one!',
          );
        }

        return RefreshIndicator(
          color: AppColors.sage,
          onRefresh: () async => await Future.delayed(const Duration(milliseconds: 500)),
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              var data = doc.data() as Map<String, dynamic>;
              final bookingDate = (data['bookingDate'] as Timestamp).toDate();
              final status = data['status'] ?? 'pending';

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: NeuDecoration.raised(color: AppColors.cream, radius: 16, offset: 3, blur: 6),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
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
                                Text(data['serviceName'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: AppColors.textPrimary)),
                                const SizedBox(height: 4),
                                Text(bookingDate.toString().substring(0, 16), style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                          Text('\$${(data['price'] ?? 0.0).toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.success)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Status timeline
                      _buildStatusTimeline(status),
                      // Rate button for completed
                      if (status == 'completed' || status == 'approved') ...[
                        const SizedBox(height: 10),
                        _buildRateButton(data['serviceId'] ?? '', data['serviceName'] ?? '', doc.id),
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

  // Booking status timeline
  Widget _buildStatusTimeline(String currentStatus) {
    final steps = ['pending', 'approved', 'completed'];
    int currentIndex = steps.indexOf(currentStatus.toLowerCase());
    if (currentStatus.toLowerCase() == 'cancelled') {
      // Show cancelled state
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cancel_rounded, size: 16, color: AppColors.error),
            SizedBox(width: 6),
            Text('CANCELLED', style: TextStyle(color: AppColors.error, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
          ],
        ),
      );
    }

    return Row(
      children: List.generate(steps.length * 2 - 1, (index) {
        if (index.isOdd) {
          // Connector line
          final stepBefore = index ~/ 2;
          return Expanded(
            child: Container(
              height: 2,
              color: stepBefore < currentIndex ? AppColors.success : AppColors.beige,
            ),
          );
        }
        final stepIndex = index ~/ 2;
        final isActive = stepIndex <= currentIndex;
        final isCurrent = stepIndex == currentIndex;
        final labels = ['Pending', 'Approved', 'Done'];
        final icons = [Icons.hourglass_top_rounded, Icons.check_circle_rounded, Icons.star_rounded];

        return Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: isCurrent ? 32 : 26,
              height: isCurrent ? 32 : 26,
              decoration: BoxDecoration(
                color: isActive ? AppColors.success.withValues(alpha: 0.15) : AppColors.creamLight,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isActive ? AppColors.success : AppColors.beige,
                  width: isCurrent ? 2 : 1.5,
                ),
              ),
              child: Icon(icons[stepIndex], size: isCurrent ? 16 : 12,
                  color: isActive ? AppColors.success : AppColors.textLight),
            ),
            const SizedBox(height: 4),
            Text(labels[stepIndex], style: TextStyle(
              fontSize: 9,
              color: isActive ? AppColors.success : AppColors.textLight,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            )),
          ],
        );
      }),
    );
  }

  // Rate button
  Widget _buildRateButton(String serviceId, String serviceName, String bookingId) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('ratings').doc(bookingId).snapshots(),
      builder: (context, snapshot) {
        final hasRated = snapshot.hasData && snapshot.data!.exists;
        if (hasRated) {
          final rating = (snapshot.data!.data() as Map<String, dynamic>)['rating'] ?? 0;
          return Row(
            children: [
              ...List.generate(5, (i) => Icon(
                i < rating ? Icons.star_rounded : Icons.star_border_rounded,
                size: 16, color: AppColors.warning,
              )),
              const SizedBox(width: 8),
              const Text('Rated', style: TextStyle(fontSize: 11, color: AppColors.textLight)),
            ],
          );
        }
        return GestureDetector(
          onTap: () => _showRatingDialog(serviceId, serviceName, bookingId),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: NeuDecoration.raised(color: AppColors.warning.withValues(alpha: 0.1), radius: 8, offset: 1, blur: 3),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star_rounded, size: 16, color: AppColors.warning),
                SizedBox(width: 6),
                Text('Rate Service', style: TextStyle(color: AppColors.warning, fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        );
      },
    );
  }

  // Rating dialog
  void _showRatingDialog(String serviceId, String serviceName, String bookingId) {
    int selectedRating = 0;
    final reviewController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.cream,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('Rate Service', style: TextStyle(color: AppColors.sageDark, fontWeight: FontWeight.w600)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(serviceName, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (i) {
                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setDialogState(() => selectedRating = i + 1);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(
                            i < selectedRating ? Icons.star_rounded : Icons.star_border_rounded,
                            size: 36, color: AppColors.warning,
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: reviewController,
                    maxLines: 3,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Write a review (optional)',
                      hintStyle: const TextStyle(color: AppColors.textLight),
                      filled: true,
                      fillColor: AppColors.creamLight,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: selectedRating == 0 ? null : () async {
                    try {
                      await FirebaseFirestore.instance.collection('ratings').doc(bookingId).set({
                        'serviceId': serviceId,
                        'serviceName': serviceName,
                        'userId': FirebaseAuth.instance.currentUser?.uid,
                        'rating': selectedRating,
                        'review': reviewController.text.trim(),
                        'createdAt': Timestamp.now(),
                      });
                      if (ctx.mounted) Navigator.pop(ctx);
                      if (context.mounted) {
                        HapticFeedback.heavyImpact();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Thanks for your review!')),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
                        );
                      }
                    }
                  },
                  child: const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showBookingDialog(BuildContext context, ServiceModel service) {
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();
    bool isBooking = false;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return Theme(
              data: Theme.of(context).copyWith(
                datePickerTheme: DatePickerThemeData(
                  backgroundColor: AppColors.cream,
                  headerBackgroundColor: AppColors.sage,
                  headerForegroundColor: AppColors.white,
                  dayForegroundColor: WidgetStatePropertyAll(AppColors.textPrimary),
                  todayForegroundColor: WidgetStatePropertyAll(AppColors.sage),
                  todayBorder: const BorderSide(color: AppColors.sage),
                ),
                timePickerTheme: TimePickerThemeData(
                  backgroundColor: AppColors.cream,
                  dialHandColor: AppColors.sage,
                  hourMinuteColor: AppColors.creamLight,
                ),
              ),
              child: AlertDialog(
                backgroundColor: AppColors.cream,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                title: const Text('Book Service', style: TextStyle(color: AppColors.sageDark, fontWeight: FontWeight.w600)),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(service.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18, color: AppColors.textPrimary)),
                    const SizedBox(height: 4),
                    Text(service.description, style: const TextStyle(color: AppColors.textSecondary)),
                    const SizedBox(height: 8),
                    Text('Price: \$${service.price.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.w600)),
                    if (service.duration.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text('Duration: ${service.duration}', style: const TextStyle(color: AppColors.textSecondary)),
                    ],
                    if (service.phone.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text('Contact: ${service.phone}', style: const TextStyle(color: AppColors.textSecondary)),
                    ],
                    Divider(height: 24, color: AppColors.beige.withValues(alpha: 0.5)),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.calendar_today_rounded, color: AppColors.sage),
                      title: Text(
                        '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}',
                        style: const TextStyle(color: AppColors.textPrimary),
                      ),
                      onTap: () async {
                        HapticFeedback.selectionClick();
                        final picked = await showDatePicker(
                          context: ctx,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 90)),
                        );
                        if (picked != null) setDialogState(() => selectedDate = picked);
                      },
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.access_time_rounded, color: AppColors.sage),
                      title: Text(selectedTime.format(ctx), style: const TextStyle(color: AppColors.textPrimary)),
                      onTap: () async {
                        HapticFeedback.selectionClick();
                        final picked = await showTimePicker(context: ctx, initialTime: selectedTime);
                        if (picked != null) setDialogState(() => selectedTime = picked);
                      },
                    ),
                  ],
                ),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                  isBooking
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.sage))
                      : ElevatedButton.icon(
                          icon: const Icon(Icons.check_rounded, size: 18),
                          label: const Text('Book Now'),
                          onPressed: () async {
                            final user = FirebaseAuth.instance.currentUser;
                            if (user == null) return;

                            setDialogState(() => isBooking = true);
                            HapticFeedback.lightImpact();

                            final bookingDateTime = DateTime(
                              selectedDate.year, selectedDate.month, selectedDate.day,
                              selectedTime.hour, selectedTime.minute,
                            );

                            try {
                              await FirebaseFirestore.instance.collection('bookings').add({
                                'userId': user.uid,
                                'serviceId': service.id,
                                'serviceName': service.name,
                                'price': service.price,
                                'bookingDate': Timestamp.fromDate(bookingDateTime),
                                'status': 'pending',
                              });
                              if (ctx.mounted) Navigator.pop(ctx);
                              if (context.mounted) {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => BookingConfirmationScreen(
                                      serviceName: service.name,
                                      date: '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}',
                                      time: selectedTime.format(context),
                                      price: service.price,
                                    ),
                                  ),
                                );
                                if (result == 'bookings' && mounted) {
                                  setState(() => _currentIndex = 1);
                                }
                              }
                            } catch (e) {
                              setDialogState(() => isBooking = false);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Booking failed: $e'), backgroundColor: AppColors.error),
                                );
                              }
                            }
                          },
                        ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Shimmer loading
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
                  _shimmerBox(50, 50, 14),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _shimmerBox(double.infinity, 14, 6),
                        const SizedBox(height: 8),
                        _shimmerBox(150, 10, 6),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _shimmerBox(double.infinity, 40, 12),
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
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: AppColors.beige.withValues(alpha: value),
            borderRadius: BorderRadius.circular(radius),
          ),
        );
      },
      onEnd: () {},
    );
  }

  // Styled empty state
  Widget _buildEmptyState({required IconData icon, required String title, required String subtitle}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90, height: 90,
            decoration: NeuDecoration.raised(color: AppColors.cream, radius: 45, offset: 5, blur: 10),
            child: Icon(icon, size: 44, color: AppColors.sageLight),
          ),
          const SizedBox(height: 24),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Text(subtitle, style: const TextStyle(color: AppColors.textLight, fontSize: 14)),
        ],
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

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'electric': return Icons.electrical_services_rounded;
      case 'plumbing': return Icons.plumbing_rounded;
      case 'carpenter': return Icons.handyman_rounded;
      case 'cleaning': return Icons.cleaning_services_rounded;
      default: return Icons.build_rounded;
    }
  }
}
