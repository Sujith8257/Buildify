class DeviceHeartbeat {
  const DeviceHeartbeat({
    required this.sessionId,
    required this.batteryPercent,
    required this.cpuPercent,
    required this.timestampMs,
  });

  final String sessionId;
  final int batteryPercent;
  final double cpuPercent;
  final int timestampMs;
}

class DeviceRequestMetric {
  const DeviceRequestMetric({
    required this.sessionId,
    required this.requestCount,
    required this.requestsPerSecond,
    required this.timestampMs,
  });

  final String sessionId;
  final int requestCount;
  final double requestsPerSecond;
  final int timestampMs;
}

class DeviceLogMetric {
  const DeviceLogMetric({
    required this.sessionId,
    required this.projectId,
    required this.level,
    required this.message,
    required this.timestampMs,
  });

  final String sessionId;
  final String projectId;
  final String level;
  final String message;
  final int timestampMs;
}

abstract class DeviceRuntimeAdapter {
  Future<void> sendHeartbeat(DeviceHeartbeat heartbeat);
  Future<void> sendRequestMetric(DeviceRequestMetric metric);
  Future<void> sendLogMetric(DeviceLogMetric metric);
}
