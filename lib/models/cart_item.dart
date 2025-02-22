import 'menu_item.dart';

class CartItem {
  final MenuItem menuItem;
  int quantity;

  CartItem({
    required this.menuItem,
    this.quantity = 1,
  });

  double get total => menuItem.price * quantity;

  String get name => menuItem.name;
  double get price => menuItem.price;
}