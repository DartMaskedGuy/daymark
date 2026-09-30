import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/extensions/date_x.dart';
import '../../../data/database/app_database.dart';
import '../../../data/repositories/bucket_list_repository.dart';
import '../bloc/home_cubit.dart';
import '../widgets/sky_hero.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit(context.read<BucketListRepository>()),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            final loading = state.status == HomeStatus.loading;
            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  automaticallyImplyLeading: false,
                  toolbarHeight: 56,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      color: const Color(0xFF0E0D2B),
                      child: SafeArea(
                        top: true,
                        bottom: false,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: AppSpacing.sm,
                          ),
                          child: Row(
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
                                        BoxShadow(
                                          color: kLivedAmber,
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Text(
                                    'Daymark',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
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
                                  onPressed: () => context.push('/settings'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SkyHero(
                    greeting: _greeting,
                    completed: state.completed,
                    total: state.total,
                    progress: state.progress,
                    loading: loading,
                    hideAppBar: true,
                  ),
                ),
                if (state.status == HomeStatus.error)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: _ErrorNote(),
                    ),
                  )
                else if (!loading)
                  SliverList(
                    delegate: SliverChildListDelegate(
                      _sections(context, state),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<Widget> _sections(BuildContext context, HomeState state) {
    final stats = <_StatEntry>[
      _StatEntry(
        value: state.completed,
        label: 'Lived',
        icon: Icons.auto_awesome_rounded,
        color: kLivedAmber,
        emphasize: true,
      ),
      _StatEntry(
        value: state.remaining,
        label: 'To go',
        icon: Icons.hourglass_bottom_rounded,
        color: AppColors.itemPalette['neutral']!,
      ),
      if (state.countries > 0)
        _StatEntry(
          value: state.countries,
          label: 'Countries',
          icon: Icons.public_rounded,
          color: AppColors.itemPalette['teal']!,
        ),
      if (state.states > 0)
        _StatEntry(
          value: state.states,
          label: 'States',
          icon: Icons.location_on_rounded,
          color: AppColors.itemPalette['violet']!,
        ),
    ];

    return [
      if (state.total > 0)
        _FadeIn(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.md,
              0,
            ),
            child: _StatsStrip(entries: stats),
          ),
        ),
      _FadeIn(
        delayMs: 80,
        child: Padding(
          padding: const EdgeInsets.only(top: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: _SectionHeader(title: 'Recently lived'),
              ),
              const SizedBox(height: AppSpacing.sm),
              if (state.recentlyCompleted.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  child: _FirstStarCard(
                    onAdd: () => context.push('/bucket-list/add'),
                  ),
                )
              else
                SizedBox(
                  height: 150,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    itemCount: state.recentlyCompleted.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(width: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final item = state.recentlyCompleted[index];
                      return _LivedCard(
                        item: item,
                        onTap: () => context.push('/bucket-list/${item.id}'),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
      if (state.highPriority.isNotEmpty)
        _FadeIn(
          delayMs: 160,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.md,
              0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionHeader(
                  title: 'Must experience',
                  actionLabel: 'View all',
                  onAction: () => context.go('/bucket-list'),
                ),
                const SizedBox(height: AppSpacing.sm),
                _MustExperienceList(items: state.highPriority),
              ],
            ),
          ),
        ),
      _FadeIn(
        delayMs: 240,
        child: const Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.md,
            0,
          ),
          child: _TogetherPreview(),
        ),
      ),
      const SizedBox(height: AppSpacing.xl),
    ];
  }
}

IconData _categoryIcon(String category) => switch (category) {
  'Travel' => Icons.flight_takeoff,
  'Experience' => Icons.auto_awesome,
  'Personal' => Icons.person_outline,
  'Career' => Icons.work_outline,
  'Education' => Icons.school_outlined,
  'Adventure' => Icons.terrain,
  _ => Icons.star_outline,
};

String _locationOf(BucketListItem item) => [
  item.city,
  item.country,
].where((s) => s != null && s.isNotEmpty).join(', ');

/// Fades and lifts a section in once, so the page settles in a cascade
/// rather than appearing all at once. Skipped when animations are off.
class _FadeIn extends StatelessWidget {
  const _FadeIn({required this.child, this.delayMs = 0});

  final Widget child;
  final int delayMs;

  static const int _baseMs = 550;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).disableAnimations) return child;
    final totalMs = _baseMs + delayMs;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: totalMs),
      curve: Interval(delayMs / totalMs, 1, curve: Curves.easeOutCubic),
      child: child,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, 16 * (1 - t)),
          child: child,
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.actionLabel, this.onAction});

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: theme.textTheme.titleMedium),
        if (actionLabel != null)
          TextButton(onPressed: onAction, child: Text(actionLabel!)),
      ],
    );
  }
}

class _StatEntry {
  const _StatEntry({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
    this.emphasize = false,
  });

  final int value;
  final String label;
  final IconData icon;
  final Color color;
  final bool emphasize;
}

/// Stats laid out as waypoints on a trail rather than columns divided by
/// hairlines — a small continuation of the hero's connected-star idea, one
/// step down from the sky itself. Each stat gets its own tinted badge
/// (occluding the dashed trail behind it, like a bead on a string) instead
/// of every number looking the same; "Lived" gets a soft glow to match its
/// weight as the headline stat.
class _StatsStrip extends StatelessWidget {
  const _StatsStrip({required this.entries});

  final List<_StatEntry> entries;

  static const double _badgeSize = 40;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = theme.cardTheme.color ?? theme.colorScheme.surface;
    final trailColor =
        theme.dividerTheme.color ??
        theme.colorScheme.outline.withValues(alpha: 0.3);

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, AppSpacing.lg, 0, AppSpacing.md),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // First and last badges sit at the center of their own evenly
            // divided column, so the trail's inset from each edge is
            // exactly half a column's width — not a guessed pixel value.
            final inset = constraints.maxWidth / (2 * entries.length);
            return Stack(
              alignment: Alignment.topCenter,
              children: [
                Positioned(
                  top: _badgeSize / 2,
                  left: inset,
                  right: inset,
                  child: CustomPaint(
                    size: const Size(double.infinity, 1),
                    painter: _DashedLinePainter(color: trailColor),
                  ),
                ),
                Row(
                  children: [
                    for (final entry in entries)
                      Expanded(
                        child: Column(
                          children: [
                            Container(
                              width: _badgeSize,
                              height: _badgeSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: cardColor,
                                border: Border.all(
                                  color: entry.color.withValues(alpha: 0.55),
                                  width: 1.4,
                                ),
                                boxShadow: entry.emphasize
                                    ? [
                                        BoxShadow(
                                          color: entry.color.withValues(
                                            alpha: 0.35,
                                          ),
                                          blurRadius: 14,
                                          spreadRadius: 1,
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Icon(
                                entry.icon,
                                size: 18,
                                color: entry.color,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            TweenAnimationBuilder<double>(
                              tween: Tween(
                                begin: 0,
                                end: entry.value.toDouble(),
                              ),
                              duration: const Duration(milliseconds: 800),
                              curve: Curves.easeOutCubic,
                              builder: (context, value, _) => Text(
                                '${value.round()}',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontSize: entry.emphasize ? 24 : 20,
                                ),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              entry.label,
                              style: theme.textTheme.labelSmall,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  _DashedLinePainter({required this.color});

  final Color color;
  static const double _dashWidth = 4;
  static const double _gap = 4;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    final y = size.height / 2;
    var x = 0.0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, y), Offset(x + _dashWidth, y), paint);
      x += _dashWidth + _gap;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) =>
      oldDelegate.color != color;
}

class _LivedCard extends StatelessWidget {
  const _LivedCard({required this.item, required this.onTap});

  final BucketListItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = AppColors.fromKey(item.color);
    final subline = [
      _locationOf(item),
      item.completedAt?.relativeOrFormatted ?? '',
    ].where((s) => s.isNotEmpty).join(' • ');

    return SizedBox(
      width: 232,
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 64,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      accent.withValues(alpha: 0.35),
                      accent.withValues(alpha: 0.08),
                    ],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(_categoryIcon(item.category), color: accent),
                    Icon(Icons.check_circle, color: accent, size: 20),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: theme.textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subline,
                      style: theme.textTheme.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FirstStarCard extends StatelessWidget {
  const _FirstStarCard({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: kLivedAmber.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.star_outline_rounded, color: kLivedAmber),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your story is just beginning.',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Live your first item and it lights a star in your sky.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Add something',
              onPressed: onAdd,
              icon: Icon(
                Icons.add_circle_outline,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MustExperienceList extends StatelessWidget {
  const _MustExperienceList({required this.items});

  final List<BucketListItem> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            InkWell(
              onTap: () => context.push('/bucket-list/${items[i].id}'),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.fromKey(
                          items[i].color,
                        ).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _categoryIcon(items[i].category),
                        size: 20,
                        color: AppColors.fromKey(items[i].color),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            items[i].title,
                            style: theme.textTheme.titleMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (_locationOf(items[i]).isNotEmpty)
                            Text(
                              _locationOf(items[i]),
                              style: theme.textTheme.bodyMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: theme.textTheme.bodyMedium?.color,
                    ),
                  ],
                ),
              ),
            ),
            if (i < items.length - 1)
              Divider(height: 1, indent: 72, color: theme.dividerTheme.color),
          ],
        ],
      ),
    );
  }
}

/// Placeholder for the upcoming social features: sharing a list with
/// friends, group bucket lists, and connecting with like-minded people.
class _TogetherPreview extends StatelessWidget {
  const _TogetherPreview();

  static const _avatarSize = 36.0;
  static const _avatarOverlap = 24.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.colorScheme.surface;
    final avatarColors = [
      AppColors.itemPalette['indigo']!,
      AppColors.itemPalette['teal']!,
      AppColors.itemPalette['pink']!,
    ];

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sharing and groups are on the way.')),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Together', style: theme.textTheme.titleMedium),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Text(
                      'Soon',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Share your list with friends, dream up group bucket lists, and meet people who want the same things.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                height: _avatarSize,
                width: _avatarOverlap * avatarColors.length + _avatarSize,
                child: Stack(
                  children: [
                    for (var i = 0; i < avatarColors.length; i++)
                      Positioned(
                        left: i * _avatarOverlap,
                        child: Container(
                          width: _avatarSize,
                          height: _avatarSize,
                          decoration: BoxDecoration(
                            color: avatarColors[i].withValues(alpha: 0.85),
                            shape: BoxShape.circle,
                            border: Border.all(color: surface, width: 2),
                          ),
                          child: const Icon(
                            Icons.person_outline,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    Positioned(
                      left: avatarColors.length * _avatarOverlap,
                      child: Container(
                        width: _avatarSize,
                        height: _avatarSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.6,
                            ),
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          Icons.add,
                          size: 18,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              const Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  _TeaserChip(
                    icon: Icons.ios_share_rounded,
                    label: 'Share your list',
                  ),
                  _TeaserChip(
                    icon: Icons.groups_outlined,
                    label: 'Group lists',
                  ),
                  _TeaserChip(
                    icon: Icons.favorite_border_rounded,
                    label: 'Like minds',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TeaserChip extends StatelessWidget {
  const _TeaserChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodyMedium?.color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: theme.dividerTheme.color ?? Colors.transparent,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: muted),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _ErrorNote extends StatelessWidget {
  const _ErrorNote();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Text(
          'Something went wrong while loading your journey.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}
