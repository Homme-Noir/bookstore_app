/// Build-time `--dart-define` values merged with optional `.env` / `.env.local`
/// files (desktop / CLI). Set [instance] in [main] before [runApp].
class ResolvedRuntimeConfig {
  ResolvedRuntimeConfig({
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    required this.discoveryApiBaseUrl,
    required this.includeAnnaDiscovery,
    required this.discoveryApiBaseUrlExplicit,
  });

  final String supabaseUrl;
  final String supabaseAnonKey;
  final String discoveryApiBaseUrl;
  final bool includeAnnaDiscovery;

  /// True when `DISCOVERY_API_BASE_URL` was set via define or env file (not only default).
  final bool discoveryApiBaseUrlExplicit;

  bool get isSupabaseConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  /// Assigned in [main] before [runApp]; do not read earlier.
  static late ResolvedRuntimeConfig instance;

  static const _defaultDiscoveryUrl = 'https://bookstore-discovery.fly.dev';

  /// Compile-time defines override file values.
  static ResolvedRuntimeConfig mergeFromFiles(Map<String, String> fileEnv) {
    const cUrl = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
    const cKey = String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');
    const cDisc = String.fromEnvironment(
      'DISCOVERY_API_BASE_URL',
      defaultValue: '',
    );
    const cAnna = bool.fromEnvironment(
      'DISCOVERY_INCLUDE_ANNA',
      defaultValue: false,
    );

    String pick(String compile, String fileKey) {
      final v = compile.isNotEmpty ? compile : (fileEnv[fileKey] ?? '');
      return v.trim();
    }

    final url = pick(cUrl, 'SUPABASE_URL');
    final anon = pick(cKey, 'SUPABASE_ANON_KEY');

    final fileDisc = (fileEnv['DISCOVERY_API_BASE_URL'] ?? '').trim();
    final explicitDisc = cDisc.isNotEmpty || fileDisc.isNotEmpty;
    var disc = cDisc.isNotEmpty ? cDisc.trim() : fileDisc;
    if (disc.isEmpty) disc = _defaultDiscoveryUrl;

    final annaStr = (fileEnv['DISCOVERY_INCLUDE_ANNA'] ?? '').toLowerCase();
    final anna = cAnna ||
        annaStr == 'true' ||
        annaStr == '1' ||
        annaStr == 'yes';

    return ResolvedRuntimeConfig(
      supabaseUrl: url,
      supabaseAnonKey: anon,
      discoveryApiBaseUrl: disc,
      includeAnnaDiscovery: anna,
      discoveryApiBaseUrlExplicit: explicitDisc,
    );
  }
}
