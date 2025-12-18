/// Location picker sheet for selecting/searching locations

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/models.dart';
import '../../core/providers/providers.dart';

class LocationPickerSheet extends ConsumerStatefulWidget {
  const LocationPickerSheet({super.key});

  @override
  ConsumerState<LocationPickerSheet> createState() => _LocationPickerSheetState();
}

class _LocationPickerSheetState extends ConsumerState<LocationPickerSheet> {
  final TextEditingController _controller = TextEditingController();
  List<Location> _results = [];
  bool _searching = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _useCurrentLocation() async {
    setState(() {
      _error = null;
    });
    final manager = ref.read(locationManagerProvider);
    final hasPerm = await manager.hasLocationPermission();
    if (!hasPerm) {
      final granted = await manager.requestLocationPermission();
      if (!granted) {
        setState(() {
          _error = 'Location permission denied';
        });
        return;
      }
    }
    final loc = await manager.getCurrentDeviceLocation();
    if (loc != null) {
      await manager.setCurrentLocation(loc);
      if (mounted) Navigator.pop(context);
    } else {
      setState(() {
        _error = 'Failed to get current location';
      });
    }
  }

  Future<void> _search(String query) async {
    setState(() {
      _searching = true;
      _error = null;
    });
    try {
      final results = await ref.read(locationManagerProvider).searchLocations(query);
      setState(() {
        _results = results;
      });
    } catch (e) {
      setState(() {
        _error = 'Search error: $e';
      });
    } finally {
      setState(() {
        _searching = false;
      });
    }
  }

  Future<void> _select(Location location) async {
    final manager = ref.read(locationManagerProvider);
    await manager.saveLocation(location);
    await manager.setCurrentLocation(location);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      builder: (context, scrollController) => Padding(
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
            Text(
              'Pick Location',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Search city or address',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onSubmitted: _search,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => _search(_controller.text),
                  icon: const Icon(Icons.search),
                  label: const Text('Search'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _useCurrentLocation,
                icon: const Icon(Icons.my_location),
                label: const Text('Use current location'),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
            const SizedBox(height: 8),
            Expanded(
              child: _searching
                  ? const Center(child: CircularProgressIndicator())
                  : _results.isEmpty
                      ? const Center(child: Text('Search results will appear here'))
                      : ListView.builder(
                          controller: scrollController,
                          itemCount: _results.length,
                          itemBuilder: (context, index) {
                            final loc = _results[index];
                            return ListTile(
                              leading: const Icon(Icons.location_on),
                              title: Text(loc.name),
                              subtitle: Text(loc.country),
                              onTap: () => _select(loc),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
