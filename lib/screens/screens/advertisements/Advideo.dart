import '../../../Models/subscrptions/advertisement_model.dart';
import '../../../Services/Auth_service/food_authservice.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';



class VideoPreviewContainer extends StatefulWidget {
  const VideoPreviewContainer({Key? key}) : super(key: key);

  @override
  State<VideoPreviewContainer> createState() => _VideoPreviewContainerState();
}

class _VideoPreviewContainerState extends State<VideoPreviewContainer> {
  List<Advertisement> ads = [];
  int currentIndex = 0;

  VideoPlayerController? _controller;
  bool isMuted = true;
  bool isLoading = true;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _loadAds();
  }

  Future<void> _loadAds() async {
    try {
      final fetchedAds = await food_Authservice.fetchAdvertisements();

      if (!mounted) return;

      ads = fetchedAds
          .where(
            (ad) =>
                // ignore: unnecessary_null_comparison
                ad.resolution != null &&
                ad.resolution.toLowerCase() == "horizontal",
          )
          .toList();

      if (ads.isNotEmpty) {
        _initializeMedia(0);
      }
    } catch (e) {
      debugPrint("Error loading ads: $e");
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  void _initializeMedia(int index) {
    final ad = ads[index];

    if (ad.type.toLowerCase() == "video") {
      _playVideo(ad.mediaUrl);
    } else {
      _controller?.dispose();
      _controller = null;
      _startImageTimer();
    }
  }

  void _playVideo(String url) {
    _controller?.dispose();

    final controller = VideoPlayerController.networkUrl(Uri.parse(url));
    _controller = controller;

    controller.initialize().then((_) {
      if (!mounted || _isDisposed) return;

      setState(() {});
      controller
        ..setLooping(false)
        ..setVolume(isMuted ? 0 : 1)
        ..play();
    });

    controller.addListener(() {
      if (!mounted || _isDisposed) return;

      if (!controller.value.isPlaying &&
          controller.value.position >= controller.value.duration) {
        _nextAd();
      }
    });
  }

  void _startImageTimer() async {
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted || _isDisposed) return;
    _nextAd();
  }

  void _nextAd() {
    currentIndex = (currentIndex + 1) % ads.length;
    _initializeMedia(currentIndex);
  }

  @override
  void dispose() {
    _isDisposed = true;
    _controller?.removeListener(() {});
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        height: 250,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (ads.isEmpty) {
      return const SizedBox(
        height: 250,
        child: Center(child: Text("No advertisements available")),
      );
    }

    final ad = ads[currentIndex];

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: 4 / 2, // ✅ better for home banner
              child: ad.type.toLowerCase() == "video" && _controller != null
                  ? (_controller!.value.isInitialized
                        ? FittedBox(
                            fit: BoxFit.cover,
                            child: SizedBox(
                              width: _controller!.value.size.width,
                              height: _controller!.value.size.height,
                              child: VideoPlayer(_controller!),
                            ),
                          )
                        : const Center(child: CircularProgressIndicator()))
                  : Image.network(ad.mediaUrl, fit: BoxFit.contain),
            ),
          ),
        ),
      ],
    );
  }
}
