import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/currency_formatter.dart';

import '../../domain/models/wallet_entry_model.dart';
import '../providers/wallet_providers.dart';

/// Opens a stylised bottom sheet with actions for [wallet].
Future<void> showWalletActionSheet({
  required BuildContext context,
  required WalletEntry wallet,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _WalletActionSheet(wallet: wallet),
  );
}

class _WalletActionSheet extends ConsumerStatefulWidget {
  const _WalletActionSheet({required this.wallet});

  final WalletEntry wallet;

  @override
  ConsumerState<_WalletActionSheet> createState() => _WalletActionSheetState();
}

class _WalletActionSheetState extends ConsumerState<_WalletActionSheet> {
  late bool _isDefault;

  @override
  void initState() {
    super.initState();
    _isDefault = widget.wallet.isDefault;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        0,
        0,
        0,
        MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Drag handle ─────────────────────────────────────────────
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 4),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: cs.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // ── Wallet header ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: widget.wallet.displayColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(
                    widget.wallet.type.icon,
                    color: widget.wallet.displayColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.wallet.name,
                        style: tt.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        widget.wallet.balance.formatted,
                        style: tt.bodyMedium?.copyWith(
                          color:
                              widget.wallet.type == WalletType.creditCard &&
                                  widget.wallet.balance < 0
                              ? cs.error
                              : cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Divider(color: cs.outlineVariant, height: 1),
          ),

          // ── Edit ─────────────────────────────────────────────────────
          _ActionTile(
            icon: Icons.edit_outlined,
            label: 'Edit Wallet',
            cs: cs,
            onTap: () {
              final nav = Navigator.of(context, rootNavigator: true);
              nav.pop();
              Future.microtask(() {
                if (!nav.mounted) return;
                _showEditSheet(nav.context, ref, widget.wallet);
              });
            },
          ),

          // ── Set as Default (Switch) ───────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.star_outline_rounded,
                    color: cs.onPrimaryContainer,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Set as Default', style: tt.bodyLarge),
                      Text(
                        'Use for quick transactions',
                        style: tt.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _isDefault,
                  onChanged: (val) {
                    setState(() => _isDefault = val);
                    if (val) {
                      ref
                          .read(walletsProvider.notifier)
                          .setDefault(widget.wallet.id);
                    }
                  },
                  activeThumbColor: cs.primary,
                ),
              ],
            ),
          ),

          // ── Adjust Balance ────────────────────────────────────────────
          _ActionTile(
            icon: Icons.tune_rounded,
            label: 'Adjust Balance',
            cs: cs,
            onTap: () {
              final nav = Navigator.of(context, rootNavigator: true);
              nav.pop();
              Future.microtask(() {
                if (!nav.mounted) return;
                _showAdjustBalanceSheet(nav.context, ref, widget.wallet);
              });
            },
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Divider(color: cs.outlineVariant, height: 1),
          ),

          // ── Delete (red) ──────────────────────────────────────────────
          _ActionTile(
            icon: Icons.delete_outline_rounded,
            label: 'Delete Wallet',
            cs: cs,
            color: cs.error,
            onTap: () => _confirmDelete(context, ref),
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    final nav = Navigator.of(context, rootNavigator: true);
    nav.pop();
    Future.microtask(() {
      if (!nav.mounted) return;
      _doDelete(nav.context, ref);
    });
  }

  void _doDelete(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;
        return AlertDialog(
          title: const Text('Delete Wallet'),
          content: Text(
            'Delete "${widget.wallet.name}"? This cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: cs.error),
              onPressed: () {
                ref
                    .read(walletsProvider.notifier)
                    .deleteWallet(widget.wallet.id);
                Navigator.of(ctx).pop();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}

// ─── Edit wallet bottom sheet ─────────────────────────────────────────────

void _showEditSheet(BuildContext context, WidgetRef ref, WalletEntry wallet) {
  final nameCtrl = TextEditingController(text: wallet.name);

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      final cs = Theme.of(ctx).colorScheme;
      return Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          MediaQuery.of(ctx).viewInsets.bottom + 24,
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
                'Edit Wallet',
                style: Theme.of(
                  ctx,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Wallet Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () {
                  final name = nameCtrl.text.trim();
                  if (name.isNotEmpty) {
                    ref
                        .read(walletsProvider.notifier)
                        .updateWallet(wallet.copyWith(name: name));
                  }
                  if (ctx.mounted) ctx.pop();
                },
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      );
    },
  );
}

// ─── Adjust balance bottom sheet ──────────────────────────────────────────

void _showAdjustBalanceSheet(
  BuildContext context,
  WidgetRef ref,
  WalletEntry wallet,
) {
  final balanceCtrl = TextEditingController(
    text: wallet.balance.toStringAsFixed(2),
  );

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      final cs = Theme.of(ctx).colorScheme;
      return Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          MediaQuery.of(ctx).viewInsets.bottom + 24,
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
                'Adjust Balance',
                style: Theme.of(
                  ctx,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                wallet.name,
                style: Theme.of(
                  ctx,
                ).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: balanceCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'^-?\d*\.?\d{0,2}'),
                  ),
                ],
                decoration: InputDecoration(
                  labelText: 'Balance (₺)',
                  hintText: '0.00',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  prefixIcon: const Icon(Icons.currency_lira),
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () {
                  final parsed = double.tryParse(
                    balanceCtrl.text.trim().replaceAll(',', '.'),
                  );
                  if (parsed != null) {
                    ref
                        .read(walletsProvider.notifier)
                        .adjustBalance(wallet.id, parsed);
                  }
                  if (ctx.mounted) ctx.pop();
                },
                child: const Text('Update Balance'),
              ),
            ],
          ),
        ),
      );
    },
  );
}

// ─── Shared tile ─────────────────────────────────────────────────────────────

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.cs,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final ColorScheme cs;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? cs.onSurface;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: (color ?? cs.onSurface).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: effectiveColor, size: 20),
      ),
      title: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.bodyLarge?.copyWith(color: effectiveColor),
      ),
      onTap: onTap,
    );
  }
}
