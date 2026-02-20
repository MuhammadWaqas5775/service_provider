import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/service_model.dart';
import '../app_theme.dart';

class AdminServicesTab extends StatelessWidget {
  const AdminServicesTab({super.key});

  static const List<String> _categories = [
    'Home', 'Repair', 'Beauty', 'Cleaning', 'Plumbing', 'Electrical', 'Other',
  ];

  static const List<String> _durations = [
    '30 mins', '1 hour', '1-2 hours', '2-3 hours', '3-4 hours', 'Half day', 'Full day',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: StreamBuilder<QuerySnapshot>(
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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 90, height: 90,
                    decoration: NeuDecoration.raised(color: AppColors.cream, radius: 45, offset: 5, blur: 10),
                    child: const Icon(Icons.handyman_rounded, size: 44, color: AppColors.sageLight),
                  ),
                  const SizedBox(height: 24),
                  const Text('No Services Yet',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  const Text('Tap the + button to add your first service.',
                      style: TextStyle(color: AppColors.textLight, fontSize: 14)),
                ],
              ),
            );
          }

          final services = snapshot.data!.docs.map((doc) {
            return ServiceModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
          }).toList();

          return RefreshIndicator(
            color: AppColors.sage,
            onRefresh: () async => await Future.delayed(const Duration(milliseconds: 500)),
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
              itemCount: services.length,
              itemBuilder: (context, index) {
                final service = services[index];
                return Dismissible(
                  key: Key(service.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 24),
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.delete_rounded, color: AppColors.error, size: 28),
                        SizedBox(height: 4),
                        Text('Delete', style: TextStyle(color: AppColors.error, fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  confirmDismiss: (direction) async {
                    HapticFeedback.mediumImpact();
                    return await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: AppColors.cream,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        title: const Text('Delete Service', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                        content: Text('Are you sure you want to delete "${service.name}"?',
                            style: const TextStyle(color: AppColors.textSecondary)),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                  },
                  onDismissed: (direction) async {
                    try {
                      await FirebaseFirestore.instance.collection('services').doc(service.id).delete();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Service deleted')),
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
                  child: Container(
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
                                child: Icon(_getIconData(service.icon), color: AppColors.sageDark, size: 24),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(service.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: AppColors.textPrimary)),
                                    const SizedBox(height: 2),
                                    Text(service.description, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                                        maxLines: 1, overflow: TextOverflow.ellipsis),
                                  ],
                                ),
                              ),
                              Text('\$${service.price.toStringAsFixed(2)}',
                                  style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.w700, fontSize: 15)),
                            ],
                          ),
                          const SizedBox(height: 10),
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
                          Divider(height: 20, color: AppColors.beige.withValues(alpha: 0.5)),
                          Row(
                            children: [
                              // Swipe hint
                              const Text('← Swipe to delete', style: TextStyle(color: AppColors.textLight, fontSize: 10)),
                              const Spacer(),
                              _actionButton(
                                icon: Icons.edit_rounded,
                                color: AppColors.sage,
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  _showServiceDialog(context, service: service);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: Container(
        width: 56, height: 56,
        decoration: NeuDecoration.raised(color: AppColors.sage, radius: 16, offset: 3, blur: 6),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              HapticFeedback.lightImpact();
              _showServiceDialog(context);
            },
            child: const Icon(Icons.add_rounded, color: AppColors.white, size: 28),
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

  Widget _actionButton({required IconData icon, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38, height: 38,
        decoration: NeuDecoration.raised(color: AppColors.creamLight, radius: 10, offset: 2, blur: 4),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }

  // Shimmer loading
  Widget _buildShimmerList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: 3,
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

  void _showServiceDialog(BuildContext context, {ServiceModel? service}) {
    final nameController = TextEditingController(text: service?.name ?? '');
    final descController = TextEditingController(text: service?.description ?? '');
    final priceController = TextEditingController(text: service != null ? service.price.toString() : '');
    final phoneController = TextEditingController(text: service?.phone ?? '');
    String selectedIcon = service?.icon ?? 'build';
    String selectedCategory = service?.category ?? 'Other';
    String selectedDuration = service?.duration ?? '1 hour';

    final icons = ['build', 'electric', 'plumbing', 'carpenter', 'cleaning'];
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.cream,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(
                service == null ? 'Add Service' : 'Edit Service',
                style: const TextStyle(color: AppColors.sageDark, fontWeight: FontWeight.w600),
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _dialogField(nameController, 'Service Name *', Icons.build_rounded,
                          validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null),
                      const SizedBox(height: 12),
                      _dialogField(descController, 'Description', Icons.description_rounded, maxLines: 2),
                      const SizedBox(height: 12),
                      _dialogField(priceController, 'Price *', Icons.attach_money_rounded,
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Required';
                            if (double.tryParse(v.trim()) == null) return 'Invalid number';
                            return null;
                          }),
                      const SizedBox(height: 12),
                      _dialogField(phoneController, 'Phone Number *', Icons.phone_rounded,
                          keyboardType: TextInputType.phone,
                          validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null),
                      const SizedBox(height: 12),
                      _styledDropdown<String>(
                        value: selectedCategory, label: 'Category', icon: Icons.category_rounded,
                        items: _categories,
                        onChanged: (v) => setDialogState(() => selectedCategory = v!),
                      ),
                      const SizedBox(height: 12),
                      _styledDropdown<String>(
                        value: selectedDuration, label: 'Duration', icon: Icons.access_time_rounded,
                        items: _durations,
                        onChanged: (v) => setDialogState(() => selectedDuration = v!),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: selectedIcon,
                        decoration: InputDecoration(
                          labelText: 'Icon',
                          labelStyle: const TextStyle(color: AppColors.textSecondary),
                          prefixIcon: const Icon(Icons.palette_rounded, color: AppColors.sage),
                          filled: true, fillColor: AppColors.creamLight,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                        ),
                        dropdownColor: AppColors.cream,
                        items: icons.map((icon) {
                          return DropdownMenuItem(
                            value: icon,
                            child: Row(
                              children: [
                                Icon(_getIconData(icon), size: 20, color: AppColors.sage),
                                const SizedBox(width: 8),
                                Text(icon, style: const TextStyle(color: AppColors.textPrimary)),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (v) => setDialogState(() => selectedIcon = v!),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    HapticFeedback.lightImpact();

                    final data = {
                      'name': nameController.text.trim(),
                      'description': descController.text.trim(),
                      'price': double.tryParse(priceController.text.trim()) ?? 0.0,
                      'phone': phoneController.text.trim(),
                      'category': selectedCategory,
                      'duration': selectedDuration,
                      'icon': selectedIcon,
                    };

                    try {
                      if (service == null) {
                        await FirebaseFirestore.instance.collection('services').add(data);
                      } else {
                        await FirebaseFirestore.instance.collection('services').doc(service.id).update(data);
                      }
                      if (ctx.mounted) Navigator.pop(ctx);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(service == null ? 'Service added' : 'Service updated')),
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
                  child: Text(service == null ? 'Add' : 'Update'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _dialogField(TextEditingController controller, String label, IconData icon, {
    TextInputType? keyboardType, String? Function(String?)? validator, int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller, keyboardType: keyboardType, validator: validator, maxLines: maxLines,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label, labelStyle: const TextStyle(color: AppColors.textSecondary),
        prefixIcon: Icon(icon, color: AppColors.sage),
        filled: true, fillColor: AppColors.creamLight,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.sage, width: 1.5),
        ),
      ),
    );
  }

  Widget _styledDropdown<T>({required T value, required String label, required IconData icon,
    required List<T> items, required void Function(T?) onChanged}) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: label, labelStyle: const TextStyle(color: AppColors.textSecondary),
        prefixIcon: Icon(icon, color: AppColors.sage),
        filled: true, fillColor: AppColors.creamLight,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      ),
      dropdownColor: AppColors.cream,
      style: const TextStyle(color: AppColors.textPrimary),
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item.toString()))).toList(),
      onChanged: onChanged,
    );
  }

  static IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'electric': return Icons.electrical_services_rounded;
      case 'plumbing': return Icons.plumbing_rounded;
      case 'carpenter': return Icons.handyman_rounded;
      case 'cleaning': return Icons.cleaning_services_rounded;
      default: return Icons.build_rounded;
    }
  }
}
