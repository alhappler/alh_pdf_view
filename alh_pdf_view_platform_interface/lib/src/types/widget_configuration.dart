import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';

@immutable
class WidgetConfiguration {
  final PointerUpEventListener onPointerUp;
  final PlatformViewCreatedCallback onPlatformViewCreated;

  final Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers;

  const WidgetConfiguration({
    required this.onPointerUp,
    required this.onPlatformViewCreated,
    required this.gestureRecognizers,
  });
}
