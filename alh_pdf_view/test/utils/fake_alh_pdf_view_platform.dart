import 'dart:async';

import 'package:alh_pdf_view/alh_pdf_view.dart';
import 'package:alh_pdf_view_platform_interface/alh_pdf_view_platform_interface.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_transform/stream_transform.dart';

// ignore_for_file: close_sinks, use_setters_to_change_properties

class FakeAlhPdfViewPlatform extends AlhPdfViewPlatform {
  final StreamController<MapEvent<Object?>> mapEventStreamController =
      StreamController<MapEvent<Object?>>.broadcast();

  Stream<MapEvent<Object?>> _events(int viewId) =>
      mapEventStreamController.stream.where((event) => event.viewId == viewId);

  @override
  Future<void> init(int viewId) async {}

  ///
  /// buildView
  ///

  int _buildViewCalls = 0;
  AlhPdfViewCreationParams? _buildViewCreationParams;
  WidgetConfiguration? _buildViewWidgetConfiguration;
  Widget? _buildViewResult;

  void setUpBuildView({required Widget result}) {
    _buildViewResult = result;
  }

  @override
  Widget buildView({
    required AlhPdfViewCreationParams creationParams,
    required WidgetConfiguration widgetConfiguration,
    int viewId = 0,
  }) {
    if (_buildViewResult == null) {
      throw UnimplementedError(
        'Call setUpBuildView before calling this method!',
      );
    }

    if (_buildViewCalls == 0) {
      widgetConfiguration.onPlatformViewCreated(viewId);
    }

    _buildViewCreationParams = creationParams;
    _buildViewWidgetConfiguration = widgetConfiguration;
    _buildViewCalls++;

    return _buildViewResult!;
  }

  void verifyBuildView({
    required AlhPdfViewCreationParams creationParams,
    required WidgetConfiguration widgetConfiguration,
    int called = 1,
  }) {
    if (_buildViewCreationParams == null ||
        _buildViewWidgetConfiguration == null) {
      throw UnimplementedError(
        'Call buildView before calling this method!',
      );
    }
    expect(_buildViewCalls, called);
    _buildViewCalls -= called;

    // compare creationParams
    expect(_buildViewCreationParams, equals(creationParams));

    // compare widgetConfiguration
    final actualConfig = _buildViewWidgetConfiguration!;
    expect(
      actualConfig.gestureRecognizers,
      widgetConfiguration.gestureRecognizers,
    );
  }

  ///
  /// onRender
  ///

  @override
  Stream<OnRenderEvent> onRender({required int viewId}) {
    return _events(viewId).whereType<OnRenderEvent>();
  }

  void addOnRenderEvent({required int viewId, required int pageCount}) {
    mapEventStreamController.add(OnRenderEvent(viewId, pageCount));
  }

  ///
  /// onPageChanged
  ///

  @override
  Stream<OnPageChangedEvent> onPageChanged({required int viewId}) {
    return _events(viewId).whereType<OnPageChangedEvent>();
  }

  void addOnPageChangedEvent({
    required int viewId,
    required int page,
    required int total,
  }) {
    final event = PageChangedObject(total: total, page: page);
    mapEventStreamController.add(OnPageChangedEvent(viewId, event));
  }

  ///
  /// onError
  ///

  @override
  Stream<OnErrorEvent> onError({required int viewId}) {
    return _events(viewId).whereType<OnErrorEvent>();
  }

  void addOnErrorEvent({
    required int viewId,
    required String error,
  }) {
    mapEventStreamController.add(OnErrorEvent(viewId, error));
  }

  ///
  /// onZoomChanged
  ///

  @override
  Stream<OnZoomChangedEvent> onZoomChanged({required int viewId}) {
    return _events(viewId).whereType<OnZoomChangedEvent>();
  }

  void addOnZoomChangedEvent({
    required int viewId,
    required double zoom,
  }) {
    mapEventStreamController.add(OnZoomChangedEvent(viewId, zoom));
  }

  ///
  /// onLinkHandle
  ///

  @override
  Stream<OnLinkHandleEvent> onLinkHandle({required int viewId}) {
    return _events(viewId).whereType<OnLinkHandleEvent>();
  }

  void addOnLinkHandleEvent({
    required int viewId,
    required String link,
  }) {
    mapEventStreamController.add(OnLinkHandleEvent(viewId, link));
  }

  ///
  /// onTap
  ///

  @override
  Stream<OnTapEvent> onTap({required int viewId}) {
    return _events(viewId).whereType<OnTapEvent>();
  }

  void addOnTapEvent({
    required int viewId,
  }) {
    mapEventStreamController.add(OnTapEvent(viewId));
  }

  ///
  /// getPageCount
  ///

  int _getPageCountCalls = 0;
  int? _pageCount;

  void setUpGetPageCount({required int pageCount}) {
    _pageCount = pageCount;
  }

  @override
  Future<int> getPageCount({required int viewId}) async {
    if (_pageCount == null) {
      throw UnimplementedError(
        'Call setUpGetPageCount before calling this method!',
      );
    }

    _getPageCountCalls++;
    return _pageCount!;
  }

  void verifyGetPageCount() {
    expect(_getPageCountCalls--, 1);
  }

  ///
  /// getCurrentPage
  ///

  int _getCurrentPageCalls = 0;
  int? _getCurrentPageResult;

  void setUpGetCurrentPage({required int page}) {
    _getCurrentPageResult = page;
  }

  @override
  Future<int> getCurrentPage({required int viewId}) async {
    if (_getCurrentPageResult == null) {
      throw UnimplementedError(
        'Call setUpGetCurrentPage before calling this method!',
      );
    }
    _getCurrentPageCalls++;
    return _getCurrentPageResult!;
  }

  void verifyGetCurrentPage() {
    expect(_getCurrentPageCalls--, 1);
  }

  ///
  /// setPage
  ///

  int _setPageCalls = 0;
  bool? _setPageResult;
  int? _setPageActualPage;
  bool? _setPageWithAnimation;

  void setUpSetPage({required bool result}) {
    _setPageResult = result;
  }

  @override
  Future<bool> setPage({
    required int viewId,
    required int page,
    required bool withAnimation,
  }) async {
    if (_setPageResult == null) {
      throw UnimplementedError(
        'Call setUpSetPage before calling this method!',
      );
    }
    _setPageActualPage = page;
    _setPageWithAnimation = withAnimation;
    _setPageCalls++;

    return _setPageResult!;
  }

  void verifySetPage({
    required int page,
    required bool withAnimation,
  }) {
    if (_setPageActualPage == null || _setPageWithAnimation == null) {
      throw UnimplementedError(
        'Call setPage before calling this method!',
      );
    }

    expect(_setPageCalls--, 1);
    expect(page, _setPageActualPage);
    expect(withAnimation, _setPageWithAnimation);
  }

  ///
  /// goToNextPage
  ///

  int _goToNextPageCalls = 0;
  bool? _goToNextPageResult;
  bool? _goToNextPageWithAnimation;

  void setUpGoToNextPage({required bool result}) {
    _goToNextPageResult = result;
  }

  @override
  Future<bool> goToNextPage({
    required int viewId,
    required bool withAnimation,
  }) async {
    if (_goToNextPageResult == null) {
      throw UnimplementedError(
        'Call setUpGoToNextPage before calling this method!',
      );
    }
    _goToNextPageWithAnimation = withAnimation;
    _goToNextPageCalls++;

    return _goToNextPageResult!;
  }

  void verifyGoToNextPage({
    required bool withAnimation,
  }) {
    if (_goToNextPageWithAnimation == null) {
      throw UnimplementedError(
        'Call goToNextPage before calling this method!',
      );
    }

    expect(_goToNextPageCalls--, 1);
    expect(withAnimation, _goToNextPageWithAnimation);
  }

  ///
  /// goToPreviousPage
  ///

  int _goToPreviousPageCalls = 0;
  bool? _goToPreviousPageResult;
  bool? _goToPreviousPageWithAnimation;

  void setUpGoToPreviousPage({required bool result}) {
    _goToPreviousPageResult = result;
  }

  @override
  Future<bool> goToPreviousPage({
    required int viewId,
    required bool withAnimation,
  }) async {
    if (_goToPreviousPageResult == null) {
      throw UnimplementedError(
        'Call setUpGoToPreviousPage before calling this method!',
      );
    }
    _goToPreviousPageWithAnimation = withAnimation;
    _goToPreviousPageCalls++;

    return _goToPreviousPageResult!;
  }

  void verifyGoToPreviousPage({
    required bool withAnimation,
  }) {
    if (_goToPreviousPageWithAnimation == null) {
      throw UnimplementedError(
        'Call goToPreviousPage before calling this method!',
      );
    }

    expect(_goToPreviousPageCalls--, 1);
    expect(withAnimation, _goToPreviousPageWithAnimation);
  }

  ///
  /// resetZoom
  ///

  int _resetZoomCalls = 0;

  @override
  Future<void> resetZoom({required int viewId}) async {
    _resetZoomCalls++;
  }

  void verifyResetZoom() {
    expect(_resetZoomCalls--, 1);
  }

  ///
  /// setZoom
  ///

  int _setZoomCalls = 0;
  double? _actualSetZoom;

  @override
  Future<void> setZoom({
    required int viewId,
    required double zoom,
  }) async {
    _setZoomCalls++;
    _actualSetZoom = zoom;
  }

  void verifySetZoom({required double zoom}) {
    expect(_setZoomCalls--, 1);
    expect(zoom, _actualSetZoom);
  }

  ///
  /// getZoom
  ///

  int _getZoomCalls = 0;
  double? _getZoomResult;

  void setUpGetZoom({required double zoom}) {
    _getZoomResult = zoom;
  }

  @override
  Future<double> getZoom({required int viewId}) async {
    if (_getZoomResult == null) {
      throw UnimplementedError(
        'Call setUpGetZoom before calling this method!',
      );
    }

    _getZoomCalls++;

    return _getZoomResult!;
  }

  void verifyGetZoom() {
    expect(_getZoomCalls--, 1);
  }

  ///
  /// getPageSize
  ///

  int _getPageSizeCalls = 0;
  int? _getPageSizePage;
  Size? _getPageSizeResult;

  void setUpGetPageSize({required Size pageSize}) {
    _getPageSizeResult = pageSize;
  }

  @override
  Future<Size> getPageSize({
    required int viewId,
    required int page,
  }) async {
    if (_getPageSizeResult == null) {
      throw UnimplementedError(
        'Call setUpGetPageSize before calling this method!',
      );
    }

    _getPageSizePage = page;
    _getPageSizeCalls++;

    return _getPageSizeResult!;
  }

  void verifyGetPageSize({required int page}) {
    if (_getPageSizePage == null) {
      throw UnimplementedError(
        'Call getPageSize before calling this method!',
      );
    }
    expect(_getPageSizeCalls--, 1);
    expect(page, _getPageSizePage);
  }

  ///
  /// setOrientation
  ///

  int _setOrientationCalls = 0;
  Orientation? _setOrientationActualOrientation;
  Map<String, dynamic>? _setOrientationCreationParams;

  @override
  Future<void> setOrientation({
    required int viewId,
    required Orientation orientation,
    required Map<String, dynamic> creationParams,
  }) async {
    _setOrientationActualOrientation = orientation;
    _setOrientationCreationParams = creationParams;
    _setOrientationCalls++;
  }

  void verifySetOrientation({
    Orientation? orientation,
    Map<String, dynamic>? creationParams,
    int called = 1,
  }) {
    if (called == 0) {
      expect(_setOrientationCalls, 0);
      return;
    }

    if (_setOrientationActualOrientation == null ||
        _setOrientationCreationParams == null) {
      throw UnimplementedError(
        'Call setOrientation before calling this method!',
      );
    }
    expect(_setOrientationCalls, called);
    _setOrientationCalls -= called;
    expect(orientation, _setOrientationActualOrientation);
    expect(creationParams, _setOrientationCreationParams);
  }

  ///
  /// updateBytesOrPath
  ///

  int _refreshPdfCalls = 0;
  Map<String, dynamic>? _refreshPdfActualCreationParams;

  @override
  Future<void> refreshPdf({
    required int viewId,
    required Map<String, dynamic> creationParams,
  }) async {
    _refreshPdfActualCreationParams = creationParams;
    _refreshPdfCalls++;
  }

  void verifyRefreshPdf({
    int called = 1,
    Map<String, dynamic>? creationParams,
  }) {
    if (called == 0) {
      expect(_setOrientationCalls, 0);
      return;
    }

    if (_refreshPdfActualCreationParams == null) {
      throw UnimplementedError(
        'Call updateBytesOrPath before calling this method!',
      );
    }
    expect(_refreshPdfCalls--, 1);
    expect(creationParams, _refreshPdfActualCreationParams);
  }

  ///
  /// updateFitPolicy
  ///

  int _updateFitPolicyCalls = 0;
  Map<String, dynamic>? _updateFitPolicyCallsActualCreationParams;

  @override
  Future<void> updateFitPolicy({
    required int viewId,
    required Map<String, dynamic> creationParams,
  }) async {
    _updateFitPolicyCallsActualCreationParams = creationParams;
    _updateFitPolicyCalls++;
  }

  void verifyUpdateFitPolicy({
    int called = 1,
    Map<String, dynamic>? creationParams,
  }) {
    if (called == 0) {
      expect(_setOrientationCalls, 0);
      return;
    }

    if (_updateFitPolicyCallsActualCreationParams == null) {
      throw UnimplementedError(
        'Call updateFitPolicy before calling this method!',
      );
    }
    expect(_updateFitPolicyCalls--, 1);
    expect(creationParams, _updateFitPolicyCallsActualCreationParams);
  }

  ///
  /// updateScrollbar
  ///

  int _updateScrollbarCalls = 0;
  Map<String, dynamic>? _updateScrollbarCallsActualCreationParams;

  @override
  Future<void> updateScrollbar({
    required int viewId,
    required Map<String, dynamic> creationParams,
  }) async {
    _updateScrollbarCallsActualCreationParams = creationParams;
    _updateScrollbarCalls++;
  }

  void verifyUpdateScrollbar({
    int called = 1,
    Map<String, dynamic>? creationParams,
  }) {
    if (called == 0) {
      expect(_setOrientationCalls, 0);
      return;
    }

    if (_updateScrollbarCallsActualCreationParams == null) {
      throw UnimplementedError(
        'Call updateScrollbar before calling this method!',
      );
    }
    expect(_updateScrollbarCalls--, 1);
    expect(creationParams, _updateScrollbarCallsActualCreationParams);
  }

  ///
  /// dispose
  ///

  int _disposeCalls = 0;

  @override
  Future<void> dispose({required int viewId}) async {
    _disposeCalls++;
  }

  void verifyDispose({int called = 1}) {
    if (called == 0) {
      expect(_disposeCalls, 0);
      return;
    }

    expect(_disposeCalls--, 1);
  }

  void verifyNoMoreInteraction() {
    expect(_buildViewCalls, 0);
    expect(_getPageCountCalls, 0);
    expect(_getCurrentPageCalls, 0);
    expect(_setOrientationCalls, 0);
    expect(_setPageCalls, 0);
    expect(_goToPreviousPageCalls, 0);
    expect(_goToNextPageCalls, 0);
    expect(_getZoomCalls, 0);
    expect(_getPageSizeCalls, 0);
    expect(_resetZoomCalls, 0);
    expect(_getZoomCalls, 0);
    expect(_refreshPdfCalls, 0);
  }
}
