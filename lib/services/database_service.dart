import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../models/menu_item.dart';
import '../models/user.dart';

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
        version: 1,
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

  void close() {
    _db?.close();
  }
} 