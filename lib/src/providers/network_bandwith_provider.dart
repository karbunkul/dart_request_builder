import 'package:request_builder/src/request_context.dart';
import 'package:request_builder/src/request_provider.dart';
import 'package:request_builder/src/request_response.dart';

/// Enum representing different types of network bandwidths.
enum BandwidthType {
  /// No simulate.
  none('without simulate', 0),

  /// GPRS (2G) with a bandwidth of 56 Kbps.
  gprs('GPRS (2G)', 56),

  /// EDGE (2.5G) with a bandwidth of 135 Kbps.
  edge('EDGE (2.5G)', 135),

  /// 3G with a bandwidth of 384 Kbps.
  threeG('3G', 384),

  /// HSPA+ (3.5G) with a bandwidth of 5 Mbps (5000 Kbps).
  hspaPlus('HSPA+ (3.5G)', 5000),

  /// LTE (4G) with a bandwidth of 50 Mbps (50000 Kbps).
  lte('LTE (4G)', 50000),

  /// 5G with a bandwidth of 100 Mbps (100000 Kbps).
  fiveG('5G', 100000),

  /// Wi-Fi 4 with a bandwidth of 72 Mbps (72000 Kbps).
  wifi4('Wi-Fi 4', 72000),

  /// Wi-Fi 5 with a bandwidth of 433 Mbps (433000 Kbps).
  wifi5('Wi-Fi 5', 433000),

  /// Wi-Fi 6 with a bandwidth of 1 Gbps (1000000 Kbps).
  wifi6('Wi-Fi 6', 1000000),

  /// Ethernet with a bandwidth of 1 Gbps (1000000 Kbps).
  ethernet('Ethernet (1 Gbit)', 1000000);

  /// The display name of the bandwidth type.
  final String name;

  /// The bandwidth value in Kbps (kilobits per second).
  final int bandwidth;

  /// Constructor for the `BandwidthType` enum.
  const BandwidthType(this.name, this.bandwidth);

  /// Calculates the time required to transmit the given number of bytes
  /// over the network represented by this `BandwidthType`.
  ///
  /// The result is a `Duration` representing the calculated delay.
  ///
  /// - [bytes]: The number of bytes to be transmitted.
  ///
  /// Returns a `Duration` representing the delay for the transmission.
  Duration calc(int bytes) {
    if (bandwidth <= 0) {
      throw ArgumentError(
          'Bandwidth must be greater than 0 to calculate delay.');
    }

    // Convert bytes to kilobits (1 byte = 8 bits = 0.008 kilobits).
    final kilobits = bytes * 0.008;

    // Calculate the delay in seconds (kilobits / bandwidth in Kbps).
    final delayInSeconds = kilobits / bandwidth;

    // Convert delay to Duration and return.
    return Duration(milliseconds: (delayInSeconds * 1000).round());
  }
}

final class NetworkBandwidthProvider implements RequestProvider {
  final RequestProvider provider;
  final BandwidthType bandwidth;

  const NetworkBandwidthProvider({
    required this.provider,
    required this.bandwidth,
  });

  @override
  Future<RequestResponse> request(RequestContext context) async {
    if (bandwidth.bandwidth == 0) {
      return provider.request(context);
    }

    final responseTime = Stopwatch()..start();
    final response = await provider.request(context);
    responseTime.stop();

    final simulatedTime = bandwidth.calc(response.bytes.length);

    if (responseTime.elapsedMilliseconds < simulatedTime.inMilliseconds) {
      final remainTime =
          simulatedTime.inMilliseconds - responseTime.elapsedMilliseconds;
      await Future.delayed(Duration(milliseconds: remainTime), () => response);
    }

    return response;
  }
}
