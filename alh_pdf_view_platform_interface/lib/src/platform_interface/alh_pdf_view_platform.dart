// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:alh_pdf_view_platform_interface/alh_pdf_view_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// The interface that platform-specific implementations of `alh_pdf_view` must extend.
///
/// Avoid `implements` of this interface. Using `implements` makes adding any new
/// methods here a breaking change for end users of your platform!
///
/// Do `extends AlhPdfViewPlatform` instead, so new methods added here are
/// inherited in your code with the default implementation (that throws at runtime),
/// rather than breaking your users at compile time.
abstract class AlhPdfViewPlatform extends PlatformInterface {
  /// Constructs a AlhPdfViewPlatform.
  AlhPdfViewPlatform() : super(token: _token);

  static final Object _token = Object();

  static AlhPdfViewPlatform? _instance;

  /// The default instance of [AlhPdfViewPlatform] to use.
  static AlhPdfViewPlatform? get instance => _instance;

  /// Platform-specific plugins should set this with their own platform-specific
  /// class that extends [AlhPdfViewPlatform] when they register themselves.
  static set instance(AlhPdfViewPlatform? instance) {
    if (instance == null) {
      throw AssertionError(
        'Platform interfaces can only be set to a non-null instance',
      );
    }

    PlatformInterface.verify(instance, _token);
    _instance = instance;
  }

  /// /// Initializes the platform interface with [viewId].
  ///
  /// This method is called when the plugin is first initialized.
  Future<void> init(int viewId) {
    throw UnimplementedError('init() has not been implemented.');
  }

  /// Should be called when the widget disposes.
  Future<void> dispose({required int viewId}) {
    throw UnimplementedError('dispose() has not been implemented.');
  }

  /// Returns the number of pages  for the PDF.
  Future<int> getPageCount({required int viewId}) {
    throw UnimplementedError('getPageCount() has not been implemented.');
  }

  /// Returns the current page that is shown.
  Future<int> getCurrentPage({required int viewId}) {
    throw UnimplementedError('getCurrentPage() has not been implemented.');
  }

  /// Jumping to the given [page].
  Future<bool> setPage({
    required int page,
    required int viewId,
    required bool withAnimation,
  }) {
    throw UnimplementedError('setPage() has not been implemented.');
  }

  /// Goes to the next page.
  Future<bool> goToNextPage({
    required int viewId,
    required bool withAnimation,
  }) {
    throw UnimplementedError('goToNextPage() has not been implemented.');
  }

  /// Goes to the previous page.
  Future<bool> goToPreviousPage({
    required int viewId,
    required bool withAnimation,
  }) {
    throw UnimplementedError('goToPreviousPage() has not been implemented.');
  }

  /// Setting the scale factor to the default zoom factor.
  Future<void> resetZoom({required int viewId}) {
    throw UnimplementedError('resetZoom() has not been implemented.');
  }

  /// Zooming to the given [zoom].
  Future<void> setZoom({
    required int viewId,
    required double zoom,
  }) {
    throw UnimplementedError('setZoom() has not been implemented.');
  }

  /// Returns the current zoom value.
  Future<double> getZoom({required int viewId}) {
    throw UnimplementedError('getZoom() has not been implemented.');
  }

  /// Returns the size of the given [page] index.
  Future<Size> getPageSize({
    required int page,
    required int viewId,
  }) {
    throw UnimplementedError('getPageSize() has not been implemented.');
  }

  /// Notifies the current [orientation].
  Future<void> setOrientation({
    required Orientation orientation,
    required Map<String, dynamic> creationParams,
    required int viewId,
  }) {
    throw UnimplementedError('setOrientation() has not been implemented.');
  }

  /// Updating bytes for the native PDF View.
  Future<void> updateBytes({
    required Map<String, dynamic> creationParams,
    required int viewId,
  }) {
    throw UnimplementedError(
      'updateBytes() has not been implemented.',
    );
  }

  /// Updating fitPolicy for the native PDF View.
  Future<void> updateFitPolicy({
    required Map<String, dynamic> creationParams,
    required int viewId,
  }) {
    throw UnimplementedError(
      'updateFitPolicy() has not been implemented.',
    );
  }

  /// Updating scrollbar for the native PDF View.
  Future<void> updateScrollbar({
    required Map<String, dynamic> creationParams,
    required int viewId,
  }) {
    throw UnimplementedError(
      'updateScrollbar() has not been implemented.',
    );
  }

  /// Returns a widget displaying pdf view.
  Widget buildView({
    required AlhPdfViewCreationParams creationParams,
    required WidgetConfiguration widgetConfiguration,
  }) {
    throw UnimplementedError('buildView() has not been implemented.');
  }

  ///
  /// handlePlatformViewCreated methods
  ///
  ///

  Stream<OnRenderEvent> onRender({required int viewId}) {
    throw UnimplementedError('onRender() has not been implemented.');
  }

  Stream<OnPageChangedEvent> onPageChanged({required int viewId}) {
    throw UnimplementedError('onPageChanged() has not been implemented.');
  }

  Stream<OnErrorEvent> onError({required int viewId}) {
    throw UnimplementedError('onError() has not been implemented.');
  }

  Stream<OnZoomChangedEvent> onZoomChanged({required int viewId}) {
    throw UnimplementedError('onZoomChanged() has not been implemented.');
  }

  Stream<OnLinkHandleEvent> onLinkHandle({required int viewId}) {
    throw UnimplementedError('onLinkHandle() has not been implemented.');
  }

  Stream<OnTapEvent> onTap({required int viewId}) {
    throw UnimplementedError('onTap() has not been implemented.');
  }
}
