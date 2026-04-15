import 'dart:async';
import 'dart:io';

import 'package:epub_view/epub_view.dart' as epub;
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:pdfx/pdfx.dart' as pdfx;
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart' show ShareParams, SharePlus;
import 'package:url_launcher/url_launcher.dart';

import '../../../../providers/reading_stats_provider.dart';
import '../../../library/domain/models/library_item.dart';
import '../../../library/presentation/providers/library_provider.dart';
import '../../data/epub_text_extract.dart';
import '../../domain/bookmark_marker.dart';
import '../../domain/models/reader_engine_contract.dart';
import '../providers/reader_provider.dart';

class ReaderScreen extends StatefulWidget {
  const ReaderScreen({super.key, required this.item});

  final LibraryItem item;

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen>
    with WidgetsBindingObserver {
  late double _progress;
  final TextEditingController _noteController = TextEditingController();
  pdfx.PdfControllerPinch? _pdfController;
  epub.EpubController? _epubController;
  int _pdfPages = 1;
  bool _loading = true;
  String? _loadError;
  Timer? _statsTimer;
  DateTime _statsLastBeat = DateTime.now();
  FlutterTts? _tts;
  bool _ttsSpeaking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final reader = context.read<ReaderProvider>();
    _progress =
        reader.progressFor(widget.item.id)?.percentage ?? widget.item.progress;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ReadingStatsProvider>().registerReaderOpen();
    });
    _statsLastBeat = DateTime.now();
    _statsTimer = Timer.periodic(const Duration(seconds: 20), (_) {
      _heartbeatStats();
    });
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      if (_isPdf) {
        final doc = await pdfx.PdfDocument.openFile(widget.item.filePath);
        _pdfPages = doc.pagesCount;
        final initial =
            ((_progress * _pdfPages).round()).clamp(1, _pdfPages);
        _pdfController = pdfx.PdfControllerPinch(
          document: Future.value(doc),
          initialPage: initial,
        );
      } else if (_isEpub) {
        _epubController = epub.EpubController(
          document: epub.EpubDocument.openFile(File(widget.item.filePath)),
        );
      }
    } catch (e) {
      _loadError = e.toString();
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  void dispose() {
    _heartbeatStats();
    _statsTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _tts?.stop();
    _pdfController?.dispose();
    _epubController?.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _heartbeatStats();
    }
  }

  void _heartbeatStats() {
    if (!mounted) return;
    final now = DateTime.now();
    final secs = now.difference(_statsLastBeat).inSeconds;
    if (secs > 0) {
      context.read<ReadingStatsProvider>().addElapsedSeconds(secs);
    }
    _statsLastBeat = now;
  }

  Future<void> _quickBookmark() async {
    await context.read<ReaderProvider>().addBookmarkAt(
          itemId: widget.item.id,
          position: (_progress * 1000).round(),
        );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bookmark added')),
      );
    }
  }

  Future<void> _exportAnnotations() async {
    final text = context
        .read<ReaderProvider>()
        .exportAnnotationsAsText(widget.item);
    await SharePlus.instance.share(
      ShareParams(text: text, subject: widget.item.title),
    );
  }

  Future<void> _readAloud() async {
    _tts ??= FlutterTts();
    await _tts!.setLanguage('en-US');
    if (_ttsSpeaking) {
      await _tts!.stop();
      if (mounted) setState(() => _ttsSpeaking = false);
      return;
    }
    var text = _isEpub
        ? await extractEpubPlainTextPreview(widget.item.filePath)
        : null;
    text ??=
        '${widget.item.title}. By ${widget.item.author}. ';
    if (_isPdf && _pdfController != null) {
      final p = _pdfController!.pageListenable.value;
      text = '$text Page $p of $_pdfPages.';
    }
    _tts!.setCompletionHandler(() {
      if (mounted) setState(() => _ttsSpeaking = false);
    });
    if (mounted) setState(() => _ttsSpeaking = true);
    await _tts!.speak(text);
  }

  bool get _isPdf => widget.item.format.toLowerCase().contains('pdf');
  bool get _isEpub => widget.item.format.toLowerCase().contains('epub');

  Future<void> _saveProgress() async {
    final reader = context.read<ReaderProvider>();
    final library = context.read<LibraryProvider>();
    final positionState = ReaderEnginePosition(
      itemId: widget.item.id,
      progress: _progress,
      location: (_progress * 1000).round(),
      engine: _isPdf ? 'pdf-native' : (_isEpub ? 'epub-webview' : 'fallback'),
    );
    await reader.saveProgress(
      itemId: positionState.itemId,
      percentage: positionState.progress,
      position: positionState.location,
    );
    await library.updateProgress(positionState.itemId, positionState.progress);
  }

  Future<void> _addNote() async {
    final text = _noteController.text.trim();
    if (text.isEmpty) return;
    await context.read<ReaderProvider>().addAnnotation(
          itemId: widget.item.id,
          note: text,
          start: (_progress * 1000).round(),
          end: (_progress * 1000).round() + 1,
        );
    _noteController.clear();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note saved')),
      );
    }
  }

  Future<void> _openWikipedia() async {
    final q = Uri.encodeComponent(
      '${widget.item.title} ${widget.item.author}'.trim(),
    );
    final uri = Uri.parse(
      'https://en.wikipedia.org/wiki/Special:Search?search=$q',
    );
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) &&
        mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open browser')),
      );
    }
  }

  void _showReaderTools() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Consumer<ReaderProvider>(
              builder: (context, r, _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Reading layout',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    SegmentedButton<ReaderPaperTheme>(
                      segments: const [
                        ButtonSegment(
                          value: ReaderPaperTheme.light,
                          label: Text('Day'),
                          icon: Icon(Icons.wb_sunny_outlined),
                        ),
                        ButtonSegment(
                          value: ReaderPaperTheme.sepia,
                          label: Text('Sepia'),
                          icon: Icon(Icons.auto_awesome_outlined),
                        ),
                        ButtonSegment(
                          value: ReaderPaperTheme.dark,
                          label: Text('Night'),
                          icon: Icon(Icons.nightlight_round),
                        ),
                      ],
                      selected: {r.paperTheme},
                      onSelectionChanged: (s) {
                        r.setReaderPreferences(paperTheme: s.first);
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text(
                          'Text size',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Expanded(
                          child: Slider(
                            value: r.fontScale,
                            min: 0.8,
                            max: 1.4,
                            divisions: 12,
                            label: r.fontScale.toStringAsFixed(2),
                            onChanged: (v) {
                              r.setReaderPreferences(fontScale: v);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Manual progress',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    Slider(
                      value: _progress,
                      onChanged: (v) => setState(() => _progress = v),
                      onChangeEnd: (_) => _saveProgress(),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _noteController,
                      decoration: const InputDecoration(
                        labelText: 'Quick note at this position',
                        border: OutlineInputBorder(),
                      ),
                      minLines: 1,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 8),
                    FilledButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _addNote();
                      },
                      icon: const Icon(Icons.note_add_outlined),
                      label: const Text('Save note'),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Annotations',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    if (r.annotationsFor(widget.item.id).isEmpty)
                      Text(
                        'None yet.',
                        style: Theme.of(context).textTheme.bodySmall,
                      )
                    else
                      ...r.annotationsFor(widget.item.id).map(
                        (entry) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            isBookmarkNote(entry.note)
                                ? Icons.bookmark_rounded
                                : Icons.sticky_note_2_outlined,
                          ),
                          title: Text(
                            isBookmarkNote(entry.note)
                                ? 'Bookmark'
                                : entry.note,
                          ),
                          subtitle: Text('${entry.createdAt}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () async {
                              await r.deleteAnnotation(
                                itemId: widget.item.id,
                                annotationId: entry.annotationId,
                              );
                              if (context.mounted) {
                                setState(() {});
                              }
                            },
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ReaderProvider>(
      builder: (context, reader, _) {
        return Scaffold(
          backgroundColor: reader.readerBackgroundColor,
          appBar: AppBar(
            backgroundColor: reader.readerBackgroundColor,
            foregroundColor: reader.readerForegroundColor,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  widget.item.author,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: reader.readerForegroundColor.withValues(
                          alpha: 0.75,
                        ),
                      ),
                ),
              ],
            ),
            actions: [
              IconButton(
                tooltip: 'Look up on Wikipedia',
                onPressed: _openWikipedia,
                icon: const Icon(Icons.travel_explore_rounded),
              ),
              IconButton(
                tooltip: _ttsSpeaking ? 'Stop reading aloud' : 'Read aloud',
                onPressed: _readAloud,
                icon: Icon(
                  _ttsSpeaking ? Icons.stop_rounded : Icons.record_voice_over_rounded,
                ),
              ),
              IconButton(
                tooltip: 'Add bookmark',
                onPressed: _quickBookmark,
                icon: const Icon(Icons.bookmark_add_outlined),
              ),
              IconButton(
                tooltip: 'Export notes',
                onPressed: _exportAnnotations,
                icon: const Icon(Icons.ios_share_rounded),
              ),
              IconButton(
                tooltip: 'Save progress',
                onPressed: _saveProgress,
                icon: const Icon(Icons.save_rounded),
              ),
              IconButton(
                tooltip: 'Reader tools',
                onPressed: _showReaderTools,
                icon: const Icon(Icons.tune_rounded),
              ),
            ],
          ),
          body: _loading
              ? const Center(child: CircularProgressIndicator())
              : _loadError != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'Could not open this file.\n$_loadError',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        Expanded(child: _readerSurface(reader)),
                        _bottomBar(reader),
                      ],
                    ),
        );
      },
    );
  }

  Widget _bottomBar(ReaderProvider reader) {
    return Material(
      elevation: 8,
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isPdf && _pdfController != null)
                      ValueListenableBuilder<int>(
                        valueListenable: _pdfController!.pageListenable,
                        builder: (context, page, _) {
                          return Text(
                            'Page $page / $_pdfPages',
                            style: Theme.of(context).textTheme.labelLarge,
                          );
                        },
                      )
                    else ...[
                      Text(
                        'Progress ${(_progress * 100).toStringAsFixed(0)}%',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      LinearProgressIndicator(value: _progress.clamp(0, 1)),
                    ],
                  ],
                ),
              ),
              IconButton(
                onPressed: _showReaderTools,
                icon: const Icon(Icons.more_horiz_rounded),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _readerSurface(ReaderProvider reader) {
    if (_isPdf && _pdfController != null) {
      return pdfx.PdfViewPinch(
        controller: _pdfController!,
        onPageChanged: (page) {
          setState(() {
            _progress = _pdfPages <= 0 ? 0 : (page / _pdfPages).clamp(0, 1);
          });
          _saveProgress();
        },
      );
    }

    if (_isEpub && _epubController != null) {
      return ColoredBox(
        color: reader.readerBackgroundColor,
        child: epub.EpubView(
          controller: _epubController!,
          builders: epub.EpubViewBuilders<epub.DefaultBuilderOptions>(
            options: epub.DefaultBuilderOptions(
              textStyle: TextStyle(
                fontSize: 16 * reader.fontScale,
                color: reader.readerForegroundColor,
                height: 1.45,
              ),
              chapterPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
          onChapterChanged: (_) {},
        ),
      );
    }

    return Center(
      child: Text(
        'This format is not supported in the reader.',
        style: TextStyle(color: reader.readerForegroundColor),
      ),
    );
  }
}
