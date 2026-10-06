import 'package:flutter_test/flutter_test.dart';
import 'package:tinyinventoryr6p4/models/collection_stats.dart';
import 'package:tinyinventoryr6p4/models/inventory_item.dart';
import 'package:tinyinventoryr6p4/store/inventory_store.dart';

InventoryItem sample({
  required String id,
  required String name,
  required String category,
  int quantity = 1,
  DateTime? updatedAt,
}) {
  final created = DateTime.utc(2026, 1, 1);
  return InventoryItem(
    id: id,
    name: name,
    emoji: '📦',
    category: category,
    quantity: quantity,
    notes: '',
    createdAt: created,
    updatedAt: updatedAt ?? created,
  );
}

void main() {
  test('stats stay empty until items exist', () {
    final stats = CollectionStats(const []);
    expect(stats.isEmpty, isTrue);
    expect(stats.itemCount, 0);
    expect(stats.totalQuantity, 0);
    expect(stats.copyText, contains('empty'));
  });

  test('stats group quantity by category', () {
    final stats = CollectionStats([
      sample(id: '1', name: 'Camera', category: 'Tools', quantity: 2),
      sample(id: '2', name: 'Wrench', category: 'Tools', quantity: 1),
      sample(
        id: '3',
        name: 'Novel',
        category: 'Books',
        quantity: 4,
        updatedAt: DateTime.utc(2026, 2, 2),
      ),
    ]);

    expect(stats.itemCount, 3);
    expect(stats.totalQuantity, 7);
    expect(stats.categoryCount, 2);
    expect(stats.quantityByCategory['Books'], 4);
    expect(stats.quantityByCategory['Tools'], 3);
    expect(stats.largestStack?.name, 'Novel');
    expect(stats.newest?.name, 'Novel');
  });

  test('store add, update, and delete stay in memory when persistence is off', () async {
    final store = InventoryStore(persist: false);
    await store.load();
    expect(store.items, isEmpty);

    final item = sample(id: '1', name: 'Hammer', category: 'Tools');
    await store.add(item);
    expect(store.items.single.name, 'Hammer');

    await store.update(item.copyWith(name: 'Claw hammer'));
    expect(store.items.single.name, 'Claw hammer');

    await store.delete('1');
    expect(store.items, isEmpty);
  });
}
