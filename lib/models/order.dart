import 'cart_item.dart';

class Order {
  final List<CartItem> items;
  final String? notes;
  final double subtotal;
  final double tax;
  final double total;

  Order({
    required this.items,
    this.notes,
    required this.subtotal,
    required this.tax,
    required this.total,
  });
}
