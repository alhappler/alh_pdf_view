import 'dart:typed_data';

import 'package:alh_pdf_view/lib.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../services/fake_platform_views.dart';
import '../services/utils.dart';

void main() {
  group('Throws Errors', () {
    testWidgets(
        "GIVEN no bytes and no filePath "
        "WHEN pumping [AlhPdfView] "
        "THEN should throw [AssertionError]", (WidgetTester tester) async {
      // given

      // when
      Future<void> pumpWidget() => tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: AlhPdfView(),
              ),
            ),
          );

      // then
      expect(pumpWidget, throwsAssertionError);
    });

    testWidgets(
        "GIVEN bytes and defaultZoomFactor < 0 "
        "WHEN pumping [AlhPdfView] "
        "THEN should throw [AssertionError]", (WidgetTester tester) async {
      // given

      // when
      Future<void> pumpWidget() => tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: AlhPdfView(
                  bytes: Uint8List(10),
                  defaultZoomFactor: -1.0,
                ),
              ),
            ),
          );

      // then
      expect(pumpWidget, throwsAssertionError);
    });
  });

  testWidgets(
      "GIVEN platform == TargetPlatform.iOS, filePath and no other parameters "
      "WHEN pumping [AlhPdfView] "
      "THEN should have expected default parameters and "
      "should show [UiKitView] with expected creationParams",
      (WidgetTester tester) async {
    // given
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

    const givenFilePath = 'path';

    // when
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AlhPdfView(
            filePath: givenFilePath,
          ),
        ),
      ),
    );

    // then
    expect(
        find.byWidgetPredicate((widget) =>
            widget is AlhPdfView &&
            widget.filePath == givenFilePath &&
            widget.bytes == null &&
            widget.fitPolicy == FitPolicy.both &&
            widget.fitEachPage &&
            widget.enableSwipe &&
            widget.password.isEmpty &&
            !widget.nightMode &&
            widget.autoSpacing &&
            widget.pageFling &&
            widget.pageSnap &&
            widget.defaultPage == 0 &&
            widget.backgroundColor == Colors.transparent &&
            widget.defaultZoomFactor == 1.0 &&
            widget.enableDoubleTap),
        findsOneWidget);
    expect(
        find.byWidgetPredicate((widget) =>
            widget is UiKitView &&
            widget.creationParams['filePath'] == givenFilePath &&
            widget.creationParams['bytes'] == null &&
            widget.creationParams['fitPolicy'] == FitPolicy.both.toString() &&
            widget.creationParams['fitEachPage'] &&
            widget.creationParams['enableSwipe'] &&
            !widget.creationParams['swipeHorizontal'] &&
            !widget.creationParams['nightMode'] &&
            widget.creationParams['autoSpacing'] &&
            widget.creationParams['pageFling'] &&
            widget.creationParams['pageSnap'] &&
            widget.creationParams['defaultPage'] == 0 &&
            widget.creationParams['defaultZoomFactor'] == 1.0 &&
            widget.creationParams['backgroundColor'] ==
                Colors.transparent.value &&
            widget.creationParams['password'] == '' &&
            widget.creationParams['enableDoubleTap']),
        findsOneWidget);

    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets(
      "GIVEN platform == TargetPlatform.android, bytes and all parameters "
      "WHEN pumping [AlhPdfView] "
      "THEN should show [AndroidView] with expected creationParams",
      (WidgetTester tester) async {
    // given
    debugDefaultTargetPlatformOverride = TargetPlatform.android;

    final givenBytes = Uint8List(9);
    const givenFilePath = 'path';
    const givenDefaultZoomFactor = 200.0;
    const givenPassword = 'password secret';
    const givenFitPolicy = FitPolicy.height;
    const givenDefaultPage = 99;
    const givenBackgroundColor = Colors.blue;

    // when
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AlhPdfView(
            filePath: givenFilePath,
            bytes: givenBytes,
            defaultZoomFactor: givenDefaultZoomFactor,
            enableDoubleTap: false,
            swipeHorizontal: true,
            password: givenPassword,
            nightMode: true,
            pageSnap: false,
            pageFling: false,
            fitPolicy: givenFitPolicy,
            enableSwipe: false,
            fitEachPage: false,
            defaultPage: givenDefaultPage,
            backgroundColor: givenBackgroundColor,
            autoSpacing: false,
          ),
        ),
      ),
    );

    // then
    expect(
        find.byWidgetPredicate((widget) =>
            widget is AndroidView &&
            widget.creationParams['filePath'] == givenFilePath &&
            widget.creationParams['bytes'] == givenBytes &&
            widget.creationParams['fitPolicy'] == givenFitPolicy.toString() &&
            !widget.creationParams['fitEachPage'] &&
            !widget.creationParams['enableSwipe'] &&
            widget.creationParams['swipeHorizontal'] &&
            widget.creationParams['nightMode'] &&
            !widget.creationParams['autoSpacing'] &&
            !widget.creationParams['pageFling'] &&
            !widget.creationParams['pageSnap'] &&
            widget.creationParams['defaultPage'] == givenDefaultPage &&
            widget.creationParams['defaultZoomFactor'] ==
                givenDefaultZoomFactor &&
            widget.creationParams['backgroundColor'] ==
                givenBackgroundColor.value &&
            widget.creationParams['password'] == givenPassword &&
            !widget.creationParams['enableDoubleTap']),
        findsOneWidget);

    debugDefaultTargetPlatformOverride = null;
  });

  group('Platform = .iOS and invoking method calls', () {
    Future<void> pumpWidget(
      WidgetTester tester, {
      PDFViewCreatedCallback? onViewCreated,
      ErrorCallback? onError,
      RenderCallback? onRender,
      PageChangedCallback? onPageChanged,
      PageErrorCallback? onPageError,
      ZoomChangedCallback? onZoomChanged,
    }) =>
        tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AlhPdfView(
                filePath: 'path',
                onViewCreated: onViewCreated,
                onError: onError,
                onRender: onRender,
                onPageChanged: onPageChanged,
                onPageError: onPageError,
                onZoomChanged: onZoomChanged,
              ),
            ),
          ),
        );

    testWidgets(
        "GIVEN platform = .iOS, path and [AlhPdfView] "
        "WHEN pumping finished "
        "THEN should call #onViewCreated", (WidgetTester tester) async {
      // given
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

      AlhPdfViewController? actualController;

      final viewsController = FakeIosPlatformViewsController();
      viewsController.registerViewType('alh_pdf_view');

      // when
      await pumpWidget(
        tester,
        onViewCreated: (controller) {
          actualController = controller;
        },
      );
      await tester.pumpAndSettle();

      // then
      expect(actualController, isNotNull);

      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets(
        "GIVEN platform = .iOS, path and [AlhPdfView] "
        "WHEN invoking onError "
        "THEN should call #onError with given error",
        (WidgetTester tester) async {
      // given
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

      const givenError = 'error 123';
      dynamic actualError;

      final viewsController = FakeIosPlatformViewsController();
      viewsController.registerViewType('alh_pdf_view');

      await pumpWidget(
        tester,
        onError: (error) {
          actualError = error;
        },
      );
      final viewId = viewsController.views.first.id;

      // when
      await invokeMethodCall(
        const MethodCall('onError', {'error': givenError}),
        channelName: 'alh_pdf_view_$viewId',
      );

      // then
      expect(actualError, equals(givenError));

      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets(
        "GIVEN platform = .iOS, path and [AlhPdfView] "
        "WHEN invoking onRender "
        "THEN should call #onRender with given pages",
        (WidgetTester tester) async {
      // given
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

      const givenPages = 9999;
      int? actualPages;

      final viewsController = FakeIosPlatformViewsController();
      viewsController.registerViewType('alh_pdf_view');

      await pumpWidget(
        tester,
        onRender: (pages) {
          actualPages = pages;
        },
      );
      final viewId = viewsController.views.first.id;

      // when
      await invokeMethodCall(
        const MethodCall('onRender', {'pages': givenPages}),
        channelName: 'alh_pdf_view_$viewId',
      );

      // then
      expect(actualPages, equals(givenPages));

      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets(
        "GIVEN platform = .iOS, path and [AlhPdfView] "
        "WHEN invoking onPageChanged "
        "THEN should call #onPageChanged with given page and total",
        (WidgetTester tester) async {
      // given
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

      const givenPage = 9;
      const givenTotal = 10;
      int? actualPage;
      int? actualTotal;

      final viewsController = FakeIosPlatformViewsController();
      viewsController.registerViewType('alh_pdf_view');

      await pumpWidget(
        tester,
        onPageChanged: (page, total) {
          actualPage = page;
          actualTotal = total;
        },
      );
      final viewId = viewsController.views.first.id;

      // when
      await invokeMethodCall(
        const MethodCall('onPageChanged', {
          'page': givenPage,
          'total': givenTotal,
        }),
        channelName: 'alh_pdf_view_$viewId',
      );

      // then
      expect(actualPage, equals(givenPage));
      expect(actualTotal, equals(givenTotal));

      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets(
        "GIVEN platform = .iOS, path and [AlhPdfView] "
        "WHEN invoking onPageError "
        "THEN should call #onPageError with given page and error",
        (WidgetTester tester) async {
      // given
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

      const givenPage = 9;
      const givenError = 'error aaaaaaaaa';
      int? actualPage;
      dynamic actualError;

      final viewsController = FakeIosPlatformViewsController();
      viewsController.registerViewType('alh_pdf_view');

      await pumpWidget(
        tester,
        onPageError: (page, error) {
          actualPage = page;
          actualError = error;
        },
      );
      final viewId = viewsController.views.first.id;

      // when
      await invokeMethodCall(
        const MethodCall('onPageError', {
          'page': givenPage,
          'error': givenError,
        }),
        channelName: 'alh_pdf_view_$viewId',
      );

      // then
      expect(actualPage, equals(givenPage));
      expect(actualError, equals(givenError));

      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets(
        "GIVEN platform = .iOS, path and [AlhPdfView] "
        "WHEN invoking onZoomChanged "
        "THEN should call #onZoomChanged with given zoom",
        (WidgetTester tester) async {
      // given
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

      const givenZoom = 234.4;
      double? actualZoom;

      final viewsController = FakeIosPlatformViewsController();
      viewsController.registerViewType('alh_pdf_view');

      await pumpWidget(
        tester,
        onZoomChanged: (zoom) {
          actualZoom = zoom;
        },
      );
      final viewId = viewsController.views.first.id;

      // when
      await invokeMethodCall(
        const MethodCall('onZoomChanged', {'zoom': givenZoom}),
        channelName: 'alh_pdf_view_$viewId',
      );

      // then
      expect(actualZoom, equals(givenZoom));

      debugDefaultTargetPlatformOverride = null;
    });
  });
}
