import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/order_provider.dart';
import '../models/order.dart';
import 'package:intl/intl.dart';
import 'order_details_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      
      if (authProvider.isAuthenticated) {
        final userId = authProvider.currentUser!.id.toString();
        await orderProvider.loadUserOrders(userId);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar pedidos: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.receipt_long, size: 26),
            const SizedBox(width: 8),
            const Text('Mis Pedidos'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar pedidos',
            onPressed: _loadOrders,
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
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Consumer<OrderProvider>(
                builder: (context, orderProvider, child) {
                  if (orderProvider.orders.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.receipt_long,
                            size: 80,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No tienes pedidos',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pushReplacementNamed(context, '/menu');
                            },
                            icon: const Icon(Icons.restaurant_menu),
                            label: const Text('Ir al Menú'),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: _loadOrders,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: orderProvider.orders.length,
                      itemBuilder: (context, index) {
                        final order = orderProvider.orders[index];
                        return _buildOrderCard(context, order);
                      },
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushReplacementNamed(context, '/menu');
        },
        icon: const Icon(Icons.restaurant_menu),
        label: const Text('Menú'),
        backgroundColor: Colors.blue.shade700,
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, Order order) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.restaurant, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(
                      'Pedido #${order.id}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        dateFormat.format(order.orderDate),
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.attach_money, size: 20, color: Colors.green),
                const SizedBox(width: 4),
                Text(
                  'Total: \$${order.total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildStatusWidget(order.status),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OrderDetailsScreen(order: order),
                  ),
                );
              },
              icon: const Icon(Icons.visibility),
              label: const Text('Ver detalles'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 40),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusWidget(OrderStatus status) {
    Color backgroundColor;
    Color textColor = Colors.white;
    String statusText;
    IconData statusIcon;

    switch (status) {
      case OrderStatus.pending:
        backgroundColor = Colors.orange;
        statusText = 'Pendiente';
        statusIcon = Icons.hourglass_empty;
        break;
      case OrderStatus.preparing:
        backgroundColor = Colors.blue;
        statusText = 'En preparación';
        statusIcon = Icons.restaurant;
        break;
      case OrderStatus.ready:
        backgroundColor = Colors.green;
        statusText = 'Listo para entrega';
        statusIcon = Icons.check_circle;
        break;
      case OrderStatus.delivered:
        backgroundColor = Colors.purple;
        statusText = 'Entregado ¡Disfrute su comida!';
        statusIcon = Icons.celebration;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, color: textColor, size: 20),
          const SizedBox(width: 8),
          Text(
            statusText,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
} 