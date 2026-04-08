import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../goals/domain/goal_model.dart';
import '../../goals/providers/goals_provider.dart';
import '../../home/domain/transaction.dart';
import '../../home/providers/home_provider.dart';
import '../../home/providers/transactions_provider.dart';

enum EntrySheetMode { expense, income, goal }

class _CategoryOption {
  const _CategoryOption({
    required this.id,
    required this.label,
    required this.iconData,
    required this.color,
  });

  final String id;
  final String label;
  final int iconData;
  final Color color;
}

/// Manual entry form: segmented mode, amount, chips, numpad, save.
class AddEntryBottomSheet extends ConsumerStatefulWidget {
  const AddEntryBottomSheet({super.key});

  @override
  ConsumerState<AddEntryBottomSheet> createState() =>
      _AddEntryBottomSheetState();
}

class _AddEntryBottomSheetState extends ConsumerState<AddEntryBottomSheet> {
  static final List<_CategoryOption> _expenseCategories = <_CategoryOption>[
    _CategoryOption(
      id: 'food',
      label: 'Food',
      iconData: Icons.restaurant_rounded.codePoint,
      color: const Color(0xFFE57373),
    ),
    _CategoryOption(
      id: 'transport',
      label: 'Transport',
      iconData: Icons.directions_car_rounded.codePoint,
      color: const Color(0xFF64B5F6),
    ),
    _CategoryOption(
      id: 'shopping',
      label: 'Shopping',
      iconData: Icons.shopping_bag_rounded.codePoint,
      color: const Color(0xFFBA68C8),
    ),
    _CategoryOption(
      id: 'bills',
      label: 'Bills',
      iconData: Icons.receipt_long_rounded.codePoint,
      color: const Color(0xFFFFB74D),
    ),
    _CategoryOption(
      id: 'other_exp',
      label: 'Other',
      iconData: Icons.more_horiz_rounded.codePoint,
      color: const Color(0xFF78909C),
    ),
  ];

  static final List<_CategoryOption> _incomeCategories = <_CategoryOption>[
    _CategoryOption(
      id: 'salary',
      label: 'Salary',
      iconData: Icons.account_balance_wallet_rounded.codePoint,
      color: const Color(0xFF81C784),
    ),
    _CategoryOption(
      id: 'freelance',
      label: 'Freelance',
      iconData: Icons.work_rounded.codePoint,
      color: const Color(0xFF4FC3F7),
    ),
    _CategoryOption(
      id: 'investment',
      label: 'Investment',
      iconData: Icons.trending_up_rounded.codePoint,
      color: const Color(0xFFFFD54F),
    ),
    _CategoryOption(
      id: 'other_inc',
      label: 'Other',
      iconData: Icons.more_horiz_rounded.codePoint,
      color: const Color(0xFF90A4AE),
    ),
  ];

  EntrySheetMode _mode = EntrySheetMode.expense;
  String _amountBuffer = '';
  String? _selectedCategoryId;
  String? _selectedGoalId;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = _expenseCategories.first.id;
  }

  double? get _parsedAmount {
    if (_amountBuffer.isEmpty || _amountBuffer == '.') return null;
    return double.tryParse(_amountBuffer);
  }

  String get _amountDisplay {
    if (_amountBuffer.isEmpty) return '\$0';
    if (_amountBuffer == '.') return '\$.';
    return '\$$_amountBuffer';
  }

  bool get _canSave {
    final amount = _parsedAmount;
    if (amount == null || amount <= 0) return false;
    if (_mode == EntrySheetMode.goal) {
      return _selectedGoalId != null;
    }
    return _selectedCategoryId != null;
  }

  void _onKeyTap(String key) {
    setState(() {
      if (key == 'del') {
        if (_amountBuffer.isNotEmpty) {
          _amountBuffer = _amountBuffer.substring(0, _amountBuffer.length - 1);
        }
        return;
      }
      if (key == '.') {
        if (_amountBuffer.contains('.')) return;
        if (_amountBuffer.isEmpty) _amountBuffer = '0';
        _amountBuffer += '.';
        return;
      }
      if (key == '0' && _amountBuffer == '0') {
        return;
      }
      if (_amountBuffer == '0' && key != '.') {
        _amountBuffer = key;
      } else {
        _amountBuffer += key;
      }
    });
  }

  void _onModeChanged(EntrySheetMode mode) {
    setState(() {
      _mode = mode;
      if (mode == EntrySheetMode.expense) {
        _selectedCategoryId = _expenseCategories.first.id;
        _selectedGoalId = null;
      } else if (mode == EntrySheetMode.income) {
        _selectedCategoryId = _incomeCategories.first.id;
        _selectedGoalId = null;
      } else {
        _selectedCategoryId = null;
        final goals = ref.read(goalsProvider).goals;
        _selectedGoalId = goals.isNotEmpty ? goals.first.id : null;
      }
    });
  }

  Future<void> _onSave() async {
    final amount = _parsedAmount;
    if (amount == null || amount <= 0) return;

    if (_mode == EntrySheetMode.goal) {
      final goalId = _selectedGoalId;
      if (goalId == null) return;
      ref.read(goalsProvider.notifier).contributeToGoal(goalId, amount);
      if (mounted) Navigator.of(context).pop();
      return;
    }

    final catId = _selectedCategoryId;
    if (catId == null) return;

    final options = _mode == EntrySheetMode.expense
        ? _expenseCategories
        : _incomeCategories;
    final cat = options.firstWhere((c) => c.id == catId);
    final signed = _mode == EntrySheetMode.expense
        ? -amount.abs()
        : amount.abs();

    final tx = Transaction(
      id: 'tx_${DateTime.now().microsecondsSinceEpoch}',
      title: cat.label,
      amount: signed,
      iconData: cat.iconData,
      iconBgColor: cat.color,
    );

    ref.read(transactionsProvider.notifier).addAtTop(tx);
    ref.read(homeProvider.notifier).adjustBalance(signed);

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final goals = ref.watch(goalsProvider).goals;
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF12151C),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.fromLTRB(20, 16, 20, 16 + bottomInset),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _SegmentedModeBar(mode: _mode, onChanged: _onModeChanged),
              const SizedBox(height: 24),
              Text(
                _amountDisplay,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 52,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
              const SizedBox(height: 20),
              if (_mode == EntrySheetMode.goal)
                _GoalChips(
                  goals: goals,
                  selectedId: _selectedGoalId,
                  onSelect: (id) => setState(() => _selectedGoalId = id),
                )
              else
                _CategoryChips(
                  options: _mode == EntrySheetMode.expense
                      ? _expenseCategories
                      : _incomeCategories,
                  selectedId: _selectedCategoryId,
                  onSelect: (id) => setState(() => _selectedCategoryId = id),
                ),
              const SizedBox(height: 20),
              _Numpad(onKeyTap: _onKeyTap),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _canSave ? _onSave : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    disabledBackgroundColor: Colors.white24,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Save Entry',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SegmentedModeBar extends StatelessWidget {
  const _SegmentedModeBar({required this.mode, required this.onChanged});

  final EntrySheetMode mode;
  final ValueChanged<EntrySheetMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF1E222A),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _SegChip(
            label: 'Expense',
            selected: mode == EntrySheetMode.expense,
            onTap: () => onChanged(EntrySheetMode.expense),
          ),
          _SegChip(
            label: 'Income',
            selected: mode == EntrySheetMode.income,
            onTap: () => onChanged(EntrySheetMode.income),
          ),
          _SegChip(
            label: 'Goal',
            selected: mode == EntrySheetMode.goal,
            onTap: () => onChanged(EntrySheetMode.goal),
          ),
        ],
      ),
    );
  }
}

class _SegChip extends StatelessWidget {
  const _SegChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: selected ? Colors.white.withValues(alpha: 0.12) : null,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : Colors.white54,
                fontSize: 14,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  const _CategoryChips({
    required this.options,
    required this.selectedId,
    required this.onSelect,
  });

  final List<_CategoryOption> options;
  final String? selectedId;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: options.map((c) {
        final sel = c.id == selectedId;
        return FilterChip(
          label: Text(c.label),
          selected: sel,
          onSelected: (_) => onSelect(c.id),
          showCheckmark: false,
          selectedColor: Colors.white.withValues(alpha: 0.2),
          backgroundColor: const Color(0xFF1E222A),
          labelStyle: TextStyle(
            color: sel ? Colors.white : Colors.white70,
            fontWeight: sel ? FontWeight.w600 : FontWeight.w500,
          ),
          side: BorderSide(color: sel ? Colors.white54 : Colors.white24),
        );
      }).toList(),
    );
  }
}

class _GoalChips extends StatelessWidget {
  const _GoalChips({
    required this.goals,
    required this.selectedId,
    required this.onSelect,
  });

  final List<GoalModel> goals;
  final String? selectedId;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    if (goals.isEmpty) {
      return const Text(
        'No goals yet. Create a goal first.',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white54, fontSize: 14),
      );
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: goals.map<Widget>((GoalModel g) {
        final id = g.id;
        final title = g.title;
        final sel = id == selectedId;
        return FilterChip(
          label: Text(title),
          selected: sel,
          onSelected: (_) => onSelect(id),
          showCheckmark: false,
          selectedColor: Colors.white.withValues(alpha: 0.2),
          backgroundColor: const Color(0xFF1E222A),
          labelStyle: TextStyle(
            color: sel ? Colors.white : Colors.white70,
            fontWeight: sel ? FontWeight.w600 : FontWeight.w500,
          ),
          side: BorderSide(color: sel ? Colors.white54 : Colors.white24),
        );
      }).toList(),
    );
  }
}

class _Numpad extends StatelessWidget {
  const _Numpad({required this.onKeyTap});

  final void Function(String key) onKeyTap;

  @override
  Widget build(BuildContext context) {
    const keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['.', '0', 'del'],
    ];
    return Column(
      children: keys.map((row) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: row.map((k) {
              return _NumKey(
                label: k == 'del' ? '⌫' : k,
                onTap: () => onKeyTap(k),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}

class _NumKey extends StatelessWidget {
  const _NumKey({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      height: 52,
      child: Material(
        color: const Color(0xFF1E222A),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
