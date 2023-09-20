import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'types.dart';

typedef _EntryPointCallback = Function(SendPort sendPort);

sealed class IsolationJsonDecoder {
  static Future<Json> fromBytes(List<int> source) async {
    final result = await _decode(source);
    return result as Json;
  }

  static Future<Json> fromString(String source) async {
    final result = await _decode(source);
    return result as Json;
  }

  static Future<List<Json>> listFromBytes(List<int> source) async {
    final result = await _decode(source);
    return (result as List).cast<Json>();
  }

  static Future<List<Json>> listFromString(String source) async {
    final result = await _decode(source);
    return (result as List).cast<Json>();
  }

  static Future<dynamic> _decode(dynamic source) async {
    final receivePort = ReceivePort();
    final isolate = await Isolate.spawn<SendPort>(
      _onIsolate(source),
      receivePort.sendPort,
      onError: receivePort.sendPort,
    );

    final completer = Completer();

    // listen receive port
    receivePort.listen((message) {
      if (message is _IsolationError) {
        completer.completeError(message.error, message.stackTrace);
      } else {
        completer.complete(message);
      }

      isolate.kill(priority: Isolate.immediate);
      receivePort.close();
    });

    return completer.future;
  }

  static _EntryPointCallback _onIsolate(dynamic source) {
    return (SendPort sendPort) {
      try {
        if (source is String) {
          // decode text to json
          final decoded = jsonDecode(source);
          sendPort.send(decoded);
        } else if (source is List<int>) {
          // convert to text
          final str = utf8.decode(source);
          // decode text to json
          final decoded = jsonDecode(str);
          sendPort.send(decoded);
        }
      } catch (e, st) {
        sendPort.send(_IsolationError(error: e, stackTrace: st));
      }
    };
  }
}

final class _IsolationError {
  final Object error;
  final StackTrace stackTrace;

  _IsolationError({required this.error, required this.stackTrace});
}
