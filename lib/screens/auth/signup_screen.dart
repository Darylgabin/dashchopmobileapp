import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../customer/main_customer_nav.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/signup_bg.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            // Dark overlay for better readability
            Container(color: Colors.black.withOpacity(0.3)),
            // Header
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
                child: Text(
                  "Register",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            // Form Content
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
                          // Glassmorphism Card
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
                                      Text(
                                        "Welcome Onboard!",
                                        style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF1a1a1a),
                                        ),
                                      ),
                                      SizedBox(height: 12),
                                      Text(
                                        "Join our community and order meals",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: const Color(0xFF4a4a4a),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(height: 30),
                                      // Full Name Field
                                      TextFormField(
                                        controller: _nameController,
                                        style: TextStyle(
                                          color: Color(0xFF1a1a1a),
                                          fontWeight: FontWeight.w600,
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter your full name';
                                          }
                                          if (value.length < 3) {
                                            return 'Name must be at least 3 characters';
                                          }
                                          return null;
                                        },
                                        decoration: InputDecoration(
                                          hintText: "Enter full name",
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
                                      SizedBox(height: 16),
                                      // Email Field
                                      TextFormField(
                                        controller: _emailController,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        style: TextStyle(
                                          color: Color(0xFF1a1a1a),
                                          fontWeight: FontWeight.w600,
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter your email';
                                          }
                                          if (!value.contains('@')) {
                                            return 'Please enter a valid email';
                                          }
                                          return null;
                                        },
                                        decoration: InputDecoration(
                                          hintText: "Enter your email",
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
                                      SizedBox(height: 16),
                                      // Password Field
                                      TextFormField(
                                        controller: _passwordController,
                                        obscureText: !_showPassword,
                                        style: TextStyle(
                                          color: Color(0xFF1a1a1a),
                                          fontWeight: FontWeight.w600,
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter a password';
                                          }
                                          if (value.length < 6) {
                                            return 'Password must be at least 6 characters';
                                          }
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
                                              setState(() {
                                                _showPassword = !_showPassword;
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 16),
                                      // Confirm Password Field
                                      TextFormField(
                                        controller: _confirmPasswordController,
                                        obscureText: !_showConfirmPassword,
                                        style: TextStyle(
                                          color: Color(0xFF1a1a1a),
                                          fontWeight: FontWeight.w600,
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please confirm your password';
                                          }
                                          if (value !=
                                              _passwordController.text) {
                                            return 'Passwords do not match';
                                          }
                                          return null;
                                        },
                                        decoration: InputDecoration(
                                          hintText: "Confirm password",
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
                                              _showConfirmPassword
                                                  ? Icons.visibility
                                                  : Icons.visibility_off,
                                              color: Colors.grey,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _showConfirmPassword =
                                                    !_showConfirmPassword;
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 28),
                                      // Register Button
                                      SizedBox(
                                        width: double.infinity,
                                        height: 52,
                                        child: ElevatedButton(
                                          onPressed: _isLoading
                                              ? null
                                              : () async {
                                                  if (!_formKey.currentState!
                                                      .validate()) {
                                                    return;
                                                  }

                                                  setState(
                                                    () => _isLoading = true,
                                                  );

                                                  try {
                                                    // TODO: Implement signup with your authentication service
                                                    // For now, navigate to MainCustomerNav on success
                                                    await Future.delayed(
                                                      Duration(seconds: 1),
                                                    );

                                                    Navigator.pushReplacement(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (_) =>
                                                            MainCustomerNav(),
                                                      ),
                                                    );
                                                  } catch (e) {
                                                    setState(
                                                      () => _isLoading = false,
                                                    );

                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          'Signup failed: $e',
                                                        ),
                                                      ),
                                                    );
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
                                              ? SizedBox(
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
                                                  "REGISTER",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
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
                          SizedBox(height: 24),
                          // Login Link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Already have an account? ",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => LoginScreen(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  "Login",
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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
