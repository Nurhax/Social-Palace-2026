import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_assets.dart';
import '../widgets/comic_shapes.dart';

/// Red tile + black frame + label drawn in code; the glyph inside comes from
/// assets/images/arcana/<name>.png (falls back to a Material icon).
class ArcanaBadge extends StatelessWidget {
  final Arcana arcana;
  final double size;
  final bool showLabel;

  const ArcanaBadge(
      {super.key, required this.arcana, this.size = 74, this.showLabel = true});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Transform.rotate(
            angle: -0.05,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFF0401),
                border: Border.all(color: Colors.black, width: 4),
              ),
              alignment: Alignment.center,
              child: AssetImageOr(
                path: AppAssets.arcana(arcana.name),
                width: size * 0.62,
                height: size * 0.62,
                fallback:
                    Icon(arcana.icon, color: Colors.white, size: size * 0.5),
              ),
            ),
          ),
          if (showLabel)
            Positioned(
              bottom: -6,
              left: -4,
              right: -4,
              child: Text(
                arcana.name,
                textAlign: TextAlign.center,
                overflow: TextOverflow.clip,
                softWrap: false,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                  color: Colors.white,
                  shadows: [Shadow(color: Colors.black, offset: Offset(1, 1))],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

const double _levelBoxWidth = 32;

/// A row from the main "Social Links" list: arcana badge, name ribbon with
/// level progress bar, favourite star (tap to toggle), level number, and
/// stacked +/- exp buttons. Tapping the name opens the details.
class SocialLinkRow extends StatelessWidget {
  final SocialLink link;
  final VoidCallback onOpen;
  final VoidCallback onAddExp;
  final VoidCallback onRemoveExp;
  final VoidCallback onToggleFavourite;

  const SocialLinkRow({
    super.key,
    required this.link,
    required this.onOpen,
    required this.onAddExp,
    required this.onRemoveExp,
    required this.onToggleFavourite,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ArcanaBadge(arcana: link.arcana),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: onOpen,
              child: Stack(
                children: [
                  // Banner, pushed down so the star can sit above it.
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: SlantedBox(
                      color: Colors.black,
                      borderColor: Colors.white,
                      skew: 14,
                      shadowOffset: 4,
                      padding: const EdgeInsets.fromLTRB(20, 16, 22, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // right padding keeps long names clear of the star
                          Padding(
                            padding: const EdgeInsets.only(right: 40),
                            child: Text(
                              link.name,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
                                fontSize: 20,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(2),
                                  child: LinearProgressIndicator(
                                    value: link.exp / 10,
                                    minHeight: 10,
                                    backgroundColor: Colors.white24,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // fixed width so the star can be centred on it
                              Container(
                                width: _levelBoxWidth,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 1),
                                alignment: Alignment.center,
                                color: Colors.white,
                                child: Text(
                                  '${link.level}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FontStyle.italic,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Favourite star, exactly above the level box.
                  // Level box centre = 3 (border) + 22 (padding) + width / 2
                  // from the banner's right edge; the star box is 40 wide.
                  Positioned(
                    top: 0,
                    right: 3 + 22 + _levelBoxWidth / 2 - 20,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onToggleFavourite,
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: Center(
                          child: AssetImageOr(
                            path: link.favourite
                                ? AppAssets.favouriteOn
                                : AppAssets.favouriteOff,
                            width: 32,
                            height: 32,
                            fallback: Icon(
                              link.favourite ? Icons.star : Icons.star_border,
                              color: link.favourite ? Colors.red : Colors.white,
                              size: 30,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 6),
          Column(
            children: [
              _smallSquareButton(icon: Icons.add, onTap: onAddExp),
              const SizedBox(height: 6),
              _smallSquareButton(icon: Icons.remove, onTap: onRemoveExp),
            ],
          ),
        ],
      ),
    );
  }

  Widget _smallSquareButton(
      {required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Transform.rotate(
        angle: -0.08,
        child: Container(
          width: 34,
          height: 30,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black, width: 3),
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 18, color: Colors.black),
        ),
      ),
    );
  }
}
