/// Alarms screen for managing prayer alarms

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/models.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/app_theme.dart';

class AlarmsScreen extends ConsumerWidget {
  const AlarmsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prayer Alarms'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/create-alarm'),
          ),
        ],
      ),
      body: ref.watch(alarmsProvider).when(
        data: (alarms) => alarms.isEmpty
            ? _buildEmptyState(context)
            : _buildAlarmsList(context, ref, alarms),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState(context, error),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/create-alarm'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.alarm_off,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No Alarms Set',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first prayer alarm to get started',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.push('/create-alarm'),
            icon: const Icon(Icons.add),
            label: const Text('Create Alarm'),
          ),
        ],
      ),
    );
  }

  Widget _buildAlarmsList(BuildContext context, WidgetRef ref, List<Alarm> alarms) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: alarms.length,
      itemBuilder: (context, index) {
        final alarm = alarms[index];
        return _buildAlarmCard(context, ref, alarm);
      },
    );
  }

  Widget _buildAlarmCard(BuildContext context, WidgetRef ref, Alarm alarm) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: SwitchListTile(
        value: alarm.isActive,
        onChanged: (value) {
          ref.read(alarmManagerProvider).toggleAlarm(alarm.id!, value);
        },
        secondary: CircleAvatar(
          backgroundColor: colorScheme.getPrayerColor(alarm.prayer),
          child: Icon(
            _getPrayerIcon(alarm.prayer),
            color: colorScheme.onPrimary,
          ),
        ),
        title: Text(
          alarm.displayLabel,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          alarm.prayer.displayName,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (alarm.label != null && alarm.label!.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  alarm.label!,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () => _showAlarmOptions(context, ref, alarm),
            ),
          ],
        ),
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
            'Error Loading Alarms',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => ref.refresh(alarmsProvider),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _showAlarmOptions(BuildContext context, WidgetRef ref, Alarm alarm) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Alarm'),
              onTap: () {
                Navigator.pop(context);
                context.push('/alarm-details/${alarm.id}');
              },
            ),
            ListTile(
              leading: Icon(
                alarm.isActive ? Icons.notifications_off : Icons.notifications_active,
              ),
              title: Text(alarm.isActive ? 'Disable' : 'Enable'),
              onTap: () {
                Navigator.pop(context);
                ref.read(alarmManagerProvider).toggleAlarm(alarm.id!, !alarm.isActive);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Alarm', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(context, ref, alarm);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, Alarm alarm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Alarm'),
        content: const Text('Are you sure you want to delete this alarm?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(alarmManagerProvider).deleteAlarm(alarm.id!);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  IconData _getPrayerIcon(Prayer prayer) {
    switch (prayer) {
      case Prayer.fajr:
        return Icons.wb_twilight;
      case Prayer.dhuhr:
        return Icons.wb_sunny;
      case Prayer.asr:
        return Icons.wb_twilight;
      case Prayer.maghrib:
        return Icons.wb_twilight;
      case Prayer.isha:
        return Icons.nights_stay;
    }
  }
}