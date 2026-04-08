import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../domain/transaction.dart';
import '../../providers/transactions_provider.dart';

/// Vertical animated list of recent financial transactions.
///
/// • Swipe LEFT  → reveals a red delete action (flutter_slidable BehindMotion)
/// • Swipe RIGHT → pin to top (green Pin action)
/// • Pinned item shows Pinned.svg badge; tapping it unpins.
/// • Pinning animates the item flying to the top via [AnimatedList].
class RecentTransactionsWidget extends ConsumerStatefulWidget {
  const RecentTransactionsWidget({super.key, required this.horizontalPadding});

  final double horizontalPadding;

  @override
  ConsumerState<RecentTransactionsWidget> createState() =>
      _RecentTransactionsWidgetState();
}

class _RecentTransactionsWidgetState
    extends ConsumerState<RecentTransactionsWidget>
    with TickerProviderStateMixin {
  final _listKey = GlobalKey<AnimatedListState>();

  // ── Actions ──────────────────────────────────────────────────────────────

  void _onPin(String id) {
    final notifier = ref.read(transactionsProvider.notifier);
    final before = List<Transaction>.from(ref.read(transactionsProvider));
    final fromIdx = before.indexWhere((t) => t.id == id);
    if (fromIdx < 0) return;
    if (fromIdx == 0) {
      // First item can also be pinned (state flag update only).
      notifier.pinTransaction(id);
      return;
    }

    _listKey.currentState?.removeItem(
      fromIdx,
      (context, animation) =>
          _buildTile(before[fromIdx], animation, isRemoving: true),
      duration: const Duration(milliseconds: 280),
    );

    notifier.pinTransaction(id);

    Future.delayed(const Duration(milliseconds: 60), () {
      if (!mounted) return;
      _listKey.currentState?.insertItem(
        0,
        duration: const Duration(milliseconds: 400),
      );
    });
  }

  void _onUnpin(String id) {
    final before = List<Transaction>.from(ref.read(transactionsProvider));
    final fromIdx = before.indexWhere((t) => t.id == id);

    _listKey.currentState?.removeItem(
      fromIdx,
      (context, animation) =>
          _buildTile(before[fromIdx], animation, isRemoving: true),
      duration: const Duration(milliseconds: 280),
    );

    ref.read(transactionsProvider.notifier).unpinTransaction(id);

    Future.delayed(const Duration(milliseconds: 60), () {
      if (!mounted) return;
      final next = ref.read(transactionsProvider);
      final newIdx = next.indexWhere((t) => t.id == id);
      if (newIdx >= 0) {
        _listKey.currentState?.insertItem(
          newIdx,
          duration: const Duration(milliseconds: 400),
        );
      }
    });
  }

  void _onDelete(String id) {
    final before = List<Transaction>.from(ref.read(transactionsProvider));
    final idx = before.indexWhere((t) => t.id == id);
    if (idx < 0) return;

    _listKey.currentState?.removeItem(
      idx,
      (context, animation) =>
          _buildTile(before[idx], animation, isRemoving: true),
      duration: const Duration(milliseconds: 300),
    );

    ref.read(transactionsProvider.notifier).deleteTransaction(id);
  }

  // ── Build helpers ─────────────────────────────────────────────────────────

  Widget _buildTile(
    Transaction tx,
    Animation<double> animation, {
    bool isRemoving = false,
  }) {
    return SizeTransition(
      sizeFactor: animation,
      child: FadeTransition(
        opacity: animation,
        child: _TransactionTile(
          transaction: tx,
          horizontalPadding: widget.horizontalPadding,
          onPin: () => _onPin(tx.id),
          onUnpin: () => _onUnpin(tx.id),
          onDelete: () => _onDelete(tx.id),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<List<Transaction>>(transactionsProvider, (previous, next) {
      if (previous == null || next.length <= previous.length) return;
      final added = next.length - previous.length;
      for (var i = 0; i < added; i++) {
        _listKey.currentState?.insertItem(
          0,
          duration: const Duration(milliseconds: 350),
        );
      }
    });

    final transactions = ref.watch(transactionsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: widget.horizontalPadding),
          child: const Text(
            'Recent Transaction',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 14),
        // SlidableAutoCloseBehavior ensures only one item is open at a time.
        SlidableAutoCloseBehavior(
          child: AnimatedList(
            key: _listKey,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            initialItemCount: transactions.length,
            itemBuilder: (context, index, animation) {
              if (index >= transactions.length) return const SizedBox.shrink();
              return _buildTile(transactions[index], animation);
            },
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Individual slidable tile
// ---------------------------------------------------------------------------

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({
    required this.transaction,
    required this.horizontalPadding,
    required this.onPin,
    required this.onUnpin,
    required this.onDelete,
  });

  final Transaction transaction;
  final double horizontalPadding;
  final VoidCallback onPin;
  final VoidCallback onUnpin;
  final VoidCallback onDelete;

  // Unified corner radius for the card AND the action pane buttons.
  static const double _radius = 18;
  static const _tileRadius = BorderRadius.all(Radius.circular(_radius));

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Vertical gap between rows lives OUTSIDE Slidable so action panes
      // are only as tall as the card row itself.
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 6),
      child: Slidable(
        key: ValueKey(transaction.id),
        // ── Swipe LEFT → delete ───────────────────────────────────────────
        endActionPane: ActionPane(
          motion: const BehindMotion(),
          extentRatio: 0.24,
          children: [
            // Small gap between card and action button.
            const SizedBox(width: 8),
            Expanded(
              child: ClipRRect(
                borderRadius: _tileRadius,
                child: SlidableAction(
                  onPressed: (_) => onDelete(),
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  icon: Icons.delete_outline_rounded,
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        ),
        // ── Swipe RIGHT → pin ─────────────────────────────────────────────
        startActionPane: ActionPane(
          motion: const BehindMotion(),
          extentRatio: 0.24,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: _tileRadius,
                child: SlidableAction(
                  onPressed: (_) => onPin(),
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  icon: Icons.push_pin_outlined,
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
            // Small gap between action button and card.
            const SizedBox(width: 8),
          ],
        ),
        child: ClipRRect(
          borderRadius: _tileRadius,
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFF1A1C20),
              borderRadius: _tileRadius,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                _TransactionIcon(transaction: transaction),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    transaction.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      transaction.formattedAmount,
                      style: TextStyle(
                        color: transaction.amount < 0
                            ? Colors.redAccent
                            : const Color(0xFF39D353),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (transaction.isPinned) ...[
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: onUnpin,
                        child: SvgPicture.asset(
                          'assets/icons/Pinned.svg',
                          width: 18,
                          height: 18,
                          colorFilter: const ColorFilter.mode(
                            Colors.white70,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Leading icon circle
// ---------------------------------------------------------------------------

class _TransactionIcon extends StatelessWidget {
  const _TransactionIcon({required this.transaction});

  final Transaction transaction;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: transaction.iconBgColor,
        shape: BoxShape.circle,
      ),
      child: Icon(
        IconData(transaction.iconData, fontFamily: 'MaterialIcons'),
        color: Colors.white,
        size: 22,
      ),
    );
  }
}
