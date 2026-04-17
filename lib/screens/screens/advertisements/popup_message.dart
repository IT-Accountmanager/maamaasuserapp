import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../Models/promotions_model/promotions_model.dart';

class PromotionPopup {
  static void show(BuildContext context, Campaign ads) {
    final screenHeight = MediaQuery.of(context).size.height;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final url = ads.imageUrl ?? '';

        // ✅ Robust detection
        final isVideo =
            (ads.mediaType?.toUpperCase() == "VIDEO") ||
            url.toLowerCase().contains(".mp4");

        return Container(
          height: screenHeight * 0.60,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            children: [
              /// MEDIA SECTION
              Expanded(
                flex: 9,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      child: SizedBox.expand(
                        child: isVideo
                            ? _VideoPlayerWidget(url: url)
                            : Image.network(
                                url,
                                fit: BoxFit.contain,

                                /// ✅ Loader
                                loadingBuilder: (context, child, progress) {
                                  if (progress == null) return child;
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                },

                                /// ✅ Error fallback
                                errorBuilder: (context, error, stackTrace) {
                                  return const Center(
                                    child: Icon(Icons.broken_image, size: 40),
                                  );
                                },
                              ),
                      ),
                    ),

                    /// ❌ Close Button
                    Positioned(
                      right: 12,
                      top: 12,
                      child: InkWell(
                        onTap: () => Navigator.pop(context),
                        child: const CircleAvatar(
                          radius: 14,
                          backgroundColor: Colors.black54,
                          child: Icon(
                            Icons.close,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    /// 🔥 Hot Deal Badge
                    Positioned(
                      left: 12,
                      top: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.red, Colors.orange],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text(
                          '🔥 Hot Deal',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// 🎥 VIDEO PLAYER WIDGET
class _VideoPlayerWidget extends StatefulWidget {
  final String url;

  const _VideoPlayerWidget({required this.url});

  @override
  State<_VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<_VideoPlayerWidget> {
  VideoPlayerController? _controller;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.network(widget.url)
      ..initialize()
          .then((_) {
            if (!mounted) return;
            setState(() {});
            _controller?.play();
            _controller?.setLooping(true);
          })
          .catchError((e) {
            setState(() {
              _hasError = true;
            });
          });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return const Center(child: Icon(Icons.error, size: 40));
    }

    if (_controller == null || !_controller!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return AspectRatio(
      aspectRatio: _controller!.value.aspectRatio,
      child: VideoPlayer(_controller!),
    );
  }
}
