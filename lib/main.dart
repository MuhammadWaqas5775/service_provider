import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'SignUp_page.dart';
import 'Login_page.dart';
import 'home_page.dart';

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
      routes: {
        "/SignUp_page": (context) => const SignupPage(),
        "/Login_page": (context) => const LoginPage(),
        "/home_page": (context) => const HomePage(),
      },
      home: const LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
