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
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Premium Header with App Bar
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            stretch: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [
                StretchMode.zoomBackground,
                StretchMode.blurBackground,
              ],
              title: Text(
                AppConstants.appName,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              centerTitle: true,
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          colorScheme.primary,
                          colorScheme.secondary.withOpacity(0.8),
                          colorScheme.primary.withOpacity(0.9),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                  // Subtle Pattern Overlay
                  Opacity(
                    opacity: 0.1,
                    child: Center(
                      child: Icon(
                        Icons.mosque,
                        size: 150,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ),
                  // Bottom Rounded Edge
                  Positioned(
                    bottom: -1,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 30,
                      decoration: BoxDecoration(
                        color: theme.scaffoldBackgroundColor,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(32),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined, color: Colors.white),
                onPressed: () => context.push('/settings'),
              ),
            ],
          ),

          // Content
          SliverList(
            delegate: SliverChildListDelegate([
              _buildLocationHeader(context, ref),
              _buildNextPrayerHero(context, ref),
              _buildPrayerTimesSection(context, ref),
              _buildQuickActions(context, ref),
              const SizedBox(height: 32),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationHeader(BuildContext context, WidgetRef ref) {
    final locationAsync = ref.watch(currentLocationProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          locationAsync.when(
            data: (location) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 16, color: colorScheme.primary),
                    const SizedBox(width: 4),
                    Text(
                      location?.country ?? '',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
                Text(
                  location?.name ?? 'Detecting Location...',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            loading: () => const ShimmerPlaceholder(height: 40, width: 150),
            error: (_, __) => const Text('Location unavailable'),
          ),
          IconButton.filledTonal(
            icon: const Icon(Icons.my_location),
            onPressed: () => context.push('/location'),
          ),
        ],
      ),
    );
  }

  Widget _buildNextPrayerHero(BuildContext context, WidgetRef ref) {
    final nextPrayerData = ref.watch(nextPrayerProvider);
    final (nextPrayer, countdown) = nextPrayerData;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (nextPrayer == null) return const SizedBox.shrink();

    final prayerColor = colorScheme.getPrayerColor(nextPrayer);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: prayerColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: prayerColor.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: prayerColor.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getPrayerIcon(nextPrayer),
                color: prayerColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'NEXT PRAYER: ${nextPrayer.displayName.toUpperCase()}',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: prayerColor,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TweenAnimationBuilder<Duration>(
            duration: const Duration(seconds: 1),
            tween: Tween(begin: countdown, end: countdown),
            builder: (context, val, child) {
              return Text(
                _formatDuration(val),
                style: theme.textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: colorScheme.onSurface,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: prayerColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Remaining',
              style: theme.textTheme.labelMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerTimesSection(BuildContext context, WidgetRef ref) {
    final prayerTimesAsync = ref.watch(todayPrayerTimesProvider);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Today\'s Timetable',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => context.push('/calendar'),
                child: const Text('View Calendar'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          prayerTimesAsync.when(
            data: (times) => _buildPrayerTimesList(context, ref, times),
            loading: () => const Center(child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            )),
            error: (e, __) => Text('Error: $e'),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerTimesList(BuildContext context, WidgetRef ref, Map<Prayer, DateTime> times) {
    final settings = ref.watch(appSettingsProvider).value;
    final is24Hour = settings?.is24HourFormat ?? false;
    final now = DateTime.now();
    final nextPrayer = ref.watch(nextPrayerProvider).$1;

    return Column(
      children: Prayer.values.map((prayer) {
        final time = times[prayer];
        final isNext = prayer == nextPrayer;
        final hasPassed = time != null && time.isBefore(now) && !isNext;
        
        return _buildPrayerTimeRow(
          context,
          prayer: prayer,
          time: time,
          isNext: isNext,
          hasPassed: hasPassed,
          is24Hour: is24Hour,
        );
      }).toList(),
    );
  }

  Widget _buildPrayerTimeRow(
    BuildContext context, {
    required Prayer prayer,
    required DateTime? time,
    required bool isNext,
    required bool hasPassed,
    required bool is24Hour,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final prayerColor = colorScheme.getPrayerColor(prayer);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isNext ? prayerColor.withOpacity(0.08) : colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isNext ? prayerColor.withOpacity(0.3) : colorScheme.outlineVariant.withOpacity(0.5),
          width: isNext ? 2 : 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: hasPassed ? colorScheme.surfaceVariant : prayerColor.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getPrayerIcon(prayer),
            color: hasPassed ? colorScheme.onSurfaceVariant : prayerColor,
            size: 24,
          ),
        ),
        title: Text(
          prayer.displayName,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: isNext ? FontWeight.w800 : FontWeight.w600,
            color: hasPassed ? colorScheme.onSurfaceVariant : colorScheme.onSurface,
          ),
        ),
        subtitle: isNext 
          ? Text('Coming up next', style: TextStyle(color: prayerColor, fontWeight: FontWeight.bold, fontSize: 12)) 
          : null,
        trailing: Text(
          time != null ? _formatTime(time, is24Hour) : '--:--',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: hasPassed ? colorScheme.onSurfaceVariant : (isNext ? prayerColor : colorScheme.onSurface),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Shortcuts',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildModernActionBtn(
                context,
                icon: Icons.notifications_active_outlined,
                label: 'Alarms',
                onTap: () => context.push('/alarms'),
              ),
              const SizedBox(width: 16),
              _buildModernActionBtn(
                context,
                icon: Icons.explore_outlined,
                label: 'Qibla',
                onTap: () => context.push('/qibla'),
              ),
              const SizedBox(width: 16),
              _buildModernActionBtn(
                context,
                icon: Icons.settings_outlined,
                label: 'Settings',
                onTap: () => context.push('/settings'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModernActionBtn(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Icon(icon, color: colorScheme.primary, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
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
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  IconData _getPrayerIcon(Prayer prayer) {
    switch (prayer) {
      case Prayer.fajr: return Icons.wb_twilight_outlined;
      case Prayer.dhuhr: return Icons.wb_sunny_outlined;
      case Prayer.asr: return Icons.wb_cloudy_outlined;
      case Prayer.maghrib: return Icons.wb_twilight_rounded;
      case Prayer.isha: return Icons.nights_stay_outlined;
    }
  }
}

class ShimmerPlaceholder extends StatelessWidget {
  final double height;
  final double width;
  const ShimmerPlaceholder({super.key, required this.height, required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}