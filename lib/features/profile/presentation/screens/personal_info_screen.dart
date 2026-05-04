import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../../providers/profile_providers.dart';

class PersonalInfoScreen extends ConsumerStatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  ConsumerState<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends ConsumerState<PersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  final _phoneCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileProvider);
    _nameCtrl = TextEditingController(text: profile.fullName);
    _emailCtrl = TextEditingController(text: profile.email);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    // Mock async save — replace with real API call.
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() => _saving = false);
    ref.read(profileProvider.notifier).updateFullName(_nameCtrl.text.trim());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.personalInfoSaved),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _confirmDeleteAccount() {
    showDialog<void>(
      context: context,
      builder: (ctx) {
        final dL10n = AppLocalizations.of(ctx)!;
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            dL10n.personalInfoDeleteQuestionTitle,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Theme.of(ctx).colorScheme.onSurface,
            ),
          ),
          content: Text(
            dL10n.personalInfoDeleteQuestionBody,
            style: TextStyle(
              color: Theme.of(ctx).colorScheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(dL10n.commonCancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    behavior: SnackBarBehavior.floating,
                    content: Text(dL10n.personalInfoDeletionRequested),
                    backgroundColor: const Color(0xFFB85C6A),
                    duration: const Duration(seconds: 3),
                  ),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFB85C6A),
              ),
              child: Text(dL10n.commonDelete),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(
          l10n.personalInfoTitle,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : TextButton(
                    onPressed: _saveChanges,
                    child: Text(
                      l10n.commonSave,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
          children: [
            // ── Avatar section ─────────────────────────────────────────
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 52,
                      backgroundColor: cs.primaryContainer,
                      child: Icon(
                        Icons.person_rounded,
                        size: 52,
                        color: cs.onPrimaryContainer,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.photoPickerSoon),
                            duration: const Duration(seconds: 2),
                          ),
                        ),
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: cs.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: cs.surface, width: 2.5),
                          ),
                          child: Icon(
                            Icons.edit_rounded,
                            size: 16,
                            color: cs.onPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Fields ────────────────────────────────────────────────
            _FieldLabel(label: l10n.fieldFullName, cs: cs),
            _FormField(
              controller: _nameCtrl,
              hint: l10n.hintFullNameExample,
              prefixIcon: Icons.person_outline_rounded,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? l10n.fieldRequired : null,
            ),
            const SizedBox(height: 16),

            _FieldLabel(label: l10n.fieldEmailAddress, cs: cs),
            _FormField(
              controller: _emailCtrl,
              hint: l10n.hintEmailPersonal,
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return l10n.fieldRequired;
                if (!v.contains('@')) {
                  return l10n.validationEnterValidEmailShort;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            _FieldLabel(label: l10n.fieldPhoneNumber, cs: cs),
            _FormField(
              controller: _phoneCtrl,
              hint: l10n.hintPhoneExample,
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),

            _FieldLabel(label: l10n.fieldLocationAddress, cs: cs),
            _FormField(
              controller: _locationCtrl,
              hint: l10n.hintLocationExample,
              prefixIcon: Icons.location_on_outlined,
              maxLines: 2,
            ),

            // ── Account removal (minimal, soft accent) ─────────────────────
            const SizedBox(height: 40),
            Text(
              l10n.personalInfoDeleteWarningFooter,
              style: tt.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
                height: 1.45,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: _confirmDeleteAccount,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFB85C6A),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 8,
                  ),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  l10n.personalInfoDeleteAccountButton,
                  style: tt.titleSmall?.copyWith(
                    color: const Color(0xFFB85C6A),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
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

// ─── Reusable sub-widgets ─────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label, required this.cs});

  final String label;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: TextStyle(
          color: cs.onSurfaceVariant,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  const _FormField({
    required this.controller,
    required this.hint,
    required this.prefixIcon,
    this.keyboardType,
    this.maxLines = 1,
    this.validator,
  });

  final TextEditingController controller;
  final String hint;
  final IconData prefixIcon;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: cs.onSurfaceVariant.withValues(alpha: 0.5)),
        prefixIcon: Icon(prefixIcon, size: 20, color: cs.onSurfaceVariant),
        filled: true,
        fillColor: cs.surfaceContainerHighest,
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
          borderSide: BorderSide(color: cs.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: cs.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: cs.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}
