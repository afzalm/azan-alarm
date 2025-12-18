/// Alarm creation sheet for creating new alarms

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/models.dart';
import '../../core/providers/providers.dart';
import 'sound_picker_sheet.dart';

class AlarmCreationSheet extends ConsumerStatefulWidget {
  const AlarmCreationSheet({super.key});

  @override
  ConsumerState<AlarmCreationSheet> createState() => _AlarmCreationSheetState();
}

class _AlarmCreationSheetState extends ConsumerState<AlarmCreationSheet> {
  Prayer _selectedPrayer = Prayer.fajr;
  int _offsetMinutes = 0; // negative = before, positive = after
  final TextEditingController _labelController = TextEditingController();
  bool _vibrationEnabled = true;
  final Set<int> _repeatDays = <int>{}; // 1=Mon..7=Sun
  String? _soundPath; // Placeholder for future sound picker
  bool _saving = false;

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
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
                    'Create Alarm',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _saving ? null : () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    _buildSectionHeader(context, 'Prayer'),
                    Wrap(
                      spacing: 8,
                      children: Prayer.values.map((p) {
                        final selected = p == _selectedPrayer;
                        return ChoiceChip(
                          label: Text(p.displayName),
                          selected: selected,
                          onSelected: (val) {
                            if (val) setState(() => _selectedPrayer = p);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    _buildSectionHeader(context, 'Offset (minutes)'),
                    Row(
                      children: [
                        const Text('-60'),
                        Expanded(
                          child: Slider(
                            value: _offsetMinutes.toDouble(),
                            min: -60,
                            max: 60,
                            divisions: 24,
                            label: _offsetMinutes.toString(),
                            onChanged: (v) => setState(() => _offsetMinutes = v.round()),
                          ),
                        ),
                        const Text('+60'),
                      ],
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        _offsetMinutes == 0
                            ? 'At prayer time'
                            : (_offsetMinutes > 0
                                ? '${_offsetMinutes.abs()} min after'
                                : '${_offsetMinutes.abs()} min before'),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildSectionHeader(context, 'Label (optional)'),
                    TextField(
                      controller: _labelController,
                      decoration: const InputDecoration(
                        hintText: 'e.g., Fajr wake-up',
                        prefixIcon: Icon(Icons.label_outline),
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildSectionHeader(context, 'Repeat (optional)'),
                    Wrap(
                      spacing: 8,
                      children: [1, 2, 3, 4, 5, 6, 7].map((d) {
                        final selected = _repeatDays.contains(d);
                        return FilterChip(
                          label: Text(_weekdayLabel(d)),
                          selected: selected,
                          onSelected: (val) {
                            setState(() {
                              if (val) {
                                _repeatDays.add(d);
                              } else {
                                _repeatDays.remove(d);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    _buildSectionHeader(context, 'Vibration'),
                    SwitchListTile(
                      value: _vibrationEnabled,
                      title: const Text('Enable vibration'),
                      onChanged: (v) => setState(() => _vibrationEnabled = v),
                    ),
                    const SizedBox(height: 8),

                    _buildSectionHeader(context, 'Sound (optional)'),
                    ListTile(
                      leading: const Icon(Icons.music_note),
                      title: Text(_soundPath ?? 'Default notification sound'),
                      subtitle: const Text('Tap to choose and preview Azan'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        final selected = await showModalBottomSheet<String>(
                          context: context,
                          isScrollControlled: true,
                          builder: (context) => const FractionallySizedBox(
                            heightFactor: 0.9,
                            child: SoundPickerSheet(),
                          ),
                        );
                        if (selected != null) {
                          setState(() => _soundPath = selected);
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: Text(_saving ? 'Saving...' : 'Save Alarm'),
                  onPressed: _saving ? null : _save,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _weekdayLabel(int d) {
    switch (d) {
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thu';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      case 7:
        return 'Sun';
      default:
        return d.toString();
    }
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final id = await ref.read(alarmManagerProvider).createAlarm(
            prayer: _selectedPrayer,
            offsetMinutes: _offsetMinutes,
            label: _labelController.text.trim().isEmpty ? null : _labelController.text.trim(),
            soundPath: _soundPath,
            repeatDays: _repeatDays.toList()..sort(),
            vibrationEnabled: _vibrationEnabled,
          );

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Alarm saved (ID: $id)')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save alarm: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
