import 'dart:async';

import 'package:alh_pdf_view_platform_interface/alh_pdf_view_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:stream_transform/stream_transform.dart';

// ignore_for_file: close_sinks

/// An implementation of [AlhPdfViewPlatform] for Android.
class AlhPdfViewAndroid extends AlhPdfViewPlatform {
  static const _viewType = 'alh_pdf_view';

  /// Registers the Android implementation of GoogleMapsFlutterPlatform.
  static void registerWith() {
    AlhPdfViewPlatform.instance = AlhPdfViewAndroid();
  }

  /// Keep a collection of id -> channel.
  @visibleForTesting
  final Map<int, MethodChannel> channels = <int, MethodChannel>{};

  /// The controller we need to broadcast the different events coming
  /// from handleMethodCall.
  ///
  /// It is a `broadcast` because multiple controllers will connect to
  /// different stream views of this Controller.
  final StreamController<MapEvent<Object?>> _mapEventStreamController =
      StreamController<MapEvent<Object?>>.broadcast();

  Stream<MapEvent<Object?>> _events(int viewId) =>
      _mapEventStreamController.stream.where((event) => event.viewId == viewId);

  @override
  Future<void> init(int viewId) async {
    _ensureChannelInitialized(viewId);
  }

  @override
  Future<void> dispose({required int viewId}) async {
    // nothing to do on the native side
  }

  /// Returns the number of pages  for the PDF.
  @override
  Future<int> getPageCount({required int viewId}) async {
    final int pageCount = await this._channel(viewId).invokeMethod('pageCount');
    return pageCount;
  }

  /// Returns the current page that is shown.
  ///
  /// The page index begins at 0.
  @override
  Future<int> getCurrentPage({required int viewId}) async {
    final currentPage = await this._channel(viewId).invokeMethod('currentPage');
    return currentPage;
  }

  /// Jumping to the given [page].
  ///
  /// By default, [withAnimation] is true and takes 400ms to animate the page change.
  /// Returns true if page change was possible.
  @override
  Future<bool> setPage({
    required int page,
    required int viewId,
    required bool withAnimation,
  }) async {
    return await this._channel(viewId).invokeMethod('setPage', {
      'page': page,
      'withAnimation': withAnimation,
    });
  }

  /// Goes to the next page.
  ///
  /// By default, [withAnimation] is true and takes 400ms to animate the page change.
  /// Returns true if page change was possible.
  @override
  Future<bool> goToNextPage({
    required int viewId,
    required bool withAnimation,
  }) async {
    return await this._channel(viewId).invokeMethod(
      'nextPage',
      {'withAnimation': withAnimation},
    );
  }

  /// Goes to the previous page.
  ///
  /// By default, [withAnimation] is true and takes 400ms to animate the page change.
  /// Returns true if page change was possible.
  @override
  Future<bool> goToPreviousPage({
    required int viewId,
    required bool withAnimation,
  }) async {
    return await this._channel(viewId).invokeMethod(
      'previousPage',
      {'withAnimation': withAnimation},
    );
  }

  /// Setting the scale factor to the default zoom factor.
  @override
  Future<void> resetZoom({required int viewId}) async {
    await this._channel(viewId).invokeMethod('resetZoom');
  }

  /// Zooming to the given [zoom].
  ///
  /// By default, the zoom animation duration is 400 ms.
  @override
  Future<void> setZoom({
    required double zoom,
    required int viewId,
  }) async {
    await this._channel(viewId).invokeMethod('setZoom', <String, dynamic>{
      'newZoom': zoom,
    });
  }

  /// Returns the current zoom value.
  @override
  Future<double> getZoom({required int viewId}) async {
    return await this._channel(viewId).invokeMethod('currentZoom');
  }

  /// Notifies the current [orientation].
  @override
  Future<void> setOrientation({
    required Orientation orientation,
    required Map<String, dynamic> creationParams,
    required int viewId,
  }) async {
    await this._channel(viewId).invokeMethod('setOrientation', {
      'orientation': orientation.toString(),
      ...creationParams,
    });
  }

  @override
  Widget buildView({
    required AlhPdfViewCreationParams creationParams,
    required WidgetConfiguration widgetConfiguration,
  }) {
    final creationParamsMap = creationParams.toMap();

    return Listener(
      onPointerUp: widgetConfiguration.onPointerUp,
      child: PlatformViewLink(
        viewType: _viewType,
        surfaceFactory: (
          BuildContext context,
          PlatformViewController controller,
        ) {
          return AndroidViewSurface(
            controller: controller as AndroidViewController,
            gestureRecognizers: widgetConfiguration.gestureRecognizers ??
                const <Factory<OneSequenceGestureRecognizer>>{},
            hitTestBehavior: PlatformViewHitTestBehavior.opaque,
          );
        },
        onCreatePlatformView: (PlatformViewCreationParams params) {
          final controller = PlatformViewsService.initSurfaceAndroidView(
            id: params.id,
            viewType: _viewType,
            layoutDirection: TextDirection.ltr,
            creationParams: creationParamsMap,
            creationParamsCodec: const StandardMessageCodec(),
            onFocus: () => params.onFocusChanged(true),
          );
          controller.addOnPlatformViewCreatedListener(
            params.onPlatformViewCreated,
          );
          controller.addOnPlatformViewCreatedListener(
            widgetConfiguration.onPlatformViewCreated,
          );
          unawaited(controller.create());

          return controller;
        },
      ),
    );
  }

  ///
  /// handleMethodCalls
  ///

  @override
  Stream<OnRenderEvent> onRender({required int viewId}) {
    return this._events(viewId).whereType<OnRenderEvent>();
  }

  @override
  Stream<OnPageChangedEvent> onPageChanged({required int viewId}) {
    return this._events(viewId).whereType<OnPageChangedEvent>();
  }

  @override
  Stream<OnErrorEvent> onError({required int viewId}) {
    return this._events(viewId).whereType<OnErrorEvent>();
  }

  @override
  Stream<OnPageErrorEvent> onPageError({required int viewId}) {
    return this._events(viewId).whereType<OnPageErrorEvent>();
  }

  @override
  Stream<OnZoomChangedEvent> onZoomChanged({required int viewId}) {
    return this._events(viewId).whereType<OnZoomChangedEvent>();
  }

  @override
  Stream<OnLinkHandleEvent> onLinkHandle({required int viewId}) {
    return this._events(viewId).whereType<OnLinkHandleEvent>();
  }

  @override
  Stream<OnTapEvent> onTap({required int viewId}) {
    return this._events(viewId).whereType<OnTapEvent>();
  }

  ///
  /// Private methods section
  ///

  /// Accesses the MethodChannel associated to the passed viewId.
  MethodChannel _channel(int viewId) {
    final MethodChannel? channel = channels[viewId];

    if (channel == null) {
      throw UnknownViewIdError(viewId);
    }
    return channel;
  }

  /// Returns the channel for [viewId], creating it if it doesn't already exist.
  void _ensureChannelInitialized(int viewId) {
    MethodChannel? channel = this.channels[viewId];

    if (channel == null) {
      channel = MethodChannel('alh_pdf_view_$viewId');
      channel.setMethodCallHandler(
        (MethodCall call) async => this._handleMethodCall(call, viewId),
      );
      this.channels[viewId] = channel;
    }
  }

  Future<dynamic> _handleMethodCall(MethodCall call, int viewId) async {
    switch (call.method) {
      case 'onRender':
        final event = OnRenderEvent(
          viewId,
          call.arguments['pages'],
        );
        this._mapEventStreamController.add(event);
        break;
      case 'onPageChanged':
        final pageChangedObject = PageChangedObject(
          page: call.arguments['page'],
          total: call.arguments['total'],
        );
        final event = OnPageChangedEvent(viewId, pageChangedObject);
        this._mapEventStreamController.add(event);
        break;
      case 'onError':
        final event = OnErrorEvent(viewId, call.arguments['error']);
        this._mapEventStreamController.add(event);
        break;
      case 'onPageError':
        final pageChangedObject = PageErrorObject(
          page: call.arguments['page'],
          error: call.arguments['error'],
        );
        final event = OnPageErrorEvent(viewId, pageChangedObject);
        this._mapEventStreamController.add(event);
        break;
      case 'onZoomChanged':
        final event = OnZoomChangedEvent(
          viewId,
          call.arguments['zoom'],
        );
        this._mapEventStreamController.add(event);
        break;
      case 'onTap':
        final event = OnTapEvent(viewId);
        this._mapEventStreamController.add(event);
        break;
      default:
        throw MissingPluginException(
          '${call.method} was invoked but has no handler',
        );
    }
  }
}
