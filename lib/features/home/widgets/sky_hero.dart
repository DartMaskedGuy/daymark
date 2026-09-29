import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/constants/app_spacing.dart';

/// Warm light used for everything "lived" in the hero: lit stars, the sun
/// and the progress fill. Kept separate from the indigo brand color so the
/// night sky reads as cold and the lived moments read as warm.
const Color kLivedAmber = Color(0xFFFFC46B);
const Color _starCore = Color(0xFFFFE9BF);

/// Home's hero: a dusk sky that is the user's progress made visible.
/// Every bucket-list item is a star on a winding path — lived ones are lit
/// and joined by a line, the rest wait faintly ahead — and the sun climbs
/// out from behind the ridge as the percentage grows.
class SkyHero extends StatefulWidget {
  const SkyHero({
    super.key,
    required this.greeting,
    required this.completed,
    required this.total,
    required this.progress,
    required this.loading,
    required this.onSettings,
  });

  final String greeting;
  final int completed;
  final int total;
  final double progress;
  final bool loading;
  final VoidCallback onSettings;

  @override
  State<SkyHero> createState() => _SkyHeroState();
}

class _SkyHeroState extends State<SkyHero> with TickerProviderStateMixin {
  late final AnimationController _reveal = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  );
  late final AnimationController _twinkle = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  );
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _startIfReady();
  }

  @override
  void didUpdateWidget(covariant SkyHero oldWidget) {
    super.didUpdateWidget(oldWidget);
    _startIfReady();
  }

  // Wait for real data so lit stars appear one by one instead of popping in
  // after the animation has already finished.
  void _startIfReady() {
    if (_started || widget.loading) return;
    _started = true;
    if (MediaQuery.of(context).disableAnimations) {
      _reveal.value = 1;
    } else {
      _reveal.forward();
      _twinkle.repeat();
    }
  }

  @override
  void dispose() {
    _reveal.dispose();
    _twinkle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percent = (widget.progress * 100).round();

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(36)),
      child: Stack(
        children: [
          Positioned.fill(
            child: RepaintBoundary(
              child: CustomPaint(
                painter: SkyPainter(
                  total: widget.total,
                  completed: widget.completed,
                  progress: widget.progress,
                  reveal: _reveal,
                  twinkle: _twinkle,
                ),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                56,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: kLivedAmber,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(color: kLivedAmber, blurRadius: 8),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'Daymark',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontSize: 15,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ),
                      Material(
                        color: Colors.white.withValues(alpha: 0.12),
                        shape: const CircleBorder(),
                        child: IconButton(
                          tooltip: 'Settings',
                          icon: const Icon(
                            Icons.settings_outlined,
                            color: Colors.white,
                          ),
                          onPressed: widget.onSettings,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    // widget.greeting.replaceFirst(' ', '\n'),
                    widget.greeting,
                    style: theme.textTheme.displaySmall?.copyWith(
                      color: Colors.white,
                      fontSize: 30,
                      height: 1.12,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 200),
                    child: Text(
                      'Your journey, one mark at a time.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.72),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AnimatedOpacity(
                    opacity: widget.loading ? 0 : 1,
                    duration: const Duration(milliseconds: 400),
                    child: widget.total == 0
                        ? _EmptyJourney(theme: theme)
                        : Semantics(
                            label:
                                '${widget.completed} of ${widget.total} experiences lived, $percent percent',
                            child: ExcludeSemantics(
                              child: _JourneyBlock(
                                theme: theme,
                                completed: widget.completed,
                                total: widget.total,
                                progress: widget.progress,
                                percent: percent,
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _JourneyBlock extends StatelessWidget {
  const _JourneyBlock({
    required this.theme,
    required this.completed,
    required this.total,
    required this.progress,
    required this.percent,
  });

  final ThemeData theme;
  final int completed;
  final int total;
  final double progress;
  final int percent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              '$completed',
              style: theme.textTheme.displaySmall?.copyWith(
                color: Colors.white,
                fontSize: 64,
                height: 1,
                letterSpacing: -2,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              '/ $total',
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 20,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'experiences lived',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.white.withValues(alpha: 0.72),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 260),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: progress),
                    duration: const Duration(milliseconds: 900),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) => FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: value,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: kLivedAmber,
                          borderRadius: BorderRadius.circular(3),
                          boxShadow: [
                            BoxShadow(
                              color: kLivedAmber.withValues(alpha: 0.6),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm + 4),
              Text(
                '$percent%',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EmptyJourney extends StatelessWidget {
  const _EmptyJourney({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your sky is empty',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontSize: 26,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 240),
          child: Text(
            'Add your first idea and the first star lights up.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.72),
            ),
          ),
        ),
      ],
    );
  }
}

class SkyPainter extends CustomPainter {
  SkyPainter({
    required this.total,
    required this.completed,
    required this.progress,
    required this.reveal,
    required this.twinkle,
  }) : super(repaint: Listenable.merge([reveal, twinkle]));

  final int total;
  final int completed;
  final double progress;
  final Animation<double> reveal;
  final Animation<double> twinkle;

  static const int _maxStars = 14;
  static const int _emptyStars = 6;

  @override
  void paint(Canvas canvas, Size size) {
    _paintSky(canvas, size);
    _paintDust(canvas, size);
    _paintSun(canvas, size);
    _paintConstellation(canvas, size);
    _paintRidges(canvas, size);
  }

  void _paintSky(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0E0D2B),
            Color(0xFF231A5C),
            Color(0xFF6A3585),
            Color(0xFFE9825F),
          ],
          stops: [0.0, 0.45, 0.76, 1.0],
        ).createShader(rect),
    );
  }

  void _paintDust(Canvas canvas, Size size) {
    final rng = math.Random(11);
    final paint = Paint();
    for (var i = 0; i < 46; i++) {
      final dx = rng.nextDouble() * size.width;
      final dy = rng.nextDouble() * size.height * 0.55;
      final radius = 0.5 + rng.nextDouble() * 0.9;
      final phase = rng.nextDouble() * math.pi * 2;
      final wave = 0.5 + 0.5 * math.sin(twinkle.value * math.pi * 2 + phase);
      paint.color = Colors.white.withValues(alpha: 0.22 + 0.32 * wave);
      canvas.drawCircle(Offset(dx, dy), radius, paint);
    }
  }

  void _paintSun(Canvas canvas, Size size) {
    const radius = 26.0;
    final horizon = size.height * 0.79;
    final centerX = size.width * 0.74;
    // At 0% the sun sits just behind the ridge; at 100% it clears it.
    final centerY = horizon + radius * 1.1 - progress * radius * 2.9;

    final glowCenter = Offset(centerX, horizon);
    final glowRadius = size.width * 0.55;
    canvas.drawCircle(
      glowCenter,
      glowRadius,
      Paint()
        ..shader = RadialGradient(
          colors: [
            kLivedAmber.withValues(alpha: 0.25 + 0.35 * progress),
            kLivedAmber.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: glowCenter, radius: glowRadius)),
    );

    canvas.drawCircle(
      Offset(centerX, centerY),
      radius,
      Paint()..color = const Color(0xFFFFD98F),
    );
  }

  int get _shownStars => total == 0 ? _emptyStars : math.min(total, _maxStars);

  int get _litStars {
    if (total == 0 || completed == 0) return 0;
    final shown = _shownStars;
    var lit = (completed / total * shown).round();
    if (lit == 0) lit = 1;
    if (completed < total && lit >= shown) lit = shown - 1;
    return math.max(lit, 0);
  }

  // Deterministic so the same journey always draws the same constellation.
  List<Offset> _starPoints(Size size, int count) {
    final rng = math.Random(23);
    return List.generate(count, (i) {
      final t = count == 1 ? 0.5 : i / (count - 1);
      final x = size.width * (0.52 + 0.42 * t) + (rng.nextDouble() - 0.5) * 14;
      final wave = math.sin(t * math.pi * 1.6 + 0.4);
      final y =
          size.height * (0.30 - 0.12 * wave) + (rng.nextDouble() - 0.5) * 26;
      return Offset(x, y);
    });
  }

  void _paintConstellation(Canvas canvas, Size size) {
    final points = _starPoints(size, _shownStars);
    final lit = _litStars;

    final pathAhead = Paint()
      ..color = Colors.white.withValues(alpha: 0.10)
      ..strokeWidth = 1;
    for (var i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i], points[i + 1], pathAhead);
    }

    final revealed = reveal.value * lit;

    final linePaint = Paint()
      ..color = kLivedAmber.withValues(alpha: 0.55)
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < lit - 1; i++) {
      final amount = (revealed - i - 0.3).clamp(0.0, 1.0);
      if (amount <= 0) continue;
      canvas.drawLine(
        points[i],
        Offset.lerp(points[i], points[i + 1], amount)!,
        linePaint,
      );
    }

    final dim = Paint()..color = Colors.white.withValues(alpha: 0.38);
    for (var i = lit; i < points.length; i++) {
      canvas.drawCircle(points[i], 1.8, dim);
    }

    final glow = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    final core = Paint();
    for (var i = 0; i < lit; i++) {
      final visible = (revealed - i).clamp(0.0, 1.0);
      if (visible <= 0) continue;
      final tw = 0.5 + 0.5 * math.sin(twinkle.value * math.pi * 2 + i * 1.7);
      glow.color = kLivedAmber.withValues(
        alpha: 0.30 * visible * (0.7 + 0.3 * tw),
      );
      canvas.drawCircle(points[i], 9, glow);
      core.color = _starCore.withValues(alpha: visible);
      canvas.drawCircle(points[i], (2.6 + tw * 0.5) * visible, core);
    }

    if (lit > 0 && revealed >= lit - 0.2) {
      canvas.drawCircle(
        points[lit - 1],
        7,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = kLivedAmber.withValues(alpha: 0.5),
      );
    }
  }

  void _paintRidges(Canvas canvas, Size size) {
    _ridge(canvas, size, const [
      0.74,
      0.68,
      0.76,
      0.72,
      0.80,
      0.77,
      0.70,
    ], const Color(0xFF3B2470));
    _ridge(canvas, size, const [
      0.84,
      0.79,
      0.86,
      0.82,
      0.88,
      0.83,
    ], const Color(0xFF231650));
    _ridge(canvas, size, const [
      0.92,
      0.95,
      0.90,
      0.94,
      0.91,
    ], const Color(0xFF140E36));
  }

  void _ridge(Canvas canvas, Size size, List<double> heights, Color color) {
    final last = heights.length - 1;
    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, heights.first * size.height);
    for (var i = 0; i < last; i++) {
      final x0 = size.width * i / last;
      final x1 = size.width * (i + 1) / last;
      final y0 = heights[i] * size.height;
      final y1 = heights[i + 1] * size.height;
      final midX = (x0 + x1) / 2;
      path.cubicTo(midX, y0, midX, y1, x1, y1);
    }
    path
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant SkyPainter oldDelegate) {
    return oldDelegate.total != total ||
        oldDelegate.completed != completed ||
        oldDelegate.progress != progress;
  }
}
