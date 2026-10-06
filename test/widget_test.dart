import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tinyinventoryr6p4/main.dart';
import 'package:tinyinventoryr6p4/store/inventory_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late InventoryStore store;

  setUp(() {
    store = InventoryStore(persist: false);
  });

  Future<void> tapInView(WidgetTester tester, Finder finder) async {
    final verticalScroll = find.byWidgetPredicate(
      (widget) => widget is Scrollable && widget.axis == Axis.vertical,
    );
    for (var attempt = 0; attempt < 8; attempt++) {
      if (finder.hitTestable().evaluate().isNotEmpty) break;
      await tester.drag(verticalScroll.first, const Offset(0, -220));
      await tester.pumpAndSettle();
    }
    await tester.tap(finder.hitTestable());
    await tester.pump();
  }

  Future<void> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(TinyInventoryApp(store: store));
    await tester.pumpAndSettle();
  }

  testWidgets('starts empty and lets the user add, copy, edit, and delete', (
    tester,
  ) async {
    await pumpApp(tester);

    expect(find.text('Your collection is empty'), findsOneWidget);
    expect(find.byKey(const Key('empty_collection')), findsOneWidget);

    await tester.tap(find.byKey(const Key('nav_add')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('name_field')), 'Film Camera');
    await tapInView(tester, find.byKey(const Key('qty_plus')));
    await tester.enterText(find.byKey(const Key('notes_field')), 'Sea-blue body');
    await tapInView(tester, find.byKey(const Key('save_item')));
    await tester.pumpAndSettle();

    expect(find.text('Film Camera'), findsOneWidget);
    expect(find.text('×2'), findsOneWidget);
    expect(find.text('Sea-blue body'), findsOneWidget);

    final copied = <String?>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          final args = Map<String, dynamic>.from(call.arguments as Map);
          copied.add(args['text'] as String?);
        }
        return null;
      },
    );

    await tester.tap(find.text('📋  Copy'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('✅  Copied'), findsOneWidget);
    expect(copied.single, contains('Film Camera'));
    expect(copied.single, contains('Quantity: 2'));

    await tester.tap(find.text('✏️  Edit'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Save changes'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('name_field')), 'Film Camera 35mm');
    await tapInView(tester, find.byKey(const Key('save_item')));
    await tester.pumpAndSettle();
    expect(find.text('Film Camera 35mm'), findsOneWidget);

    await tester.tap(find.byKey(const Key('nav_stats')));
    await tester.pumpAndSettle();
    expect(find.text('Pieces'), findsOneWidget);
    expect(find.textContaining('Film Camera 35mm'), findsWidgets);
    expect(find.text('📋  Copy summary'), findsOneWidget);

    await tester.tap(find.byKey(const Key('nav_items')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('🗑️  Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm_delete')));
    await tester.pumpAndSettle();

    expect(find.text('Your collection is empty'), findsOneWidget);
    expect(store.items, isEmpty);
  });

  testWidgets('save asks for a name before creating an item', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.byKey(const Key('nav_add')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('name_field')), '   ');
    await tapInView(tester, find.byKey(const Key('save_item')));
    await tester.pump();
    expect(find.byKey(const Key('form_error')), findsOneWidget);
    expect(store.items, isEmpty);
  });
}
