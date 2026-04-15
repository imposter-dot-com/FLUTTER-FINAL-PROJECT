// Simple wrapper for the three UI states used by the station screen.
enum AsyncValueState { loading, error, success }

class AsyncValue<T> {
  final T? data;
  final Object? error;
  final AsyncValueState state;

  AsyncValue._({this.data, this.error, required this.state});

  factory AsyncValue.loading() => AsyncValue._(state: AsyncValueState.loading);

  factory AsyncValue.success(T data) {
    return AsyncValue._(data: data, state: AsyncValueState.success);
  }

  factory AsyncValue.error(Object error) {
    return AsyncValue._(error: error, state: AsyncValueState.error);
  }
}
