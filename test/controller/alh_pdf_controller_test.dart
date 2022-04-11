import 'package:alh_pdf_view/controller/alh_pdf_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AlhPdfController controller;
  const givenId = 0;
  const channel = MethodChannel('alh_pdf_$givenId');

  setUp(() {
    controller = AlhPdfController(id: givenId);
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  group('#setOrienation', () {
    test(
        'GIVEN creationParams and orientation '
        'WHEN calling #setOrientation '
        'THEN should call channel with expected arguments', () async {
      // given
      final givenCreationParams = <String, dynamic>{'creation': 'params'};
      const givenOrientation = Orientation.landscape;

      late final MethodCall actualMethodCall;
      channel.setMockMethodCallHandler((call) async {
        if (call.method == 'setOrientation') {
          actualMethodCall = call;
        }
      });

      // when
      await controller.setOrienation(
        orientation: givenOrientation,
        creationParams: givenCreationParams,
      );

      // then
      final expectedMethodCall = MethodCall('setOrientation', {
        'orientation': givenOrientation.toString(),
        ...givenCreationParams,
      });
      expect(actualMethodCall.method, equals(expectedMethodCall.method));
      expect(actualMethodCall.arguments, equals(expectedMethodCall.arguments));
    });
  });

  group('#updateCreationParams', () {
    const givenChannelMethodName = 'updateCreationParams';
    test(
        'GIVEN platform = .iOS and creationParams '
        'WHEN calling #updateCreationParams '
        'THEN should call channel with expected arguments', () async {
      // given
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

      final givenCreationParams = <String, dynamic>{'creation': 'params'};

      late final MethodCall actualMethodCall;
      channel.setMockMethodCallHandler((call) async {
        if (call.method == givenChannelMethodName) {
          actualMethodCall = call;
        }
      });

      // when
      await controller.updateCreationParams(
        creationParams: givenCreationParams,
      );

      // then
      final expectedMethodCall = MethodCall(
        'updateCreationParams',
        givenCreationParams,
      );
      expect(actualMethodCall.method, equals(expectedMethodCall.method));
      expect(actualMethodCall.arguments, equals(expectedMethodCall.arguments));

      debugDefaultTargetPlatformOverride = null;
    });

    test(
        'GIVEN platform = .android and creationParams '
        'WHEN calling #updateCreationParams '
        'THEN should call nothing', () async {
      // given
      debugDefaultTargetPlatformOverride = TargetPlatform.android;

      final givenCreationParams = <String, dynamic>{'creation': 'params'};

      MethodCall? actualMethodCall;
      channel.setMockMethodCallHandler((call) async {
        if (call.method == givenChannelMethodName) {
          actualMethodCall = call;
        }
      });

      // when
      await controller.updateCreationParams(
        creationParams: givenCreationParams,
      );

      // then
      expect(actualMethodCall, isNull);

      debugDefaultTargetPlatformOverride = null;
    });
  });
}
