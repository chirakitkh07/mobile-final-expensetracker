import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/category_model.dart';
import '../models/expense_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'expense_tracker.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE categories(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        iconCodePoint INTEGER NOT NULL,
        color INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE expenses(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        categoryId INTEGER NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        notes TEXT NOT NULL,
        FOREIGN KEY (categoryId) REFERENCES categories(id)
      )
    ''');

    // Insert default categories
    final categories = [
      {'name': 'Food & Drinks', 'iconCodePoint': Icons.restaurant.codePoint, 'color': 0xFFFF6B6B},
      {'name': 'Transport', 'iconCodePoint': Icons.directions_car.codePoint, 'color': 0xFF4ECDC4},
      {'name': 'Shopping', 'iconCodePoint': Icons.shopping_bag.codePoint, 'color': 0xFFFFE66D},
      {'name': 'Entertainment', 'iconCodePoint': Icons.movie.codePoint, 'color': 0xFFA78BFA},
      {'name': 'Health', 'iconCodePoint': Icons.local_hospital.codePoint, 'color': 0xFF6BCB77},
      {'name': 'Bills & Utilities', 'iconCodePoint': Icons.receipt_long.codePoint, 'color': 0xFFFF8C42},
    ];

    for (final cat in categories) {
      await db.insert('categories', cat);
    }

    // Insert 12 sample expenses
    final now = DateTime.now();
    final sampleExpenses = [
      {'name': 'Lunch at Somtam Shop', 'categoryId': 1, 'amount': 85.0, 'date': now.subtract(const Duration(days: 1)).toIso8601String(), 'notes': 'Papaya salad and sticky rice'},
      {'name': 'Grab to University', 'categoryId': 2, 'amount': 120.0, 'date': now.subtract(const Duration(days: 1)).toIso8601String(), 'notes': 'Morning commute'},
      {'name': 'New Headphones', 'categoryId': 3, 'amount': 1590.0, 'date': now.subtract(const Duration(days: 2)).toIso8601String(), 'notes': 'Bluetooth wireless headphones'},
      {'name': 'Movie Ticket', 'categoryId': 4, 'amount': 200.0, 'date': now.subtract(const Duration(days: 3)).toIso8601String(), 'notes': 'Weekend movie night'},
      {'name': 'Coffee at Café Amazon', 'categoryId': 1, 'amount': 65.0, 'date': now.subtract(const Duration(days: 3)).toIso8601String(), 'notes': 'Iced latte'},
      {'name': 'Monthly Bus Pass', 'categoryId': 2, 'amount': 500.0, 'date': now.subtract(const Duration(days: 5)).toIso8601String(), 'notes': 'University shuttle pass'},
      {'name': 'Pharmacy Medicine', 'categoryId': 5, 'amount': 350.0, 'date': now.subtract(const Duration(days: 6)).toIso8601String(), 'notes': 'Cold medicine and vitamins'},
      {'name': 'Electric Bill', 'categoryId': 6, 'amount': 850.0, 'date': now.subtract(const Duration(days: 7)).toIso8601String(), 'notes': 'March electricity'},
      {'name': 'Dinner at MK Restaurant', 'categoryId': 1, 'amount': 450.0, 'date': now.subtract(const Duration(days: 8)).toIso8601String(), 'notes': 'Dinner with friends'},
      {'name': 'T-Shirt from Uniqlo', 'categoryId': 3, 'amount': 590.0, 'date': now.subtract(const Duration(days: 9)).toIso8601String(), 'notes': 'Cotton casual t-shirt'},
      {'name': 'Internet Bill', 'categoryId': 6, 'amount': 699.0, 'date': now.subtract(const Duration(days: 10)).toIso8601String(), 'notes': 'Monthly internet subscription'},
      {'name': 'Gym Membership', 'categoryId': 5, 'amount': 1200.0, 'date': now.subtract(const Duration(days: 12)).toIso8601String(), 'notes': 'Monthly gym fee'},
    ];

    for (final expense in sampleExpenses) {
      await db.insert('expenses', expense);
    }
  }

  // ========== Category CRUD ==========

  Future<List<Category>> getCategories() async {
    final db = await database;
    final maps = await db.query('categories');
    return maps.map((map) => Category.fromMap(map)).toList();
  }

  // ========== Expense CRUD ==========

  Future<List<Expense>> getExpenses() async {
    final db = await database;
    final maps = await db.query('expenses', orderBy: 'date DESC');
    return maps.map((map) => Expense.fromMap(map)).toList();
  }

  Future<Expense> getExpenseById(int id) async {
    final db = await database;
    final maps = await db.query('expenses', where: 'id = ?', whereArgs: [id]);
    return Expense.fromMap(maps.first);
  }

  Future<int> insertExpense(Expense expense) async {
    final db = await database;
    return await db.insert('expenses', expense.toMap());
  }

  Future<int> updateExpense(Expense expense) async {
    final db = await database;
    return await db.update(
      'expenses',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  Future<int> deleteExpense(int id) async {
    final db = await database;
    return await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Expense>> searchExpenses(String query) async {
    final db = await database;
    final maps = await db.query(
      'expenses',
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'date DESC',
    );
    return maps.map((map) => Expense.fromMap(map)).toList();
  }

  Future<List<Expense>> getExpensesByCategory(int categoryId) async {
    final db = await database;
    final maps = await db.query(
      'expenses',
      where: 'categoryId = ?',
      whereArgs: [categoryId],
      orderBy: 'date DESC',
    );
    return maps.map((map) => Expense.fromMap(map)).toList();
  }
}
