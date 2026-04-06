import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'menu_screen.dart';
// We will create these two later, using placeholders for now:
import 'cart_screen.dart';
import 'order_history_screen.dart';

class MainCustomerNav extends StatefulWidget {
  @override
  _MainCustomerNavState createState() => _MainCustomerNavState();
}

class _MainCustomerNavState extends State<MainCustomerNav> {
  int _currentIndex = 0;
  final Color primaryBrown = const Color(0xFF7D4427);

  final List<Widget> _screens = [
    MenuScreen(),
    Center(child: CartScreen()), 
    Center(child: OrderHistoryScreen()), // Placeholder
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            backgroundColor: Colors.white,
            selectedItemColor: primaryBrown,
            unselectedItemColor: Colors.grey.shade400,
            showSelectedLabels: true,
            showUnselectedLabels: false,
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.square_grid_2x2),
                activeIcon: Icon(CupertinoIcons.square_grid_2x2_fill),
                label: 'Menu',
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.cart),
                activeIcon: Icon(CupertinoIcons.cart_fill),
                label: 'Cart',
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.clock),
                activeIcon: Icon(CupertinoIcons.clock_fill),
                label: 'History',
              ),
            ],
          ),
        ),
      ),
    );
  }
}