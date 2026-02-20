import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app_theme.dart';
import 'signup_page.dart';
import 'login_page.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/services_screen.dart';
import 'screens/my_bookings_page.dart';
import 'screens/admin_panel_screen.dart';
import 'screens/booking_confirmation_screen.dart';

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
      theme: AppTheme.theme,
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
      onGenerateRoute: (settings) {
        Widget page;
        switch (settings.name) {
          case '/splash':
            page = const SplashScreen();
            break;
          case '/onboarding':
            page = const OnboardingScreen();
            break;
          case '/login':
            page = const LoginPage();
            break;
          case '/signup':
            page = const SignupPage();
            break;
          case '/services':
            page = const ServicesScreen();
            break;
          case '/my_bookings':
            page = const MyBookingsPage();
            break;
          case '/admin_panel':
            page = const AdminPanelScreen();
            break;
          default:
            page = const SplashScreen();
        }

        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOutCubic;
            final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            final fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: const Interval(0.0, 0.6, curve: Curves.easeIn)),
            );

            return SlideTransition(
              position: animation.drive(tween),
              child: FadeTransition(opacity: fadeAnim, child: child),
            );
          },
          transitionDuration: const Duration(milliseconds: 350),
        );
      },
    );
  }
}
