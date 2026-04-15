import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/layout/app_shell_layout.dart';
import '../../../library/presentation/providers/library_provider.dart';
import '../../../opds/opds_catalog_screen.dart';
import '../../domain/models/discovery_result.dart';
import '../providers/discovery_provider.dart';

class DiscoveryScreen extends StatefulWidget {
  const DiscoveryScreen({super.key});

  @override
  State<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends State<DiscoveryScreen> {
  final TextEditingController _queryController = TextEditingController();
  final TextEditingController _directUrlController = TextEditingController();
  final TextEditingController _titleController = TextEditingController(
    text: 'Downloaded Book',
  );
  final TextEditingController _authorController = TextEditingController(
    text: 'Unknown Author',
  );
  Timer? _searchDebounce;

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _queryController.dispose();
    _directUrlController.dispose();
    _titleController.dispose();
    _authorController.dispose();
    super.dispose();
  }

  Future<void> _openExternal(String? url) async {
    if (url == null || url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open link')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Consumer<DiscoveryProvider>(
      builder: (context, discovery, _) {
        final compact = useCompactTopChrome(context);
        final discoverAppBar = compact
            ? SliverAppBar(
                pinned: true,
                title: const Text('Discover'),
                backgroundColor: colorScheme.surface,
                surfaceTintColor: Colors.transparent,
              )
            : SliverAppBar.large(
                title: const Text('Discover'),
                backgroundColor: colorScheme.surface,
                surfaceTintColor: Colors.transparent,
              );
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              discoverAppBar,
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Search catalogs and import books you have the rights to use.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodySmall?.color,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Add to your library',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '1. Turn on “I accept responsibility” below (required for downloads).\n'
                        '2. Search, then use Import / Find file on a result — or paste a file URL — or browse OPDS.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const OpdsCatalogScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.rss_feed_rounded),
                        label: const Text('OPDS — Project Gutenberg'),
                      ),
                      const SizedBox(height: 16),
                      SearchBar(
                        controller: _queryController,
                        hintText: 'Title, author, or topic',
                        leading: const Icon(Icons.search_rounded),
                        trailing: [
                          IconButton(
                            tooltip: 'Search',
                            onPressed: () {
                              _searchDebounce?.cancel();
                              discovery.search(_queryController.text);
                            },
                            icon: const Icon(Icons.arrow_forward_rounded),
                          ),
                        ],
                        onChanged: (value) {
                          _searchDebounce?.cancel();
                          final t = value.trim();
                          if (t.isNotEmpty && t.length < 2) return;
                          _searchDebounce = Timer(
                            const Duration(milliseconds: 420),
                            () => discovery.search(value),
                          );
                        },
                        onSubmitted: (value) {
                          _searchDebounce?.cancel();
                          discovery.search(value);
                        },
                      ),
                      if (discovery.error != null) ...[
                        const SizedBox(height: 12),
                        Material(
                          color: colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline_rounded,
                                  color: colorScheme.onErrorContainer,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    discovery.error!,
                                    style: TextStyle(
                                      color: colorScheme.onErrorContainer,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Card(
                        margin: EdgeInsets.zero,
                        child: SwitchListTile.adaptive(
                          value: discovery.policyAccepted,
                          onChanged: discovery.setPolicyAccepted,
                          title: const Text('I accept responsibility'),
                          subtitle: const Text(
                            'You must comply with copyright and licensing for any import.',
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ExpansionTile(
                        initiallyExpanded: true,
                        tilePadding: EdgeInsets.zero,
                        title: Text(
                          'Import from URL',
                          style: theme.textTheme.titleSmall,
                        ),
                        subtitle: Text(
                          'Direct .epub / .pdf URL, or a magnet link',
                          style: theme.textTheme.bodySmall,
                        ),
                        childrenPadding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
                        children: [
                          TextField(
                            controller: _directUrlController,
                            decoration: const InputDecoration(
                              labelText: 'File URL or magnet',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _titleController,
                            decoration: const InputDecoration(
                              labelText: 'Title',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _authorController,
                            decoration: const InputDecoration(
                              labelText: 'Author',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Tooltip(
                              message: discovery.policyAccepted
                                  ? 'Download the file and add it to your library'
                                  : 'Turn on “I accept responsibility” above first',
                              child: FilledButton.icon(
                                onPressed: discovery.policyAccepted
                                    ? () async {
                                        final messenger =
                                            ScaffoldMessenger.of(context);
                                        final libraryProvider =
                                            context.read<LibraryProvider>();
                                        final message =
                                            await discovery.downloadFromUrl(
                                          url: _directUrlController.text
                                              .trim(),
                                          title: _titleController.text.trim(),
                                          author: _authorController.text.trim(),
                                          libraryProvider: libraryProvider,
                                        );
                                        if (!mounted) return;
                                        messenger.showSnackBar(
                                          SnackBar(content: Text(message)),
                                        );
                                      }
                                    : () {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Turn on “I accept responsibility” above to download and import.',
                                            ),
                                          ),
                                        );
                                      },
                                icon: const Icon(Icons.download_rounded),
                                label: const Text('Download and import'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (discovery.isLoading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (discovery.results.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                    child: Column(
                      children: [
                        Icon(
                          Icons.menu_book_rounded,
                          size: 48,
                          color: theme.hintColor,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          discovery.query.isEmpty
                              ? 'No catalog results yet'
                              : 'No matches for this query',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          discovery.query.isEmpty
                              ? 'Enter a search above, or use “Import from URL” or OPDS. '
                                  'After you search, each row can offer Import, Find file, or Catalog.'
                              : 'Try different keywords, or tap Find file on a hit to look for a downloadable copy.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.textTheme.bodySmall?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    0,
                    16,
                    shellScrollBottomPadding(context),
                  ),
                  sliver: SliverList.separated(
                    itemCount: discovery.results.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = discovery.results[index];
                      return RepaintBoundary(
                        child: _DiscoveryHitCard(
                        item: item,
                        policyAccepted: discovery.policyAccepted,
                        onImport: () async {
                          final messenger = ScaffoldMessenger.of(context);
                          final libraryProvider =
                              context.read<LibraryProvider>();
                          final message = await discovery.downloadAndImport(
                            result: item,
                            libraryProvider: libraryProvider,
                          );
                          if (!mounted) return;
                          messenger.showSnackBar(
                            SnackBar(content: Text(message)),
                          );
                        },
                        onFindFile: () => discovery.searchForDownloadableCopy(
                          title: item.title,
                          author: item.author,
                        ),
                        onOpenCatalog: item.catalogUrl != null
                            ? () => _openExternal(item.catalogUrl)
                            : null,
                      ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _DiscoveryHitCard extends StatelessWidget {
  const _DiscoveryHitCard({
    required this.item,
    required this.policyAccepted,
    required this.onImport,
    required this.onFindFile,
    this.onOpenCatalog,
  });

  final DiscoveryResult item;
  final bool policyAccepted;
  final VoidCallback onImport;
  final VoidCallback onFindFile;
  final VoidCallback? onOpenCatalog;

  static bool _showAcquire(DiscoveryResult item) =>
      item.hasDirectHttpDownload ||
      item.hasMagnet ||
      item.source == 'AnnaArchive';

  static String _acquireLabel(DiscoveryResult item) {
    if (item.hasDirectHttpDownload) return 'Import';
    if (item.hasMagnet) return 'Torrent';
    if (item.source == 'AnnaArchive') return 'Get file';
    return 'Find file';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cover = item.coverUrl;

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onOpenCatalog,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 56,
                  height: 84,
                  child: cover != null && cover.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: cover,
                          fit: BoxFit.cover,
                          memCacheWidth: 112,
                          fadeInDuration: Duration.zero,
                          placeholder: (_, __) => ColoredBox(
                            color: theme.colorScheme.surfaceContainerHigh,
                            child: Icon(
                              Icons.book_rounded,
                              color: theme.hintColor,
                            ),
                          ),
                          errorWidget: (_, __, ___) => ColoredBox(
                            color: theme.colorScheme.surfaceContainerHigh,
                            child: Icon(
                              Icons.book_rounded,
                              color: theme.hintColor,
                            ),
                          ),
                        )
                      : ColoredBox(
                          color: theme.colorScheme.surfaceContainerHigh,
                          child: Icon(
                            Icons.book_rounded,
                            color: theme.hintColor,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.author,
                      style: theme.textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _InfoChip(
                          label: item.source,
                          icon: Icons.public_rounded,
                        ),
                        _InfoChip(
                          label: item.format,
                          icon: item.hasDirectHttpDownload
                              ? Icons.file_present_rounded
                              : item.hasMagnet
                                  ? Icons.link_rounded
                                  : Icons.info_outline_rounded,
                        ),
                        if (item.formatVerified)
                          _InfoChip(
                            label: 'Verified',
                            icon: Icons.verified_rounded,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (_showAcquire(item))
                    Tooltip(
                      message: policyAccepted
                          ? 'Add this title to your library'
                          : 'Turn on “I accept responsibility” at the top of Discover',
                      child: FilledButton(
                        onPressed: policyAccepted
                            ? onImport
                            : () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Turn on “I accept responsibility” at the top of Discover to import or download.',
                                    ),
                                  ),
                                );
                              },
                        child: Text(_acquireLabel(item)),
                      ),
                    )
                  else
                    OutlinedButton(
                      onPressed: onFindFile,
                      child: const Text('Find file'),
                    ),
                  if (onOpenCatalog != null) ...[
                    const SizedBox(height: 6),
                    TextButton(
                      onPressed: onOpenCatalog,
                      child: const Text('Catalog'),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}
