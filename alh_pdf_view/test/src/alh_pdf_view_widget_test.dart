import 'dart:async';

import 'package:alh_pdf_view/alh_pdf_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../utils/fake_alh_pdf_view_platform.dart';
import '../utils/utils.dart';

void main() {
  late FakeAlhPdfViewPlatform fakeAlhPdfViewPlatform;

  const givenView = Placeholder();

  const givenFilePath = 'path';
  final expectedDefaultWidgetConfiguration = WidgetConfiguration(
    onPointerUp: (_) {},
    onPlatformViewCreated: (_) {},
    gestureRecognizers: null,
  );

  setUp(() {
    fakeAlhPdfViewPlatform = FakeAlhPdfViewPlatform();
    fakeAlhPdfViewPlatform.setUpBuildView(result: givenView);

    AlhPdfViewPlatform.instance = fakeAlhPdfViewPlatform;
  });

  tearDown(() {
    fakeAlhPdfViewPlatform.verifyNoMoreInteraction();
  });

  AlhPdfViewCreationParams getExpectedDefaultCreationParams({
    String? filePath,
    Uint8List? bytes,
    FitPolicy? fitPolicy,
  }) {
    return AlhPdfViewCreationParams(
      filePath: givenFilePath,
      bytes: null,
      fitPolicy: fitPolicy ?? FitPolicy.both,
      fitEachPage: true,
      enableSwipe: true,
      swipeHorizontal: false,
      nightMode: false,
      autoSpacing: true,
      pageFling: true,
      showScrollbar: true,
      pageSnap: true,
      defaultPage: 0,
      defaultZoomFactor: 1.0,
      backgroundColor: Colors.transparent,
      password: '',
      enableDoubleTap: true,
      minZoom: 0.5,
      maxZoom: 4.0,
      enableDefaultScrollHandle: false,
      spacing: 0,
      hasOnLinkHandle: false,
    );
  }

  group('Throws Errors', () {
    testWidgets(
        'GIVEN no bytes and no filePath '
        'WHEN pumping [AlhPdfView] '
        'THEN should throw [AssertionError]', (WidgetTester tester) async {
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
        'GIVEN bytes and defaultZoomFactor < 0 '
        'WHEN pumping [AlhPdfView] '
        'THEN should throw [AssertionError]', (WidgetTester tester) async {
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

    testWidgets(
        'GIVEN bytes and minZoom < 0 '
        'WHEN pumping [AlhPdfView] '
        'THEN should throw [AssertionError]', (WidgetTester tester) async {
      // given

      // when
      Future<void> pumpWidget() => tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: AlhPdfView(
                  bytes: Uint8List(10),
                  minZoom: -1.0,
                ),
              ),
            ),
          );

      // then
      expect(pumpWidget, throwsAssertionError);
    });

    testWidgets(
        'GIVEN bytes and maxZoom < 0 '
        'WHEN pumping [AlhPdfView] '
        'THEN should throw [AssertionError]', (WidgetTester tester) async {
      // given

      // when
      Future<void> pumpWidget() => tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: AlhPdfView(
                  bytes: Uint8List(10),
                  maxZoom: -1.0,
                ),
              ),
            ),
          );

      // then
      expect(pumpWidget, throwsAssertionError);
    });
  });

  group('platform == TargetPlatform.android', () {
    testWidgets(
        'GIVEN platform == TargetPlatform.android, filePath and no other parameters '
        'WHEN pumping [AlhPdfView] '
        'THEN should have expected default parameters and '
        'should show [UiKitView] with expected creationParams and '
        'should call setOrientation of [AlhPdfController]',
        (WidgetTester tester) async {
      // given

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
      await tester.pumpAndSettle();

      // then
      expect(
        find.byWidgetPredicate(
          (widget) =>
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
              widget.enableDoubleTap &&
              widget.minZoom == 0.5 &&
              widget.maxZoom == 4.0 &&
              !widget.enableDefaultScrollHandle &&
              widget.showScrollbar &&
              widget.spacing == 0,
        ),
        findsOneWidget,
      );
      fakeAlhPdfViewPlatform.verifyBuildView(
        creationParams: getExpectedDefaultCreationParams(),
        widgetConfiguration: expectedDefaultWidgetConfiguration,
      );
      fakeAlhPdfViewPlatform.verifySetOrientation(
        orientation: Orientation.landscape,
        creationParams: getExpectedDefaultCreationParams().toMap(),
      );

      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets(
        'GIVEN platform == TargetPlatform.android, [AlhPdfView] and orientation = portrait '
        'WHEN changing orientation '
        'THEN should call setRotation of [AlhPdfController]',
        (WidgetTester tester) async {
      // given
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      changeOrientation(tester, landscape: false);

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
      await tester.pumpAndSettle();

      changeOrientation(tester, landscape: true);
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      // then
      fakeAlhPdfViewPlatform.verifyBuildView(
        creationParams: getExpectedDefaultCreationParams(),
        widgetConfiguration: expectedDefaultWidgetConfiguration,
        called: 2,
      );
      fakeAlhPdfViewPlatform.verifySetOrientation(
        orientation: Orientation.landscape,
        creationParams: getExpectedDefaultCreationParams().toMap(),
        called: 3,
      );

      clearTestValues(tester);
      debugDefaultTargetPlatformOverride = null;
    });
  });

  group('platform == TargetPlatform.iOS', () {
    testWidgets(
        'GIVEN bytes and all parameters '
        'WHEN pumping [AlhPdfView] '
        'THEN should show [UiKitView] with expected creationParams',
        (WidgetTester tester) async {
      // given
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

      final givenBytes = Uint8List(9);
      const givenFilePath = 'path';
      const givenDefaultZoomFactor = 200.0;
      const givenPassword = 'password secret';
      const givenFitPolicy = FitPolicy.height;
      const givenDefaultPage = 99;
      const givenBackgroundColor = Colors.blue;
      const givenMinZoom = 0.04;
      const givenMaxZoom = 100.0;
      const givenSpacing = 12345;

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
              showScrollbar: false,
              minZoom: givenMinZoom,
              maxZoom: givenMaxZoom,
              spacing: givenSpacing,
              onLinkHandle: (_) {},
            ),
          ),
        ),
      );

      // then
      final expectedCreationParams = AlhPdfViewCreationParams(
        filePath: givenFilePath,
        bytes: givenBytes,
        fitPolicy: givenFitPolicy,
        fitEachPage: false,
        enableSwipe: false,
        swipeHorizontal: true,
        nightMode: true,
        autoSpacing: false,
        pageFling: false,
        showScrollbar: false,
        pageSnap: false,
        defaultPage: givenDefaultPage,
        defaultZoomFactor: givenDefaultZoomFactor,
        backgroundColor: givenBackgroundColor,
        password: givenPassword,
        enableDoubleTap: false,
        minZoom: givenMinZoom,
        maxZoom: givenMaxZoom,
        enableDefaultScrollHandle: false,
        spacing: givenSpacing,
        hasOnLinkHandle: true,
      );
      final expectedWidgetConfiguration = WidgetConfiguration(
        onPointerUp: (_) {},
        onPlatformViewCreated: (_) {},
        gestureRecognizers: null,
      );

      fakeAlhPdfViewPlatform.verifyBuildView(
        creationParams: expectedCreationParams,
        widgetConfiguration: expectedWidgetConfiguration,
        called: 1,
      );

      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets(
        'GIVEN filePath, updated fitPolicy and [AlhPdfView] '
        'WHEN updating fitPolicy '
        'THEN should updateCreationParams of [AlhPdfController]',
        (WidgetTester tester) async {
      // given
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

      const givenFitPolicy = FitPolicy.both;
      const givenUpdatedFitPolicy = FitPolicy.width;

      await tester.pumpWidget(
        const MaterialApp(
          home: _UpdateAlhPdfViewTest(
            filePath: givenFilePath,
            fitPolicy: givenFitPolicy,
            updatedFitPolicy: givenUpdatedFitPolicy,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // when
      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();

      // then
      final expectedCreationParams = getExpectedDefaultCreationParams(
        fitPolicy: givenUpdatedFitPolicy,
      );
      fakeAlhPdfViewPlatform.verifyBuildView(
        creationParams: expectedCreationParams,
        widgetConfiguration: expectedDefaultWidgetConfiguration,
        called: 2,
      );
      fakeAlhPdfViewPlatform.verifyUpdateFitPolicy(
        creationParams: expectedCreationParams.toMap(),
        called: 1,
      );

      debugDefaultTargetPlatformOverride = null;
    });

    group('invoking method calls', () {
      const expectedViewId = 0;

      Future<void> pumpWidget(
        WidgetTester tester, {
        PDFViewCreatedCallback? onViewCreated,
        ErrorCallback? onError,
        RenderCallback? onRender,
        PageChangedCallback? onPageChanged,
        ZoomChangedCallback? onZoomChanged,
      }) async =>
          tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: AlhPdfView(
                  filePath: givenFilePath,
                  onViewCreated: onViewCreated,
                  onError: onError,
                  onRender: onRender,
                  onPageChanged: onPageChanged,
                  onZoomChanged: onZoomChanged,
                ),
              ),
            ),
          );

      tearDown(() {
        fakeAlhPdfViewPlatform.verifyBuildView(
          creationParams: getExpectedDefaultCreationParams(),
          widgetConfiguration: expectedDefaultWidgetConfiguration,
          called: 1,
        );
        fakeAlhPdfViewPlatform.verifySetOrientation(
          creationParams: getExpectedDefaultCreationParams().toMap(),
          orientation: Orientation.landscape,
          called: 1,
        );
      });

      testWidgets(
          'GIVEN path and [AlhPdfView] '
          'WHEN pumping finished '
          'THEN should call #onViewCreated', (WidgetTester tester) async {
        // given
        AlhPdfViewController? actualController;

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
      });

      testWidgets(
          'GIVEN path and [AlhPdfView] '
          'WHEN invoking onError '
          'THEN should call #onError with given error',
          (WidgetTester tester) async {
        // given
        final completer = Completer();

        const givenError = 'error 123';
        dynamic actualError;

        await pumpWidget(
          tester,
          onError: (error) {
            actualError = error;
            completer.complete();
          },
        );

        // when
        fakeAlhPdfViewPlatform.addOnErrorEvent(
          viewId: expectedViewId,
          error: givenError,
        );

        // then
        await completer.future;
        expect(actualError, equals(givenError));
      });

      testWidgets(
          'GIVEN path and [AlhPdfView] '
          'WHEN invoking onRender '
          'THEN should call #onRender with given pages',
          (WidgetTester tester) async {
        // given
        final completer = Completer();

        const givenPages = 9999;
        int? actualPages;

        await pumpWidget(
          tester,
          onRender: (pages) {
            actualPages = pages;
            completer.complete();
          },
        );

        // when
        fakeAlhPdfViewPlatform.addOnRenderEvent(
          viewId: expectedViewId,
          pageCount: givenPages,
        );

        // then
        await completer.future;
        expect(actualPages, equals(givenPages));
      });

      testWidgets(
          'GIVEN path and [AlhPdfView] '
          'WHEN invoking onPageChanged '
          'THEN should call #onPageChanged with given page and total',
          (WidgetTester tester) async {
        // given
        final completer = Completer();

        const givenPage = 9;
        const givenTotal = 10;
        int? actualPage;
        int? actualTotal;

        await pumpWidget(
          tester,
          onPageChanged: (page, total) {
            actualPage = page;
            actualTotal = total;
            completer.complete();
          },
        );

        // when
        fakeAlhPdfViewPlatform.addOnPageChangedEvent(
          viewId: expectedViewId,
          page: givenPage,
          total: givenTotal,
        );

        // then
        await completer.future;
        expect(actualPage, equals(givenPage));
        expect(actualTotal, equals(givenTotal));
      });

      testWidgets(
          'GIVEN path and [AlhPdfView] '
          'WHEN invoking onZoomChanged '
          'THEN should call #onZoomChanged with given zoom',
          (WidgetTester tester) async {
        // given
        final completer = Completer();

        const givenZoom = 234.4;
        double? actualZoom;

        await pumpWidget(
          tester,
          onZoomChanged: (zoom) {
            actualZoom = zoom;
            completer.complete();
          },
        );

        // when
        fakeAlhPdfViewPlatform.addOnZoomChangedEvent(
          viewId: expectedViewId,
          zoom: givenZoom,
        );

        // then
        await completer.future;
        expect(actualZoom, equals(givenZoom));
      });
    });
  });
}

class _UpdateAlhPdfViewTest extends StatefulWidget {
  final String filePath;
  final FitPolicy fitPolicy;
  final FitPolicy updatedFitPolicy;

  const _UpdateAlhPdfViewTest({
    required this.filePath,
    required this.fitPolicy,
    required this.updatedFitPolicy,
  });

  @override
  State<_UpdateAlhPdfViewTest> createState() => _UpdateAlhPdfViewTestState();
}

class _UpdateAlhPdfViewTestState extends State<_UpdateAlhPdfViewTest> {
  late FitPolicy fitPolicy;

  @override
  void initState() {
    fitPolicy = widget.fitPolicy;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: AlhPdfView(
            filePath: widget.filePath,
            fitPolicy: fitPolicy,
          ),
        ),
        TextButton(
          onPressed: () {
            setState(() {
              fitPolicy = widget.updatedFitPolicy;
            });
          },
          child: const Text('update'),
        ),
      ],
    );
  }
}
