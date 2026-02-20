import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'app_theme.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> with SingleTickerProviderStateMixin {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool isObscure = true;
  bool isLoading = false;
  final _key = GlobalKey<FormState>();
  final _nameFocus = FocusNode();
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();

    // Auto-focus name field
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) _nameFocus.requestFocus();
    });
  }

  Future<void> _signup() async {
    if (!_key.currentState!.validate()) return;

    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match'), backgroundColor: AppColors.error),
      );
      return;
    }

    setState(() => isLoading = true);
    HapticFeedback.lightImpact();

    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (cred.user != null) {
        await FirebaseFirestore.instance.collection('users').doc(cred.user!.uid).set({
          'name': nameController.text.trim(),
          'email': emailController.text.trim(),
          'uid': cred.user!.uid,
          'role': 'customer',
        });

        if (mounted) {
          HapticFeedback.heavyImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User registered successfully')),
          );
          Navigator.pushReplacementNamed(context, '/login');
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Registration failed'), backgroundColor: AppColors.error),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("An unexpected error occurred"), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    _nameFocus.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [AppColors.creamLight, AppColors.beigeLight, AppColors.cream],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: FadeTransition(
                opacity: _fadeAnim,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 90, height: 90,
                      decoration: NeuDecoration.raised(color: AppColors.cream, radius: 45, offset: 5, blur: 10),
                      child: const Icon(Icons.person_add_rounded, size: 40, color: AppColors.sage),
                    ),
                    const SizedBox(height: 16),
                    const Text('Create Account', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.sageDark, letterSpacing: 0.5)),
                    const SizedBox(height: 6),
                    const Text('Sign up to get started', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                    const SizedBox(height: 32),

                    GlassContainer(
                      blur: 8, opacity: 0.2,
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _key,
                        child: Column(
                          children: [
                            NeuTextField(
                              controller: nameController,
                              hintText: 'Full Name',
                              prefixIcon: Icons.person_outline,
                              validator: (v) => v == null || v.isEmpty ? 'Please enter your name' : null,
                            ),
                            const SizedBox(height: 14),
                            NeuTextField(
                              controller: emailController,
                              hintText: 'Email',
                              prefixIcon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) => v == null || v.isEmpty ? 'Please enter your email' : null,
                            ),
                            const SizedBox(height: 14),
                            NeuTextField(
                              controller: passwordController,
                              hintText: 'Password',
                              prefixIcon: Icons.lock_outline,
                              obscureText: isObscure,
                              suffixIcon: IconButton(
                                onPressed: () => setState(() => isObscure = !isObscure),
                                icon: Icon(isObscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: AppColors.sage, size: 20),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Please enter your password';
                                if (v.length < 6) return 'Password must be at least 6 characters';
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),
                            NeuTextField(
                              controller: confirmPasswordController,
                              hintText: 'Confirm Password',
                              prefixIcon: Icons.lock_outline,
                              obscureText: isObscure,
                              validator: (v) => v == null || v.isEmpty ? 'Please confirm your password' : null,
                            ),
                            const SizedBox(height: 24),
                            isLoading
                                ? const CircularProgressIndicator(color: AppColors.sage)
                                : NeuButton(onPressed: _signup, label: 'Create Account', icon: Icons.person_add_rounded),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Already have an account?', style: TextStyle(color: AppColors.textSecondary)),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Login', style: TextStyle(fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
