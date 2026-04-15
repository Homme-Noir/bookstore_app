import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/config/resolved_runtime_config.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onComplete});

  final VoidCallback onComplete;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  bool _accepted = false;

  Future<void> _finish() async {
    if (!_accepted) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final supabaseReady =
        ResolvedRuntimeConfig.instance.isSupabaseConfigured;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Icon(Icons.auto_stories_rounded, size: 80, color: scheme.primary),
              const SizedBox(height: 24),
              Text(
                'Personal Library',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Import EPUB and PDF, read with a calm layout, and sync when you connect Supabase.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Responsibility',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'You are responsible for copyright and licensing of anything you import or download.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SwitchListTile.adaptive(
                value: _accepted,
                onChanged: (v) => setState(() => _accepted = v),
                title: const Text('I understand'),
                subtitle: const Text('I will comply with applicable laws.'),
              ),
              ExpansionTile(
                title: Text(
                  'Technical status',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                children: [
                  ListTile(
                    dense: true,
                    title: Text(
                      supabaseReady
                          ? 'Supabase compile-time keys present'
                          : 'Supabase keys not embedded (local-only)',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              FilledButton(
                onPressed: _accepted ? _finish : null,
                child: const Text('Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
