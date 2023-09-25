import 'dart:convert';
import 'dart:io';

import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:request_builder/src/isolation_json_decoder.dart';

final file = File('./benchmarks/heavy_json.txt');
final json = file.readAsBytesSync();

void main() {
  const number = 0;
  IsolationDecodeBenchmark(number).report();
  JsonDecodeBenchmark(number).report();
}

class IsolationDecodeBenchmark extends AsyncBenchmarkBase {
  final int number;
  const IsolationDecodeBenchmark(this.number)
      : super('IsolationDecodeBenchmark');

  @override
  Future<void> run() async {
    for (int i = 0; i < number; i++) {
      await IsolationJsonDecoder.listFromBytes(json);
    }
  }
}

class JsonDecodeBenchmark extends BenchmarkBase {
  final int number;
  const JsonDecodeBenchmark(this.number) : super('JsonDecodeBenchmark');

  @override
  void run() {
    for (int i = 0; i < number; i++) {
      final str = utf8.decode(json);
      jsonDecode(str);
    }
  }
}
