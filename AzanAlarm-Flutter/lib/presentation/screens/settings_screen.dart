/// Settings screen for app configuration

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/models.dart';
import '../../core/providers/providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ref.watch(appSettingsProvider).when(
        data: (settings) => _buildSettingsList(context, ref, settings),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState(context, error),
      ),
    );
  }

  Widget _buildSettingsList(BuildContext context, WidgetRef ref, AppSettings settings) {
    return ListView(
      children: [
        _buildSectionHeader(context, 'General'),
        _buildSwitchTile(
          context,
          title: '24-Hour Format',
          value: settings.is24HourFormat,
          onChanged: (value) => ref.read(settingsUpdaterProvider).updateTimeFormat(value),
          icon: Icons.access_time,
        ),
        _buildDropdownTile(
          context,
          title: 'Theme',
          value: settings.theme,
          items: AppTheme.values,
          onChanged: (value) => ref.read(settingsUpdaterProvider).updateTheme(value),
          icon: Icons.palette,
        ),
        _buildDropdownTile(
          context,
          title: 'Language',
          value: settings.language,
          items: ['en', 'ar', 'ur'],
          onChanged: (value) => ref.read(settingsUpdaterProvider).updateLanguage(value),
          icon: Icons.language,
        ),
        
        const Divider(),
        
        _buildSectionHeader(context, 'Prayer Times'),
        _buildDropdownTile(
          context,
          title: 'Calculation Method',
          value: settings.calculationMethod,
          items: PrayerCalculationMethod.values,
          onChanged: (value) => ref.read(settingsUpdaterProvider).updateCalculationMethod(value),
          icon: Icons.calculate,
        ),
        _buildDropdownTile(
          context,
          title: 'Juristic Method',
          value: settings.juristicMethod,
          items: JuristicMethod.values,
          onChanged: (value) => ref.read(settingsUpdaterProvider).updateJuristicMethod(value),
          icon: Icons.book,
        ),
        
        const Divider(),
        
        _buildSectionHeader(context, 'Notifications'),
        _buildSwitchTile(
          context,
          title: 'Enable Notifications',
          value: settings.enableNotifications,
          onChanged: (value) => ref.read(settingsUpdaterProvider).updateNotifications(value),
          icon: Icons.notifications,
        ),
        _buildSwitchTile(
          context,
          title: 'Enable Vibration',
          value: settings.enableVibration,
          onChanged: (value) => ref.read(settingsUpdaterProvider).updateVibration(value),
          icon: Icons.vibration,
        ),
        
        const Divider(),
        
        _buildSectionHeader(context, 'Audio'),
        _buildDropdownTile(
          context,
          title: 'Audio Theme',
          value: settings.audioTheme,
          items: ['default', 'soft', 'loud'],
          onChanged: (value) => ref.read(settingsUpdaterProvider).updateAudioTheme(value),
          icon: Icons.volume_up,
        ),
        
        const Divider(),
        
        ListTile(
          leading: const Icon(Icons.restore, color: Colors.orange),
          title: const Text('Reset to Defaults'),
          onTap: () => _showResetConfirmation(context, ref),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
  }) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      secondary: Icon(icon),
      title: Text(title),
    );
  }

  Widget _buildDropdownTile<T>(
    BuildContext context, {
    required String title,
    required T value,
    required List<T> items,
    required ValueChanged<T> onChanged,
    required IconData icon,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: DropdownButton<T>(
        value: value,
        items: items.map((item) {
          String displayValue;
          if (item is AppTheme) {
            displayValue = item.name.toUpperCase();
          } else if (item is PrayerCalculationMethod) {
            displayValue = item.name.replaceAll('_', ' ').split(' ').map((word) => 
              word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1).toLowerCase()
            ).join(' ');
          } else if (item is JuristicMethod) {
            displayValue = item.name.toUpperCase();
          } else {
            displayValue = item.toString();
          }
          
          return DropdownMenuItem(
            value: item,
            child: Text(displayValue),
          );
        }).toList(),
        onChanged: (newValue) {
          if (newValue != null) {
            onChanged(newValue);
          }
        },
        underline: const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Error Loading Settings',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showResetConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text('Are you sure you want to reset all settings to defaults?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(settingsUpdaterProvider).resetToDefaults();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings reset to defaults')),
              );
            },
            child: const Text('Reset', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}