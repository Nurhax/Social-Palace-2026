import 'package:flutter/material.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../widgets/comic_shapes.dart';
import '../widgets/social_link_card.dart';
import '../widgets/sopal_chrome.dart';
import 'add_social_link_screen.dart';
import 'logs_screen.dart';
import 'settings_screen.dart';
import 'social_link_detail_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const _SocialLinksPage(),
      const LogsScreen(),
      const SettingsScreen(),
    ];
    return Scaffold(
      body: pages[_tab],
      bottomNavigationBar: SopalBottomNav(
        currentIndex: _tab,
        onTap: (i) => setState(() => _tab = i),
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
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 12, bottom: 12),
              itemCount: state.socialLinks.length + 1,
              itemBuilder: (context, index) {
                if (index == state.socialLinks.length) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    child: ComicButton(
                      label: '+',
                      fontSize: 28,
                      onTap: () async {
                        final result =
                            await Navigator.of(context).push<SocialLink>(
                          MaterialPageRoute(
                              builder: (_) => const AddSocialLinkScreen()),
                        );
                        if (result != null) {
                          state.addSocialLink(result);
                          if (context.mounted) {
                            _showAddedPopup(context);
                          }
                        }
                      },
                    ),
                  );
                }
                final link = state.socialLinks[index];
                return SocialLinkRow(
                  link: link,
                  onOpen: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => SocialLinkDetailScreen(link: link)),
                  ),
                  onAddExp: () => state.addExp(link, 1),
                  onRemoveExp: () => state.addExp(link, -1),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddedPopup(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black45,
      builder: (_) => const Dialog(
        backgroundColor: Colors.transparent,
        child: BurstBox(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: const Text(
              'New Social\nLink Added!',
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
      ),
    );
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (context.mounted)
        Navigator.of(context, rootNavigator: true).maybePop();
    });
  }
}
