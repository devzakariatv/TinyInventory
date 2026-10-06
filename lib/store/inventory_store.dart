import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/collection_stats.dart';
import '../models/inventory_item.dart';

class InventoryStore extends ChangeNotifier {
  InventoryStore({bool persist = true}) : _persist = persist;

  static const storageKey = 'tiny_inventory_items';

  final bool _persist;
  final List<InventoryItem> _items = [];
  bool _ready = false;

  bool get isReady => _ready;

  List<InventoryItem> get items => List<InventoryItem>.unmodifiable(_items);

  CollectionStats get stats => CollectionStats(_items);

  String get collectionCopyText {
    if (_items.isEmpty) {
      return '🧰 Tiny Inventory Shelf\nYour collection is empty.';
    }
    final buffer = StringBuffer('🧰 Tiny Inventory Shelf\n');
    for (var i = 0; i < _items.length; i++) {
      if (i > 0) buffer.writeln();
      buffer.writeln(_items[i].copyText);
    }
    return buffer.toString().trimRight();
  }

  Future<void> load() async {
    if (_persist) {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(storageKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          _items
            ..clear()
            ..addAll(
              decoded.whereType<Map>().map(
                    (entry) => InventoryItem.fromJson(
                      Map<String, dynamic>.from(entry),
                    ),
                  ),
            );
        }
      }
    }
    _ready = true;
    notifyListeners();
  }

  Future<void> add(InventoryItem item) async {
    _items.insert(0, item);
    await _write();
    notifyListeners();
  }

  Future<void> update(InventoryItem item) async {
    final index = _items.indexWhere((entry) => entry.id == item.id);
    if (index == -1) {
      await add(item);
      return;
    }
    _items.removeAt(index);
    _items.insert(0, item);
    await _write();
    notifyListeners();
  }

  Future<void> delete(String id) async {
    _items.removeWhere((entry) => entry.id == id);
    await _write();
    notifyListeners();
  }

  Future<void> _write() async {
    if (!_persist) return;
    final prefs = await SharedPreferences.getInstance();
    final payload = jsonEncode(_items.map((item) => item.toJson()).toList());
    await prefs.setString(storageKey, payload);
  }
}

class StoreScope extends InheritedNotifier<InventoryStore> {
  const StoreScope({
    required InventoryStore store,
    required super.child,
    super.key,
  }) : super(notifier: store);

  static InventoryStore of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<StoreScope>();
    assert(scope != null, 'StoreScope is missing above this widget');
    return scope!.notifier!;
  }
}
