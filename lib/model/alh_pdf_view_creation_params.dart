import 'dart:typed_data';

import 'package:alh_pdf_view/model/fit_policy.dart';
import 'package:flutter/cupertino.dart';

/// These params are added for the native views.
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

  final bool pageSnap; // only: Android
  final bool fitEachPage; // only: Android
  final bool nightMode; // only: Android
  final bool autoSpacing; // only: Android
  final bool enableDoubleTap; // only: Android
  final bool enableDefaultScrollHandle; // only: Android

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
    required this.pageSnap,
    required this.defaultPage,
    required this.defaultZoomFactor,
    required this.backgroundColor,
    required this.password,
    required this.enableDoubleTap,
    required this.minZoom,
    required this.maxZoom,
    required this.enableDefaultScrollHandle,
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
        'pageSnap': this.pageSnap,
        'defaultPage': this.defaultPage,
        'defaultZoomFactor': this.defaultZoomFactor,
        'backgroundColor': this.backgroundColor.value,
        'password': this.password,
        'enableDoubleTap': this.enableDoubleTap,
        'minZoom': this.minZoom,
        'maxZoom': this.maxZoom,
        'enableDefaultScrollHandle': this.enableDefaultScrollHandle,
        'hasOnLinkHandle': this.hasOnLinkHandle,
      };
}
