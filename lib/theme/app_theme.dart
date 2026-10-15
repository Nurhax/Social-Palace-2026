import 'package:flutter/material.dart';

/// Persona-style palettes. Users can switch these from Settings > Theme,
/// mirroring the "Select Theme" screen in the Figma mockup (P5 / P4 / P3).
enum SopalPalette { p5, p5Alt, p4, p3 }

class SopalColors {
  final Color primary; // main background red/yellow/blue
  final Color primaryDark;
  final Color accent; // small accent, e.g. star / highlight
  final String label;

  const SopalColors({
    required this.primary,
    required this.primaryDark,
    required this.accent,
    required this.label,
  });
}

const Map<SopalPalette, SopalColors> kPalettes = {
  SopalPalette.p5: SopalColors(
    primary: Color(0xFFCE3233),
    primaryDark: Color(0xFF8C1F20),
    accent: Color(0xFFE94141),
    label: 'Persona 5',
  ),
  SopalPalette.p5Alt: SopalColors(
    primary: Color(0xFFB6272A),
    primaryDark: Color(0xFF6E1517),
    accent: Color(0xFFFFFFFF),
    label: 'Persona 5',
  ),
  SopalPalette.p4: SopalColors(
    primary: Color(0xFFF2C300),
    primaryDark: Color(0xFF9C7E00),
    accent: Color(0xFF222222),
    label: 'Persona 4',
  ),
  SopalPalette.p3: SopalColors(
    primary: Color(0xFF1E3E8C),
    primaryDark: Color(0xFF10234F),
    accent: Color(0xFF4C6FCB),
    label: 'Persona 3',
  ),
};

/// A bold italic "outlined" comic-book style text: white fill with a thick
/// black stroke behind it, matching the SoPal logo / headers in the mockup.
class ComicText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color fillColor;
  final Color strokeColor;
  final double strokeWidth;
  final TextAlign textAlign;
  final double letterSpacing;
  final FontStyle fontStyle;

  const ComicText(
    this.text, {
    super.key,
    this.fontSize = 32,
    this.fillColor = Colors.white,
    this.strokeColor = Colors.black,
    this.strokeWidth = 6,
    this.textAlign = TextAlign.left,
    this.letterSpacing = 0.5,
    this.fontStyle = FontStyle.italic,
  });

  TextStyle _base() => TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w900,
        fontStyle: fontStyle,
        letterSpacing: letterSpacing,
        height: 1.0,
      );

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Text(
          text,
          textAlign: textAlign,
          style: _base().copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = strokeWidth
              ..strokeJoin = StrokeJoin.round
              ..color = strokeColor,
          ),
        ),
        Text(
          text,
          textAlign: textAlign,
          style: _base().copyWith(color: fillColor),
        ),
      ],
    );
  }
}

/// Standard drop-shadow used under most comic shapes to give them the
/// "layered paper" depth seen throughout the mockup.
List<BoxShadow> comicShadow({Color color = Colors.black, double offset = 6}) {
  return [
    BoxShadow(
      color: color,
      offset: Offset(offset, offset),
      blurRadius: 0,
    ),
  ];
}
