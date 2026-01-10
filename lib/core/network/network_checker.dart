import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Network connectivity checker with real-time monitoring
class NetworkChecker {
  final Connectivity _connectivity;

  NetworkChecker(this._connectivity);

  /// Check if device is currently connected to internet
  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    return _isConnectedFromResult(result.first);
  }

  /// Get current network type
  Future<NetworkType> get networkType async {
    final result = await _connectivity.checkConnectivity();
    return _networkTypeFromResult(result.first);
  }

  /// Stream of connectivity changes
  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map((result) {
      return _isConnectedFromResult(result.first);
    });
  }

  /// Stream of network type changes
  Stream<NetworkType> get onNetworkTypeChanged {
    return _connectivity.onConnectivityChanged.map((result) {
      return _networkTypeFromResult(result.first);
    });
  }

  bool _isConnectedFromResult(ConnectivityResult result) {
    return result != ConnectivityResult.none;
  }

  NetworkType _networkTypeFromResult(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.wifi:
        return NetworkType.wifi;
      case ConnectivityResult.mobile:
        return NetworkType.mobile;
      case ConnectivityResult.ethernet:
        return NetworkType.ethernet;
      case ConnectivityResult.vpn:
        return NetworkType.vpn;
      case ConnectivityResult.bluetooth:
        return NetworkType.bluetooth;
      case ConnectivityResult.other:
        return NetworkType.other;
      case ConnectivityResult.none:
        return NetworkType.none;
    }
  }
}

/// Network type enumeration
enum NetworkType {
  none,
  wifi,
  mobile,
  ethernet,
  vpn,
  bluetooth,
  other;

  bool get isConnected => this != NetworkType.none;
  bool get isWifi => this == NetworkType.wifi;
  bool get isMobile => this == NetworkType.mobile;
}

// ============================================================================
// Riverpod Providers
// ============================================================================

/// Provider for Connectivity instance
final connectivityProvider = Provider<Connectivity>((ref) {
  return Connectivity();
});

/// Provider for NetworkChecker
final networkCheckerProvider = Provider<NetworkChecker>((ref) {
  final connectivity = ref.watch(connectivityProvider);
  return NetworkChecker(connectivity);
});

/// Stream provider for connectivity status
final connectivityStreamProvider = StreamProvider<bool>((ref) {
  final checker = ref.watch(networkCheckerProvider);
  return checker.onConnectivityChanged;
});

/// Stream provider for network type
final networkTypeStreamProvider = StreamProvider<NetworkType>((ref) {
  final checker = ref.watch(networkCheckerProvider);
  return checker.onNetworkTypeChanged;
});

/// Future provider for current connectivity status
final isConnectedProvider = FutureProvider<bool>((ref) {
  final checker = ref.watch(networkCheckerProvider);
  return checker.isConnected;
});
