part of 'testing.dart';

@visibleForTesting

/// A mock implementation of [RequestProvider] used for testing purposes.
///
/// Allows simulating HTTP responses with configurable status code, body,
/// headers, and optional artificial delay.

final class FixtureProvider implements RequestProvider {
  int _statusCode = 200;
  List<int> _content = [];
  Map<String, String> _headers = {};
  Duration _delay = Duration.zero;

  /// Updates the status code for the simulated response.
  void updateStatusCode(int value) {
    _statusCode = value;
  }

  /// Updates the response content using raw bytes.
  void updateContentFromBytes(List<int> value) {
    _content = value;
  }

  /// Updates the response content from a plain text string.
  void updateContentFromText(String value) {
    _content = utf8.encode(value);
  }

  /// Updates the response content by serializing and encoding a JSON object.
  void updateContentFromJson(Json value) {
    final jsonStr = jsonEncode(value);
    final decoded = utf8.encode(jsonStr);

    _content = decoded;
  }

  /// Updates the headers of the simulated response.
  void updateHeaders(Map<String, String> value) {
    _headers = value;
  }

  /// Simulates a delay before the response is returned.
  ///
  /// Useful for testing timeout behavior or simulating network latency.
  void simulateResponseDelay(Duration value) {
    _delay = value;
  }

  /// Resets the internal state to default values.
  void reset() {
    _statusCode = 200;
    _content = [];
    _headers = {};
    _delay = Duration.zero;
  }

  @override

  /// Sends a mock request and returns a simulated response based on the current configuration.
  Future<RequestResponse> request(RequestContext context) async {
    if (_delay > Duration.zero) {
      await Future.delayed(_delay);
    }

    return RequestResponse(
      request: context,
      statusCode: _statusCode,
      bytes: Uint8List.fromList(_content),
      headers: responseHeaders,
    );
  }

  /// Converts internal header map to a list of [ResponseHeader]s.
  List<ResponseHeader> get responseHeaders {
    if (_headers.isEmpty) {
      return [];
    }
    final items = <ResponseHeader>[];
    for (final name in _headers.keys) {
      items.add(ResponseHeader(name: name, values: [_headers[name]!]));
    }

    return items;
  }
}
