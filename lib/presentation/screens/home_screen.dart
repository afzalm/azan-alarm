/// Home screen displaying prayer times and next prayer countdown

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/models.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                AppConstants.appName,
                style: TextStyle(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.primary,
                      colorScheme.secondary,
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.calendar_month),
                onPressed: () => context.push('/calendar'),
              ),
              IconButton(
                icon: const Icon(Icons.compass_calibration),
                onPressed: () => context.push('/qibla'),
              ),
            ],
          ),

          // Current Location Header
          SliverToBoxAdapter(
            child: _buildLocationHeader(context, ref),
          ),

          // Next Prayer Countdown
          SliverToBoxAdapter(
            child: _buildNextPrayerCountdown(context, ref),
          ),

          // Today's Prayer Times
          SliverToBoxAdapter(
            child: _buildPrayerTimesList(context, ref),
          ),

          // Quick Actions
          SliverToBoxAdapter(
            child: _buildQuickActions(context, ref),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationHeader(BuildContext context, WidgetRef ref) {
    final locationAsync = ref.watch(currentLocationProvider);
    final settingsAsync = ref.watch(appSettingsProvider);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.location_on,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Location',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                locationAsync.when(
                  data: (location) => Text(
                    location?.displayName ?? 'No location set',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  loading: () => const CircularProgressIndicator(),
                  error: (error, stack) => Text(
                    'Error loading location',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_location),
            onPressed: () => context.push('/location'),
          ),
        ],
      ),
    );
  }

  Widget _buildNextPrayerCountdown(BuildContext context, WidgetRef ref) {
    final nextPrayerData = ref.watch(nextPrayerProvider);
    final (nextPrayer, countdown) = nextPrayerData;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: nextPrayer != null
              ? [
                  Theme.of(context).colorScheme.getPrayerColor(nextPrayer),
                  Theme.of(context).colorScheme.primary,
                ]
              : [
                  Theme.of(context).colorScheme.surfaceVariant,
                  Theme.of(context).colorScheme.surface,
                ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            nextPrayer != null
                ? 'Next Prayer: ${nextPrayer.displayName}'
                : 'No Prayer Times Available',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: nextPrayer != null
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          if (nextPrayer != null) ...[
            Text(
              _formatDuration(countdown),
              style: AppTextStyles.countdownTimer.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Until ${nextPrayer.displayName}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPrayerTimesList(BuildContext context, WidgetRef ref) {
    final prayerTimesAsync = ref.watch(todayPrayerTimesProvider);
    final settingsAsync = ref.watch(appSettingsProvider);

    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today\'s Prayer Times',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          prayerTimesAsync.when(
            data: (prayerTimes) => _buildPrayerTimesCards(context, prayerTimes, settingsAsync.value),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
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
                    'Error loading prayer times',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error.toString(),
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerTimesCards(BuildContext context, Map<Prayer, DateTime> prayerTimes, AppSettings? settings) {
    if (prayerTimes.isEmpty) {
      return Center(
        child: Column(
          children: [
            Icon(
              Icons.schedule,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No prayer times available',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    final is24Hour = settings?.is24HourFormat ?? false;
    final now = DateTime.now();

    return Column(
      children: Prayer.values.map((prayer) {
        final prayerTime = prayerTimes[prayer];
        final hasPassed = prayerTime?.isBefore(now) ?? false;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: Card(
            elevation: hasPassed ? 0 : 2,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.getPrayerColor(prayer),
                child: Icon(
                  _getPrayerIcon(prayer),
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              title: Text(
                prayer.displayName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                hasPassed ? 'Passed' : 'Upcoming',
                style: TextStyle(
                  color: hasPassed
                      ? Theme.of(context).colorScheme.onSurfaceVariant
                      : Theme.of(context).colorScheme.primary,
                ),
              ),
              trailing: Text(
                prayerTime != null
                    ? _formatTime(prayerTime, is24Hour)
                    : '--:--',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: hasPassed
                      ? Theme.of(context).colorScheme.onSurfaceVariant
                      : Theme.of(context).colorScheme.primary,
                ),
              ),
              onTap: () => _showPrayerDetails(context, prayer, prayerTime),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQuickActions(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  context,
                  icon: Icons.alarm_add,
                  title: 'Add Alarm',
                  onTap: () => context.push('/create-alarm'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionCard(
                  context,
                  icon: Icons.notifications_active,
                  title: 'Manage Alarms',
                  onTap: () => context.push('/alarms'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  context,
                  icon: Icons.location_on,
                  title: 'Change Location',
                  onTap: () => context.push('/location'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionCard(
                  context,
                  icon: Icons.notifications_active,
                  title: 'Schedule Next Prayer',
                  onTap: () async {
                    final prayerTimes = ref.read(todayPrayerTimesProvider).value;
                    if (prayerTimes == null || prayerTimes.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Prayer times unavailable')),
                      );
                      return;
                    }
                    final pts = ref.read(prayerTimesServiceProvider);
                    final next = pts.getNextPrayer(prayerTimes);
                    if (next == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('No upcoming prayer today')),
                      );
                      return;
                    }
                    final time = prayerTimes[next]!;
                    final notifier = ref.read(notificationServiceProvider);
                    await notifier.initialize();
                    final granted = await notifier.arePermissionsGranted();
                    if (!granted) await notifier.requestPermissions();
                    await notifier.scheduleNotificationAt(
                      time: time,
                      title: 'Next Prayer: ${next.displayName}',
                      body: 'Scheduled reminder for ${next.displayName}',
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Notification scheduled for ${next.displayName}')),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.outlineVariant,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showPrayerDetails(BuildContext context, Prayer prayer, DateTime? time) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
              Icon(
                _getPrayerIcon(prayer),
                size: 48,
                color: Theme.of(context).colorScheme.getPrayerColor(prayer),
              ),
              const SizedBox(height: 16),
              Text(
                prayer.displayName,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                time != null
                    ? 'Time: ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}'
                    : 'Time not available',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      context.push('/create-alarm');
                    },
                    icon: const Icon(Icons.alarm_add),
                    label: const Text('Set Alarm'),
                  ),
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time, bool is24Hour) {
    if (is24Hour) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else {
      final hour = time.hour % 12;
      final hour12 = hour == 0 ? 12 : hour;
      final period = time.hour < 12 ? 'AM' : 'PM';
      return '$hour12:${time.minute.toString().padLeft(2, '0')} $period';
    }
  }

  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours % 24}h';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else {
      return '${duration.inMinutes}m ${duration.inSeconds % 60}s';
    }
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