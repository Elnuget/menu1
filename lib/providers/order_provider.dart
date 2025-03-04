import 'package:flutter/foundation.dart';
import '../models/order.dart';
import '../models/cart_item.dart';
import '../services/database_service.dart';

class OrderProvider with ChangeNotifier {
  List<Order> _orders = [];
  bool _isLoading = false;

  List<Order> get orders => List.unmodifiable(_orders);
  bool get isLoading => _isLoading;

  Future<void> loadUserOrders(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final userOrders = await DatabaseService().getOrdersByUser(userId);
      _orders = userOrders;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error al cargar pedidos: $e');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> loadAllOrders() async {
    _isLoading = true;
    notifyListeners();

    try {
      final allOrders = await DatabaseService().getAllOrders();
      _orders = allOrders;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error al cargar todos los pedidos: $e');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> createOrder(
    String userId, 
    String username, 
    List<CartItem> items, 
    double subtotal, 
    double tax, 
    double total
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      final order = Order(
        userId: userId,
        username: username,
        items: items,
        subtotal: subtotal,
        tax: tax,
        total: total,
        orderDate: DateTime.now(),
        status: OrderStatus.preparing, // Inicialmente, el pedido está en preparación
      );

      final orderId = await DatabaseService().createOrder(order, items);
      await loadUserOrders(userId);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('Error al crear pedido: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateOrderStatus(int orderId, OrderStatus status) async {
    _isLoading = true;
    notifyListeners();

    try {
      await DatabaseService().updateOrderStatus(orderId, status);
      
      // Actualizar el pedido en la lista local
      final orderIndex = _orders.indexWhere((order) => order.id == orderId);
      if (orderIndex >= 0) {
        _orders[orderIndex].status = status;
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('Error al actualizar estado del pedido: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
} 