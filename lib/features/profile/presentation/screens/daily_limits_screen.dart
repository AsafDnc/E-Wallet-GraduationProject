import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../providers/profile_providers.dart';

class DailyLimitsScreen extends ConsumerStatefulWidget {
  const DailyLimitsScreen({super.key});

  @override
  ConsumerState<DailyLimitsScreen> createState() => _DailyLimitsScreenState();
}

class _DailyLimitsScreenState extends ConsumerState<DailyLimitsScreen> {
  late final TextEditingController _limitCtrl;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final limits = ref.read(dailyLimitsProvider);
    _limitCtrl = TextEditingController(
      text: limits.limitAmount.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _limitCtrl.dispose();
    super.dispose();
  }

  void _applyLimit() {
    final raw = _limitCtrl.text.replaceAll(RegExp(r'[^\d]'), '');
    final parsed = double.tryParse(raw);
    if (parsed != null && parsed > 0) {
      ref.read(dailyLimitsProvider.notifier).setLimit(parsed);
    }
    setState(() => _isEditing = false);
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Daily limit updated'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final limits = ref.watch(dailyLimitsProvider);

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Daily Transaction Limits',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        children: [
          // ── Enable toggle card ────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  secondary: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: limits.isEnabled
                          ? cs.primary.withValues(alpha: 0.12)
                          : cs.onSurfaceVariant.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 22,
                      color: limits.isEnabled
                          ? cs.primary
                          : cs.onSurfaceVariant,
                    ),
                  ),
                  title: const Text(
                    'Enable Daily Limit',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    limits.isEnabled
                        ? 'You will be alerted when spending exceeds the limit'
                        : 'No daily spending limit is enforced',
                    style: tt.bodySmall?.copyWith(
                      color: limits.isEnabled
                          ? const Color(0xFF27AE60)
                          : cs.onSurfaceVariant,
                    ),
                  ),
                  value: limits.isEnabled,
                  onChanged: (v) {
                    ref.read(dailyLimitsProvider.notifier).setEnabled(v);
                    if (!v) {
                      setState(() => _isEditing = false);
                      FocusScope.of(context).unfocus();
                    }
                  },
                  activeThumbColor: cs.primary,
                ),

                // ── Animated limit input ────────────────────────────────
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOutCubic,
                  child: limits.isEnabled
                      ? _LimitInputSection(
                          cs: cs,
                          tt: tt,
                          limits: limits,
                          controller: _limitCtrl,
                          isEditing: _isEditing,
                          onEditTap: () => setState(() => _isEditing = true),
                          onApply: _applyLimit,
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── Info card ─────────────────────────────────────────────────
          AnimatedOpacity(
            opacity: limits.isEnabled ? 1.0 : 0.4,
            duration: const Duration(milliseconds: 250),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cs.primaryContainer.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: cs.primary.withValues(alpha: 0.15)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded, size: 18, color: cs.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'When your total daily spending approaches or exceeds '
                      'the limit, you will receive an in-app alert before '
                      'confirming a transaction.',
                      style: tt.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Limit input section ──────────────────────────────────────────────────────

class _LimitInputSection extends StatelessWidget {
  const _LimitInputSection({
    required this.cs,
    required this.tt,
    required this.limits,
    required this.controller,
    required this.isEditing,
    required this.onEditTap,
    required this.onApply,
  });

  final ColorScheme cs;
  final TextTheme tt;
  final DailyLimitsState limits;
  final TextEditingController controller;
  final bool isEditing;
  final VoidCallback onEditTap;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Divider(color: cs.outlineVariant, height: 1, indent: 16, endIndent: 16),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Daily Spending Limit',
                style: tt.labelLarge?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),

              // Display or edit mode
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: isEditing
                    ? _EditField(
                        key: const ValueKey('edit'),
                        cs: cs,
                        tt: tt,
                        controller: controller,
                        onApply: onApply,
                      )
                    : _DisplayAmount(
                        key: const ValueKey('display'),
                        cs: cs,
                        tt: tt,
                        limits: limits,
                        onEditTap: onEditTap,
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DisplayAmount extends StatelessWidget {
  const _DisplayAmount({
    super.key,
    required this.cs,
    required this.tt,
    required this.limits,
    required this.onEditTap,
  });

  final ColorScheme cs;
  final TextTheme tt;
  final DailyLimitsState limits;
  final VoidCallback onEditTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: cs.outlineVariant),
            ),
            child: Text(
              limits.limitAmount.formatted,
              style: tt.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: cs.primary,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        FilledButton.tonalIcon(
          onPressed: onEditTap,
          icon: const Icon(Icons.edit_rounded, size: 18),
          label: const Text('Edit'),
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}

class _EditField extends StatelessWidget {
  const _EditField({
    super.key,
    required this.cs,
    required this.tt,
    required this.controller,
    required this.onApply,
  });

  final ColorScheme cs;
  final TextTheme tt;
  final TextEditingController controller;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: tt.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: cs.primary,
              letterSpacing: -0.5,
            ),
            decoration: InputDecoration(
              prefixText: '₺ ',
              prefixStyle: tt.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: cs.onSurfaceVariant,
              ),
              hintText: '0',
              filled: true,
              fillColor: cs.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: cs.primary, width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: cs.outline),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: cs.primary, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        FilledButton.icon(
          onPressed: onApply,
          icon: const Icon(Icons.check_rounded, size: 18),
          label: const Text('Apply'),
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}
