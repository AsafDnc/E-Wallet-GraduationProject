import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Presents the "Add subscription" form (UI only; persistence TODO).
Future<void> showAddSubscriptionSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    useSafeArea: true,
    builder: (ctx) => const _AddSubscriptionSheet(),
  );
}

/// Presents the "Add saving goal" form (UI only; persistence TODO).
Future<void> showAddSavingGoalSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    useSafeArea: true,
    builder: (ctx) => const _AddSavingGoalSheet(),
  );
}

// ─── Add subscription ─────────────────────────────────────────────────────────

enum _BillingCycle { monthly, yearly }

class _AddSubscriptionSheet extends StatefulWidget {
  const _AddSubscriptionSheet();

  @override
  State<_AddSubscriptionSheet> createState() => _AddSubscriptionSheetState();
}

class _AddSubscriptionSheetState extends State<_AddSubscriptionSheet> {
  final _nameCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _renewalDayCtrl = TextEditingController();
  _BillingCycle _cycle = _BillingCycle.monthly;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    _renewalDayCtrl.dispose();
    super.dispose();
  }

  void _confirm() {
    // TODO: persist new subscription (Supabase / Isar).
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: cs.onSurface.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'New Subscription',
                style: TextStyle(
                  color: cs.onSurface,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _nameCtrl,
                textInputAction: TextInputAction.next,
                style: TextStyle(color: cs.onSurface, fontSize: 15),
                decoration: _fieldDecoration(
                  cs,
                  label: 'Subscription name',
                  hint: 'e.g. Netflix Premium',
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                style: TextStyle(color: cs.onSurface, fontSize: 15),
                decoration: _fieldDecoration(
                  cs,
                  label: 'Amount',
                  hint: '0.00',
                  prefixText: r'$ ',
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Billing cycle',
                style: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              SegmentedButton<_BillingCycle>(
                segments: const [
                  ButtonSegment(
                    value: _BillingCycle.monthly,
                    label: Text('Monthly'),
                  ),
                  ButtonSegment(
                    value: _BillingCycle.yearly,
                    label: Text('Yearly'),
                  ),
                ],
                selected: {_cycle},
                onSelectionChanged: (s) {
                  setState(() => _cycle = s.first);
                },
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _renewalDayCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(2),
                ],
                style: TextStyle(color: cs.onSurface, fontSize: 15),
                decoration: _fieldDecoration(
                  cs,
                  label: 'Renewal day',
                  hint: '1–31',
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: _confirm,
                      child: const Text('Confirm'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Add saving goal ──────────────────────────────────────────────────────────

class _AddSavingGoalSheet extends StatefulWidget {
  const _AddSavingGoalSheet();

  @override
  State<_AddSavingGoalSheet> createState() => _AddSavingGoalSheetState();
}

class _AddSavingGoalSheetState extends State<_AddSavingGoalSheet> {
  final _titleCtrl = TextEditingController();
  final _targetCtrl = TextEditingController();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _targetCtrl.dispose();
    super.dispose();
  }

  void _confirm() {
    // TODO: persist new saving goal (Supabase / Isar).
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: cs.onSurface.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'New Saving Goal',
                style: TextStyle(
                  color: cs.onSurface,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _titleCtrl,
                textInputAction: TextInputAction.next,
                style: TextStyle(color: cs.onSurface, fontSize: 15),
                decoration: _fieldDecoration(
                  cs,
                  label: 'Goal title',
                  hint: 'e.g. New Laptop',
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _targetCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                style: TextStyle(color: cs.onSurface, fontSize: 15),
                decoration: _fieldDecoration(
                  cs,
                  label: 'Total target amount',
                  hint: '0.00',
                  prefixText: r'$ ',
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: _confirm,
                      child: const Text('Confirm'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

InputDecoration _fieldDecoration(
  ColorScheme cs, {
  required String label,
  required String hint,
  String? prefixText,
}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    prefixText: prefixText,
    filled: true,
    fillColor: cs.surfaceContainerHighest,
    labelStyle: TextStyle(color: cs.onSurfaceVariant, fontSize: 14),
    hintStyle: TextStyle(color: cs.onSurfaceVariant.withValues(alpha: 0.5)),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );
}
