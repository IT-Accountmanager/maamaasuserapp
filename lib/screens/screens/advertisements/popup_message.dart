// import 'package:custom_cached_image/custom_cached_image.dart';
// import 'package:maamaas/screens/Food&beverages/Menu/menu_screen.dart';
// import '../../../Models/promotions_model/promotions_model.dart';
// import 'package:video_player/video_player.dart';
// import 'package:flutter/material.dart';
// import '../../../widgets/safearea.dart';
// import '../referrznd earn.dart';
//
// class PromotionPopup {
//   static void show(BuildContext context, Campaign ads) {
//     final screenHeight = MediaQuery.of(context).size.height;
//
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) {
//         final url = ads.imageUrl ?? '';
//
//         // ✅ Robust detection
//         final isVideo =
//             (ads.mediaType?.toUpperCase() == "VIDEO") ||
//             url.toLowerCase().contains(".mp4");
//
//         return PlatformSafeArea(
//           child: Container(
//             height: screenHeight * 0.60,
//             width: double.infinity,
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(20),
//               boxShadow: [
//                 BoxShadow(
//                   // ignore: deprecated_member_use
//                   color: Colors.black.withOpacity(0.2),
//                   blurRadius: 30,
//                   offset: const Offset(0, 15),
//                 ),
//               ],
//             ),
//             child: Column(
//               children: [
//                 Expanded(
//                   flex: 9,
//                   child: Stack(
//                     children: [
//                       GestureDetector(
//                         // onTap: ads.callToAction == CallToAction.ORDER_NOW
//                         //     ? () {
//                         //         Navigator.pop(context);
//                         //
//                         //         Navigator.push(
//                         //           context,
//                         //           MaterialPageRoute(
//                         //             builder: (_) => MenuScreen(
//                         //               vendorId: ads.vendorId ?? 0,
//                         //             ), // or your Menu Screen
//                         //           ),
//                         //         );
//                         //       }
//                         //     : null,
//                         onTap: () {
//                           // Close popup first
//                           Navigator.pop(context);
//
//                           // Handle CTA
//                           if (ads.callToAction == CallToAction.ORDER_NOW) {
//                             // ------------------------------------
//                             // ORDER NOW → Particular Vendor Menu
//                             // ------------------------------------
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (_) =>
//                                     MenuScreen(vendorId: ads.vendorId ?? 0),
//                               ),
//                             );
//                           } else if (ads.callToAction ==
//                               CallToAction.REFER_AND_EARN) {
//                             debugPrint(
//                               'CallToAction: REFER_AND_EARN triggered → navigating to ReferEarnScreen',
//                             );
//
//                             // ------------------------------------
//                             // REFERRAL EARN → Referral Page
//                             // ------------------------------------
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (_) => const ReferEarnScreen(),
//                               ),
//                             );
//                           }
//                         },
//
//                         child: ClipRRect(
//                           borderRadius: const BorderRadius.vertical(
//                             top: Radius.circular(20),
//                           ),
//                           child: SizedBox.expand(
//                             child: isVideo
//                                 ? _VideoPlayerWidget(url: url)
//                                 : CustomCachedImage(
//                                     imageUrl: url,
//                                     fit: BoxFit.fill,
//                                     width: double.infinity,
//                                     height: double.infinity,
//                                     isProfile: false,
//
//                                     errorWidget: const Center(
//                                       child: Icon(Icons.broken_image, size: 40),
//                                     ),
//                                     borderRadius: 0,
//                                   ),
//                           ),
//                         ),
//                       ),
//
//                       /// ❌ Close Button
//                       Positioned(
//                         right: 12,
//                         top: 12,
//                         child: InkWell(
//                           onTap: () => Navigator.pop(context),
//                           child: const CircleAvatar(
//                             radius: 14,
//                             backgroundColor: Colors.black54,
//                             child: Icon(
//                               Icons.close,
//                               size: 16,
//                               color: Colors.white,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
//
// /// 🎥 VIDEO PLAYER WIDGET
// class _VideoPlayerWidget extends StatefulWidget {
//   final String url;
//
//   const _VideoPlayerWidget({required this.url});
//
//   @override
//   State<_VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
// }
//
// class _VideoPlayerWidgetState extends State<_VideoPlayerWidget> {
//   VideoPlayerController? _controller;
//   bool _hasError = false;
//
//   @override
//   void initState() {
//     super.initState();
//
//     // ignore: deprecated_member_use
//     _controller = VideoPlayerController.network(widget.url)
//       ..initialize()
//           .then((_) {
//             if (!mounted) return;
//             setState(() {});
//             _controller?.play();
//             _controller?.setLooping(true);
//           })
//           .catchError((e) {
//             setState(() {
//               _hasError = true;
//             });
//           });
//   }
//
//   @override
//   void dispose() {
//     _controller?.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (_hasError) {
//       return const Center(child: Icon(Icons.error, size: 40));
//     }
//
//     if (_controller == null || !_controller!.value.isInitialized) {
//       return const Center(child: CircularProgressIndicator());
//     }
//
//     return AspectRatio(
//       aspectRatio: _controller!.value.aspectRatio,
//       child: VideoPlayer(_controller!),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:custom_cached_image/custom_cached_image.dart';
import 'package:video_player/video_player.dart';

import 'package:maamaas/screens/Food&beverages/Menu/menu_screen.dart';
import '../../../Models/promotions_model/promotions_model.dart';
import '../../../Services/Auth_service/food_authservice.dart';
import '../../../widgets/safearea.dart';
import '../referrznd earn.dart';

class PromotionPopup {
  static void show(BuildContext parentContext, Campaign ads) {
    final screenHeight = MediaQuery.of(parentContext).size.height;

    showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      isDismissible: true,
      builder: (sheetContext) {
        final String url = ads.imageUrl ?? '';

        final bool isVideo =
            ads.mediaType?.toUpperCase() == 'VIDEO' ||
            url.toLowerCase().endsWith('.mp4') ||
            url.toLowerCase().contains('.mp4?');

        return PlatformSafeArea(
          child: Container(
            height: screenHeight * 0.60,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              child: Stack(
                children: [
                  // =========================================================
                  // IMAGE / VIDEO
                  // =========================================================
                  Positioned.fill(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        _handlePromotionTap(
                          parentContext: parentContext,
                          sheetContext: sheetContext,
                          ads: ads,
                        );
                      },
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                        child: isVideo
                            ? _VideoPlayerWidget(url: url)
                            : _PromotionImage(url: url),
                      ),
                    ),
                  ),

                  // =========================================================
                  // CLOSE BUTTON
                  // =========================================================
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(30),
                        onTap: () {
                          Navigator.of(sheetContext).pop();
                        },
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.65),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // =======================================================================
  // HANDLE PROMOTION CLICK
  // =======================================================================

  static Future<void> _handlePromotionTap({
    required BuildContext parentContext,
    required BuildContext sheetContext,
    required Campaign ads,
  }) async {
    // ---------------------------------------------------------
    // Close bottom sheet first
    // ---------------------------------------------------------

    if (Navigator.of(sheetContext).canPop()) {
      Navigator.of(sheetContext).pop();
    }

    // ---------------------------------------------------------
    // Wait for bottom sheet animation to finish
    // ---------------------------------------------------------

    await Future.delayed(const Duration(milliseconds: 250));

    if (!parentContext.mounted) {
      return;
    }

    // =========================================================
    // ORDER NOW
    // =========================================================

    // if (ads.callToAction == CallToAction.ORDER_NOW) {
    //   final int vendorId = ads.vendorId ?? 0;
    //
    //   if (vendorId <= 0) {
    //     _showError(parentContext, 'Restaurant information is not available.');
    //
    //     return;
    //   }
    //
    //   await Navigator.of(parentContext).push(
    //     MaterialPageRoute(
    //       builder: (context) {
    //         return MenuScreen(vendorId: vendorId);
    //       },
    //     ),
    //   );
    //
    //   return;
    // }
    if (ads.callToAction == CallToAction.ORDER_NOW) {
      debugPrint("✅ ORDER_NOW matched");

      final int vendorId = ads.vendorId ?? 0;

      if (vendorId <= 0) {
        _showError(
          parentContext,
          'Restaurant information is not available.',
        );
        return;
      }

      final String ordertype = "DINE_IN";

      try {
        debugPrint("🛒 Creating cart with order type: $ordertype");

        final result = await food_Authservice.createCart(ordertype);

        debugPrint("✅ Cart created: $result");

        // Navigate to MenuScreen after cart is created
        await Navigator.of(parentContext).push(
          MaterialPageRoute(
            builder: (context) {
              return MenuScreen(
                vendorId: vendorId,
              );
            },
          ),
        );
      } catch (e) {
        debugPrint("❌ Failed to create cart: $e");

        _showError(
          parentContext,
          'Unable to create cart. Please try again.',
        );
      }

      return;
    }


    // =========================================================
    // REFER AND EARN
    // =========================================================

    if (ads.callToAction == CallToAction.REFER_AND_EARN) {
      await Navigator.of(parentContext).push(
        MaterialPageRoute(
          builder: (context) {
            return const ReferEarnScreen();
          },
        ),
      );

      return;
    }

    // =========================================================
    // NO CTA
    // =========================================================

    _showError(
      parentContext,
      'This promotion does not have an action configured.',
    );
  }

  // =======================================================================
  // ERROR MESSAGE
  // =======================================================================

  static void _showError(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }
}

// ===========================================================================
// PROMOTION IMAGE
// ===========================================================================

class _PromotionImage extends StatelessWidget {
  final String url;

  const _PromotionImage({required this.url});

  @override
  Widget build(BuildContext context) {
    if (url.trim().isEmpty) {
      return const Center(
        child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
      );
    }

    return CustomCachedImage(
      imageUrl: url,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      isProfile: false,
      borderRadius: 0,
      errorWidget: const Center(
        child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
      ),
    );
  }
}

// ===========================================================================
// VIDEO PLAYER
// ===========================================================================

class _VideoPlayerWidget extends StatefulWidget {
  final String url;

  const _VideoPlayerWidget({required this.url});

  @override
  State<_VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<_VideoPlayerWidget> {
  VideoPlayerController? _controller;

  bool _hasError = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      if (widget.url.trim().isEmpty) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });

        return;
      }

      final controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.url),
      );

      _controller = controller;

      await controller.initialize();

      if (!mounted) return;

      await controller.setLooping(true);
      await controller.setVolume(1.0);
      await controller.play();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return const Center(
        child: Icon(Icons.error_outline, size: 50, color: Colors.grey),
      );
    }

    if (_isLoading ||
        _controller == null ||
        !_controller!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: _controller!.value.size.width,
          height: _controller!.value.size.height,
          child: VideoPlayer(_controller!),
        ),
      ),
    );
  }
}
