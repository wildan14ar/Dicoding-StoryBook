import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // Added for LatLng
import '../provider/story_provider.dart';
import '../build_config.dart';
import '../widgets/map_picker.dart';
import '../common/location_helper.dart';
import '../widgets/address_info_widget.dart';

class AddStoryPage extends StatefulWidget {
  const AddStoryPage({super.key});

  @override
  State<AddStoryPage> createState() => _AddStoryPageState();
}

class _AddStoryPageState extends State<AddStoryPage> {
  final descriptionController = TextEditingController();
  File? imageFile;
  final picker = ImagePicker();
  LatLng? _selectedLocation; // Ditambahkan untuk paid variant
  String? _address; // Ditambahkan untuk menampilkan alamat

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(bool fromCamera) async {
    final picked = await picker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
    );
    if (picked != null) {
      setState(() => imageFile = File(picked.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final storyProvider = Provider.of<StoryProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Add New Story'),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors:
                isDark
                    ? [Colors.grey[900]!, Colors.grey[800]!]
                    : [Colors.purple.shade200, Colors.purple.shade600],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, kToolbarHeight + 16, 16, 16),
            child: Card(
              color: Theme.of(context).cardColor.withOpacity(0.9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 6,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Image preview
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey),
                      ),
                      clipBehavior: Clip.hardEdge,
                      child:
                          imageFile == null
                              ? const Center(child: Icon(Icons.image, size: 48))
                              : Image.file(imageFile!, fit: BoxFit.cover),
                    ),
                    const SizedBox(height: 16),

                    // Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => _pickImage(true),
                          icon: const Icon(Icons.camera_alt_outlined),
                          label: const Text('Camera'),
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => _pickImage(false),
                          icon: const Icon(Icons.photo_library_outlined),
                          label: const Text('Gallery'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Description
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        prefixIcon: const Icon(Icons.text_fields),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),

                    // Picker lokasi hanya untuk paid variant
                    if (BuildConfig.flavor == AppFlavor.paid) ...[
                      const SizedBox(height: 16),
                      const Text('Pilih Lokasi:'),
                      MapPicker(
                        initial: _selectedLocation,
                        onPicked: (pos) async {
                          setState(() => _selectedLocation = pos);
                          _address = await LocationHelper.reverseGeocode(
                            pos.latitude,
                            pos.longitude,
                          );
                        },
                      ),
                      if (_address != null) ...[
                        const SizedBox(height: 8),
                        AddressInfoWidget(address: _address!),
                      ],
                      const SizedBox(height: 24),
                    ],

                    // Upload button
                    SizedBox(
                      height: 48,
                      child:
                          storyProvider.isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () async {
                                  if (imageFile == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Please select an image first',
                                        ),
                                      ),
                                    );
                                    return;
                                  }
                                  final success = await storyProvider.addStory(
                                    descriptionController.text,
                                    imageFile!.path,
                                    lat: _selectedLocation?.latitude,
                                    lon: _selectedLocation?.longitude,
                                  );
                                  if (success && mounted) {
                                    await storyProvider.fetchStories(
                                      isInitial: true,
                                    );
                                    context.go('/home');
                                  } else if (!success) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          storyProvider.errorMessage,
                                        ),
                                      ),
                                    );
                                  }
                                },
                                child: const Text(
                                  'Upload',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
