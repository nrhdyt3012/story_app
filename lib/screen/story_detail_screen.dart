import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart' as geo;
import '../provider/auth_provider.dart';
import '../provider/story_provider.dart';
import '../l10n/app_localizations.dart';

class StoryDetailScreen extends StatefulWidget {
  final String storyId;
  final VoidCallback onBack;

  const StoryDetailScreen({
    Key? key,
    required this.storyId,
    required this.onBack,
  }) : super(key: key);

  @override
  State<StoryDetailScreen> createState() => _StoryDetailScreenState();
}

class _StoryDetailScreenState extends State<StoryDetailScreen> {
  String? _address;
  bool _isLoadingAddress = false;

  @override
  void initState() {
    super.initState();
    _loadStoryDetail();
  }

  Future<void> _loadStoryDetail() async {
    final authProvider = context.read<AuthProvider>();
    final storyProvider = context.read<StoryProvider>();
    final token = await authProvider.getToken();

    if (token != null) {
      await storyProvider.fetchStoryDetail(token, widget.storyId);

      // Get address if location exists
      final story = storyProvider.selectedStory;
      if (story != null && story.lat != null && story.lon != null) {
        _getAddressFromLatLng(story.lat!, story.lon!);
      }
    }
  }

  Future<void> _getAddressFromLatLng(double lat, double lon) async {
    setState(() {
      _isLoadingAddress = true;
    });

    try {
      final placemarks = await geo.placemarkFromCoordinates(lat, lon);

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        setState(() {
          _address = '${placemark.street}, ${placemark.subLocality}, '
              '${placemark.locality}, ${placemark.country}';
          _isLoadingAddress = false;
        });
      }
    } catch (e) {
      setState(() {
        _address = 'Unable to get address';
        _isLoadingAddress = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      body: Consumer<StoryProvider>(
        builder: (context, storyProvider, child) {
          if (storyProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (storyProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(storyProvider.errorMessage!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadStoryDetail,
                    child: Text(localizations.retry),
                  ),
                ],
              ),
            );
          }

          final story = storyProvider.selectedStory;
          if (story == null) {
            return Center(child: Text(localizations.storyNotFound));
          }

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: widget.onBack,
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Hero(
                    tag: 'story-${story.id}',
                    child: Image.network(
                      story.photoUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.broken_image, size: 64),
                        );
                      },
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Theme.of(context).primaryColor,
                            child: Text(
                              story.name[0].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  story.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  DateFormat('MMM dd, yyyy - HH:mm')
                                      .format(story.createdAt),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        localizations.description,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        story.description,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      if (story.lat != null && story.lon != null) ...[
                        const SizedBox(height: 24),
                        Text(
                          localizations.location,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        if (_isLoadingAddress)
                          const CircularProgressIndicator()
                        else if (_address != null)
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  const Icon(Icons.location_on, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(_address!)),
                                ],
                              ),
                            ),
                          ),
                        const SizedBox(height: 8),
                        Container(
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: GoogleMap(
                              initialCameraPosition: CameraPosition(
                                target: LatLng(story.lat!, story.lon!),
                                zoom: 15,
                              ),
                              markers: {
                                Marker(
                                  markerId: MarkerId(story.id),
                                  position: LatLng(story.lat!, story.lon!),
                                  infoWindow: InfoWindow(
                                    title: story.name,
                                    snippet: _address ?? 'Loading address...',
                                  ),
                                ),
                              },
                              zoomControlsEnabled: false,
                              myLocationButtonEnabled: false,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Lat: ${story.lat?.toStringAsFixed(6)}, '
                              'Lon: ${story.lon?.toStringAsFixed(6)}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}