import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../core/constants/app_spacing.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          _SectionHeader('Appearance'),
          const ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Theme'),
            subtitle: Text('Follows your system setting'),
            trailing: Icon(Icons.chevron_right),
          ),
          const SizedBox(height: AppSpacing.lg),
          _SectionHeader('Data'),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.file_upload_outlined),
            title: const Text('Export data'),
            onTap: () {},
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.file_download_outlined),
            title: const Text('Import data'),
            onTap: () {},
          ),
          const SizedBox(height: AppSpacing.lg),
          _SectionHeader('Cloud Sync'),
          const ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.cloud_outlined),
            title: Text('Cloud sync'),
            subtitle: Text('Coming soon'),
          ),
          const SizedBox(height: AppSpacing.lg),
          _SectionHeader('About'),
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              final version = snapshot.data?.version ?? '—';
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('App version'),
                trailing: Text(version),
              );
            },
          ),
          const ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('About Daymark'),
            subtitle: Text('Keep track of the things you want to live, and the ones you already have.'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(label, style: Theme.of(context).textTheme.labelSmall),
    );
  }
}
