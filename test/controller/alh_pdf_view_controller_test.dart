import 'package:alh_pdf_view/lib.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../services/utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AlhPdfViewController controller;

  const givenId = 0;
  const channel = MethodChannel('alh_pdf_view_$givenId');

  void setUpController({
    required int id,
    RenderCallback? onRender,
    PageChangedCallback? onPageChanged,
    ErrorCallback? onError,
    PageErrorCallback? onPageError,
    ZoomChangedCallback? onZoomChanged,
  }) {
    controller = AlhPdfViewController(
      id: id,
      onZoomChanged: onZoomChanged,
      onRender: onRender,
      onPageError: onPageError,
      onPageChanged: onPageChanged,
      onError: onError,
    );
  }

  setUp(() {
    setUpController(id: givenId);
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  group('#invoking methods', () {
    test(
        'GIVEN pages '
        'WHEN invoking method "onRender" '
        'THEN should call #onRender with given pages', () async {
      // given
      const givenPages = 10;

      int? actualPages;
      setUpController(
        id: givenId,
        onRender: (pages) {
          actualPages = pages;
        },
      );

      // when
      await invokeMethodCall(
        const MethodCall('onRender', {'pages': givenPages}),
        channelName: 'alh_pdf_view_$givenId',
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
      setUpController(
        id: givenId,
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
        channelName: channel.name,
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
      setUpController(
        id: givenId,
        onError: (error) {
          actualError = error;
        },
      );

      // when
      await invokeMethodCall(
        const MethodCall('onError', {'error': givenError}),
        channelName: channel.name,
      );

      // then
      expect(actualError, equals(givenError));
    });

    test(
        'GIVEN error and page '
        'WHEN invoking method "onPageError" '
        'THEN should call #onPageError with given error and page', () async {
      // given
      const givenError = 'helpppp!!! errrorrrr 404';
      const givenPage = 10;

      dynamic actualError;
      int? actualPage;
      setUpController(
        id: givenId,
        onPageError: (page, error) {
          actualError = error;
          actualPage = page;
        },
      );

      // when
      await invokeMethodCall(
        const MethodCall('onPageError', {
          'error': givenError,
          'page': givenPage,
        }),
        channelName: channel.name,
      );

      // then
      expect(actualError, equals(givenError));
      expect(actualPage, equals(givenPage));
    });

    test(
        'GIVEN zoom '
        'WHEN invoking method "onZoomChanged" '
        'THEN should call #onZoomChanged with given zoom', () async {
      // given
      const givenZoom = 5.8;

      double? actualZoom;
      setUpController(
        id: givenId,
        onZoomChanged: (zoom) {
          actualZoom = zoom;
        },
      );

      // when
      await invokeMethodCall(
        const MethodCall('onZoomChanged', {'zoom': givenZoom}),
        channelName: channel.name,
      );

      // then
      expect(actualZoom, equals(givenZoom));
    });
  });

  group('#getPageSize', () {
    test(
        'GIVEN size and page '
        'WHEN calling #getPageSize '
        'THEN should return given size and should call "pageSize"', () async {
      // given
      const givenPage = 5;
      const givenSize = Size(100.0, 200.0);
      late final MethodCall actualMethodCall;
      channel.setMockMethodCallHandler((call) async {
        if (call.method == 'pageSize') {
          actualMethodCall = call;
          return {'height': givenSize.height, 'width': givenSize.width};
        }
      });

      // when
      final actual = await controller.getPageSize(page: givenPage);

      // then
      expect(actual, equals(givenSize));
      const expectedMethodCall = MethodCall('pageSize', {'page': givenPage});
      expect(actualMethodCall.method, equals(expectedMethodCall.method));
      expect(actualMethodCall.arguments, equals(expectedMethodCall.arguments));
    });
  });

  group('#getPageCount', () {
    test(
        'GIVEN pageCount '
        'WHEN calling #getPageCount '
        'THEN should return given pageCount and should call "pageCount"',
        () async {
      // given
      const givenPageCount = 5;
      late final MethodCall actualMethodCall;
      channel.setMockMethodCallHandler((call) async {
        if (call.method == 'pageCount') {
          actualMethodCall = call;
          return givenPageCount;
        }
      });

      // when
      final actual = await controller.getPageCount();

      // then
      expect(actual, equals(givenPageCount));
      const expectedMethodCall = MethodCall('pageCount', null);
      expect(actualMethodCall.method, equals(expectedMethodCall.method));
      expect(actualMethodCall.arguments, equals(expectedMethodCall.arguments));
    });
  });

  group('#getCurrentPage', () {
    test(
        'GIVEN pageCount '
        'WHEN calling #getCurrentPage '
        'THEN should return given pageCount and should call "currentPage"',
        () async {
      // given
      const givenPage = 5;
      late final MethodCall actualMethodCall;
      channel.setMockMethodCallHandler((call) async {
        if (call.method == 'currentPage') {
          actualMethodCall = call;
          return givenPage;
        }
      });

      // when
      final actual = await controller.getCurrentPage();

      // then
      expect(actual, equals(givenPage));
      const expectedMethodCall = MethodCall('currentPage', null);
      expect(actualMethodCall.method, equals(expectedMethodCall.method));
      expect(actualMethodCall.arguments, equals(expectedMethodCall.arguments));
    });
  });

  group('#setPage', () {
    test(
        'GIVEN page '
        'WHEN calling #setPage '
        'THEN should should call "setPage" with given page', () async {
      // given
      const givenPage = 100;
      late final MethodCall actualMethodCall;
      channel.setMockMethodCallHandler((call) async {
        if (call.method == 'setPage') {
          actualMethodCall = call;
          return givenPage;
        }
      });

      // when
      await controller.setPage(page: givenPage);

      // then
      const expectedMethodCall = MethodCall('setPage', {'page': givenPage});
      expect(actualMethodCall.method, equals(expectedMethodCall.method));
      expect(actualMethodCall.arguments, equals(expectedMethodCall.arguments));
    });
  });

  group('#setPageWithAnimation', () {
    test(
        'GIVEN platform = Android and page '
        'WHEN calling #setPageWithAnimation '
        'THEN should should call "setPageWithAnimation" with given page',
        () async {
      // given
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      const givenPage = 100;
      late final MethodCall actualMethodCall;
      channel.setMockMethodCallHandler((call) async {
        if (call.method == 'setPageWithAnimation') {
          actualMethodCall = call;
          return givenPage;
        }
      });

      // when
      await controller.setPageWithAnimation(page: givenPage);

      // then
      const expectedMethodCall =
          MethodCall('setPageWithAnimation', {'page': givenPage});
      expect(actualMethodCall.method, equals(expectedMethodCall.method));
      expect(actualMethodCall.arguments, equals(expectedMethodCall.arguments));
      debugDefaultTargetPlatformOverride = null;
    });

    test(
        'GIVEN platform = iOS and page '
        'WHEN calling #setPageWithAnimation '
        'THEN should should call "setPage" with given page', () async {
      // given
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      const givenPage = 100;
      late final MethodCall actualMethodCall;
      channel.setMockMethodCallHandler((call) async {
        if (call.method == 'setPage') {
          actualMethodCall = call;
          return givenPage;
        }
      });

      // when
      await controller.setPageWithAnimation(page: givenPage);

      // then
      const expectedMethodCall = MethodCall('setPage', {'page': givenPage});
      expect(actualMethodCall.method, equals(expectedMethodCall.method));
      expect(actualMethodCall.arguments, equals(expectedMethodCall.arguments));
      debugDefaultTargetPlatformOverride = null;
    });
  });

  group('#resetZoom', () {
    test(
        'GIVEN - '
        'WHEN calling #resetZoom '
        'THEN should should call "resetZoom"', () async {
      // given
      late final MethodCall actualMethodCall;
      channel.setMockMethodCallHandler((call) async {
        if (call.method == 'resetZoom') {
          actualMethodCall = call;
        }
      });

      // when
      await controller.resetZoom();

      // then
      const expectedMethodCall = MethodCall('resetZoom', null);
      expect(actualMethodCall.method, equals(expectedMethodCall.method));
      expect(actualMethodCall.arguments, equals(expectedMethodCall.arguments));
    });
  });

  group('#setZoom', () {
    test(
        'GIVEN zoom '
        'WHEN calling #setZoom '
        'THEN should should call "setZoom" with given zoom', () async {
      // given
      const givenZoom = 100.1;
      late final MethodCall actualMethodCall;
      channel.setMockMethodCallHandler((call) async {
        if (call.method == 'setZoom') {
          actualMethodCall = call;
        }
      });

      // when
      await controller.setZoom(zoom: givenZoom);

      // then
      const expectedMethodCall = MethodCall('setZoom', {'newZoom': givenZoom});
      expect(actualMethodCall.method, equals(expectedMethodCall.method));
      expect(actualMethodCall.arguments, equals(expectedMethodCall.arguments));
    });
  });

  group('#getZoom', () {
    test(
        'GIVEN zoom '
        'WHEN calling #getZoom '
        'THEN should should call "getZoom" and return given zoom', () async {
      // given
      const givenZoom = 33.333;
      late final MethodCall actualMethodCall;
      channel.setMockMethodCallHandler((call) async {
        if (call.method == 'currentZoom') {
          actualMethodCall = call;
          return givenZoom;
        }
      });

      // when
      final actual = await controller.getZoom();

      // then
      expect(actual, equals(givenZoom));
      const expectedMethodCall = MethodCall('currentZoom', null);
      expect(actualMethodCall.method, equals(expectedMethodCall.method));
      expect(actualMethodCall.arguments, equals(expectedMethodCall.arguments));
    });
  });
}
