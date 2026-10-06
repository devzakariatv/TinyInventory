import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/inventory_item.dart';
import '../store/inventory_store.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_button.dart';

class ItemsPage extends StatelessWidget {
  const ItemsPage({super.key, required this.onAdd, required this.onEdit});

  final VoidCallback onAdd;
  final ValueChanged<InventoryItem> onEdit;

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final items = store.items;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      children: [
        if (items.isEmpty)
          _EmptyCollection(onAdd: onAdd)
        else ...[
          CopyGradientButton(
            key: const Key('copy_collection'),
            text: store.collectionCopyText,
            label: '📋  Copy collection',
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < items.length; i++) ...[
            _RiseIn(
              key: ValueKey(items[i].id),
              child: _ItemCard(
                item: items[i],
                onEdit: () => onEdit(items[i]),
                onDelete: () => _confirmDelete(context, store, items[i]),
              ),
            ),
            if (i != items.length - 1) const SizedBox(height: 12),
          ],
        ],
      ],
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    InventoryStore store,
    InventoryItem item,
  ) async {
    final remove = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remove this piece?'),
          content: Text(
            'Delete ${item.emoji} ${item.name} from your collection. This only affects this device.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Keep'),
            ),
            TextButton(
              key: const Key('confirm_delete'),
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Delete',
                style: TextStyle(color: AppColors.coral, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    );
    if (remove == true) {
      HapticFeedback.mediumImpact();
      await store.delete(item.id);
    }
  }
}

class _EmptyCollection extends StatelessWidget {
  const _EmptyCollection({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('empty_collection'),
      padding: const EdgeInsets.fromLTRB(22, 36, 22, 28),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(28),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        children: [
          const Text('📦', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 12),
          const Text(
            'Your collection is empty',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add a book, a figure, a record, or anything you love. Nothing is stored until you add it.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, height: 1.4, color: AppColors.muted),
          ),
          const SizedBox(height: 18),
          GradientButton(
            key: const Key('empty_add'),
            label: '✨  Add your first piece',
            onPressed: onAdd,
          ),
        ],
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  const _ItemCard({
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  final InventoryItem item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 58,
                height: 58,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.foam,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(item.emoji, style: const TextStyle(fontSize: 30)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _Pill(label: item.category),
                        _Pill(label: '×${item.quantity}'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (item.notes.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              item.notes.trim(),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.muted, height: 1.35),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _QuietButton(
                  key: Key('edit_${item.id}'),
                  label: '✏️  Edit',
                  onPressed: onEdit,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _QuietButton(
                  key: Key('delete_${item.id}'),
                  label: '🗑️  Delete',
                  danger: true,
                  onPressed: onDelete,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          CopyGradientButton(
            key: Key('copy_${item.id}'),
            text: item.copyText,
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.foam,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.ocean,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _QuietButton extends StatelessWidget {
  const _QuietButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.danger = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger ? AppColors.coral : AppColors.ocean;
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withValues(alpha: 0.35)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }
}

class _RiseIn extends StatefulWidget {
  const _RiseIn({super.key, required this.child});

  final Widget child;

  @override
  State<_RiseIn> createState() => _RiseInState();
}

class _RiseInState extends State<_RiseIn> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  )..forward();

  late final Animation<double> _curve = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _curve,
      builder: (context, child) {
        return Opacity(
          opacity: _curve.value,
          child: Transform.translate(
            offset: Offset(0, (1 - _curve.value) * 18),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
