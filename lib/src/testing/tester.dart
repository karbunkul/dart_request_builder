part of 'testing.dart';

@visibleForTesting
final class RequestBuilderTester {
  RequestProvider makeMockProvider() {
    return FixtureProvider();
  }

  FixtureBuilder makeMockBuilder({
    required PlatformType platform,
    Uri? endpoint,
    Duration? timeout,
    List<Interceptor>? interceptors,
  }) {
    return FixtureBuilder(
      platform: platform,
      endpoint: endpoint?.toString(),
      interceptors: interceptors,
      fixture: FixtureProvider(),
      timeout: timeout,
    );
  }

  ResponseExpect responseExpect(RequestResponse value) {
    return ResponseExpect(value);
  }
}
