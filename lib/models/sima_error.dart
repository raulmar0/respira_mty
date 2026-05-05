enum SimaErrorKind { simaDown, networkError }

class SimaError implements Exception {
  final SimaErrorKind kind;
  final String message;
  final int? statusCode;

  const SimaError({required this.kind, required this.message, this.statusCode});

  factory SimaError.simaDown({String? message, int? statusCode}) = SimaErrorSimaDown;
  factory SimaError.networkError({String? message}) = SimaErrorNetwork;

  bool get isSimaDown => kind == SimaErrorKind.simaDown;

  @override
  String toString() => 'SimaError(${kind.name}): $message';
}

class SimaErrorSimaDown extends SimaError {
  SimaErrorSimaDown({String? message, super.statusCode})
      : super(
          kind: SimaErrorKind.simaDown,
          message: message ?? 'SIMA server is unavailable',
        );
}

class SimaErrorNetwork extends SimaError {
  SimaErrorNetwork({String? message})
      : super(
          kind: SimaErrorKind.networkError,
          message: message ?? 'No internet connection',
        );
}