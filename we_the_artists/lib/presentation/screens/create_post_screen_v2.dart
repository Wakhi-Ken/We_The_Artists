// ignore_for_file: use_super_parameters, unnecessary_nullable_for_final_variable_declarations, use_build_context_synchronously, avoid_print, curly_braces_in_flow_control_structures

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({Key? key}) : super(key: key);

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();
  final List<XFile> _selectedImages = [];
  final List<XFile> _selectedVideos = [];
  final List<String> _tags = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _contentController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  // IMAGE PICKERS
  Future<void> _pickImages() async {
    final List<XFile>? images = await _picker.pickMultiImage();
    if (images != null && images.isNotEmpty) {
      setState(() => _selectedImages.addAll(images));
    }
  }

  Future<void> _takePhoto() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() => _selectedImages.add(photo));
    }
  }

  // VIDEO PICKER
  Future<void> _pickVideo() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      setState(() => _selectedVideos.add(video));
    }
  }

  // REMOVE MEDIA
  void _removeMedia(int index, String type) {
    setState(() {
      if (type == 'image') _selectedImages.removeAt(index);
      if (type == 'video') _selectedVideos.removeAt(index);
    });
  }

  // TAGS
  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && tag.length <= 20 && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    } else if (tag.length > 20) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tag too long (max 20 characters)')),
      );
    }
  }

  void _removeTag(String tag) => setState(() => _tags.remove(tag));

  // UPLOAD FILES TO FIREBASE STORAGE
  Future<List<String>> _uploadFiles(List<XFile> files, String folder) async {
    List<String> urls = [];
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) throw Exception('User not found.');

    for (var file in files) {
      try {
        final ref = FirebaseStorage.instance.ref().child(
          'posts/${currentUser.uid}/$folder/${DateTime.now().millisecondsSinceEpoch}_${file.name}',
        );

        final task = ref.putFile(File(file.path));

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Center(child: CircularProgressIndicator()),
        );

        final snapshot = await task.whenComplete(() {});
        urls.add(await snapshot.ref.getDownloadURL());

        Navigator.of(context).pop();
      } catch (e) {
        Navigator.of(context).pop();
        print('❌ Failed to upload $folder: $e');
      }
    }
    return urls;
  }

  // SAVE POST
  Future<void> _savePost() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) throw Exception('User not found.');

    if (_selectedImages.isEmpty &&
        _selectedVideos.isEmpty &&
        _contentController.text.trim().isEmpty) {
      throw Exception('Cannot publish empty post');
    }

    final imageUrls = await _uploadFiles(_selectedImages, 'images');
    final videoUrls = await _uploadFiles(_selectedVideos, 'videos');

    await FirebaseFirestore.instance.collection('Posts').add({
      'content': _contentController.text.trim(),
      'imageUrls': imageUrls,
      'videoUrls': videoUrls,
      'tags': _tags,
      'userId': currentUser.uid,
      'displayName': currentUser.displayName ?? '',
      'createdAt': FieldValue.serverTimestamp(),
    });

    print('🎉 Post saved!');
  }

  // PUBLISH POST
  void _publishPost() async {
    if (_contentController.text.trim().isEmpty &&
        _selectedImages.isEmpty &&
        _selectedVideos.isEmpty)
      return;

    try {
      await _savePost();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post published successfully!')),
      );
      Navigator.pop(context);
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to publish post: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final canPublish =
        _contentController.text.isNotEmpty ||
        _selectedImages.isNotEmpty ||
        _selectedVideos.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
        actions: [
          TextButton(
            onPressed: canPublish ? _publishPost : null,
            child: const Text(
              'Publish',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // CONTENT
            TextField(
              controller: _contentController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Share your thoughts about your artwork...',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),

            _buildMediaPreview(),
            const SizedBox(height: 16),

            // MEDIA BUTTONS
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickImages,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Images'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickVideo,
                    icon: const Icon(Icons.video_library),
                    label: const Text('Videos'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _takePhoto,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // TAGS
            const Text(
              'Tags',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tagController,
                    decoration: const InputDecoration(
                      hintText: 'Add a tag',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addTag(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _addTag,
                  icon: const Icon(Icons.add),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            if (_tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _tags
                    .map(
                      (tag) => Chip(
                        label: Text('#$tag'),
                        onDeleted: () => _removeTag(tag),
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // MEDIA PREVIEW
  Widget _buildMediaPreview() {
    List<Widget> previews = [];

    for (int i = 0; i < _selectedImages.length; i++) {
      previews.add(_mediaTile(_selectedImages[i].path, i, 'image'));
    }
    for (int i = 0; i < _selectedVideos.length; i++) {
      previews.add(_mediaTile(_selectedVideos[i].path, i, 'video'));
    }

    if (previews.isEmpty) {
      return Container(
        height: 120,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text('No media selected'),
      );
    }

    return SizedBox(
      height: 120,
      child: ListView(scrollDirection: Axis.horizontal, children: previews),
    );
  }

  Widget _mediaTile(String path, int index, String type) {
    IconData icon;
    if (type == 'image')
      icon = Icons.image;
    else
      icon = Icons.videocam;

    return Stack(
      children: [
        Container(
          width: 120,
          height: 120,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey[300],
            image: type == 'image'
                ? DecorationImage(
                    image: FileImage(File(path)),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: type != 'image'
              ? Center(child: Icon(icon, size: 48, color: Colors.black54))
              : null,
        ),
        Positioned(
          top: 4,
          right: 12,
          child: GestureDetector(
            onTap: () => _removeMedia(index, type),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
