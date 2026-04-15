import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/layout/app_shell_layout.dart';
import '../../domain/models/library_item.dart';
import '../providers/library_provider.dart';
import '../../../reader/presentation/screens/reader_screen.dart';

enum _LibrarySort { recent, title, author }

class LibraryHubScreen extends StatefulWidget {
  const LibraryHubScreen({super.key});

  @override
  State<LibraryHubScreen> createState() => _LibraryHubScreenState();
}

class _LibraryHubScreenState extends State<LibraryHubScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  _LibrarySort _sort = _LibrarySort.recent;
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LibraryProvider>().loadItems();
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<LibraryItem> _filterAndSort(List<LibraryItem> items) {
    var list = List<LibraryItem>.from(items);
    final q = _query.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list
          .where(
            (i) =>
                i.title.toLowerCase().contains(q) ||
                i.author.toLowerCase().contains(q) ||
                i.format.toLowerCase().contains(q) ||
                i.tags.any((t) => t.toLowerCase().contains(q)),
          )
          .toList();
    }
    switch (_sort) {
      case _LibrarySort.recent:
        list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      case _LibrarySort.title:
        list.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
      case _LibrarySort.author:
        list.sort(
          (a, b) => a.author.toLowerCase().compareTo(b.author.toLowerCase()),
        );
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LibraryProvider>(
      builder: (context, library, _) {
        final compact = useCompactTopChrome(context);
        final sortAndImport = <Widget>[
          PopupMenuButton<_LibrarySort>(
            tooltip: 'Sort',
            onSelected: (v) => setState(() => _sort = v),
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: _LibrarySort.recent,
                child: Text('Recently updated'),
              ),
              PopupMenuItem(
                value: _LibrarySort.title,
                child: Text('Title A–Z'),
              ),
              PopupMenuItem(
                value: _LibrarySort.author,
                child: Text('Author A–Z'),
              ),
            ],
            icon: const Icon(Icons.sort_rounded),
          ),
          IconButton(
            tooltip: 'Import EPUB or PDF',
            onPressed: library.importBook,
            icon: const Icon(Icons.add_rounded),
          ),
        ];
        final tabBar = TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Reading'),
            Tab(text: 'Finished'),
            Tab(text: 'Tags'),
          ],
        );
        return Scaffold(
          body: NestedScrollView(
            headerSliverBuilder: (context, inner) => [
              if (compact)
                SliverAppBar(
                  pinned: true,
                  title: const Text('Library'),
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  surfaceTintColor: Colors.transparent,
                  actions: sortAndImport,
                  bottom: tabBar,
                )
              else
                SliverAppBar.large(
                  title: const Text('Library'),
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  surfaceTintColor: Colors.transparent,
                  actions: sortAndImport,
                  bottom: tabBar,
                ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                sliver: SliverToBoxAdapter(
                  child: SearchBar(
                    controller: _searchController,
                    hintText: 'Search your library',
                    leading: const Icon(Icons.search_rounded),
                    trailing: [
                      if (_query.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () {
                            _searchDebounce?.cancel();
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                        ),
                    ],
                    onChanged: (v) {
                      _searchDebounce?.cancel();
                      _searchDebounce = Timer(
                        const Duration(milliseconds: 220),
                        () {
                          if (mounted) setState(() => _query = v);
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
            body: TabBarView(
              controller: _tabController,
              children: [
                _LibraryGrid(
                  items: _filterAndSort(library.items),
                  onOpen: _openReader,
                  onRefresh: library.loadItems,
                ),
                _LibraryGrid(
                  items: _filterAndSort(library.currentlyReading),
                  onOpen: _openReader,
                  onRefresh: library.loadItems,
                ),
                _LibraryGrid(
                  items: _filterAndSort(library.finished),
                  onOpen: _openReader,
                  onRefresh: library.loadItems,
                ),
                _CollectionsOverview(items: library.items),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openReader(LibraryItem item) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ReaderScreen(item: item),
      ),
    );
  }
}

class _LibraryGrid extends StatelessWidget {
  const _LibraryGrid({
    required this.items,
    required this.onOpen,
    required this.onRefresh,
  });

  final List<LibraryItem> items;
  final void Function(LibraryItem) onOpen;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.menu_book_rounded,
                size: 64,
                color: Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(height: 16),
              Text(
                'Nothing here yet',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Import EPUB or PDF from the + button, or add books from Discover.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final cross = (w / 176).floor().clamp(2, 8);
          final bottom = shellScrollBottomPadding(context);
          return GridView.builder(
            cacheExtent: 280,
            padding: EdgeInsets.fromLTRB(16, 8, 16, bottom),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cross,
              childAspectRatio: 0.72,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return _BookTile(item: item, onTap: () => onOpen(item));
            },
          );
        },
      ),
    );
  }
}

class _BookTile extends StatelessWidget {
  const _BookTile({required this.item, required this.onTap});

  final LibraryItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final t = item.title.trim();
    final initials =
        t.isEmpty ? '?' : t.substring(0, 1).toUpperCase();

    return Material(
      color: scheme.surfaceContainerHighest.withValues(alpha: 0.35),
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      scheme.primaryContainer,
                      scheme.secondaryContainer,
                    ],
                  ),
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: scheme.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 4),
              child: Text(
                item.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
              child: Text(
                item.author,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              ),
            ),
            LinearProgressIndicator(
              value: item.progress.clamp(0, 1),
              minHeight: 3,
              borderRadius: BorderRadius.circular(2),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 6, 10, 10),
              child: Row(
                children: [
                  Text(
                    item.format.toUpperCase(),
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  const Spacer(),
                  Text(
                    '${(item.progress * 100).round()}%',
                    style: Theme.of(context).textTheme.labelSmall,
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

class _CollectionsOverview extends StatelessWidget {
  const _CollectionsOverview({required this.items});

  final List<LibraryItem> items;

  @override
  Widget build(BuildContext context) {
    final collections = <String, int>{};
    for (final item in items) {
      final bucket = item.tags.isEmpty ? 'Unsorted' : item.tags.first;
      collections[bucket] = (collections[bucket] ?? 0) + 1;
    }

    if (collections.isEmpty) {
      return Center(
        child: Text(
          'Tag books in a future update — for now, everything lives in All.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: collections.entries
          .map(
            (e) => Card(
              child: ListTile(
                leading: const Icon(Icons.label_outline_rounded),
                title: Text(e.key),
                trailing: Text('${e.value}'),
              ),
            ),
          )
          .toList(),
    );
  }
}
