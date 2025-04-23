part of 'testing.dart';

@visibleForTesting
final class RequestBuilderTester {
  RequestProvider makeMockProvider({
    int statusCode = 200,
    List<int> content = const <int>[],
    Map<String, String> headers = const {},
    Duration delay = Duration.zero,
  }) {
    return FixtureProvider();
  }

  RequestBuilder makeMockBuilder({
    required PlatformType platform,
    Uri? endpoint,
    Duration? timeout,
    List<Interceptor>? interceptors,
  }) {
    return RequestBuilder(
      platform: platform,
      endpoint: endpoint?.toString(),
      timeout: timeout,
      provider: makeMockProvider(),
      interceptors: interceptors,
    );
  }

  ResponseExpect responseExpect(RequestResponse value) {
    return ResponseExpect(value);
  }
}
