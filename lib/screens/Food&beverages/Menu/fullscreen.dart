import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';

class FullScreenGallery extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const FullScreenGallery({
    super.key,
    required this.images,
    required this.initialIndex,
  });

  @override
  State<FullScreenGallery> createState() => _FullScreenGalleryState();
}

class _FullScreenGalleryState extends State<FullScreenGallery> {
  late PageController _controller;
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    _controller = PageController(initialPage: currentIndex);
  }


  bool _isVideo(String url) {
    final lower = url.toLowerCase();
    return lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.avi') ||
        lower.endsWith('.mkv');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          "${currentIndex + 1} / ${widget.images.length}",
          style: TextStyle(fontSize: 14.sp),
        ),
      ),

      body: Stack(
        children: [
          // 🔹 Full width image viewer
          PageView.builder(
            controller: _controller,
            itemCount: widget.images.length,
            onPageChanged: (index) {
              setState(() => currentIndex = index);
            },
            // itemBuilder: (context, index) {
            //             //   return SizedBox(
            //             //     width: double.infinity,
            //             //     height: double.infinity,
            //             //     child: InteractiveViewer(
            //             //       child: Image.network(
            //             //         widget.images[index],
            //             //         fit: BoxFit.contain, // keeps full image visible
            //             //         width: double.infinity,
            //             //       ),
            //             //     ),
            //             //   );
            //             // },
            itemBuilder: (context, index) {
              final url = widget.images[index];

              return SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: _isVideo(url)
                    ? _VideoPlayerWidget(url: url)
                    : InteractiveViewer(
                        child: Image.network(
                          url,
                          fit: BoxFit.contain,
                          width: double.infinity,
                        ),
                      ),
              );
            },
          ),

          // 🔹 LEFT ARROW (overlay on image)
          if (currentIndex > 0)
            Positioned(
              left: 12.w,
              top: 0,
              bottom: 0,
              child: Center(
                child: _arrowButton(
                  icon: Icons.arrow_back_ios_new,
                  onTap: () {
                    _controller.previousPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                ),
              ),
            ),

          // 🔹 RIGHT ARROW (overlay on image)
          if (currentIndex < widget.images.length - 1)
            Positioned(
              right: 12.w,
              top: 0,
              bottom: 0,
              child: Center(
                child: _arrowButton(
                  icon: Icons.arrow_forward_ios,
                  onTap: () {
                    _controller.nextPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _arrowButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(10.r),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 18.sp),
      ),
    );
  }
}

class _VideoPlayerWidget extends StatefulWidget {
  final String url;

  const _VideoPlayerWidget({required this.url});

  @override
  State<_VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<_VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.network(widget.url)
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlay() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        isPlaying = false;
      } else {
        _controller.play();
        isPlaying = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return Center(child: CircularProgressIndicator());
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: VideoPlayer(_controller),
        ),

        // ▶ Play/Pause Button
        GestureDetector(
          onTap: _togglePlay,
          child: Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
      ],
    );
  }
}
