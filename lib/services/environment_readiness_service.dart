import '../core/config/resolved_runtime_config.dart';

class EnvironmentReadinessService {
  const EnvironmentReadinessService();

  bool get hasSupabaseUrl =>
      ResolvedRuntimeConfig.instance.supabaseUrl.isNotEmpty;

  bool get hasSupabaseAnonKey =>
      ResolvedRuntimeConfig.instance.supabaseAnonKey.isNotEmpty;

  bool get hasDiscoveryApiBaseUrl =>
      ResolvedRuntimeConfig.instance.discoveryApiBaseUrlExplicit;

  bool get isSupabaseReady =>
      ResolvedRuntimeConfig.instance.isSupabaseConfigured;
}
