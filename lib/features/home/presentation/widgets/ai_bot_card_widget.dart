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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1C20),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.07),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // AI avatar
          const _AiAvatar(),
          const SizedBox(width: 14),
          // Text content
          const Expanded(child: _AiTextContent()),
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
  const _AiTextContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'AI Bot',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 5),
        Text(
          AiBotCardWidget._description,
          style: TextStyle(color: Colors.white54, fontSize: 13, height: 1.45),
        ),
      ],
    );
  }
}
