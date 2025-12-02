import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:gnbtask/provider/property_provider.dart';
import 'package:gnbtask/Services/permission_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:html' as html;

class ImageUploadScreen extends StatefulWidget {
  final String propertyId;
  final String propertyTitle;

  const ImageUploadScreen({
    super.key,
    required this.propertyId,
    required this.propertyTitle,
  });

  @override
  State<ImageUploadScreen> createState() => _ImageUploadScreenState();
}

class _ImageUploadScreenState extends State<ImageUploadScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _capturedImage;
  Uint8List? _webImageBytes;

  // Camera capture - optimized for web
Future<void> _takePhoto() async {
  if (kIsWeb) {
    final html.InputElement input = html.InputElement(type: 'file');
    input.accept = 'image/*';
    input.capture = 'camera'; // forces webcam on mobile & triggers permission on desktop

    input.onChange.listen((event) {
      final file = input.files?.first;
      if (file != null) {
        final reader = html.FileReader();

        reader.onLoadEnd.listen((event) {
          setState(() {
            _webImageBytes = reader.result as Uint8List?;
            _capturedImage = XFile(file.name);
          });
        });

        reader.readAsArrayBuffer(file);
      }
    });

    input.click(); // triggers browser permission popup
    return;
  }

  // Mobile code (unchanged)
  final hasPermission = await PermissionService().requestCameraPermission();
  if (!hasPermission) return;

  final XFile? photo = await _picker.pickImage(
    source: ImageSource.camera,
    imageQuality: 80,
    maxWidth: 1024,
  );

  if (photo != null) {
    final bytes = await photo.readAsBytes();
    setState(() {
      _capturedImage = photo;
      _webImageBytes = bytes;
    });
  }
}

  // Gallery pick
  Future<void> _pickFromGallery() async {
    // Skip permission check on web (browser handles it)
    if (!kIsWeb) {
      final hasPermission = await PermissionService().requestGalleryPermission();

      if (!hasPermission) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Gallery permission is required. Please enable it in settings."),
              action: SnackBarAction(
                label: "Settings",
                onPressed: () => PermissionService().openSettings(),
              ),
              duration: const Duration(seconds: 5),
            ),
          );
        }
        return;
      }
    }

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1024,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _capturedImage = image;
          _webImageBytes = bytes;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gallery Error: $e")),
        );
      }
    }
  }

  void _clearImage() {
    setState(() {
      _capturedImage = null;
      _webImageBytes = null;
    });
  }

  Future<void> _uploadImage() async {
    if (_capturedImage == null) return;

    final provider = context.read<PropertyProvider>();

    final success = await provider.uploadPropertyImage(
      widget.propertyId,
      _capturedImage!,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Image Uploaded Successfully!"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? "Upload Failed"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<PropertyProvider>().isUploading;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // Define common button style properties for consistency
    final commonButtonStyle = ElevatedButton.styleFrom(
      minimumSize: const Size(0, 56), // Use 0 width with Expanded
      padding: const EdgeInsets.symmetric(vertical: 16),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          iconSize: 32, // Fixed size that works on all platforms
          onPressed: () {
            Navigator.pop(context);
          },
          tooltip: 'Back',
        ),
        titleSpacing: 0,
        title: Text(widget.propertyTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? colorScheme.surfaceVariant
                      : colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: colorScheme.outlineVariant,
                    width: 2,
                  ),
                ),
                child: _capturedImage == null
                    ? _buildPlaceholder(isDark, colorScheme)
                    : _buildPreview(),
              ),
            ),
            const SizedBox(height: 20),
            if (isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_capturedImage == null)
              // === MODIFIED: Buttons for Capture/Pick in a Row ===
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _takePhoto,
                      icon: Icon(kIsWeb ? Icons.videocam : Icons.camera_alt),
                      label: Text(kIsWeb ? "Webcam" : "Camera"),
                      style: commonButtonStyle.copyWith(
                        backgroundColor: MaterialStatePropertyAll(
                          colorScheme.primary,
                        ),
                        foregroundColor: MaterialStatePropertyAll(
                          colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _pickFromGallery,
                      icon: const Icon(Icons.photo_library),
                      label: const Text("Gallery"),
                      style: commonButtonStyle.copyWith(
                        backgroundColor: MaterialStatePropertyAll(
                          colorScheme.secondaryContainer,
                        ),
                        foregroundColor: MaterialStatePropertyAll(
                          colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            else
              // Buttons to Retake/Upload in a Row (Existing structure)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _clearImage,
                      icon: const Icon(Icons.refresh),
                      label: const Text("Retake"),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 56),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        foregroundColor: colorScheme.error,
                        side: BorderSide(color: colorScheme.error, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _uploadImage,
                      icon: const Icon(Icons.cloud_upload),
                      label: const Text("Upload"),
                      style: commonButtonStyle.copyWith(
                        backgroundColor: MaterialStatePropertyAll(
                          colorScheme.primary,
                        ),
                        foregroundColor: MaterialStatePropertyAll(
                          colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }


  Widget _buildPlaceholder(bool isDark, ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            kIsWeb ? Icons.photo_camera : Icons.camera_alt_outlined,
            size: 80,
            color: colorScheme.onSurfaceVariant.withOpacity(0.6),
          ),
          const SizedBox(height: 16),
          Text(
            kIsWeb
                ? "Click 'Webcam' to use camera or 'Gallery' to upload from device"
                : "Tap below to take photo or pick from gallery",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (kIsWeb) ...[
            const SizedBox(height: 12),
            Text(
              "Browser will show camera option when you click Webcam",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                fontSize: 13,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPreview() {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: _webImageBytes != null
            ? Image.memory(_webImageBytes!, fit: BoxFit.contain)
            : const SizedBox.shrink(),
      ),
    );
  }
}
