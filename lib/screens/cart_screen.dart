import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/order_provider.dart';
import '../models/cart_item.dart';
import 'orders_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.shopping_cart),
            const SizedBox(width: 8),
            const Text('Mi Carrito'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Vaciar carrito',
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Row(
                    children: [
                      Icon(Icons.delete_forever, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Vaciar Carrito'),
                    ],
                  ),
                  content: const Text('¿Estás seguro de que deseas vaciar tu carrito?'),
                  actions: [
                    TextButton.icon(
                      icon: Icon(Icons.cancel),
                      label: Text('Cancelar'),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                    ElevatedButton.icon(
                      icon: Icon(Icons.delete),
                      label: Text('Vaciar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        Provider.of<CartProvider>(context, listen: false).clearCart();
                        Navigator.of(ctx).pop();
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
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
        child: Consumer<CartProvider>(
          builder: (context, cartProvider, child) {
            if (cartProvider.items.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.shopping_cart,
                      size: 80,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Tu carrito está vacío',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.restaurant_menu),
                      label: const Text('Ir al Menú'),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: cartProvider.items.length,
                    itemBuilder: (context, index) {
                      final CartItem item = cartProvider.items[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              // Icono basado en la categoría
                              CircleAvatar(
                                backgroundColor: _getCategoryColor(item.menuItem.category).withOpacity(0.2),
                                radius: 25,
                                child: Icon(
                                  _getCategoryIcon(item.menuItem.category),
                                  color: _getCategoryColor(item.menuItem.category),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Información del producto
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '\$${item.menuItem.price.toStringAsFixed(2)} por unidad',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Total: \$${item.total.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        color: Colors.blue[700],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Controles de cantidad
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.red.shade100,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: IconButton(
                                          icon: const Icon(Icons.remove, color: Colors.red),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(
                                            minWidth: 36,
                                            minHeight: 36,
                                          ),
                                          onPressed: () => cartProvider.updateQuantity(
                                            item.name,
                                            item.quantity - 1,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12),
                                        child: Text(
                                          '${item.quantity}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.green.shade100,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: IconButton(
                                          icon: const Icon(Icons.add, color: Colors.green),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(
                                            minWidth: 36,
                                            minHeight: 36,
                                          ),
                                          onPressed: () => cartProvider.updateQuantity(
                                            item.name,
                                            item.quantity + 1,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => cartProvider.removeItem(item.menuItem),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Card(
                  elevation: 8,
                  margin: EdgeInsets.zero,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 10,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Subtotal:',
                              style: TextStyle(fontSize: 16),
                            ),
                            Text(
                              '\$${cartProvider.subtotal.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'IVA (16%):',
                              style: TextStyle(fontSize: 16),
                            ),
                            Text(
                              '\$${cartProvider.tax.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(height: 1),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              '\$${cartProvider.total.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: Consumer<AuthProvider>(
                            builder: (context, authProvider, _) {
                              if (!authProvider.isAuthenticated) {
                                return ElevatedButton.icon(
                                  icon: const Icon(Icons.login),
                                  label: const Text('Inicia sesión para realizar pedido'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/login');
                                  },
                                );
                              }
                              
                              return ElevatedButton.icon(
                                icon: const Icon(Icons.check_circle),
                                label: const Text('Realizar Pedido'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () => _processOrder(context, cartProvider, authProvider),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _processOrder(
    BuildContext context, 
    CartProvider cartProvider, 
    AuthProvider authProvider
  ) async {
    if (cartProvider.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El carrito está vacío')),
      );
      return;
    }

    if (authProvider.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes iniciar sesión para realizar un pedido')),
      );
      return;
    }

    // Mostrar diálogo de confirmación
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Pedido'),
        content: const Text('¿Estás seguro de realizar este pedido?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // Mostrar indicador de progreso
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Procesando pedido...'),
          ],
        ),
      ),
    );

    try {
      final userId = authProvider.currentUser!.id.toString();
      final username = authProvider.currentUser!.username;
      
      final success = await orderProvider.createOrder(
        userId,
        username,
        List.from(cartProvider.items),
        cartProvider.subtotal,
        cartProvider.tax,
        cartProvider.total,
      );

      // Cerrar diálogo de progreso
      Navigator.pop(context);

      if (success) {
        cartProvider.clearCart();
        
        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Pedido realizado con éxito!'),
          ),
        );
        
        // Navegar a pantalla de pedidos
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OrdersScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al procesar el pedido. Intente nuevamente.'),
          ),
        );
      }
    } catch (e) {
      // Cerrar diálogo de progreso
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
        ),
      );
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Entradas':
        return Colors.orange;
      case 'Platos Fuertes':
        return Colors.red;
      case 'Bebidas':
        return Colors.blue;
      case 'Postres':
        return Colors.pink;
      default:
        return Colors.green;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Entradas':
        return Icons.restaurant_menu;
      case 'Platos Fuertes':
        return Icons.lunch_dining;
      case 'Bebidas':
        return Icons.local_drink;
      case 'Postres':
        return Icons.icecream;
      default:
        return Icons.food_bank;
    }
  }
}
