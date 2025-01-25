import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cart_item.dart';
import '../providers/cart_provider.dart';
import 'menu_screen.dart';

class ThankYouScreen extends StatelessWidget {
  final List<CartItem> items;
  final double total;

  const ThankYouScreen({
    super.key,
    required this.items,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Prevenir el botón de retroceso y forzar el uso del botón de "Volver al Inicio"
        return false;
      },
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 100,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    '¡Gracias por tu pedido!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Estamos preparándolo. En breve estará listo.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Resumen del Pedido:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...items.map((item) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('${item.quantity}x ${item.name}'),
                                    Text(
                                      '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                                    ),
                                  ],
                                ),
                              )),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '\$${total.toStringAsFixed(2)}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {
                      // Limpiar el carrito antes de navegar al menú
                      Provider.of<CartProvider>(context, listen: false).clearCart();
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const MenuScreen(),
                        ),
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 48,
                        vertical: 16,
                      ),
                    ),
                    child: const Text('Volver al Inicio'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
