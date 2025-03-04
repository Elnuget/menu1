import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../models/menu_item.dart';
import '../models/user.dart';
import '../models/order.dart';
import '../models/cart_item.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  Database? _db;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<void> connect() async {
    try {
      print('Intentando conectar a la base de datos...');
      final databasesPath = await getDatabasesPath();
      final path = join(databasesPath, 'menu.db');

      _db = await openDatabase(
        path,
        version: 2,
        onCreate: (Database db, int version) async {
          // Crear tabla de usuarios
          await db.execute('''
            CREATE TABLE users (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              username TEXT UNIQUE NOT NULL,
              password TEXT NOT NULL,
              email TEXT UNIQUE NOT NULL,
              is_admin INTEGER NOT NULL DEFAULT 0
            )
          ''');

          // Crear tabla de menú
          await db.execute('''
            CREATE TABLE menu_items (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT UNIQUE NOT NULL,
              price REAL NOT NULL,
              category TEXT NOT NULL
            )
          ''');

          // Crear tabla de pedidos
          await db.execute('''
            CREATE TABLE orders (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              user_id TEXT NOT NULL,
              username TEXT NOT NULL,
              subtotal REAL NOT NULL,
              tax REAL NOT NULL,
              total REAL NOT NULL,
              order_date TEXT NOT NULL,
              status INTEGER NOT NULL DEFAULT 0
            )
          ''');

          // Crear tabla de items de pedidos
          await db.execute('''
            CREATE TABLE order_items (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              order_id INTEGER NOT NULL,
              item_name TEXT NOT NULL,
              price REAL NOT NULL,
              quantity INTEGER NOT NULL,
              FOREIGN KEY (order_id) REFERENCES orders (id) ON DELETE CASCADE
            )
          ''');

          // Insertar usuario administrador por defecto
          final passwordHash = sha256.convert(utf8.encode('admin123')).toString();
          await db.insert('users', {
            'username': 'admin',
            'password': passwordHash,
            'email': 'admin@restaurant.com',
            'is_admin': 1,
          });

          // Insertar elementos de menú de ejemplo
          await db.insert('menu_items', {
            'name': 'Ensalada César',
            'price': 8.99,
            'category': 'Entradas',
          });
          await db.insert('menu_items', {
            'name': 'Pizza Margarita',
            'price': 12.99,
            'category': 'Platos Fuertes',
          });
          await db.insert('menu_items', {
            'name': 'Limonada',
            'price': 3.99,
            'category': 'Bebidas',
          });
          await db.insert('menu_items', {
            'name': 'Tiramisú',
            'price': 6.99,
            'category': 'Postres',
          });
        },
        onUpgrade: (Database db, int oldVersion, int newVersion) async {
          if (oldVersion < 2) {
            // Crear tabla de pedidos si no existe
            await db.execute('''
              CREATE TABLE IF NOT EXISTS orders (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                user_id TEXT NOT NULL,
                username TEXT NOT NULL,
                subtotal REAL NOT NULL,
                tax REAL NOT NULL,
                total REAL NOT NULL,
                order_date TEXT NOT NULL,
                status INTEGER NOT NULL DEFAULT 0
              )
            ''');

            // Crear tabla de items de pedidos
            await db.execute('''
              CREATE TABLE IF NOT EXISTS order_items (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                order_id INTEGER NOT NULL,
                item_name TEXT NOT NULL,
                price REAL NOT NULL,
                quantity INTEGER NOT NULL,
                FOREIGN KEY (order_id) REFERENCES orders (id) ON DELETE CASCADE
              )
            ''');
          }
        },
      );

      print('Conexión exitosa a la base de datos');

      // Verificar si la tabla users existe y tiene datos
      final usersCount = await _db?.query('users');
      print('Número de usuarios en la base de datos: ${usersCount?.length ?? 0}');
      
      // Verificar si existe el usuario admin
      final adminCheck = await _db?.query(
        'users',
        where: 'username = ?',
        whereArgs: ['admin'],
      );
      print('¿Existe el usuario admin?: ${adminCheck?.isNotEmpty}');
    } catch (e) {
      print('Error al conectar a la base de datos: $e');
      rethrow;
    }
  }

  Future<User?> login(String username, String password) async {
    try {
      print('Intentando login con usuario: $username');
      
      // Primero verificamos si el usuario existe
      final userCheck = await _db?.query(
        'users',
        where: 'username = ?',
        whereArgs: [username],
      );
      print('Usuario encontrado en la base de datos: ${userCheck?.isNotEmpty}');

      // Calcular el hash de la contraseña
      final passwordHash = sha256.convert(utf8.encode(password)).toString();

      // Luego intentamos el login completo
      final results = await _db?.query(
        'users',
        where: 'username = ? AND password = ?',
        whereArgs: [username, passwordHash],
      );

      print('Resultados de la consulta de login: ${results?.length ?? 0} filas');
      
      if (results != null && results.isNotEmpty) {
        final user = User.fromMap(results.first);
        print('Usuario encontrado: ${user.username}, isAdmin: ${user.isAdmin}');
        return user;
      }
      print('No se encontró el usuario con las credenciales proporcionadas');
      return null;
    } catch (e) {
      print('Error en login: $e');
      rethrow;
    }
  }

  Future<bool> registerUser(String username, String password, String email) async {
    try {
      print('Intentando registrar usuario: $username');
      
      // Verificar si el usuario ya existe
      final userCheck = await _db?.query(
        'users',
        where: 'username = ? OR email = ?',
        whereArgs: [username, email],
      );
      
      if (userCheck != null && userCheck.isNotEmpty) {
        print('El usuario o email ya existe');
        return false;
      }
      
      // Calcular el hash de la contraseña
      final passwordHash = sha256.convert(utf8.encode(password)).toString();
      
      // Insertar el nuevo usuario
      final result = await _db?.insert('users', {
        'username': username,
        'password': passwordHash,
        'email': email,
        'is_admin': 0,  // Los usuarios registrados no son administradores por defecto
      });
      
      print('Usuario registrado con ID: $result');
      return result != null && result > 0;
    } catch (e) {
      print('Error en registerUser: $e');
      return false;
    }
  }

  Future<List<MenuItem>> getMenuItems() async {
    final results = await _db?.query('menu_items');
    return results?.map((row) => MenuItem(
      name: row['name'] as String,
      price: row['price'] as double,
      category: row['category'] as String,
    )).toList() ?? [];
  }

  Future<void> addMenuItem(MenuItem item) async {
    await _db?.insert('menu_items', {
      'name': item.name,
      'price': item.price,
      'category': item.category,
    });
  }

  Future<void> updateMenuItem(MenuItem item, String originalName) async {
    await _db?.update(
      'menu_items',
      {
        'name': item.name,
        'price': item.price,
        'category': item.category,
      },
      where: 'name = ?',
      whereArgs: [originalName],
    );
  }

  Future<void> deleteMenuItem(String name) async {
    await _db?.delete(
      'menu_items',
      where: 'name = ?',
      whereArgs: [name],
    );
  }

  // Métodos para gestionar pedidos
  Future<int> createOrder(Order order, List<CartItem> items) async {
    final db = _db;
    if (db == null) throw Exception('Base de datos no inicializada');

    int orderId = 0;
    
    await db.transaction((txn) async {
      // Insertar el pedido
      orderId = await txn.insert('orders', order.toMap());
      
      // Insertar los elementos del pedido
      for (var item in items) {
        await txn.insert('order_items', {
          'order_id': orderId,
          'item_name': item.name,
          'price': item.price,
          'quantity': item.quantity,
        });
      }
    });
    
    return orderId;
  }

  Future<List<Order>> getOrdersByUser(String userId) async {
    final db = _db;
    if (db == null) throw Exception('Base de datos no inicializada');
    
    final orderMaps = await db.query(
      'orders',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'order_date DESC',
    );
    
    final orders = <Order>[];
    
    for (var orderMap in orderMaps) {
      final order = Order.fromMap(orderMap);
      
      // Obtener los items del pedido
      final itemMaps = await db.query(
        'order_items',
        where: 'order_id = ?',
        whereArgs: [order.id],
      );
      
      final items = itemMaps.map((itemMap) => OrderItem.fromMap(itemMap)).toList();
      
      orders.add(order);
    }
    
    return orders;
  }

  Future<List<Order>> getAllOrders() async {
    final db = _db;
    if (db == null) throw Exception('Base de datos no inicializada');
    
    final orderMaps = await db.query(
      'orders',
      orderBy: 'order_date DESC',
    );
    
    final orders = <Order>[];
    
    for (var orderMap in orderMaps) {
      final order = Order.fromMap(orderMap);
      
      // Obtener los items del pedido
      final itemMaps = await db.query(
        'order_items',
        where: 'order_id = ?',
        whereArgs: [order.id],
      );
      
      final items = itemMaps.map((itemMap) => OrderItem.fromMap(itemMap)).toList();
      
      orders.add(order);
    }
    
    return orders;
  }

  Future<void> updateOrderStatus(int orderId, OrderStatus status) async {
    final db = _db;
    if (db == null) throw Exception('Base de datos no inicializada');
    
    await db.update(
      'orders',
      {'status': status.index},
      where: 'id = ?',
      whereArgs: [orderId],
    );
  }

  Future<List<OrderItem>> getOrderItems(int orderId) async {
    final db = _db;
    if (db == null) throw Exception('Base de datos no inicializada');
    
    final itemMaps = await db.query(
      'order_items',
      where: 'order_id = ?',
      whereArgs: [orderId],
    );
    
    return itemMaps.map((itemMap) => OrderItem.fromMap(itemMap)).toList();
  }

  void close() {
    _db?.close();
  }
} 