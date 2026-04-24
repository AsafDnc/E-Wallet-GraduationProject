import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/theme_provider.dart';

// ─── Presentation-local domain ────────────────────────────────────────────────

enum _TxType { income, expense }

class _TxRecord {
  const _TxRecord({
    required this.name,
    required this.category,
    required this.amount,
    required this.type,
    required this.date,
    required this.iconBgColor,
    required this.iconData,
  });

  final String name;
  final String category;
  final double amount;
  final _TxType type;
  final DateTime date;
  final Color iconBgColor;
  final IconData iconData;

  String get formattedAmount {
    final sign = type == _TxType.expense ? '-' : '+';
    return '$sign\$${amount.toStringAsFixed(2)}';
  }
}

// ─── Dummy data ───────────────────────────────────────────────────────────────

final _kTransactions = <_TxRecord>[
  _TxRecord(
    name: 'Youtube Premium',
    category: 'Subscription',
    amount: 169.99,
    type: _TxType.expense,
    date: DateTime(2025, 12, 21),
    iconBgColor: const Color(0xFFFF1744),
    iconData: Icons.play_circle_fill_rounded,
  ),
  _TxRecord(
    name: 'Transfer From Sayuti',
    category: 'Salary',
    amount: 430.00,
    type: _TxType.income,
    date: DateTime(2025, 12, 21),
    iconBgColor: const Color(0xFF4CAF50),
    iconData: Icons.person_rounded,
  ),
  _TxRecord(
    name: 'Apple Music',
    category: 'Subscription',
    amount: 15.55,
    type: _TxType.expense,
    date: DateTime(2025, 12, 20),
    iconBgColor: const Color(0xFF607D8B),
    iconData: Icons.music_note_rounded,
  ),
  _TxRecord(
    name: 'Transfer From Zahra',
    category: 'Subscription',
    amount: 550.00,
    type: _TxType.income,
    date: DateTime(2025, 12, 20),
    iconBgColor: const Color(0xFF9C27B0),
    iconData: Icons.person_rounded,
  ),
  _TxRecord(
    name: 'Twitch Premium',
    category: 'Subscription',
    amount: 18.50,
    type: _TxType.expense,
    date: DateTime(2025, 12, 20),
    iconBgColor: const Color(0xFF6441A4),
    iconData: Icons.videogame_asset_rounded,
  ),
  _TxRecord(
    name: 'Netflix',
    category: 'Entertainment',
    amount: 13.99,
    type: _TxType.expense,
    date: DateTime(2025, 12, 19),
    iconBgColor: const Color(0xFFE53935),
    iconData: Icons.live_tv_rounded,
  ),
  _TxRecord(
    name: 'Freelance Payment',
    category: 'Freelance',
    amount: 1200.00,
    type: _TxType.income,
    date: DateTime(2025, 12, 19),
    iconBgColor: const Color(0xFF0288D1),
    iconData: Icons.work_rounded,
  ),
  _TxRecord(
    name: 'Grocery Store',
    category: 'Food',
    amount: 87.40,
    type: _TxType.expense,
    date: DateTime(2025, 12, 18),
    iconBgColor: const Color(0xFF388E3C),
    iconData: Icons.shopping_cart_rounded,
  ),
  _TxRecord(
    name: 'Uber Ride',
    category: 'Transport',
    amount: 22.00,
    type: _TxType.expense,
    date: DateTime(2025, 12, 18),
    iconBgColor: const Color(0xFF424242),
    iconData: Icons.directions_car_rounded,
  ),
  _TxRecord(
    name: 'Stock Dividend',
    category: 'Investment',
    amount: 340.00,
    type: _TxType.income,
    date: DateTime(2025, 12, 17),
    iconBgColor: const Color(0xFFF9A825),
    iconData: Icons.trending_up_rounded,
  ),
  _TxRecord(
    name: 'Spotify Premium',
    category: 'Subscription',
    amount: 9.99,
    type: _TxType.expense,
    date: DateTime(2025, 12, 17),
    iconBgColor: const Color(0xFF1DB954),
    iconData: Icons.headphones_rounded,
  ),
];

// ─── Grouping helper ──────────────────────────────────────────────────────────

Map<DateTime, List<_TxRecord>> _groupByDate(List<_TxRecord> records) {
  final result = <DateTime, List<_TxRecord>>{};
  for (final r in records) {
    final key = DateTime(r.date.year, r.date.month, r.date.day);
    (result[key] ??= []).add(r);
  }
  return result;
}

// ─── App bar leading: shell callback or GoRouter pop ───────────────────────────

class _WalletBackButton extends StatelessWidget {
  const _WalletBackButton({this.onBackTap});

  final VoidCallback? onBackTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final canGoBack = onBackTap != null || context.canPop();
    if (!canGoBack) {
      return const SizedBox.shrink();
    }
    return IconButton(
      icon: Icon(
        Icons.arrow_back_ios_new_rounded,
        color: cs.onSurface,
        size: 20,
      ),
      onPressed: () {
        final cb = onBackTap;
        if (cb != null) {
          cb();
        } else {
          context.pop();
        }
      },
    );
  }
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key, this.onBackTap});

  final VoidCallback? onBackTap;

  static const _kDayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  static String _dayName(DateTime d) => _kDayNames[d.weekday - 1];

  static String _monthYear(DateTime d) =>
      '${d.month.toString().padLeft(2, '0')}.${d.year}';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final groups = _groupByDate(_kTransactions);
    final sortedDates = groups.keys.toList()..sort((a, b) => b.compareTo(a));

    return Scaffold(
      backgroundColor: cs.surface,
      body: CustomScrollView(
        slivers: [
          // ── App bar ─────────────────────────────────────────────────────
          SliverAppBar(
            backgroundColor: cs.surface,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            pinned: true,
            automaticallyImplyLeading: false,
            titleSpacing: 20,
            leading: _WalletBackButton(onBackTap: onBackTap),
            title: Text(
              'Transactions',
              style: TextStyle(
                color: cs.onSurface,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            actions: [
              // Search
              IconButton(
                icon: Icon(Icons.search_rounded, color: cs.onSurface, size: 22),
                onPressed: () {},
              ),
              // Theme toggle — moon in light mode, sun in dark mode
              IconButton(
                icon: Icon(
                  isLight ? Icons.dark_mode_outlined : Icons.light_mode_rounded,
                  color: cs.onSurface,
                  size: 22,
                ),
                tooltip: isLight
                    ? 'Switch to dark mode'
                    : 'Switch to light mode',
                onPressed: () => ref.read(themeModeProvider.notifier).toggle(),
              ),
              // User avatar
              Padding(
                padding: const EdgeInsets.only(right: 14),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: cs.surfaceContainerHighest,
                  child: Icon(
                    Icons.person_rounded,
                    color: cs.onSurfaceVariant,
                    size: 20,
                  ),
                ),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Divider(height: 1, thickness: 1, color: cs.outlineVariant),
            ),
          ),

          // ── Grouped transaction list ─────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 120),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final date = sortedDates[index];
                final items = groups[date]!;
                return _DateGroup(
                  date: date,
                  dayName: _dayName(date),
                  monthYear: _monthYear(date),
                  items: items,
                );
              }, childCount: sortedDates.length),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Date group ───────────────────────────────────────────────────────────────

class _DateGroup extends StatelessWidget {
  const _DateGroup({
    required this.date,
    required this.dayName,
    required this.monthYear,
    required this.items,
  });

  final DateTime date;
  final String dayName;
  final String monthYear;
  final List<_TxRecord> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        _DateHeader(day: date.day, dayName: dayName, monthYear: monthYear),
        const SizedBox(height: 4),
        ...items.map((r) => _TransactionRow(record: r)),
      ],
    );
  }
}

// ─── Date header ─────────────────────────────────────────────────────────────

class _DateHeader extends StatelessWidget {
  const _DateHeader({
    required this.day,
    required this.dayName,
    required this.monthYear,
  });

  final int day;
  final String dayName;
  final String monthYear;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '$day',
          style: TextStyle(
            color: cs.onSurface,
            fontSize: 30,
            fontWeight: FontWeight.w800,
            height: 1,
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Text(
            dayName,
            style: TextStyle(
              color: cs.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          monthYear,
          style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Divider(color: cs.outlineVariant, thickness: 1, height: 1),
        ),
      ],
    );
  }
}

// ─── Transaction row ──────────────────────────────────────────────────────────

class _TransactionRow extends StatelessWidget {
  const _TransactionRow({required this.record});

  final _TxRecord record;

  static const _kRed = Color(0xFFE53935);
  static const _kGreen = Color(0xFF00C853);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isExpense = record.type == _TxType.expense;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          // Leading: tinted circle with icon
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: record.iconBgColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(record.iconData, color: record.iconBgColor, size: 26),
          ),
          const SizedBox(width: 14),

          // Middle: name + category
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.name,
                  style: TextStyle(
                    color: cs.onSurface,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  record.category,
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Trailing: amount + type label
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                record.formattedAmount,
                style: TextStyle(
                  color: isExpense ? _kRed : _kGreen,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                isExpense ? 'Expense' : 'Income',
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
