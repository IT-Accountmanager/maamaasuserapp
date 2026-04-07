import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

class UploadableProfileAvatar extends StatefulWidget {
  final String heroTag;
  final Function(File) onImageSelected;
  final Uint8List? imageBytes;
  final String? networkImageUrl; // 👈 add this

  const UploadableProfileAvatar({
    Key? key,
    required this.heroTag,
    required this.onImageSelected,
    this.imageBytes,
    this.networkImageUrl,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _UploadableProfileAvatarState createState() =>
      _UploadableProfileAvatarState();
}

class _UploadableProfileAvatarState extends State<UploadableProfileAvatar> {
  File? _imageFile;
  final picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      _imageFile = File(pickedImage.path);
      setState(() {}); // Refresh UI with new image
      widget.onImageSelected(_imageFile!);
    }
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider? imageProvider;

    if (_imageFile != null) {
      imageProvider = FileImage(_imageFile!);
    } else if (widget.imageBytes != null) {
      imageProvider = MemoryImage(widget.imageBytes!);
    } else if (widget.networkImageUrl != null &&
        widget.networkImageUrl!.isNotEmpty) {
      imageProvider = NetworkImage(widget.networkImageUrl!);
    }

    return Stack(
      children: [
        Hero(
          tag: widget.heroTag,
          child: CircleAvatar(
            radius: 50.r,
            backgroundImage: imageProvider,
            backgroundColor: Colors.grey[300],
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: InkWell(
            onTap: _pickImage,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // ignore: deprecated_member_use
                color: Colors.black.withOpacity(0.6),
              ),
              child: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
