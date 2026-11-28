import 'package:flutter/material.dart';
import '../audio/audio_service.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_assets.dart';
import '../theme/app_theme.dart';
import '../widgets/comic_shapes.dart';
import '../widgets/persona_transitions.dart';
import '../widgets/social_link_card.dart';
import '../widgets/sopal_chrome.dart';
import 'auth_screens.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final colors = state.colors;
    final latest = state.latestLog;

    return Scaffold(
      backgroundColor: colors.primary,
      appBar: const SopalHeader(
        title: 'Settings',
        iconAsset: AppAssets.headerSettingsIcon,
        fallbackIcon: Icons.settings,
        scrollableTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _row('Total Social Links :', '${state.socialLinks.length}'),
            const SizedBox(height: 22),
            _row('Total Logs :', '${state.totalLogs}'),
            const SizedBox(height: 26),
            _linkRow('Most Favourite:', state.mostFavourite),
            const SizedBox(height: 26),
            _linkRow('Least Favourite:', state.leastFavourite),
            const SizedBox(height: 26),
            _linkRow(
              'Latest Log:',
              latest?.link,
              subtitle: latest == null
                  ? null
                  : '${latest.log.dateLabel}: ${latest.log.text}',
            ),
            const SizedBox(height: 26),
            _row('ID:', state.userId),
            const SizedBox(height: 36),
            Center(
              child: ComicButton(
                label: 'Theme',
                fontSize: 24,
                onTap: () => Navigator.of(context).push(
                  PersonaRoute<void>(builder: (_) => const ThemeSelectScreen()),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Center(
              child: ComicButton(
                label: 'LOGOUT',
                fontSize: 22,
                deselect: true,
                onTap: () {
                  AudioService.instance.stopBgm();
                  state.signOut();
                  Navigator.of(context).pushAndRemoveUntil(
                    PersonaRoute<void>(builder: (_) => const EnterIdScreen()),
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
        Expanded(child: ComicText(label, fontSize: 20, strokeWidth: 5)),
        ComicText(value, fontSize: 22, strokeWidth: 5),
      ],
    );
  }

  /// "Label:" followed by the arcana badge + the social link's name
  /// (and an optional second line, e.g. the log text).
  Widget _linkRow(String label, SocialLink? link, {String? subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ComicText(label, fontSize: 20, strokeWidth: 5),
        const SizedBox(height: 12),
        if (link == null)
          const ComicText('-', fontSize: 22, strokeWidth: 5)
        else
          Row(
            children: [
              ArcanaBadge(arcana: link.arcana, size: 56),
              const SizedBox(width: 14),
              Expanded(
                child: SlantedBox(
                  color: Colors.black,
                  borderColor: Colors.white,
                  skew: 12,
                  shadowOffset: 4,
                  padding: const EdgeInsets.fromLTRB(16, 8, 22, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        link.name,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                          fontSize: 18,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
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
                        onTap: () {
                          if (!selected) AudioService.instance.playSelect();
                          state.setPalette(p);
                        },
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
