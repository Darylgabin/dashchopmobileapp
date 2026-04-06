import 'package:flutter/material.dart';
import 'screens/auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(DashChopApp());
}

class DashChopApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DashChop',
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}
