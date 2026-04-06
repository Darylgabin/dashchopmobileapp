import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../customer/menu_screen.dart';
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
                color: const Color(0xFFFFA500),
                child: Text(
                  "DashChop Register",
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
                                    color: const Color(0xFFFFA500),
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
                                      TextField(
                                        controller: _nameController,
                                        style: TextStyle(
                                          color: Color(0xFF1a1a1a),
                                          fontWeight: FontWeight.w600,
                                        ),
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
                                      TextField(
                                        controller: _emailController,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        style: TextStyle(
                                          color: Color(0xFF1a1a1a),
                                          fontWeight: FontWeight.w600,
                                        ),
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
                                      TextField(
                                        controller: _passwordController,
                                        obscureText: !_showPassword,
                                        style: TextStyle(
                                          color: Color(0xFF1a1a1a),
                                          fontWeight: FontWeight.w600,
                                        ),
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
                                      TextField(
                                        controller: _confirmPasswordController,
                                        obscureText: !_showConfirmPassword,
                                        style: TextStyle(
                                          color: Color(0xFF1a1a1a),
                                          fontWeight: FontWeight.w600,
                                        ),
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
                                                  final name = _nameController
                                                      .text
                                                      .trim();
                                                  final email = _emailController
                                                      .text
                                                      .trim();
                                                  final password =
                                                      _passwordController.text
                                                          .trim();
                                                  final confirmPassword =
                                                      _confirmPasswordController
                                                          .text
                                                          .trim();

                                                  if (name.isEmpty ||
                                                      email.isEmpty ||
                                                      password.isEmpty ||
                                                      confirmPassword.isEmpty) {
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                          'Please fill all fields',
                                                        ),
                                                      ),
                                                    );
                                                    return;
                                                  }

                                                  if (password !=
                                                      confirmPassword) {
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                          'Passwords do not match',
                                                        ),
                                                      ),
                                                    );
                                                    return;
                                                  }

                                                  setState(
                                                    () => _isLoading = true,
                                                  );

                                                  try {
                                                    // TODO: Implement signup with your authentication service
                                                    throw Exception(
                                                      'Signup not yet implemented',
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
                                              0xFFFFA500,
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
                                    color: Color(0xFFFFA500),
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
