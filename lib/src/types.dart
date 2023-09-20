import 'dart:isolate';

typedef Json = Map<String, dynamic>;
typedef ImportCallback<T> = T Function(Json json);
typedef IsolateEntryPointCallback = Function(SendPort sendPort);
