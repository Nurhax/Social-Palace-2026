import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../audio/audio_service.dart';

/// A slanted parallelogram with one corner "folded", used for the black
/// name ribbons, text fields, and rectangular buttons (ENTER / ADD / DONE)
/// throughout the mockup.
class ParallelogramClipper extends CustomClipper<Path> {
  final double skew;
  final double foldCorner;

  const ParallelogramClipper({this.skew = 18, this.foldCorner = 0});

  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(skew, 0);
    if (foldCorner > 0) {
      path.lineTo(size.width - foldCorner, 0);
      path.lineTo(size.width, foldCorner);
    } else {
      path.lineTo(size.width, 0);
    }
    path.lineTo(size.width - skew, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

/// Parallelogram outline shared by the fill, the border and the shadow.
Path _slantedPath(Size size, double skew, double foldCorner,
    {double inset = 0}) {
  final w = size.width;
  final h = size.height;
  final i = inset;
  final path = Path()..moveTo(skew + i, i);
  if (foldCorner > 0) {
    path.lineTo(w - foldCorner - i, i);
    path.lineTo(w - i, foldCorner + i);
  } else {
    path.lineTo(w - i, i);
  }
  path.lineTo(w - skew - i, h - i);
  path.lineTo(i, h - i);
  path.close();
  return path;
}

/// Draws the black drop shadow, the fill and a border that follows the whole
/// slanted outline (so the border is never cut off at the corners).
class _SlantedBoxPainter extends CustomPainter {
  final Color color;
  final Color borderColor;
  final double borderWidth;
  final double skew;
  final double foldCorner;
  final double shadowOffset;

  const _SlantedBoxPainter({
    required this.color,
    required this.borderColor,
    required this.borderWidth,
    required this.skew,
    required this.foldCorner,
    required this.shadowOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final outer = _slantedPath(size, skew, foldCorner);

    canvas.drawPath(
      outer.shift(Offset(shadowOffset, shadowOffset)),
      Paint()..color = Colors.black,
    );
    canvas.drawPath(outer, Paint()..color = color);

    if (borderWidth > 0) {
      canvas.drawPath(
        _slantedPath(size, skew, foldCorner, inset: borderWidth / 2),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = borderWidth
          ..strokeJoin = StrokeJoin.miter
          ..color = borderColor,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SlantedBoxPainter old) =>
      old.color != color ||
      old.borderColor != borderColor ||
      old.borderWidth != borderWidth ||
      old.skew != skew ||
      old.foldCorner != foldCorner ||
      old.shadowOffset != shadowOffset;
}

/// A slanted card with a black drop shadow and an outline that wraps the
/// whole shape, like the mockup's ribbons. It sizes itself to [child] (or
/// fills the width it is given).
class SlantedBox extends StatelessWidget {
  final Widget child;
  final Color color;
  final Color borderColor;
  final double skew;
  final double foldCorner;
  final EdgeInsets padding;
  final double borderWidth;
  final double shadowOffset;

  const SlantedBox({
    super.key,
    required this.child,
    this.color = Colors.black,
    this.borderColor = Colors.white,
    this.skew = 18,
    this.foldCorner = 0,
    this.padding = const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
    this.borderWidth = 3,
    this.shadowOffset = 5,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SlantedBoxPainter(
        color: color,
        borderColor: borderColor,
        borderWidth: borderWidth,
        skew: skew,
        foldCorner: foldCorner,
        shadowOffset: shadowOffset,
      ),
      // the border sits inside the padding, like a Container border would
      child: Padding(
        padding: padding + EdgeInsets.all(borderWidth),
        child: child,
      ),
    );
  }
}

/// Generates a jagged "explosion" polygon, used for the BACK button and
/// popup confirmation bubbles in the mockup.
class BurstClipper extends CustomClipper<Path> {
  final int spikes;
  final double innerRadiusFactor;
  final double seed;

  const BurstClipper(
      {this.spikes = 12, this.innerRadiusFactor = 0.78, this.seed = 0});

  @override
  Path getClip(Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final outerRx = size.width / 2;
    final outerRy = size.height / 2;
    final path = Path();
    final points = spikes * 2;
    for (int i = 0; i < points; i++) {
      final isOuter = i.isEven;
      final wobble = 1 + 0.06 * math.sin(i * 12.9898 + seed);
      final rx = (isOuter ? outerRx : outerRx * innerRadiusFactor) * wobble;
      final ry = (isOuter ? outerRy : outerRy * innerRadiusFactor) * wobble;
      final angle = (math.pi * 2 * i) / points - math.pi / 2;
      final x = cx + rx * math.cos(angle);
      final y = cy + ry * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class BurstBox extends StatelessWidget {
  final Widget child;
  final Color color;
  final Color borderColor;
  final double borderWidth;
  final int spikes;

  const BurstBox({
    super.key,
    required this.child,
    this.color = Colors.white,
    this.borderColor = Colors.black,
    this.borderWidth = 4,
    this.spikes = 14,
  });

  @override
  Widget build(BuildContext context) {
    final clipper = BurstClipper(spikes: spikes);
    return ClipPath(
      clipper: clipper,
      child: Container(
        decoration: BoxDecoration(color: borderColor),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: ClipPath(
            clipper: BurstClipper(spikes: spikes, innerRadiusFactor: 0.75),
            child: Container(
              color: color,
              alignment: Alignment.center,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// A tappable slanted button (used for ENTER / ADD / DONE / +).
class ComicButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final Color color;
  final Color textColor;
  final double fontSize;
  final IconData? icon;

  /// true -> plays the "deselect" sound (e.g. BACK) instead of "select".
  final bool deselect;

  const ComicButton({
    super.key,
    required this.label,
    this.onTap,
    this.color = Colors.white,
    this.textColor = Colors.black,
    this.fontSize = 22,
    this.icon,
    this.deselect = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap == null
          ? null
          : () {
              if (deselect) {
                AudioService.instance.playDeselect();
              } else {
                AudioService.instance.playSelect();
              }
              onTap!();
            },
      child: SlantedBox(
        color: color,
        borderColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        child: Center(
          child: icon != null
              ? Icon(icon, color: textColor, size: fontSize + 4)
              : Text(
                  label,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                    fontSize: fontSize,
                  ),
                ),
        ),
      ),
    );
  }
}

/// Slanted text input field mimicking "Enter here..." fields.
class ComicTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final int maxLines;

  const ComicTextField({
    super.key,
    required this.controller,
    this.hint = 'Enter here...',
    this.keyboardType,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return SlantedBox(
      color: Colors.black,
      borderColor: Colors.white,
      shadowOffset: 4,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: const TextStyle(
          color: Colors.white,
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: const TextStyle(
            color: Colors.white70,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
