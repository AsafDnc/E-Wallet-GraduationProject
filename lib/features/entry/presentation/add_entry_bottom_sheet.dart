import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../home/domain/transaction.dart';
import '../../home/providers/home_provider.dart';
import '../../home/providers/transactions_provider.dart';

// ─── Domain ───────────────────────────────────────────────────────────────────

enum _EntryMode { income, expense }

class _Category {
  const _Category({
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
  });

  final String id;
  final String label;
  final IconData icon;
  final Color color;
}

// ─── Category data ────────────────────────────────────────────────────────────

const _kExpense = <_Category>[
  _Category(
    id: 'food',
    label: 'Food',
    icon: Icons.restaurant_rounded,
    color: Color(0xFFE57373),
  ),
  _Category(
    id: 'transport',
    label: 'Transport',
    icon: Icons.directions_car_rounded,
    color: Color(0xFF64B5F6),
  ),
  _Category(
    id: 'shopping',
    label: 'Shopping',
    icon: Icons.shopping_bag_rounded,
    color: Color(0xFFBA68C8),
  ),
  _Category(
    id: 'bills',
    label: 'Bills',
    icon: Icons.receipt_long_rounded,
    color: Color(0xFFFFB74D),
  ),
  _Category(
    id: 'subscription',
    label: 'Subscription',
    icon: Icons.subscriptions_rounded,
    color: Color(0xFF4FC3F7),
  ),
  _Category(
    id: 'entertainment',
    label: 'Entertainment',
    icon: Icons.movie_rounded,
    color: Color(0xFFF06292),
  ),
  _Category(
    id: 'health',
    label: 'Healthcare',
    icon: Icons.local_hospital_rounded,
    color: Color(0xFF81C784),
  ),
  _Category(
    id: 'other_exp',
    label: 'Other',
    icon: Icons.more_horiz_rounded,
    color: Color(0xFF78909C),
  ),
];

const _kIncome = <_Category>[
  _Category(
    id: 'salary',
    label: 'Salary',
    icon: Icons.account_balance_wallet_rounded,
    color: Color(0xFF81C784),
  ),
  _Category(
    id: 'freelance',
    label: 'Freelance',
    icon: Icons.work_rounded,
    color: Color(0xFF4FC3F7),
  ),
  _Category(
    id: 'investment',
    label: 'Investment',
    icon: Icons.trending_up_rounded,
    color: Color(0xFFFFD54F),
  ),
  _Category(
    id: 'gift',
    label: 'Gift',
    icon: Icons.card_giftcard_rounded,
    color: Color(0xFFF06292),
  ),
  _Category(
    id: 'rental',
    label: 'Rental',
    icon: Icons.home_rounded,
    color: Color(0xFFAED581),
  ),
  _Category(
    id: 'other_inc',
    label: 'Other',
    icon: Icons.more_horiz_rounded,
    color: Color(0xFF90A4AE),
  ),
];

// ─── Helper ───────────────────────────────────────────────────────────────────

String _formatDate(DateTime d) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${d.day} ${months[d.month - 1]} ${d.year},';
}

// ─── Main Widget ──────────────────────────────────────────────────────────────

/// Full-height transaction entry sheet.
/// Opened directly by tapping the center (+) button in the bottom nav.
class AddTransactionSheet extends ConsumerStatefulWidget {
  const AddTransactionSheet({super.key});

  @override
  ConsumerState<AddTransactionSheet> createState() =>
      _AddTransactionSheetState();
}

class _AddTransactionSheetState extends ConsumerState<AddTransactionSheet> {
  _EntryMode _mode = _EntryMode.expense;
  String _buffer = '';
  late _Category _category;
  DateTime _date = DateTime.now();
  bool _showAlert = true;

  @override
  void initState() {
    super.initState();
    _category = _kExpense.first;
  }

  List<_Category> get _categories =>
      _mode == _EntryMode.income ? _kIncome : _kExpense;

  double? get _parsedAmount {
    if (_buffer.isEmpty || _buffer == '.') return null;
    return double.tryParse(_buffer);
  }

  String get _amountDisplay {
    if (_buffer.isEmpty) return '\$0';
    if (_buffer == '.') return '\$0.';
    return '\$$_buffer';
  }

  bool get _canSave {
    final v = _parsedAmount;
    return v != null && v > 0;
  }

  void _onModeChanged(_EntryMode m) {
    setState(() {
      _mode = m;
      _category = m == _EntryMode.income ? _kIncome.first : _kExpense.first;
    });
  }

  void _onKey(String k) {
    setState(() {
      if (k == 'del') {
        if (_buffer.isNotEmpty) {
          _buffer = _buffer.substring(0, _buffer.length - 1);
        }
        return;
      }
      if (k == '.') {
        if (_buffer.contains('.')) return;
        if (_buffer.isEmpty) _buffer = '0';
        _buffer += '.';
        return;
      }
      if (k == '0' && _buffer == '0') return;
      if (_buffer == '0') {
        _buffer = k;
        return;
      }
      // Guard: max 2 decimal places
      final dot = _buffer.indexOf('.');
      if (dot != -1 && _buffer.length - dot > 2) return;
      _buffer += k;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && mounted) {
      setState(() => _date = picked);
    }
  }

  Future<void> _pickCategory() async {
    final result = await showModalBottomSheet<_Category>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) =>
          _CategorySheet(categories: _categories, selected: _category),
    );
    if (result != null && mounted) {
      setState(() => _category = result);
    }
  }

  void _save() {
    final amount = _parsedAmount;
    if (amount == null || amount <= 0) return;

    final signed = _mode == _EntryMode.expense ? -amount : amount;

    ref
        .read(transactionsProvider.notifier)
        .addAtTop(
          Transaction(
            id: 'tx_${DateTime.now().microsecondsSinceEpoch}',
            title: _category.label,
            amount: signed,
            iconData: _category.icon.codePoint,
            iconBgColor: _category.color,
          ),
        );
    ref.read(homeProvider.notifier).adjustBalance(signed);

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bottomPad = MediaQuery.viewPaddingOf(context).bottom;

    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + bottomPad),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: cs.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Segmented control
            _SegmentControl(mode: _mode, onChanged: _onModeChanged),
            const SizedBox(height: 14),

            // Budget alert
            if (_showAlert) ...[
              _BudgetAlert(onDismiss: () => setState(() => _showAlert = false)),
              const SizedBox(height: 14),
            ],

            // Amount display
            Text(
              'Amount',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: cs.onSurfaceVariant,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _amountDisplay,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: cs.onSurface,
                fontSize: 52,
                fontWeight: FontWeight.w700,
                height: 1.1,
                letterSpacing: -1.5,
              ),
            ),
            const SizedBox(height: 18),

            // Category + Date row
            Row(
              children: [
                Expanded(
                  child: _InputBox(
                    icon: _category.icon,
                    label: _category.label,
                    onTap: _pickCategory,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _InputBox(
                    icon: Icons.calendar_today_rounded,
                    label: _formatDate(_date),
                    onTap: _pickDate,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Numpad
            _Numpad(onKey: _onKey),
            const SizedBox(height: 14),

            // Add Transaction button
            SizedBox(
              height: 56,
              child: FilledButton(
                onPressed: _canSave ? _save : null,
                style: FilledButton.styleFrom(
                  backgroundColor: cs.primary,
                  foregroundColor: cs.onPrimary,
                  disabledBackgroundColor: cs.primary.withValues(alpha: 0.35),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: const Text(
                  'Add Transaction',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Segment Control ──────────────────────────────────────────────────────────

class _SegmentControl extends StatelessWidget {
  const _SegmentControl({required this.mode, required this.onChanged});

  final _EntryMode mode;
  final ValueChanged<_EntryMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      height: 50,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(28),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final halfW = constraints.maxWidth / 2;

          return Stack(
            fit: StackFit.expand,
            children: [
              // Animated sliding pill
              AnimatedPositioned(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeInOut,
                left: mode == _EntryMode.income ? 0 : halfW,
                top: 0,
                bottom: 0,
                width: halfW,
                child: Container(
                  decoration: BoxDecoration(
                    color: cs.onSurface,
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
              // Tab labels (above the pill)
              Row(
                children: [
                  Expanded(
                    child: _SegTab(
                      label: 'Income',
                      selected: mode == _EntryMode.income,
                      selectedColor: cs.surface,
                      unselectedColor: cs.onSurfaceVariant,
                      onTap: () => onChanged(_EntryMode.income),
                    ),
                  ),
                  Expanded(
                    child: _SegTab(
                      label: 'Expense',
                      selected: mode == _EntryMode.expense,
                      selectedColor: cs.surface,
                      unselectedColor: cs.onSurfaceVariant,
                      onTap: () => onChanged(_EntryMode.expense),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SegTab extends StatelessWidget {
  const _SegTab({
    required this.label,
    required this.selected,
    required this.selectedColor,
    required this.unselectedColor,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color selectedColor;
  final Color unselectedColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 180),
          style: TextStyle(
            fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily,
            color: selected ? selectedColor : unselectedColor,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 15,
          ),
          child: Text(label),
        ),
      ),
    );
  }
}

// ─── Budget Alert Banner ──────────────────────────────────────────────────────

class _BudgetAlert extends StatelessWidget {
  const _BudgetAlert({required this.onDismiss});

  final VoidCallback onDismiss;

  static const _blue = Color(0xFF2196F3);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: Color(0x1A2196F3),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.info_rounded, color: _blue, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Budget Alert',
                  style: TextStyle(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "You've spent 57% of your monthly budget",
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onDismiss,
            child: Icon(
              Icons.close_rounded,
              size: 18,
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Input Box ────────────────────────────────────────────────────────────────

class _InputBox extends StatelessWidget {
  const _InputBox({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: cs.onSurface),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: cs.onSurface,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 20,
              color: cs.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Numpad ───────────────────────────────────────────────────────────────────

class _Numpad extends StatelessWidget {
  const _Numpad({required this.onKey});

  final void Function(String) onKey;

  static const _rows = <List<String>>[
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
    ['.', '0', 'del'],
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _rows.map((row) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            children: row.map((k) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: _NumKey(numKey: k, onTap: () => onKey(k)),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}

class _NumKey extends StatelessWidget {
  const _NumKey({required this.numKey, required this.onTap});

  final String numKey;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDel = numKey == 'del';

    return Material(
      color: cs.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: cs.primary.withValues(alpha: 0.08),
        highlightColor: cs.primary.withValues(alpha: 0.04),
        child: SizedBox(
          height: 60,
          child: Center(
            child: isDel
                ? Icon(Icons.backspace_outlined, color: cs.onSurface, size: 22)
                : Text(
                    numKey,
                    style: TextStyle(
                      color: cs.onSurface,
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

// ─── Category Picker Sheet ────────────────────────────────────────────────────

class _CategorySheet extends StatelessWidget {
  const _CategorySheet({required this.categories, required this.selected});

  final List<_Category> categories;
  final _Category selected;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bottomPad = MediaQuery.viewPaddingOf(context).bottom;

    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.fromLTRB(20, 12, 20, 16 + bottomPad),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: cs.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                'Select Category',
                style: TextStyle(
                  color: cs.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: categories.length,
              separatorBuilder: (context, index) => const SizedBox(height: 2),
              itemBuilder: (ctx, i) {
                final cat = categories[i];
                final isSelected = cat.id == selected.id;

                return Material(
                  color: isSelected
                      ? cs.primaryContainer.withValues(alpha: 0.55)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    onTap: () => Navigator.of(ctx).pop(cat),
                    borderRadius: BorderRadius.circular(14),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 11,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: cat.color.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(cat.icon, color: cat.color, size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              cat.label,
                              style: TextStyle(
                                color: cs.onSurface,
                                fontSize: 15,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check_circle_rounded,
                              color: cs.primary,
                              size: 22,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
