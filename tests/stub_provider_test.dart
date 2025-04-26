import 'package:request_builder/request_builder.dart';

const endpoint = 'https://foobar.net';

void main() {
  final fixture = FixtureProvider();
  final provider = StubProvider(
    entries: [TestEntry()],
    provider: fixture,
    enabled: true,
  );

  requestBuilderTest('description', (tester) async {
    fixture.updateStatusCode(503);
    final builder = RequestBuilder(
      endpoint: endpoint,
      platform: PlatformType.web,
      provider: provider,
    );

    final response = await builder.query('limit', 10).get('posts');

    tester.responseExpect(response).isSuccess();
  });
}

final class TestEntry extends StubEntry {
  @override
  List<StubCase> cases() {
    return [
      StubCase(
        request: StubRequest(
          method: 'get',
          queries: {'limit': '10'},
          path: '$endpoint/posts',
        ),
        response: StubResponse(statusCode: 200, content: []),
      )
    ];
  }
}
