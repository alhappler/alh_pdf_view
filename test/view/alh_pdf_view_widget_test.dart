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

    testWidgets(
        "GIVEN bytes and minZoom < 0 "
        "WHEN pumping [AlhPdfView] "
        "THEN should throw [AssertionError]", (WidgetTester tester) async {
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
        "GIVEN bytes and maxZoom < 0 "
        "WHEN pumping [AlhPdfView] "
        "THEN should throw [AssertionError]", (WidgetTester tester) async {
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
    late FakeAndroidPlatformViewsController viewsController;

    setUp(() {
      viewsController = FakeAndroidPlatformViewsController();
      viewsController.registerViewType('alh_pdf_view');
    });

    testWidgets(
        "GIVEN platform == TargetPlatform.android, filePath and no other parameters "
        "WHEN pumping [AlhPdfView] "
        "THEN should have expected default parameters and "
        "should show [UiKitView] with expected creationParams and "
        "should call setOrientation of [AlhPdfController]",
        (WidgetTester tester) async {
      // given
      changeOrientation(tester, landscape: false);

      const givenFilePath = 'path';

      const channel = MethodChannel('alh_pdf_0');
      MethodCall? methodCall;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        if (call.method == 'setOrientation') {
          methodCall = call;
        }
        return null;
      });

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
                widget.showScrollbar,
          ),
          findsOneWidget);
      expect(
          find.byWidgetPredicate((widget) =>
              widget is PlatformViewLink && widget.viewType == 'alh_pdf_view'),
          findsOneWidget);
      expect(methodCall?.method, equals('setOrientation'));
      expect(methodCall?.arguments['orientation'],
          equals(Orientation.portrait.toString()));

      clearTestValues(tester);
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets(
        "GIVEN platform == TargetPlatform.android, [AlhPdfView] and orientation = portrait "
        "WHEN changing orientation "
        "THEN should call setRotation of [AlhPdfController]",
        (WidgetTester tester) async {
      // given
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      changeOrientation(tester, landscape: false);

      // when
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AlhPdfView(
              filePath: 'path',
            ),
          ),
        ),
      );

      final viewId = viewsController.views.first.id;
      final channel = MethodChannel('alh_pdf_$viewId');
      MethodCall? methodCall;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        if (call.method == 'setOrientation') {
          methodCall = call;
        }
        return null;
      });

      await tester.pumpAndSettle();

      changeOrientation(tester, landscape: true);
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      // then
      expect(methodCall?.method, equals('setOrientation'));
      expect(methodCall?.arguments['orientation'],
          equals(Orientation.landscape.toString()));

      clearTestValues(tester);
      debugDefaultTargetPlatformOverride = null;
    });
  });

  group('platform == TargetPlatform.iOS', () {
    late FakeIosPlatformViewsController viewsController;

    setUp(() {
      viewsController = FakeIosPlatformViewsController();
      viewsController.registerViewType('alh_pdf_view');
    });

    testWidgets(
        "GIVEN bytes and all parameters "
        "WHEN pumping [AlhPdfView] "
        "THEN should show [UiKitView] with expected creationParams",
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
              onLinkHandle: (_) {},
            ),
          ),
        ),
      );

      // then
      expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is UiKitView &&
                widget.creationParams['filePath'] == givenFilePath &&
                widget.creationParams['bytes'] == givenBytes &&
                widget.creationParams['fitPolicy'] ==
                    givenFitPolicy.toString() &&
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
                !widget.creationParams['enableDoubleTap'] &&
                widget.creationParams['minZoom'] == givenMinZoom &&
                widget.creationParams['maxZoom'] == givenMaxZoom &&
                widget.creationParams['hasOnLinkHandle'] == true &&
                !widget.creationParams['showScrollbar'],
          ),
          findsOneWidget);

      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets(
        "GIVEN filePath, updated fitPolicy and [AlhPdfView] "
        "WHEN updating fitPolicy "
        "THEN should updateCreationParams of [AlhPdfController]",
        (WidgetTester tester) async {
      // given
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

      const givenFilePath = 'path';
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

      final viewId = viewsController.views.first.id;
      final channel = MethodChannel('alh_pdf_$viewId');
      MethodCall? methodCall;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        if (call.method == 'updateCreationParams') {
          methodCall = call;
        }
        return null;
      });

      // when
      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();

      // then
      expect(methodCall?.arguments['fitPolicy'],
          equals(givenUpdatedFitPolicy.toString()));

      debugDefaultTargetPlatformOverride = null;
    });

    group('invoking method calls', () {
      Future<void> pumpWidget(
        WidgetTester tester, {
        PDFViewCreatedCallback? onViewCreated,
        ErrorCallback? onError,
        RenderCallback? onRender,
        PageChangedCallback? onPageChanged,
        PageErrorCallback? onPageError,
        ZoomChangedCallback? onZoomChanged,
      }) =>
// ignore: discarded_futures,
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
          "GIVEN path and [AlhPdfView] "
          "WHEN pumping finished "
          "THEN should call #onViewCreated", (WidgetTester tester) async {
        // given
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

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

        debugDefaultTargetPlatformOverride = null;
      });

      testWidgets(
          "GIVEN path and [AlhPdfView] "
          "WHEN invoking onError "
          "THEN should call #onError with given error",
          (WidgetTester tester) async {
        // given
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

        const givenError = 'error 123';
        dynamic actualError;

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
          "GIVEN path and [AlhPdfView] "
          "WHEN invoking onRender "
          "THEN should call #onRender with given pages",
          (WidgetTester tester) async {
        // given
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

        const givenPages = 9999;
        int? actualPages;

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
          "GIVEN path and [AlhPdfView] "
          "WHEN invoking onPageChanged "
          "THEN should call #onPageChanged with given page and total",
          (WidgetTester tester) async {
        // given
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

        const givenPage = 9;
        const givenTotal = 10;
        int? actualPage;
        int? actualTotal;

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
          "GIVEN path and [AlhPdfView] "
          "WHEN invoking onPageError "
          "THEN should call #onPageError with given page and error",
          (WidgetTester tester) async {
        // given
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

        const givenPage = 9;
        const givenError = 'error aaaaaaaaa';
        int? actualPage;
        dynamic actualError;

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
          "GIVEN path and [AlhPdfView] "
          "WHEN invoking onZoomChanged "
          "THEN should call #onZoomChanged with given zoom",
          (WidgetTester tester) async {
        // given
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

        const givenZoom = 234.4;
        double? actualZoom;

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
    this.fitPolicy = widget.fitPolicy;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: AlhPdfView(
            filePath: widget.filePath,
            fitPolicy: this.fitPolicy,
          ),
        ),
        TextButton(
          onPressed: () {
            setState(() {
              this.fitPolicy = widget.updatedFitPolicy;
            });
          },
          child: const Text('update'),
        ),
      ],
    );
  }
}
