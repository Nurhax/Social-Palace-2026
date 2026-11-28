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

class AddSocialLinkScreen extends StatefulWidget {
  const AddSocialLinkScreen({super.key});

  @override
  State<AddSocialLinkScreen> createState() => _AddSocialLinkScreenState();
}

class _AddSocialLinkScreenState extends State<AddSocialLinkScreen> {
  final _nameController = TextEditingController();
  final _levelController = TextEditingController();
  Arcana _arcana = kArcanaList.first; // NULL

  @override
  void dispose() {
    _nameController.dispose();
    _levelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppScope.of(context).colors;
    return Scaffold(
      backgroundColor: colors.primary,
      appBar: const SopalHeader(title: 'New\nSocial Link'),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.black, width: 3),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ComicText('Arcana', fontSize: 26),
                const SizedBox(height: 10),
                Row(
                  children: [
                    ArcanaBadge(arcana: _arcana, showLabel: true),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          AudioService.instance.playSelect();
                          final selected = await Navigator.of(context).push(
                            PersonaRoute<Arcana>(
                              builder: (_) => ArcanaSelectionScreen(
                                initialArcana: _arcana,
                              ),
                            ),
                          );
                          if (selected != null) {
                            setState(() => _arcana = selected);
                          }
                        },
                        child: SlantedBox(
                          color: Colors.black,
                          borderColor: Colors.white,
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Select arcana',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontStyle: FontStyle.italic)),
                              SizedBox(width: 8),
                              AssetImageOr(
                                path: AppAssets.selectArcanaArrow,
                                width: 24,
                                height: 24,
                                fallback: Icon(
                                  Icons.chevron_right,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 26),
                const ComicText('Name', fontSize: 26),
                const SizedBox(height: 10),
                ComicTextField(
                    controller: _nameController, hint: 'Enter here...'),
                const SizedBox(height: 26),
                const ComicText('Current Level', fontSize: 26),
                const SizedBox(height: 10),
                ComicTextField(
                  controller: _levelController,
                  hint: 'Enter here...',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 30),
                Center(
                  child: ComicButton(
                    label: 'ADD',
                    fontSize: 26,
                    onTap: () {
                      if (_nameController.text.trim().isEmpty) return;
                      final level = int.tryParse(_levelController.text) ?? 1;
                      Navigator.of(context).pop(
                        SocialLink(
                          name: _nameController.text.trim(),
                          arcana: _arcana,
                          level: level.clamp(1, 10),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ArcanaSelectionScreen extends StatefulWidget {
  final Arcana initialArcana;

  const ArcanaSelectionScreen({super.key, required this.initialArcana});

  @override
  State<ArcanaSelectionScreen> createState() => _ArcanaSelectionScreenState();
}

class _ArcanaSelectionScreenState extends State<ArcanaSelectionScreen> {
  late Arcana _selectedArcana = widget.initialArcana;

  @override
  Widget build(BuildContext context) {
    final colors = AppScope.of(context).colors;
    return Scaffold(
      backgroundColor: colors.primary,
      appBar: const SopalHeader(title: 'New\nSocial Link'),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.primary,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.black, width: 3),
            ),
            child: Column(
              children: [
                const ComicText('Arcana Selection',
                    fontSize: 24, strokeWidth: 5),
                const SizedBox(height: 16),
                Expanded(
                  child: GridView.builder(
                    itemCount: kArcanaList.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.9,
                    ),
                    itemBuilder: (context, index) {
                      final arcana = kArcanaList[index];
                      final isSelected = arcana == _selectedArcana;
                      return GestureDetector(
                        onTap: () {
                          AudioService.instance.playSelect();
                          setState(() => _selectedArcana = arcana);
                        },
                        child: Center(
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              if (isSelected)
                                Positioned(
                                  left: -5,
                                  top: -5,
                                  right: -5,
                                  bottom: -5,
                                  child: IgnorePointer(
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: const Color.fromARGB(
                                              255, 222, 234, 255),
                                          width: 5,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ArcanaBadge(arcana: arcana, size: 84),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                ComicButton(
                  label: 'DONE',
                  fontSize: 24,
                  playSound: false,
                  onTap: () {
                    AudioService.instance.playConfirm();
                    Navigator.of(context).pop(_selectedArcana);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
