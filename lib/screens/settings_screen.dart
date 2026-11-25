import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../theme/app_assets.dart';
import '../theme/app_theme.dart';
import '../widgets/comic_shapes.dart';
import '../widgets/social_link_card.dart';
import '../widgets/sopal_chrome.dart';
import 'auth_screens.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final colors = state.colors;
    final least = state.leastFavourite;

    return Scaffold(
      backgroundColor: colors.primary,
      appBar: const SopalHeader(
        title: 'Settings',
        iconAsset: AppAssets.headerSettingsIcon,
        fallbackIcon: Icons.settings,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _row('Total Social Links :', '${state.socialLinks.length}'),
            const SizedBox(height: 22),
            _row('Total Logs :', '${state.totalLogs}'),
            const SizedBox(height: 22),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Least Favourite:',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                      fontSize: 20,
                    ),
                  ),
                ),
                if (least != null) ArcanaBadge(arcana: least.arcana, size: 64),
              ],
            ),
            const SizedBox(height: 22),
            _row('ID:', state.userId),
            const SizedBox(height: 40),
            Center(
              child: ComicButton(
                label: 'Theme',
                fontSize: 24,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ThemeSelectScreen()),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Center(
              child: ComicButton(
                label: 'LOGOUT',
                fontSize: 22,
                onTap: () {
                  state.signOut();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const EnterIdScreen()),
                    (route) => false,
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
              fontSize: 20,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
            fontSize: 22,
          ),
        ),
      ],
    );
  }
}

class ThemeSelectScreen extends StatelessWidget {
  const ThemeSelectScreen({super.key});

  String _badge(SopalPalette p) {
    switch (p) {
      case SopalPalette.p5:
        return 'P5';
      case SopalPalette.p4:
        return 'P4';
      case SopalPalette.p3:
        return 'P3';
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final colors = state.colors;

    return Scaffold(
      backgroundColor: colors.primary,
      appBar: const SopalHeader(title: 'Select\nTheme'),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: SopalPalette.values.map((p) {
                    final c = kPalettes[p]!;
                    final selected = state.palette == p;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: GestureDetector(
                        onTap: () => state.setPalette(p),
                        child: Opacity(
                          // Only the selected theme is fully highlighted.
                          opacity: selected ? 1 : 0.55,
                          child: Row(
                            children: [
                              Transform.rotate(
                                angle: selected ? -0.08 : -0.03,
                                child: Container(
                                  width: selected ? 70 : 56,
                                  height: selected ? 56 : 44,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: c.primary,
                                    border: Border.all(
                                        color: Colors.black, width: 3),
                                  ),
                                  child: Text(
                                    _badge(p),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontStyle: FontStyle.italic,
                                      fontSize: selected ? 22 : 18,
                                      color: p == SopalPalette.p4
                                          ? Colors.black
                                          : Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: SlantedBox(
                                  color: Colors.black,
                                  borderColor:
                                      selected ? Colors.white : Colors.white38,
                                  borderWidth: selected ? 4 : 2,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          c.label,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ),
                                      if (selected)
                                        const Icon(Icons.check,
                                            color: Colors.white),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              ComicButton(
                label: 'DONE',
                fontSize: 24,
                onTap: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
