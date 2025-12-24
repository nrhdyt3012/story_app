import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import '../provider/auth_provider.dart';
import '../provider/upload_provider.dart';
import '../provider/story_provider.dart';

class AddStoryScreen extends StatefulWidget {
  final VoidCallback onUpload;
  final VoidCallback onBack;

  const AddStoryScreen({
    Key? key,
    required this.onUpload,
    required this.onBack,
  }) : super(key: key);

  @override
  State<AddStoryScreen> createState() => _AddStoryScreenState();
}

class _AddStoryScreenState extends State<AddStoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  bool _isCompressing = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<File> _compressImage(File file) async {
    try {
      final bytes = await file.readAsBytes();
      img.Image? image = img.decodeImage(Uint8List.fromList(bytes));

      if (image == null) return file;

      const int maxSizeInBytes = 1024 * 1024;
      int currentSize = await file.length();

      if (currentSize <= maxSizeInBytes) {
        return file;
      }

      int quality = 85;
      List<int> compressedBytes = [];

      if (image.width > 1920 || image.height > 1920) {
        image = img.copyResize(
          image,
          width: image.width > image.height ? 1920 : null,
          height: image.height > image.width ? 1920 : null,
        );
      }

      do {
        compressedBytes = img.encodeJpg(image, quality: quality);

        quality -= 5;

        if (quality < 50) break;

      } while (compressedBytes.length > maxSizeInBytes);

      final compressedFile = File('${file.parent.path}/compressed_${file.uri.pathSegments.last}');
      await compressedFile.writeAsBytes(compressedBytes);

      return compressedFile;
    } catch (e) {
      return file;
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _isCompressing = true;
        });

        File selectedFile = File(image.path);

        final fileSize = await selectedFile.length();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ukuran asli: ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB'),
              duration: const Duration(seconds: 2),
            ),
          );
        }

        if (fileSize > 1024 * 1024) {
          selectedFile = await _compressImage(selectedFile);

          final compressedSize = await selectedFile.length();

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Gambar dikompres menjadi ${(compressedSize / 1024 / 1024).toStringAsFixed(2)} MB',
                ),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        }

        setState(() {
          _imageFile = selectedFile;
          _isCompressing = false;
        });
      }
    } catch (e) {
      setState(() {
        _isCompressing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error memproses gambar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleUpload() async {
    if (_formKey.currentState!.validate() && _imageFile != null) {
      final authProvider = context.read<AuthProvider>();
      final uploadProvider = context.read<UploadProvider>();
      final storyProvider = context.read<StoryProvider>();

      final token = await authProvider.getToken();

      if (token != null) {
        final success = await uploadProvider.uploadStory(
          token,
          _descriptionController.text,
          _imageFile!,
        );

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Story berhasil diupload!'),
              backgroundColor: Colors.green,
            ),
          );

          // Refresh story list
          await storyProvider.fetchStories(token);

          widget.onUpload();
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(uploadProvider.errorMessage ?? 'Upload gagal'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih gambar terlebih dahulu'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Kamera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeri'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Story'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: _isCompressing ? null : _showImageSourceDialog,
                child: Container(
                  height: 300,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: _isCompressing
                      ? const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Mengompres gambar...'),
                    ],
                  )
                      : _imageFile != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      _imageFile!,
                      fit: BoxFit.cover,
                    ),
                  )
                      : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Tap untuk pilih gambar',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Gambar akan otomatis dikompres\njika lebih dari 1MB',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_imageFile != null)
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _imageFile = null;
                    });
                  },
                  icon: const Icon(Icons.close),
                  label: const Text('Hapus Gambar'),
                ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi',
                  hintText: 'Ceritakan tentang momen ini...',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Silakan masukkan deskripsi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Consumer<UploadProvider>(
                builder: (context, uploadProvider, child) {
                  return ElevatedButton(
                    onPressed: uploadProvider.isLoading || _isCompressing
                        ? null
                        : _handleUpload,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: uploadProvider.isLoading
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                        : const Text('Upload Story'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}