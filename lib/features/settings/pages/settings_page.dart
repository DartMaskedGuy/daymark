// import 'package:flutter/material.dart';
// import 'package:package_info_plus/package_info_plus.dart';
// import '../../../core/constants/app_spacing.dart';

// class SettingsPage extends StatelessWidget {
//   const SettingsPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Settings')),
//       body: ListView(
//         padding: const EdgeInsets.all(AppSpacing.md),
//         children: [
//           _SectionHeader('Appearance'),
//           const ListTile(
//             contentPadding: EdgeInsets.zero,
//             title: Text('Theme'),
//             subtitle: Text('Follows your system setting'),
//             trailing: Icon(Icons.chevron_right),
//           ),
//           const SizedBox(height: AppSpacing.lg),
//           _SectionHeader('Data'),
//           ListTile(
//             contentPadding: EdgeInsets.zero,
//             leading: const Icon(Icons.file_upload_outlined),
//             title: const Text('Export data'),
//             onTap: () {},
//           ),
//           ListTile(
//             contentPadding: EdgeInsets.zero,
//             leading: const Icon(Icons.file_download_outlined),
//             title: const Text('Import data'),
//             onTap: () {},
//           ),
//           const SizedBox(height: AppSpacing.lg),
//           _SectionHeader('Cloud Sync'),
//           const ListTile(
//             contentPadding: EdgeInsets.zero,
//             leading: Icon(Icons.cloud_outlined),
//             title: Text('Cloud sync'),
//             subtitle: Text('Coming soon'),
//           ),
//           const SizedBox(height: AppSpacing.lg),
//           _SectionHeader('About'),
//           FutureBuilder<PackageInfo>(
//             future: PackageInfo.fromPlatform(),
//             builder: (context, snapshot) {
//               final version = snapshot.data?.version ?? '—';
//               return ListTile(
//                 contentPadding: EdgeInsets.zero,
//                 title: const Text('App version'),
//                 trailing: Text(version),
//               );
//             },
//           ),
//           const ListTile(
//             contentPadding: EdgeInsets.zero,
//             title: Text('About Daymark'),
//             subtitle: Text(
//               'Keep track of the things you want to live, and the ones you already have.',
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _SectionHeader extends StatelessWidget {
//   const _SectionHeader(this.label);

//   final String label;

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: AppSpacing.sm),
//       child: Text(label, style: Theme.of(context).textTheme.labelSmall),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../core/constants/app_spacing.dart';

Color _darken(Color c, [double amount = 0.4]) =>
    Color.lerp(c, Colors.black, amount) ?? c;

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Cached so the lookup isn't repeated on every rebuild.
  late final Future<PackageInfo> _packageInfo = PackageInfo.fromPlatform();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final topInset = MediaQuery.paddingOf(context).top + kToolbarHeight;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          'Settings',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Ambient glow behind the header.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 380,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      primary.withValues(alpha: 0.22),
                      primary.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          ListView(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.md,
              topInset + AppSpacing.sm,
              AppSpacing.md,
              96,
            ),
            children: [
              _Reveal(
                index: 0,
                child: FutureBuilder<PackageInfo>(
                  future: _packageInfo,
                  builder: (context, snapshot) =>
                      _BrandCard(version: snapshot.data?.version),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _Reveal(
                index: 1,
                child: _Group(
                  label: 'Appearance',
                  children: [
                    _SettingsTile(
                      icon: Icons.palette_rounded,
                      color: const Color(0xFF8B5CF6),
                      title: 'Theme',
                      subtitle: 'Follows your system setting',
                      trailing: const _ValuePill('System'),
                      showChevron: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _Reveal(
                index: 2,
                child: _Group(
                  label: 'Data',
                  children: [
                    _SettingsTile(
                      icon: Icons.file_upload_rounded,
                      color: const Color(0xFF10B981),
                      title: 'Export data',
                      showChevron: true,
                      onTap: () {}, // TODO: hook up export.
                    ),
                    _SettingsTile(
                      icon: Icons.file_download_rounded,
                      color: const Color(0xFF3B82F6),
                      title: 'Import data',
                      showChevron: true,
                      onTap: () {}, // TODO: hook up import.
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _Reveal(
                index: 3,
                child: _Group(
                  label: 'Cloud Sync',
                  children: const [
                    _SettingsTile(
                      icon: Icons.cloud_rounded,
                      color: Color(0xFF06B6D4),
                      title: 'Cloud sync',
                      subtitle: 'Coming soon',
                      trailing: _SoonBadge(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _Reveal(
                index: 4,
                child: FutureBuilder<PackageInfo>(
                  future: _packageInfo,
                  builder: (context, snapshot) {
                    final version = snapshot.data?.version ?? '—';
                    return _Group(
                      label: 'About',
                      children: [
                        _SettingsTile(
                          icon: Icons.info_rounded,
                          color: primary,
                          title: 'App version',
                          trailing: _ValuePill(version),
                        ),
                        _SettingsTile(
                          icon: Icons.favorite_rounded,
                          color: const Color(0xFFEC4899),
                          title: 'About Daymark',
                          subtitle:
                              'Keep track of the things you want to live, and the ones you already have.',
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Brand card
// ─────────────────────────────────────────────────────────────────────────────

class _BrandCard extends StatelessWidget {
  const _BrandCard({required this.version});

  final String? version;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primary, _darken(primary, 0.5)],
        ),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.4),
            blurRadius: 34,
            offset: const Offset(0, 16),
            spreadRadius: -8,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Stack(
          children: [
            Positioned(
              right: -40,
              top: -50,
              child: _Orb(size: 170, alpha: 0.13),
            ),
            Positioned(
              left: -36,
              bottom: -64,
              child: _Orb(size: 150, alpha: 0.08),
            ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Row(
                children: [
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      color: Colors.white.withValues(alpha: 0.18),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Icon(
                      Icons.wb_twilight_rounded,
                      color: Colors.white,
                      size: 34,
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Daymark',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.6,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            version == null ? 'Version —' : 'Version $version',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
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

// ─────────────────────────────────────────────────────────────────────────────
// Grouped sections
// ─────────────────────────────────────────────────────────────────────────────

class _Group extends StatelessWidget {
  const _Group({required this.label, required this.children});

  final String label;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 6, bottom: AppSpacing.sm),
          child: Text(
            label.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              letterSpacing: 1.6,
              fontWeight: FontWeight.w800,
              color: scheme.onSurfaceVariant.withValues(alpha: 0.85),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: scheme.outlineVariant.withValues(alpha: 0.45),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: Column(
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  if (i > 0)
                    Divider(
                      height: 1,
                      indent: 72,
                      color: scheme.outlineVariant.withValues(alpha: 0.4),
                    ),
                  children[i],
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.color,
    required this.title,
    this.subtitle,
    this.trailing,
    this.showChevron = false,
    this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final bool showChevron;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap == null
            ? null
            : () {
                HapticFeedback.selectionClick();
                onTap!();
              },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [color, _darken(color, 0.25)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                      spreadRadius: -4,
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[const SizedBox(width: 8), trailing!],
              if (showChevron) ...[
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right_rounded,
                  color: scheme.onSurfaceVariant,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ValuePill extends StatelessWidget {
  const _ValuePill(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _SoonBadge extends StatelessWidget {
  const _SoonBadge();

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primary.withValues(alpha: 0.3)),
      ),
      child: Text(
        'SOON',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: primary,
          letterSpacing: 1.4,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Entrance animation
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
