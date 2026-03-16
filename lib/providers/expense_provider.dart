import 'package:flutter/foundation.dart' hide Category;
import '../models/category_model.dart';
import '../models/expense_model.dart';
import '../services/database_service.dart';

class ExpenseProvider extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();

  List<Expense> _expenses = [];
  List<Expense> _filteredExpenses = [];
  List<Category> _categories = [];
  String _searchQuery = '';
  int? _selectedCategoryId;
  String _sortBy = 'date'; // 'date' or 'amount'
  bool _sortAscending = false;

  List<Expense> get expenses => _filteredExpenses;
  List<Category> get categories => _categories;
  String get searchQuery => _searchQuery;
  int? get selectedCategoryId => _selectedCategoryId;
  String get sortBy => _sortBy;
  bool get sortAscending => _sortAscending;

  // ========== Dashboard Getters ==========

  int get totalItems => _expenses.length;

  double get totalExpenses =>
      _expenses.fold(0.0, (sum, e) => sum + e.amount);

  String get mostExpensiveCategory {
    if (_expenses.isEmpty || _categories.isEmpty) return '-';
    final Map<int, double> catTotals = {};
    for (final e in _expenses) {
      catTotals[e.categoryId] = (catTotals[e.categoryId] ?? 0) + e.amount;
    }
    final maxEntry = catTotals.entries.reduce(
      (a, b) => a.value >= b.value ? a : b,
    );
    final cat = _categories.firstWhere(
      (c) => c.id == maxEntry.key,
      orElse: () => _categories.first,
    );
    return cat.name;
  }

  Map<String, double> get expensesByCategory {
    final Map<int, double> catTotals = {};
    for (final e in _expenses) {
      catTotals[e.categoryId] = (catTotals[e.categoryId] ?? 0) + e.amount;
    }
    final Map<String, double> result = {};
    for (final entry in catTotals.entries) {
      final cat = _categories.firstWhere(
        (c) => c.id == entry.key,
        orElse: () => _categories.first,
      );
      result[cat.name] = entry.value;
    }
    return result;
  }

  Map<int, Category> get categoryMap {
    return {for (final c in _categories) c.id!: c};
  }

  // ========== Data Loading ==========

  Future<void> loadData() async {
    _categories = await _dbService.getCategories();
    _expenses = await _dbService.getExpenses();
    _applyFilters();
    notifyListeners();
  }

  // ========== CRUD ==========

  Future<void> addExpense(Expense expense) async {
    final id = await _dbService.insertExpense(expense);
    final newExpense = expense.copyWith(id: id);
    _expenses.insert(0, newExpense);
    _applyFilters();
    notifyListeners();
  }

  Future<void> updateExpense(Expense expense) async {
    await _dbService.updateExpense(expense);
    final index = _expenses.indexWhere((e) => e.id == expense.id);
    if (index != -1) {
      _expenses[index] = expense;
    }
    _applyFilters();
    notifyListeners();
  }

  Future<void> deleteExpense(int id) async {
    await _dbService.deleteExpense(id);
    _expenses.removeWhere((e) => e.id == id);
    _applyFilters();
    notifyListeners();
  }

  // ========== Search & Filter ==========

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void setSelectedCategory(int? categoryId) {
    _selectedCategoryId = categoryId;
    _applyFilters();
    notifyListeners();
  }

  void setSortBy(String field) {
    if (_sortBy == field) {
      _sortAscending = !_sortAscending;
    } else {
      _sortBy = field;
      _sortAscending = false;
    }
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    List<Expense> result = List.from(_expenses);

    // Search filter
    if (_searchQuery.isNotEmpty) {
      result = result
          .where((e) => e.name.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // Category filter
    if (_selectedCategoryId != null) {
      result = result.where((e) => e.categoryId == _selectedCategoryId).toList();
    }

    // Sort
    if (_sortBy == 'date') {
      result.sort((a, b) => _sortAscending
          ? a.date.compareTo(b.date)
          : b.date.compareTo(a.date));
    } else if (_sortBy == 'amount') {
      result.sort((a, b) => _sortAscending
          ? a.amount.compareTo(b.amount)
          : b.amount.compareTo(a.amount));
    }

    _filteredExpenses = result;
  }
}
