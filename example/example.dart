import 'dart:async';
import 'dart:convert';

import 'package:request_builder/request_builder.dart';

import 'dio_provider.dart';

Future<void> main() async {
  final payload = JsonBody({
    'title': 'foo bar',
    'body': 'baz',
    'userId': 3,
  });

  final res = await builder
      .body(payload)
      .get('posts', timeout: Duration(milliseconds: 800));

  // final todo = await res.json.of(TodoModel.fromJson);
  // print(todo);
  final todos = await res.jsonList.of(TodoModel.fromJson);
  for (var e in todos) {
    print(e.title);
  }
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
    provider: DioProvider(),
    debugMode: true,
    endpoint: 'https://jsonplaceholder.typicode.com',
    interceptors: [
      CurlInterceptor(onCurl: print),
      DebugInterceptor(headers: false, weight: 0),
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
