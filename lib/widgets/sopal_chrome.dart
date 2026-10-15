import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A simplified geometric approximation of the jagged red/black/white SoPal
/// shard logo seen on the splash and header screens.
class SopalMark extends StatelessWidget {
  final double size;
  const SopalMark({super.key, this.size = 90});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _MarkPainter()),
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

/// Top header bar with the SoPal mark + a title, used across most screens.
class SopalHeader extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool showFullLogo;
  final double height;

  const SopalHeader({
    super.key,
    this.title,
    this.showFullLogo = false,
    this.height = 150,
  });

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: const BoxDecoration(
        color: Color(0xFF7A3232),
        border: Border(bottom: BorderSide(color: Colors.black, width: 4)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          SopalMark(size: height * 0.62),
          const SizedBox(width: 10),
          Expanded(
            child: showFullLogo
                ? const ComicText('SoPal', fontSize: 46)
                : ComicText(title ?? '', fontSize: 34),
          ),
        ],
      ),
    );
  }
}

/// Bottom nav bar: Social Links / Logs / Settings, matching the rounded
/// white bar fixed at the bottom of the mockup.
class SopalBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const SopalBottomNav({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
      ),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _navItem(0, Icons.link, 'Social Links'),
          _navItem(1, Icons.forum, 'Logs'),
          _navItem(2, Icons.settings, 'Settings'),
        ],
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
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
            Icon(icon, color: color, size: 28),
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
