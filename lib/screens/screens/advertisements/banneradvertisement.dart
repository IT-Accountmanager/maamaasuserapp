import 'dart:async';

import '../../../Models/promotions_model/promotions_model.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';

class BannerAdvertisement extends StatefulWidget {
  final List<Campaign> ads;
  final double height;

  const BannerAdvertisement({Key? key, required this.ads, this.height = 250})
    : super(key: key);

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

    if ((ad.mediaType ?? '').toLowerCase() == "video") {
      _playVideo(ad.imageUrl ?? '');
    } else {
      _controller?.dispose();
      _controller = null;
      _startImageTimer();
    }
  }

  void _playVideo(String url) {
    _imageTimer?.cancel(); // ✅ stop image timer

    _controller?.removeListener(_videoListener ?? () {});
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

    _videoListener = () {
      if (!mounted || _isDisposed) return;

      final isFinished = controller.value.position >= controller.value.duration;

      if (isFinished && !controller.value.isPlaying) {
        _nextAd();
      }
    };

    controller.addListener(_videoListener!);
  }

  void _startImageTimer() {
    _imageTimer?.cancel(); // ✅ cancel old timer

    _imageTimer = Timer(const Duration(seconds: 5), () {
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

    final ad = widget.ads[currentIndex]; // ✅ FIXED

    return GestureDetector(
      onTap: () {},
      child: SizedBox(
        height: widget.height,
        child:
            (ad.mediaType ?? "").toLowerCase() == "video" && _controller != null
            ? (_controller!.value.isInitialized
                  ? SizedBox.expand(
                      child: FittedBox(
                        fit:
                            BoxFit.cover, // ✅ makes video fullscreen like image
                        child: SizedBox(
                          width: _controller!.value.size.width,
                          height: _controller!.value.size.height,
                          child: VideoPlayer(_controller!),
                        ),
                      ),
                    )
                  : const Center(child: CircularProgressIndicator()))
            : Image.network(
                ad.imageUrl ?? '',
                fit: BoxFit.cover, // ✅ IMPORTANT
                width: double.infinity,
                height: double.infinity,
              ),
      ),
    );
  }
}
