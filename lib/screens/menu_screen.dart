import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/menu_item.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import '../services/database_service.dart';
import 'cart_screen.dart';
import 'orders_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> with WidgetsBindingObserver {
  String selectedCategory = 'Bebidas';
  List<MenuItem> menuItems = [];
  bool isLoading = true;
  
  final List<Map<String, dynamic>> categories = [
    {'name': 'Entradas', 'icon': Icons.restaurant_menu},
    {'name': 'Platos Fuertes', 'icon': Icons.lunch_dining},
    {'name': 'Bebidas', 'icon': Icons.local_drink},
    {'name': 'Postres', 'icon': Icons.icecream},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadMenuItems();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadMenuItems();
    }
  }

  Future<void> _loadMenuItems() async {
    print('Cargando items del menú...');
    setState(() {
      isLoading = true;
    });

    try {
      final items = await DatabaseService().getMenuItems();
      print('Items cargados: ${items.length}');
      items.forEach((item) => print('Item: ${item.name} - ${item.category}'));

      if (mounted) {
        setState(() {
          menuItems = items;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error cargando menú: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al cargar el menú'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _navigateToCart() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CartScreen()),
    );
  }

  Future<void> _navigateToAdmin() async {
    final result = await Navigator.pushNamed(context, '/admin');
    print('Regresando de admin screen');
    await _loadMenuItems();
    setState(() {});
  }

  void _handleLogout(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.logout();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sesión cerrada exitosamente'),
        duration: Duration(seconds: 2),
      ),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Cliente'),
        centerTitle: true,
        actions: [
          if (authProvider.isAuthenticated) ...[
            IconButton(
              icon: const Icon(Icons.receipt_long),
              tooltip: 'Mis Pedidos',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const OrdersScreen()),
                );
              },
            ),
            if (authProvider.isAdmin)
              IconButton(
                icon: const Icon(Icons.admin_panel_settings),
                onPressed: _navigateToAdmin,
              ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => _handleLogout(context),
            ),
          ] else
            IconButton(
              icon: const Icon(Icons.login),
              onPressed: () async {
                await Navigator.pushNamed(context, '/login');
                setState(() {});
              },
            ),
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadMenuItems,
              child: Column(
                children: [
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
                                    print('Categoría seleccionada: $selectedCategory');
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
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCart,
        child: const Icon(Icons.shopping_cart),
      ),
    );
  }
}
