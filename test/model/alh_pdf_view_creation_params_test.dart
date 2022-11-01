import 'dart:typed_data';

import 'package:alh_pdf_view/lib.dart';
import 'package:alh_pdf_view/model/alh_pdf_view_creation_params.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('#toMap', () {
    test(
        'GIVEN parameter for [AlhPdfViewCreationParams] '
        'WHEN calling #toMap '
        'THEN should return expected map', () {
      // given
      const givenFilePath = 'file path';
      final givenBytes = Uint8List(10);
      const givenFitPolicy = FitPolicy.width;
      const givenFitEachPage = false;
      const givenEnableSwipe = true;
      const givenSwipeHorizontal = false;
      const givenNightMode = true;
      const givenAutoSpacing = false;
      const givenPageFling = true;
      const givenPageSnap = false;
      const givenDefaultPage = 10;
      const givenDefaultZoomFactor = 5.0;
      const givenBackgroundColor = Colors.blue;
      const givenPassword = 'password';
      const givenEnableDoubleTap = true;
      const givenMinZoom = 0.1;
      const givenMaxZoom = 5.0;
      const givenEnableDefaultScrollHandle = true;
      const givenHasOnLinkHandle = false;
      final givenAlhPdfViewCreationParams = AlhPdfViewCreationParams(
        filePath: givenFilePath,
        bytes: givenBytes,
        fitPolicy: givenFitPolicy,
        fitEachPage: givenFitEachPage,
        enableSwipe: givenEnableSwipe,
        swipeHorizontal: givenSwipeHorizontal,
        nightMode: givenNightMode,
        autoSpacing: givenAutoSpacing,
        pageFling: givenPageFling,
        pageSnap: givenPageSnap,
        defaultPage: givenDefaultPage,
        defaultZoomFactor: givenDefaultZoomFactor,
        backgroundColor: givenBackgroundColor,
        password: givenPassword,
        enableDoubleTap: givenEnableDoubleTap,
        minZoom: givenMinZoom,
        maxZoom: givenMaxZoom,
        enableDefaultScrollHandle: givenEnableDefaultScrollHandle,
        hasOnLinkHandle: givenHasOnLinkHandle,
      );

      // when
      final actual = givenAlhPdfViewCreationParams.toMap();

      // then
      final expectedMap = {
        'filePath': givenFilePath,
        'bytes': givenBytes,
        'fitPolicy': givenFitPolicy.toString(),
        'fitEachPage': givenFitEachPage,
        'enableSwipe': givenEnableSwipe,
        'swipeHorizontal': givenSwipeHorizontal,
        'nightMode': givenNightMode,
        'autoSpacing': givenAutoSpacing,
        'pageFling': givenPageFling,
        'pageSnap': givenPageSnap,
        'defaultPage': givenDefaultPage,
        'defaultZoomFactor': givenDefaultZoomFactor,
        'backgroundColor': givenBackgroundColor.value,
        'password': givenPassword,
        'enableDoubleTap': givenEnableDoubleTap,
        'minZoom': givenMinZoom,
        'maxZoom': givenMaxZoom,
        'enableDefaultScrollHandle': givenEnableDefaultScrollHandle,
        'hasOnLinkHandle': givenHasOnLinkHandle,
      };
      expect(actual, equals(expectedMap));
    });
  });
}
