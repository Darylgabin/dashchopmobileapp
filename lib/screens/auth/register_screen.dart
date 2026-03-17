import 'package:flutter/material.dart';
import '../customer/home_screen.dart';
import '../restaurant/dashboard_screen.dart';

class RegisterScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String role = "customer"; // default

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("DashChop Register")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            SizedBox(height: 10),
            DropdownButton<String>(
              value: role,
              items: [
                DropdownMenuItem(
                  value: "customer",
                  child: Text("Customer"),
                ),
                DropdownMenuItem(
                  value: "restaurant",
                  child: Text("Restaurant"),
                ),
              ],
              onChanged: (val) {
                if (val != null) {
                  role = val;
                }
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate based on role
                if (role == "customer") {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => HomeScreen()));
                } else {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => DashboardScreen()));
                }
              },
              child: Text("Register"),
            ),
          ],
        ),
      ),
    );
  }
}