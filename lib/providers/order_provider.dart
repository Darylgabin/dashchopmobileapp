import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final historyProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final supabase = Supabase.instance.client;
  final userId = supabase.auth.currentUser!.id;

  final response = await supabase
      .from('orders')
      .select()
      .eq('customer_id', userId)
      .order('created_at', ascending: false);

  return List<Map<String, dynamic>>.from(response);
});