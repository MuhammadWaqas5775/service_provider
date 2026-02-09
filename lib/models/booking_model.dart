import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
  final String id;
  final String userId;
  final String serviceId;
  final String serviceName;
  final double price;
  final DateTime bookingDate;
  final String status; // 'pending', 'confirmed', 'completed', 'cancelled'

  BookingModel({
    required this.id,
    required this.userId,
    required this.serviceId,
    required this.serviceName,
    required this.price,
    required this.bookingDate,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'price': price,
      'bookingDate': bookingDate,
      'status': status,
    };
  }

  factory BookingModel.fromMap(String id, Map<String, dynamic> map) {
    return BookingModel(
      id: id,
      userId: map['userId'] ?? '',
      serviceId: map['serviceId'] ?? '',
      serviceName: map['serviceName'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      bookingDate: (map['bookingDate'] as Timestamp).toDate(),
      status: map['status'] ?? 'pending',
    );
  }
}
