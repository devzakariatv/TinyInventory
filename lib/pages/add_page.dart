import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/inventory_item.dart';
import '../store/inventory_store.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_button.dart';

class AddPage extends StatefulWidget {
  const AddPage({
    super.key,
    required this.editing,
    required this.formToken,
    required this.onSaved,
  });

  final InventoryItem? editing;
  final int formToken;
  final VoidCallback onSaved;

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  static const _emojis = [
    '📦',
    '🎁',
    '📚',
    '🎮',
    '🎵',
    '🎨',
    '🧸',
    '💎',
    '📷',
    '🪴',
    '👟',
    '🪙',
    '🏆',
    '🚗',
    '🎸',
    '⌚',
    '🧩',
    '🍀',
    '⭐',
    '🕯️',
  ];

  static const _categories = [
    'Collectibles',
    'Books',
    'Games',
    'Music',
    'Art',
    'Fashion',
    'Tools',
    'Nature',
  ];

  final _name = TextEditingController();
  final _category = TextEditingController();
  final _notes = TextEditingController();
  String _emoji = '📦';
  int _quantity = 1;
  String? _error;

  @override
  void initState() {
    super.initState();
    _apply(widget.editing);
  }

  @override
  void didUpdateWidget(AddPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.formToken != oldWidget.formToken) {
      _apply(widget.editing);
    }
  }

  void _apply(InventoryItem? item) {
    _emoji = item?.emoji ?? '📦';
    _quantity = item?.quantity ?? 1;
    _name.text = item?.name ?? '';
    _category.text = item?.category ?? 'Collectibles';
    _notes.text = item?.notes ?? '';
    _error = null;
  }

  @override
  void dispose() {
    _name.dispose();
    _category.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    final category = _category.text.trim();
    if (name.isEmpty || category.isEmpty) {
      setState(() {
        _error = name.isEmpty
            ? 'Give this piece a name.'
            : 'Choose a category.';
      });
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    final store = StoreScope.of(context);
    final now = DateTime.now();
    final existing = widget.editing;
    final item = InventoryItem(
      id: existing?.id ?? now.microsecondsSinceEpoch.toString(),
      name: name,
      emoji: _emoji,
      category: category,
      quantity: _quantity,
      notes: _notes.text.trim(),
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );

    if (existing == null) {
      await store.add(item);
    } else {
      await store.update(item);
    }
    HapticFeedback.lightImpact();
    widget.onSaved();
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.editing;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(28),
            boxShadow: AppColors.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                editing == null ? '✨ New piece' : '✏️ Editing ${editing.emoji}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                editing == null
                    ? 'Start from an empty shelf and add only what you own.'
                    : 'Update ${editing.name} and save it back to your shelf.',
                style: const TextStyle(color: AppColors.muted, height: 1.35),
              ),
              const SizedBox(height: 16),
              const Text(
                'Emoji',
                style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.ink),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 58,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _emojis.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final emoji = _emojis[index];
                    final selected = emoji == _emoji;
                    return GestureDetector(
                      onTap: () => setState(() => _emoji = emoji),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        width: 52,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: selected ? AppColors.button : null,
                          color: selected ? null : AppColors.foam,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: selected
                              ? [
                                  BoxShadow(
                                    color: AppColors.ocean.withValues(alpha: 0.28),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : null,
                        ),
                        child: Text(emoji, style: const TextStyle(fontSize: 26)),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              _Field(
                fieldKey: const Key('name_field'),
                controller: _name,
                label: 'Name',
                hint: 'Vintage camera',
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 14),
              const Text(
                'Category',
                style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.ink),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final category in _categories)
                    ChoiceChip(
                      label: Text(category),
                      selected: _category.text == category,
                      selectedColor: AppColors.sky,
                      labelStyle: TextStyle(
                        color: _category.text == category
                            ? Colors.white
                            : AppColors.ink,
                        fontWeight: FontWeight.w700,
                      ),
                      backgroundColor: AppColors.foam,
                      side: BorderSide.none,
                      onSelected: (_) => setState(() => _category.text = category),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              _Field(
                fieldKey: const Key('category_field'),
                controller: _category,
                label: 'Or type your own',
                hint: 'Vinyl, stamps, cards…',
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 14),
              const Text(
                'Quantity',
                style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.ink),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _StepButton(
                    buttonKey: const Key('qty_minus'),
                    label: '−',
                    onPressed: _quantity > 1
                        ? () => setState(() => _quantity -= 1)
                        : null,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Text(
                      '$_quantity',
                      key: const Key('quantity_value'),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                  _StepButton(
                    buttonKey: const Key('qty_plus'),
                    label: '+',
                    onPressed: _quantity < 9999
                        ? () => setState(() => _quantity += 1)
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _Field(
                fieldKey: const Key('notes_field'),
                controller: _notes,
                label: 'Notes',
                hint: 'Where you found it, condition, a memory…',
                maxLines: 3,
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  key: const Key('form_error'),
                  style: const TextStyle(
                    color: AppColors.coral,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              GradientButton(
                key: const Key('save_item'),
                label: editing == null ? '✨  Save to collection' : '✅  Save changes',
                onPressed: _save,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    this.fieldKey,
    required this.controller,
    required this.label,
    required this.hint,
    this.maxLines = 1,
    this.textInputAction,
    this.onChanged,
  });

  final Key? fieldKey;
  final TextEditingController controller;
  final String label;
  final String hint;
  final int maxLines;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      key: fieldKey,
      controller: controller,
      maxLines: maxLines,
      textInputAction: textInputAction,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: AppColors.foam,
        labelStyle: const TextStyle(color: AppColors.muted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    this.buttonKey,
    required this.label,
    required this.onPressed,
  });

  final Key? buttonKey;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.foam,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        key: buttonKey,
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: 48,
          height: 48,
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: onPressed == null ? AppColors.muted : AppColors.ocean,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
