import 'package:alh_pdf_view/controller/alh_pdf_internal_controller.dart';
import 'package:alh_pdf_view/controller/alh_pdf_view_controller.dart';
import 'package:alh_pdf_view/model/alh_pdf_view_creation_params.dart';
import 'package:alh_pdf_view/model/fit_policy.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
  /// The fitPolicy is also updated after rotating the screen.
  /// On Android, the PDF view will be rebuilt and
  /// on iOS the scaleFactor to fit is recalculated.
  ///
  /// Default value: [FitPolicy.both].
  final FitPolicy fitPolicy;

  /// The current page will be changed when swiping.
  ///
  /// Default value: true
  final bool enableSwipe;

  /// If true, all pages are displayed in horizontal direction.
  ///
  /// Default value: false
  final bool swipeHorizontal;

  /// Making a fling change.
  ///
  /// Default value: true
  final bool pageFling;

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

  /// Min zoom value that the user can reach.
  ///
  /// Default value: 0.5
  final double minZoom;

  /// Max zoom value that the user can reach.
  ///
  /// Default value: 4.0
  final double maxZoom;

  /// Each page of the PDF will fit inside the given space.
  ///
  /// Working only for Android.
  /// Default value: true
  final bool fitEachPage;

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

  /// Snap pages to screen boundaries when changing the current page.
  ///
  /// Working only for Android.
  /// Default value: true
  final bool pageSnap;

  /// When double tapping, the zoom of the page changes.
  ///
  /// Only working on Android. On iOS, the double tap cannot be disabled.
  /// Default value: true
  final bool enableDoubleTap;

  /// When enabled, you have an extra button to scroll faster.
  ///
  /// The button is similar to a scroll bar.
  /// On iOS, there is always a scrollbar that can be used to scroll faster.
  ///
  /// Only working on Android.
  /// Default value: false
  final bool enableDefaultScrollHandle;

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
    this.minZoom = 0.5,
    this.maxZoom = 4.0,
    this.enableDefaultScrollHandle = false,
    Key? key,
  })  : assert(filePath != null || bytes != null),
        assert(defaultZoomFactor > 0.0),
        assert(minZoom > 0),
        assert(maxZoom > 0),
        super(key: key);

  @override
  _AlhPdfViewState createState() => _AlhPdfViewState();
}

// ignore: prefer_mixin
class _AlhPdfViewState extends State<AlhPdfView> with WidgetsBindingObserver {
  static const _viewType = 'alh_pdf_view';

  AlhPdfInternalController? _alhPdfInternalController;
  AlhPdfViewController? _alhPdfViewController;
  late double _zoom;

  @override
  void initState() {
    super.initState();

    _zoom = widget.defaultZoomFactor;
    _ambiguate(WidgetsBinding.instance)!.addObserver(this);
  }

  @override
  void didUpdateWidget(covariant AlhPdfView oldWidget) {
    if (widget != oldWidget) {
      _alhPdfInternalController?.updateCreationParams(
        creationParams: _creationParams.toMap(),
      );
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeMetrics() {
    final orientationBefore = MediaQuery.of(context).orientation;
    _ambiguate(WidgetsBinding.instance)!.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final orientationAfter = MediaQuery.of(context).orientation;

      // Fixing the bug having a white screen on Android
      // Calling a native method that reloads the PDF
      // This prevents reloading the whole widget, because on iOS it works
      if (orientationBefore != orientationAfter) {
        _handleRotationChanged(orientation: orientationAfter);
      }
    });
  }

  @override
  void dispose() {
    _ambiguate(WidgetsBinding.instance)!.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final alhPdfViewCreationParamsMap = _creationParams.toMap();

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return Listener(
          onPointerUp: (PointerUpEvent event) async {
            final onZoomChanged = widget.onZoomChanged;
            final alhPdfViewController = _alhPdfViewController;

            if (this.mounted &&
                onZoomChanged != null &&
                alhPdfViewController != null) {
              final newZoom = await alhPdfViewController.getZoom();

              if (newZoom != _zoom) {
                onZoomChanged(newZoom);
                _zoom = newZoom;
              }
            }
          },
          child: PlatformViewLink(
            viewType: _viewType,
            surfaceFactory: (
              BuildContext context,
              PlatformViewController controller,
            ) {
              return AndroidViewSurface(
                controller: controller as AndroidViewController,
                gestureRecognizers: widget.gestureRecognizers ??
                    const <Factory<OneSequenceGestureRecognizer>>{},
                hitTestBehavior: PlatformViewHitTestBehavior.opaque,
              );
            },
            onCreatePlatformView: (PlatformViewCreationParams params) {
              return PlatformViewsService.initSurfaceAndroidView(
                id: params.id,
                viewType: _viewType,
                layoutDirection: TextDirection.ltr,
                creationParams: alhPdfViewCreationParamsMap,
                creationParamsCodec: const StandardMessageCodec(),
                onFocus: () {
                  params.onFocusChanged(true);
                },
              )
                ..addOnPlatformViewCreatedListener(params.onPlatformViewCreated)
                ..addOnPlatformViewCreatedListener(_onPlatformViewCreated)
                ..create();
            },
          ),
        );
      case TargetPlatform.iOS:
        return UiKitView(
          viewType: _viewType,
          onPlatformViewCreated: _onPlatformViewCreated,
          gestureRecognizers: widget.gestureRecognizers,
          creationParams: alhPdfViewCreationParamsMap,
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
    final alhPdfViewController = AlhPdfViewController(
      id: id,
      onError: widget.onError,
      onPageChanged: widget.onPageChanged,
      onPageError: widget.onPageError,
      onRender: widget.onRender,
      onZoomChanged: widget.onZoomChanged,
    );
    _alhPdfInternalController = AlhPdfInternalController(id: id);
    _alhPdfViewController = alhPdfViewController;

    _handleRotationChanged(orientation: MediaQuery.of(context).orientation);

    widget.onViewCreated?.call(alhPdfViewController);
  }

  /// Calling setOrientation of [_alhPdfInternalController] for rebuilding this widget.
  ///
  /// On Android, there is a problem when the rotation changes. It results
  /// to a white screen. To prevent that, this widget rebuilds the PDF view
  /// with all current params.
  /// This postFrameCallBack is necessary to ensure that the rebuild was finished
  /// before the native part can calculate the FitPolicy for the PDF.
  void _handleRotationChanged({required Orientation orientation}) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      _alhPdfInternalController?.setOrientation(
        orientation: orientation,
        creationParams: _creationParams.toMap(),
      );
    }
  }

  AlhPdfViewCreationParams get _creationParams => AlhPdfViewCreationParams(
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
        minZoom: widget.minZoom,
        maxZoom: widget.maxZoom,
        enableDefaultScrollHandle: widget.enableDefaultScrollHandle,
      );
}

/// This allows a value of type T or T?
/// to be treated as a value of type T?.
///
/// We use this so that APIs that have become
/// non-nullable can still be used with `!` and `?`
/// to support older versions of the API as well.
T? _ambiguate<T>(T? value) => value;
