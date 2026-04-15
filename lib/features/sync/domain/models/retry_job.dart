class RetryJob {
  final int id;
  final String jobType;
  final String payloadJson;
  final int attempts;
  final String status;
  final String? lastError;
  final DateTime nextRetryAt;
  final DateTime createdAt;

  const RetryJob({
    required this.id,
    required this.jobType,
    required this.payloadJson,
    required this.attempts,
    required this.status,
    this.lastError,
    required this.nextRetryAt,
    required this.createdAt,
  });
}

