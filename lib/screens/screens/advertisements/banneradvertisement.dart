import 'dart:async';
import '../../../Models/promotions_model/promotions_model.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';

class BannerAdvertisement extends StatefulWidget {
  final List<Campaign> ads;
  final double height;

  const BannerAdvertisement({super.key, required this.ads, this.height = 250});

  @override
  State<BannerAdvertisement> createState() => _BannerAdvertisementState();
}

class _BannerAdvertisementState extends State<BannerAdvertisement> {
  int currentIndex = 0;
  VideoPlayerController? _controller;
  bool isMuted = true;
  bool _isDisposed = false;
  VoidCallback? _videoListener;
  Timer? _imageTimer;

  @override
  void initState() {
    super.initState();
    if (widget.ads.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initializeMedia(0);
      });
    }
  }

  @override
  void dispose() {
    _isDisposed = true;

    _imageTimer?.cancel(); // ✅ IMPORTANT

    if (_videoListener != null) {
      _controller?.removeListener(_videoListener!);
    }

    _controller?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant BannerAdvertisement oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.ads != oldWidget.ads && widget.ads.isNotEmpty) {
      currentIndex = 0;
      _initializeMedia(0);
    }
  }

  void _initializeMedia(int index) {
    final ad = widget.ads[index];

    final isVideo = (ad.mediaType ?? '').toLowerCase() == "video";

    if (isVideo && (ad.imageUrl?.isNotEmpty ?? false)) {
      _playVideo(ad.imageUrl!); // ✅ FIXED
    } else {
      _disposeVideo(); // ✅ centralized cleanup
      _startImageTimer();
    }
  }
  void _disposeVideo() {
    _imageTimer?.cancel();

    if (_videoListener != null && _controller != null) {
      _controller!.removeListener(_videoListener!);
    }

    _controller?.dispose();
    _controller = null;
  }

  void _playVideo(String url) {
    _disposeVideo(); // ✅ always cleanup first

    final controller = VideoPlayerController.networkUrl(Uri.parse(url));
    _controller = controller;

    controller.initialize().then((_) {
      if (!mounted || _isDisposed || _controller != controller) return;

      setState(() {});
      controller
        ..setLooping(false)
        ..setVolume(isMuted ? 0 : 1)
        ..play();
    });

    _videoListener = () {
      if (!mounted || _isDisposed || _controller != controller) return;

      final value = controller.value;

      if (value.isInitialized &&
          value.duration != Duration.zero &&
          value.position >= value.duration &&
          !value.isPlaying) {
        _nextAd();
      }
    };

    controller.addListener(_videoListener!);
  }

  void _startImageTimer() {
    _imageTimer?.cancel(); // ✅ cancel old timer

    _imageTimer = Timer(const Duration(seconds: 6), () {
      if (!mounted || _isDisposed) return;
      _nextAd();
    });
  }

  void _nextAd() {
    if (!mounted || _isDisposed) return;

    currentIndex = (currentIndex + 1) % widget.ads.length;

    setState(() {}); // ✅ ensure UI updates

    _initializeMedia(currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.ads.isEmpty) {
      return SizedBox(
        height: widget.height,
        child: const Center(child: Text("No advertisements available")),
      );
    }

    final ad = widget.ads[currentIndex];

    return GestureDetector(
      onTap: () {},
      child: SizedBox(
        // ✅ ADD THIS BACK
        height: widget.height,
        width: double.infinity,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          switchInCurve: Curves.easeIn,
          switchOutCurve: Curves.easeOut,

          // ✅ OPTIONAL but improves animation smoothness
          layoutBuilder: (currentChild, previousChildren) {
            return Stack(
              alignment: Alignment.center,
              children: [
                ...previousChildren,
                if (currentChild != null) currentChild,
              ],
            );
          },

          child: _buildAdContent(ad), // uses ValueKey inside
        ),
      ),
    );
  }

  Widget _buildAdContent(Campaign ad) {
    final isVideo = (ad.mediaType ?? "").toLowerCase() == "video";

    /// ================= VIDEO =================
    if (isVideo && _controller != null) {
      final controller = _controller!;

      if (!controller.value.isInitialized ||
          controller.value.size.width <= 0 ||
          controller.value.size.height <= 0) {
        return const Center(
          key: ValueKey("video_loader"),
          child: CircularProgressIndicator(),
        );
      }

      return SizedBox.expand(
        key: ValueKey(ad.imageUrl ?? "video"),
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: controller.value.size.width,
            height: controller.value.size.height,
            child: VideoPlayer(controller),
          ),
        ),
      );
    }

    /// ================= IMAGE =================
    final imageUrl = ad.imageUrl;

    if (imageUrl == null || imageUrl.isEmpty) {
      return const Center(
        key: ValueKey("invalid_image"),
        child: Icon(Icons.broken_image),
      );
    }

    return SizedBox.expand(
      key: ValueKey(imageUrl),
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,

        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },

        errorBuilder: (context, error, stackTrace) {
          return const Center(child: Icon(Icons.broken_image));
        },
      ),
    );
  }
}
