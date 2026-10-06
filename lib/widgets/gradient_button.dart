import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';

class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final child = DecoratedBox(
      decoration: BoxDecoration(
        gradient: onPressed == null ? null : AppColors.button,
        color: onPressed == null ? AppColors.muted.withValues(alpha: 0.35) : null,
        borderRadius: BorderRadius.circular(16),
        boxShadow: onPressed == null
            ? null
            : [
                BoxShadow(
                  color: AppColors.ocean.withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 15,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ),
      ),
    );

    if (!expand) return child;
    return SizedBox(width: double.infinity, child: child);
  }
}

class CopyGradientButton extends StatefulWidget {
  const CopyGradientButton({
    super.key,
    required this.text,
    this.label = '📋  Copy',
    this.expand = true,
  });

  final String text;
  final String label;
  final bool expand;

  @override
  State<CopyGradientButton> createState() => _CopyGradientButtonState();
}

class _CopyGradientButtonState extends State<CopyGradientButton> {
  bool _copied = false;

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.text));
    HapticFeedback.lightImpact();
    if (!mounted) return;
    setState(() => _copied = true);
    await Future<void>.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;
    setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    return GradientButton(
      label: _copied ? '✅  Copied' : widget.label,
      expand: widget.expand,
      onPressed: _copy,
    );
  }
}
