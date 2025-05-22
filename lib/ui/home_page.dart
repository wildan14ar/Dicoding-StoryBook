import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import '../common/preferences_helper.dart';
import '../provider/story_provider.dart';

// Custom widget yang fetch sendiri dan pakai Image.memory
class CustomNetworkImage extends StatelessWidget {
  final String url;
  final double width;
  final double height;
  final BoxFit fit;

  const CustomNetworkImage({
    required this.url,
    required this.width,
    required this.height,
    this.fit = BoxFit.cover,
    Key? key,
  }) : super(key: key);

  Future<Uint8List?> _fetchBytes() async {
    try {
      final resp = await http.get(Uri.parse(url));
      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        return resp.bodyBytes;
      }
    } catch (_) {}
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: _fetchBytes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return SizedBox(
            width: width,
            height: height,
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }
        if (snapshot.data != null) {
          return Image.memory(
            snapshot.data!,
            width: width,
            height: height,
            fit: fit,
          );
        }
        // fallback placeholder
        return Container(
          width: width,
          height: height,
          color: Colors.grey[300],
          child: const Icon(Icons.broken_image, size: 24),
        );
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<StoryProvider>(context, listen: false);
    // Fetch first page
    provider.fetchStories(isInitial: true);

    // Setup infinite scroll
    _scrollController =
        ScrollController()..addListener(() {
          if (_scrollController.position.atEdge &&
              _scrollController.position.pixels != 0 &&
              !provider.isLoading) {
            provider.fetchStories();
          }
        });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final storyProvider = Provider.of<StoryProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Dicoding Story'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () async {
              await PreferencesHelper().removeToken();
              if (!mounted) return;
              context.go('/login');
            },
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Container(
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
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, kToolbarHeight + 16, 16, 16),
            child: Builder(
              builder: (_) {
                if (storyProvider.isLoading && storyProvider.stories.isEmpty) {
                  // Initial loading
                  return const Center(child: CircularProgressIndicator());
                } else if (storyProvider.errorMessage.isNotEmpty) {
                  // Error state
                  return Center(
                    child: Text('Error: ${storyProvider.errorMessage}'),
                  );
                } else if (storyProvider.stories.isEmpty) {
                  // No data
                  return const Center(child: Text('Belum ada cerita.'));
                } else {
                  // Data loaded with possible pagination
                  return ListView.builder(
                    controller: _scrollController,
                    itemCount:
                        storyProvider.stories.length +
                        (storyProvider.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == storyProvider.stories.length) {
                        // Footer loading indicator
                        return const Padding(
                          padding: EdgeInsets.all(8),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      final story = storyProvider.stories[index];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(8),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CustomNetworkImage(
                              url: story.photoUrl,
                              width: 50,
                              height: 50,
                            ),
                          ),
                          title: Text(story.name),
                          subtitle: Text(
                            story.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () => context.push('/detail/${story.id}'),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-story'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
