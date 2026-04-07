import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:media_compressor/media_compressor.dart';

class MediaUtils {
  static final ImagePicker _picker = ImagePicker();

  // ================================================
  // COMPRESS IMAGE FILE (SAFE & COMPATIBLE)
  // ================================================
  static Future<File?> compressImageFile(
      File originalFile, {
        String? purpose,
        int quality = 80,
        int maxWidth = 1200,
        int maxHeight = 1200,
      }) async {
    try {
      // print("🔄 Compressing ${purpose ?? 'image'}");

      await originalFile.length();
      // print(
      //   "📁 Original size: ${(originalSize / 1024).toStringAsFixed(2)} KB",
      // );

      final result = await MediaCompressor.compressImage(
        ImageCompressionConfig(
          path: originalFile.path,
          quality: quality,
          maxWidth: maxWidth,   // ✅ int
          maxHeight: maxHeight, // ✅ int
        ),
      );

      if (result.isSuccess && result.path != null) {
        final compressedFile = File(result.path!);

        if (await compressedFile.exists()) {
          await compressedFile.length();

          // print("✅ Compression successful");
          // print(
          //   "📁 Compressed size: ${(compressedSize / 1024).toStringAsFixed(2)} KB",
          // );
          // print(
          //   "📊 Ratio: ${((compressedSize / originalSize) * 100).toStringAsFixed(1)}%",
          // );

          return compressedFile;
        }
      }

      // print("⚠️ Compression failed → using original file");
      return originalFile;
    } catch (e) {
      // print("❌ Compression error: $e");
      return originalFile;
    }
  }

  // ================================================
  // PICK + COMPRESS IMAGE
  // ================================================
  static Future<File?> pickAndCompressImage({
    required String purpose,
    ImageSource source = ImageSource.gallery,
    int quality = 80,
    int maxWidth = 1200,
    int maxHeight = 1200,
  }) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 90,
        maxWidth: maxWidth.toDouble(),   // ImagePicker requires double
        maxHeight: maxHeight.toDouble(),
      );

      if (pickedFile == null) return null;

      final originalFile = File(pickedFile.path);
      // print("📸 Selected $purpose → ${originalFile.path}");

      return await compressImageFile(
        originalFile,
        purpose: purpose,
        quality: quality,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      );
    } catch (e) {
      // print("❌ Error picking $purpose: $e");
      return null;
    }
  }

  // ================================================
  // FILE SIZE HELPER
  // ================================================
  static Future<double> getFileSizeMB(File file) async {
    final bytes = await file.length();
    return bytes / (1024 * 1024);
  }
}
