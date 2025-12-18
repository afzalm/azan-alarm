/// Sound picker bottom sheet with Azan preview using just_audio

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class SoundPickerSheet extends StatefulWidget {
  final String? initialSelection;
  const SoundPickerSheet({super.key, this.initialSelection});

  @override
  State<SoundPickerSheet> createState() => _SoundPickerSheetState();
}

class _SoundPickerSheetState extends State<SoundPickerSheet> {
  final _player = AudioPlayer();
  String? _selected;
  bool _loading = false;

  // Predefined list of Azan sounds (assets). Ensure these files exist under assets/audio/
  static const List<Map<String, String>> _sounds = [
    {
      'name': 'Adhan Makkah',
      'asset': 'assets/audio/adhan_makkah.mp3',
    },
    {
      'name': 'Adhan Madinah',
      'asset': 'assets/audio/adhan_madinah.mp3',
    },
    {
      'name': 'Takbir Simple',
      'asset': 'assets/audio/takbir_simple.mp3',
    },
  ];

  @override
  void initState() {
    super.initState();
    _selected = widget.initialSelection;
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _preview(String assetPath) async {
    setState(() => _loading = true);
    try {
      // Stop any current playback
      await _player.stop();
      await _player.setAsset(assetPath);
      await _player.play();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to play preview. Ensure asset exists: $assetPath'),
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _selectAndClose() {
    Navigator.pop(context, _selected);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      builder: (context, scrollController) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    'Select Azan Sound',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: _sounds.length,
                  itemBuilder: (context, index) {
                    final item = _sounds[index];
                    final name = item['name']!;
                    final asset = item['asset']!;
                    final selected = _selected == asset;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Icon(
                          selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                          color: selected ? Theme.of(context).colorScheme.primary : null,
                        ),
                        title: Text(name),
                        subtitle: Text(asset),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: _loading ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.play_arrow),
                              onPressed: _loading ? null : () => _preview(asset),
                              tooltip: 'Preview',
                            ),
                            IconButton(
                              icon: const Icon(Icons.check),
                              onPressed: () => setState(() => _selected = asset),
                              tooltip: 'Select',
                            ),
                          ],
                        ),
                        onTap: () => setState(() => _selected = asset),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('Use Selected Sound'),
                  onPressed: _selectAndClose,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
