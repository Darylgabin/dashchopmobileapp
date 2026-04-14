import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final historyProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final supabase = Supabase.instance.client;
  final userId = supabase.auth.currentUser!.id;

  // .stream() keeps a live connection to the database
  return supabase
      .from('orders')
      .stream(primaryKey: ['id'])
      .eq('customer_id', userId)
      .order('created_at')
      .map((maps) => maps.toList());
});
