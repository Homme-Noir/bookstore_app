import 'dart:math' as math;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/layout/app_shell_layout.dart';
import '../features/discovery/presentation/providers/discovery_provider.dart';
import '../features/library/presentation/providers/library_provider.dart';
import '../features/reader/presentation/providers/reader_provider.dart';
import '../features/sync/presentation/providers/sync_provider.dart';
import '../providers/app_provider.dart';
import '../providers/theme_controller.dart';
import '../services/environment_readiness_service.dart';

/// Hub for appearance, account, cloud sync, and backups (Readest-style “settings / more”).
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SyncProvider>().refreshJobs();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<SyncProvider>().runBackgroundRetry(
            libraryProvider: context.read<LibraryProvider>(),
            discoveryProvider: context.read<DiscoveryProvider>(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    const readiness = EnvironmentReadinessService();
    final compact = useCompactTopChrome(context);
    final settingsAppBar = compact
        ? SliverAppBar(
            pinned: true,
            title: const Text('Settings'),
            backgroundColor: Theme.of(context).colorScheme.surface,
            surfaceTintColor: Colors.transparent,
          )
        : SliverAppBar.large(
            title: const Text('Settings'),
            backgroundColor: Theme.of(context).colorScheme.surface,
            surfaceTintColor: Colors.transparent,
          );
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          settingsAppBar,
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              16,
              0,
              16,
              math.max(32, shellScrollBottomPadding(context)),
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  Consumer<ThemeController>(
                    builder: (context, theme, _) {
                      return _SectionCard(
                        title: 'Appearance',
                        child: SegmentedButton<ThemeMode>(
                          segments: const [
                            ButtonSegment(
                              value: ThemeMode.system,
                              label: Text('System'),
                              icon: Icon(Icons.brightness_auto_rounded),
                            ),
                            ButtonSegment(
                              value: ThemeMode.light,
                              label: Text('Light'),
                              icon: Icon(Icons.light_mode_rounded),
                            ),
                            ButtonSegment(
                              value: ThemeMode.dark,
                              label: Text('Dark'),
                              icon: Icon(Icons.dark_mode_rounded),
                            ),
                          ],
                          selected: {theme.themeMode},
                          onSelectionChanged: (s) {
                            theme.setThemeMode(s.first);
                          },
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _SectionCard(
                    title: 'Account',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.person_outline_rounded),
                          title: const Text('Profile & display name'),
                          subtitle: const Text('Reading preferences and identity'),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () =>
                              Navigator.of(context).pushNamed('/profile'),
                        ),
                        const Divider(height: 24),
                        FilledButton.tonalIcon(
                          onPressed: () => context.read<AppProvider>().signOut(),
                          icon: const Icon(Icons.logout_rounded),
                          label: const Text('Sign out'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _SectionCard(
                    title: 'Environment',
                    child: Text(
                      readiness.isSupabaseReady
                          ? 'Cloud sync is configured.'
                          : 'Running local-only (add SUPABASE_URL and SUPABASE_ANON_KEY to .env.local or use --dart-define).',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Consumer<SyncProvider>(
                    builder: (context, sync, _) {
                      return _SectionCard(
                        title: 'Cloud & backup',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Backend: ${sync.isConfigured ? "connected" : "not configured"} · '
                              '${sync.schemaStatus}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 12),
                            FilledButton.icon(
                              onPressed: sync.running
                                  ? null
                                  : () => sync.syncNow(
                                        libraryProvider:
                                            context.read<LibraryProvider>(),
                                        readerProvider:
                                            context.read<ReaderProvider>(),
                                        discoveryProvider: context
                                            .read<DiscoveryProvider>(),
                                      ),
                              icon: const Icon(Icons.sync_rounded),
                              label: Text(
                                sync.running ? 'Syncing…' : 'Sync now',
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: () async {
                                    final path = await sync.exportBackup();
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Backup: $path'),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.backup_rounded),
                                  label: const Text('Export'),
                                ),
                                OutlinedButton.icon(
                                  onPressed: () async {
                                    final selected =
                                        await FilePicker.platform.pickFiles(
                                      dialogTitle: 'Verify backup',
                                      type: FileType.custom,
                                      allowedExtensions: const ['json'],
                                    );
                                    final path = selected?.files.single.path;
                                    if (path == null) return;
                                    final verify = await sync.verifyBackup(path);
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          verify == null
                                              ? 'Integrity OK'
                                              : 'Failed: $verify',
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.verified_rounded),
                                  label: const Text('Verify'),
                                ),
                                OutlinedButton.icon(
                                  onPressed: () async {
                                    final selected =
                                        await FilePicker.platform.pickFiles(
                                      dialogTitle: 'Import backup',
                                      type: FileType.custom,
                                      allowedExtensions: const ['json'],
                                    );
                                    final path = selected?.files.single.path;
                                    if (path == null) return;
                                    await sync.importBackup(path);
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Backup imported'),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.restore_page_rounded),
                                  label: const Text('Import'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Retry queue',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: 8),
                            if (sync.jobs.isEmpty)
                              Text(
                                'No queued jobs.',
                                style: Theme.of(context).textTheme.bodySmall,
                              )
                            else
                              ...sync.jobs.map(
                                (job) => Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: ListTile(
                                    title: Text('${job.jobType} · ${job.status}'),
                                    subtitle: Text(
                                      job.lastError ?? '—',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.replay_rounded),
                                          onPressed: () =>
                                              sync.retryJobNow(job.id),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.close_rounded),
                                          onPressed: () =>
                                              sync.cancelJob(job.id),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
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

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
