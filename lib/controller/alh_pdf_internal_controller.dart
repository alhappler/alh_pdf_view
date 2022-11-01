import 'package:alh_pdf_view/lib.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Should be used for general configurations for the native PDF.
///
/// This controller is not accessible outside this package.
class AlhPdfInternalController {
  late final MethodChannel _channel;

  AlhPdfInternalController({required int id}) {
    _channel = MethodChannel('alh_pdf_$id');
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
    await this._channel.invokeMethod('setOrientation', {
      'orientation': orientation.toString(),
      ...creationParams,
    });
  }

  /// Updating values for the native PDF View.
  ///
  /// Currently only for iOS when updating [FitPolicy].
  Future<void> updateCreationParams({
    required Map<String, dynamic> creationParams,
  }) async {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      await this._channel.invokeMethod('updateCreationParams', creationParams);
    }
  }

  Future<void> onLinkHandle({
    required String url,
  }) async {
    await this._channel.invokeListMethod('onLinkHandle', {
      'url': url,
    });
  }
}
