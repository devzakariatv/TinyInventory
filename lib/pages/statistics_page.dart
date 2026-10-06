import 'package:flutter/material.dart';

import '../store/inventory_store.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_button.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final stats = StoreScope.of(context).stats;
    if (stats.isEmpty) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        children: const [
          _EmptyStats(),
        ],
      );
    }

    final categories = stats.quantityByCategory.entries.toList();
    final maxQuantity = categories.fold<int>(
      1,
      (max, entry) => entry.value > max ? entry.value : max,
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      children: [
        CopyGradientButton(
          key: const Key('copy_stats'),
          text: stats.copyText,
          label: '📋  Copy summary',
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                emoji: '📦',
                label: 'Pieces',
                value: stats.itemCount,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                emoji: '🔢',
                label: 'Quantity',
                value: stats.totalQuantity,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _StatCard(
          emoji: '🏷️',
          label: 'Categories',
          value: stats.categoryCount,
        ),
        const SizedBox(height: 12),
        _HighlightCard(
          title: 'Largest stack',
          emoji: stats.largestStack!.emoji,
          body: '${stats.largestStack!.name} · ×${stats.largestStack!.quantity}',
        ),
        const SizedBox(height: 12),
        _HighlightCard(
          title: 'Most recently updated',
          emoji: stats.newest!.emoji,
          body: stats.newest!.name,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(24),
            boxShadow: AppColors.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '📊  By category',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 14),
              for (final entry in categories) ...[
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        entry.key,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                    Text(
                      '${entry.value}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.ocean,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: entry.value / maxQuantity),
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) {
                      return LinearProgressIndicator(
                        value: value,
                        minHeight: 10,
                        backgroundColor: AppColors.foam,
                        color: AppColors.sky,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _EmptyStats extends StatelessWidget {
  const _EmptyStats();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('empty_stats'),
      padding: const EdgeInsets.fromLTRB(22, 36, 22, 28),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(28),
        boxShadow: AppColors.cardShadow,
      ),
      child: const Column(
        children: [
          Text('📊', style: TextStyle(fontSize: 56)),
          SizedBox(height: 12),
          Text(
            'Nothing to count yet',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Statistics appear after you add the first piece. Your shelf starts empty.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, height: 1.4, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.emoji,
    required this.label,
    required this.value,
  });

  final String emoji;
  final String label;
  final int value;

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
          Text(emoji, style: const TextStyle(fontSize: 26)),
          const SizedBox(height: 8),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: value.toDouble()),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
            builder: (context, animated, _) {
              return Text(
                '${animated.round()}',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              );
            },
          ),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.muted,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _HighlightCard extends StatelessWidget {
  const _HighlightCard({
    required this.title,
    required this.emoji,
    required this.body,
  });

  final String title;
  final String emoji;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.foam,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(emoji, style: const TextStyle(fontSize: 26)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  body,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
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
