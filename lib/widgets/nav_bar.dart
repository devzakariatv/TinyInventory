import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class AppNavBar extends StatelessWidget {
  const AppNavBar({
    super.key,
    required this.index,
    required this.onChanged,
  });

  final int index;
  final ValueChanged<int> onChanged;

  static const _tabs = [
    (key: 'nav_items', emoji: '🧰', label: 'Items'),
    (key: 'nav_add', emoji: '✨', label: 'Add'),
    (key: 'nav_stats', emoji: '📊', label: 'Statistics'),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
            boxShadow: AppColors.cardShadow,
          ),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Row(
              children: [
                for (var i = 0; i < _tabs.length; i++)
                  Expanded(
                    child: _NavTab(
                      buttonKey: Key(_tabs[i].key),
                      emoji: _tabs[i].emoji,
                      label: _tabs[i].label,
                      selected: index == i,
                      onTap: () => onChanged(i),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  const _NavTab({
    required this.buttonKey,
    required this.emoji,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final Key buttonKey;
  final String emoji;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: GestureDetector(
        key: buttonKey,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            gradient: selected ? AppColors.button : null,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : AppColors.muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
