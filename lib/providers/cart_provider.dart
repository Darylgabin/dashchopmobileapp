import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/food_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// 1. We create a small model to track Food + Quantity
class CartItem {
  final FoodItem food;
  int quantity;

  CartItem({required this.food, this.quantity = 1});
}

// 2. The Notifier manages the logic using Modern Riverpod 2.0 Syntax
class CartNotifier extends Notifier<List<CartItem>> {
  // build() initializes the starting state (an empty list of CartItems)
  @override
  List<CartItem> build() {
    return [];
  }

  // Adds an item or increases its quantity
  void addItem(FoodItem food) {
    final existingIndex = state.indexWhere((item) => item.food.id == food.id);

    if (existingIndex >= 0) {
      // If it exists, increase quantity
      var updatedCart = [...state];
      updatedCart[existingIndex].quantity++;
      state = updatedCart;
    } else {
      // If it's new, add to list
      state = [...state, CartItem(food: food)];
    }
  }

  // Decreases quantity, or removes it if quantity reaches 0
  void removeSingleItem(FoodItem food) {
    final existingIndex = state.indexWhere((item) => item.food.id == food.id);

    if (existingIndex >= 0) {
      var updatedCart = [...state];
      if (updatedCart[existingIndex].quantity > 1) {
        updatedCart[existingIndex].quantity--;
        state = updatedCart; // Triggers UI update
      } else {
        updatedCart.removeAt(existingIndex);
        state = updatedCart; // Triggers UI update
      }
    }
  }

  // Clears the whole cart after ordering
  void clearCart() {
    state = [];
  }

  // --- ADD THIS INSIDE CartNotifier ---
  Future<bool> checkout(
    String address,
    double latitude,
    double longitude,
    int deliveryFee, // 👈 NEW: Accepts the dynamic fee from the Cart Screen
  ) async {
    if (state.isEmpty || address.isEmpty) return false;

    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser!.id;
      // We use the Admin UUID you generated to link the order to the restaurant
      final restaurantId = 'bca3a1ee-2a21-4994-ae19-531b8de91d32';

      // 💡 NEW: Calculates total using the dynamic fee!
      final total = subtotal + deliveryFee;

      // 1. Create the Order in the database
      final orderResponse = await supabase
          .from('orders')
          .insert({
            'customer_id': userId,
            'restaurant_id': restaurantId,
            'total_price': total,
            'delivery_address': address,
            'delivery_lat': latitude, // 👈 The Exact GPS Pin
            'delivery_lng': longitude, // 👈 The Exact GPS Pin
            'status': 'confirmed',
          })
          .select()
          .single();

      final orderId = orderResponse['id'];

      // 2. Insert all the individual cakes/pies into order_items
      final orderItemsData = state
          .map(
            (item) => {
              'order_id': orderId,
              'food_item_id': item.food.id,
              'quantity': item.quantity,
              'price': item.food.price,
            },
          )
          .toList();

      await supabase.from('order_items').insert(orderItemsData);

      // 3. Clear the cart on success
      clearCart();
      return true;
    } catch (e) {
      print("Checkout Error: $e");
      return false;
    }
  }

  // Calculate subtotal dynamically
  int get subtotal =>
      state.fold(0, (sum, item) => sum + (item.food.price * item.quantity));
}

// 3. The global provider we will call from our screens
final cartProvider = NotifierProvider<CartNotifier, List<CartItem>>(() {
  return CartNotifier();
});
