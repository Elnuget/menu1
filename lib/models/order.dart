import 'cart_item.dart';
import 'package:flutter/foundation.dart';

enum OrderStatus {
  pending,    // Pendiente
  preparing,  // En preparación
  ready,      // Listo para entrega
  delivered   // Entregado
}

class Order {
  final int? id;
  final String userId;
  final String username;
  final List<CartItem> items;
  final double subtotal;
  final double tax;
  final double total;
  final DateTime orderDate;
  OrderStatus status;

  Order({
    this.id,
    required this.userId,
    required this.username,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.orderDate,
    this.status = OrderStatus.pending,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'username': username,
      'subtotal': subtotal,
      'tax': tax,
      'total': total,
      'order_date': orderDate.toIso8601String(),
      'status': status.index,
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'] as int?,
      userId: map['user_id'] as String,
      username: map['username'] as String,
      items: [], // Los items se cargarán por separado
      subtotal: map['subtotal'] as double,
      tax: map['tax'] as double,
      total: map['total'] as double,
      orderDate: DateTime.parse(map['order_date'] as String),
      status: OrderStatus.values[map['status'] as int],
    );
  }

  String get statusText {
    switch (status) {
      case OrderStatus.pending:
        return 'Pendiente';
      case OrderStatus.preparing:
        return 'En preparación';
      case OrderStatus.ready:
        return 'Listo para entrega';
      case OrderStatus.delivered:
        return 'Entregado';
    }
  }
}

class OrderItem {
  final int? id;
  final int orderId;
  final String itemName;
  final double price;
  final int quantity;

  OrderItem({
    this.id,
    required this.orderId,
    required this.itemName,
    required this.price,
    required this.quantity,
  });

  double get total => price * quantity;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order_id': orderId,
      'item_name': itemName,
      'price': price,
      'quantity': quantity,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      id: map['id'] as int?,
      orderId: map['order_id'] as int,
      itemName: map['item_name'] as String,
      price: map['price'] as double,
      quantity: map['quantity'] as int,
    );
  }

  factory OrderItem.fromCartItem(CartItem item, int orderId) {
    return OrderItem(
      orderId: orderId,
      itemName: item.name,
      price: item.price,
      quantity: item.quantity,
    );
  }
}
