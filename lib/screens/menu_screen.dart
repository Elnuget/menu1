import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/menu_item.dart';
import '../providers/cart_provider.dart';
import 'cart_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  String selectedCategory = 'Entradas';
  
  final List<Map<String, dynamic>> categories = [
    {'name': 'Entradas', 'icon': Icons.restaurant_menu},
    {'name': 'Platos Fuertes', 'icon': Icons.lunch_dining},
    {'name': 'Bebidas', 'icon': Icons.local_drink},
    {'name': 'Postres', 'icon': Icons.icecream},
  ];

  final List<MenuItem> menuItems = [
    MenuItem(name: 'Ensalada César', price: 8.99, category: 'Entradas'),
    MenuItem(name: 'Pizza Margarita', price: 12.99, category: 'Platos Fuertes'),
    MenuItem(name: 'Limonada', price: 3.99, category: 'Bebidas'),
    MenuItem(name: 'Tiramisú', price: 6.99, category: 'Postres'),
  ];

  void _navigateToCart() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CartScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menú'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.shopping_cart),
                if (cartProvider.items.isNotEmpty)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '${cartProvider.items.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: _navigateToCart,
          ),
        ],
      ),
      body: Column(
        children: [
          // Categorías
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      IconButton(
                        icon: Icon(categories[index]['icon']),
                        onPressed: () {
                          setState(() {
                            selectedCategory = categories[index]['name'];
                          });
                        },
                        color: selectedCategory == categories[index]['name']
                            ? Theme.of(context).primaryColor
                            : Colors.grey,
                      ),
                      Text(categories[index]['name']),
                    ],
                  ),
                );
              },
            ),
          ),
          // Lista de platos
          Expanded(
            child: ListView.builder(
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final item = menuItems[index];
                if (item.category == selectedCategory) {
                  return ListTile(
                    title: Text(item.name),
                    subtitle: Text('\$${item.price.toStringAsFixed(2)}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.add_shopping_cart),
                      onPressed: () {
                        cartProvider.addItem(item);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${item.name} agregado al carrito'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCart,
        child: const Icon(Icons.shopping_cart),
      ),
    );
  }
}
