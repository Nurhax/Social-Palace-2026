import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_assets.dart';
import '../theme/app_theme.dart';

/// The SoPal shard logo. Uses assets/images/logo/sopal_mark.png when present,
/// otherwise falls back to a simple geometric drawing.
class SopalMark extends StatelessWidget {
  final double size;
  const SopalMark({super.key, this.size = 90});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: AssetImageOr(
        path: AppAssets.logoMark,
        fallback: CustomPaint(painter: _MarkPainter()),
      ),
    );
  }
}

class _MarkPainter extends CustomPainter {
  Path _star(double cx, double cy, double r, int spikes) {
    final path = Path();
    for (int i = 0; i < spikes * 2; i++) {
      final rad = i.isEven ? r : r * 0.6;
      final angle = (math.pi * 2 * i) / (spikes * 2) - math.pi / 2;
      final dx = cx + rad * math.cos(angle);
      final dy = cy + rad * math.sin(angle);
      if (i == 0) {
        path.moveTo(dx, dy);
      } else {
        path.lineTo(dx, dy);
      }
    }
    path.close();
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;

    final burst = _star(w * 0.5, h * 0.45, w * 0.62, 7);
    canvas.drawPath(burst, Paint()..color = const Color(0xFFE23B3B));
    canvas.drawPath(
      burst,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.035,
    );

    final blackDiamond = Path()
      ..moveTo(w * 0.30, h * 0.10)
      ..lineTo(w * 0.82, h * 0.22)
      ..lineTo(w * 0.62, h * 0.55)
      ..lineTo(w * 0.20, h * 0.62)
      ..close();
    canvas.drawPath(blackDiamond, Paint()..color = Colors.black);

    final whiteShard = Path()
      ..moveTo(w * 0.16, h * 0.28)
      ..lineTo(w * 0.42, h * 0.20)
      ..lineTo(w * 0.30, h * 0.62)
      ..lineTo(w * 0.08, h * 0.72)
      ..close();
    canvas.drawPath(whiteShard, Paint()..color = Colors.white);
    canvas.drawPath(
      whiteShard,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.03,
    );

    final redShard = Path()
      ..moveTo(w * 0.34, h * 0.22)
      ..lineTo(w * 0.58, h * 0.28)
      ..lineTo(w * 0.48, h * 0.68)
      ..lineTo(w * 0.26, h * 0.64)
      ..close();
    canvas.drawPath(redShard, Paint()..color = const Color(0xFFE23B3B));
    canvas.drawPath(
      redShard,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.03,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Top header bar. Pass [iconAsset] (+ [fallbackIcon]) to show a screen
/// specific icon instead of the SoPal mark, and the header automatically
/// grows by the status-bar height so nothing hides under it.
class SopalHeader extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool showFullLogo;
  final double height;
  final String? iconAsset;
  final IconData? fallbackIcon;

  const SopalHeader({
    super.key,
    this.title,
    this.showFullLogo = false,
    this.height = 150,
    this.iconAsset,
    this.fallbackIcon,
  });

  @override
  Size get preferredSize => Size.fromHeight(height);

  Widget _leading() {
    final iconSize = height * 0.62;
    if (iconAsset == null) return SopalMark(size: iconSize);
    return AssetImageOr(
      path: iconAsset!,
      height: iconSize,
      fallback: fallbackIcon != null
          ? Icon(fallbackIcon, color: Colors.white, size: iconSize * 0.7)
          : SopalMark(size: iconSize),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold reserves (preferredSize + status bar) for the app bar slot.
    final topInset = MediaQuery.of(context).padding.top;
    return Container(
      height: height + topInset,
      decoration: const BoxDecoration(
        color: Color(0xFF7A3232),
        border: Border(bottom: BorderSide(color: Colors.black, width: 4)),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            AppAssets.headerBg,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                const SizedBox.shrink(),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16, topInset, 16, 0),
            child: Row(
              children: [
                _leading(),
                const SizedBox(width: 10),
                Expanded(
                  child: showFullLogo
                      ? const ComicText('SoPal', fontSize: 46)
                      : ComicText(title ?? '', fontSize: 34),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom nav bar: Social Links / Logs / Settings.
/// Raised by the system navigation bar height, so it no longer sits under
/// the 3-button navigation (and still clears gesture navigation).
class SopalBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const SopalBottomNav(
      {super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
      ),
      padding: EdgeInsets.only(top: 10, bottom: bottomInset + 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _navItem(0, Icons.link, 'Social Links', AppAssets.navSocialLinks,
              AppAssets.navSocialLinksActive),
          _navItem(1, Icons.forum, 'Logs', AppAssets.navLogs,
              AppAssets.navLogsActive),
          _navItem(2, Icons.settings, 'Settings', AppAssets.navSettings,
              AppAssets.navSettingsActive),
        ],
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label, String asset,
      String activeAsset) {
    final active = index == currentIndex;
    final color = active ? Colors.red : Colors.black87;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 34,
              child: AssetImageOr(
                path: active ? activeAsset : asset,
                height: 34,
                fallback: Icon(icon, color: color, size: 28),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
