class Result<T> {
  const Result._({this.data, this.error});

  final T? data;
  final String? error;

  bool get isSuccess => error == null;

  factory Result.success(T data) => Result._(data: data);
  factory Result.failure(String error) => Result._(error: error);
}
