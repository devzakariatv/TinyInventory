import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_shell.dart';
import 'store/inventory_store.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  final store = InventoryStore();
  await store.load();
  runApp(TinyInventoryApp(store: store));
}

class TinyInventoryApp extends StatelessWidget {
  const TinyInventoryApp({super.key, required this.store});

  final InventoryStore store;

  @override
  Widget build(BuildContext context) {
    return StoreScope(
      store: store,
      child: MaterialApp(
        title: 'Tiny Inventory',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const AppShell(),
      ),
    );
  }
}
