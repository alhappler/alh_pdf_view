import 'package:alh_pdf_view_android/alh_pdf_view_android.dart';
import 'package:alh_pdf_view_platform_interface/alh_pdf_view_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

final binaryMessenger =
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AlhPdfViewAndroid platform;

  setUp(() {
    platform = AlhPdfViewAndroid();
  });

  group('#init', () {
    test(
        'GIVEN viewId '
        'WHEN calling init '
        'THEN should init one new channel', () async {
      // given
      const givenViewId = 999;

      // when
      await platform.init(givenViewId);

      // then
      expect(platform.channels.length, equals(1));
      const expectedName = 'alh_pdf_view_$givenViewId';
      expect(platform.channels[givenViewId]!.name, equals(expectedName));
    });

    test(
        'GIVEN viewId and called init '
        'WHEN calling init again with same viewId '
        'THEN should init only one channel', () async {
      // given
      const givenViewId = 999;
      await platform.init(givenViewId);

      // when
      await platform.init(givenViewId);

      // then
      expect(platform.channels.length, equals(1));
      const expectedName = 'alh_pdf_view_$givenViewId';
      expect(platform.channels[givenViewId]!.name, equals(expectedName));
    });
  });

  group('#MethodChannel Calls', () {
    const givenViewId = 123;
    const expectedChannel = MethodChannel('alh_pdf_view_$givenViewId');

    setUp(() async {
      await platform.init(givenViewId);
    });

    void setUpMethodCall(
      Future<Object?>? Function(MethodCall message) handler,
    ) {
      binaryMessenger.setMockMethodCallHandler(expectedChannel, handler);
    }

    test(
        'GIVEN - '
        'WHEN calling #dispose '
        'THEN should do nothing', () async {
      // given
      MethodCall? actualCall;

      setUpMethodCall(
        (call) async {
          actualCall = call;
          return null;
        },
      );

      // when
      await platform.dispose(viewId: givenViewId);

      // then
      expect(actualCall, isNull);
    });

    test(
        'GIVEN pageCount '
        'WHEN calling #getPageCount '
        'THEN should return given pageCount and call "pageCount"', () async {
      // given
      const givenPageCount = 5;
      late final MethodCall actualCall;

      setUpMethodCall(
        (call) async {
          if (call.method == 'pageCount') {
            actualCall = call;
            return givenPageCount;
          }
          return null;
        },
      );

      // when
      final actual = await platform.getPageCount(viewId: givenViewId);

      // then
      expect(actual, equals(givenPageCount));

      const expectedCall = MethodCall('pageCount', null);
      expect(actualCall.method, equals(expectedCall.method));
      expect(actualCall.arguments, equals(expectedCall.arguments));
    });

    test(
        'GIVEN page '
        'WHEN calling #getCurrentPage '
        'THEN should return given page and call "currentPage"', () async {
      // given
      const givenPage = 5;
      late final MethodCall actualCall;

      setUpMethodCall(
        (call) async {
          if (call.method == 'currentPage') {
            actualCall = call;
            return givenPage;
          }
          return null;
        },
      );

      // when
      final actual = await platform.getCurrentPage(viewId: givenViewId);

      // then
      expect(actual, equals(givenPage));

      const expectedCall = MethodCall('currentPage', null);
      expect(actualCall.method, equals(expectedCall.method));
      expect(actualCall.arguments, equals(expectedCall.arguments));
    });

    test(
        'GIVEN page and withAnimation = false '
        'WHEN calling #setPage '
        'THEN should return true and call "setPage"', () async {
      // given
      const givenPage = 5;
      late final MethodCall actualCall;

      setUpMethodCall(
        (call) async {
          if (call.method == 'setPage') {
            actualCall = call;
            return true;
          }
          return null;
        },
      );

      // when
      final actual = await platform.setPage(
        viewId: givenViewId,
        page: givenPage,
        withAnimation: false,
      );

      // then
      expect(actual, isTrue);

      const expectedCall = MethodCall('setPage', {
        'page': givenPage,
        'withAnimation': false,
      });
      expect(actualCall.method, equals(expectedCall.method));
      expect(actualCall.arguments, equals(expectedCall.arguments));
    });

    test(
        'GIVEN withAnimation = true '
        'WHEN calling #goToNextPage '
        'THEN should return false and call "nextPage"', () async {
      // given
      late final MethodCall actualCall;

      setUpMethodCall(
        (call) async {
          if (call.method == 'nextPage') {
            actualCall = call;
            return false;
          }
          return null;
        },
      );

      // when
      final actual = await platform.goToNextPage(
        viewId: givenViewId,
        withAnimation: true,
      );

      // then
      expect(actual, isFalse);

      const expectedCall = MethodCall('nextPage', {
        'withAnimation': true,
      });
      expect(actualCall.method, equals(expectedCall.method));
      expect(actualCall.arguments, equals(expectedCall.arguments));
    });

    test(
        'GIVEN withAnimation = false '
        'WHEN calling #goToPreviousPage '
        'THEN should return false and call "previousPage"', () async {
      // given
      late final MethodCall actualCall;

      setUpMethodCall(
        (call) async {
          if (call.method == 'previousPage') {
            actualCall = call;
            return false;
          }
          return null;
        },
      );

      // when
      final actual = await platform.goToPreviousPage(
        viewId: givenViewId,
        withAnimation: false,
      );

      // then
      expect(actual, isFalse);

      const expectedCall = MethodCall('previousPage', {
        'withAnimation': false,
      });
      expect(actualCall.method, equals(expectedCall.method));
      expect(actualCall.arguments, equals(expectedCall.arguments));
    });

    test(
        'GIVEN - '
        'WHEN calling #resetZoom '
        'THEN should call "resetZoom"', () async {
      // given
      late final MethodCall actualCall;

      setUpMethodCall(
        (call) async {
          if (call.method == 'resetZoom') {
            actualCall = call;
          }
          return null;
        },
      );

      // when
      await platform.resetZoom(viewId: givenViewId);

      // then
      const expectedCall = MethodCall('resetZoom');
      expect(actualCall.method, equals(expectedCall.method));
      expect(actualCall.arguments, equals(expectedCall.arguments));
    });

    test(
        'GIVEN zoom '
        'WHEN calling #setZoom '
        'THEN should call "setZoom"', () async {
      // given
      const givenZoom = 5.12345;
      late final MethodCall actualCall;

      setUpMethodCall(
        (call) async {
          if (call.method == 'setZoom') {
            actualCall = call;
            return true;
          }
          return null;
        },
      );

      // when
      await platform.setZoom(
        viewId: givenViewId,
        zoom: givenZoom,
      );

      // then
      const expectedCall = MethodCall('setZoom', {
        'newZoom': givenZoom,
      });
      expect(actualCall.method, equals(expectedCall.method));
      expect(actualCall.arguments, equals(expectedCall.arguments));
    });

    test(
        'GIVEN channel returns zoom '
        'WHEN calling #getZoom '
        'THEN should return given zoom and call "currentZoom"', () async {
      // given
      const givenZoom = 5.67;
      late final MethodCall actualCall;

      setUpMethodCall(
        (call) async {
          if (call.method == 'currentZoom') {
            actualCall = call;
            return givenZoom;
          }
          return null;
        },
      );

      // when
      final actual = await platform.getZoom(viewId: givenViewId);

      // then
      expect(actual, equals(givenZoom));

      const expectedCall = MethodCall('currentZoom', null);
      expect(actualCall.method, equals(expectedCall.method));
      expect(actualCall.arguments, equals(expectedCall.arguments));
    });

    test(
        'GIVEN orientation = .landscape and creationParams '
        'WHEN calling #setOrientation '
        'THEN should call "setOrientation"', () async {
      // given
      const givenCreationParams = {'hallo': 'hello'};
      const givenOrientation = Orientation.landscape;

      late final MethodCall actualCall;

      setUpMethodCall(
        (call) async {
          if (call.method == 'setOrientation') {
            actualCall = call;
            return true;
          }
          return null;
        },
      );

      // when
      await platform.setOrientation(
        viewId: givenViewId,
        creationParams: givenCreationParams,
        orientation: givenOrientation,
      );

      // then
      final expectedCall = MethodCall('setOrientation', {
        'orientation': givenOrientation.toString(),
        ...givenCreationParams,
      });
      expect(actualCall.method, equals(expectedCall.method));
      expect(actualCall.arguments, equals(expectedCall.arguments));
    });

    test(
        'GIVEN creationParams '
        'WHEN calling #updateBytes '
        'THEN should call "setOrientation"', () async {
      // given
      const givenCreationParams = {'hallo': 'hello'};

      late final MethodCall actualCall;

      setUpMethodCall(
        (call) async {
          if (call.method == 'updateBytes') {
            actualCall = call;
            return true;
          }
          return null;
        },
      );

      // when
      await platform.updateBytes(
        viewId: givenViewId,
        creationParams: givenCreationParams,
      );

      // then
      const expectedCall = MethodCall(
        'updateBytes',
        givenCreationParams,
      );
      expect(actualCall.method, equals(expectedCall.method));
      expect(actualCall.arguments, equals(expectedCall.arguments));
    });
  });

  group('#buildView', () {
    testWidgets(
        'GIVEN creationParams and widgetConfiguration '
        'WHEN pumping return value of buildView '
        'THEN should show expected widgets', (WidgetTester tester) async {
      // given
      const givenCreationParams = AlhPdfViewCreationParams(
        filePath: 'file path',
        bytes: null,
        fitPolicy: FitPolicy.both,
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

      final givenWidgetConfiguration = WidgetConfiguration(
        onPointerUp: (_) {},
        // cannot be tested so easily for android
        onPlatformViewCreated: (_) {},
        gestureRecognizers: null,
      );

      // when
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: platform.buildView(
              creationParams: givenCreationParams,
              widgetConfiguration: givenWidgetConfiguration,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // then
      expect(
        find.byWidgetPredicate(
          (widget) => widget is Listener && widget.child is PlatformViewLink,
        ),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is PlatformViewLink && widget.viewType == 'alh_pdf_view',
        ),
        findsOneWidget,
      );
    });
  });

  group('#invoking methods', () {
    late _TestAlhPdfViewController testController;

    const givenViewId = 123;
    const expectedChannel = MethodChannel('alh_pdf_view_$givenViewId');

    setUp(() async {
      await platform.init(givenViewId);
      testController = _TestAlhPdfViewController(
        platform: platform,
      );
    });

    Future<void> invokeMethodCall(MethodCall methodCall) async =>
        binaryMessenger.handlePlatformMessage(
          expectedChannel.name,
          const StandardMethodCodec().encodeMethodCall(methodCall),
          (data) {},
        );

    test(
        'GIVEN pages '
        'WHEN invoking method "onRender" '
        'THEN should call #onRender with given pages', () async {
      // given
      const givenPages = 10;

      int? actualPages;
      testController.connectStreams(
        viewId: givenViewId,
        onRender: (pages) {
          actualPages = pages;
        },
      );

      // when
      await invokeMethodCall(
        const MethodCall('onRender', {'pages': givenPages}),
      );

      // then
      expect(actualPages, equals(givenPages));
    });

    test(
        'GIVEN page and total '
        'WHEN invoking method "onPageChanged" '
        'THEN should call #onPageChanged with given page and total', () async {
      // given
      const givenPage = 10;
      const givenTotal = 1000;

      int? actualPage;
      int? actualTotal;
      testController.connectStreams(
        viewId: givenViewId,
        onPageChanged: (page, total) {
          actualPage = page;
          actualTotal = total;
        },
      );

      // when
      await invokeMethodCall(
        const MethodCall('onPageChanged', {
          'page': givenPage,
          'total': givenTotal,
        }),
      );

      // then
      expect(actualPage, equals(givenPage));
      expect(actualTotal, equals(givenTotal));
    });

    test(
        'GIVEN error '
        'WHEN invoking method "onError" '
        'THEN should call #onError with given error', () async {
      // given
      const givenError = 'helpppp!!! errrorrrr';

      dynamic actualError;
      testController.connectStreams(
        viewId: givenViewId,
        onError: (error) {
          actualError = error;
        },
      );

      // when
      await invokeMethodCall(
        const MethodCall('onError', {'error': givenError}),
      );

      // then
      expect(actualError, equals(givenError));
    });

    test(
        'GIVEN zoom '
        'WHEN invoking method "onZoomChanged" '
        'THEN should call #onZoomChanged with given zoom', () async {
      // given
      const givenZoom = 5.8;

      double? actualZoom;
      testController.connectStreams(
        viewId: givenViewId,
        onZoomChanged: (zoom) {
          actualZoom = zoom;
        },
      );

      // when
      await invokeMethodCall(
        const MethodCall('onZoomChanged', {'zoom': givenZoom}),
      );

      // then
      expect(actualZoom, equals(givenZoom));
    });
  });
}

class _TestAlhPdfViewController {
  final AlhPdfViewAndroid platform;

  const _TestAlhPdfViewController({
    required this.platform,
  });

  AlhPdfViewPlatform get _instance => this.platform;

  void connectStreams({
    required int viewId,
    RenderCallback? onRender,
    PageChangedCallback? onPageChanged,
    ErrorCallback? onError,
    ZoomChangedCallback? onZoomChanged,
  }) {
    this._instance.onRender(viewId: viewId).listen((event) {
      onRender?.call(event.value);
    });
    this._instance.onPageChanged(viewId: viewId).listen((event) {
      onPageChanged?.call(event.value.page, event.value.total);
    });
    this._instance.onError(viewId: viewId).listen((event) {
      onError?.call(event.value);
    });
    this._instance.onZoomChanged(viewId: viewId).listen((event) {
      onZoomChanged?.call(event.value);
    });
  }
}
