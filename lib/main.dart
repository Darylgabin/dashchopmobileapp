import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Run: flutter pub add flutter_riverpod
import 'screens/auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Wrap with ProviderScope for Riverpod state management
  runApp(const ProviderScope(child: DashChopApp()));
}

class DashChopApp extends StatelessWidget {
  const DashChopApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryBrown = Color(0xFF7D4427);

    return MaterialApp(
      title: 'DashChop',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: primaryBrown,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryBrown,
          primary: primaryBrown,
        ),
        // This ensures all your AppBars look the same automatically
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.black, 
            fontSize: 20, 
            fontWeight: FontWeight.bold
          ),
        ),
      ),
      home: LoginScreen(),
    );
  }
}