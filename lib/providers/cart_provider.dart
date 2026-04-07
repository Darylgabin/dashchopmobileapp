import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/dummy_data.dart';

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

  // Calculate subtotal dynamically
  int get subtotal => state.fold(0, (sum, item) => sum + (item.food.price * item.quantity));
}

// 3. The global provider we will call from our screens
final cartProvider = NotifierProvider<CartNotifier, List<CartItem>>(() {
  return CartNotifier();
});