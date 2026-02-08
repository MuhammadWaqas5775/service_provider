import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/service_model.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Services'),
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/Login_page');
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('services').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No services found.'));
          }

          final services = snapshot.data!.docs.map((doc) {
            return ServiceModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
          }).toList();

          return ListView.builder(
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: Icon(_getIconData(service.icon), color: Colors.blue, size: 40),
                  title: Text(service.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(service.description),
                  trailing: Text('\$${service.price.toStringAsFixed(2)}', 
                    style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                  onTap: () {
                    // Navigate to service details or booking screen
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'electric': return Icons.electrical_services;
      case 'plumbing': return Icons.plumbing;
      case 'carpenter': return Icons.handyman;
      case 'cleaning': return Icons.cleaning_services;
      default: return Icons.build;
    }
  }
}
