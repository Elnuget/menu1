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
    {'name': 'Entradas', 'icon': Icons.restaurant_menu, 'color': Colors.orange},
    {'name': 'Platos Fuertes', 'icon': Icons.lunch_dining, 'color': Colors.red},
    {'name': 'Bebidas', 'icon': Icons.local_drink, 'color': Colors.blue},
    {'name': 'Postres', 'icon': Icons.icecream, 'color': Colors.pink},
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
        title: Row(
          children: [
            const Icon(Icons.restaurant_menu, size: 28),
            const SizedBox(width: 8),
            const Text('Menú Cliente'),
          ],
        ),
        centerTitle: true,
        elevation: 4,
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
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: _navigateToCart,
              ),
              if (cartProvider.items.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
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
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.blue.shade100,
                    Colors.blue.shade50,
                  ],
                ),
              ),
              child: RefreshIndicator(
                onRefresh: _loadMenuItems,
                child: Column(
                  children: [
                    // Categorías con animación
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 110,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final isSelected = selectedCategory == categories[index]['name'];
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isSelected 
                                        ? categories[index]['color'] 
                                        : Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: categories[index]['color']
                                                  .withOpacity(0.4),
                                              spreadRadius: 2,
                                              blurRadius: 5,
                                            )
                                          ]
                                        : null,
                                  ),
                                  child: IconButton(
                                    icon: Icon(categories[index]['icon']),
                                    color: isSelected ? Colors.white : Colors.grey.shade700,
                                    iconSize: 32,
                                    onPressed: () {
                                      setState(() {
                                        selectedCategory = categories[index]['name'];
                                        print('Categoría seleccionada: $selectedCategory');
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  categories[index]['name'],
                                  style: TextStyle(
                                    fontWeight: isSelected 
                                        ? FontWeight.bold 
                                        : FontWeight.normal,
                                    color: isSelected 
                                        ? categories[index]['color'] 
                                        : Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    // Lista de elementos del menú
                    Expanded(
                      child: menuItems.where((item) => item.category == selectedCategory).isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.no_food,
                                    size: 64,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No hay productos en esta categoría',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : GridView.builder(
                              padding: const EdgeInsets.all(8),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.8,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                              ),
                              itemCount: menuItems
                                  .where((item) => item.category == selectedCategory)
                                  .length,
                              itemBuilder: (context, index) {
                                final filteredItems = menuItems
                                    .where((item) => item.category == selectedCategory)
                                    .toList();
                                final item = filteredItems[index];
                                
                                // Seleccionar un icono basado en la categoría
                                IconData itemIcon;
                                Color itemColor;
                                
                                switch (item.category) {
                                  case 'Entradas':
                                    itemIcon = Icons.restaurant_menu;
                                    itemColor = Colors.orange;
                                    break;
                                  case 'Platos Fuertes':
                                    itemIcon = Icons.lunch_dining;
                                    itemColor = Colors.red;
                                    break;
                                  case 'Bebidas':
                                    itemIcon = Icons.local_drink;
                                    itemColor = Colors.blue;
                                    break;
                                  case 'Postres':
                                    itemIcon = Icons.icecream;
                                    itemColor = Colors.pink;
                                    break;
                                  default:
                                    itemIcon = Icons.food_bank;
                                    itemColor = Colors.green;
                                }
                                
                                return Card(
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      // Parte superior con el icono
                                      Container(
                                        height: 100,
                                        decoration: BoxDecoration(
                                          color: itemColor.withOpacity(0.2),
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(12),
                                            topRight: Radius.circular(12),
                                          ),
                                        ),
                                        child: Icon(
                                          itemIcon,
                                          size: 50,
                                          color: itemColor,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '\$${item.price.toStringAsFixed(2)}',
                                              style: TextStyle(
                                                color: Colors.blue.shade700,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            ElevatedButton.icon(
                                              onPressed: () {
                                                cartProvider.addItem(item);
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text('${item.name} agregado al carrito'),
                                                    duration: const Duration(seconds: 1),
                                                    backgroundColor: Colors.green,
                                                    action: SnackBarAction(
                                                      label: 'VER CARRITO',
                                                      onPressed: _navigateToCart,
                                                      textColor: Colors.white,
                                                    ),
                                                  ),
                                                );
                                              },
                                              icon: const Icon(Icons.add_shopping_cart, size: 18),
                                              label: const Text('Agregar'),
                                              style: ElevatedButton.styleFrom(
                                                minimumSize: const Size(double.infinity, 36),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToCart,
        icon: const Icon(Icons.shopping_cart),
        label: const Text('Ver Carrito'),
        backgroundColor: Colors.blue.shade700,
      ),
    );
  }
}
