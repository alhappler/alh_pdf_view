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
        'filePath': this.filePath,
        'bytes': this.bytes,
        'fitPolicy': this.fitPolicy.toString(),
        'fitEachPage': this.fitEachPage,
        'enableSwipe': this.enableSwipe,
        'swipeHorizontal': this.swipeHorizontal,
        'nightMode': this.nightMode,
        'autoSpacing': this.autoSpacing,
        'pageFling': this.pageFling,
        'showScrollbar': this.showScrollbar,
        'pageSnap': this.pageSnap,
        'defaultPage': this.defaultPage,
        'defaultZoomFactor': this.defaultZoomFactor,
        'backgroundColor': this.backgroundColor.value,
        'password': this.password,
        'enableDoubleTap': this.enableDoubleTap,
        'minZoom': this.minZoom,
        'maxZoom': this.maxZoom,
        'enableDefaultScrollHandle': this.enableDefaultScrollHandle,
        'spacing': this.spacing,
        'hasOnLinkHandle': this.hasOnLinkHandle,
      };

  @override
  bool operator ==(Object other) =>
      other is AlhPdfViewCreationParams &&
      other.runtimeType == this.runtimeType &&
      other.filePath == this.filePath &&
      other.bytes == this.bytes &&
      other.fitPolicy == this.fitPolicy &&
      other.fitEachPage == this.fitEachPage &&
      other.enableSwipe == this.enableSwipe &&
      other.swipeHorizontal == this.swipeHorizontal &&
      other.nightMode == this.nightMode &&
      other.autoSpacing == this.autoSpacing &&
      other.pageFling == this.pageFling &&
      other.showScrollbar == this.showScrollbar &&
      other.pageSnap == this.pageSnap &&
      other.defaultPage == this.defaultPage &&
      other.defaultZoomFactor == this.defaultZoomFactor &&
      other.backgroundColor == this.backgroundColor &&
      other.password == this.password &&
      other.enableDoubleTap == this.enableDoubleTap &&
      other.minZoom == this.minZoom &&
      other.maxZoom == this.maxZoom &&
      other.enableDefaultScrollHandle == this.enableDefaultScrollHandle &&
      other.spacing == this.spacing &&
      other.hasOnLinkHandle == this.hasOnLinkHandle;

  @override
  int get hashCode => filePath.hashCode + bytes.hashCode;
}
