import 'dart:convert';

import 'package:flutter/foundation.dart';

class TelemetryService {
  const TelemetryService();

  void event(String name, Map<String, Object?> payload) {
    final body = jsonEncode({
      'event': name,
      'ts': DateTime.now().toIso8601String(),
      'payload': payload,
    });
    debugPrint('[telemetry] $body');
  }
}

