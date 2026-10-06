import 'package:flutter/material.dart';

import 'models/inventory_item.dart';
import 'pages/add_page.dart';
import 'pages/items_page.dart';
import 'pages/statistics_page.dart';
import 'theme/app_theme.dart';
import 'widgets/nav_bar.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;
  int _formToken = 0;
  InventoryItem? _editing;

  void _selectTab(int index) {
    setState(() {
      if (index == 1 && _index != 1) {
        _editing = null;
        _formToken++;
      }
      _index = index;
    });
  }

  void _edit(InventoryItem item) {
    setState(() {
      _editing = item;
      _formToken++;
      _index = 1;
    });
  }

  void _saved() {
    setState(() {
      _editing = null;
      _formToken++;
      _index = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    final page = switch (_index) {
      1 => AddPage(
          key: ValueKey('add-$_formToken'),
          editing: _editing,
          formToken: _formToken,
          onSaved: _saved,
        ),
      2 => const StatisticsPage(key: ValueKey('stats')),
      _ => ItemsPage(
          key: const ValueKey('items'),
          onAdd: () => _selectTab(1),
          onEdit: _edit,
        ),
    };

    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppColors.background),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _Header(index: _index, editing: _editing),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 280),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) {
                    final slide = Tween<Offset>(
                      begin: const Offset(0, 0.04),
                      end: Offset.zero,
                    ).animate(animation);
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(position: slide, child: child),
                    );
                  },
                  child: page,
                ),
              ),
              if (!keyboardOpen) AppNavBar(index: _index, onChanged: _selectTab),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.index, required this.editing});

  final int index;
  final InventoryItem? editing;

  @override
  Widget build(BuildContext context) {
    final title = switch (index) {
      1 when editing != null => 'Edit',
      1 => 'Add',
      2 => 'Statistics',
      _ => 'Items',
    };
    final subtitle = switch (index) {
      1 when editing != null => 'Update this piece ✏️',
      1 => 'Put something on the shelf ✨',
      2 => 'A snapshot of your shelf 📊',
      _ => 'Everything you keep 🧰',
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        children: [
          const Text('🧰', style: TextStyle(fontSize: 34)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tiny Inventory',
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    letterSpacing: 0.3,
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 240),
                  child: Column(
                    key: ValueKey('$index-${editing?.id ?? 'new'}'),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          height: 1.1,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
