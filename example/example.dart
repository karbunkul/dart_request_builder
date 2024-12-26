import 'dart:async';
import 'dart:convert';

import 'package:request_builder/request_builder.dart';

import 'memory_cache_storage.dart';

final storage = MemoryCacheStorage();

Future<void> main() async {
  await requestTodos();
  await requestTodos();
  print('wait two seconds');
  await Future.delayed(Duration(seconds: 2), () => null);
  await requestTodos();
}

Future<void> requestTodos() async {
  final payload = JsonBody({
    'title': 'foo bar',
    'body': 'baz',
    'userId': 3,
  });

  final res = await builder
      // .body(payload)
      .withCache(ttl: Duration(seconds: 6), storage: storage)
      .get('posts');

  // final todos = await res.jsonList.of(TodoModel.fromJson);

  // print((await res.text).substring(0, 100));
}

class TodoModel {
  final int id;
  final int userId;
  final String title;
  final String body;

  TodoModel({
    required this.id,
    required this.title,
    required this.userId,
    required this.body,
  });

  @override
  String toString() {
    return '(id=$id, userId=$userId, title=$title, body=$body)';
  }

  static TodoModel fromJson(Json json) {
    return TodoModel(
      id: json['id'],
      userId: json['userId'],
      title: json['title'],
      body: json['body'],
    );
  }
}

typedef Json = Map<String, dynamic>;

RequestBuilder get builder {
  return RequestBuilder(
    // provider: HttpProvider(proxyOptions: ProxyOptions(port: 8080)),
    // provider: DioProvider(),
    debugMode: true,
    endpoint: 'https://jsonplaceholder.typicode.com',
    interceptors: [
      CurlInterceptor(onCurl: print),
    ],
  );
}

void prettyJson(Json json) {
  final encoder = JsonEncoder.withIndent('  ');
  print(encoder.convert(json));
}

extension CustomQueryManager on RequestBuilder {
  RequestBuilder limit(int value) {
    query('limit', value.toString());
    return this;
  }
}
