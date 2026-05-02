import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/currency_formatter.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/budget_providers.dart';

class BudgetScreen extends ConsumerStatefulWidget {
  const BudgetScreen({super.key});

  @override
  ConsumerState<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends ConsumerState<BudgetScreen> {
  late final TextEditingController _limitCtrl;
  bool _editingLimit = false;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(budgetSettingsProvider);
    _limitCtrl = TextEditingController(
      text: settings.monthlyLimit.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _limitCtrl.dispose();
    super.dispose();
  }

  void _applyLimit() {
    final parsed = double.tryParse(_limitCtrl.text.replaceAll(',', '.'));
    if (parsed != null && parsed > 0) {
      ref.read(budgetSettingsProvider.notifier).setLimit(parsed);
    } else {
      // Reset field to current valid value on bad input.
      _limitCtrl.text = ref
          .read(budgetSettingsProvider)
          .monthlyLimit
          .toStringAsFixed(0);
    }
    setState(() => _editingLimit = false);
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final settings = ref.watch(budgetSettingsProvider);
    final spent = ref.watch(currentMonthSpendingProvider);
    final progress = ref.watch(budgetProgressProvider).clamp(0.0, 1.0);

    final progressColor = switch (progress) {
      >= 1.0 => cs.error,
      >= 0.9 => const Color(0xFFFF7043),
      >= 0.75 => const Color(0xFFFFB300),
      _ => cs.primary,
    };

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
        title: Text(
          l10n.budgetScreenTitle,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        children: [
          // ── Limit card ─────────────────────────────────────────────────
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.budgetMonthlyLimit,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    if (!_editingLimit)
                      TextButton.icon(
                        onPressed: () => setState(() => _editingLimit = true),
                        icon: const Icon(Icons.edit_outlined, size: 16),
                        label: Text(l10n.commonEdit),
                        style: TextButton.styleFrom(
                          foregroundColor: cs.primary,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _editingLimit
                      ? Row(
                          key: const ValueKey('edit'),
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _limitCtrl,
                                autofocus: true,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'[\d,.]'),
                                  ),
                                ],
                                decoration: InputDecoration(
                                  prefixText: appCurrencySymbolSpaced,
                                  labelText: l10n.budgetMonthlyLimit,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                onSubmitted: (_) => _applyLimit(),
                              ),
                            ),
                            const SizedBox(width: 10),
                            FilledButton(
                              onPressed: _applyLimit,
                              child: Text(l10n.commonApply),
                            ),
                          ],
                        )
                      : Column(
                          key: const ValueKey('display'),
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              settings.monthlyLimit.formattedCompact,
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: cs.onSurface,
                                  ),
                            ),
                            Text(
                              l10n.budgetPerMonth,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: cs.onSurfaceVariant),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── Progress card ──────────────────────────────────────────────
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.budgetSpendingThisMonth,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),

                // Animated progress bar
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: progress),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOutCubic,
                  builder: (_, value, child) => ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: value,
                      minHeight: 14,
                      backgroundColor: cs.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.budgetSpentFragment(spent.formattedCompact),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: progressColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      l10n.budgetOfLimitFragment(
                        settings.monthlyLimit.formattedCompact,
                      ),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: progress >= 1.0
                      ? Row(
                          key: const ValueKey('over'),
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              size: 15,
                              color: cs.error,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              l10n.budgetOverBy(
                                (spent - settings.monthlyLimit).formatted,
                              ),
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: cs.error,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        )
                      : Text(
                          key: const ValueKey('remaining'),
                          l10n.budgetRemaining(
                            (settings.monthlyLimit - spent).formattedCompact,
                          ),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: cs.onSurfaceVariant),
                        ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── Alert settings card ────────────────────────────────────────
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.budgetAlertSettings,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.budgetAlertsTitle),
                  subtitle: Text(
                    l10n.budgetAlertsSubtitle,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                  value: settings.isAlertEnabled,
                  onChanged: (val) => ref
                      .read(budgetSettingsProvider.notifier)
                      .setAlertEnabled(val),
                  activeThumbColor: cs.primary,
                ),
                AnimatedOpacity(
                  opacity: settings.isAlertEnabled ? 1.0 : 0.38,
                  duration: const Duration(milliseconds: 200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Divider(color: cs.outlineVariant, height: 1),
                      const SizedBox(height: 14),
                      Text(
                        l10n.budgetAlertThreshold,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SegmentedButton<double>(
                        segments: const [
                          ButtonSegment<double>(value: 0.5, label: Text('50%')),
                          ButtonSegment<double>(
                            value: 0.75,
                            label: Text('75%'),
                          ),
                          ButtonSegment<double>(value: 0.9, label: Text('90%')),
                          ButtonSegment<double>(
                            value: 1.0,
                            label: Text('100%'),
                          ),
                        ],
                        selected: {settings.alertThreshold},
                        onSelectionChanged: settings.isAlertEnabled
                            ? (s) => ref
                                  .read(budgetSettingsProvider.notifier)
                                  .setThreshold(s.first)
                            : null,
                        style: const ButtonStyle(
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        l10n.budgetAlertFiresWhen(
                          (settings.alertThreshold * 100).toInt(),
                        ),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
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

// ─── Card wrapper ─────────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }
}
