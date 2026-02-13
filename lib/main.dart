import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'SignUp_page.dart';
import 'Login_page.dart';
import 'screens/services_screen.dart';
import 'screens/admin_panel_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
        "/SignUp_page": (context) => const SignupPage(),
        "/Login_page": (context) => const LoginPage(),
        "/services": (context) => const ServicesScreen(),
        "/admin_panel": (context) => const AdminPanelScreen(),
      },
      home: const LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
