import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../data/database/app_database.dart';
import '../../../data/repositories/bucket_list_repository.dart';
import '../../../data/repositories/media_repository.dart';
import '../../../data/repositories/memory_repository.dart';
import '../bloc/item_details_cubit.dart';

const double _heroHeight = 380;
const double _sheetOverlap = 28;

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

Color _darken(Color c, [double amount = 0.4]) =>
    Color.lerp(c, Colors.black, amount) ?? c;

IconData _categoryIcon(String category) => switch (category) {
  'Travel' => Icons.flight_takeoff_rounded,
  'Experience' => Icons.auto_awesome_rounded,
  'Personal' => Icons.person_rounded,
  'Career' => Icons.work_rounded,
  'Education' => Icons.school_rounded,
  'Adventure' => Icons.terrain_rounded,
  _ => Icons.star_rounded,
};

Color _priorityColor(String priority) => switch (priority) {
  'High' => const Color(0xFFEF4444),
  'Medium' => const Color(0xFFEAB308),
  _ => const Color(0xFF9CA3AF),
};

IconData _priorityIcon(String priority) => switch (priority) {
  'High' => Icons.local_fire_department_rounded,
  'Medium' => Icons.bolt_rounded,
  _ => Icons.spa_rounded,
};

Color _successOf(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
    ? AppColors.darkSuccess
    : AppColors.lightSuccess;

String _countdown(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final days = DateTime(
    date.year,
    date.month,
    date.day,
  ).difference(today).inDays;
  if (days < 0) return 'Date has passed';
  if (days == 0) return 'That\'s today!';
  if (days == 1) return 'Tomorrow';
  if (days < 60) return 'In $days days';
  if (days < 700) return 'In about ${(days / 30).round()} months';
  return 'In about ${(days / 365).toStringAsFixed(1)} years';
}

// ─────────────────────────────────────────────────────────────────────────────
// Page
// ─────────────────────────────────────────────────────────────────────────────

class ItemDetailsPage extends StatelessWidget {
  const ItemDetailsPage({super.key, required this.itemId});

  final String itemId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ItemDetailsCubit(
        context.read<BucketListRepository>(),
        context.read<MediaRepository>(),
        context.read<MemoryRepository>(),
        itemId,
      ),
      child: const _ItemDetailsView(),
    );
  }
}

class _ItemDetailsView extends StatelessWidget {
  const _ItemDetailsView();

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => const _DeleteDialog(),
    );
    if (confirmed == true && context.mounted) {
      await context.read<ItemDetailsCubit>().delete();
      if (context.mounted) context.pop();
    }
  }

  Future<void> _handleToggle(BuildContext context, Color accent) async {
    final nowCompleted = await context
        .read<ItemDetailsCubit>()
        .toggleCompleted();
    if (!context.mounted || !nowCompleted) return;
    HapticFeedback.heavyImpact();
    await showDialog<bool>(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => _CelebrationDialog(accent: accent),
    );
  }

  Future<void> _openMemory(BuildContext context) async {
    final cubit = context.read<ItemDetailsCubit>();
    await context.push('/memory/${cubit.itemId}');
    if (context.mounted) cubit.refresh();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<ItemDetailsCubit, ItemDetailsState>(
      listenWhen: (a, b) =>
          a.errorMessage != b.errorMessage && b.errorMessage != null,
      listener: (context, state) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(state.errorMessage!))),
      builder: (context, state) {
        if (state.status == ItemDetailsStatus.loading) {
          return const _LoadingView();
        }
        if (state.status == ItemDetailsStatus.notFound || state.item == null) {
          return _NotFoundView(onBack: () => context.pop());
        }

        final item = state.item!;
        final accent = AppColors.fromKey(item.color);
        final success = _successOf(context);
        final location = [
          item.city,
          item.state,
          item.country,
        ].where((s) => s != null && s.isNotEmpty).join(', ');
        final hasDescription =
            item.description != null && item.description!.isNotEmpty;
        final date = item.targetDate;

        var reveal = 0;

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: Scaffold(
            bottomNavigationBar: _ActionBar(
              isCompleted: item.isCompleted,
              success: success,
              onTap: () => _handleToggle(context, accent),
            ),
            body: CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  elevation: 0,
                  scrolledUnderElevation: 0,
                  surfaceTintColor: Colors.transparent,
                  backgroundColor: _darken(accent, 0.5),
                  automaticallyImplyLeading: false,
                  expandedHeight: _heroHeight,
                  toolbarHeight: 60,
                  leadingWidth: 68,
                  leading: Padding(
                    padding: const EdgeInsets.only(left: AppSpacing.md),
                    child: Center(
                      child: _GlassButton(
                        icon: Icons.arrow_back_rounded,
                        onTap: () => context.pop(),
                      ),
                    ),
                  ),
                  actions: [
                    _GlassButton(
                      icon: Icons.edit_rounded,
                      onTap: () => context.push('/bucket-list/${item.id}/edit'),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _GlassButton(
                      icon: Icons.delete_outline_rounded,
                      onTap: () => _confirmDelete(context),
                    ),
                    const SizedBox(width: AppSpacing.md),
                  ],
                  flexibleSpace: _HeroSpace(
                    item: item,
                    media: state.media,
                    accent: accent,
                    location: location,
                  ),
                ),
                SliverToBoxAdapter(
                  child: Transform.translate(
                    offset: const Offset(0, -_sheetOverlap),
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.scaffoldBackgroundColor,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(32),
                        ),
                      ),
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        AppSpacing.lg,
                        AppSpacing.md,
                        AppSpacing.xxl,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: AppSpacing.lg),
                          _Reveal(
                            index: reveal++,
                            child: IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    child: _FactTile(
                                      icon: _priorityIcon(item.priority),
                                      label: 'Priority',
                                      value: item.priority,
                                      color: _priorityColor(item.priority),
                                    ),
                                  ),
                                  if (date != null) ...[
                                    const SizedBox(width: AppSpacing.sm),
                                    Expanded(
                                      child: _FactTile(
                                        icon: Icons.event_rounded,
                                        label: 'Target',
                                        value: DateFormat(
                                          'MMM d, y',
                                        ).format(date),
                                        caption: item.isCompleted
                                            ? null
                                            : _countdown(date),
                                        color:
                                            !item.isCompleted &&
                                                date.isBefore(DateTime.now())
                                            ? theme.colorScheme.error
                                            : accent,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          if (location.isNotEmpty) ...[
                            const SizedBox(height: AppSpacing.sm),
                            _Reveal(
                              index: reveal++,
                              child: _LocationTile(
                                location: location,
                                accent: accent,
                              ),
                            ),
                          ],
                          if (hasDescription) ...[
                            const SizedBox(height: AppSpacing.md),
                            _Reveal(
                              index: reveal++,
                              child: _Section(
                                icon: Icons.format_quote_rounded,
                                title: 'The story',
                                accent: accent,
                                child: Text(
                                  item.description!,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    height: 1.55,
                                  ),
                                ),
                              ),
                            ),
                          ],
                          if (state.links.isNotEmpty) ...[
                            const SizedBox(height: AppSpacing.md),
                            _Reveal(
                              index: reveal++,
                              child: _Section(
                                icon: Icons.link_rounded,
                                title: 'Links',
                                accent: accent,
                                child: Column(
                                  children: [
                                    for (final link in state.links)
                                      _LinkTile(
                                        title: link.title,
                                        url: link.url,
                                        accent: accent,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                          // Memory
                          if (item.isCompleted) ...[
                            const SizedBox(height: AppSpacing.md),
                            _MemorySection(
                              memory: state.memory,
                              accent: accent,
                              onTap: () => _openMemory(context),
                            ),
                          ],
                          const SizedBox(height: AppSpacing.md),
                          _Reveal(
                            index: reveal++,
                            child: _JourneyCard(
                              item: item,
                              accent: accent,
                              success: success,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Collapsing hero
// ─────────────────────────────────────────────────────────────────────────────

/// Reads the SliverAppBar's collapse progress and hands it to the hero content.
class _HeroSpace extends StatelessWidget {
  const _HeroSpace({
    required this.item,
    required this.media,
    required this.accent,
    required this.location,
  });

  final BucketListItem item;
  final List<MediaItem> media;
  final Color accent;
  final String location;

  @override
  Widget build(BuildContext context) {
    final settings = context
        .dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();
    var t = 0.0;
    var maxExtent = _heroHeight;
    var currentExtent = _heroHeight;
    var delta = 1.0;
    if (settings != null) {
      maxExtent = settings.maxExtent;
      currentExtent = settings.currentExtent;
      delta = math.max(settings.maxExtent - settings.minExtent, 1);
      t = ((maxExtent - currentExtent) / delta).clamp(0.0, 1.0).toDouble();
    }

    return _HeroContent(
      item: item,
      media: media,
      accent: accent,
      location: location,
      t: t,
      mediaHeight: math.max(maxExtent, currentExtent),
      parallax: t * delta * 0.35,
      topPadding: MediaQuery.paddingOf(context).top,
    );
  }
}

class _HeroContent extends StatefulWidget {
  const _HeroContent({
    required this.item,
    required this.media,
    required this.accent,
    required this.location,
    required this.t,
    required this.mediaHeight,
    required this.parallax,
    required this.topPadding,
  });

  final BucketListItem item;
  final List<MediaItem> media;
  final Color accent;
  final String location;
  final double t;
  final double mediaHeight;
  final double parallax;
  final double topPadding;

  @override
  State<_HeroContent> createState() => _HeroContentState();
}

class _HeroContentState extends State<_HeroContent> {
  final _pageController = PageController();
  int _page = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _openFullScreen(int initialIndex) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black,
        pageBuilder: (context, animation, secondary) => FadeTransition(
          opacity: animation,
          child: _FullScreenGallery(
            media: widget.media,
            initialIndex: initialIndex,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final item = widget.item;
    final accent = widget.accent;
    final t = widget.t;
    final hasMedia = widget.media.isNotEmpty;
    final multiple = widget.media.length > 1;
    final fade = (1 - t * 2.2).clamp(0.0, 1.0).toDouble();
    final titleFade = ((t - 0.72) / 0.28).clamp(0.0, 1.0).toDouble();

    return Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.hardEdge,
      children: [
        // Media / accent panel, kept at full height and clipped for parallax.
        Positioned(
          top: -widget.parallax,
          left: 0,
          right: 0,
          height: widget.mediaHeight,
          child: hasMedia
              ? PageView.builder(
                  controller: _pageController,
                  itemCount: widget.media.length,
                  onPageChanged: (i) => setState(() => _page = i),
                  itemBuilder: (context, index) {
                    final m = widget.media[index];
                    return GestureDetector(
                      onTap: () => _openFullScreen(index),
                      child: Hero(
                        tag: 'media-${m.id}',
                        child: Image.file(
                          File(m.path),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                color: accent.withValues(alpha: 0.2),
                                child: Icon(
                                  Icons.broken_image_outlined,
                                  color: accent,
                                ),
                              ),
                        ),
                      ),
                    );
                  },
                )
              : _AccentPanel(accent: accent, category: item.category),
        ),

        // Top scrim for status bar + floating buttons.
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 140 + widget.topPadding,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.5),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),

        // Bottom scrim so the title stays readable on bright photos.
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 300,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: hasMedia ? 0.78 : 0.4),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Solid accent bar once collapsed.
        Positioned.fill(
          child: IgnorePointer(
            child: ColoredBox(color: _darken(accent, 0.5).withValues(alpha: t)),
          ),
        ),

        // "LIVED" stamp.
        if (item.isCompleted)
          Positioned(
            top: widget.topPadding + 74,
            right: 20,
            child: IgnorePointer(
              child: Opacity(
                opacity: (1 - t * 3).clamp(0.0, 1.0).toDouble(),
                child: const _LivedStamp(),
              ),
            ),
          ),

        // Title block.
        Positioned(
          left: 20,
          right: 20,
          bottom: _sheetOverlap + (multiple ? 42 : 20),
          child: IgnorePointer(
            ignoring: fade == 0,
            child: Opacity(
              opacity: fade,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      _GlassTag(
                        icon: _categoryIcon(item.category),
                        label: item.category,
                      ),
                      const SizedBox(width: 8),
                      _GlassTag(
                        icon: _priorityIcon(item.priority),
                        label: '${item.priority} priority',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item.title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                      letterSpacing: -0.7,
                    ),
                  ),
                  if (widget.location.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(
                          Icons.place_rounded,
                          size: 16,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            widget.location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white70,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),

        // Page dots.
        if (multiple)
          Positioned(
            bottom: _sheetOverlap + 14,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Opacity(
                opacity: fade,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(widget.media.length, (i) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: i == _page ? 20 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(
                          alpha: i == _page ? 0.95 : 0.45,
                        ),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),

        // Compact title shown in the collapsed bar.
        Positioned(
          left: 76,
          right: 128,
          bottom: 0,
          height: 60,
          child: IgnorePointer(
            child: Opacity(
              opacity: titleFade,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Shown when the item has no photos: the item's own colour does the work.
class _AccentPanel extends StatelessWidget {
  const _AccentPanel({required this.accent, required this.category});

  final Color accent;
  final String category;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [accent, _darken(accent, 0.55)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(right: -60, top: 40, child: _Orb(size: 240, alpha: 0.12)),
          Positioned(
            left: -50,
            bottom: 60,
            child: _Orb(size: 180, alpha: 0.08),
          ),
          Align(
            alignment: const Alignment(0, -0.35),
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
              ),
              child: Icon(
                _categoryIcon(category),
                size: 56,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Orb extends StatelessWidget {
  const _Orb({required this.size, required this.alpha});

  final double size;
  final double alpha;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: alpha),
      ),
    );
  }
}

class _LivedStamp extends StatelessWidget {
  const _LivedStamp();

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.28,
      child: Container(
        width: 78,
        height: 78,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withValues(alpha: 0.28),
          border: Border.all(color: Colors.white, width: 1.8),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_rounded, color: Colors.white, size: 22),
            SizedBox(height: 1),
            Text(
              'LIVED',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassTag extends StatelessWidget {
  const _GlassTag({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassButton extends StatelessWidget {
  const _GlassButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Material(
          color: Colors.black.withValues(alpha: 0.28),
          child: InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              onTap();
            },
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Entrance animation + section container
// ─────────────────────────────────────────────────────────────────────────────

class _Reveal extends StatelessWidget {
  const _Reveal({required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 420 + index * 90),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, 24 * (1 - t)),
          child: child,
        ),
      ),
      child: child,
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.icon,
    required this.title,
    required this.accent,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Color accent;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, size: 17, color: accent),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Facts, location, links
// ─────────────────────────────────────────────────────────────────────────────

class _FactTile extends StatelessWidget {
  const _FactTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.caption,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(height: 14),
          Text(
            label.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              letterSpacing: 1.3,
              fontWeight: FontWeight.w700,
              color: scheme.onSurfaceVariant.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          if (caption != null) ...[
            const SizedBox(height: 3),
            Text(
              caption!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LocationTile extends StatelessWidget {
  const _LocationTile({required this.location, required this.accent});

  final String location;
  final Color accent;

  Future<void> _openMaps() async {
    final uri = Uri.https('www.google.com', '/maps/search/', {
      'api': '1',
      'query': location,
    });
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Material(
      color: scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.2)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          _openMaps();
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.place_rounded, size: 22, color: accent),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LOCATION',
                      style: theme.textTheme.labelSmall?.copyWith(
                        letterSpacing: 1.3,
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurfaceVariant.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      location,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.map_rounded, size: 20, color: accent),
            ],
          ),
        ),
      ),
    );
  }
}

class _LinkTile extends StatelessWidget {
  const _LinkTile({
    required this.title,
    required this.url,
    required this.accent,
  });

  final String title;
  final String url;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final uri = Uri.tryParse(url);
    final host = (uri != null && uri.host.isNotEmpty) ? uri.host : url;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: uri == null
              ? null
              : () {
                  HapticFeedback.selectionClick();
                  launchUrl(uri, mode: LaunchMode.externalApplication);
                },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(Icons.link_rounded, color: accent, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        host,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.north_east_rounded,
                  size: 18,
                  color: scheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MemorySection extends StatelessWidget {
  const _MemorySection({
    required this.memory,
    required this.accent,
    required this.onTap,
  });

  final Memory? memory;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final hasNotes = memory?.notes != null && memory!.notes!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.2)),
      ),

      child: InkWell(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accent.withValues(alpha: 0.2),
              ),
              child: Icon(Icons.auto_stories_outlined, color: accent, size: 18),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasNotes ? 'Memory' : 'Save the memory',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hasNotes
                        ? memory!.notes!
                        : 'Add notes, photos, videos, or links from this experience.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontStyle: hasNotes ? FontStyle.italic : FontStyle.normal,
                    ),
                    maxLines: hasNotes ? 3 : 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: theme.textTheme.bodyMedium?.color),
          ],
        ),
      ),
    );
  }
}
// ─────────────────────────────────────────────────────────────────────────────
// Journey / status card
// ─────────────────────────────────────────────────────────────────────────────

class _JourneyCard extends StatelessWidget {
  const _JourneyCard({
    required this.item,
    required this.accent,
    required this.success,
  });

  final BucketListItem item;
  final Color accent;
  final Color success;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final completedAt = item.completedAt;
    final date = item.targetDate;

    if (item.isCompleted) {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [success, _darken(success, 0.4)],
          ),
          boxShadow: [
            BoxShadow(
              color: success.withValues(alpha: 0.35),
              blurRadius: 28,
              offset: const Offset(0, 14),
              spreadRadius: -8,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            children: [
              Positioned(
                right: -30,
                top: -40,
                child: _Orb(size: 140, alpha: 0.13),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.2),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.35),
                        ),
                      ),
                      child: const Icon(
                        Icons.emoji_events_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'YOU LIVED IT',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.white70,
                              letterSpacing: 1.6,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            completedAt != null
                                ? DateFormat('MMMM d, y').format(completedAt)
                                : 'Completed',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: accent.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent.withValues(alpha: 0.14),
            ),
            child: Icon(Icons.hourglass_top_rounded, color: accent, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'STILL AHEAD',
                  style: theme.textTheme.labelSmall?.copyWith(
                    letterSpacing: 1.6,
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurfaceVariant.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date != null ? _countdown(date) : 'No target date yet',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  date != null
                      ? 'Make it happen.'
                      : 'Set one whenever you\'re ready.',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sticky action bar
// ─────────────────────────────────────────────────────────────────────────────

class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.isCompleted,
    required this.success,
    required this.onTap,
  });

  final bool isCompleted;
  final Color success;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        10,
        AppSpacing.md,
        10 + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(
          top: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.4)),
        ),
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: isCompleted
              ? null
              : LinearGradient(colors: [success, _darken(success, 0.35)]),
          color: isCompleted ? scheme.surfaceContainerHigh : null,
          border: isCompleted
              ? Border.all(color: scheme.outlineVariant.withValues(alpha: 0.6))
              : null,
          boxShadow: isCompleted
              ? null
              : [
                  BoxShadow(
                    color: success.withValues(alpha: 0.45),
                    blurRadius: 22,
                    offset: const Offset(0, 10),
                    spreadRadius: -6,
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              HapticFeedback.mediumImpact();
              onTap();
            },
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isCompleted
                        ? Icons.undo_rounded
                        : Icons.check_circle_rounded,
                    size: 16,
                    color: isCompleted ? scheme.onSurface : Colors.white,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    isCompleted ? 'Mark as incomplete' : 'Mark as completed',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                      fontSize: 14,
                      color: isCompleted ? scheme.onSurface : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Dialogs
// ─────────────────────────────────────────────────────────────────────────────

class _DeleteDialog extends StatelessWidget {
  const _DeleteDialog();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Dialog(
      backgroundColor: scheme.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: scheme.error.withValues(alpha: 0.13),
              ),
              child: Icon(
                Icons.delete_outline_rounded,
                color: scheme.error,
                size: 32,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Delete this bucket-list item?',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This will remove the item and its saved memories.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: scheme.surfaceContainerHigh,
                        foregroundColor: scheme.onSurface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: scheme.error,
                        foregroundColor: scheme.onError,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        Navigator.of(context).pop(true);
                      },
                      child: const Text(
                        'Delete',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CelebrationDialog extends StatelessWidget {
  const _CelebrationDialog({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final success = _successOf(context);

    return Dialog(
      backgroundColor: scheme.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 170,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  _Burst(colors: [accent, success, const Color(0xFFEAB308)]),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 750),
                    curve: Curves.elasticOut,
                    builder: (context, t, child) =>
                        Transform.scale(scale: t.clamp(0.0, 1.3), child: child),
                    child: Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [success, _darken(success, 0.35)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: success.withValues(alpha: 0.5),
                            blurRadius: 26,
                            offset: const Offset(0, 10),
                            spreadRadius: -4,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.emoji_events_rounded,
                        color: Colors.white,
                        size: 44,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              'You lived it. ✨',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Want to save the memory?',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 22),
            Container(
              height: 54,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(
                  colors: [accent, _darken(accent, 0.35)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.45),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                    spreadRadius: -6,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    Navigator.of(context).pop(true);
                  },
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.auto_stories_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Add memory',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Maybe later',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A one-shot radial burst of dots behind the trophy.
class _Burst extends StatelessWidget {
  const _Burst({required this.colors});

  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    const count = 14;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeOutCubic,
      builder: (context, t, _) {
        return Stack(
          alignment: Alignment.center,
          children: [
            for (var i = 0; i < count; i++)
              Transform.translate(
                offset: Offset.fromDirection(
                  (2 * math.pi / count) * i,
                  46 + (i.isEven ? 58 : 40) * t,
                ),
                child: Opacity(
                  opacity: (1 - t).clamp(0.0, 1.0).toDouble(),
                  child: Container(
                    width: i.isEven ? 9 : 6,
                    height: i.isEven ? 9 : 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors[i % colors.length],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Loading / not found
// ─────────────────────────────────────────────────────────────────────────────

class _LoadingView extends StatefulWidget {
  const _LoadingView();

  @override
  State<_LoadingView> createState() => _LoadingViewState();
}

class _LoadingViewState extends State<_LoadingView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final base = scheme.surfaceContainerHigh;
    final strong = scheme.surfaceContainerHighest;

    Widget block(double h, {double? w, double r = 14}) => Container(
      height: h,
      width: w,
      decoration: BoxDecoration(
        color: strong,
        borderRadius: BorderRadius.circular(r),
      ),
    );

    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final o = 0.45 + 0.4 * Curves.easeInOut.transform(_controller.value);
          return Opacity(
            opacity: o,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: _heroHeight,
                  decoration: BoxDecoration(
                    color: base,
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(32),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: block(92, r: 24)),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(child: block(92, r: 24)),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      block(120, r: 26),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _NotFoundView extends StatelessWidget {
  const _NotFoundView({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: onBack,
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primary.withValues(alpha: 0.12),
                ),
                child: Icon(Icons.search_off_rounded, size: 44, color: primary),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'This item no longer exists.',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              FilledButton.tonal(
                onPressed: onBack,
                child: const Text('Go back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Full-screen gallery
// ─────────────────────────────────────────────────────────────────────────────

/// Full-bleed, pinch-to-zoom viewer for a tapped photo, opened as a
/// Hero-linked overlay rather than a full page transition.
class _FullScreenGallery extends StatefulWidget {
  const _FullScreenGallery({required this.media, required this.initialIndex});

  final List<MediaItem> media;
  final int initialIndex;

  @override
  State<_FullScreenGallery> createState() => _FullScreenGalleryState();
}

class _FullScreenGalleryState extends State<_FullScreenGallery> {
  late final PageController _controller = PageController(
    initialPage: widget.initialIndex,
  );
  late int _index = widget.initialIndex;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: widget.media.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, index) {
              final item = widget.media[index];
              return Center(
                child: Hero(
                  tag: 'media-${item.id}',
                  child: InteractiveViewer(
                    child: Image.file(
                      File(item.path),
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.broken_image_outlined,
                        color: Colors.white54,
                        size: 48,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          Positioned(
            top: top + AppSpacing.sm,
            right: AppSpacing.md,
            child: _GlassButton(
              icon: Icons.close_rounded,
              onTap: () => Navigator.of(context).pop(),
            ),
          ),
          if (widget.media.length > 1)
            Positioned(
              top: top + AppSpacing.sm,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_index + 1} / ${widget.media.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
