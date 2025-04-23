import 'package:request_builder/request_builder.dart';
import 'package:test/test.dart';

void main() {
  group('Request builder tests', () {
    requestBuilderTest('demo test', (tester) async {
      final builder = tester.makeMockBuilder(
        platform: PlatformType.web,
        endpoint: Uri.parse('https://foobar.net'),
        interceptors: [
          UserAgentInterceptor('Request-Builder'),
        ],
      );

      final response = await builder
          .query('s', 'search')
          .query('q', 'red')
          .query('limit', 10)
          .get('posts');

      tester.responseExpect(response)
        ..isSuccess()
        ..hasHeader('User-Agent', value: 'Request-Builder')
        ..hasQuery('q')
        ..hasQuery('limit', value: '10');
    });
  });
}
