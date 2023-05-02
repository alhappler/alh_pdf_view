// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
//
// Source: https://github.com/flutter/flutter/blob/master/packages/flutter/test/services/fake_platform_views.dart

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Used in internal testing.
class FakePlatformViewController extends PlatformViewController {
  FakePlatformViewController(this.viewId);

  bool disposed = false;
  bool focusCleared = false;

  /// Events that are dispatched.
  List<PointerEvent> dispatchedPointerEvents = <PointerEvent>[];

  @override
  final int viewId;

  @override
  Future<void> dispatchPointerEvent(PointerEvent event) async {
    this.dispatchedPointerEvents.add(event);
  }

  void clearTestingVariables() {
    this.dispatchedPointerEvents.clear();
    this.disposed = false;
    this.focusCleared = false;
  }

  @override
  Future<void> dispose() async {
    this.disposed = true;
  }

  @override
  Future<void> clearFocus() async {
    this.focusCleared = true;
  }
}

class FakeAndroidViewController implements AndroidViewController {
  FakeAndroidViewController(this.viewId);

  bool disposed = false;
  bool focusCleared = false;
  bool created = false;

  /// Events that are dispatched.
  List<PointerEvent> dispatchedPointerEvents = <PointerEvent>[];

  @override
  final int viewId;

  @override
  late PointTransformer pointTransformer;

  @override
  Future<void> dispatchPointerEvent(PointerEvent event) async {
    this.dispatchedPointerEvents.add(event);
  }

  void clearTestingVariables() {
    this.dispatchedPointerEvents.clear();
    this.disposed = false;
    this.focusCleared = false;
  }

  @override
  Future<void> dispose() async {
    this.disposed = true;
  }

  @override
  Future<void> clearFocus() async {
    this.focusCleared = true;
  }

  @override
  Future<Size> setSize(Size size) {
    return Future<Size>.value(size);
  }

  @override
  int get textureId => throw UnimplementedError();

  @override
  bool get isCreated => throw UnimplementedError();

  @override
  void addOnPlatformViewCreatedListener(PlatformViewCreatedCallback listener) =>
      throw UnimplementedError();

  @override
  void removeOnPlatformViewCreatedListener(
      PlatformViewCreatedCallback listener) {
    throw UnimplementedError();
  }

  @override
  Future<void> sendMotionEvent(AndroidMotionEvent event) {
    throw UnimplementedError();
  }

  @override
  Future<void> setLayoutDirection(TextDirection layoutDirection) {
    throw UnimplementedError();
  }

  @override
  List<PlatformViewCreatedCallback> get createdCallbacks =>
      <PlatformViewCreatedCallback>[];

  @override
  Future<void> setOffset(Offset off) async {}

  @override
  bool get awaitingCreation => throw UnimplementedError();

  @override
  Future<void> create({Size? size, Offset? position}) async {
    this.created = true;
  }

  @override
  bool get requiresViewComposition => throw UnimplementedError();
}

class FakeAndroidPlatformViewsController {
  FakeAndroidPlatformViewsController() {
    TestDefaultBinaryMessengerBinding.instance!.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform_views, _onMethodCall);
  }

  Iterable<FakeAndroidPlatformView> get views => this._views.values;
  final Map<int, FakeAndroidPlatformView> _views =
      <int, FakeAndroidPlatformView>{};

  final Map<int, List<FakeAndroidMotionEvent>> motionEvents =
      <int, List<FakeAndroidMotionEvent>>{};

  final Set<String> _registeredViewTypes = <String>{};

  int _textureCounter = 0;

  Completer<void>? resizeCompleter;

  Completer<void>? createCompleter;

  int? lastClearedFocusViewId;

  Map<int, Offset> offsets = <int, Offset>{};

  void registerViewType(String viewType) {
    this._registeredViewTypes.add(viewType);
  }

  void invokeViewFocused(int viewId) {
    final MethodCodec codec = SystemChannels.platform_views.codec;
    final ByteData data =
        codec.encodeMethodCall(MethodCall('viewFocused', viewId));
// ignore: discarded_futures,
    ServicesBinding.instance.defaultBinaryMessenger.handlePlatformMessage(
        SystemChannels.platform_views.name, data, (ByteData? data) {});
  }

  Future<dynamic> _onMethodCall(MethodCall call) {
    switch (call.method) {
      case 'create':
        return this._create(call);
      case 'dispose':
        return this._dispose(call);
      case 'resize':
        return this._resize(call);
      case 'touch':
        return this._touch(call);
      case 'setDirection':
        return this._setDirection(call);
      case 'clearFocus':
        return this._clearFocus(call);
      case 'offset':
        return this._offset(call);
    }
    return Future<dynamic>.sync(() => null);
  }

  Future<dynamic> _create(MethodCall call) async {
    final Map<dynamic, dynamic> args = call.arguments as Map<dynamic, dynamic>;
    final int id = args['id'] as int;
    final String viewType = args['viewType'] as String;
    final double? width = args['width'] as double?;
    final double? height = args['height'] as double?;
    final int layoutDirection = args['direction'] as int;
    final bool? hybrid = args['hybrid'] as bool?;
    final Uint8List? creationParams = args['params'] as Uint8List?;

    if (this._views.containsKey(id)) {
      throw PlatformException(
        code: 'error',
        message:
            'Trying to create an already created platform view, view id: $id',
      );
    }

    if (!this._registeredViewTypes.contains(viewType)) {
      throw PlatformException(
        code: 'error',
        message:
            'Trying to create a platform view of unregistered type: $viewType',
      );
    }

    if (this.createCompleter != null) {
      await this.createCompleter!.future;
    }

    this._views[id] = FakeAndroidPlatformView(
      id,
      viewType,
      width != null && height != null ? Size(width, height) : null,
      layoutDirection,
      hybrid,
      creationParams,
    );
    final int textureId = this._textureCounter++;
    return Future<int>.sync(() => textureId);
  }

  Future<dynamic> _dispose(MethodCall call) {
    assert(call.arguments is Map);
    final Map<Object?, Object?> arguments =
        call.arguments as Map<Object?, Object?>;

    final int id = arguments['id']! as int;
    final bool hybrid = arguments['hybrid']! as bool;

    if (hybrid && !this._views[id]!.hybrid!) {
      throw ArgumentError(
          'An $AndroidViewController using hybrid composition must pass `hybrid: true`');
    } else if (!hybrid && (this._views[id]!.hybrid ?? false)) {
      throw ArgumentError(
          'An $AndroidViewController not using hybrid composition must pass `hybrid: false`');
    }

    if (!this._views.containsKey(id)) {
      throw PlatformException(
        code: 'error',
        message: 'Trying to dispose a platform view with unknown id: $id',
      );
    }

    this._views.remove(id);
    return Future<dynamic>.sync(() => null);
  }

  Future<dynamic> _resize(MethodCall call) async {
    final Map<dynamic, dynamic> args = call.arguments as Map<dynamic, dynamic>;
    final int id = args['id'] as int;
    final double width = args['width'] as double;
    final double height = args['height'] as double;

    if (!this._views.containsKey(id)) {
      throw PlatformException(
        code: 'error',
        message: 'Trying to resize a platform view with unknown id: $id',
      );
    }

    if (this.resizeCompleter != null) {
      await this.resizeCompleter!.future;
    }
    this._views[id] = this._views[id]!.copyWith(size: Size(width, height));

    return Future<Map<dynamic, dynamic>>.sync(
        () => <dynamic, dynamic>{'width': width, 'height': height});
  }

  Future<dynamic> _offset(MethodCall call) async {
    final Map<dynamic, dynamic> args = call.arguments as Map<dynamic, dynamic>;
    final int id = args['id'] as int;
    final double top = args['top'] as double;
    final double left = args['left'] as double;
    this.offsets[id] = Offset(left, top);
    return Future<dynamic>.sync(() => null);
  }

  Future<dynamic> _touch(MethodCall call) {
    final List<dynamic> args = call.arguments as List<dynamic>;
    final int id = args[0] as int;
    final int action = args[3] as int;
    final List<List<dynamic>> pointerProperties =
        (args[5] as List<dynamic>).cast<List<dynamic>>();
    final List<List<dynamic>> pointerCoords =
        (args[6] as List<dynamic>).cast<List<dynamic>>();
    final List<Offset> pointerOffsets = <Offset>[];
    final List<int> pointerIds = <int>[];
    for (int i = 0; i < pointerCoords.length; i++) {
      pointerIds.add(pointerProperties[i][0] as int);
      final double x = pointerCoords[i][7] as double;
      final double y = pointerCoords[i][8] as double;
      pointerOffsets.add(Offset(x, y));
    }

    if (!this.motionEvents.containsKey(id)) {
      this.motionEvents[id] = <FakeAndroidMotionEvent>[];
    }

    this
        .motionEvents[id]!
        .add(FakeAndroidMotionEvent(action, pointerIds, pointerOffsets));
    return Future<dynamic>.sync(() => null);
  }

  Future<dynamic> _setDirection(MethodCall call) async {
    final Map<dynamic, dynamic> args = call.arguments as Map<dynamic, dynamic>;
    final int id = args['id'] as int;
    final int layoutDirection = args['direction'] as int;

    if (!this._views.containsKey(id)) {
      throw PlatformException(
        code: 'error',
        message: 'Trying to resize a platform view with unknown id: $id',
      );
    }

    this._views[id] =
        this._views[id]!.copyWith(layoutDirection: layoutDirection);

    return Future<dynamic>.sync(() => null);
  }

  Future<dynamic> _clearFocus(MethodCall call) {
    final int id = call.arguments as int;

    if (!this._views.containsKey(id)) {
      throw PlatformException(
        code: 'error',
        message:
            'Trying to clear the focus on a platform view with unknown id: $id',
      );
    }

    this.lastClearedFocusViewId = id;
    return Future<dynamic>.sync(() => null);
  }
}

class FakeIosPlatformViewsController {
  FakeIosPlatformViewsController() {
    TestDefaultBinaryMessengerBinding.instance!.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform_views, _onMethodCall);
  }

  Iterable<FakeUiKitView> get views => this._views.values;
  final Map<int, FakeUiKitView> _views = <int, FakeUiKitView>{};

  final Set<String> _registeredViewTypes = <String>{};

  // When this completer is non null, the 'create' method channel call will be
  // delayed until it completes.
  Completer<void>? creationDelay;

  // Maps a view id to the number of gestures it accepted so far.
  final Map<int, int> gesturesAccepted = <int, int>{};

  // Maps a view id to the number of gestures it rejected so far.
  final Map<int, int> gesturesRejected = <int, int>{};

  void registerViewType(String viewType) {
    this._registeredViewTypes.add(viewType);
  }

  Future<dynamic> _onMethodCall(MethodCall call) {
    switch (call.method) {
      case 'create':
        return this._create(call);
      case 'dispose':
        return this._dispose(call);
      case 'acceptGesture':
        return this._acceptGesture(call);
      case 'rejectGesture':
        return this._rejectGesture(call);
    }
    return Future<dynamic>.sync(() => null);
  }

  Future<dynamic> _create(MethodCall call) async {
    if (this.creationDelay != null) await this.creationDelay!.future;
    final Map<dynamic, dynamic> args = call.arguments as Map<dynamic, dynamic>;
    final int id = args['id'] as int;
    final String viewType = args['viewType'] as String;
    final Uint8List? creationParams = args['params'] as Uint8List?;

    if (this._views.containsKey(id)) {
      throw PlatformException(
        code: 'error',
        message:
            'Trying to create an already created platform view, view id: $id',
      );
    }

    if (!this._registeredViewTypes.contains(viewType)) {
      throw PlatformException(
        code: 'error',
        message:
            'Trying to create a platform view of unregistered type: $viewType',
      );
    }

    this._views[id] = FakeUiKitView(id, viewType, creationParams);
    this.gesturesAccepted[id] = 0;
    this.gesturesRejected[id] = 0;
    return Future<int?>.sync(() => null);
  }

  Future<dynamic> _acceptGesture(MethodCall call) async {
    final Map<dynamic, dynamic> args = call.arguments as Map<dynamic, dynamic>;
    final int id = args['id'] as int;
    this.gesturesAccepted[id] = this.gesturesAccepted[id]! + 1;
    return Future<int?>.sync(() => null);
  }

  Future<dynamic> _rejectGesture(MethodCall call) async {
    final Map<dynamic, dynamic> args = call.arguments as Map<dynamic, dynamic>;
    final int id = args['id'] as int;
    this.gesturesRejected[id] = this.gesturesRejected[id]! + 1;
    return Future<int?>.sync(() => null);
  }

  Future<dynamic> _dispose(MethodCall call) {
    final int id = call.arguments as int;

    if (!this._views.containsKey(id)) {
      throw PlatformException(
        code: 'error',
        message: 'Trying to dispose a platform view with unknown id: $id',
      );
    }

    this._views.remove(id);
    return Future<dynamic>.sync(() => null);
  }
}

class FakeHtmlPlatformViewsController {
  FakeHtmlPlatformViewsController() {
    TestDefaultBinaryMessengerBinding.instance!.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform_views, _onMethodCall);
  }

  Iterable<FakeHtmlPlatformView> get views => this._views.values;
  final Map<int, FakeHtmlPlatformView> _views = <int, FakeHtmlPlatformView>{};

  final Set<String> _registeredViewTypes = <String>{};

  late Completer<void> resizeCompleter;

  Completer<void>? createCompleter;

  void registerViewType(String viewType) {
    this._registeredViewTypes.add(viewType);
  }

  Future<dynamic> _onMethodCall(MethodCall call) {
    switch (call.method) {
      case 'create':
        return this._create(call);
      case 'dispose':
        return this._dispose(call);
    }
    return Future<dynamic>.sync(() => null);
  }

  Future<dynamic> _create(MethodCall call) async {
    final Map<dynamic, dynamic> args = call.arguments as Map<dynamic, dynamic>;
    final int id = args['id'] as int;
    final String viewType = args['viewType'] as String;

    if (this._views.containsKey(id)) {
      throw PlatformException(
        code: 'error',
        message:
            'Trying to create an already created platform view, view id: $id',
      );
    }

    if (!this._registeredViewTypes.contains(viewType)) {
      throw PlatformException(
        code: 'error',
        message:
            'Trying to create a platform view of unregistered type: $viewType',
      );
    }

    if (this.createCompleter != null) {
      await this.createCompleter!.future;
    }

    this._views[id] = FakeHtmlPlatformView(id, viewType);
    return Future<int?>.sync(() => null);
  }

  Future<dynamic> _dispose(MethodCall call) {
    final int id = call.arguments as int;

    if (!this._views.containsKey(id)) {
      throw PlatformException(
        code: 'error',
        message: 'Trying to dispose a platform view with unknown id: $id',
      );
    }

    this._views.remove(id);
    return Future<dynamic>.sync(() => null);
  }
}

@immutable
class FakeAndroidPlatformView {
  const FakeAndroidPlatformView(
      this.id, this.type, this.size, this.layoutDirection, this.hybrid,
      [this.creationParams]);

  final int id;
  final String type;
  final Uint8List? creationParams;
  final Size? size;
  final int layoutDirection;
  final bool? hybrid;

  FakeAndroidPlatformView copyWith({Size? size, int? layoutDirection}) =>
      FakeAndroidPlatformView(
        this.id,
        this.type,
        size ?? this.size,
        layoutDirection ?? this.layoutDirection,
        this.hybrid,
        this.creationParams,
      );

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is FakeAndroidPlatformView &&
        other.id == this.id &&
        other.type == this.type &&
        listEquals<int>(other.creationParams, this.creationParams) &&
        other.size == this.size &&
        other.hybrid == this.hybrid &&
        other.layoutDirection == this.layoutDirection;
  }

  @override
  int get hashCode => Object.hash(
        this.id,
        this.type,
        Object.hashAll(this.creationParams ?? []),
        this.size,
        this.layoutDirection,
        this.hybrid,
      );

  @override
  String toString() {
    return 'FakeAndroidPlatformView(id: ${this.id}, type: ${this.type}, size: ${this.size}, layoutDirection: ${this.layoutDirection}, hybrid: ${this.hybrid}, creationParams: ${this.creationParams})';
  }
}

@immutable
class FakeAndroidMotionEvent {
  const FakeAndroidMotionEvent(this.action, this.pointerIds, this.pointers);

  final int action;
  final List<Offset> pointers;
  final List<int> pointerIds;

  @override
  bool operator ==(Object other) {
    return other is FakeAndroidMotionEvent &&
        listEquals<int>(other.pointerIds, this.pointerIds) &&
        other.action == this.action &&
        listEquals<Offset>(other.pointers, this.pointers);
  }

  @override
  int get hashCode => Object.hash(
        this.action,
        Object.hashAll(this.pointers),
        Object.hashAll(this.pointerIds),
      );

  @override
  String toString() {
    return 'FakeAndroidMotionEvent(action: ${this.action}, pointerIds: ${this.pointerIds}, pointers: ${this.pointers})';
  }
}

@immutable
class FakeUiKitView {
  const FakeUiKitView(this.id, this.type, [this.creationParams]);

  final int id;
  final String type;
  final Uint8List? creationParams;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is FakeUiKitView &&
        other.id == this.id &&
        other.type == this.type &&
        other.creationParams == this.creationParams;
  }

  @override
  int get hashCode => Object.hash(this.id, this.type);

  @override
  String toString() {
    return 'FakeUiKitView(id: ${this.id}, type: ${this.type}, creationParams: ${this.creationParams})';
  }
}

@immutable
class FakeHtmlPlatformView {
  const FakeHtmlPlatformView(this.id, this.type);

  final int id;
  final String type;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is FakeHtmlPlatformView &&
        other.id == this.id &&
        other.type == this.type;
  }

  @override
  int get hashCode => Object.hash(this.id, this.type);

  @override
  String toString() {
    return 'FakeHtmlPlatformView(id: ${this.id}, type: ${this.type})';
  }
}
