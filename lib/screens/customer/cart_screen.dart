import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/cart_provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'location_picker_screen.dart';

class CartScreen extends ConsumerStatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  final Color primaryBrown = const Color(0xFF7D4427);
  final TextEditingController _addressController = TextEditingController();
  bool _isProcessing = false;
  LatLng? _selectedDeliveryLocation;

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);

    int subtotal = cartNotifier.subtotal;
    int deliveryFee = cartItems.isEmpty ? 0 : 1000;
    int total = subtotal + deliveryFee;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Your Cart",
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: cartItems.isEmpty
                ? Center(
                    child: Text(
                      "Your cart is empty. Go add some cakes!",
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 16,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) =>
                        _buildCartItem(cartItems[index]),
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Location Description",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  // ✅ RENAMED TEXT FIELD
                  TextField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      hintText:
                          "Describe your location or any special instructions...",
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(
                        CupertinoIcons.doc_text_fill,
                        color: primaryBrown,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF5F5F5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ListTile(
                    leading: const Icon(
                      CupertinoIcons.map_pin_ellipse,
                      color: Colors.red,
                    ),
                    title: Text(
                      _selectedDeliveryLocation == null
                          ? "Set GPS Delivery Pin"
                          : "GPS Location Saved!",
                    ),
                    subtitle: const Text(
                      "Required: Drag the pin to your exact house",
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      final selectedLatLng = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LocationPickerScreen(),
                        ),
                      );
                      if (selectedLatLng != null)
                        setState(
                          () => _selectedDeliveryLocation = selectedLatLng,
                        );
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildReceiptRow("Subtotal", "$subtotal F"),
                  const SizedBox(height: 8),
                  _buildReceiptRow("Delivery Fee", "$deliveryFee F"),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1, thickness: 1),
                  ),
                  _buildReceiptRow("Total", "$total F", isTotal: true),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: cartItems.isEmpty || _isProcessing
                          ? null
                          : () async {
                              if (_selectedDeliveryLocation == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Please set your delivery pin on the map first!",
                                    ),
                                  ),
                                );
                                return;
                              }

                              setState(() => _isProcessing = true);

                              // We still send the description, even if it's blank
                              final description = _addressController.text
                                  .trim();
                              bool success = await ref
                                  .read(cartProvider.notifier)
                                  .checkout(
                                    description,
                                    _selectedDeliveryLocation!.latitude,
                                    _selectedDeliveryLocation!.longitude,
                                    deliveryFee,
                                  );

                              setState(() => _isProcessing = false);

                              if (success) {
                                _addressController.clear();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                      'Order Placed Successfully!',
                                    ),
                                    backgroundColor: primaryBrown,
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Checkout failed. Try again.',
                                    ),
                                  ),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBrown,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 0,
                      ),
                      child: _isProcessing
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "Place Order",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(CartItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 70,
            width: 70,
            decoration: BoxDecoration(
              color: primaryBrown.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.cake, color: primaryBrown.withOpacity(0.5)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.food.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${item.food.price} F",
                  style: TextStyle(
                    color: primaryBrown,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(CupertinoIcons.minus, size: 16),
                  onPressed: () => ref
                      .read(cartProvider.notifier)
                      .removeSingleItem(item.food),
                ),
                Text(
                  "${item.quantity}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(CupertinoIcons.plus, size: 16),
                  color: primaryBrown,
                  onPressed: () =>
                      ref.read(cartProvider.notifier).addItem(item.food),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptRow(String title, String amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            color: isTotal ? const Color(0xFF1A1A1A) : Colors.grey.shade600,
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            color: isTotal ? primaryBrown : const Color(0xFF1A1A1A),
            fontSize: isTotal ? 20 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
