import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/food_model.dart';

// This FutureProvider automatically talks to Supabase and gets your menu
final menuProvider = FutureProvider<List<FoodItem>>((ref) async {
  final supabase = Supabase.instance.client;
  
  // Go to the 'food_items' table and get everything
  final response = await supabase.from('food_items').select();
  
  // Convert the JSON list into a list of FoodItem objects
  return response.map((data) => FoodItem.fromJson(data)).toList();
});