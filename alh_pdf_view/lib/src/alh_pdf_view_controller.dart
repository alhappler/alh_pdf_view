part of '../alh_pdf_view.dart';

class AlhPdfViewController {
  final int viewId;
  final RenderCallback? _onRender;
  final PageChangedCallback? _onPageChanged;
  final ErrorCallback? _onError;
  final ZoomChangedCallback? _onZoomChanged;
  final LinkHandleCallback? _onLinkHandle;
  final VoidCallback? _onTap;

  StreamSubscription<OnRenderEvent>? _onRenderSubscription;
  StreamSubscription<OnPageChangedEvent>? _onPageChangedSubscription;
  StreamSubscription<OnErrorEvent>? _onErrorSubscription;
  StreamSubscription<OnZoomChangedEvent>? _onZoomChangedSubscription;
  StreamSubscription<OnLinkHandleEvent>? _onLinkHandleSubscription;
  StreamSubscription<OnTapEvent>? _onTapSubscription;

  AlhPdfViewController._({
    required this.viewId,
    required RenderCallback? onRender,
    required PageChangedCallback? onPageChanged,
    required ErrorCallback? onError,
    required ZoomChangedCallback? onZoomChanged,
    required LinkHandleCallback? onLinkHandle,
    required VoidCallback? onTap,
  })  : _onRender = onRender,
        _onPageChanged = onPageChanged,
        _onError = onError,
        _onZoomChanged = onZoomChanged,
        _onLinkHandle = onLinkHandle,
        _onTap = onTap {
    this._connectStreams();
  }

  /// Initialize control of a [AlhPdfView] with [viewId].
  static Future<AlhPdfViewController> init({
    required int viewId,
    required RenderCallback? onRender,
    required PageChangedCallback? onPageChanged,
    required ErrorCallback? onError,
    required ZoomChangedCallback? onZoomChanged,
    required LinkHandleCallback? onLinkHandle,
    required VoidCallback? onTap,
  }) async {
    // Before initializing AlhPdfViewPlatform, create this controller first
    // to ensure that all streams can listen to every upcoming event.
    final controller = AlhPdfViewController._(
      viewId: viewId,
      onRender: onRender,
      onPageChanged: onPageChanged,
      onError: onError,
      onZoomChanged: onZoomChanged,
      onLinkHandle: onLinkHandle,
      onTap: onTap,
    );
    await AlhPdfViewPlatform.instance!.init(viewId);

    return controller;
  }

  AlhPdfViewPlatform get _instance => AlhPdfViewPlatform.instance!;

  void _connectStreams() {
    if (this._onRender != null) {
      this._onRenderSubscription =
          this._instance.onRender(viewId: viewId).listen((event) {
        this._onRender(event.value);
      });
    }
    if (this._onPageChanged != null) {
      this._onPageChangedSubscription =
          this._instance.onPageChanged(viewId: viewId).listen((event) {
        this._onPageChanged(event.value.page, event.value.total);
      });
    }
    if (this._onError != null) {
      this._onErrorSubscription =
          this._instance.onError(viewId: viewId).listen((event) {
        this._onError(event.value);
      });
    }
    if (this._onZoomChanged != null) {
      this._onZoomChangedSubscription =
          this._instance.onZoomChanged(viewId: viewId).listen((event) {
        this._onZoomChanged(event.value);
      });
    }
    if (this._onLinkHandle != null) {
      this._onLinkHandleSubscription =
          this._instance.onLinkHandle(viewId: viewId).listen((event) {
        this._onLinkHandle(event.value);
      });
    }
    if (this._onTap != null) {
      this._onTapSubscription =
          this._instance.onTap(viewId: viewId).listen((event) {
        this._onTap();
      });
    }
  }

  /// Returns the number of pages  for the PDF.
  Future<int> getPageCount() async {
    return this._instance.getPageCount(viewId: viewId);
  }

  /// Returns the current page that is shown.
  ///
  /// The page index begins at 0.
  Future<int> getCurrentPage() async {
    return this._instance.getCurrentPage(viewId: viewId);
  }

  /// Jumping to the given [page].
  ///
  /// By default, [withAnimation] is true and takes 400ms to animate the page change.
  /// Returns true if page change was possible.
  Future<bool> setPage({required int page, bool withAnimation = true}) async {
    return this._instance.setPage(
          page: page,
          withAnimation: withAnimation,
          viewId: viewId,
        );
  }

  /// Goes to the next page.
  ///
  /// By default, [withAnimation] is true and takes 400ms to animate the page change.
  /// Returns true if page change was possible.
  Future<bool> goToNextPage({bool withAnimation = true}) async {
    return this._instance.goToNextPage(
          viewId: viewId,
          withAnimation: withAnimation,
        );
  }

  /// Goes to the previous page.
  ///
  /// By default, [withAnimation] is true and takes 400ms to animate the page change.
  /// Returns true if page change was possible.
  Future<bool> goToPreviousPage({bool withAnimation = true}) async {
    return this._instance.goToPreviousPage(
          viewId: viewId,
          withAnimation: withAnimation,
        );
  }

  /// Setting the scale factor to the default zoom factor.
  Future<void> resetZoom() async {
    await this._instance.resetZoom(viewId: viewId);
  }

  /// Zooming to the given [zoom].
  ///
  /// By default, the zoom animation duration is 400 ms.
  Future<void> setZoom({required double zoom}) async {
    await this._instance.setZoom(viewId: viewId, zoom: zoom);
  }

  /// Returns the current zoom value.
  Future<double> getZoom() async {
    return this._instance.getZoom(viewId: viewId);
  }

  /// Returns the size of the given [page] index.
  ///
  /// Only working for iOS.
  Future<Size> getPageSize({required int page}) async {
    return this._instance.getPageSize(
          page: page,
          viewId: viewId,
        );
  }

  /// Notifies the current [orientation].
  ///
  /// This notification is handled by [AlhPdfView] and is important to make sure
  /// that the PDF is still displayed when changing the orientation. Otherwise
  /// a blank screen would be visible.
  ///
  /// For a short moment, the screen is white, when the device is rotated and redrawn.
  /// Only for Android.
  Future<void> setOrientation({
    required Orientation orientation,
    required Map<String, dynamic> creationParams,
  }) async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      await this._instance.setOrientation(
            orientation: orientation,
            creationParams: creationParams,
            viewId: viewId,
          );
    }
  }

  /// Updating values for the native PDF View.
  Future<void> updateCreationParams({
    required Map<String, dynamic> creationParams,
    required Map<String, dynamic> updatedParams,
  }) async {
    if (creationParams["bytes"] != updatedParams["bytes"] ||
        creationParams["filePath"] != updatedParams["filePath"]) {
      await this._instance.refreshPdf(
            creationParams: updatedParams,
            viewId: viewId,
          );
    }

    // fitPolicy and showScrollbar only necessary to update on iOS.
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      if (creationParams["fitPolicy"] != updatedParams["fitPolicy"]) {
        await this._instance.updateFitPolicy(
              creationParams: updatedParams,
              viewId: viewId,
            );
      }
      if (creationParams["showScrollbar"] != updatedParams["showScrollbar"]) {
        await this._instance.updateScrollbar(
              creationParams: updatedParams,
              viewId: viewId,
            );
      }
    }
  }

  /// Cancels all active stream subscriptions and calling platforms dispose.
  ///
  /// Currently the dispose call has only an effect on iOS to remove
  /// observers which are triggered if the user is zooming on the pdf.
  void dispose() {
    unawaited(this._onRenderSubscription?.cancel());
    unawaited(this._onPageChangedSubscription?.cancel());
    unawaited(this._onErrorSubscription?.cancel());
    unawaited(this._onZoomChangedSubscription?.cancel());
    unawaited(this._onLinkHandleSubscription?.cancel());
    unawaited(this._onTapSubscription?.cancel());

    unawaited(this._instance.dispose(viewId: this.viewId));
  }
}
