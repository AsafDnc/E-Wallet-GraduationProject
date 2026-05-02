import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/currency_formatter.dart';
import '../../budget/providers/budget_providers.dart';
import '../../categories/domain/category_model.dart';
import '../../categories/providers/category_provider.dart';
import '../../home/domain/transaction.dart';
import '../../home/providers/transactions_provider.dart';
import '../../wallets/domain/models/wallet_entry_model.dart';
import '../../wallets/presentation/providers/wallet_providers.dart';

// ─── Entry mode ───────────────────────────────────────────────────────────────

enum _EntryMode { income, transfer, expense }

extension _EntryModeX on _EntryMode {
  String get label {
    switch (this) {
      case _EntryMode.income:
        return 'Income';
      case _EntryMode.transfer:
        return 'Transfer';
      case _EntryMode.expense:
        return 'Expense';
    }
  }

  Color pillColor(ColorScheme cs) {
    switch (this) {
      case _EntryMode.income:
        return const Color(0xFF27AE60);
      case _EntryMode.transfer:
        return cs.primary;
      case _EntryMode.expense:
        return cs.error;
    }
  }
}

// Category type alias — using the shared domain model throughout this file.

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
///
/// Opened directly by tapping the center (+) button in the bottom nav.
/// Pass [initialTransfer] to jump straight to the Transfer segment.
/// Pass [initialFromWalletId] to pre-select the "From" wallet.
/// Pass [initialWalletId] to pre-select the main wallet (Income / Expense).
class AddTransactionSheet extends ConsumerStatefulWidget {
  const AddTransactionSheet({
    super.key,
    this.initialTransfer = false,
    this.initialFromWalletId,
    this.initialWalletId,
  });

  final bool initialTransfer;
  final String? initialFromWalletId;

  /// When not in transfer mode, pre-selects this wallet if it exists in
  /// [walletsProvider]. Ignored when [initialTransfer] is true.
  final String? initialWalletId;

  @override
  ConsumerState<AddTransactionSheet> createState() =>
      _AddTransactionSheetState();
}

class _AddTransactionSheetState extends ConsumerState<AddTransactionSheet> {
  _EntryMode _mode = _EntryMode.expense;
  String _buffer = '';
  Category? _category;
  DateTime _date = DateTime.now();
  final _noteCtrl = TextEditingController();
  String? _selectedWalletId;
  String? _selectedToWalletId;

  @override
  void initState() {
    super.initState();
    if (widget.initialTransfer) _mode = _EntryMode.transfer;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final wallets = ref.read(walletsProvider);
      final categories = ref.read(categoryProvider);
      if (!mounted) return;
      setState(() {
        if (wallets.isEmpty) {
          _selectedWalletId = null;
        } else {
          final String defaultWalletId = wallets
              .firstWhere((w) => w.isDefault, orElse: () => wallets.first)
              .id;

          if (widget.initialTransfer) {
            _selectedWalletId = widget.initialFromWalletId ?? defaultWalletId;
          } else if (widget.initialWalletId != null &&
              wallets.any((w) => w.id == widget.initialWalletId)) {
            _selectedWalletId = widget.initialWalletId;
          } else {
            _selectedWalletId = defaultWalletId;
          }
        }
        if (!widget.initialTransfer) {
          final expenseCats = categories
              .where((c) => c.type == CategoryType.expense)
              .toList();
          if (expenseCats.isNotEmpty) _category = expenseCats.first;
        }
      });
    });
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  List<Category> _currentCategories() {
    final all = ref.read(categoryProvider);
    return _mode == _EntryMode.income
        ? all.where((c) => c.type == CategoryType.income).toList()
        : all.where((c) => c.type == CategoryType.expense).toList();
  }

  String? _effectivePrimaryWalletId(List<WalletEntry> wallets) {
    if (wallets.isEmpty) return null;
    if (_selectedWalletId != null &&
        wallets.any((w) => w.id == _selectedWalletId)) {
      return _selectedWalletId;
    }
    return wallets
        .firstWhere((w) => w.isDefault, orElse: () => wallets.first)
        .id;
  }

  String? _resolvedDestinationWalletId(List<WalletEntry> wallets) {
    final id = _selectedToWalletId;
    if (id == null || !wallets.any((w) => w.id == id)) return null;
    return id;
  }

  double? get _parsedAmount {
    if (_buffer.isEmpty || _buffer == '.') return null;
    return double.tryParse(_buffer);
  }

  String get _amountDisplay {
    if (_buffer.isEmpty) return '₺0';
    if (_buffer == '.') return '₺0.';
    return '₺$_buffer';
  }

  bool get _canSave {
    final v = _parsedAmount;
    if (v == null || v <= 0) return false;
    final wallets = ref.read(walletsProvider);
    if (_mode == _EntryMode.transfer) {
      return _selectedWalletId != null &&
          _selectedToWalletId != null &&
          _selectedWalletId != _selectedToWalletId;
    }
    if (wallets.isEmpty) return false;
    return _effectivePrimaryWalletId(wallets) != null;
  }

  String get _buttonLabel =>
      _mode == _EntryMode.transfer ? 'Add Transfer' : 'Add Transaction';

  void _onModeChanged(_EntryMode m) {
    final all = ref.read(categoryProvider);
    setState(() {
      _mode = m;
      if (m == _EntryMode.income) {
        final inc = all.where((c) => c.type == CategoryType.income).toList();
        _category = inc.isNotEmpty ? inc.first : null;
      } else if (m == _EntryMode.expense) {
        final exp = all.where((c) => c.type == CategoryType.expense).toList();
        _category = exp.isNotEmpty ? exp.first : null;
      }
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
    final cats = _currentCategories();
    final result = await showModalBottomSheet<Category>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _CategorySheet(categories: cats, selected: _category),
    );
    if (result != null && mounted) setState(() => _category = result);
  }

  Future<void> _pickWallet({bool isDestination = false}) async {
    final wallets = ref.read(walletsProvider);
    final currentId = isDestination ? _selectedToWalletId : _selectedWalletId;

    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _WalletPickerSheet(
        wallets: wallets,
        selectedId: currentId,
        excludeId: isDestination ? _selectedWalletId : null,
        title: isDestination ? 'To Wallet' : 'From Wallet',
      ),
    );
    if (result != null && mounted) {
      setState(() {
        if (isDestination) {
          _selectedToWalletId = result;
        } else {
          _selectedWalletId = result;
        }
      });
    }
  }

  Future<void> _save() async {
    final amount = _parsedAmount;
    if (amount == null || amount <= 0) return;

    final wallets = ref.read(walletsProvider);

    if (_mode == _EntryMode.transfer) {
      if (_selectedWalletId != null && _selectedToWalletId != null) {
        final fromId = _effectivePrimaryWalletId(wallets);
        final toId = _resolvedDestinationWalletId(wallets);
        if (fromId == null || toId == null || fromId == toId) return;

        final dstName = wallets
            .firstWhere((w) => w.id == toId, orElse: () => wallets.first)
            .name;
        HapticFeedback.mediumImpact();
        try {
          await ref
              .read(transactionsProvider.notifier)
              .recordNewTransaction(
                Transaction(
                  id: 'tx_${DateTime.now().microsecondsSinceEpoch}',
                  title: 'Transfer to $dstName',
                  amount: -amount,
                  iconData: Icons.swap_horiz_rounded.codePoint,
                  iconBgColor: Theme.of(context).colorScheme.primary,
                  createdAt: _date,
                  walletId: fromId,
                  transferToWalletId: toId,
                ),
              );
        } catch (e, st) {
          assert(() {
            debugPrint('AddTransactionSheet: transfer save failed: $e\n$st');
            return true;
          }());
          return;
        }
      } else {
        if (_selectedWalletId != null) {
          final src = wallets.firstWhere(
            (w) => w.id == _selectedWalletId,
            orElse: () => wallets.first,
          );
          ref
              .read(walletsProvider.notifier)
              .adjustBalance(_selectedWalletId!, src.balance - amount);
        }
        if (_selectedToWalletId != null) {
          final dst = wallets.firstWhere(
            (w) => w.id == _selectedToWalletId,
            orElse: () => wallets.first,
          );
          ref
              .read(walletsProvider.notifier)
              .adjustBalance(_selectedToWalletId!, dst.balance + amount);
        }
      }
    } else {
      final walletId = _effectivePrimaryWalletId(wallets);
      if (walletId == null) return;

      final signed = _mode == _EntryMode.expense ? -amount : amount;

      HapticFeedback.mediumImpact();
      try {
        await ref
            .read(transactionsProvider.notifier)
            .recordNewTransaction(
              Transaction(
                id: 'tx_${DateTime.now().microsecondsSinceEpoch}',
                title: _noteCtrl.text.trim().isNotEmpty
                    ? _noteCtrl.text.trim()
                    : (_category?.name ?? 'Transaction'),
                amount: signed,
                iconData:
                    _category?.displayIcon.codePoint ??
                    Icons.payment_rounded.codePoint,
                iconBgColor: _category?.displayColor ?? const Color(0xFF78909C),
                createdAt: _date,
                walletId: walletId,
              ),
            );
      } catch (e, st) {
        assert(() {
          debugPrint('AddTransactionSheet: transaction save failed: $e\n$st');
          return true;
        }());
        return;
      }
    }

    if (mounted) Navigator.of(context).pop();
  }

  // ─── Wallet label helpers ──────────────────────────────────────────────────

  String _walletLabel(String? id, List<WalletEntry> wallets) {
    if (id == null || wallets.isEmpty) return 'Select Wallet';
    final found = wallets.where((w) => w.id == id);
    return found.isNotEmpty ? found.first.name : 'Select Wallet';
  }

  IconData _walletIcon(String? id, List<WalletEntry> wallets) {
    if (id == null || wallets.isEmpty) {
      return Icons.account_balance_wallet_outlined;
    }
    final found = wallets.where((w) => w.id == id);
    return found.isNotEmpty
        ? found.first.type.icon
        : Icons.account_balance_wallet_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bottomPad = MediaQuery.viewPaddingOf(context).bottom;
    final wallets = ref.watch(walletsProvider);
    final modeColor = _mode.pillColor(cs);

    final parsedAmount = _parsedAmount ?? 0;
    final showBudgetAlert =
        _mode == _EntryMode.expense &&
        ref.watch(budgetAlertForAmountProvider(parsedAmount));
    final budgetSettings = ref.watch(budgetSettingsProvider);

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
            // ── Drag handle ───────────────────────────────────────────────
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

            // ── 3-way segment control ─────────────────────────────────────
            _SegmentControl(mode: _mode, onChanged: _onModeChanged),
            const SizedBox(height: 14),

            // ── Budget alert (dynamic) ────────────────────────────────────
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, animation) => SizeTransition(
                sizeFactor: animation,
                child: FadeTransition(opacity: animation, child: child),
              ),
              child: showBudgetAlert
                  ? Padding(
                      key: const ValueKey('budget_alert'),
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _BudgetAlertBanner(
                        thresholdPercent: (budgetSettings.alertThreshold * 100)
                            .toInt(),
                      ),
                    )
                  : const SizedBox.shrink(key: ValueKey('no_alert')),
            ),

            // ── Amount display ────────────────────────────────────────────
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
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 220),
              style: TextStyle(
                color: _buffer.isEmpty
                    ? cs.onSurfaceVariant.withValues(alpha: 0.4)
                    : modeColor,
                fontSize: 52,
                fontWeight: FontWeight.w700,
                height: 1.1,
                letterSpacing: -1.5,
                fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily,
              ),
              child: Text(_amountDisplay, textAlign: TextAlign.center),
            ),
            const SizedBox(height: 12),

            // ── Note input ────────────────────────────────────────────────
            TextField(
              controller: _noteCtrl,
              style: TextStyle(color: cs.onSurface, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Add a note (optional)',
                hintStyle: TextStyle(color: cs.onSurfaceVariant, fontSize: 14),
                prefixIcon: Icon(
                  Icons.edit_note_rounded,
                  color: cs.onSurfaceVariant,
                  size: 20,
                ),
                filled: true,
                fillColor: cs.surfaceContainerHighest,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: modeColor, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ── Transfer mode: From / To wallet row ────────────────────────
            if (_mode == _EntryMode.transfer) ...[
              Row(
                children: [
                  Expanded(
                    child: _InputBox(
                      icon: _walletIcon(_selectedWalletId, wallets),
                      label: _walletLabel(_selectedWalletId, wallets),
                      subLabel: 'From',
                      onTap: () => _pickWallet(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: cs.onSurfaceVariant,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _InputBox(
                      icon: _walletIcon(_selectedToWalletId, wallets),
                      label: _walletLabel(_selectedToWalletId, wallets),
                      subLabel: 'To',
                      onTap: () => _pickWallet(isDestination: true),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _InputBox(
                icon: Icons.calendar_today_rounded,
                label: _formatDate(_date),
                onTap: _pickDate,
              ),
              const SizedBox(height: 14),
            ] else ...[
              // ── Category  |  Wallet  |  Date ─────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: _InputBox(
                      icon: _category?.displayIcon ?? Icons.category_rounded,
                      label: _category?.name ?? 'Category',
                      onTap: _pickCategory,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _InputBox(
                      icon: _walletIcon(_selectedWalletId, wallets),
                      label: _walletLabel(_selectedWalletId, wallets),
                      onTap: () => _pickWallet(),
                    ),
                  ),
                  const SizedBox(width: 10),
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
            ],

            // ── Numpad ────────────────────────────────────────────────────
            _Numpad(onKey: _onKey),
            const SizedBox(height: 14),

            // ── Dynamic action button ─────────────────────────────────────
            SizedBox(
              height: 56,
              child: FilledButton(
                onPressed: _canSave ? () => _save() : null,
                style: FilledButton.styleFrom(
                  backgroundColor: modeColor,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: modeColor.withValues(alpha: 0.35),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    _buttonLabel,
                    key: ValueKey(_buttonLabel),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── 3-Way Segment Control ────────────────────────────────────────────────────

class _SegmentControl extends StatelessWidget {
  const _SegmentControl({required this.mode, required this.onChanged});

  final _EntryMode mode;
  final ValueChanged<_EntryMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final modes = _EntryMode.values;

    return Container(
      height: 50,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(28),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final segW = constraints.maxWidth / modes.length;

          return Stack(
            fit: StackFit.expand,
            children: [
              // Animated sliding pill.
              AnimatedPositioned(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeInOut,
                left: segW * modes.indexOf(mode),
                top: 0,
                bottom: 0,
                width: segW,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  decoration: BoxDecoration(
                    color: mode.pillColor(cs),
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
              // Labels on top of the pill.
              Row(
                children: modes
                    .map(
                      (m) => Expanded(
                        child: _SegTab(
                          label: m.label,
                          selected: m == mode,
                          selectedColor: Colors.white,
                          unselectedColor: cs.onSurfaceVariant,
                          onTap: () => onChanged(m),
                        ),
                      ),
                    )
                    .toList(),
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
            fontSize: 14,
          ),
          child: Text(label),
        ),
      ),
    );
  }
}

// ─── Budget Alert Banner ──────────────────────────────────────────────────────

class _BudgetAlertBanner extends StatelessWidget {
  const _BudgetAlertBanner({required this.thresholdPercent});

  final int thresholdPercent;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: cs.errorContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.error.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: cs.error.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.warning_amber_rounded, color: cs.error, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '⚠️ Budget Alert',
                  style: TextStyle(
                    color: cs.onErrorContainer,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'This exceeds your $thresholdPercent% budget limit!',
                  style: TextStyle(
                    color: cs.onErrorContainer.withValues(alpha: 0.8),
                    fontSize: 12,
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

// ─── Input Box ────────────────────────────────────────────────────────────────

class _InputBox extends StatelessWidget {
  const _InputBox({
    required this.icon,
    required this.label,
    required this.onTap,
    this.subLabel,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final String? subLabel;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (subLabel != null) ...[
              Text(
                subLabel!,
                style: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 3),
            ],
            Row(
              children: [
                Icon(icon, size: 15, color: cs.onSurface),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: cs.onSurface,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 16,
                  color: cs.onSurfaceVariant,
                ),
              ],
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

  final List<Category> categories;
  final Category? selected;

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
              separatorBuilder: (_, _) => const SizedBox(height: 2),
              itemBuilder: (ctx, i) {
                final cat = categories[i];
                final isSelected = cat.id == selected?.id;

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
                              color: cat.displayColor.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              cat.displayIcon,
                              color: cat.displayColor,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              cat.name,
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

// ─── Wallet Picker Sheet ──────────────────────────────────────────────────────

class _WalletPickerSheet extends StatelessWidget {
  const _WalletPickerSheet({
    required this.wallets,
    required this.selectedId,
    required this.title,
    this.excludeId,
  });

  final List<WalletEntry> wallets;
  final String? selectedId;
  final String? excludeId;
  final String title;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bottomPad = MediaQuery.viewPaddingOf(context).bottom;

    final displayWallets = wallets.where((w) => w.id != excludeId).toList();

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
                title,
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
              itemCount: displayWallets.length,
              separatorBuilder: (context, index) => const SizedBox(height: 2),
              itemBuilder: (ctx, i) {
                final wallet = displayWallets[i];
                final isSelected = wallet.id == selectedId;

                return Material(
                  color: isSelected
                      ? cs.primaryContainer.withValues(alpha: 0.55)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    onTap: () => Navigator.of(ctx).pop(wallet.id),
                    borderRadius: BorderRadius.circular(14),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: wallet.displayColor.withValues(
                                alpha: 0.15,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              wallet.type.icon,
                              color: wallet.displayColor,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  wallet.name,
                                  style: TextStyle(
                                    color: cs.onSurface,
                                    fontSize: 15,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  wallet.balance.formatted,
                                  style: TextStyle(
                                    color: wallet.balance < 0
                                        ? cs.error
                                        : cs.onSurfaceVariant,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
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
