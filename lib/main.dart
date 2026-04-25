import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/auth/login_screen.dart';
import 'screens/customer/main_customer_nav.dart';
import 'screens/restaurant/dashboard_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

 //supabase initialization 
  await Supabase.initialize(
    url:  'SUPABASE_URL' ,
    anonKey: 'SUPABASE_ANON_KEY',
       
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
        colorScheme: ColorScheme.fromSeed(seedColor: primaryBrown, primary: primaryBrown),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          titleTextStyle: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      // Use our new AuthGate instead of going straight to LoginScreen
      home: const AuthGate(), 
    );
  }
}

// 🧠 This Widget decides which screen to show when the app opens
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    // Simulate a tiny loading delay for visual smoothness
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    if (user == null) {
      // Not logged in -> Send to Login
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
    } else {
      // Logged in! Fetch role to decide where they go
      try {
        final userData = await supabase.from('users').select('role').eq('id', user.id).single();
        if (userData['role'] == 'restaurant') {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => DashboardScreen()));
        } else {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MainCustomerNav()));
        }
      } catch (e) {
        // If fetch fails, force them back to login just in case
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show a loading spinner while it checks the secure token
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(color: Color(0xFF7D4427)),
      ),
    );
  }
}