part of '../alh_pdf_view.dart';

typedef PDFViewCreatedCallback = void Function(AlhPdfViewController controller);

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

  /// Responsible to show the scrolling indicator (ScrollBar) inside the pdf view.
  ///
  /// Working only for iOS (use [enableDefaultScrollHandle] for Android)
  /// Default value: true
  final bool showScrollbar;

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
  /// Working only for Android (use [showScrollbar] for iOS)
  /// Default value: false
  final bool enableDefaultScrollHandle;

  /// Spacing between pdf pages.
  ///
  /// Android: Spacing is only between pages.
  /// iOS: Spacing is also on the last page to the bottom.
  ///
  /// Default value: 0
  final int spacing;

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

  /// Called when tapped a link in PDF.
  ///
  /// If this function is null, then the Browser will be opened
  ///
  /// This works only for iOS.
  final LinkHandleCallback? onLinkHandle;

  /// Called when tapped in PDF.
  final VoidCallback? onTap;

  const AlhPdfView({
    this.filePath,
    this.bytes,
    this.onViewCreated,
    this.onRender,
    this.onPageChanged,
    this.onError,
    this.onZoomChanged,
    this.gestureRecognizers,
    this.onLinkHandle,
    this.onTap,
    this.fitPolicy = FitPolicy.both,
    this.fitEachPage = true,
    this.enableSwipe = true,
    this.swipeHorizontal = false,
    this.password = '',
    this.nightMode = false,
    this.autoSpacing = true,
    this.pageFling = true,
    this.showScrollbar = true,
    this.pageSnap = true,
    this.defaultPage = 0,
    this.backgroundColor = Colors.transparent,
    this.defaultZoomFactor = 1.0,
    this.enableDoubleTap = true,
    this.minZoom = 0.5,
    this.maxZoom = 4.0,
    this.enableDefaultScrollHandle = false,
    this.spacing = 0,
    super.key,
  })  : assert(filePath != null || bytes != null),
        assert(defaultZoomFactor > 0.0),
        assert(minZoom > 0),
        assert(maxZoom > 0);

  @override
  _AlhPdfViewState createState() => _AlhPdfViewState();
}

class _AlhPdfViewState extends State<AlhPdfView> with WidgetsBindingObserver {
  AlhPdfViewController? _alhPdfViewController;
  late AlhPdfViewCreationParams _currentCreationParams;

  late double _zoom;

  @override
  void initState() {
    super.initState();

    this._currentCreationParams = this._creationParams;
    this._zoom = widget.defaultZoomFactor;
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didUpdateWidget(covariant AlhPdfView oldWidget) {
    if (this._currentCreationParams != this._creationParams) {
      unawaited(
        this._alhPdfViewController?.updateCreationParams(
              creationParams: this._currentCreationParams.toMap(),
              updatedParams: this._creationParams.toMap(),
            ),
      );
      this._currentCreationParams = this._creationParams;
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeMetrics() {
    final orientationBefore = MediaQuery.of(context).orientation;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final orientationAfter = MediaQuery.of(context).orientation;

      // Fixing the bug having a white screen on Android
      // Calling a native method that reloads the PDF
      // This prevents reloading the whole widget, because on iOS it works
      if (orientationBefore != orientationAfter) {
        unawaited(this._handleRotationChanged(orientation: orientationAfter));
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    this._alhPdfViewController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlhPdfViewPlatform.instance!.buildView(
      creationParams: this._creationParams,
      widgetConfiguration: WidgetConfiguration(
        onPlatformViewCreated: this._handlePlatformViewCreated,
        gestureRecognizers: this.widget.gestureRecognizers,
        // this callback only happens in android
        // to make the onZoomChangedCallback available
        onPointerUp: (PointerUpEvent event) async {
          final onZoomChanged = widget.onZoomChanged;
          final alhPdfViewController = this._alhPdfViewController;

          if (this.mounted &&
              onZoomChanged != null &&
              alhPdfViewController != null) {
            final newZoom = await alhPdfViewController.getZoom();

            if (newZoom != this._zoom) {
              onZoomChanged(newZoom);
              this._zoom = newZoom;
            }
          }
        },
      ),
    );
  }

  /// Creates new [AlhPdfViewController] that depends on [id].
  ///
  /// Callback after native view was created.
  Future<void> _handlePlatformViewCreated(int id) async {
    final orientation = MediaQuery.of(context).orientation;

    final alhPdfViewController = await AlhPdfViewController.init(
      viewId: id,
      onRender: this.widget.onRender,
      onPageChanged: this.widget.onPageChanged,
      onError: this.widget.onError,
      onZoomChanged: this.widget.onZoomChanged,
      onLinkHandle: this.widget.onLinkHandle,
      onTap: this.widget.onTap,
    );
    this._alhPdfViewController = alhPdfViewController;
    unawaited(this._handleRotationChanged(orientation: orientation));

    this.widget.onViewCreated?.call(alhPdfViewController);
  }

  /// Calling setOrientation of [_alhPdfViewController] for rebuilding this widget.
  ///
  /// On Android, there is a problem when the rotation changes. It results
  /// to a white screen. To prevent that, this widget rebuilds the PDF view
  /// with all current params.
  /// This postFrameCallBack is necessary to ensure that the rebuild was finished
  /// before the native part can calculate the FitPolicy for the PDF.
  Future<void> _handleRotationChanged({
    required Orientation orientation,
  }) async {
    await this._alhPdfViewController?.setOrientation(
          orientation: orientation,
          creationParams: this._creationParams.toMap(),
        );
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
        showScrollbar: widget.showScrollbar,
        pageSnap: widget.pageSnap,
        password: widget.password,
        swipeHorizontal: widget.swipeHorizontal,
        enableDoubleTap: widget.enableDoubleTap,
        minZoom: widget.minZoom,
        maxZoom: widget.maxZoom,
        enableDefaultScrollHandle: widget.enableDefaultScrollHandle,
        spacing: widget.spacing,
        hasOnLinkHandle: widget.onLinkHandle != null,
      );
}
