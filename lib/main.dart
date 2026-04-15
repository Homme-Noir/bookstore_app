/// Personal Library — app entrypoint, dependency wiring, and routes.
///
/// Initializes Supabase when `SUPABASE_URL` and `SUPABASE_ANON_KEY` are set
/// via `--dart-define`, `--dart-define-from-file`, or project `.env` /
/// `.env.local` (read on IO from the process working directory). Otherwise
/// the app runs with mock auth and local-only data paths. Discovery can use
/// the remote FastAPI service (`DISCOVERY_API_BASE_URL`) or in-process Open
/// Library + optional Anna adapters when the base URL is empty.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/config/load_env.dart';
import 'core/config/resolved_runtime_config.dart';
import 'core/security/secure_kv_store.dart';
import 'core/storage/backup_service.dart';
import 'core/storage/local_database.dart';
import 'features/discovery/data/download_ingest_service.dart';
import 'features/discovery/data/anna_archive_source_adapter.dart';
import 'features/discovery/data/discovery_api_source_adapter.dart';
import 'features/discovery/data/open_library_source_adapter.dart';
import 'features/discovery/presentation/providers/discovery_provider.dart';
import 'features/library/data/local_library_repository.dart';
import 'features/library/presentation/providers/library_provider.dart';
import 'features/reader/data/local_reader_repository.dart';
import 'features/reader/presentation/providers/reader_provider.dart';
import 'features/sync/data/sync_retry_repository.dart';
import 'features/sync/presentation/providers/sync_provider.dart';
import 'providers/app_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/reading_stats_provider.dart';
import 'providers/theme_controller.dart';
import 'screens/home_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/library_shell_screen.dart';
import 'services/auth_service.dart';
import 'services/open_library_service.dart';
import 'services/supabase_sync_service.dart';
import 'services/sync_state_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final fileEnv = await loadProjectEnvFiles();
  ResolvedRuntimeConfig.instance =
      ResolvedRuntimeConfig.mergeFromFiles(fileEnv);
  final cfg = ResolvedRuntimeConfig.instance;

  if (cfg.isSupabaseConfigured) {
    await Supabase.initialize(
      url: cfg.supabaseUrl,
      anonKey: cfg.supabaseAnonKey,
    );
  }

  final localDatabase = await LocalDatabase.create();
  runApp(MyApp(localDatabase: localDatabase));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.localDatabase});

  final LocalDatabase localDatabase;

  @override
  Widget build(BuildContext context) {
    const secureStore = SecureKvStore();
    final authService = AuthService(secureStore: secureStore);
    final openLibraryService = OpenLibraryService();
    final ingestService = DownloadIngestService();
    const syncService = SupabaseSyncService();
    final syncStateService = SyncStateService(secureStore: secureStore);
    final retryRepository = SyncRetryRepository(database: localDatabase);
    final localRepository = LocalLibraryRepository(database: localDatabase);
    final localReaderRepository =
        LocalReaderRepository(database: localDatabase);
    final backupService = BackupService(database: localDatabase);

    final cfg = ResolvedRuntimeConfig.instance;
    final discoveryApiBaseUrl = cfg.discoveryApiBaseUrl;
    final includeAnnaDiscovery = cfg.includeAnnaDiscovery;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeController()),
        ChangeNotifierProvider(create: (_) => ReadingStatsProvider()),
        ChangeNotifierProvider(
          create: (_) => AppProvider(
            authService: authService,
          ),
        ),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(
          create: (_) => LibraryProvider(repository: localRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => ReaderProvider(
            repository: localReaderRepository,
          )..load(),
        ),
        ChangeNotifierProvider(
          create: (_) => DiscoveryProvider(
            adapters: discoveryApiBaseUrl.trim().isNotEmpty
                ? [
                    DiscoveryApiSourceAdapter(
                      baseUrl: discoveryApiBaseUrl,
                      includeAnna: includeAnnaDiscovery,
                    ),
                  ]
                : [
                    OpenLibrarySourceAdapter(service: openLibraryService),
                    AnnaArchiveSourceAdapter(
                      baseUrl: null,
                      includeAnna: includeAnnaDiscovery,
                    ),
                  ],
            ingestService: ingestService,
            retryRepository: retryRepository,
            discoveryApiBaseUrl: discoveryApiBaseUrl.trim().isNotEmpty
                ? discoveryApiBaseUrl.trim()
                : null,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => SyncProvider(
            service: syncService,
            retryRepository: retryRepository,
            stateService: syncStateService,
            backupService: backupService,
          ),
        ),
      ],
      child: Consumer<ThemeController>(
        builder: (context, themeController, _) {
          return MaterialApp(
            title: 'Personal Library',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeController.themeMode,
            home: const HomeScreen(),
            debugShowCheckedModeBanner: false,
            routes: {
              '/register_screen': (context) => const RegisterScreen(),
              '/forgot_password_screen': (context) =>
                  const ForgotPasswordScreen(),
              '/login': (context) => const LoginScreen(),
              '/app': (context) => const LibraryShellScreen(),
              '/home_screen': (context) => const HomeScreen(),
              '/profile': (context) => const ProfileScreen(),
            },
          );
        },
      ),
    );
  }
}
