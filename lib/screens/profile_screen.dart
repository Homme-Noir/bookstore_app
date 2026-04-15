import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../features/library/presentation/providers/library_provider.dart';
import '../providers/app_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/reading_stats_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _displayNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = context.read<AppProvider>().userId;
      if (uid != null) {
        context.read<ProfileProvider>().loadProfile(uid);
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Account'),
              Tab(text: 'Reading'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _AccountTab(
              emailController: _emailController,
              displayNameController: _displayNameController,
              formKey: _formKey,
            ),
            const _ReadingStatsTab(),
          ],
        ),
      ),
    );
  }
}

class _AccountTab extends StatelessWidget {
  const _AccountTab({
    required this.emailController,
    required this.displayNameController,
    required this.formKey,
  });

  final TextEditingController emailController;
  final TextEditingController displayNameController;
  final GlobalKey<FormState> formKey;

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, child) {
        if (emailController.text.isEmpty && profileProvider.email.isNotEmpty) {
          emailController.text = profileProvider.email;
        }
        if (displayNameController.text.isEmpty &&
            profileProvider.displayName.isNotEmpty) {
          displayNameController.text = profileProvider.displayName;
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 48,
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    child: Icon(
                      Icons.person_rounded,
                      size: 48,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: displayNameController,
                  decoration: const InputDecoration(
                    labelText: 'Display name',
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a display name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      final uid = context.read<AppProvider>().userId;
                      if (uid == null) return;
                      await profileProvider.updateDisplayName(
                        uid,
                        displayNameController.text,
                      );
                      await profileProvider.updateEmail(
                        uid,
                        emailController.text,
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Profile updated')),
                        );
                      }
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ReadingStatsTab extends StatelessWidget {
  const _ReadingStatsTab();

  @override
  Widget build(BuildContext context) {
    return Consumer2<LibraryProvider, ReadingStatsProvider>(
      builder: (context, library, stats, _) {
        final total = library.items.length;
        final reading = library.currentlyReading.length;
        final done = library.finished.length;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Library overview',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            _StatTile(
              icon: Icons.library_books_outlined,
              label: 'Books in library',
              value: '$total',
            ),
            _StatTile(
              icon: Icons.bookmark_outline_rounded,
              label: 'Currently reading',
              value: '$reading',
            ),
            _StatTile(
              icon: Icons.check_circle_outline_rounded,
              label: 'Finished',
              value: '$done',
            ),
            _StatTile(
              icon: Icons.timer_outlined,
              label: 'Time in reader (local)',
              value: stats.formattedTotalTime,
            ),
            _StatTile(
              icon: Icons.menu_book_outlined,
              label: 'Reader sessions',
              value: '${stats.readerOpens}',
            ),
            const SizedBox(height: 16),
            Text(
              'Reading time is tracked on this device only.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        );
      },
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(label),
        trailing: Text(
          value,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}
