import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:komiut/core/network/network_info.dart';

class MockConnectivity extends Mock implements Connectivity {}

void main() {
  late NetworkInfo networkInfo;
  late MockConnectivity mockConnectivity;

  setUp(() {
    mockConnectivity = MockConnectivity();
    networkInfo = NetworkInfoImpl(mockConnectivity);
  });

  group('isConnected', () {
    test('should return true when connectivity is wifi', () async {
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.wifi]);

      final result = await networkInfo.isConnected;

      expect(result, true);
    });

    test('should return true when connectivity is mobile', () async {
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.mobile]);

      final result = await networkInfo.isConnected;

      expect(result, true);
    });

    test('should return false when connectivity is none', () async {
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.none]);

      final result = await networkInfo.isConnected;

      expect(result, false);
    });
  });

  group('onConnectivityChanged', () {
    test('should emit connectivity results', () async {
      final tResult = [ConnectivityResult.wifi];
      when(() => mockConnectivity.onConnectivityChanged)
          .thenAnswer((_) => Stream.value(tResult));

      expect(networkInfo.onConnectivityChanged, emits(tResult));
    });
  });
}


