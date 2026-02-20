import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isObscure = true;
  bool isLoading = false;
  bool rememberMe = false;
  final _key = GlobalKey<FormState>();
  final _emailFocus = FocusNode();
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();

    // Auto-focus email field after animation
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) _emailFocus.requestFocus();
    });

    _loadRememberMe();
  }

  Future<void> _loadRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('remember_email') ?? '';
    if (savedEmail.isNotEmpty && mounted) {
      setState(() {
        emailController.text = savedEmail;
        rememberMe = true;
      });
    }
  }

  Future<void> _login() async {
    if (!_key.currentState!.validate()) return;
    setState(() => isLoading = true);
    HapticFeedback.lightImpact();

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    try {
      UserCredential cred;
      try {
        cred = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      } on FirebaseAuthException catch (e) {
        if ((e.code == 'user-not-found' || e.code == 'invalid-credential') &&
            email == 'admin@gmail.com' && password == '123123') {
          cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
        } else {
          rethrow;
        }
      }

      // Save remember me
      final prefs = await SharedPreferences.getInstance();
      if (rememberMe) {
        await prefs.setString('remember_email', email);
      } else {
        await prefs.remove('remember_email');
      }
      await prefs.setBool('remember_me', rememberMe);

      if (mounted && cred.user != null) {
        HapticFeedback.heavyImpact();
        if (email == 'admin@gmail.com') {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Welcome Admin!')));
          Navigator.pushReplacementNamed(context, '/admin_panel');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Logged in successfully')));
          Navigator.pushReplacementNamed(context, '/services');
        }
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Login failed';
      if (e.code == 'user-not-found') {
        errorMessage = 'No account found. Please sign up first.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Wrong password provided.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'The email address is invalid.';
      } else if (e.code == 'invalid-credential') {
        errorMessage = 'Invalid email or password. Please sign up if you don\'t have an account.';
      } else {
        errorMessage = e.message ?? 'An unknown error occurred.';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: AppColors.error),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An unexpected error occurred: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    _emailFocus.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.cream, AppColors.beigeLight, AppColors.creamLight],
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
                      width: 100, height: 100,
                      decoration: NeuDecoration.raised(color: AppColors.cream, radius: 50, offset: 5, blur: 10),
                      child: const Icon(Icons.handyman_rounded, size: 48, color: AppColors.sage),
                    ),
                    const SizedBox(height: 16),
                    const Text('Service Provider', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.sageDark, letterSpacing: 0.5)),
                    const SizedBox(height: 6),
                    const Text('Sign in to continue', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                    const SizedBox(height: 40),

                    GlassContainer(
                      blur: 8, opacity: 0.2,
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _key,
                        child: Column(
                          children: [
                            NeuTextField(
                              controller: emailController,
                              hintText: 'Email',
                              prefixIcon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) => v == null || v.isEmpty ? 'Please enter your email' : null,
                            ),
                            const SizedBox(height: 16),
                            NeuTextField(
                              controller: passwordController,
                              hintText: 'Password',
                              prefixIcon: Icons.lock_outline,
                              obscureText: isObscure,
                              suffixIcon: IconButton(
                                onPressed: () => setState(() => isObscure = !isObscure),
                                icon: Icon(isObscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: AppColors.sage, size: 20),
                              ),
                              validator: (v) => v == null || v.isEmpty ? 'Please enter your password' : null,
                            ),
                            const SizedBox(height: 12),
                            // Remember me
                            Row(
                              children: [
                                SizedBox(
                                  width: 24, height: 24,
                                  child: Checkbox(
                                    value: rememberMe,
                                    onChanged: (v) => setState(() => rememberMe = v ?? false),
                                    activeColor: AppColors.sage,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text('Remember me', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                              ],
                            ),
                            const SizedBox(height: 20),
                            isLoading
                                ? const CircularProgressIndicator(color: AppColors.sage)
                                : NeuButton(onPressed: _login, label: 'Sign In', icon: Icons.login_rounded),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account?", style: TextStyle(color: AppColors.textSecondary)),
                        TextButton(
                          onPressed: () => Navigator.pushNamed(context, '/signup'),
                          child: const Text('Sign Up', style: TextStyle(fontWeight: FontWeight.w700)),
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
