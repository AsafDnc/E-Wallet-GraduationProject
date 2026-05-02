import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../entry/presentation/add_entry_bottom_sheet.dart';
import '../../../home/domain/transaction.dart';
import '../../../home/providers/transactions_provider.dart';
import '../../../profile/providers/profile_providers.dart';
import '../../domain/models/wallet_entry_model.dart';
import '../providers/wallet_providers.dart';
import '../widgets/pay_credit_card_debt_sheet.dart';
import '../widgets/wallet_action_bottom_sheet.dart';

/// Shell tab 1: premium wallet card carousel + filterable transaction history.
class AccountsWalletsDashboardScreen extends ConsumerStatefulWidget {
  const AccountsWalletsDashboardScreen({super.key});

  @override
  ConsumerState<AccountsWalletsDashboardScreen> createState() =>
      _AccountsWalletsDashboardScreenState();
}

enum _AmountFilter { all, income, expense }

class _AccountsWalletsDashboardScreenState
    extends ConsumerState<AccountsWalletsDashboardScreen> {
  // ── State ─────────────────────────────────────────────────────────────────
  PageController? _pageController;
  int _pageIndex = 0;
  String _searchQuery = '';
  _AmountFilter _amountFilter = _AmountFilter.all;

  /// Brief shimmer to showcase loading UX; replaced by real async loading
  /// once Supabase transaction fetch is wired up.
  bool _txShimmer = true;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _txShimmer = false);
    });
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  // ── Preserved filter / controller logic (DO NOT MODIFY) ──────────────────

  void _ensurePageController(List<WalletEntry> wallets) {
    if (wallets.isEmpty) {
      _pageController?.dispose();
      _pageController = null;
      return;
    }
    if (_pageController != null) return;
    final ip = wallets.indexWhere((w) => w.isDefault);
    final idx = ip >= 0 ? ip : 0;
    _pageController = PageController(initialPage: idx, viewportFraction: 0.85);
    _pageIndex = idx;
  }

  void _jumpToPrimaryWallet() {
    final c = _pageController;
    if (c == null || !c.hasClients) return;
    final wallets = ref.read(walletsProvider);
    if (wallets.isEmpty) return;
    final ip = wallets.indexWhere((w) => w.isDefault);
    final target = ip >= 0 ? ip : 0;
    c.jumpToPage(target);
    if (mounted) {
      setState(() => _pageIndex = target);
    }
  }

  WalletEntry? _walletVisibleFromPageView() {
    final wallets = ref.read(walletsProvider);
    if (wallets.isEmpty) return null;
    final c = _pageController;
    if (c == null) return null;
    final int idx;
    if (c.hasClients) {
      final page = c.page ?? c.initialPage.toDouble();
      idx = page.round().clamp(0, wallets.length - 1);
    } else {
      idx = c.initialPage.clamp(0, wallets.length - 1);
    }
    return wallets[idx];
  }

  void _openAddEntry() {
    final visible = _walletVisibleFromPageView();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => AddTransactionSheet(initialWalletId: visible?.id),
    );
  }

  void _openTransferSheet(WalletEntry fromWallet) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => AddTransactionSheet(
        initialTransfer: true,
        initialFromWalletId: fromWallet.id,
      ),
    );
  }

  void _openPayDebtSheet(WalletEntry creditCard) {
    showPayCreditCardDebtSheet(context: context, creditCard: creditCard);
  }

  void _openCardSettings(WalletEntry wallet) {
    showWalletActionSheet(context: context, wallet: wallet);
  }

  List<Transaction> _applyLocalFilters(List<Transaction> list) {
    var out = list;
    switch (_amountFilter) {
      case _AmountFilter.income:
        out = out.where((t) => t.amount > 0).toList();
        break;
      case _AmountFilter.expense:
        out = out.where((t) => t.amount < 0).toList();
        break;
      case _AmountFilter.all:
        break;
    }
    final q = _searchQuery.trim().toLowerCase();
    if (q.isNotEmpty) {
      out = out.where((t) => t.title.toLowerCase().contains(q)).toList();
    }
    return out;
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final wallets = ref.watch(walletsProvider);
    final profile = ref.watch(profileProvider);

    _ensurePageController(wallets);

    ref.listen<List<WalletEntry>>(walletsProvider, (previous, next) {
      if (previous == null) return;
      if (previous.length != next.length && next.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _jumpToPrimaryWallet();
        });
      }
      if (next.isNotEmpty && _pageIndex >= next.length) {
        final last = next.length - 1;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _pageController?.jumpToPage(last);
          setState(() => _pageIndex = last);
        });
      }
    });

    final safeIndex = _pageIndex.clamp(
      0,
      wallets.isEmpty ? 0 : wallets.length - 1,
    );
    final selectedWallet = wallets.isEmpty ? null : wallets[safeIndex];
    final baseList = selectedWallet == null
        ? const <Transaction>[]
        : ref.watch(transactionsForWalletProvider(selectedWallet.id));
    final filtered = _applyLocalFilters(baseList);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: cs.surface,
      body: SafeArea(
        child: wallets.isEmpty
            ? _EmptyWallets(cs: cs, l10n: l10n)
            : CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // ── Screen title ──────────────────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(22, 20, 22, 14),
                      child: Text(
                        l10n.accountsScreenTitle,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                      ),
                    ),
                  ),

                  // ── Premium card carousel ─────────────────────────────────
                  SliverToBoxAdapter(
                    child: LayoutBuilder(
                      builder: (ctx, constraints) {
                        final cardW = constraints.maxWidth * 0.85 - 12;
                        final cardH = cardW / 1.586;
                        return SizedBox(
                          // Extra vertical room for drop shadow to breathe.
                          height: cardH + 28,
                          child: PageView.builder(
                            controller: _pageController!,
                            itemCount: wallets.length,
                            padEnds: true,
                            onPageChanged: (i) {
                              HapticFeedback.selectionClick();
                              setState(() => _pageIndex = i);
                            },
                            itemBuilder: (context, i) {
                              return AnimatedBuilder(
                                animation: _pageController!,
                                builder: (context, _) {
                                  final page = _pageController!.hasClients
                                      ? (_pageController!.page ??
                                            _pageIndex.toDouble())
                                      : _pageIndex.toDouble();
                                  final dist = (i - page).abs().clamp(0.0, 1.0);
                                  final scale = 1.0 - dist * 0.1;
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 10,
                                    ),
                                    child: Transform.scale(
                                      scale: scale,
                                      child: _PremiumWalletCard(
                                        wallet: wallets[i],
                                        holderName: profile.fullName,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),

                  // ── Page-indicator dots ───────────────────────────────────
                  if (wallets.length > 1)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(wallets.length, (i) {
                            final active = i == safeIndex;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              width: active ? 20 : 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: active
                                    ? cs.primary
                                    : cs.onSurface.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),

                  // ── Action buttons (lazy wallet resolve on tap; no watch) ──
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(22, 14, 22, 4),
                      child: _AccountsActionButtonsBar(
                        l10n: l10n,
                        pageController: _pageController!,
                        onAdd: _openAddEntry,
                        onOpenTransfer: _openTransferSheet,
                        onOpenPayDebt: _openPayDebtSheet,
                        onOpenCardSettings: _openCardSettings,
                      ),
                    ),
                  ),

                  // ── Filter bar ────────────────────────────────────────────
                  SliverToBoxAdapter(
                    child: _FilterBar(
                      l10n: l10n,
                      amountFilter: _amountFilter,
                      onSearch: (v) => setState(() => _searchQuery = v),
                      onFilter: (f) => setState(() => _amountFilter = f),
                    ),
                  ),

                  // ── History section header ────────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(22, 20, 22, 6),
                      child: Row(
                        children: [
                          Text(
                            l10n.accountsHistoryTitle,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const Spacer(),
                          if (!_txShimmer)
                            Text(
                              l10n.historyItemCount(filtered.length),
                              style: TextStyle(
                                color: cs.onSurfaceVariant,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // ── Content: shimmer / empty / list ───────────────────────
                  if (_txShimmer)
                    _ShimmerList()
                  else if (filtered.isEmpty)
                    SliverToBoxAdapter(
                      child: _EmptyTransactions(
                        l10n: l10n,
                        hasActiveFilters:
                            _searchQuery.isNotEmpty ||
                            _amountFilter != _AmountFilter.all,
                      ),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final tx = filtered[index];
                        return _TransactionTile(
                          key: ValueKey<String>(tx.id),
                          transaction: tx,
                          showDivider: index < filtered.length - 1,
                          onPin: () => ref
                              .read(transactionsProvider.notifier)
                              .pinTransaction(tx.id),
                          onUnpin: () => ref
                              .read(transactionsProvider.notifier)
                              .unpinTransaction(tx.id),
                          onDelete: () {
                            HapticFeedback.heavyImpact();
                            ref
                                .read(transactionsProvider.notifier)
                                .deleteTransaction(tx.id);
                          },
                        );
                      }, childCount: filtered.length),
                    ),

                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 120 + MediaQuery.viewInsetsOf(context).bottom,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PREMIUM WALLET CARD
// ─────────────────────────────────────────────────────────────────────────────

class _PremiumWalletCard extends StatelessWidget {
  const _PremiumWalletCard({required this.wallet, required this.holderName});

  final WalletEntry wallet;
  final String holderName;

  static LinearGradient _gradientFor(WalletType type) {
    switch (type) {
      case WalletType.bank:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A4A9C), Color(0xFF0A1628)],
          stops: [0.0, 1.0],
        );
      case WalletType.cash:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF059669), Color(0xFF064E3B)],
          stops: [0.0, 1.0],
        );
      case WalletType.creditCard:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4A1A7C), Color(0xFF0E0820)],
          stops: [0.0, 1.0],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final gradient = _gradientFor(wallet.type);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: gradient,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.32),
            blurRadius: 22,
            spreadRadius: 0,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 6,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ── Background circle decoration ──────────────────────────────
            Positioned(
              right: -40,
              bottom: -40,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),
            Positioned(
              right: 20,
              bottom: -80,
              child: Container(
                width: 210,
                height: 210,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.07),
                    width: 1.5,
                  ),
                ),
              ),
            ),
            // ── Subtle top-edge highlight ─────────────────────────────────
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.white.withValues(alpha: 0.18),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // ── Card content ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row: chip + NFC/primary-badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (wallet.type != WalletType.cash)
                        const _EmvChip()
                      else
                        Icon(
                          Icons.payments_rounded,
                          color: Colors.white.withValues(alpha: 0.75),
                          size: 30,
                        ),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (wallet.type != WalletType.cash)
                            Icon(
                              Icons.contactless_rounded,
                              color: Colors.white.withValues(alpha: 0.45),
                              size: 24,
                            ),
                          if (wallet.isDefault) ...[
                            if (wallet.type != WalletType.cash)
                              const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.28),
                                  width: 0.5,
                                ),
                              ),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.walletBadgePrimary,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Holder name
                  Text(
                    holderName.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.55),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Wallet name + balance on same row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text(
                          wallet.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        wallet.balance.formatted,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EMV CHIP
// ─────────────────────────────────────────────────────────────────────────────

class _EmvChip extends StatelessWidget {
  const _EmvChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 30,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE5C76B), Color(0xFFB8960C), Color(0xFFE5C76B)],
          stops: [0.0, 0.55, 1.0],
        ),
      ),
      child: const CustomPaint(painter: _ChipPainter()),
    );
  }
}

class _ChipPainter extends CustomPainter {
  const _ChipPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF8B6914).withValues(alpha: 0.55)
      ..strokeWidth = 0.7
      ..style = PaintingStyle.stroke;

    // Vertical center line
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      paint,
    );
    // Horizontal thirds
    canvas.drawLine(
      Offset(0, size.height * 0.33),
      Offset(size.width, size.height * 0.33),
      paint,
    );
    canvas.drawLine(
      Offset(0, size.height * 0.66),
      Offset(size.width, size.height * 0.66),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// ACTION BUTTONS (wallet resolved on tap via [PageController] + ref.read)
// ─────────────────────────────────────────────────────────────────────────────

class _AccountsActionButtonsBar extends ConsumerStatefulWidget {
  const _AccountsActionButtonsBar({
    required this.l10n,
    required this.pageController,
    required this.onAdd,
    required this.onOpenTransfer,
    required this.onOpenPayDebt,
    required this.onOpenCardSettings,
  });

  final AppLocalizations l10n;
  final PageController pageController;
  final VoidCallback onAdd;
  final void Function(WalletEntry wallet) onOpenTransfer;
  final void Function(WalletEntry wallet) onOpenPayDebt;
  final void Function(WalletEntry wallet) onOpenCardSettings;

  @override
  ConsumerState<_AccountsActionButtonsBar> createState() =>
      _AccountsActionButtonsBarState();
}

class _AccountsActionButtonsBarState
    extends ConsumerState<_AccountsActionButtonsBar> {
  WalletEntry? _walletForTap() {
    final wallets = ref.read(walletsProvider);
    if (wallets.isEmpty) return null;
    final c = widget.pageController;
    final int idx;
    if (c.hasClients) {
      final page = c.page ?? c.initialPage.toDouble();
      idx = page.round().clamp(0, wallets.length - 1);
    } else {
      idx = c.initialPage.clamp(0, wallets.length - 1);
    }
    return wallets[idx];
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _ActionButton(
          icon: Icons.add_rounded,
          label: widget.l10n.accountsActionAdd,
          onTap: widget.onAdd,
        ),
        _ActionButton(
          icon: Icons.swap_horiz_rounded,
          label: widget.l10n.accountsActionTransfer,
          onTap: () {
            final w = _walletForTap();
            if (w == null) return;
            widget.onOpenTransfer(w);
          },
        ),
        _ActionButton(
          icon: Icons.credit_score_rounded,
          label: widget.l10n.accountsActionPayDebt,
          onTap: () {
            final w = _walletForTap();
            if (w == null) return;
            widget.onOpenPayDebt(w);
          },
        ),
        _ActionButton(
          icon: Icons.settings_rounded,
          label: widget.l10n.accountsActionSettings,
          onTap: () {
            final w = _walletForTap();
            if (w == null) return;
            widget.onOpenCardSettings(w);
          },
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final enabled = onTap != null;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: enabled
                  ? cs.primary.withValues(alpha: 0.12)
                  : cs.onSurface.withValues(alpha: 0.06),
            ),
            child: Icon(
              icon,
              size: 22,
              color: enabled
                  ? cs.primary
                  : cs.onSurface.withValues(alpha: 0.28),
            ),
          ),
          const SizedBox(height: 7),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: enabled
                  ? cs.onSurface
                  : cs.onSurface.withValues(alpha: 0.32),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ANIMATED FILTER BAR
// Chips row + collapsible search icon that expands to a full-width text field.
// The two elements are stacked with AnimatedPositioned so the search bar
// "eats" the chips as it expands from right to left.
// ─────────────────────────────────────────────────────────────────────────────

class _FilterBar extends StatefulWidget {
  const _FilterBar({
    required this.l10n,
    required this.amountFilter,
    required this.onSearch,
    required this.onFilter,
  });

  final AppLocalizations l10n;
  final _AmountFilter amountFilter;
  final ValueChanged<String> onSearch;
  final ValueChanged<_AmountFilter> onFilter;

  @override
  State<_FilterBar> createState() => _FilterBarState();
}

class _FilterBarState extends State<_FilterBar> {
  static const _dur = Duration(milliseconds: 320);
  static const _iconW = 44.0;

  bool _isSearching = false;
  final _focusNode = FocusNode();
  final _textCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _textCtrl.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus && _isSearching) _closeSearch();
  }

  void _openSearch() {
    HapticFeedback.lightImpact();
    setState(() => _isSearching = true);
    // Brief delay lets the position animation start before the keyboard
    // animation begins — prevents a jarring layout jump on slower devices.
    Future.delayed(const Duration(milliseconds: 60), () {
      if (mounted) _focusNode.requestFocus();
    });
  }

  void _closeSearch() {
    _focusNode.unfocus();
    _textCtrl.clear();
    widget.onSearch('');
    if (mounted) setState(() => _isSearching = false);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 16, 22, 0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final totalW = constraints.maxWidth;

          return ClipRect(
            child: SizedBox(
              height: _iconW,
              child: Stack(
                children: [
                  // ── Filter chips (slide left as search bar expands) ────────
                  AnimatedPositioned(
                    duration: _dur,
                    curve: Curves.easeOutCubic,
                    left: _isSearching ? -totalW : 0,
                    top: 0,
                    bottom: 0,
                    width: totalW - _iconW - 8,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _FilterChipItem(
                            label: widget.l10n.filterAll,
                            selected: widget.amountFilter == _AmountFilter.all,
                            onTap: () => widget.onFilter(_AmountFilter.all),
                          ),
                          const SizedBox(width: 8),
                          _FilterChipItem(
                            label: widget.l10n.filterIncome,
                            selected:
                                widget.amountFilter == _AmountFilter.income,
                            onTap: () => widget.onFilter(_AmountFilter.income),
                            activeColor: const Color(0xFF22C55E),
                          ),
                          const SizedBox(width: 8),
                          _FilterChipItem(
                            label: widget.l10n.filterExpense,
                            selected:
                                widget.amountFilter == _AmountFilter.expense,
                            onTap: () => widget.onFilter(_AmountFilter.expense),
                            activeColor: const Color(0xFFEF4444),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Search bar (expands right → left, anchored to right) ───
                  AnimatedPositioned(
                    duration: _dur,
                    curve: Curves.easeOutCubic,
                    right: 0,
                    top: 0,
                    bottom: 0,
                    width: _isSearching ? totalW : _iconW,
                    child: Stack(
                      alignment: Alignment.centerRight,
                      children: [
                        // Full-width text field — fades in after bar expands.
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 180),
                          opacity: _isSearching ? 1.0 : 0.0,
                          child: IgnorePointer(
                            ignoring: !_isSearching,
                            child: Container(
                              height: _iconW,
                              decoration: BoxDecoration(
                                color: cs.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                children: [
                                  const SizedBox(width: 14),
                                  Icon(
                                    Icons.search_rounded,
                                    color: cs.onSurfaceVariant,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(
                                      controller: _textCtrl,
                                      focusNode: _focusNode,
                                      style: TextStyle(
                                        color: cs.onSurface,
                                        fontSize: 14,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: widget.l10n.searchHint,
                                        hintStyle: TextStyle(
                                          color: cs.onSurfaceVariant.withValues(
                                            alpha: 0.6,
                                          ),
                                          fontSize: 14,
                                        ),
                                        border: InputBorder.none,
                                        isDense: true,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                      onChanged: widget.onSearch,
                                    ),
                                  ),
                                  // Clear "✕" button — only when text is present.
                                  ValueListenableBuilder<TextEditingValue>(
                                    valueListenable: _textCtrl,
                                    builder: (context, value, _) {
                                      if (value.text.isEmpty) {
                                        return const SizedBox(width: 14);
                                      }
                                      return GestureDetector(
                                        onTap: () {
                                          _textCtrl.clear();
                                          widget.onSearch('');
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            right: 10,
                                          ),
                                          child: Icon(
                                            Icons.clear_rounded,
                                            size: 18,
                                            color: cs.onSurfaceVariant,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Search icon button — fades out as bar expands.
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 180),
                          opacity: _isSearching ? 0.0 : 1.0,
                          child: IgnorePointer(
                            ignoring: _isSearching,
                            child: GestureDetector(
                              onTap: _openSearch,
                              child: Container(
                                width: _iconW,
                                height: _iconW,
                                decoration: BoxDecoration(
                                  color: cs.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(
                                  Icons.search_rounded,
                                  color: cs.onSurfaceVariant,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FilterChipItem extends StatelessWidget {
  const _FilterChipItem({
    required this.label,
    required this.selected,
    required this.onTap,
    this.activeColor,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? activeColor;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = activeColor ?? cs.primary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: 0.13)
              : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: selected
              ? Border.all(color: color.withValues(alpha: 0.45), width: 1)
              : null,
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selected ? color : cs.onSurfaceVariant,
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MINIMALIST TRANSACTION TILE
// ─────────────────────────────────────────────────────────────────────────────

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({
    super.key,
    required this.transaction,
    required this.showDivider,
    required this.onPin,
    required this.onUnpin,
    required this.onDelete,
  });

  final Transaction transaction;
  final bool showDivider;
  final VoidCallback onPin;
  final VoidCallback onUnpin;
  final VoidCallback onDelete;

  static const double _slideRatio = 0.22;
  static const _slideRadius = BorderRadius.all(Radius.circular(14));

  static String _fmtDate(BuildContext context, DateTime d) {
    final tag = Localizations.localeOf(context).toLanguageTag();
    return DateFormat.MMMd(tag).format(d);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isIncome = transaction.amount > 0;

    return Slidable(
      key: ValueKey<String>(transaction.id),
      endActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio: _slideRatio,
        children: [
          const SizedBox(width: 6),
          Expanded(
            child: ClipRRect(
              borderRadius: _slideRadius,
              child: SlidableAction(
                onPressed: (_) => onDelete(),
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                icon: Icons.delete_outline_rounded,
                padding: EdgeInsets.zero,
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      startActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio: _slideRatio,
        children: [
          const SizedBox(width: 16),
          Expanded(
            child: ClipRRect(
              borderRadius: _slideRadius,
              child: SlidableAction(
                onPressed: (_) => transaction.isPinned ? onUnpin() : onPin(),
                backgroundColor: AppTheme.pinSwipeBackground,
                foregroundColor: Colors.white,
                icon: transaction.isPinned
                    ? Icons.push_pin
                    : Icons.push_pin_outlined,
                padding: EdgeInsets.zero,
              ),
            ),
          ),
          const SizedBox(width: 6),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 13),
              child: Row(
                children: [
                  // Category icon circle (flat, no white bg)
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: transaction.iconBgColor.withValues(alpha: 0.13),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      IconData(
                        transaction.iconData,
                        fontFamily: 'MaterialIcons',
                      ),
                      color: transaction.iconBgColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Title + date
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                transaction.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: cs.onSurface,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (transaction.isPinned) ...[
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: onUnpin,
                                child: SvgPicture.asset(
                                  'assets/icons/Pinned.svg',
                                  width: 13,
                                  height: 13,
                                  colorFilter: ColorFilter.mode(
                                    cs.onSurfaceVariant,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _fmtDate(context, transaction.createdAt),
                          style: TextStyle(
                            color: cs.onSurfaceVariant,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Amount — green for income, red for expense
                  Text(
                    transaction.formattedAmount,
                    style: TextStyle(
                      color: isIncome
                          ? const Color(0xFF22C55E)
                          : const Color(0xFFEF4444),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            if (showDivider)
              Divider(
                height: 1,
                thickness: 0.5,
                color: cs.outlineVariant.withValues(alpha: 0.5),
                indent: 58,
                endIndent: 0,
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EMPTY STATES
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyWallets extends StatelessWidget {
  const _EmptyWallets({required this.cs, required this.l10n});

  final ColorScheme cs;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.account_balance_wallet_outlined,
              size: 40,
              color: cs.onSurfaceVariant.withValues(alpha: 0.45),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            l10n.emptyNoWalletsTitle,
            style: TextStyle(
              color: cs.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              l10n.emptyNoWalletsBody,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: cs.onSurfaceVariant,
                fontSize: 14,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyTransactions extends StatelessWidget {
  const _EmptyTransactions({
    required this.l10n,
    required this.hasActiveFilters,
  });

  final AppLocalizations l10n;
  final bool hasActiveFilters;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 40, 40, 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Icon(
              hasActiveFilters
                  ? Icons.search_off_rounded
                  : Icons.receipt_long_outlined,
              size: 34,
              color: cs.onSurfaceVariant.withValues(alpha: 0.45),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            hasActiveFilters
                ? l10n.emptyNoResultsTitle
                : l10n.emptyNoTransactionsTitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: cs.onSurface,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            hasActiveFilters
                ? l10n.emptyNoResultsBody
                : l10n.emptyNoTransactionsBody,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: cs.onSurfaceVariant,
              fontSize: 13,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHIMMER SKELETON
// ─────────────────────────────────────────────────────────────────────────────

class _ShimmerList extends StatelessWidget {
  const _ShimmerList();

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => _ShimmerTile(key: ValueKey<int>(index)),
        childCount: 5,
      ),
    );
  }
}

class _ShimmerTile extends StatefulWidget {
  const _ShimmerTile({super.key});

  @override
  State<_ShimmerTile> createState() => _ShimmerTileState();
}

class _ShimmerTileState extends State<_ShimmerTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? const Color(0xFF2A2D32) : const Color(0xFFE8ECF0);
    final highlight = isDark
        ? const Color(0xFF3A3D44)
        : const Color(0xFFF5F7FA);

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final v = _ctrl.value;
        final shimmer = LinearGradient(
          begin: const Alignment(-1.5, 0),
          end: const Alignment(1.5, 0),
          colors: [base, highlight, base],
          stops: [
            (v - 0.3).clamp(0.0, 1.0),
            v.clamp(0.0, 1.0),
            (v + 0.3).clamp(0.0, 1.0),
          ],
        );

        BoxDecoration shimmerBox({double? w, double? h, bool circle = false}) =>
            BoxDecoration(
              color: base,
              gradient: shimmer,
              borderRadius: circle ? null : BorderRadius.circular(6),
              shape: circle ? BoxShape.circle : BoxShape.rectangle,
            );

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: shimmerBox(circle: true),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 13,
                      width: double.infinity,
                      decoration: shimmerBox(),
                    ),
                    const SizedBox(height: 7),
                    Container(height: 10, width: 70, decoration: shimmerBox()),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(height: 13, width: 58, decoration: shimmerBox()),
            ],
          ),
        );
      },
    );
  }
}
