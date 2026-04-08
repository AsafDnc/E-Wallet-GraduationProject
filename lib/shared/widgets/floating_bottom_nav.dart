import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Global floating bottom navigation bar.
///
/// Floats over the page content via a [Positioned] widget inside a [Stack].
/// SVG assets are loaded from assets/icons/. The active tab renders its
/// *Active variant (e.g. HomeActive.svg); inactive tabs use the default file.
///
/// Extend with a [selectedIndex] parameter + callback when real tab routing
/// is wired up via Riverpod.
class FloatingBottomNav extends StatelessWidget {
  const FloatingBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onIndexChanged,
  });

  final int selectedIndex;
  final ValueChanged<int> onIndexChanged;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 24,
      right: 24,
      bottom: 24,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _SvgNavIcon(
              asset: selectedIndex == 0
                  ? 'assets/icons/HomeActive.svg'
                  : 'assets/icons/Home.svg',
              isActive: selectedIndex == 0,
              onTap: () => onIndexChanged(0),
            ),
            _SvgNavIcon(
              asset: selectedIndex == 1
                  ? 'assets/icons/ChartActive.svg'
                  : 'assets/icons/Chart.svg',
              isActive: selectedIndex == 1,
              onTap: () => onIndexChanged(1),
            ),
            _SvgNavIcon(
              asset: 'assets/icons/Add.svg',
              isActive: false,
              onTap: () => onIndexChanged(2),
            ),
            _SvgNavIcon(
              asset: selectedIndex == 3
                  ? 'assets/icons/SubsActive.svg'
                  : 'assets/icons/Subs.svg',
              isActive: selectedIndex == 3,
              onTap: () => onIndexChanged(3),
            ),
            _SvgNavIcon(
              asset: selectedIndex == 4
                  ? 'assets/icons/WalletActive.svg'
                  : 'assets/icons/Wallet.svg',
              isActive: selectedIndex == 4,
              onTap: () => onIndexChanged(4),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Individual SVG nav icon
// ---------------------------------------------------------------------------

class _SvgNavIcon extends StatelessWidget {
  const _SvgNavIcon({
    required this.asset,
    required this.isActive,
    required this.onTap,
  });

  /// Path to the SVG asset (e.g. 'assets/icons/HomeActive.svg').
  final String asset;

  /// When true the icon is rendered at full opacity; inactive icons are dimmed.
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Opacity(
        opacity: isActive ? 1.0 : 0.45,
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: SvgPicture.asset(asset, width: 32, height: 32),
        ),
      ),
    );
  }
}
