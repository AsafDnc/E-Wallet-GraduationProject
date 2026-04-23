import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/models/wallet_entry_model.dart';
import '../providers/wallet_providers.dart';
import '../widgets/total_balance_card.dart';
import '../widgets/wallet_action_bottom_sheet.dart';
import '../widgets/wallet_list_item.dart';

class MyWalletsScreen extends ConsumerWidget {
  const MyWalletsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final wallets = ref.watch(walletsProvider);

    return Scaffold(
      backgroundColor: cs.surface,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── App Bar ────────────────────────────────────────────────
          SliverAppBar(
            backgroundColor: cs.surface,
            surfaceTintColor: Colors.transparent,
            pinned: true,
            centerTitle: false,
            title: Text(
              'My Wallets',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: cs.onSurface),
              onPressed: () => context.pop(),
            ),
          ),

          // ── Total Balance Card ─────────────────────────────────────
          const SliverToBoxAdapter(child: TotalBalanceCard()),

          // ── Section header ─────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text(
                'All Accounts',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),

          // ── Wallet list ────────────────────────────────────────────
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final wallet = wallets[index];
              return WalletListItem(
                wallet: wallet,
                onTap: () =>
                    showWalletActionSheet(context: context, wallet: wallet),
              );
            }, childCount: wallets.length),
          ),

          // ── Bottom padding for FAB ─────────────────────────────────
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),

      // ── FAB: Add Wallet ─────────────────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddWalletSheet(context, ref),
        backgroundColor: cs.primaryContainer,
        foregroundColor: cs.onPrimaryContainer,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add Wallet',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

// ─── Add Wallet bottom sheet ──────────────────────────────────────────────

void _showAddWalletSheet(BuildContext context, WidgetRef ref) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _AddWalletSheet(),
  );
}

class _AddWalletSheet extends ConsumerStatefulWidget {
  @override
  ConsumerState<_AddWalletSheet> createState() => _AddWalletSheetState();
}

class _AddWalletSheetState extends ConsumerState<_AddWalletSheet> {
  final _nameCtrl = TextEditingController();
  final _balanceCtrl = TextEditingController(text: '0.00');
  WalletType _selectedType = WalletType.bank;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _balanceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: cs.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            Text(
              'Add Wallet',
              style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 20),

            // ── Name field ────────────────────────────────────────────
            TextField(
              controller: _nameCtrl,
              decoration: InputDecoration(
                labelText: 'Wallet Name',
                hintText: 'e.g. Vacation Savings',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // ── Balance field ─────────────────────────────────────────
            TextField(
              controller: _balanceCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d{0,2}')),
              ],
              decoration: InputDecoration(
                labelText: 'Initial Balance (₺)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                prefixIcon: const Icon(Icons.currency_lira),
              ),
            ),
            const SizedBox(height: 14),

            // ── Type selector ─────────────────────────────────────────
            Text(
              'Account Type',
              style: tt.labelLarge?.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            Row(
              children: WalletType.values.map((type) {
                final selected = type == _selectedType;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedType = type),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: selected
                              ? cs.primaryContainer
                              : cs.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                          border: selected
                              ? Border.all(color: cs.primary, width: 1.5)
                              : null,
                        ),
                        child: Column(
                          children: [
                            Icon(
                              type.icon,
                              size: 22,
                              color: selected
                                  ? cs.primary
                                  : cs.onSurfaceVariant,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              type.label,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: selected
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                                color: selected
                                    ? cs.primary
                                    : cs.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // ── Save ──────────────────────────────────────────────────
            FilledButton(
              onPressed: () {
                final name = _nameCtrl.text.trim();
                if (name.isEmpty) return;
                final balance =
                    double.tryParse(_balanceCtrl.text.trim()) ?? 0.0;
                final newWallet = WalletEntry(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: name,
                  type: _selectedType,
                  balance: balance,
                  color: const Color(0xFF1D75DD).toARGB32(),
                  iconCode: _selectedType.icon.codePoint,
                );
                ref.read(walletsProvider.notifier).addWallet(newWallet);
                Navigator.of(context).pop();
              },
              child: const Text('Add Wallet'),
            ),
          ],
        ),
      ),
    );
  }
}
