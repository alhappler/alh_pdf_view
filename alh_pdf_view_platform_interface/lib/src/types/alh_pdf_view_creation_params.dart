import 'dart:typed_data';

import 'package:alh_pdf_view_platform_interface/src/types/fit_policy.dart';
import 'package:flutter/cupertino.dart';

/// These params are added for the native views.
@immutable
class AlhPdfViewCreationParams {
  final String? filePath;
  final Uint8List? bytes;

  final FitPolicy fitPolicy;
  final bool enableSwipe;
  final bool swipeHorizontal;
  final bool pageFling;
  final int defaultPage;
  final double defaultZoomFactor;
  final Color backgroundColor;
  final String password;
  final double minZoom;
  final double maxZoom;

  final bool showScrollbar;

  final bool pageSnap; // only: Android
  final bool fitEachPage; // only: Android
  final bool nightMode; // only: Android
  final bool autoSpacing; // only: Android
  final bool enableDoubleTap; // only: Android
  final bool enableDefaultScrollHandle; // only: Android
  final int spacing;

  /// Flag to know if onLinkHandle is provided
  final bool hasOnLinkHandle;

  const AlhPdfViewCreationParams({
    required this.filePath,
    required this.bytes,
    required this.fitPolicy,
    required this.fitEachPage,
    required this.enableSwipe,
    required this.swipeHorizontal,
    required this.nightMode,
    required this.autoSpacing,
    required this.pageFling,
    required this.showScrollbar,
    required this.pageSnap,
    required this.defaultPage,
    required this.defaultZoomFactor,
    required this.backgroundColor,
    required this.password,
    required this.enableDoubleTap,
    required this.minZoom,
    required this.maxZoom,
    required this.enableDefaultScrollHandle,
    required this.spacing,
    required this.hasOnLinkHandle,
  });

  Map<String, dynamic> toMap() => {
        'filePath': filePath,
        'bytes': bytes,
        'fitPolicy': fitPolicy.toString(),
        'fitEachPage': fitEachPage,
        'enableSwipe': enableSwipe,
        'swipeHorizontal': swipeHorizontal,
        'nightMode': nightMode,
        'autoSpacing': autoSpacing,
        'pageFling': pageFling,
        'showScrollbar': showScrollbar,
        'pageSnap': pageSnap,
        'defaultPage': defaultPage,
        'defaultZoomFactor': defaultZoomFactor,
        // ignore: deprecated_member_use
        'backgroundColor': backgroundColor.value,
        'password': password,
        'enableDoubleTap': enableDoubleTap,
        'minZoom': minZoom,
        'maxZoom': maxZoom,
        'enableDefaultScrollHandle': enableDefaultScrollHandle,
        'spacing': spacing,
        'hasOnLinkHandle': hasOnLinkHandle,
      };

  @override
  bool operator ==(Object other) =>
      other is AlhPdfViewCreationParams &&
      other.runtimeType == runtimeType &&
      other.filePath == filePath &&
      other.bytes == bytes &&
      other.fitPolicy == fitPolicy &&
      other.fitEachPage == fitEachPage &&
      other.enableSwipe == enableSwipe &&
      other.swipeHorizontal == swipeHorizontal &&
      other.nightMode == nightMode &&
      other.autoSpacing == autoSpacing &&
      other.pageFling == pageFling &&
      other.showScrollbar == showScrollbar &&
      other.pageSnap == pageSnap &&
      other.defaultPage == defaultPage &&
      other.defaultZoomFactor == defaultZoomFactor &&
      other.backgroundColor == backgroundColor &&
      other.password == password &&
      other.enableDoubleTap == enableDoubleTap &&
      other.minZoom == minZoom &&
      other.maxZoom == maxZoom &&
      other.enableDefaultScrollHandle == enableDefaultScrollHandle &&
      other.spacing == spacing &&
      other.hasOnLinkHandle == hasOnLinkHandle;

  @override
  int get hashCode => filePath.hashCode + bytes.hashCode;
}
