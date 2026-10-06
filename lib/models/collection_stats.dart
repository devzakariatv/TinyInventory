import 'inventory_item.dart';

class CollectionStats {
  CollectionStats(List<InventoryItem> source)
      : items = List<InventoryItem>.unmodifiable(source);

  final List<InventoryItem> items;

  bool get isEmpty => items.isEmpty;

  int get itemCount => items.length;

  int get totalQuantity => items.fold(0, (sum, item) => sum + item.quantity);

  Map<String, int> get quantityByCategory {
    final totals = <String, int>{};
    for (final item in items) {
      totals[item.category] = (totals[item.category] ?? 0) + item.quantity;
    }
    final entries = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map<String, int>.fromEntries(entries);
  }

  int get categoryCount => quantityByCategory.length;

  InventoryItem? get largestStack {
    if (items.isEmpty) return null;
    return items.reduce((a, b) => a.quantity >= b.quantity ? a : b);
  }

  InventoryItem? get newest {
    if (items.isEmpty) return null;
    return items.reduce((a, b) => a.updatedAt.isAfter(b.updatedAt) ? a : b);
  }

  String get copyText {
    if (isEmpty) {
      return '🧰 Tiny Inventory\nYour collection is empty.';
    }
    final buffer = StringBuffer()
      ..writeln('🧰 Tiny Inventory')
      ..writeln('Pieces: $itemCount')
      ..writeln('Total quantity: $totalQuantity')
      ..writeln('Categories: $categoryCount');
    final top = largestStack;
    if (top != null) {
      buffer.writeln('Largest stack: ${top.emoji} ${top.name} (${top.quantity})');
    }
    if (quantityByCategory.isNotEmpty) {
      buffer.writeln('By category:');
      for (final entry in quantityByCategory.entries) {
        buffer.writeln('• ${entry.key}: ${entry.value}');
      }
    }
    return buffer.toString().trimRight();
  }
}
