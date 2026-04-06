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
    this.imageUrl = 'assets/images/placeholder.png', // We'll use a placeholder until DB is connected
  });
}

final List<FoodItem> dummyMenu = [
  // CAKES
  FoodItem(id: '1', name: 'Plain Cake', price: 3500, category: 'Cakes'),
  FoodItem(id: '2', name: 'Yoghurt Cake', price: 5000, category: 'Cakes'),
  FoodItem(id: '3', name: 'Carrot Cake', price: 5000, category: 'Cakes'),
  FoodItem(id: '4', name: 'Banana Cake', price: 5000, category: 'Cakes'),
  FoodItem(id: '5', name: 'Plain Chocolate Cake', price: 5000, category: 'Cakes'),
  FoodItem(id: '6', name: 'Chocolate Cake (Icing)', price: 500, category: 'Cakes'),
  
  // PANCAKES & PIES
  FoodItem(id: '7', name: 'Meat Pie', price: 200, category: 'Pies & Pancakes'),
  FoodItem(id: '8', name: 'Natural Pancake', price: 100, category: 'Pies & Pancakes'),
  FoodItem(id: '9', name: 'Pancake (Choco & Honey)', price: 150, category: 'Pies & Pancakes'),
  FoodItem(id: '10', name: 'Mega Meat Pie (Cheese)', price: 10000, category: 'Pies & Pancakes'),
];