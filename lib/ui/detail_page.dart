import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../provider/story_provider.dart';
import '../data/model/story.dart';
import '../widgets/address_info_widget.dart';
import '../common/location_helper.dart';

class DetailPage extends StatelessWidget {
  final String storyId;

  const DetailPage({super.key, required this.storyId});

  @override
  Widget build(BuildContext context) {
    final storyProvider = Provider.of<StoryProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Attempt to get story from provider's list
    Story? story;
    try {
      story = storyProvider.stories.firstWhere((s) => s.id == storyId);
    } catch (_) {
      story = null;
    }

    if (storyProvider.isLoading) {
      return Scaffold(body: const Center(child: CircularProgressIndicator()));
    }
    if (storyProvider.errorMessage.isNotEmpty) {
      return Scaffold(
        body: Center(child: Text('Error: ${storyProvider.errorMessage}')),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors:
                isDark
                    ? [Colors.grey[900]!, Colors.grey[800]!]
                    : [Colors.blue.shade200, Colors.blue.shade600],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          top: false,
          child:
              story != null
                  ? SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      kToolbarHeight + 16,
                      16,
                      16,
                    ),
                    child: Card(
                      color: Theme.of(context).cardColor.withOpacity(0.9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 6,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                story.photoUrl,
                                fit: BoxFit.cover,
                                height: 300,
                                width: double.infinity,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              story.name,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              story.description,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 16),

                            // (Baru) Tampilkan peta jika koordinat tersedia
                            if (story.lat != null && story.lon != null) ...[
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 200,
                                child: GoogleMap(
                                  myLocationEnabled: true,
                                  myLocationButtonEnabled: true,
                                  initialCameraPosition: CameraPosition(
                                    target: LatLng(story.lat!, story.lon!),
                                    zoom: 15,
                                  ),
                                  markers: {
                                    Marker(
                                      markerId: MarkerId(story.id),
                                      position: LatLng(story.lat!, story.lon!),
                                      onTap: () async {
                                        // 1) Reverse-geocode untuk dapatkan alamat
                                        final addr =
                                            await LocationHelper.reverseGeocode(
                                              story!.lat!,
                                              story.lon!,
                                            );
                                        // 2) Navigasi deklaratif ke sub-route 'addressDialog'
                                        context.pushNamed(
                                          'addressDialog',
                                          pathParameters: {'id': story.id},
                                          extra: addr,
                                        );
                                      },
                                    ),
                                  },
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  )
                  : const Center(child: Text('Story not found')),
        ),
      ),
    );
  }
}
