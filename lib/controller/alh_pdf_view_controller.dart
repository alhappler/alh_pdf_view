import 'package:alh_pdf_view/lib.dart';
import 'package:alh_pdf_view/view/alh_pdf_view.dart';
import 'package:flutter/services.dart';

/// Calling native methods that can change the current settings of the PDF.
class AlhPdfViewController {
  final RenderCallback? onRender;
  final PageChangedCallback? onPageChanged;
  final ErrorCallback? onError;
  final PageErrorCallback? onPageError;
  final ZoomChangedCallback? onZoomChanged;
  // ios only
  final LinkHandleCallback? onLinkHandle;

  late final MethodChannel _channel;

  AlhPdfViewController({
    required int id,
    required this.onRender,
    required this.onPageChanged,
    required this.onError,
    required this.onPageError,
    required this.onZoomChanged,
    required this.onLinkHandle,
  }) {
    _channel = MethodChannel('alh_pdf_view_$id');
    _channel.setMethodCallHandler(_onMethodCall);
  }

  Future<void> _onMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onRender':
        if (this.onRender != null) {
          this.onRender!(call.arguments['pages']);
        }
        break;
      case 'onPageChanged':
        if (this.onPageChanged != null) {
          this.onPageChanged!(
            call.arguments['page'],
            call.arguments['total'],
          );
        }
        break;
      case 'onError':
        if (this.onError != null) {
          this.onError!(call.arguments['error']);
        }
        break;
      case 'onPageError':
        if (this.onPageError != null) {
          this.onPageError!(
            call.arguments['page'],
            call.arguments['error'],
          );
        }
        break;
      case 'onZoomChanged':
        if (this.onZoomChanged != null) {
          this.onZoomChanged!(call.arguments['zoom']);
        }
        break;
      case 'onLinkHandle':
        if (this.onLinkHandle != null) {
          this.onLinkHandle!(call.arguments['url']);
        }
        break;
      default:
        throw MissingPluginException(
          '${call.method} was invoked but has no handler',
        );
    }
  }

  /// Returns the number of pages  for the PDF.
  Future<int> getPageCount() async {
    final int pageCount = await this._channel.invokeMethod('pageCount');
    return pageCount;
  }

  /// Returns the current page that is shown.
  ///
  /// The page index begins at 0.
  Future<int> getCurrentPage() async {
    final int currentPage = await this._channel.invokeMethod('currentPage');
    return currentPage;
  }

  /// Jumping to the given [page].
  ///
  /// By default, [withAnimation] is true and takes 400ms to animate the page change.
  /// Returns true if page change was possible.
  Future<bool> setPage({required int page, bool withAnimation = true}) async {
    return await this._channel.invokeMethod('setPage', <String, dynamic>{
      'page': page,
      'withAnimation': withAnimation,
    });
  }

  /// Goes to the next page.
  ///
  /// By default, [withAnimation] is true and takes 400ms to animate the page change.
  /// Returns true if page change was possible.
  Future<bool> goToNextPage({bool withAnimation = true}) async {
    return await this._channel.invokeMethod(
      'nextPage',
      {'withAnimation': withAnimation},
    );
  }

  /// Goes to the previous page.
  ///
  /// By default, [withAnimation] is true and takes 400ms to animate the page change.
  /// Returns true if page change was possible.
  Future<bool> goToPreviousPage({bool withAnimation = true}) async {
    return await this._channel.invokeMethod(
      'previousPage',
      {'withAnimation': withAnimation},
    );
  }

  /// Setting the scale factor to the default zoom factor.
  Future<void> resetZoom() async {
    await this._channel.invokeMethod('resetZoom');
  }

  /// Zooming to the given [zoom].
  ///
  /// By default, the zoom animation duration is 400 ms.
  Future<void> setZoom({required double zoom}) async {
    await this._channel.invokeMethod('setZoom', <String, dynamic>{
      'newZoom': zoom,
    });
  }

  /// Returns the current zoom value.
  Future<double> getZoom() async {
    final double zoom = await this._channel.invokeMethod('currentZoom');
    return zoom;
  }

  /// Returns the size of the given [page] index.
  ///
  /// Only working for iOS.
  Future<Size> getPageSize({required int page}) async {
    final sizeMap =
        await this._channel.invokeMethod('pageSize', {'page': page});
    return Size(sizeMap["width"], sizeMap["height"]);
  }
}
