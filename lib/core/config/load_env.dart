import 'load_env_io.dart' if (dart.library.html) 'load_env_stub.dart' as impl;

Future<Map<String, String>> loadProjectEnvFiles() =>
    impl.loadProjectEnvFiles();
