part of 'testing.dart';

@visibleForTesting

/// A helper class used to assert properties of a [RequestResponse] during tests.
///
/// This class is intended for use in test environments to validate HTTP responses,
/// such as status codes, headers, query parameters, and body presence.
/// final class ResponseExpect {
  /// The response data to be validated.
  final RequestResponse data;

  /// Creates an instance of [ResponseExpect] with the given [data].
  const ResponseExpect(this.data);

  /// Asserts that the response has the specified [statusCode].
  ///
  /// You can optionally provide a custom [reason] or a [skip] condition.
  void isStatusCode(int statusCode, {String? reason, Object? skip}) {
    final newReason = 'invalid status code "$statusCode"';

    expect(
      data.statusCode,
      equals(statusCode),
      reason: reason ?? newReason,
      skip: skip,
    );
  }

  /// Asserts that the response has a 200 (OK) status code.
  ///
  /// You can optionally provide a custom [reason] or a [skip] condition.
  void isSuccess({String? reason, Object? skip}) {
    isStatusCode(200);
  }

  /// Asserts that the original request contains a body.
  ///
  /// Useful for checking if payloads were properly attached.
  void hasBody({String? reason, Object? skip}) {
    final newReason = 'missing body in request';

    expect(
      data.request.hasBody,
      equals(true),
      reason: reason ?? newReason,
      skip: skip,
    );
  }

  /// Asserts that the original request does **not** contain a body.
  ///
  /// Useful for validating that a request was sent without unintended content.
  void hasNoBody({String? reason, Object? skip}) {
    final newReason = 'body is not expected in request';

    expect(
      data.request.hasBody,
      equals(false),
      reason: reason ?? newReason,
      skip: skip,
    );
  }

  /// Asserts that the original request contains a query parameter named [name].
  ///
  /// If [value] is provided, also asserts that the parameter has the expected value.
  void hasQuery(String name, {String? value, String? reason, Object? skip}) {
    final queries = data.request.uri.queryParameters;

    final reasonForName =
        'missing required query parameter "$name" in URI (${data.request.uri})';

    expect(
      queries.containsKey(name),
      equals(true),
      reason: reason ?? reasonForName,
      skip: skip,
    );
    if (value != null) {
      final reasonForValue = 'invalid value for query parameter "$name"';
      final actual = queries[name];
      expect(
        actual,
        equals(value),
        reason: reason ?? reasonForValue,
        skip: skip,
      );
    }
  }

  /// Asserts that the original request contains a header named [name].
  ///
  /// If [value] is provided, also asserts that the header has the expected value.
  void hasHeader(String name, {String? value, String? reason, Object? skip}) {
    final headers = data.request.headers;
    final newName = name.toLowerCase();
    final reasonForName = 'missing header "$newName"';

    expect(
      headers.containsKey(newName),
      equals(true),
      reason: reason ?? reasonForName,
      skip: skip,
    );
    if (value != null) {
      final reasonForValue = 'invalid value for header "$newName"';
      final actual = headers[newName];
      expect(
        actual,
        equals(value),
        reason: reason ?? reasonForValue,
        skip: skip,
      );
    }
  }

  /// Asserts that the request has a `Content-Type` header with the given [value].
  ///
  /// This is a shorthand for [hasHeader] with `'content-type'` as the header name.
  void hasContentType(String value, {String? reason, Object? skip}) {
    hasHeader('content-type', value: value, reason: reason, skip: skip);
  }
}
