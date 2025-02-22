import 'package:flutter/foundation.dart';
import '../models/menu_item.dart';
import '../models/cart_item.dart';

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);
  
  double get subtotal => _items.fold(0, (sum, item) => sum + item.total);
  double get tax => subtotal * 0.16;
  double get total => subtotal + tax;

  void addItem(MenuItem menuItem) {
    final existingItemIndex = _items.indexWhere(
      (item) => item.name == menuItem.name,
    );

    if (existingItemIndex >= 0) {
      _items[existingItemIndex].quantity++;
    } else {
      _items.add(CartItem(menuItem: menuItem));
    }
    notifyListeners();
  }

  void removeItem(MenuItem menuItem) {
    _items.removeWhere((item) => item.name == menuItem.name);
    notifyListeners();
  }

  void updateQuantity(String itemName, int quantity) {
    final itemIndex = _items.indexWhere((item) => item.name == itemName);
    if (itemIndex >= 0) {
      if (quantity <= 0) {
        _items.removeAt(itemIndex);
      } else {
        _items[itemIndex].quantity = quantity;
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
