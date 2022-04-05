import 'package:flutter/services.dart';

Future<void> invokeMethodCall(
  MethodCall methodCall, {
  required String channelName,
}) =>
    ServicesBinding.instance!.defaultBinaryMessenger.handlePlatformMessage(
      channelName,
      const StandardMethodCodec().encodeMethodCall(methodCall),
      (data) {},
    );
