class FoodItem {
  final String id;
  final String name;
  final int price;
  final String category;
  final String imageUrl;

  FoodItem({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    this.imageUrl = 'assets/images/placeholder.png', 
  });

  // This magic function converts Supabase Cloud Data into our Dart Object
  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['id'],
      name: json['name'],
      price: json['price'].toInt(), // Ensures we always get a clean integer
      category: json['category'],
      imageUrl: json['image_url'] ?? 'assets/images/placeholder.png',
    );
  }
}