part of 'testing.dart';

@visibleForTesting
final class FixtureProvider implements RequestProvider {
  final int statusCode;
  final List<int> content;
  final Map<String, String> headers;
  final Duration delay;

  FixtureProvider({
    this.statusCode = 200,
    this.content = const <int>[],
    this.headers = const {},
    this.delay = Duration.zero,
  });

  @override
  Future<RequestResponse> request(RequestContext context) async {
    if (delay > Duration.zero) {
      await Future.delayed(delay);
    }

    return RequestResponse(
      request: context,
      statusCode: statusCode,
      bytes: Uint8List.fromList(content),
      headers: responseHeaders,
    );
  }

  List<ResponseHeader> get responseHeaders {
    if (headers.isEmpty) {
      return [];
    }
    final items = <ResponseHeader>[];
    for (final name in headers.keys) {
      items.add(ResponseHeader(name: name, values: [headers[name]!]));
    }

    return items;
  }
}
