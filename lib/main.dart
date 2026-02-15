import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'signup_page.dart';
import 'login_page.dart';
import 'screens/services_screen.dart';
import 'screens/my_bookings_page.dart';
import 'screens/admin_panel_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Service Provider',
      theme: ThemeData(primarySwatch: Colors.blue),
      routes: {
        "/signup": (context) => const SignupPage(),
        "/login": (context) => const LoginPage(),
        "/services": (context) => const ServicesScreen(),
        "/my_bookings": (context) => const MyBookingsPage(),
        "/admin_panel": (context) => const AdminPanelScreen(),
      },
      home: const LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
