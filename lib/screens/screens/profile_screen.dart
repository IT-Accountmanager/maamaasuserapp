import 'package:maamaas/screens/screens/supportteam/support_team.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:maamaas/Services/scaffoldmessenger/messenger.dart';
import '../../Services/Auth_service/Subscription_authservice.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:maamaas/screens/screens/saved_address.dart';
import 'package:maamaas/screens/screens/wallet_screen.dart';
import 'package:media_compressor/media_compressor.dart';
import '../../Models/subscrptions/user_account.dart';
import '../../widgets/widgets/profileavataor.dart';
import 'Refer_Earn.dart';
import 'profile screen/Profile_Account.dart';
import '../../widgets/signinrequired.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'coupons_rewards_screen.dart';
import 'orders/orders_screen.dart';
import '../foodmainscreen.dart';
import 'dart:typed_data';
import 'login_page.dart';
import 'Favorites.dart';
import 'dart:io';

// ── Design tokens ─────────────────────────────────────────────────────────────
class _T {
  // Neutrals
  static const bg = Color(0xFFF6F7FB);
  static const surface = Color(0xFFFFFFFF);
  static const border = Color(0xFFECEFF6);

  // Brand
  static const brand = Color(0xFF4F46E5); // indigo
  static const brandSoft = Color(0xFFEEEDFD);

  // Text
  static const ink = Color(0xFF111827);
  static const sub = Color(0xFF6B7280);
  static const muted = Color(0xFFB0B8C8);

  // Status
  static const red = Color(0xFFEF4444);
  static const redSoft = Color(0xFFFEF2F2);

  // Shadows
  static List<BoxShadow> card = [
    BoxShadow(
      color: const Color(0xFF000000).withOpacity(0.05),
      blurRadius: 12,
      offset: const Offset(0, 2),
    ),
  ];
}

// ── Profile screen ─────────────────────────────────────────────────────────────
class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Uint8List? _selectedImageBytes;
  String? _fetchedImageUrl;
  bool? isLoggedIn;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final loggedIn = await subscription_AuthService.isLoggedIn();
    if (!mounted) return;
    setState(() => isLoggedIn = loggedIn);
    if (loggedIn) _loadProfileImage();
  }

  void _loadProfileImage() async {
    final profile = await subscription_AuthService.getAccount();
    if (profile != null && mounted) {
      setState(() => _fetchedImageUrl = profile.image);
    }
  }

  Future<void> _uploadImage(BuildContext context, File profileImage) async {
    try {
      if (!profileImage.existsSync()) {
        AppAlert.error(context, "Image file not found");
        return;
      }
      final bool success = await subscription_AuthService.updateProfileImage(
        profileImage,
      );
      if (success) {
        // ignore: use_build_context_synchronously
        AppAlert.success(context, "Profile photo updated");
        _loadProfileImage();
      } else {
        AppAlert.error(context, "Failed to update profile photo");
      }
    } catch (e) {
      AppAlert.error(context, "Error uploading image");
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: _T.bg,
        body: AuthGuard(child: _buildBody()),
      ),
    );
  }

  Widget _buildBody() {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // ── App bar ──────────────────────────────────────────────────
        SliverAppBar(
          pinned: true,
          backgroundColor: _T.surface,
          elevation: 0,
          scrolledUnderElevation: 1,
          shadowColor: Colors.black.withOpacity(0.06),
          automaticallyImplyLeading: false,
          title: const Text(
            'Profile',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: _T.ink,
              letterSpacing: -0.3,
            ),
          ),
          centerTitle: true,
          leading: _BackButton(),
        ),

        // ── Header card ───────────────────────────────────────────────
        SliverToBoxAdapter(
          child: _ProfileHeader(
            selectedImageBytes: _selectedImageBytes,
            fetchedImageUrl: _fetchedImageUrl,
            onUpload: _uploadImage,
          ),
        ),

        // ── Menu items ────────────────────────────────────────────────
        SliverToBoxAdapter(child: _MenuList()),

        SliverToBoxAdapter(child: const SizedBox(height: 32)),
      ],
    );
  }
}

class _BackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => MainScreenfood()),
        (r) => false,
      ),
      child: Container(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: _T.bg, shape: BoxShape.circle),
        child: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 16,
          color: _T.ink,
        ),
      ),
    );
  }
}

// ── Profile header ─────────────────────────────────────────────────────────────
class _ProfileHeader extends StatelessWidget {
  final Uint8List? selectedImageBytes;
  final String? fetchedImageUrl;
  final Future<void> Function(BuildContext, File) onUpload;

  const _ProfileHeader({
    required this.selectedImageBytes,
    required this.fetchedImageUrl,
    required this.onUpload,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserAccount?>(
      future: subscription_AuthService.getAccount(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _HeaderSkeleton();
        }

        final user = snapshot.data;
        if (user == null) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _T.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: _T.card,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  // Avatar + completion ring
                  _AvatarWithRing(
                    completion: user.completionPercentage ?? 0,
                    selectedImageBytes: selectedImageBytes,
                    fetchedImageUrl: fetchedImageUrl,
                    onUpload: onUpload,
                  ),
                  const SizedBox(width: 16),

                  // User info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (user.userName ?? 'User').toUpperCase(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: _T.ink,
                            letterSpacing: -0.4,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 5),
                        _InfoRow(
                          icon: Icons.mail_outline_rounded,
                          text: user.emailId ?? '',
                        ),
                        const SizedBox(height: 4),
                        _InfoRow(
                          icon: Icons.phone_outlined,
                          text: user.phoneNumber?.isNotEmpty == true
                              ? '+91 ${user.phoneNumber}'
                              : 'Not added',
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Profile completion bar
              if ((user.completionPercentage ?? 0) < 100) ...[
                const SizedBox(height: 16),
                _CompletionBar(percent: user.completionPercentage ?? 0),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _AvatarWithRing extends StatelessWidget {
  final int completion;
  final Uint8List? selectedImageBytes;
  final String? fetchedImageUrl;
  final Future<void> Function(BuildContext, File) onUpload;

  const _AvatarWithRing({
    required this.completion,
    required this.selectedImageBytes,
    required this.fetchedImageUrl,
    required this.onUpload,
  });

  Color get _ringColor {
    if (completion >= 100) return const Color(0xFF10B981);
    if (completion >= 70) return _T.brand;
    return const Color(0xFFF59E0B);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Ring
        SizedBox(
          width: 88,
          height: 88,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: completion / 100),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (_, v, __) => CircularProgressIndicator(
              value: v,
              strokeWidth: 3.5,
              backgroundColor: _T.border,
              valueColor: AlwaysStoppedAnimation(_ringColor),
              strokeCap: StrokeCap.round,
            ),
          ),
        ),

        // Avatar
        Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: _T.surface, width: 3),
            boxShadow: _T.card,
          ),
          child: ClipOval(
            child: UploadableProfileAvatar(
              heroTag: "profile_pic",
              imageBytes: selectedImageBytes,
              networkImageUrl: fetchedImageUrl,
              onImageSelected: (File imageFile) async {
                final result = await MediaCompressor.compressImage(
                  ImageCompressionConfig(
                    path: imageFile.path,
                    quality: 80,
                    maxWidth: 1920,
                    maxHeight: 1080,
                  ),
                );
                if (result.isSuccess) {
                  final compressedFile = File(result.path!);
                  await onUpload(context, compressedFile);
                }
              },
            ),
          ),
        ),

        // Percent badge
        Positioned(
          bottom: 2,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: _ringColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$completion%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 13, color: _T.muted),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 12, color: _T.sub, height: 1.3),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _CompletionBar extends StatelessWidget {
  final int percent;

  const _CompletionBar({required this.percent});

  @override
  Widget build(BuildContext context) {
    final remaining = 100 - percent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _T.brandSoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.edit_outlined, size: 14, color: _T.brand),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Complete your profile — $remaining% remaining',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: _T.brand,
              ),
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 11,
            color: _T.brand,
          ),
        ],
      ),
    );
  }
}

class _HeaderSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _T.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: _T.card,
      ),
      child: Row(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: const BoxDecoration(
              color: _T.bg,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Shimmer(width: 130, height: 16),
                const SizedBox(height: 8),
                _Shimmer(width: 180, height: 12),
                const SizedBox(height: 6),
                _Shimmer(width: 110, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Shimmer extends StatelessWidget {
  final double width;
  final double height;

  const _Shimmer({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: _T.bg,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}

// ── Menu list ──────────────────────────────────────────────────────────────────
class _MenuList extends StatefulWidget {
  @override
  State<_MenuList> createState() => _MenuListState();
}

class _MenuListState extends State<_MenuList> {
  bool _isLoggingOut = false;

  static const _sections = [
    {
      'title': 'Orders & Wallet',
      'items': [
        {
          'icon': Icons.shopping_bag_outlined,
          'label': 'My Orders',
          'color': Color(0xFF4F46E5),
          'key': 'orders',
        },
        {
          'icon': Icons.account_balance_wallet_outlined,
          'label': 'Wallet',
          'color': Color(0xFF0EA5E9),
          'key': 'wallet',
        },
      ],
    },
    {
      'title': 'Preferences',
      'items': [
        {
          'icon': Icons.location_on_outlined,
          'label': 'Address Book',
          'color': Color(0xFF10B981),
          'key': 'address',
        },
        {
          'icon': Icons.favorite_border_rounded,
          'label': 'Favorites',
          'color': Color(0xFFF43F5E),
          'key': 'favorites',
        },
        {
          'icon': Icons.card_giftcard_outlined,
          'label': 'Rewards & Coupons',
          'color': Color(0xFF0EA5E9),
          'key': 'rewards',
        },
        {
          'icon': Icons.room_preferences,
          'label': 'Refer',
          'color': Color(0xFFF59E0B),
          'key': 'Refer',
        },
      ],
    },
    {
      'title': 'Account',
      'items': [
        {
          'icon': Icons.support_agent_outlined,
          'label': 'Support',
          'color': Color(0xFF06B6D4),
          'key': 'support',
        },
        {
          'icon': Icons.manage_accounts_outlined,
          'label': 'Account Settings',
          'color': Color(0xFF8B5CF6),
          'key': 'account',
        },
      ],
    },
  ];

  Widget? _pageForKey(String key, BuildContext context) {
    switch (key) {
      case 'orders':
        return OrdersScreen();
      case 'wallet':
        return WalletScreen();
      case 'address':
        return SavedAddress(
          onAddressSelected: (address) {
            print(address.category);
          },
        );
      case 'favorites':
        return Favorites();
      case 'rewards':
        return CouponsAndRewards();
      case 'Refer':
        return ReferEarn();
      case 'support':
        return Supportteam();
      case 'account':
        return AccountScreen();
      default:
        return null;
    }
  }

  Future<void> _logout() async {
    if (_isLoggingOut) return;
    setState(() => _isLoggingOut = true);
    try {
      await subscription_AuthService.logout();
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      const secureStorage = FlutterSecureStorage();
      await secureStorage.deleteAll();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (r) => false,
      );
    } catch (e) {
      if (!mounted) return;
      AppAlert.error(context, 'Logout failed');
    } finally {
      if (mounted) setState(() => _isLoggingOut = false);
    }
  }

  void _showLogoutSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => SafeArea(child: _LogoutSheet(onConfirm: _logout)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sections
          for (final section in _sections) ...[
            _SectionLabel(section['title'] as String),
            Container(
              decoration: BoxDecoration(
                color: _T.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: _T.card,
              ),
              child: Column(
                children: [
                  for (
                    int i = 0;
                    i < (section['items'] as List).length;
                    i++
                  ) ...[
                    _MenuItem(
                      icon: (section['items'] as List)[i]['icon'] as IconData,
                      label: (section['items'] as List)[i]['label'] as String,
                      color: (section['items'] as List)[i]['color'] as Color,
                      isLast: i == (section['items'] as List).length - 1,
                      onTap: () {
                        final key =
                            (section['items'] as List)[i]['key'] as String;
                        final page = _pageForKey(key, context);
                        if (page != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => page),
                          );
                        }
                      },
                    ),
                  ],
                ],
              ),
            ),
          ],

          // Logout
          const SizedBox(height: 8),
          _SectionLabel(''),
          Container(
            decoration: BoxDecoration(
              color: _T.redSoft,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _T.red.withOpacity(0.12)),
            ),
            child: ListTile(
              onTap: _showLogoutSheet,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 2,
              ),
              leading: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: _T.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: _T.red,
                  size: 18,
                ),
              ),
              title: const Text(
                'Logout',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _T.red,
                ),
              ),
              trailing: _isLoggingOut
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: _T.red,
                      ),
                    )
                  : const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 13,
                      color: _T.red,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 16, bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: _T.muted,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isLast;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.isLast,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _T.ink,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 13,
                  color: _T.muted,
                ),
              ],
            ),
          ),
        ),
        if (!isLast)
          Divider(height: 1, thickness: 1, color: _T.border, indent: 68),
      ],
    );
  }
}

// ── Logout confirmation sheet ──────────────────────────────────────────────────
class _LogoutSheet extends StatelessWidget {
  final VoidCallback onConfirm;

  const _LogoutSheet({required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: _T.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: _T.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Icon
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: _T.redSoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.logout_rounded, color: _T.red, size: 28),
          ),
          const SizedBox(height: 16),

          const Text(
            'Logging out?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _T.ink,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "You'll need to sign in again to access your account.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: _T.sub, height: 1.5),
          ),
          const SizedBox(height: 28),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: const BorderSide(color: _T.border),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: _T.ink,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onConfirm();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _T.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Logout',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
