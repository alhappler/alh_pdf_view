import 'dart:async';
import 'dart:typed_data';

import 'package:alh_pdf_view/controller/alh_pdf_view_controller.dart';
import 'package:alh_pdf_view/model/alh_pdf_view_creation_params.dart';
import 'package:alh_pdf_view/model/fit_policy.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef PDFViewCreatedCallback = void Function(AlhPdfViewController controller);
typedef RenderCallback = void Function(int pages);
typedef PageChangedCallback = void Function(int page, int total);
typedef ZoomChangedCallback = void Function(double zoom);
typedef ErrorCallback = void Function(dynamic error);
typedef PageErrorCallback = void Function(int page, dynamic error);

/// Showing PDF with given [filePath] or [bytes].
class AlhPdfView extends StatefulWidget {
  /// Loading the file with the given [filePath].
  ///
  /// If [bytes] and [filePath] is added, then the path will be used.
  final String? filePath;

  /// Loading the pdf with the given [bytes].
  ///
  /// Using [bytes] only if [filePath] is null.
  final Uint8List? bytes;

  /// Defines how the PDF should fit inside the widget.
  ///
  /// Default value: [FitPolicy.both].
  final FitPolicy fitPolicy;

  /// Each page of the PDF will fit inside the given space.
  ///
  /// Working only for Android.
  /// Default value: true
  final bool fitEachPage;

  /// The current page will be changed when swiping.
  ///
  /// Default value: true
  final bool enableSwipe;

  /// If true, all pages are displayed in horizontal direction.
  ///
  /// Default value: false
  final bool swipeHorizontal;

  /// Inverting colors of pages to have the look of a dark mode.
  ///
  /// Working only for Android.
  /// Default value: false
  final bool nightMode;

  /// If true, spacing will be added to fit each page on its own on the screen.
  ///
  /// Working only for Android.
  /// Default value: true
  final bool autoSpacing;

  /// Making a fling change.
  ///
  /// Default value: true
  final bool pageFling;

  /// Snap pages to screen boundaries when changing the current page.
  ///
  /// Working only for Android.
  /// Default value: true
  final bool pageSnap;

  /// Describes which page should be shown at first.
  ///
  /// Default value: 0
  final int defaultPage;

  /// Defines how much the displayed PDF page should zoomed when rendered.
  ///
  /// Default value: 1.0
  final double defaultZoomFactor;

  /// Setting backgroundColor of remaining space around the pdf view.
  ///
  /// Default value: [Colors.transparent]
  final Color backgroundColor;

  /// Unlocks PDF page with given [password].
  ///
  /// Default value: ''
  final String password;

  /// When double tapping, the zoom of the page changes.
  ///
  /// Only working on Android. On iOS, the double tap cannot be disabled.
  /// Default value: true
  final bool enableDoubleTap;

  /// Which gestures should be consumed by the pdf view.
  ///
  /// It is possible for other gesture recognizers to be competing with the pdf view on pointer
  /// events, e.g if the pdf view is inside a [ListView] the [ListView] will want to handle
  /// vertical drags. The pdf view will claim gestures that are recognized by any of the
  /// recognizers on this list.
  ///
  /// When this set is empty or null, the pdf view will only handle pointer events for gestures that
  /// were not claimed by any other gesture recognizer.
  final Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers;

  /// If not null invoked once the native view is created.
  final PDFViewCreatedCallback? onViewCreated;

  /// Callback once the PDF page was loaded.
  final RenderCallback? onRender;

  /// When changing the page, this method will be called with the new page.
  final PageChangedCallback? onPageChanged;

  /// Called when changing the zoom.
  ///
  /// This callback works only for iOS.
  final ZoomChangedCallback? onZoomChanged;

  /// When there are errors happening, this methods returns a message.
  final ErrorCallback? onError;

  /// Called when there are specific errors on a page.
  ///
  /// This callback works only for Android.
  final PageErrorCallback? onPageError;

  const AlhPdfView({
    this.filePath,
    this.bytes,
    this.onViewCreated,
    this.onRender,
    this.onPageChanged,
    this.onError,
    this.onPageError,
    this.onZoomChanged,
    this.gestureRecognizers,
    this.fitPolicy = FitPolicy.both,
    this.fitEachPage = true,
    this.enableSwipe = true,
    this.swipeHorizontal = false,
    this.password = '',
    this.nightMode = false,
    this.autoSpacing = true,
    this.pageFling = true,
    this.pageSnap = true,
    this.defaultPage = 0,
    this.backgroundColor = Colors.transparent,
    this.defaultZoomFactor = 1.0,
    this.enableDoubleTap = true,
    Key? key,
  })  : assert(filePath != null || bytes != null),
        assert(defaultZoomFactor > 0.0),
        super(key: key);

  @override
  _AlhPdfViewState createState() => _AlhPdfViewState();
}

class _AlhPdfViewState extends State<AlhPdfView> {
  static const _viewType = 'alh_pdf_view';

  final _controller = Completer<AlhPdfViewController>();

  @override
  Widget build(BuildContext context) {
    final alhPdfViewCreationParams = AlhPdfViewCreationParams(
      autoSpacing: widget.autoSpacing,
      backgroundColor: widget.backgroundColor,
      bytes: widget.bytes,
      defaultPage: widget.defaultPage,
      defaultZoomFactor: widget.defaultZoomFactor,
      enableSwipe: widget.enableSwipe,
      filePath: widget.filePath,
      fitEachPage: widget.fitEachPage,
      fitPolicy: widget.fitPolicy,
      nightMode: widget.nightMode,
      pageFling: widget.pageFling,
      pageSnap: widget.pageSnap,
      password: widget.password,
      swipeHorizontal: widget.swipeHorizontal,
      enableDoubleTap: widget.enableDoubleTap,
    );

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return AndroidView(
          viewType: _viewType,
          onPlatformViewCreated: _onPlatformViewCreated,
          gestureRecognizers: widget.gestureRecognizers,
          creationParams: alhPdfViewCreationParams.toMap(),
          creationParamsCodec: const StandardMessageCodec(),
        );
      case TargetPlatform.iOS:
        return UiKitView(
          viewType: _viewType,
          onPlatformViewCreated: _onPlatformViewCreated,
          gestureRecognizers: widget.gestureRecognizers,
          creationParams: alhPdfViewCreationParams.toMap(),
          creationParamsCodec: const StandardMessageCodec(),
        );
      default:
        throw Exception(
          'Platform $defaultTargetPlatform is currently not supported!',
        );
    }
  }

  /// Creates new [AlhPdfViewController] that depends on [id].
  ///
  /// Callback after native view was created.
  void _onPlatformViewCreated(int id) {
    final controller = AlhPdfViewController(
      id: id,
      onError: widget.onError,
      onPageChanged: widget.onPageChanged,
      onPageError: widget.onPageError,
      onRender: widget.onRender,
      onZoomChanged: widget.onZoomChanged,
    );
    _controller.complete(controller);

    if (widget.onViewCreated != null) {
      widget.onViewCreated!(controller);
    }
  }
}
