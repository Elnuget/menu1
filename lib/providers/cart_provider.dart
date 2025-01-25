import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../models/menu_item.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  double get subtotal => _items.fold(0, (sum, item) => sum + item.total);
  double get tax => subtotal * 0.16;
  double get total => subtotal + tax;

  void addItem(MenuItem menuItem) {
    final existingItem = _items.firstWhere(
      (item) => item.name == menuItem.name,
      orElse: () => CartItem(
        name: menuItem.name,
        price: menuItem.price,
        quantity: 0,
      ),
    );

    if (existingItem.quantity == 0) {
      _items.add(existingItem);
    }
    existingItem.quantity++;
    notifyListeners();
  }

  void removeItem(String itemName) {
    _items.removeWhere((item) => item.name == itemName);
    notifyListeners();
  }

  void updateQuantity(String itemName, int quantity) {
    final item = _items.firstWhere((item) => item.name == itemName);
    if (quantity <= 0) {
      removeItem(itemName);
    } else {
      item.quantity = quantity;
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
