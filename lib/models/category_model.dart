class Category {
  final int? id;
  final String name;
  final int iconCodePoint;
  final int color;

  Category({
    this.id,
    required this.name,
    required this.iconCodePoint,
    required this.color,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'iconCodePoint': iconCodePoint,
      'color': color,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int?,
      name: map['name'] as String,
      iconCodePoint: map['iconCodePoint'] as int,
      color: map['color'] as int,
    );
  }
}
