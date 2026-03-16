class Expense {
  final int? id;
  final String name;
  final int categoryId;
  final double amount;
  final DateTime date;
  final String notes;

  Expense({
    this.id,
    required this.name,
    required this.categoryId,
    required this.amount,
    required this.date,
    required this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'categoryId': categoryId,
      'amount': amount,
      'date': date.toIso8601String(),
      'notes': notes,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] as int?,
      name: map['name'] as String,
      categoryId: map['categoryId'] as int,
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.parse(map['date'] as String),
      notes: map['notes'] as String,
    );
  }

  Expense copyWith({
    int? id,
    String? name,
    int? categoryId,
    double? amount,
    DateTime? date,
    String? notes,
  }) {
    return Expense(
      id: id ?? this.id,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      notes: notes ?? this.notes,
    );
  }
}
