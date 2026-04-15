import 'dart:io';

import 'package:path/path.dart' as p;

/// Loads [name] from [Directory.current] (project root when run via `flutter run`).
Future<Map<String, String>> loadProjectEnvFiles() async {
  final root = Directory.current.path;
  final merged = <String, String>{};
  for (final name in ['.env', '.env.local']) {
    final f = File(p.join(root, name));
    if (await f.exists()) {
      final text = await f.readAsString();
      merged.addAll(_parseEnv(text));
    }
  }
  return merged;
}

Map<String, String> _parseEnv(String content) {
  final out = <String, String>{};
  for (final raw in content.split('\n')) {
    var line = raw.trimRight();
    if (line.endsWith('\r')) line = line.substring(0, line.length - 1);
    line = line.trim();
    if (line.isEmpty || line.startsWith('#')) continue;
    final eq = line.indexOf('=');
    if (eq <= 0) continue;
    var key = line.substring(0, eq).trim();
    if (key.startsWith('export ')) {
      key = key.substring(7).trim();
    }
    if (key.isEmpty) continue;
    var value = line.substring(eq + 1).trim();
    if (value.length >= 2) {
      final q = value[0];
      if ((q == '"' || q == "'") && value.endsWith(q)) {
        value = value.substring(1, value.length - 1);
      }
    }
    out[key] = value;
  }
  return out;
}
