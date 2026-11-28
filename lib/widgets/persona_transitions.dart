import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';

enum _Tone { white, black, primary, primaryDark }

/// One coloured stripe that leads the reveal edge.
/// [start] / [width] are fractions of the screen width ahead of the edge.
class _Band {
  final double start;
  final double width;
  final _Tone tone;
  const _Band(this.start, this.width, this.tone);
}

/// Look of a wipe: duration, easing, slant of the diagonal and the stripes.
class PersonaWipeStyle {
  final Duration duration;
  final Curve curve;
  final double slant; // diagonal skew as a fraction of the screen height
  final List<_Band> bands;

  const PersonaWipeStyle._({
    required this.duration,
    required this.curve,
    required this.slant,
    required this.bands,
  });

  /// Quick wipe for menus, screens and tabs.
  static const PersonaWipeStyle menu = PersonaWipeStyle._(
    duration: Duration(milliseconds: 420),
    curve: Curves.easeInOutCubic,
    slant: 0.22,
    bands: [
      _Band(0.00, 0.025, _Tone.white),
      _Band(0.025, 0.20, _Tone.black),
      _Band(0.225, 0.07, _Tone.primaryDark),
    ],
  );

  /// Longer, bolder wipe for the opening sequence and login.
  static const PersonaWipeStyle opening = PersonaWipeStyle._(
    duration: Duration(milliseconds: 900),
    curve: Curves.easeInOutQuart,
    slant: 0.30,
    bands: [
      _Band(0.00, 0.03, _Tone.white),
      _Band(0.03, 0.10, _Tone.primary),
      _Band(0.13, 0.32, _Tone.black),
      _Band(0.45, 0.03, _Tone.white),
      _Band(0.48, 0.12, _Tone.primaryDark),
    ],
  );

  double get lead {
    var m = 0.0;
    for (final b in bands) {
      m = math.max(m, b.start + b.width);
    }
    return m;
  }

  /// X position (at the vertical middle) of the reveal edge for progress [t].
  /// At t = 0 the stripes are fully off-screen on the left, at t = 1 they've
  /// fully left on the right.
  double edgeX(double t, double w, double s) {
    final start = -(lead * w + s);
    final end = w + s;
    return start + (end - start) * t;
  }
}

Color _toneColor(_Tone tone, SopalColors c) {
  switch (tone) {
    case _Tone.white:
      return Colors.white;
    case _Tone.black:
      return Colors.black;
    case _Tone.primary:
      return c.primary;
    case _Tone.primaryDark:
      return c.primaryDark;
  }
}

/// Reveals [child] with a slanted, striped wipe driven by [animation]
/// (0 -> 1 forward, 1 -> 0 on pop). Used by [PersonaRoute] and by the tab
/// switcher. Only the clip and the stripes change per frame; [child] is
/// built once and reused.
class PersonaWipe extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;
  final PersonaWipeStyle style;
  final bool fromRight;

  const PersonaWipe({
    super.key,
    required this.animation,
    required this.child,
    this.style = PersonaWipeStyle.menu,
    this.fromRight = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppScope.of(context).colors;
    final eased = animation.drive(CurveTween(curve: style.curve));
    return AnimatedBuilder(
      animation: eased,
      child: child,
      builder: (context, child) {
        final t = eased.value;
        final clipping = t < 1.0;
        // Keep the widget structure constant so the page's State survives.
        return Stack(
          fit: StackFit.expand,
          children: [
            ClipPath(
              clipper: _RevealClipper(t, style, fromRight),
              clipBehavior: clipping ? Clip.hardEdge : Clip.none,
              child: child,
            ),
            (t > 0.0 && t < 1.0)
                ? IgnorePointer(
                    child: CustomPaint(
                      painter: _BandsPainter(t, style, fromRight, colors),
                    ),
                  )
                : const SizedBox.shrink(),
          ],
        );
      },
    );
  }
}

class _RevealClipper extends CustomClipper<Path> {
  final double t;
  final PersonaWipeStyle style;
  final bool fromRight;

  const _RevealClipper(this.t, this.style, this.fromRight);

  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    final s = h * style.slant;
    final x = style.edgeX(t, w, s);
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(x + s, 0)
      ..lineTo(x - s, h)
      ..lineTo(0, h)
      ..close();
    if (!fromRight) return path;
    // Mirror horizontally (wipe from the right edge).
    final mirror = Float64List.fromList(<double>[
      -1, 0, 0, 0, //
      0, 1, 0, 0, //
      0, 0, 1, 0, //
      w, 0, 0, 1, //
    ]);
    return path.transform(mirror);
  }

  @override
  bool shouldReclip(covariant _RevealClipper oldClipper) =>
      oldClipper.t != t || oldClipper.fromRight != fromRight;
}

class _BandsPainter extends CustomPainter {
  final double t;
  final PersonaWipeStyle style;
  final bool fromRight;
  final SopalColors colors;

  const _BandsPainter(this.t, this.style, this.fromRight, this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final s = h * style.slant;
    final x = style.edgeX(t, w, s);

    if (fromRight) {
      canvas.translate(w, 0);
      canvas.scale(-1, 1);
    }

    final paint = Paint()..isAntiAlias = true;
    for (final b in style.bands) {
      final x0 = x + b.start * w;
      final x1 = x0 + b.width * w;
      final path = Path()
        ..moveTo(x0 + s, 0)
        ..lineTo(x1 + s, 0)
        ..lineTo(x1 - s, h)
        ..lineTo(x0 - s, h)
        ..close();
      paint.color = _toneColor(b.tone, colors);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BandsPainter oldDelegate) =>
      oldDelegate.t != t ||
      oldDelegate.fromRight != fromRight ||
      oldDelegate.style != style ||
      oldDelegate.colors != colors;
}

/// Drop-in replacement for MaterialPageRoute with the Persona wipe.
///
///   Navigator.of(context).push(PersonaRoute<void>(builder: (_) => const Page()));
class PersonaRoute<T> extends PageRouteBuilder<T> {
  PersonaRoute({
    required WidgetBuilder builder,
    PersonaWipeStyle style = PersonaWipeStyle.menu,
    bool fromRight = false,
  }) : super(
          transitionDuration: style.duration,
          reverseTransitionDuration: style.duration * 0.85,
          pageBuilder: (context, animation, secondaryAnimation) =>
              builder(context),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              PersonaWipe(
            animation: animation,
            style: style,
            fromRight: fromRight,
            child: child,
          ),
        );
}
