import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'signup_screen.dart';
import '../customer/main_customer_nav.dart';
import '../restaurant/dashboard_screen.dart';
import 'package:local_auth/local_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showPassword = false;
  bool _isLoading = false;
  final LocalAuthentication _localAuth = LocalAuthentication();

  Future<void> _authenticateWithFingerprint() async {
    try {
      final bool canAuthenticateWithBiometrics =
          await _localAuth.canCheckBiometrics;
      final bool canAuthenticate =
          canAuthenticateWithBiometrics || await _localAuth.isDeviceSupported();

      if (!canAuthenticate) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Biometrics not supported on this device.'),
            ),
          );
        }
        return;
      }

      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Tap your finger to log into DashChop',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (didAuthenticate && mounted) {
        // 1. Check if Supabase remembers this device's login
        final supabase = Supabase.instance.client;
        final user = supabase.auth.currentUser;

        if (user != null) {
          // 2. Fetch their role securely
          final userData = await supabase
              .from('users')
              .select()
              .eq('id', user.id)
              .single();
          final role = userData['role'];

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fingerprint Recognized')),
          );

          if (role == 'restaurant') {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => DashboardScreen()),
              (route) => false,
            );
          } else {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => MainCustomerNav()),
              (route) => false,
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Please log in with your email/password for the first time.',
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Auth Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/login_bg.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Container(color: Colors.black.withOpacity(0.3)),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 16,
                  bottom: 16,
                  left: 20,
                  right: 20,
                ),
                color: const Color(0xFF7D4427),
                child: const Text(
                  "DashChop Login",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Column(
              children: [
                SizedBox(height: MediaQuery.of(context).padding.top + 60),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 20,
                      ),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(25),
                            child: BackdropFilter(
                              filter: ui.ImageFilter.blur(
                                sigmaX: 10,
                                sigmaY: 10,
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: const Color(0xFF7D4427),
                                    width: 3,
                                  ),
                                  borderRadius: BorderRadius.circular(25),
                                  color: Colors.white.withOpacity(0.85),
                                ),
                                padding: const EdgeInsets.all(30),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    children: [
                                      const Text(
                                        "Welcome Back!",
                                        style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1a1a1a),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      const Text(
                                        "Order your favorite meals",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Color(0xFF4a4a4a),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 30),
                                      TextFormField(
                                        controller: _phoneController,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        style: const TextStyle(
                                          color: Color(0xFF1a1a1a),
                                          fontWeight: FontWeight.w600,
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty)
                                            return 'Please enter your phone number or email';
                                          return null;
                                        },
                                        decoration: InputDecoration(
                                          hintText:
                                              "Enter phone number (e.g., 671234567) or email",
                                          hintStyle: TextStyle(
                                            color: Colors.grey[400],
                                          ),
                                          filled: true,
                                          fillColor: const Color(0xFFF5F5F5),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            borderSide: BorderSide.none,
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 14,
                                              ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      TextFormField(
                                        controller: _passwordController,
                                        obscureText: !_showPassword,
                                        style: const TextStyle(
                                          color: Color(0xFF1a1a1a),
                                          fontWeight: FontWeight.w600,
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty)
                                            return 'Please enter your password';
                                          if (value.length < 6)
                                            return 'Password must be at least 6 characters';
                                          return null;
                                        },
                                        decoration: InputDecoration(
                                          hintText: "Enter password",
                                          hintStyle: TextStyle(
                                            color: Colors.grey[400],
                                          ),
                                          filled: true,
                                          fillColor: const Color(0xFFF5F5F5),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            borderSide: BorderSide.none,
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 14,
                                              ),
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              _showPassword
                                                  ? Icons.visibility
                                                  : Icons.visibility_off,
                                              color: Colors.grey,
                                            ),
                                            onPressed: () {
                                              setState(
                                                () => _showPassword =
                                                    !_showPassword,
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          TextButton(
                                            onPressed: () {},
                                            child: const Text(
                                              "Forgot Password?",
                                              style: TextStyle(
                                                color: Color(0xFF7D4427),
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                      SizedBox(
                                        width: double.infinity,
                                        height: 52,
                                        child: ElevatedButton(
                                          onPressed: _isLoading
                                              ? null
                                              : () async {
                                                  if (!_formKey.currentState!
                                                      .validate())
                                                    return;

                                                  setState(
                                                    () => _isLoading = true,
                                                  );

                                                  final inputText =
                                                      _phoneController.text
                                                          .trim();
                                                  final password =
                                                      _passwordController.text
                                                          .trim();

                                                  // 💡 THE SMART TRICK: Check if they typed an '@' symbol
                                                  final email =
                                                      inputText.contains('@')
                                                      ? inputText // If it has an @, leave it alone (e.g., admin@dashchop.com)
                                                      : "$inputText@dashchop.com"; // If it doesn't, it's a phone number. Add the fake suffix!

                                                  try {
                                                    // REAL BACKEND LOGIN
                                                    final supabase = Supabase
                                                        .instance
                                                        .client;
                                                    final authResponse =
                                                        await supabase.auth
                                                            .signInWithPassword(
                                                              email: email,
                                                              password:
                                                                  password,
                                                            );

                                                    if (authResponse.user !=
                                                        null) {
                                                      final userData =
                                                          await supabase
                                                              .from('users')
                                                              .select()
                                                              .eq(
                                                                'id',
                                                                authResponse
                                                                    .user!
                                                                    .id,
                                                              )
                                                              .single();

                                                      final role =
                                                          userData['role'];

                                                      if (mounted) {
                                                        setState(
                                                          () => _isLoading =
                                                              false,
                                                        );

                                                        if (role ==
                                                            'restaurant') {
                                                          Navigator.pushAndRemoveUntil(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  DashboardScreen(),
                                                            ),
                                                            (route) => false,
                                                          );
                                                        } else {
                                                          Navigator.pushAndRemoveUntil(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  MainCustomerNav(),
                                                            ),
                                                            (route) => false,
                                                          );
                                                        }
                                                      }
                                                    }
                                                  } catch (e) {
                                                    if (mounted) {
                                                      setState(
                                                        () =>
                                                            _isLoading = false,
                                                      );
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                            'Login failed: $e',
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                  }
                                                },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xFF7D4427,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            elevation: 0,
                                          ),
                                          child: _isLoading
                                              ? const SizedBox(
                                                  height: 24,
                                                  width: 24,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 3,
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                          Color
                                                        >(Colors.white),
                                                  ),
                                                )
                                              : const Text(
                                                  "LOGIN",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      SizedBox(
                                        width: double.infinity,
                                        height: 52,
                                        child: OutlinedButton.icon(
                                          onPressed:
                                              _authenticateWithFingerprint,
                                          style: OutlinedButton.styleFrom(
                                            side: const BorderSide(
                                              color: Color(0xFF7D4427),
                                              width: 2,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          icon: const Icon(
                                            Icons.fingerprint,
                                            color: Color(0xFF7D4427),
                                            size: 24,
                                          ),
                                          label: const Text(
                                            "Fingerprint Login",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF7D4427),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Don't have an account? ",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => RegisterScreen(),
                                  ),
                                ),
                                child: const Text(
                                  "Register",
                                  style: TextStyle(
                                    color: Color(0xFF7D4427),
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
