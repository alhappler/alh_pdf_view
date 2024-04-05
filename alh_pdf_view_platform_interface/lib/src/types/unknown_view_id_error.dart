/// Error thrown when an unknown view id is provided to a method channel API.
class UnknownViewIdError extends Error {
  /// The unknown id.
  final int viewId;

  /// Message describing the assertion error.
  final Object? message;

  /// Creates an assertion error with the provided [viewId] and optional
  /// [message].
  UnknownViewIdError(this.viewId, [this.message]);

  @override
  String toString() {
    if (message != null) {
      return 'Unknown view id $viewId: ${Error.safeToString(message)}';
    }
    return 'Unknown view id $viewId';
  }
}
