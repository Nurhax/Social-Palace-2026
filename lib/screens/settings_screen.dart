import 'package:flutter/material.dart';
import '../state/app_state.dart';
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
      appBar: const SopalHeader(title: 'Settings'),
      body: Padding(
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
            const Spacer(),
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
                  state.setId('');
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

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final colors = state.colors;

    return Scaffold(
      backgroundColor: colors.primary,
      appBar: const SopalHeader(title: 'Select\nTheme'),
      body: Padding(
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
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 46,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: c.primary,
                              border: Border.all(color: Colors.black, width: 3),
                            ),
                            child: Text(
                              p == SopalPalette.p4
                                  ? 'P4'
                                  : p == SopalPalette.p3
                                      ? 'P3'
                                      : 'P5',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontStyle: FontStyle.italic,
                                color: p == SopalPalette.p4 ? Colors.black : Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: SlantedBox(
                              color: Colors.black,
                              borderColor: selected ? Colors.amber : Colors.white,
                              child: Text(
                                c.label,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            ComicButton(label: 'DONE', fontSize: 24, onTap: () => Navigator.of(context).pop()),
          ],
        ),
      ),
    );
  }
}
