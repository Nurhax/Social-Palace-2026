import 'package:flutter/material.dart';
import '../models/models.dart';

/// Central place for every asset path, so the folder structure stays neat.
///
/// assets/images/            (logo, header, nav and favourite images)
/// assets/images/arcana/     Death.png, Lovers.png, ... (capitalised names)
/// assets/audio/sfx/         select.mp3, deselect.mp3
/// assets/audio/bgm/         p5_theme.mp3
///
/// Arcana files are the glyph only (transparent background). The red tile,
/// black frame and label are drawn in code (see ArcanaBadge).
class AppAssets {
  AppAssets._();

  static const String _img = 'assets/images';

  // logo
  static const String logoMark = '$_img/Logov1.png';

  // header
  static const String headerBg = '$_img/BGSL.png';
  static const String headerLogsIcon = '$_img/LogsHeader.png';
  static const String headerSettingsIcon = '$_img/SettingsHeader.png';

  // bottom nav
  static const String navSocialLinks = '$_img/SocialLinksNavBar.png';
  static const String navSocialLinksActive =
      '$_img/SocialLinksNavBarActive.png';
  static const String navLogs = '$_img/LogsNavBar.png';
  static const String navLogsActive = '$_img/LogsNavBarActive.png';
  static const String navSettings = '$_img/SettingsNavBar.png';
  static const String navSettingsActive = '$_img/SettingsNavBarActive.png';

  // favourite star (social link row)
  static const String favouriteOff = '$_img/Favourite.png';
  static const String favouriteOn = '$_img/FavouriteActive.png';

  // arcana glyphs, e.g. "LOVERS" -> assets/images/arcana/lovers.png
  static String arcana(String name) => '$_img/arcana/${name.toLowerCase()}.png';

  static List<String> get preloadList => [
        logoMark,
        headerBg,
        headerLogsIcon,
        headerSettingsIcon,
        navSocialLinks,
        navSocialLinksActive,
        navLogs,
        navLogsActive,
        navSettings,
        navSettingsActive,
        favouriteOff,
        favouriteOn,
        ...kArcanaList.map((a) => arcana(a.name)),
      ];

  /// Decodes every image once (during the splash) so screens and transitions
  /// don't have to decode them while animating. Missing files are ignored.
  static Future<void> precacheAll(BuildContext context) async {
    await Future.wait(
      preloadList.map(
        (path) => precacheImage(AssetImage(path), context, onError: (e, s) {}),
      ),
    );
  }
}

/// Shows an asset image, or [fallback] if the file isn't in the project yet.
/// This lets the app keep running while assets are added one by one.
class AssetImageOr extends StatelessWidget {
  final String path;
  final Widget fallback;
  final double? width;
  final double? height;
  final BoxFit fit;

  const AssetImageOr({
    super.key,
    required this.path,
    required this.fallback,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      path,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => fallback,
    );
  }
}
