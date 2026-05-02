import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../home/domain/transaction.dart';
import '../../../home/providers/transactions_provider.dart';
import '../../domain/models/wallet_entry_model.dart';
import '../providers/wallet_providers.dart';

/// Opens the "Pay Credit Card Debt" bottom sheet for [creditCard].
void showPayCreditCardDebtSheet({
  required BuildContext context,
  required WalletEntry creditCard,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    useSafeArea: true,
    enableDrag: true,
    builder: (_) => _PayCreditCardDebtSheet(creditCard: creditCard),
  );
}

class _PayCreditCardDebtSheet extends ConsumerStatefulWidget {
  const _PayCreditCardDebtSheet({required this.creditCard});

  final WalletEntry creditCard;

  @override
  ConsumerState<_PayCreditCardDebtSheet> createState() =>
      _PayCreditCardDebtSheetState();
}

class _PayCreditCardDebtSheetState
    extends ConsumerState<_PayCreditCardDebtSheet> {
  final _amountCtrl = TextEditingController();
  String? _fromWalletId;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final wallets = ref.read(walletsProvider);
      final eligible = wallets
          .where((w) => w.id != widget.creditCard.id)
          .toList();
      if (eligible.isNotEmpty) {
        setState(() => _fromWalletId = eligible.first.id);
      }
    });
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _onConfirm() async {
    final rawText = _amountCtrl.text.trim().replaceAll(',', '.');
    final amount = double.tryParse(rawText);
    if (amount == null || amount <= 0) {
      setState(
        () => _errorMessage = 'Please enter a valid amount greater than 0.',
      );
      return;
    }
    if (_fromWalletId == null) {
      setState(() => _errorMessage = 'Please select a source wallet.');
      return;
    }
    setState(() => _errorMessage = null);

    HapticFeedback.mediumImpact();
    try {
      await ref
          .read(transactionsProvider.notifier)
          .recordNewTransaction(
            Transaction(
              id: 'tx_${DateTime.now().microsecondsSinceEpoch}',
              title: 'Pay off ${widget.creditCard.name}',
              amount: -amount,
              iconData: Icons.credit_score_rounded.codePoint,
              iconBgColor: const Color(0xFF9B59B6),
              createdAt: DateTime.now(),
              walletId: _fromWalletId,
              transferToWalletId: widget.creditCard.id,
            ),
          );
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    final wallets = ref.watch(walletsProvider);
    final sourceWallets = wallets
        .where((w) => w.id != widget.creditCard.id)
        .toList();

    final debtAmount = widget.creditCard.balance < 0
        ? widget.creditCard.balance.abs()
        : 0.0;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Material(
        color: cs.surfaceContainer,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Drag handle ────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 4),
                child: Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: cs.onSurface.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // ── Header ─────────────────────────────────────────────────────
              Text(
                'Pay Credit Card Debt',
                style: TextStyle(
                  color: cs.onSurface,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                widget.creditCard.name,
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14),
              ),

              // ── Outstanding debt banner ────────────────────────────────────
              if (debtAmount > 0) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: cs.errorContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: cs.onErrorContainer,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Outstanding debt: ₺${debtAmount.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: cs.onErrorContainer,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // ── Error banner ───────────────────────────────────────────────
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _errorMessage == null
                    ? const SizedBox.shrink()
                    : Padding(
                        key: ValueKey<String>(_errorMessage!),
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Material(
                          color: cs.errorContainer,
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline_rounded,
                                  color: cs.onErrorContainer,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: TextStyle(
                                      color: cs.onErrorContainer,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
              ),

              // ── Source wallet selector ─────────────────────────────────────
              Text(
                'Pay from',
                style: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              if (sourceWallets.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'No other wallets available.',
                    style: TextStyle(color: cs.onSurfaceVariant),
                  ),
                )
              else
                ...sourceWallets.map((w) {
                  final selected = w.id == _fromWalletId;
                  return GestureDetector(
                    onTap: () => setState(() => _fromWalletId = w.id),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppTheme.primary.withValues(alpha: 0.1)
                            : cs.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(14),
                        border: selected
                            ? Border.all(color: AppTheme.primary, width: 1.5)
                            : null,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: w.displayColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              w.type.icon,
                              color: w.displayColor,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  w.name,
                                  style: TextStyle(
                                    color: cs.onSurface,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  w.balance >= 0
                                      ? '₺${w.balance.toStringAsFixed(2)}'
                                      : '-₺${w.balance.abs().toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: cs.onSurfaceVariant,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (selected)
                            Icon(
                              Icons.check_circle_rounded,
                              color: AppTheme.primary,
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  );
                }),

              const SizedBox(height: 14),

              // ── Amount field ───────────────────────────────────────────────
              Text(
                'Payment amount',
                style: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: 'Amount (₺)',
                  filled: true,
                  fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.35),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: cs.outline),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: cs.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: AppTheme.primary, width: 2),
                  ),
                  prefixIcon: const Icon(Icons.currency_lira),
                ),
              ),

              const SizedBox(height: 24),

              FilledButton(
                onPressed: _onConfirm,
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text('Confirm Payment'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
