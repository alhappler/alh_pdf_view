import 'dart:async';

import 'package:alh_pdf_view_platform_interface/alh_pdf_view_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stream_transform/stream_transform.dart';

// ignore_for_file: close_sinks

/// An implementation of [AlhPdfViewPlatform] for Android.
class AlhPdfViewIOS extends AlhPdfViewPlatform {
  static const _viewType = 'alh_pdf_view';

  /// Registers the Android implementation of GoogleMapsFlutterPlatform.
  static void registerWith() {
    AlhPdfViewPlatform.instance = AlhPdfViewIOS();
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
    await _channel(viewId).invokeMethod('dispose');
  }

  /// Returns the number of pages  for the PDF.
  @override
  Future<int> getPageCount({required int viewId}) async {
    final int pageCount = await _channel(viewId).invokeMethod('pageCount');
    return pageCount;
  }

  /// Returns the current page that is shown.
  ///
  /// The page index begins at 0.
  @override
  Future<int> getCurrentPage({required int viewId}) async {
    final currentPage = await _channel(viewId).invokeMethod('currentPage');
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
    return await _channel(viewId).invokeMethod('setPage', {
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
    return await _channel(viewId).invokeMethod(
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
    return await _channel(viewId).invokeMethod(
      'previousPage',
      {'withAnimation': withAnimation},
    );
  }

  /// Setting the scale factor to the default zoom factor.
  @override
  Future<void> resetZoom({required int viewId}) async {
    await _channel(viewId).invokeMethod('resetZoom');
  }

  /// Zooming to the given [zoom].
  ///
  /// By default, the zoom animation duration is 400 ms.
  @override
  Future<void> setZoom({
    required double zoom,
    required int viewId,
  }) async {
    await _channel(viewId).invokeMethod('setZoom', <String, dynamic>{
      'newZoom': zoom,
    });
  }

  /// Returns the current zoom value.
  @override
  Future<double> getZoom({required int viewId}) async {
    return await _channel(viewId).invokeMethod('currentZoom');
  }

  /// Returns the size of the given [page] index.
  @override
  Future<Size> getPageSize({required int viewId, required int page}) async {
    final sizeMap = await _channel(viewId).invokeMethod(
      'pageSize',
      {'page': page},
    );
    return Size(sizeMap['width'], sizeMap['height']);
  }

  /// Updating bytes or path for the native PDF View.
  @override
  Future<void> refreshPdf({
    required int viewId,
    required Map<String, dynamic> creationParams,
  }) async {
    await _channel(viewId).invokeMethod(
      'refreshPdf',
      creationParams,
    );
  }

  /// Updating fitPolicy for the native PDF View.
  @override
  Future<void> updateFitPolicy({
    required int viewId,
    required Map<String, dynamic> creationParams,
  }) async {
    await _channel(viewId).invokeMethod(
      'updateFitPolicy',
      creationParams,
    );
  }

  /// Shows or remove the scrollbar for the native Pdf view.
  @override
  Future<void> updateScrollbar({
    required int viewId,
    required Map<String, dynamic> creationParams,
  }) async {
    await _channel(viewId).invokeMethod(
      'updateScrollbar',
      creationParams,
    );
  }

  @override
  Widget buildView({
    required AlhPdfViewCreationParams creationParams,
    required WidgetConfiguration widgetConfiguration,
  }) {
    final creationParamsMap = creationParams.toMap();
    return UiKitView(
      viewType: _viewType,
      onPlatformViewCreated: widgetConfiguration.onPlatformViewCreated,
      gestureRecognizers: widgetConfiguration.gestureRecognizers,
      creationParams: creationParamsMap,
      creationParamsCodec: const StandardMessageCodec(),
    );
  }

  ///
  /// handleMethodCalls
  ///

  @override
  Stream<OnRenderEvent> onRender({required int viewId}) {
    return _events(viewId).whereType<OnRenderEvent>();
  }

  @override
  Stream<OnPageChangedEvent> onPageChanged({required int viewId}) {
    return _events(viewId).whereType<OnPageChangedEvent>();
  }

  @override
  Stream<OnErrorEvent> onError({required int viewId}) {
    return _events(viewId).whereType<OnErrorEvent>();
  }

  @override
  Stream<OnZoomChangedEvent> onZoomChanged({required int viewId}) {
    return _events(viewId).whereType<OnZoomChangedEvent>();
  }

  @override
  Stream<OnLinkHandleEvent> onLinkHandle({required int viewId}) {
    return _events(viewId).whereType<OnLinkHandleEvent>();
  }

  @override
  Stream<OnTapEvent> onTap({required int viewId}) {
    return _events(viewId).whereType<OnTapEvent>();
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
  MethodChannel _ensureChannelInitialized(int viewId) {
    MethodChannel? channel = channels[viewId];

    if (channel == null) {
      channel = MethodChannel('alh_pdf_view_$viewId');
      channel.setMethodCallHandler(
        (MethodCall call) async => _handleMethodCall(call, viewId),
      );
      channels[viewId] = channel;
    }
    return channel;
  }

  Future<dynamic> _handleMethodCall(MethodCall call, int viewId) async {
    switch (call.method) {
      case 'onRender':
        final event = OnRenderEvent(
          viewId,
          call.arguments['pages'],
        );
        _mapEventStreamController.add(event);
        break;
      case 'onPageChanged':
        final pageChangedObject = PageChangedObject(
          page: call.arguments['page'],
          total: call.arguments['total'],
        );
        final event = OnPageChangedEvent(viewId, pageChangedObject);
        _mapEventStreamController.add(event);
        break;
      case 'onError':
        final event = OnErrorEvent(viewId, call.arguments['error']);
        _mapEventStreamController.add(event);
        break;
      case 'onZoomChanged':
        final event = OnZoomChangedEvent(
          viewId,
          call.arguments['zoom'],
        );
        _mapEventStreamController.add(event);
        break;
      case 'onLinkHandle':
        final event = OnLinkHandleEvent(
          viewId,
          call.arguments['url'],
        );
        _mapEventStreamController.add(event);
        break;
      case 'onTap':
        final event = OnTapEvent(viewId);
        _mapEventStreamController.add(event);
        break;
      default:
        throw MissingPluginException(
          '${call.method} was invoked but has no handler',
        );
    }
  }
}
