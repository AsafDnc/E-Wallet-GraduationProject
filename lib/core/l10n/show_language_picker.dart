import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/locale_provider.dart';
import '../../features/profile/providers/profile_providers.dart';
import '../../l10n/app_localizations.dart';

/// iOS-style wheel to pick English or Türkçe; applies instantly via [appLocaleProvider].
void showCupertinoLanguagePicker({
  required BuildContext context,
  required WidgetRef ref,
}) {
  final l10n = AppLocalizations.of(context)!;
  showCupertinoModalPopup<void>(
    context: context,
    builder: (ctx) => _LanguagePickerSheet(parentRef: ref, l10n: l10n),
  );
}

class _LanguagePickerSheet extends StatefulWidget {
  const _LanguagePickerSheet({required this.parentRef, required this.l10n});

  final WidgetRef parentRef;
  final AppLocalizations l10n;

  @override
  State<_LanguagePickerSheet> createState() => _LanguagePickerSheetState();
}

class _LanguagePickerSheetState extends State<_LanguagePickerSheet> {
  late final FixedExtentScrollController _scrollController;
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    final code = widget.parentRef.read(appLocaleProvider).languageCode;
    _selectedIndex = code == 'tr' ? 1 : 0;
    _scrollController = FixedExtentScrollController(
      initialItem: _selectedIndex,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _applyAndClose(BuildContext modalContext) {
    final next = _selectedIndex == 1 ? const Locale('tr') : const Locale('en');
    widget.parentRef.read(appLocaleProvider.notifier).setLocale(next);
    widget.parentRef
        .read(profileProvider.notifier)
        .updateLanguage(
          _selectedIndex == 1
              ? widget.l10n.languageTurkish
              : widget.l10n.languageEnglish,
        );
    Navigator.of(modalContext).pop();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bottom = MediaQuery.paddingOf(context).bottom;
    final l10n = widget.l10n;

    return Material(
      type: MaterialType.transparency,
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: cs.shadow.withValues(alpha: 0.2),
              blurRadius: 24,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: cs.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 56),
                    Expanded(
                      child: Text(
                        l10n.languagePickerTitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: cs.onSurfaceVariant,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    CupertinoButton(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      onPressed: () => _applyAndClose(context),
                      child: Text(
                        l10n.commonDone,
                        style: TextStyle(
                          color: cs.primary,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 216,
                child: CupertinoTheme(
                  data: CupertinoThemeData(
                    brightness: Theme.of(context).brightness,
                    primaryColor: cs.primary,
                  ),
                  child: CupertinoPicker(
                    scrollController: _scrollController,
                    itemExtent: 40,
                    magnification: 1.05,
                    squeeze: 1.05,
                    useMagnifier: true,
                    onSelectedItemChanged: (int i) {
                      setState(() => _selectedIndex = i);
                    },
                    children: [
                      Center(child: Text(l10n.languageEnglish)),
                      Center(child: Text(l10n.languageTurkish)),
                    ],
                  ),
                ),
              ),
              SizedBox(height: bottom),
            ],
          ),
        ),
      ),
    );
  }
}
