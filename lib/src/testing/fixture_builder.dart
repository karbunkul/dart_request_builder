part of 'testing.dart';

final class FixtureBuilder extends RequestBuilder {
  final FixtureProvider _fixtureProvider;

  FixtureBuilder({
    required super.platform,
    super.endpoint,
    super.interceptors,
    super.timeout,
    required FixtureProvider fixture,
  })  : _fixtureProvider = fixture,
        super(provider: fixture);

  FixtureBuilder copyWith({
    PlatformType? platform,
    String? endpoint,
    List<Interceptor>? interceptors,
    Duration? timeout,
  }) {
    return FixtureBuilder(
      platform: platform ?? this.platform,
      endpoint: endpoint ?? this.endpoint,
      fixture: _fixtureProvider,
      interceptors: interceptors ?? this.interceptors,
      timeout: timeout ?? this.timeout,
    );
  }

  FixtureProvider get provider => _fixtureProvider;
}
