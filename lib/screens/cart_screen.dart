import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import 'order_confirmation_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text('Carrito de Compras'),
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cartProvider.items.length,
                  itemBuilder: (context, index) {
                    final item = cartProvider.items[index];
                    return ListTile(
                      title: Text(item.name),
                      subtitle: Text('\$${item.total.toStringAsFixed(2)}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () => cartProvider.updateQuantity(
                                item.name, item.quantity - 1),
                          ),
                          Text('${item.quantity}'),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () => cartProvider.updateQuantity(
                                item.name, item.quantity + 1),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => cartProvider.removeItem(item.name),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Card(
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Subtotal'),
                          Text('\$${cartProvider.subtotal.toStringAsFixed(2)}'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Impuestos (16%)'),
                          Text('\$${cartProvider.tax.toStringAsFixed(2)}'),
                        ],
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('\$${cartProvider.total.toStringAsFixed(2)}',
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: cartProvider.items.isEmpty
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OrderConfirmationScreen(
                                cartItems: cartProvider.items,
                                subtotal: cartProvider.subtotal,
                                tax: cartProvider.tax,
                                total: cartProvider.total,
                              ),
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: const Text('Confirmar Pedido'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
