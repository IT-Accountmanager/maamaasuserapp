import 'dart:math';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:maamaas/Services/App_color_service/app_colours.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../Services/Auth_service/promotion_services_Authservice.dart';
import '../../../Models/promotions_model/promotions_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:share_plus/share_plus.dart';
import '../../../main.dart';
import '../../../widgets/signinrequired.dart';
import 'package:flutter/material.dart';
import '../../foodmainscreen.dart';
import 'enquiryscreen.dart';
import 'dart:async';
import 'dart:io';

class ReelsScreen extends StatefulWidget {
  final int? campaignId;
  const ReelsScreen({super.key, this.campaignId});

  @override
  ReelsScreenState createState() => ReelsScreenState();
}

class ReelsScreenState extends State<ReelsScreen>
    with WidgetsBindingObserver, RouteAware {
  // ── Controllers ─────────────────────────────────────────────────────────────
  final PageController _pageController = PageController();

  /// One controller per page-index. Disposed before re-creation.
  final Map<int, VideoPlayerController> _videoControllers = {};

  // ── Timer ───────────────────────────────────────────────────────────────────
  Timer? _autoScrollTimer;

  // ── Data ────────────────────────────────────────────────────────────────────
  List<Campaign> campaigns = [];
  bool isLoading = true;
  int _currentPage = 0;

  Interest? _selectedInterest;
  List<Interest> _allInterests = [];

  // ── Analytics ────────────────────────────────────────────────────────────────
  final Map<int, int> _imageDisplayTime = {};
  final Map<int, int> _watchDuration = {};
  DateTime? _videoStartTime;
  final Set<int> _sentCampaignAnalytics = {};
  final Set<int> _likedCampaigns = {};

  // ── UI state ─────────────────────────────────────────────────────────────────
  /// True when the CURRENT page's media is manually paused by user tap.
  bool _isPaused = false;

  /// Which page indexes have their description expanded.
  final Set<int> _expandedDescriptions = {};

  /// Temporarily show the play/pause overlay icon.
  bool _showPauseIcon = false;

  /// Tracks whether this screen is the topmost route (not covered by another).
  bool _isScreenActive = true;

  /// Fetch-round token: incremented on each _fetchCampaigns call so stale
  /// async continuations know they should abort.
  int _fetchToken = 0;

  // ── Interest icons ───────────────────────────────────────────────────────────
  final Map<Interest, IconData> _interestIcons = {
    Interest.JOBS: Icons.work,
    Interest.FOOD: Icons.fastfood,
    Interest.EDUCATION: Icons.school,
    Interest.OFFERS: Icons.local_offer,
    Interest.REAL_ESTATE: Icons.home_work,
    Interest.ONLINE_COURSES: Icons.menu_book,
    Interest.BAKERY: Icons.cake,
    Interest.HEALTH: Icons.health_and_safety,
    Interest.TRAVEL: Icons.flight,
    Interest.ENTERTAINMENT: Icons.movie,
  };

  // ── Lifecycle ────────────────────────────────────────────────────────────────

  bool _isRefreshing = false;

  Future<void> _handleRefresh() async {
    if (_isRefreshing) return;

    _isRefreshing = true;

    debugPrint("🔄 Pull-to-refresh triggered");

    await _fetchCampaigns(); // reshuffle happens here

    _isRefreshing = false;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _fetchCampaigns();
  }

  @override
  void deactivate() {
    _isScreenActive = false;
    pauseAllVideos();
    _autoScrollTimer?.cancel();
    super.deactivate();
  }

  @override
  void activate() {
    super.activate();
    _isScreenActive = true;
    // Resume only if user had NOT manually paused
    if (!_isPaused) {
      resumeCurrentVideo();
    }
    _startAutoScrollTimer();
  }

  /// Called when the OS moves the whole app to background / foreground.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      for (final controller in _videoControllers.values) {
        if (controller.value.isInitialized) {
          controller.pause();
          controller.setVolume(0);
        }
      }

      _autoScrollTimer?.cancel();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _autoScrollTimer?.cancel();
    // Dispose all controllers synchronously — no risk of sound leaks after this
    for (final c in _videoControllers.values) {
      c.dispose();
    }
    _videoControllers.clear();
    _pageController.dispose();
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  // ── Video helpers ────────────────────────────────────────────────────────────

  /// Pause only the current page's video (not all).
  void pauseAllVideos() {
    for (final controller in _videoControllers.values) {
      if (controller.value.isInitialized) {
        controller.pause();
      }
    }
  }

  /// Resume only the current page's video.
  void resumeCurrentVideo() {
    final controller = _videoControllers[_currentPage];
    if (controller != null &&
        controller.value.isInitialized &&
        !controller.value.isPlaying) {
      controller.play();
    }
  }

  /// Stop + seek-to-zero a specific page's video (called when leaving that page).
  void _stopVideo(int index) {
    final controller = _videoControllers[index];
    if (controller != null) {
      controller.pause();
      controller.seekTo(Duration.zero);
    }
  }

  /// Dispose a specific controller and remove it from the map.
  void _disposeController(int index) {
    final controller = _videoControllers.remove(index);
    controller?.dispose();
  }

  @override
  void didPushNext() {
    _isScreenActive = false;
    _autoScrollTimer?.cancel();

    pauseAllVideos();

    for (final controller in _videoControllers.values) {
      controller.setVolume(0);
    }
  }

  @override
  void didPopNext() {
    // 🔥 Returned to this screen
    _isScreenActive = true;
    if (!_isPaused) {
      resumeCurrentVideo();
    }
    _startAutoScrollTimer();
  }

  /// Initialize (or re-initialize) the video for [index].
  /// FIX 6: Always disposes an existing controller first so revisiting
  ///         a page always starts from the beginning cleanly.
  Future<void> _initializeVideo(int index, {required int token}) async {
    if (!mounted) return;
    final url = campaigns[index].imageUrl ?? '';
    if (!isVideo(url)) return;

    // Dispose any existing controller for this index before creating a new one
    _disposeController(index);

    final controller = VideoPlayerController.networkUrl(Uri.parse(url));

    try {
      await controller.initialize();
    } catch (e) {
      debugPrint('❌ Video init error [$index]: $e');
      controller.dispose();
      return;
    }

    // FIX 2/3: Abort if a new fetch round started while we were initializing,
    //           or if the widget was disposed.
    if (!mounted || _fetchToken != token) {
      controller.dispose();
      return;
    }

    // Also abort if the user already swiped away from this page
    if (_currentPage != index) {
      controller.dispose();
      return;
    }

    controller.setLooping(false);

    // Only play if screen is active and user hasn't manually paused
    if (_isScreenActive && !_isPaused) {
      pauseAllVideos();
      controller.play();
    }
    _sendAnalytics(index);

    _videoControllers[index] = controller;

    // Listen for video end → auto-advance
    controller.addListener(() {
      if (!mounted) return;
      final val = controller.value;
      if (val.isInitialized &&
          !val.isPlaying &&
          val.position >= val.duration &&
          val.duration > Duration.zero &&
          _isScreenActive &&
          !_isPaused) {
        _nextPage();
      }
    });

    if (mounted) setState(() {});
  }

  Future<void> _fetchCampaigns() async {
    if (!mounted) return;

    final int token = ++_fetchToken;

    setState(() => isLoading = true);

    _autoScrollTimer?.cancel();
    _imageDisplayTime.clear();

    // Dispose all video controllers
    for (final c in _videoControllers.values) {
      c.dispose();
    }
    _videoControllers.clear();

    _currentPage = 0;
    _isPaused = false;
    _expandedDescriptions.clear();

    if (_pageController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_pageController.hasClients) {
          _pageController.jumpToPage(0);
        }
      });
    }

    try {
      final result = await promotion_Authservice.fetchcampaign();

      if (!mounted || _fetchToken != token) return;

      // ── STEP 1: Base filter ───────────────────────────────
      final baseCampaigns = result.where((c) {
        return c.addDisplayPosition == AddDisplayPosition.ADD_SCREEN &&
            c.medium == Medium.APP;
      }).toList();

      // ── STEP 2: Extract interests ─────────────────────────
      final Set<Interest> interestSet = {};
      for (final c in baseCampaigns) {
        if (c.interests != null) {
          interestSet.addAll(c.interests!);
        }
      }
      _allInterests = interestSet.toList();

      // ── STEP 3: Apply interest filter ─────────────────────
      campaigns = baseCampaigns.where((c) {
        if (_selectedInterest == null) return true;
        return c.interests?.contains(_selectedInterest) ?? false;
      }).toList();

      // ── STEP 4: 🔥 RANDOMIZE ORDER ────────────────────────
      campaigns.shuffle(Random(DateTime.now().millisecondsSinceEpoch));

      // ── STEP 5: Seed liked state ─────────────────────────
      _likedCampaigns.clear();
      for (final c in campaigns) {
        if (c.likedByCurrentUser == true) {
          _likedCampaigns.add(c.campaignId);
        }
      }

      _sentCampaignAnalytics.clear();
      _videoStartTime = campaigns.isNotEmpty ? DateTime.now() : null;

      // ── STEP 6: Init first video ─────────────────────────
      if (campaigns.isNotEmpty) {
        await _initializeVideo(0, token: token);
        _sendAnalytics(0);
      }

      if (!mounted || _fetchToken != token) return;

      _startAutoScrollTimer();
    } catch (e) {
      debugPrint('❌ Campaign API Error: $e');
    } finally {
      if (mounted && _fetchToken == token) {
        setState(() => isLoading = false);
      }
    }
  }

  void setScreenActive(bool active) {
    _isScreenActive = active;

    if (!active) {
      debugPrint("⛔ Reels paused (tab hidden)");
      _autoScrollTimer?.cancel();

      for (final controller in _videoControllers.values) {
        if (controller.value.isInitialized) {
          controller.pause();
          controller.setVolume(0); // 🔥 IMPORTANT
        }
      }
    } else {
      debugPrint("▶️ Reels resumed (tab visible)");

      for (final controller in _videoControllers.values) {
        if (controller.value.isInitialized) {
          controller.setVolume(1);
        }
      }

      if (!_isPaused) {
        resumeCurrentVideo();
        _startAutoScrollTimer();
      }
    }
  }

  // ── Auto-scroll timer ────────────────────────────────────────────────────────

  void _startAutoScrollTimer() {
    _autoScrollTimer?.cancel();

    _autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || !_isScreenActive || _isPaused) {
        debugPrint("⛔ Timer blocked (inactive screen)");
        return;
      }

      if (campaigns.isEmpty || _currentPage >= campaigns.length) return;

      final campaign = campaigns[_currentPage];

      if ((campaign.mediaType ?? '').toLowerCase() == 'image') {
        _imageDisplayTime[_currentPage] =
            (_imageDisplayTime[_currentPage] ?? 0) + 1;

        final elapsed = _imageDisplayTime[_currentPage]!;

        if (elapsed == 4) _sendAnalytics(_currentPage);
        if (elapsed >= 5) _nextPage();
      }
    });
  }

  void _nextPage() {
    if (!_pageController.hasClients) return;
    if (_currentPage < campaigns.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _pageController.jumpToPage(0);
    }
  }

  // ── Analytics ────────────────────────────────────────────────────────────────

  int _calculateWatchDuration(int index) {
    if (_videoStartTime == null) return 0;
    final seconds = DateTime.now().difference(_videoStartTime!).inSeconds;
    _watchDuration[index] = seconds;
    return seconds;
  }

  double _calculateScrollDepth(int index) {
    final controller = _videoControllers[index];
    if (controller == null || !controller.value.isInitialized) return 0;
    final total = controller.value.duration.inSeconds;
    final watched = controller.value.position.inSeconds;
    if (total == 0) return 0;
    return (watched / total) * 100;
  }

  double _calculateImageScrollDepth(int index) {
    final watched = _imageDisplayTime[index] ?? 0;
    return (watched / 5) * 100;
  }

  Future<Map<String, dynamic>> _buildPayload(int campaignId) async {
    final prefs = await SharedPreferences.getInstance();
    final customerId = prefs.getString('customerId');
    final deviceType = Platform.isAndroid
        ? 'ANDROID'
        : Platform.isIOS
        ? 'IOS'
        : 'UNKNOWN';
    return {
      'campaignId': campaignId,
      'customerId': customerId,
      'deviceType': deviceType,
    };
  }

  Future<void> _sendAnalytics(int index) async {
    // 🔥 ADD THIS
    if (!_isScreenActive || ModalRoute.of(context)?.isCurrent != true) {
      return;
    }
    if (!_isScreenActive) {
      debugPrint("⛔ Analytics blocked (screen inactive)");
      return;
    }
    if (campaigns.isEmpty || index >= campaigns.length) return;

    final campaign = campaigns[index];

    if (_sentCampaignAnalytics.contains(campaign.campaignId)) {
      debugPrint("⚠️ Already sent for campaign ${campaign.campaignId}");
      return;
    }

    if (campaigns.isEmpty || index >= campaigns.length) {
      debugPrint("⚠️ Invalid index or empty campaigns");
      return;
    }

    if (_sentCampaignAnalytics.contains(campaign.campaignId)) {
      debugPrint("⚠️ Already sent for campaign ${campaign.campaignId}");
      return;
    }

    debugPrint("🚀 Sending analytics for index: $index");
    debugPrint("🎯 Campaign ID: ${campaign.campaignId}");

    _sentCampaignAnalytics.add(campaign.campaignId);

    if (mounted) {
      setState(() {
        campaigns[index].viewedByCurrentUser = true;
        campaigns[index].viewsCount = (campaigns[index].viewsCount ?? 0) + 1;
      });
    }

    final isVideoMedia = isVideo(campaign.imageUrl);
    final duration = _calculateWatchDuration(index);
    final scrollDepth = isVideoMedia
        ? _calculateScrollDepth(index)
        : _calculateImageScrollDepth(index);

    final payload = await _buildPayload(campaign.campaignId);

    debugPrint("📦 Base Payload: $payload");

    payload.addAll({
      'distanceKm': 0,
      'durationSeconds': duration,
      'scrollDepthPercent': scrollDepth.clamp(0, 100).toInt(),
    });

    debugPrint("📦 Final Payload: $payload");

    try {
      debugPrint("📡 Calling API...");
      await promotion_Authservice.sendViewAnalytics(payload);
      debugPrint("✅ Analytics API SUCCESS");
    } catch (e, s) {
      _sentCampaignAnalytics.remove(campaign.campaignId);
      debugPrint("❌ Analytics FAILED: $e");
      debugPrint("📚 Stack: $s");
    }
  }
  // ── Helpers ──────────────────────────────────────────────────────────────────

  bool isVideo(String? url) {
    if (url == null) return false;
    final lower = url.toLowerCase();
    return lower.endsWith('.mp4') || lower.contains('.mp4?');
  }

  String getLimitedText(String text, {int wordLimit = 15}) {
    final words = text.split(' ');
    if (words.length <= wordLimit) return text;
    return '${words.take(wordLimit).join(' ')}...';
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  void _handleCTA(Campaign campaign) async {
    if (campaign.goal != Goal.LEADS) return;

    final subGoal = campaign.subGoal;
    final cta = campaign.callToAction;

    // 📱 WhatsApp
    if (subGoal == SubGoal.GET_MORE_WHATSAPP_MESSAGE &&
        cta == CallToAction.SEND_MESSAGE) {
      final phone = campaign.mobileNumber ?? '';

      final message =
          "Hi there 😊\n"
          "I recently saw your services and they look interesting!\n"
          "Can you please provide more information? 😊;.\n"
          "Thanks!";

      final encodedMessage = Uri.encodeComponent(message);

      final url = "https://wa.me/$phone?text=$encodedMessage";

      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else {
        debugPrint("❌ Could not launch WhatsApp");
      }

      return;
    }

    // 📞 Phone Call
    if (subGoal == SubGoal.GET_MORE_CALLS && cta == CallToAction.CONTACT_US) {
      final phone = campaign.mobileNumber ?? '';
      final url = "tel:$phone";

      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      }
      return;
    }

    // 🌐 Website
    if (subGoal == SubGoal.GET_MORE_WEBSITE_VISITORS &&
        [
          CallToAction.APPLY_NOW,
          CallToAction.BOOK_NOW,
          CallToAction.WATCH_MORE,
          CallToAction.LEARN_MORE,
        ].contains(cta)) {
      final url = campaign.mediaLink ?? ''; // ✅ FIXED (not mediaLink)

      if (url.isNotEmpty && await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      }
      return;
    }

    // 📝 Leads Form
    if (subGoal == SubGoal.GET_MORE_LEADS) {
      if (campaign.appType == AppType.FOOD_AND_BEVERAGES) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EnquiryScreen(
              campaignId: campaign.campaignId,
              callToAction: campaign.callToAction ?? CallToAction.APPLY_NOW,
            ),
          ),
        );
      } else if (campaign.appType == AppType.CATERINGS_SERVICES) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EnquiryFormScreen(vendorId: campaign.vendorId),
          ),
        );
        debugPrint("📦 Campaign VendorId → ${campaign.vendorId}");
      }
      return;
    }
  }

  String _getCTAText(Campaign campaign) {
    switch (campaign.callToAction) {
      case CallToAction.SEND_MESSAGE:
        return "Send Message";
      case CallToAction.CONTACT_US:
        return "Call Now";
      case CallToAction.APPLY_NOW:
        return "Apply Now";
      case CallToAction.BOOK_NOW:
        return "Book Now";
      case CallToAction.WATCH_MORE:
        return "Watch More";
      case CallToAction.LEARN_MORE:
        return "Learn More";
      default:
        return "Get Quote";
    }
  }

  @override
  Widget build(BuildContext context) {
    // FIX 10: PopScope replaces deprecated WillPopScope
    return PopScope(
      onPopInvoked: (didPop) async {
        if (didPop) await _sendAnalytics(_currentPage);
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: _buildCategoryBar(),
        body: AuthGuard(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : campaigns.isEmpty
              ? _buildEmptyState()
              : Stack(
                  children: [
                    NotificationListener<ScrollNotification>(
                      onNotification: (notification) {
                        if (notification is OverscrollNotification) {
                          if (_currentPage == 0 &&
                              notification.overscroll < 0) {
                            _handleRefresh();
                          }
                        }
                        return false;
                      },
                      child: PageView.builder(
                        scrollDirection: Axis.vertical,
                        controller: _pageController,
                        itemCount: campaigns.length,
                        onPageChanged: (index) async {
                          final leaving = _currentPage;
                          _sendAnalytics(leaving);

                          _stopVideo(leaving);

                          _isPaused = false;
                          _showPauseIcon = false;

                          _currentPage = index;
                          _videoStartTime = DateTime.now();

                          await _initializeVideo(index, token: _fetchToken);
                          _sendAnalytics(index);
                        },
                        itemBuilder: (_, index) {
                          return _buildMediaItem(index);
                        },
                      ),
                    ),

                    /// ✅ 🔥 FULL SCREEN LOADER OVERLAY (NO BLACK SCREEN)
                    if (isLoading)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black.withOpacity(0.4),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                    /// 🔄 Pull-to-refresh small loader
                    if (_isRefreshing)
                      const Positioned(
                        top: 40,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      ),
                  ],
                ),
        ),
      ),
    );
  }

  // ── App-bar / category filter ─────────────────────────────────────────────

  PreferredSizeWidget _buildCategoryBar() {
    return AppBar(
      backgroundColor: Colors.white,
      toolbarHeight: 90,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Colors.black,
          size: 20,
        ),
        onPressed: () => Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => MainScreenfood()),
          (r) => false,
        ),
      ),
      title: SizedBox(
        height: 70,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            _buildInterestItem(null, 'All'),
            ..._allInterests.map(
              (interest) => _buildInterestItem(
                interest,
                interest.name.replaceAll('_', ' '),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInterestItem(Interest? interest, String title) {
    final bool selected = _selectedInterest == interest;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedInterest = interest);
        _fetchCampaigns();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: selected
                  ? AppColors.primary
                  : Colors.grey.shade300,
              child: interest == null
                  ? const Icon(Icons.apps, color: Colors.black)
                  : Icon(
                      _interestIcons[interest] ?? Icons.category,
                      color: Colors.black,
                    ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: selected ? AppColors.primary : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Empty state ──────────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.hourglass_empty, size: 60, color: Colors.grey),
          const SizedBox(height: 12),
          const Text(
            'No campaigns available',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please check back later',
            style: TextStyle(fontSize: 14, color: Colors.white54),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _fetchCampaigns,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  // ── Media item ───────────────────────────────────────────────────────────────

  /// FIX 3: Takes only [index] — reads live data from campaigns[index] each build.
  Widget _buildMediaItem(int index) {
    // Always read from the live list so setState changes are immediately visible
    final campaign = campaigns[index];
    final isExpanded = _expandedDescriptions.contains(index);
    final description = campaign.description ?? '';
    final url = campaign.imageUrl ?? '';
    final isVideoMedia = isVideo(url);

    return GestureDetector(
      // FIX 5/11: Toggle pause only for the current visible page
      onTap: () {
        if (index != _currentPage) return; // safety guard
        setState(() {
          _isPaused = !_isPaused;
          _showPauseIcon = true;
        });

        final controller = _videoControllers[index];
        if (isVideoMedia) {
          if (_isPaused) {
            controller?.pause();
          } else {
            controller?.play();
          }
        }

        // Hide overlay after 800 ms
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) setState(() => _showPauseIcon = false);
        });
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1️⃣ Media (image or video) — always at the bottom
          isVideoMedia
              ? _buildVideo(index)
              : Image.network(
                  url,
                  fit: BoxFit.contain,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (_, __, ___) => const Center(
                    child: Icon(
                      Icons.broken_image,
                      size: 50,
                      color: Colors.white54,
                    ),
                  ),
                ),

          // 2️⃣ Full-screen bottom gradient overlay — covers entire lower half
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.4, 1.0], // starts fading at 40% down
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.80), // strong dark at the bottom
                  ],
                ),
              ),
            ),
          ),

          // 3️⃣ Play/pause icon
          if (_showPauseIcon && index == _currentPage)
            Center(
              child: AnimatedOpacity(
                opacity: 1.0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.black45,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isPaused ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
              ),
            ),

          // 4️⃣ Right action buttons (like + share)
          // Positioned(
          //   right: 16,
          //   bottom: 160,
          //   child: Column(
          //     children: [
          //       _buildLikeButton(index, campaign),
          //       const SizedBox(height: 16),
          //       _buildShareButton(index, campaign),
          //     ],
          //   ),
          // ),

          // 5️⃣ Campaign name + description — plain Column, NO DecoratedBox here
          Positioned(
            left: 16,
            right: 90,
            bottom: 120,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  campaign.campaignName ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        blurRadius: 6,
                        color: Colors.black54,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isExpanded) {
                        _expandedDescriptions.remove(index);
                        if (!_isPaused) _videoControllers[index]?.play();
                      } else {
                        _expandedDescriptions.add(index);
                        _videoControllers[index]?.pause();
                      }
                    });
                  },
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: isExpanded
                              ? description
                              : getLimitedText(description, wordLimit: 15),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        if (description.split(' ').length > 15)
                          TextSpan(
                            text: isExpanded ? '  Show less' : '  Read more',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 6️⃣ CTA button
          if (campaign.goal == Goal.LEADS)
            Positioned(
              left: 16,
              right: 16,
              bottom: 20,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () => _handleCTA(campaign),
                child: Text(
                  _getCTAText(campaign),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Like button ──────────────────────────────────────────────────────────────
  // FIX 3: Reads campaigns[index] directly — not a stale captured reference.

  Widget _buildLikeButton(int index, Campaign campaign) {
    final liked = campaigns[index].likedByCurrentUser == true;
    return Column(
      children: [
        IconButton(
          icon: Icon(
            liked ? Icons.favorite : Icons.favorite_border,
            color: liked ? Colors.red : Colors.white,
            size: 32,
          ),
          onPressed: liked
              ? null // already liked — no double-like
              : () async {
                  // Optimistic UI update immediately
                  setState(() {
                    campaigns[index].likedByCurrentUser = true;
                    campaigns[index].likesCount =
                        (campaigns[index].likesCount ?? 0) + 1;
                    _likedCampaigns.add(campaigns[index].campaignId);
                  });

                  final payload = await _buildPayload(
                    campaigns[index].campaignId,
                  );
                  try {
                    await promotion_Authservice.sendLikeAnalytics(payload);
                    debugPrint('✅ Like sent');
                  } catch (e) {
                    // Rollback on failure
                    if (mounted && index < campaigns.length) {
                      setState(() {
                        campaigns[index].likedByCurrentUser = false;
                        campaigns[index].likesCount =
                            ((campaigns[index].likesCount ?? 1) - 1).clamp(
                              0,
                              999999,
                            );
                        _likedCampaigns.remove(campaigns[index].campaignId);
                      });
                    }
                    debugPrint('❌ Like API error: $e');
                  }
                },
        ),
        Text(
          '${campaigns[index].likesCount ?? 0}',
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ],
    );
  }

  Future<String> createDynamicLink(int campaignId) async {
    try {
      final params = DynamicLinkParameters(
        uriPrefix: 'https://maamaas.page.link',
        link: Uri.parse('https://maamaas.com/campaign?id=$campaignId'),
        androidParameters: const AndroidParameters(
          packageName: 'com.maamaas.app',
        ),
        iosParameters: const IOSParameters(bundleId: 'com.maamaas.app'),
      );

      final shortLink = await FirebaseDynamicLinks.instance.buildShortLink(
        params,
      );

      return shortLink.shortUrl.toString();
    } catch (e) {
      debugPrint("⚠️ Short link failed, using long link");

      final fallback = await FirebaseDynamicLinks.instance.buildLink(
        DynamicLinkParameters(
          uriPrefix: 'https://maamaas.page.link',
          link: Uri.parse('https://maamaas.com/campaign?id=$campaignId'),
          androidParameters: const AndroidParameters(
            packageName: 'com.maamaas.app',
          ),
        ),
      );

      return fallback.toString();
    }
  }

  // ── Share button ─────────────────────────────────────────────────────────────

  Widget _buildShareButton(int index, Campaign campaign) {
    return Column(
      children: [
        IconButton(
          icon: const Icon(Icons.share, color: Colors.white, size: 30),

          onPressed: () async {
            final dynamicLink = await createDynamicLink(campaign.campaignId);

            final message =
                '🔥 Check this campaign!\n\n'
                '👉 $dynamicLink';
            debugPrint("Generated Link: $dynamicLink");
            await Share.share(message);

            final payload = await _buildPayload(campaign.campaignId);

            try {
              await promotion_Authservice.sendShareAnalytics(payload);
            } catch (e) {
              debugPrint('❌ Share analytics error: $e');
            }

            if (mounted && index < campaigns.length) {
              setState(() {
                campaigns[index].sharesCount =
                    (campaigns[index].sharesCount ?? 0) + 1;
              });
            }
          },
        ),
        Text(
          '${campaigns[index].sharesCount ?? 0}',
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ],
    );
  }

  // ── Video player widget ──────────────────────────────────────────────────────

  Widget _buildVideo(int index) {
    final controller = _videoControllers[index];

    if (controller == null || !controller.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: controller.value.size.width,
        height: controller.value.size.height,
        child: VideoPlayer(controller),
      ),
    );
  }
}
