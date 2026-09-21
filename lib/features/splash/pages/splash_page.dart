import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme/app_colors.dart';
import '../widgets/daymark_mark_painter.dart';

/// Daymark's launch moment: one orchestrated gesture rather than a logo
/// fade or a spinner. A single stroke draws itself, lands as a point, and
/// the wordmark rises to meet it — the same motion the product itself is
/// built around, marking a moment as it happens.
///
/// [onFinished] fires once the sequence completes, so the caller can swap
/// in the real app (or keep waiting on it, if bootstrapping is slower than
/// the animation — see [minDuration]).
class SplashPage extends StatefulWidget {
  const SplashPage({super.key, this.onFinished, this.minDuration = const Duration(milliseconds: 2200)});

  final VoidCallback? onFinished;
  final Duration minDuration;

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _stroke;
  late final Animation<double> _point;
  late final Animation<double> _ring;
  late final Animation<double> _wordmarkOpacity;
  late final Animation<Offset> _wordmarkOffset;
  late final Animation<double> _taglineOpacity;

  @override
  void initState() {
    super.initState();
    final reduceMotion = WidgetsBinding.instance.platformDispatcher.accessibilityFeatures.disableAnimations;

    _controller = AnimationController(
      vsync: this,
      duration: reduceMotion ? const Duration(milliseconds: 1) : widget.minDuration,
    );

    _stroke = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeInOutCubic),
    );
    _point = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.46, 0.6, curve: Curves.easeOutBack),
    );
    _ring = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.46, 0.72, curve: Curves.easeOut),
    );
    _wordmarkOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.55, 0.82, curve: Curves.easeOut),
    );
    _wordmarkOffset = Tween(begin: const Offset(0, 0.15), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.55, 0.82, curve: Curves.easeOutCubic)),
    );
    _taglineOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.78, 1.0, curve: Curves.easeOut),
    );

    _controller.forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onFinished?.call();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Stack(
        children: [
          // Off-center glow rather than a dead-centered radial wash — keeps
          // the composition asymmetric instead of a flat centered blob.
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(-0.35, -0.4),
                  radius: 1.1,
                  colors: [
                    AppColors.darkPrimary.withValues(alpha: 0.10),
                    AppColors.darkBackground,
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: CustomPaint(
                        painter: DaymarkMarkPainter(
                          strokeProgress: _stroke.value,
                          pointProgress: _point.value,
                          ringProgress: _ring.value,
                          strokeColorStart: AppColors.darkPrimaryDark,
                          strokeColorEnd: AppColors.darkPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    FadeTransition(
                      opacity: _wordmarkOpacity,
                      child: SlideTransition(
                        position: _wordmarkOffset,
                        child: Text(
                          'Daymark',
                          style: GoogleFonts.inter(
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                            color: AppColors.darkTextPrimary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    FadeTransition(
                      opacity: _taglineOpacity,
                      child: Text(
                        'Your journey, one mark at a time.',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.darkTextSecondary,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
