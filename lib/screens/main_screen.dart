import 'package:flutter/material.dart';
import '../audio/audio_service.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../widgets/comic_shapes.dart';
import '../widgets/persona_transitions.dart';
import '../widgets/social_link_card.dart';
import '../widgets/sopal_chrome.dart';
import 'logs_screen.dart';
import 'settings_screen.dart';
import 'social_link_detail_screen.dart';
import 'add_social_link_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _tab = 0;
  bool _fromRight = false; // wipe direction follows the tab order

  static const List<Widget> _pages = [
    _SocialLinksPage(),
    LogsScreen(),
    SettingsScreen(),
  ];

  void _onTab(int i) {
    if (i == _tab) return;
    AudioService.instance.playSelect();
    setState(() {
      _fromRight = i < _tab;
      _tab = i;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppScope.of(context).colors;
    final currentKey = ValueKey<int>(_tab);
    return Scaffold(
      // Same colour as the pages, so the transparent nav bar blends in.
      backgroundColor: colors.primary,
      body: AnimatedSwitcher(
        duration: PersonaWipeStyle.menu.duration,
        layoutBuilder: (current, previous) => Stack(
          fit: StackFit.expand,
          children: [...previous, if (current != null) current],
        ),
        transitionBuilder: (child, animation) {
          // Outgoing page stays still underneath; only the new page wipes in.
          if (child.key != currentKey) return child;
          return PersonaWipe(
            animation: animation,
            style: PersonaWipeStyle.menu,
            fromRight: _fromRight,
            child: child,
          );
        },
        child: KeyedSubtree(key: currentKey, child: _pages[_tab]),
      ),
      bottomNavigationBar: SopalBottomNav(
        currentIndex: _tab,
        onTap: _onTab,
      ),
    );
  }
}

class _SocialLinksPage extends StatelessWidget {
  const _SocialLinksPage();

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final colors = state.colors;
    return Scaffold(
      backgroundColor: colors.primary,
      appBar: const SopalHeader(showFullLogo: true),
      body: ListView.builder(
        padding: const EdgeInsets.only(top: 12, bottom: 12),
        itemCount: state.socialLinks.length + 1,
        itemBuilder: (context, index) {
          if (index == state.socialLinks.length) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: ComicButton(
                label: '+',
                fontSize: 28,
                onTap: () async {
                  final result = await Navigator.of(context).push(
                    PersonaRoute<SocialLink>(
                      builder: (_) => const AddSocialLinkScreen(),
                    ),
                  );
                  if (result != null) {
                    state.addSocialLink(result);
                    if (context.mounted) {
                      _showPopup(context, 'New Social\nLink Added!');
                    }
                  }
                },
              ),
            );
          }
          final link = state.socialLinks[index];
          return SocialLinkRow(
            link: link,
            onOpen: () {
              AudioService.instance.playSelect();
              Navigator.of(context).push(
                PersonaRoute<void>(
                  builder: (_) => SocialLinkDetailScreen(link: link),
                ),
              );
            },
            onAddExp: () {
              AudioService.instance.playSelect();
              final before = link.level;
              state.addExp(link, 1);
              if (link.level > before) {
                _showPopup(
                  context,
                  '${_short(link.name)}\nLevel Up!\nLv. ${link.level}',
                );
              }
            },
            onRemoveExp: () {
              AudioService.instance.playDeselect();
              final before = link.level;
              state.addExp(link, -1);
              if (link.level < before) {
                _showPopup(
                  context,
                  '${_short(link.name)}\nLevel Down!\nLv. ${link.level}',
                );
              }
            },
            onToggleFavourite: () {
              // turning the star on = select, turning it off = deselect
              if (link.favourite) {
                AudioService.instance.playDeselect();
              } else {
                AudioService.instance.playSelect();
              }
              state.toggleFavourite(link);
            },
          );
        },
      ),
    );
  }
}

/// Keeps long names from overflowing the burst popup.
String _short(String name) =>
    name.length > 14 ? '${name.substring(0, 13)}…' : name;

/// The burst popup used for "New Social Link Added!" and level up / down.
/// It closes itself after a moment (only that dialog, never another page).
void _showPopup(BuildContext context, String message) {
  showDialog<void>(
    context: context,
    barrierColor: Colors.black45,
    builder: (dialogContext) {
      final route = ModalRoute.of(dialogContext);
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (route != null && route.isActive) {
          if (route.isCurrent) {
            route.navigator?.pop();
          } else {
            route.navigator?.removeRoute(route);
          }
        }
      });
      return Dialog(
        backgroundColor: Colors.transparent,
        child: BurstBox(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
                fontSize: 20,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
      );
    },
  );
}
