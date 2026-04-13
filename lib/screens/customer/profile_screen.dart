import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../auth/login_screen.dart';

final userProfileProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final supabase = Supabase.instance.client;
  final user = supabase.auth.currentUser;
  if (user == null) throw Exception("User not logged in");

  final userData = await supabase.from('users').select().eq('id', user.id).single();
  return userData;
});

class ProfileScreen extends ConsumerWidget {
  final Color primaryBrown = const Color(0xFF7D4427);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text("Profile", style: TextStyle(color: Color(0xFF1A1A1A), fontSize: 22, fontWeight: FontWeight.bold)),
      ),
      body: userAsync.when(
        loading: () => Center(child: CircularProgressIndicator(color: primaryBrown)),
        error: (err, stack) => Center(child: Text("Error loading profile: $err")),
        data: (userData) {
          String displayContact = userData['email'];
          if (displayContact.endsWith('@dashchop.com')) {
            displayContact = displayContact.replaceAll('@dashchop.com', '');
          }

          return Column(
            children: [
              const SizedBox(height: 40),
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: primaryBrown.withOpacity(0.3), width: 2),
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: primaryBrown.withOpacity(0.1),
                        child: Icon(CupertinoIcons.person_solid, size: 50, color: primaryBrown),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      userData['name'] ?? "DashChop Customer",
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
                    ),
                    const SizedBox(height: 4),
                    Text(displayContact, style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
                  ],
                ),
              ),
              
              const SizedBox(height: 60),

              // CLEAN LOGOUT BUTTON
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))],
                ),
                child: InkWell(
                  onTap: () => _handleLogout(context),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                          child: const Icon(CupertinoIcons.arrow_right_square, color: Colors.red, size: 24),
                        ),
                        const SizedBox(width: 20),
                        const Expanded(child: Text("Log Out", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red))),
                        const Icon(CupertinoIcons.chevron_right, color: Colors.grey, size: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator(color: primaryBrown)),
    );
    await Supabase.instance.client.auth.signOut();
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => LoginScreen()), (route) => false);
    }
  }
}