class InventoryItem {
  const InventoryItem({
    required this.id,
    required this.name,
    required this.emoji,
    required this.category,
    required this.quantity,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String emoji;
  final String category;
  final int quantity;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  String get copyText {
    final buffer = StringBuffer()
      ..writeln('$emoji $name')
      ..writeln('Category: $category')
      ..writeln('Quantity: $quantity');
    final trimmed = notes.trim();
    if (trimmed.isNotEmpty) {
      buffer.writeln('Notes: $trimmed');
    }
    return buffer.toString().trimRight();
  }

  InventoryItem copyWith({
    String? name,
    String? emoji,
    String? category,
    int? quantity,
    String? notes,
    DateTime? updatedAt,
  }) {
    return InventoryItem(
      id: id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'emoji': emoji,
      'category': category,
      'quantity': quantity,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      emoji: json['emoji'] as String? ?? '📦',
      category: json['category'] as String? ?? 'Collectibles',
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      notes: json['notes'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
