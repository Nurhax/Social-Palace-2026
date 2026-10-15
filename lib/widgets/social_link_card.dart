import 'package:flutter/material.dart';
import '../models/models.dart';
import '../widgets/comic_shapes.dart';

/// Red/black icon box for an Arcana, matching the small icon tiles in the
/// mockup (e.g. the heart for LOVERS, the shrouded figure for HERMIT).
class ArcanaBadge extends StatelessWidget {
  final Arcana arcana;
  final double size;
  final bool showLabel;

  const ArcanaBadge({super.key, required this.arcana, this.size = 74, this.showLabel = true});

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
                color: const Color(0xFFE23B3B),
                border: Border.all(color: Colors.black, width: 4),
              ),
              alignment: Alignment.center,
              child: Icon(arcana.icon, color: Colors.white, size: size * 0.5),
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

/// A row from the main "Social Links" list: arcana badge, name ribbon with
/// level progress bar, favourite star, level number, checkmark (view), and
/// stacked +/- exp buttons — mirroring "Main Screen.jpg" / "Add EXP.jpg".
class SocialLinkRow extends StatelessWidget {
  final SocialLink link;
  final VoidCallback onOpen;
  final VoidCallback onAddExp;
  final VoidCallback onRemoveExp;

  const SocialLinkRow({
    super.key,
    required this.link,
    required this.onOpen,
    required this.onAddExp,
    required this.onRemoveExp,
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
              child: SlantedBox(
                color: Colors.black,
                borderColor: Colors.white,
                skew: 14,
                shadowOffset: 4,
                padding: const EdgeInsets.fromLTRB(18, 10, 34, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            link.name,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        Icon(
                          link.favourite ? Icons.star : Icons.star_border,
                          color: Colors.red,
                          size: 22,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                              value: link.exp / 10,
                              minHeight: 8,
                              backgroundColor: Colors.white24,
                              color: Colors.red,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
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

  Widget _smallSquareButton({required IconData icon, required VoidCallback onTap}) {
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
