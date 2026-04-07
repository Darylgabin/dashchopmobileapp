import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // ✅ Add this import
import 'screens/auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialize Supabase before running the app
  await Supabase.initialize(
    url: 'https://ncdydycfsjkqrbhjgacg.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5jZHlkeWNmc2prcXJiaGpnYWNnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzU1MTI1NjUsImV4cCI6MjA5MTA4ODU2NX0.5TDP4sOyar5FovPteZuCF12KdjC76aNL8oHxAToS_Vw',
  );

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
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: LoginScreen(),
    );
  }
}
