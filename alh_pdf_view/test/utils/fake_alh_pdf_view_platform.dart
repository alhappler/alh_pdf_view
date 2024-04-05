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
    this._buildViewResult = result;
  }

  @override
  Widget buildView({
    required AlhPdfViewCreationParams creationParams,
    required WidgetConfiguration widgetConfiguration,
    int viewId = 0,
  }) {
    if (this._buildViewResult == null) {
      throw UnimplementedError(
        'Call setUpBuildView before calling this method!',
      );
    }

    if (this._buildViewCalls == 0) {
      widgetConfiguration.onPlatformViewCreated(viewId);
    }

    this._buildViewCreationParams = creationParams;
    this._buildViewWidgetConfiguration = widgetConfiguration;
    this._buildViewCalls++;

    return this._buildViewResult!;
  }

  void verifyBuildView({
    required AlhPdfViewCreationParams creationParams,
    required WidgetConfiguration widgetConfiguration,
    int called = 1,
  }) {
    if (this._buildViewCreationParams == null ||
        this._buildViewWidgetConfiguration == null) {
      throw UnimplementedError(
        'Call buildView before calling this method!',
      );
    }
    expect(this._buildViewCalls, called);
    this._buildViewCalls -= called;

    // compare creationParams
    expect(this._buildViewCreationParams, equals(creationParams));

    // compare widgetConfiguration
    final actualConfig = this._buildViewWidgetConfiguration!;
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
    return this._events(viewId).whereType<OnRenderEvent>();
  }

  void addOnRenderEvent({required int viewId, required int pageCount}) {
    this.mapEventStreamController.add(OnRenderEvent(viewId, pageCount));
  }

  ///
  /// onPageChanged
  ///

  @override
  Stream<OnPageChangedEvent> onPageChanged({required int viewId}) {
    return this._events(viewId).whereType<OnPageChangedEvent>();
  }

  void addOnPageChangedEvent({
    required int viewId,
    required int page,
    required int total,
  }) {
    final event = PageChangedObject(total: total, page: page);
    this.mapEventStreamController.add(OnPageChangedEvent(viewId, event));
  }

  ///
  /// onError
  ///

  @override
  Stream<OnErrorEvent> onError({required int viewId}) {
    return this._events(viewId).whereType<OnErrorEvent>();
  }

  void addOnErrorEvent({
    required int viewId,
    required String error,
  }) {
    this.mapEventStreamController.add(OnErrorEvent(viewId, error));
  }

  ///
  /// onError
  ///

  @override
  Stream<OnPageErrorEvent> onPageError({required int viewId}) {
    return this._events(viewId).whereType<OnPageErrorEvent>();
  }

  void addOnPageErrorEvent({
    required int viewId,
    required int page,
    required String error,
  }) {
    final event = PageErrorObject(page: page, error: error);
    this.mapEventStreamController.add(OnPageErrorEvent(viewId, event));
  }

  ///
  /// onZoomChanged
  ///

  @override
  Stream<OnZoomChangedEvent> onZoomChanged({required int viewId}) {
    return this._events(viewId).whereType<OnZoomChangedEvent>();
  }

  void addOnZoomChangedEvent({
    required int viewId,
    required double zoom,
  }) {
    this.mapEventStreamController.add(OnZoomChangedEvent(viewId, zoom));
  }

  ///
  /// onLinkHandle
  ///

  @override
  Stream<OnLinkHandleEvent> onLinkHandle({required int viewId}) {
    return this._events(viewId).whereType<OnLinkHandleEvent>();
  }

  void addOnLinkHandleEvent({
    required int viewId,
    required String link,
  }) {
    this.mapEventStreamController.add(OnLinkHandleEvent(viewId, link));
  }

  ///
  /// getPageCount
  ///

  int _getPageCountCalls = 0;
  int? _pageCount;

  void setUpGetPageCount({required int pageCount}) {
    this._pageCount = pageCount;
  }

  @override
  Future<int> getPageCount({required int viewId}) async {
    if (this._pageCount == null) {
      throw UnimplementedError(
        'Call setUpGetPageCount before calling this method!',
      );
    }

    this._getPageCountCalls++;
    return this._pageCount!;
  }

  void verifyGetPageCount() {
    expect(this._getPageCountCalls--, 1);
  }

  ///
  /// getCurrentPage
  ///

  int _getCurrentPageCalls = 0;
  int? _getCurrentPageResult;

  void setUpGetCurrentPage({required int page}) {
    this._getCurrentPageResult = page;
  }

  @override
  Future<int> getCurrentPage({required int viewId}) async {
    if (this._getCurrentPageResult == null) {
      throw UnimplementedError(
        'Call setUpGetCurrentPage before calling this method!',
      );
    }
    this._getCurrentPageCalls++;
    return this._getCurrentPageResult!;
  }

  void verifyGetCurrentPage() {
    expect(this._getCurrentPageCalls--, 1);
  }

  ///
  /// setPage
  ///

  int _setPageCalls = 0;
  bool? _setPageResult;
  int? _setPageActualPage;
  bool? _setPageWithAnimation;

  void setUpSetPage({required bool result}) {
    this._setPageResult = result;
  }

  @override
  Future<bool> setPage({
    required int viewId,
    required int page,
    required bool withAnimation,
  }) async {
    if (this._setPageResult == null) {
      throw UnimplementedError(
        'Call setUpSetPage before calling this method!',
      );
    }
    this._setPageActualPage = page;
    this._setPageWithAnimation = withAnimation;
    this._setPageCalls++;

    return this._setPageResult!;
  }

  void verifySetPage({
    required int page,
    required bool withAnimation,
  }) {
    if (this._setPageActualPage == null || this._setPageWithAnimation == null) {
      throw UnimplementedError(
        'Call setPage before calling this method!',
      );
    }

    expect(this._setPageCalls--, 1);
    expect(page, this._setPageActualPage);
    expect(withAnimation, this._setPageWithAnimation);
  }

  ///
  /// goToNextPage
  ///

  int _goToNextPageCalls = 0;
  bool? _goToNextPageResult;
  bool? _goToNextPageWithAnimation;

  void setUpGoToNextPage({required bool result}) {
    this._goToNextPageResult = result;
  }

  @override
  Future<bool> goToNextPage({
    required int viewId,
    required bool withAnimation,
  }) async {
    if (this._goToNextPageResult == null) {
      throw UnimplementedError(
        'Call setUpGoToNextPage before calling this method!',
      );
    }
    this._goToNextPageWithAnimation = withAnimation;
    this._goToNextPageCalls++;

    return this._goToNextPageResult!;
  }

  void verifyGoToNextPage({
    required bool withAnimation,
  }) {
    if (this._goToNextPageWithAnimation == null) {
      throw UnimplementedError(
        'Call goToNextPage before calling this method!',
      );
    }

    expect(this._goToNextPageCalls--, 1);
    expect(withAnimation, this._goToNextPageWithAnimation);
  }

  ///
  /// goToPreviousPage
  ///

  int _goToPreviousPageCalls = 0;
  bool? _goToPreviousPageResult;
  bool? _goToPreviousPageWithAnimation;

  void setUpGoToPreviousPage({required bool result}) {
    this._goToPreviousPageResult = result;
  }

  @override
  Future<bool> goToPreviousPage({
    required int viewId,
    required bool withAnimation,
  }) async {
    if (this._goToPreviousPageResult == null) {
      throw UnimplementedError(
        'Call setUpGoToPreviousPage before calling this method!',
      );
    }
    this._goToPreviousPageWithAnimation = withAnimation;
    this._goToPreviousPageCalls++;

    return this._goToPreviousPageResult!;
  }

  void verifyGoToPreviousPage({
    required bool withAnimation,
  }) {
    if (this._goToPreviousPageWithAnimation == null) {
      throw UnimplementedError(
        'Call goToPreviousPage before calling this method!',
      );
    }

    expect(this._goToPreviousPageCalls--, 1);
    expect(withAnimation, this._goToPreviousPageWithAnimation);
  }

  ///
  /// resetZoom
  ///

  int _resetZoomCalls = 0;

  @override
  Future<void> resetZoom({required int viewId}) async {
    this._resetZoomCalls++;
  }

  void verifyResetZoom() {
    expect(this._resetZoomCalls--, 1);
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
    this._setZoomCalls++;
    this._actualSetZoom = zoom;
  }

  void verifySetZoom({required double zoom}) {
    expect(this._setZoomCalls--, 1);
    expect(zoom, this._actualSetZoom);
  }

  ///
  /// getZoom
  ///

  int _getZoomCalls = 0;
  double? _getZoomResult;

  void setUpGetZoom({required double zoom}) {
    this._getZoomResult = zoom;
  }

  @override
  Future<double> getZoom({required int viewId}) async {
    if (this._getZoomResult == null) {
      throw UnimplementedError(
        'Call setUpGetZoom before calling this method!',
      );
    }

    this._getZoomCalls++;

    return this._getZoomResult!;
  }

  void verifyGetZoom() {
    expect(this._getZoomCalls--, 1);
  }

  ///
  /// getPageSize
  ///

  int _getPageSizeCalls = 0;
  int? _getPageSizePage;
  Size? _getPageSizeResult;

  void setUpGetPageSize({required Size pageSize}) {
    this._getPageSizeResult = pageSize;
  }

  @override
  Future<Size> getPageSize({
    required int viewId,
    required int page,
  }) async {
    if (this._getPageSizeResult == null) {
      throw UnimplementedError(
        'Call setUpGetPageSize before calling this method!',
      );
    }

    this._getPageSizePage = page;
    this._getPageSizeCalls++;

    return this._getPageSizeResult!;
  }

  void verifyGetPageSize({required int page}) {
    if (this._getPageSizePage == null) {
      throw UnimplementedError(
        'Call getPageSize before calling this method!',
      );
    }
    expect(this._getPageSizeCalls--, 1);
    expect(page, this._getPageSizePage);
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
    this._setOrientationActualOrientation = orientation;
    this._setOrientationCreationParams = creationParams;
    this._setOrientationCalls++;
  }

  void verifySetOrientation({
    Orientation? orientation,
    Map<String, dynamic>? creationParams,
    int called = 1,
  }) {
    if (called == 0) {
      expect(this._setOrientationCalls, 0);
      return;
    }

    if (this._setOrientationActualOrientation == null ||
        this._setOrientationCreationParams == null) {
      throw UnimplementedError(
        'Call setOrientation before calling this method!',
      );
    }
    expect(this._setOrientationCalls, called);
    this._setOrientationCalls -= called;
    expect(orientation, this._setOrientationActualOrientation);
    expect(creationParams, this._setOrientationCreationParams);
  }

  ///
  /// updateCreationParams
  ///

  int _updateCreationParamsCalls = 0;
  Map<String, dynamic>? _updateCreationParamsActualCreationParams;

  @override
  Future<void> updateCreationParams({
    required int viewId,
    required Map<String, dynamic> creationParams,
  }) async {
    this._updateCreationParamsActualCreationParams = creationParams;
    this._updateCreationParamsCalls++;
  }

  void verifyUpdateCreationParams({
    int called = 1,
    Map<String, dynamic>? creationParams,
  }) {
    if (called == 0) {
      expect(this._setOrientationCalls, 0);
      return;
    }

    if (this._updateCreationParamsActualCreationParams == null) {
      throw UnimplementedError(
        'Call updateCreationParams before calling this method!',
      );
    }
    expect(this._updateCreationParamsCalls--, 1);
    expect(creationParams, this._updateCreationParamsActualCreationParams);
  }

  ///
  /// dispose
  ///

  int _disposeCalls = 0;

  @override
  Future<void> dispose({required int viewId}) async {
    this._disposeCalls++;
  }

  void verifyDispose({int called = 1}) {
    if (called == 0) {
      expect(this._disposeCalls, 0);
      return;
    }

    expect(this._disposeCalls--, 1);
  }

  void verifyNoMoreInteraction() {
    expect(this._buildViewCalls, 0);
    expect(this._getPageCountCalls, 0);
    expect(this._getCurrentPageCalls, 0);
    expect(this._setOrientationCalls, 0);
    expect(this._setPageCalls, 0);
    expect(this._goToPreviousPageCalls, 0);
    expect(this._goToNextPageCalls, 0);
    expect(this._getZoomCalls, 0);
    expect(this._getPageSizeCalls, 0);
    expect(this._resetZoomCalls, 0);
    expect(this._getZoomCalls, 0);
    expect(this._updateCreationParamsCalls, 0);
  }
}
