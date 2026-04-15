import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../discovery/presentation/providers/discovery_provider.dart';
import '../library/presentation/providers/library_provider.dart';
import 'opds_client.dart';
import 'opds_models.dart';

/// Project Gutenberg OPDS — search and import EPUBs (public domain).
class OpdsCatalogScreen extends StatefulWidget {
  const OpdsCatalogScreen({super.key});

  @override
  State<OpdsCatalogScreen> createState() => _OpdsCatalogScreenState();
}

class _OpdsCatalogScreenState extends State<OpdsCatalogScreen> {
  final _searchController = TextEditingController(text: 'adventure');
  final _client = OpdsClient();
  OpdsPage? _page;
  String? _error;
  bool _loading = false;
  Uri? _next;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load({Uri? url, bool append = false}) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final uri = url ??
          Uri.parse('https://www.gutenberg.org/ebooks/search.opds/').replace(
                queryParameters: {'query': _searchController.text.trim()},
              );
      final page = await _client.fetchPage(uri);
      setState(() {
        if (append && _page != null) {
          _page = OpdsPage(
            entries: [..._page!.entries, ...page.entries],
            nextUrl: page.nextUrl,
          );
        } else {
          _page = page;
        }
        _next = page.nextUrl != null ? Uri.parse(page.nextUrl!) : null;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _import(OpdsEntry entry) async {
    if (!mounted) return;
    final discovery = context.read<DiscoveryProvider>();
    final library = context.read<LibraryProvider>();
    if (!discovery.policyAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Accept responsibility on the Discover tab first.'),
        ),
      );
      return;
    }

    var epub = entry.epubUrl;
    epub ??= await _client.resolveEpubUrl(
      Uri.parse(entry.detailOrAcquisitionUrl),
    );
    if (!mounted) return;
    if (epub == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No EPUB link found')),
      );
      return;
    }

    final msg = await discovery.downloadFromUrl(
      url: epub,
      title: entry.title,
      author: entry.subtitle.isNotEmpty ? entry.subtitle : 'Unknown',
      libraryProvider: library,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('OPDS catalog')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Search Project Gutenberg',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _load(),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _loading ? null : () => _load(),
                  child: const Icon(Icons.search_rounded),
                ),
              ],
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          Expanded(
            child: _loading && _page == null
                ? const Center(child: CircularProgressIndicator())
                : _page == null
                    ? const SizedBox.shrink()
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 24),
                        itemCount: _page!.entries.length + (_next != null ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _page!.entries.length) {
                            return Padding(
                              padding: const EdgeInsets.all(16),
                              child: OutlinedButton(
                                onPressed: _loading
                                    ? null
                                    : () => _load(url: _next, append: true),
                                child: const Text('Load more'),
                              ),
                            );
                          }
                          final e = _page!.entries[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            child: ListTile(
                              title: Text(e.title),
                              subtitle: Text(
                                e.subtitle.isEmpty ? 'Project Gutenberg' : e.subtitle,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: FilledButton.tonal(
                                onPressed: () => _import(e),
                                child: const Text('EPUB'),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
