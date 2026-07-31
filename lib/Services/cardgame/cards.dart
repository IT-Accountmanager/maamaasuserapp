import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CardGameScreen extends StatefulWidget {
  const CardGameScreen({super.key});

  @override
  State<CardGameScreen> createState() => _CardGameScreenState();
}

class _CardGameScreenState extends State<CardGameScreen>
    with TickerProviderStateMixin {
  static const int cardCount = 6;

  late List<int> cardNumbers; // 1..6 shuffled — one number per card slot
  late List<AnimationController> flipControllers;
  late List<Animation<double>> flipAnimations;

  int? selectedIndex;
  bool hasPlayed = false; // 🔒 locks further taps until reset

  late ConfettiController confettiController;

  // Customize prizes per revealed number here.
  final Map<int, String> rewards = const {
    1: '🎁 10 Coins',
    2: '💎 20 Gems',
    3: '🏆 Bonus Spin',
    4: '⭐ 50 Points',
    5: '🎉 Mystery Gift',
    6: '👑 Jackpot!',
  };

  @override
  void initState() {
    super.initState();
    confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
    _initRound();
  }

  void _initRound() {
    cardNumbers = List.generate(cardCount, (i) => i + 1)..shuffle(Random());
    flipControllers = List.generate(
      cardCount,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      ),
    );
    flipAnimations = flipControllers
        .map(
          (c) => Tween<double>(
            begin: 0,
            end: pi,
          ).animate(CurvedAnimation(parent: c, curve: Curves.easeInOutBack)),
        )
        .toList();
    selectedIndex = null;
    hasPlayed = false;
  }

  @override
  void dispose() {
    for (final c in flipControllers) {
      c.dispose();
    }
    confettiController.dispose();
    super.dispose();
  }

  Future<void> _onCardTap(int index) async {
    if (hasPlayed) return; // 🔒 one play only per round

    setState(() {
      selectedIndex = index;
      hasPlayed = true;
    });

    // 📳 tap feedback
    HapticFeedback.mediumImpact();

    // 🎵 TODO: play a "flip" sound here, e.g. with audioplayers:
    // await AudioPlayer().play(AssetSource('sounds/flip.mp3'));

    await flipControllers[index].forward();

    // 🎉 reveal feedback
    confettiController.play();
    HapticFeedback.heavyImpact();

    // 🎵 TODO: play a "win" sound here:
    // await AudioPlayer().play(AssetSource('sounds/win.mp3'));

    if (mounted) {
      _showRewardDialog(cardNumbers[index]);
    }
  }

  void _resetGame() {
    setState(() {
      for (final c in flipControllers) {
        c.dispose();
      }
      _initRound();
    });
  }

  void _showRewardDialog(int number) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(24.r),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: [
              BoxShadow(
                color: Colors.purple.withOpacity(0.5),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '🎉 Congratulations! 🎉',
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'You picked card #$number',
                style: TextStyle(fontSize: 16.sp, color: Colors.white70),
              ),
              SizedBox(height: 8.h),
              Text(
                rewards[number] ?? '',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.amberAccent,
                ),
              ),
              SizedBox(height: 20.h),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF6A11CB),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 32.w,
                    vertical: 12.h,
                  ),
                ),
                child: const Text('Awesome!'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1F1C2C), Color(0xFF928DAB)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                SizedBox(height: 30.h),
                Text(
                  'Pick a Lucky Card',
                  style: TextStyle(
                    fontSize: 26.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  hasPlayed
                      ? 'You already played! Reset to play again.'
                      : 'Tap any card to reveal your number',
                  style: TextStyle(fontSize: 14.sp, color: Colors.white70),
                ),
                SizedBox(height: 40.h),
                Expanded(
                  child: GridView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    itemCount: cardCount,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 16.w,
                      mainAxisSpacing: 16.h,
                      childAspectRatio: 0.65,
                    ),
                    itemBuilder: (context, index) {
                      return _PlayingCard(
                        number: cardNumbers[index],
                        animation: flipAnimations[index],
                        isSelected: selectedIndex == index,
                        onTap: () => _onCardTap(index),
                      );
                    },
                  ),
                ),
                SizedBox(height: 20.h),
                if (hasPlayed)
                  Padding(
                    padding: EdgeInsets.only(bottom: 30.h),
                    child: ElevatedButton.icon(
                      onPressed: _resetGame,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Play Again'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amberAccent,
                        foregroundColor: Colors.black,
                        padding: EdgeInsets.symmetric(
                          horizontal: 28.w,
                          vertical: 14.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                      ),
                    ),
                  )
                else
                  SizedBox(height: 30.h),
              ],
            ),
          ),
          // Confetti overlay
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              numberOfParticles: 30,
              maxBlastForce: 20,
              minBlastForce: 8,
              gravity: 0.3,
              colors: const [
                Colors.amber,
                Colors.pink,
                Colors.blue,
                Colors.green,
                Colors.purple,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// SINGLE CARD WIDGET — 3D flip via Matrix4 (no flip_card package)
// ============================================================================

class _PlayingCard extends StatelessWidget {
  final int number;
  final Animation<double> animation; // 0 -> pi over the flip
  final bool isSelected;
  final VoidCallback onTap;

  const _PlayingCard({
    required this.number,
    required this.animation,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          final angle = animation.value;
          // Past 90 degrees we've "crossed over" to the front face.
          final isFront = angle > pi / 2;
          // Re-mirror the front face so its content isn't drawn backwards.
          final displayAngle = isFront ? angle - pi : angle;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // perspective
              ..rotateY(displayAngle),
            child: isFront ? _buildFront(isSelected) : _buildBack(),
          );
        },
      ),
    );
  }

  /// Closed / face-down state — what all cards show initially.
  // Widget _buildBack() {
  //   return Container(
  //     decoration: BoxDecoration(
  //       gradient: const LinearGradient(
  //         colors: [Color(0xFF232526), Color(0xFF414345)],
  //         begin: Alignment.topLeft,
  //         end: Alignment.bottomRight,
  //       ),
  //       borderRadius: BorderRadius.circular(14.r),
  //       border: Border.all(
  //         color: Colors.amberAccent.withOpacity(0.6),
  //         width: 1.5,
  //       ),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withOpacity(0.4),
  //           blurRadius: 10,
  //           offset: const Offset(0, 6),
  //         ),
  //       ],
  //     ),
  //     child: Center(
  //       child: Icon(
  //         Icons.style_rounded,
  //         color: Colors.amberAccent.withOpacity(0.85),
  //         size: 32.sp,
  //       ),
  //     ),
  //   );
  // }

  Widget _buildBack() {
    const gold = Color(0xFFD4AF37);

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1024), Color(0xFF3B0764), Color(0xFF1A1024)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: gold, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.45),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: gold.withOpacity(0.15),
            blurRadius: 8,
            spreadRadius: -2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: Stack(
          children: [
            // Inner recessed line — reads as an engraved "double border"
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.all(5.r),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(9.r),
                    border: Border.all(color: gold.withOpacity(0.5), width: 1),
                  ),
                ),
              ),
            ),
            // Woven diamond lattice pattern, like engraved card stock
            Positioned.fill(
              child: CustomPaint(
                painter: _CardBackPatternPainter(
                  lineColor: gold.withOpacity(0.18),
                ),
              ),
            ),
            // Center medallion
            Center(
              child: Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    colors: [Color(0xFFF7E7A0), gold, Color(0xFF9C7A22)],
                  ),
                  border: Border.all(
                    color: const Color(0xFFFCE9A6),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: gold.withOpacity(0.5),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.auto_awesome,
                  color: const Color(0xFF3B0764),
                  size: 18.sp,
                ),
              ),
            ),
            // Corner ornaments
            Positioned(top: 6.r, left: 6.r, child: _cornerDiamond(gold)),
            Positioned(top: 6.r, right: 6.r, child: _cornerDiamond(gold)),
            Positioned(bottom: 6.r, left: 6.r, child: _cornerDiamond(gold)),
            Positioned(bottom: 6.r, right: 6.r, child: _cornerDiamond(gold)),
            // Soft glossy diagonal sheen for a "printed card" highlight
            Positioned(
              top: -20.r,
              left: -30.r,
              right: -30.r,
              child: Transform.rotate(
                angle: -0.4,
                child: Container(
                  height: 40.r,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.0),
                        Colors.white.withOpacity(0.08),
                        Colors.white.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cornerDiamond(Color color) {
    return Transform.rotate(
      angle: pi / 4,
      child: Container(
        width: 7.r,
        height: 7.r,
        decoration: BoxDecoration(
          color: color.withOpacity(0.55),
          borderRadius: BorderRadius.circular(1.r),
        ),
      ),
    );
  }

  /// Open / revealed state — shown once the card finishes flipping.
  Widget _buildFront(bool selected) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: selected
              ? [const Color(0xFFFFD700), const Color(0xFFFF8C00)]
              : [Colors.white, const Color(0xFFE0E0E0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: selected
                ? Colors.amber.withOpacity(0.7)
                : Colors.black.withOpacity(0.2),
            blurRadius: selected ? 20 : 8,
            spreadRadius: selected ? 2 : 0,
          ),
        ],
      ),
      child: Center(
        child: Text(
          '$number',
          style: TextStyle(
            fontSize: 34.sp,
            fontWeight: FontWeight.bold,
            color: selected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}

class _CardBackPatternPainter extends CustomPainter {
  final Color lineColor;

  _CardBackPatternPainter({required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 1;

    const spacing = 10.0;

    // Diagonal lines one direction (\)
    for (double x = -size.height; x < size.width; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + size.height, size.height),
        paint,
      );
    }

    // Diagonal lines the other direction (/) — crossing creates the
    // diamond lattice look
    for (double x = 0; x < size.width + size.height; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x - size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CardBackPatternPainter oldDelegate) =>
      oldDelegate.lineColor != lineColor;
}
