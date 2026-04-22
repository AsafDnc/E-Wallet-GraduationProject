import 'package:flutter/material.dart';

/// A promotional card that surfaces an AI spending insight to the user.
///
/// The content is intentionally kept static for now; replace with a
/// Riverpod provider once a real AI recommendation feed is available.
class AiBotCardWidget extends StatelessWidget {
  const AiBotCardWidget({super.key});

  static const _description =
      'Paying for YouTube and Spotify? Save \$70 per month by consolidating '
      'your music habits on a single platform.';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant, width: 1),
        boxShadow: Theme.of(context).brightness == Brightness.light
            ? const [
                BoxShadow(
                  color: Color(0x12222B33),
                  blurRadius: 20,
                  offset: Offset(0, 4),
                ),
              ]
            : const [],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const _AiAvatar(),
          const SizedBox(width: 14),
          Expanded(child: _AiTextContent(cs: cs)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _AiAvatar extends StatelessWidget {
  const _AiAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF3B3C8F)],
        ),
      ),
      child: const Icon(
        Icons.auto_awesome_rounded,
        color: Colors.white,
        size: 26,
      ),
    );
  }
}

class _AiTextContent extends StatelessWidget {
  const _AiTextContent({required this.cs});

  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AI Bot',
          style: TextStyle(
            color: cs.onSurface,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          AiBotCardWidget._description,
          style: TextStyle(
            color: cs.onSurfaceVariant,
            fontSize: 13,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}
