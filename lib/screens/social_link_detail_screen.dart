import 'package:flutter/material.dart';
import '../audio/audio_service.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_assets.dart';
import '../theme/app_theme.dart';
import '../widgets/comic_shapes.dart';
import '../widgets/social_link_card.dart';

class SocialLinkDetailScreen extends StatefulWidget {
  final SocialLink link;
  const SocialLinkDetailScreen({super.key, required this.link});

  @override
  State<SocialLinkDetailScreen> createState() => _SocialLinkDetailScreenState();
}

class _SocialLinkDetailScreenState extends State<SocialLinkDetailScreen> {
  bool _editing = false;
  late TextEditingController _nameController;
  late TextEditingController _levelController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.link.name);
    _levelController =
        TextEditingController(text: widget.link.level.toString());
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final colors = state.colors;
    final link = widget.link;

    return Scaffold(
      backgroundColor: colors.primary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ArcanaBadge(arcana: link.arcana, size: 80),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SlantedBox(
                      color: Colors.black,
                      borderColor: Colors.white,
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
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.black, width: 3),
                  ),
                  child: _editing ? _editForm() : _readonlyInfo(link),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: ComicButton(
                  label: 'BACK',
                  deselect: true,
                  onTap: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _readonlyInfo(SocialLink link) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _infoRow('Level (1-10):', '${link.level}'),
        const SizedBox(height: 22),
        _infoRow('Total Logs:', '${link.totalLogs}'),
        const SizedBox(height: 22),
        _infoRow('Last Log:', link.lastLogLabel),
        const Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _iconSquareButton(
              assetPath: AppAssets.editIcon,
              fallbackIcon: Icons.edit,
              onTap: () {
                AudioService.instance.playSelect();
                setState(() => _editing = true);
              },
            ),
            const SizedBox(width: 12),
            _iconSquareButton(
              assetPath: AppAssets.deleteIcon,
              fallbackIcon: Icons.delete,
              onTap: () async {
                AudioService.instance.playDeselect();
                final state = AppScope.of(context);
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Delete this Social Link?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) {
                  state.removeSocialLink(link);
                  if (mounted) Navigator.of(context).pop();
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _editForm() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ComicText('Name', fontSize: 16, strokeWidth: 4),
          const SizedBox(height: 8),
          ComicTextField(controller: _nameController),
          const SizedBox(height: 20),
          const ComicText('Level (1-10)', fontSize: 16, strokeWidth: 4),
          const SizedBox(height: 8),
          ComicTextField(
              controller: _levelController, keyboardType: TextInputType.number),
          const SizedBox(height: 26),
          Center(
            child: ComicButton(
              label: 'Save',
              color: Colors.black,
              textColor: Colors.white,
              onTap: () {
                final state = AppScope.of(context);
                widget.link.name = _nameController.text.trim().isEmpty
                    ? widget.link.name
                    : _nameController.text.trim();
                widget.link.level =
                    (int.tryParse(_levelController.text) ?? widget.link.level)
                        .clamp(1, 10);
                state.refresh();
                setState(() => _editing = false);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      children: [
        Expanded(child: ComicText(label, fontSize: 20, strokeWidth: 5)),
        ComicText(value, fontSize: 22, strokeWidth: 5),
      ],
    );
  }

  Widget _iconSquareButton(
      {required String assetPath,
      required IconData fallbackIcon,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 56,
        height: 56,
        child: AssetImageOr(
          path: assetPath,
          width: 56,
          height: 56,
          fallback: Icon(fallbackIcon, size: 32),
        ),
      ),
    );
  }
}
