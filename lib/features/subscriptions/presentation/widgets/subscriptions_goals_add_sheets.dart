import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../goals/domain/goal_model.dart';
import '../../../goals/domain/goals_save_exception.dart';
import '../../../goals/providers/goals_provider.dart';
import '../../domain/subscription_model.dart';
import '../../providers/subscriptions_provider.dart';

const _uuid = Uuid();
const _errorAutoDismiss = Duration(seconds: 3);

void showAddSubscriptionSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    useSafeArea: true,
    enableDrag: true,
    builder: (ctx) => const _AddSubscriptionSheet(),
  );
}

void showAddSavingGoalSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    useSafeArea: true,
    enableDrag: true,
    builder: (ctx) => const _AddSavingGoalSheet(),
  );
}

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

InputDecoration _fieldDecoration(
  BuildContext context, {
  required String label,
  required bool highlightError,
}) {
  final cs = Theme.of(context).colorScheme;
  final borderColor = highlightError ? cs.error : cs.outline;
  final base = OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: BorderSide(color: borderColor, width: highlightError ? 2 : 1),
  );
  return InputDecoration(
    labelText: label,
    filled: true,
    fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.35),
    border: base,
    enabledBorder: base,
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(
        color: highlightError ? cs.error : AppTheme.primary,
        width: 2,
      ),
    ),
    errorBorder: base,
    focusedErrorBorder: base,
  );
}

Widget _buildErrorBanner(ColorScheme cs, String? message) {
  if (message == null) return const SizedBox.shrink();
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Material(
      color: cs.errorContainer,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Icon(Icons.info_outline_rounded, color: cs.onErrorContainer),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
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
  );
}

// ─── Add subscription ─────────────────────────────────────────────────────────

class _AddSubscriptionSheet extends ConsumerStatefulWidget {
  const _AddSubscriptionSheet();

  @override
  ConsumerState<_AddSubscriptionSheet> createState() =>
      _AddSubscriptionSheetState();
}

class _AddSubscriptionSheetState extends ConsumerState<_AddSubscriptionSheet> {
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _monthlyDayCtrl = TextEditingController();

  late FixedExtentScrollController _weekScrollController;

  String _billingCycle = 'monthly';
  int _weeklyWeekday = DateTime.monday;
  DateTime _yearlyRenewal = _dateOnly(
    DateTime.now(),
  ).add(const Duration(days: 1));

  String? _bannerMessage;
  Timer? _bannerTimer;

  bool _highlightName = false;
  bool _highlightPrice = false;
  bool _highlightSchedule = false;

  List<String> _localizedWeekdayLabels(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final format = DateFormat.EEEE(locale.toString());
    return List.generate(7, (i) => format.format(DateTime(2024, 1, 1 + i)));
  }

  @override
  void initState() {
    super.initState();
    _weekScrollController = FixedExtentScrollController(
      initialItem: _weeklyWeekday - 1,
    );
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _weekScrollController.dispose();
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _monthlyDayCtrl.dispose();
    super.dispose();
  }

  void _clearBannerAndHighlights() {
    _bannerTimer?.cancel();
    setState(() {
      _bannerMessage = null;
      _highlightName = false;
      _highlightPrice = false;
      _highlightSchedule = false;
    });
  }

  void _showTimedFeedback(
    String message, {
    bool name = false,
    bool price = false,
    bool schedule = false,
  }) {
    _bannerTimer?.cancel();
    setState(() {
      _bannerMessage = message;
      _highlightName = name;
      _highlightPrice = price;
      _highlightSchedule = schedule;
    });
    _bannerTimer = Timer(_errorAutoDismiss, () {
      if (!mounted) return;
      setState(() {
        _bannerMessage = null;
        _highlightName = false;
        _highlightPrice = false;
        _highlightSchedule = false;
      });
    });
  }

  void _showTransientOnly(String message) {
    _bannerTimer?.cancel();
    setState(() {
      _bannerMessage = message;
      _highlightName = false;
      _highlightPrice = false;
      _highlightSchedule = false;
    });
    _bannerTimer = Timer(_errorAutoDismiss, () {
      if (mounted) setState(() => _bannerMessage = null);
    });
  }

  int _billingDays(String cycle) {
    switch (cycle) {
      case 'yearly':
        return 365;
      case 'weekly':
        return 7;
      default:
        return 30;
    }
  }

  double _normalizedMonthlyPrice(double rawAmount, String cycle) {
    switch (cycle) {
      case 'weekly':
        return rawAmount * 52 / 12;
      case 'yearly':
        return rawAmount / 12;
      default:
        return rawAmount;
    }
  }

  DateTime _nextWeeklyRenewalDate(int targetWeekday) {
    final today = _dateOnly(DateTime.now());
    for (var i = 1; i <= 14; i++) {
      final d = today.add(Duration(days: i));
      if (d.weekday == targetWeekday) return d;
    }
    return today.add(const Duration(days: 7));
  }

  void _onMonthlyDayChanged(String value) {
    if (value.isEmpty) return;
    final n = int.tryParse(value);
    if (n == null) return;
    if (n < 1 || n > 31) {
      _monthlyDayCtrl.clear();
      _showTransientOnly(
        AppLocalizations.of(context)!.subscriptionErrorDayOfMonthRange,
      );
    }
  }

  Future<void> _onConfirm() async {
    _clearBannerAndHighlights();

    final l10n = AppLocalizations.of(context)!;
    final name = _nameCtrl.text.trim();
    final priceRaw = double.tryParse(
      _priceCtrl.text.trim().replaceAll(',', '.'),
    );

    if (name.isEmpty) {
      _showTimedFeedback(l10n.subscriptionErrorServiceNameEmpty, name: true);
      return;
    }

    if (_priceCtrl.text.trim().isEmpty || priceRaw == null || priceRaw <= 0) {
      _showTimedFeedback(l10n.subscriptionErrorAmountInvalid, price: true);
      return;
    }

    final today = _dateOnly(DateTime.now());
    int renewalDayOfMonth;
    int daysUntilRenewal;

    if (_billingCycle == 'monthly') {
      final d = int.tryParse(_monthlyDayCtrl.text.trim());
      if (_monthlyDayCtrl.text.trim().isEmpty || d == null) {
        _showTimedFeedback(
          l10n.subscriptionErrorBillingDayRequired,
          schedule: true,
        );
        return;
      }
      if (d < 1 || d > 31) {
        _monthlyDayCtrl.clear();
        _showTransientOnly(l10n.subscriptionErrorDayOfMonthRange);
        return;
      }
      renewalDayOfMonth = d;
      daysUntilRenewal = SubscriptionModel.daysUntilFromRenewalDay(d, 30);
    } else if (_billingCycle == 'weekly') {
      final next = _nextWeeklyRenewalDate(_weeklyWeekday);
      renewalDayOfMonth = next.day.clamp(1, 31);
      daysUntilRenewal = next.difference(today).inDays.clamp(1, 365);
    } else {
      final picked = _dateOnly(_yearlyRenewal);
      if (!picked.isAfter(today)) {
        _showTimedFeedback(
          l10n.subscriptionErrorBillingDateAfterToday,
          schedule: true,
        );
        return;
      }
      renewalDayOfMonth = picked.day.clamp(1, 31);
      daysUntilRenewal = picked.difference(today).inDays;
    }

    final cycleDays = _billingDays(_billingCycle);
    final monthlyPrice = _normalizedMonthlyPrice(priceRaw, _billingCycle);
    final id = _uuid.v4();

    final model = SubscriptionModel(
      id: id,
      displayName: name,
      shortNameUppercase: SubscriptionModel.shortNameFromDisplay(name),
      monthlyPrice: monthlyPrice,
      daysUntilRenewal: daysUntilRenewal,
      billingCycleDays: cycleDays,
      iconData: SubscriptionModel.defaultIconCodePointForName(name),
      iconBgColor: SubscriptionModel.colorForName(name),
      renewalDayOfMonth: renewalDayOfMonth,
    );

    try {
      await ref.read(subscriptionsProvider.notifier).addSubscription(model);
      if (!mounted) return;
      HapticFeedback.mediumImpact();
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Material(
        color: cs.surfaceContainer,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 560,
            maxHeight: MediaQuery.sizeOf(context).height * 0.92,
          ),
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + bottom),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _DragHandle(),
                const SizedBox(height: 8),
                Text(
                  l10n.subscriptionAddTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: cs.onSurface,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _bannerMessage == null
                      ? const SizedBox(height: 0)
                      : Padding(
                          key: ValueKey<String>(_bannerMessage!),
                          padding: const EdgeInsets.only(top: 12),
                          child: _buildErrorBanner(cs, _bannerMessage),
                        ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _nameCtrl,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: _fieldDecoration(
                    context,
                    label: l10n.subscriptionFieldServiceName,
                    highlightError: _highlightName,
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _priceCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: _fieldDecoration(
                    context,
                    label: l10n.subscriptionFieldAmountPerCycle(
                      appCurrencySymbol,
                    ),
                    highlightError: _highlightPrice,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.subscriptionBillingCycleLabel,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: cs.onSurfaceVariant,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                SegmentedButton<String>(
                  segments: [
                    ButtonSegment(
                      value: 'weekly',
                      label: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(l10n.subscriptionBillingWeekly),
                      ),
                      icon: Icon(Icons.calendar_view_week_rounded, size: 18),
                    ),
                    ButtonSegment(
                      value: 'monthly',
                      label: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(l10n.subscriptionBillingMonthly),
                      ),
                      icon: Icon(Icons.calendar_month_rounded, size: 18),
                    ),
                    ButtonSegment(
                      value: 'yearly',
                      label: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(l10n.subscriptionBillingYearly),
                      ),
                      icon: Icon(Icons.event_rounded, size: 18),
                    ),
                  ],
                  selected: {_billingCycle},
                  onSelectionChanged: (s) {
                    setState(() => _billingCycle = s.first);
                  },
                  style: SegmentedButton.styleFrom(
                    selectedBackgroundColor: AppTheme.primary,
                    selectedForegroundColor: Colors.white,
                    foregroundColor: cs.onSurfaceVariant,
                    side: BorderSide(color: cs.outlineVariant),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
                const SizedBox(height: 16),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: KeyedSubtree(
                    key: ValueKey<String>(_billingCycle),
                    child: _buildScheduleSection(context, cs, isDark, l10n),
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
                  child: Text(l10n.commonConfirm),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.commonCancel),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleSection(
    BuildContext context,
    ColorScheme cs,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final minYearly = _dateOnly(DateTime.now()).add(const Duration(days: 1));

    switch (_billingCycle) {
      case 'monthly':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.subscriptionBillingDayOfMonth,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: cs.onSurfaceVariant,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _monthlyDayCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(2),
              ],
              onChanged: _onMonthlyDayChanged,
              decoration: _fieldDecoration(
                context,
                label: l10n.subscriptionBillingDayField,
                highlightError: _highlightSchedule,
              ),
            ),
          ],
        );
      case 'weekly':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.subscriptionRenewalWeekday,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: cs.onSurfaceVariant,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 160,
              decoration: BoxDecoration(
                color: isDark
                    ? cs.surfaceContainerHigh
                    : const Color(0xFFF2F2F7),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _highlightSchedule ? cs.error : cs.outlineVariant,
                  width: _highlightSchedule ? 2 : 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: CupertinoTheme(
                  data: CupertinoThemeData(
                    brightness: isDark ? Brightness.dark : Brightness.light,
                    primaryColor: AppTheme.primary,
                    textTheme: CupertinoTextThemeData(
                      pickerTextStyle: TextStyle(
                        color: cs.onSurface,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  child: CupertinoPicker(
                    scrollController: _weekScrollController,
                    itemExtent: 36,
                    onSelectedItemChanged: (i) {
                      setState(() => _weeklyWeekday = i + 1);
                    },
                    children: _localizedWeekdayLabels(context)
                        .map(
                          (label) => Center(
                            child: Text(
                              label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ),
          ],
        );
      case 'yearly':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.subscriptionNextBillingDate,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: cs.onSurfaceVariant,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 216,
              decoration: BoxDecoration(
                color: isDark
                    ? cs.surfaceContainerHigh
                    : const Color(0xFFF2F2F7),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _highlightSchedule ? cs.error : cs.outlineVariant,
                  width: _highlightSchedule ? 2 : 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: CupertinoTheme(
                  data: CupertinoThemeData(
                    brightness: isDark ? Brightness.dark : Brightness.light,
                    primaryColor: AppTheme.primary,
                  ),
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: _yearlyRenewal.isBefore(minYearly)
                        ? minYearly
                        : _yearlyRenewal,
                    minimumDate: minYearly,
                    maximumDate: DateTime(DateTime.now().year + 5, 12, 31),
                    onDateTimeChanged: (d) {
                      setState(() => _yearlyRenewal = d);
                    },
                  ),
                ),
              ),
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

// ─── Add saving goal ──────────────────────────────────────────────────────────

class _AddSavingGoalSheet extends ConsumerStatefulWidget {
  const _AddSavingGoalSheet();

  @override
  ConsumerState<_AddSavingGoalSheet> createState() =>
      _AddSavingGoalSheetState();
}

class _AddSavingGoalSheetState extends ConsumerState<_AddSavingGoalSheet> {
  final _titleCtrl = TextEditingController();
  final _savedCtrl = TextEditingController();
  final _targetCtrl = TextEditingController();

  String? _bannerMessage;
  Timer? _bannerTimer;

  bool _highlightTitle = false;
  bool _highlightSaved = false;
  bool _highlightTarget = false;

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _titleCtrl.dispose();
    _savedCtrl.dispose();
    _targetCtrl.dispose();
    super.dispose();
  }

  void _clearBannerAndHighlights() {
    _bannerTimer?.cancel();
    setState(() {
      _bannerMessage = null;
      _highlightTitle = false;
      _highlightSaved = false;
      _highlightTarget = false;
    });
  }

  void _showTimedFeedback(
    String message, {
    bool title = false,
    bool saved = false,
    bool target = false,
  }) {
    _bannerTimer?.cancel();
    setState(() {
      _bannerMessage = message;
      _highlightTitle = title;
      _highlightSaved = saved;
      _highlightTarget = target;
    });
    _bannerTimer = Timer(_errorAutoDismiss, () {
      if (!mounted) return;
      setState(() {
        _bannerMessage = null;
        _highlightTitle = false;
        _highlightSaved = false;
        _highlightTarget = false;
      });
    });
  }

  Future<void> _onConfirm() async {
    _clearBannerAndHighlights();

    final l10n = AppLocalizations.of(context)!;
    final title = _titleCtrl.text.trim();
    final savedRaw = _savedCtrl.text.trim();
    final targetRaw = _targetCtrl.text.trim();
    final saved = int.tryParse(savedRaw.replaceAll(',', ''));
    final target = int.tryParse(targetRaw.replaceAll(',', ''));

    if (title.isEmpty) {
      _showTimedFeedback(l10n.savingGoalErrorEmptyName, title: true);
      return;
    }

    if (savedRaw.isEmpty || saved == null || saved < 0) {
      _showTimedFeedback(l10n.savingGoalErrorSavedAmount, saved: true);
      return;
    }

    if (targetRaw.isEmpty || target == null || target <= 0) {
      _showTimedFeedback(l10n.savingGoalErrorTargetAmount, target: true);
      return;
    }

    if (saved > target) {
      _showTimedFeedback(
        l10n.savingGoalErrorTargetVsSaved,
        saved: true,
        target: true,
      );
      return;
    }

    final id = _uuid.v4();
    final ratio = target > 0 ? (saved / target).clamp(0.0, 1.0) : 0.0;

    final model = GoalModel(
      id: id,
      title: title,
      savedAmount: saved,
      targetAmount: target,
      progress: ratio,
      emoji: GoalModel.emojiForTitle(title),
      iconBackground: GoalModel.colorForId(id),
      isPinned: false,
    );

    try {
      await ref.read(goalsProvider.notifier).addGoal(model);
      if (!mounted) return;
      HapticFeedback.mediumImpact();
      Navigator.of(context).pop();
    } on GoalsSaveException catch (e) {
      if (!mounted) return;
      final msg = switch (e.failure) {
        GoalsSaveFailure.notConnected => l10n.goalsErrorNotConnected,
        GoalsSaveFailure.notSignedIn => l10n.goalsErrorSignInRequired,
        GoalsSaveFailure.persistFailed => l10n.goalsErrorSaveFailed,
      };
      _showTimedFeedback(msg);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Material(
        color: cs.surfaceContainer,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + bottom),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _DragHandle(),
                const SizedBox(height: 8),
                Text(
                  l10n.savingGoalAddTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: cs.onSurface,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _bannerMessage == null
                      ? const SizedBox(height: 0)
                      : Padding(
                          key: ValueKey<String>(_bannerMessage!),
                          padding: const EdgeInsets.only(top: 12),
                          child: _buildErrorBanner(cs, _bannerMessage),
                        ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _titleCtrl,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: _fieldDecoration(
                    context,
                    label: l10n.savingGoalFieldName,
                    highlightError: _highlightTitle,
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _savedCtrl,
                  keyboardType: TextInputType.number,
                  decoration: _fieldDecoration(
                    context,
                    label: l10n.savingGoalFieldSavedAmount(appCurrencySymbol),
                    highlightError: _highlightSaved,
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _targetCtrl,
                  keyboardType: TextInputType.number,
                  decoration: _fieldDecoration(
                    context,
                    label: l10n.savingGoalFieldTargetAmount(appCurrencySymbol),
                    highlightError: _highlightTarget,
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
                  child: Text(l10n.commonConfirm),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.commonCancel),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Drag handle ──────────────────────────────────────────────────────────────

class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
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
    );
  }
}
