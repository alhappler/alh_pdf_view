import 'dart:async';

import 'package:alh_pdf_view/alh_pdf_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../utils/fake_alh_pdf_view_platform.dart';

void main() {
  late AlhPdfViewController controller;

  late FakeAlhPdfViewPlatform fakeAlhPdfViewPlatform;

  const givenViewId = 123;

  Future<void> setUpController({
    RenderCallback? onRender,
    PageChangedCallback? onPageChanged,
    ErrorCallback? onError,
    PageErrorCallback? onPageError,
    ZoomChangedCallback? onZoomChanged,
    LinkHandleCallback? onLinkHandle,
    VoidCallback? onTap,
  }) async {
    controller = await AlhPdfViewController.init(
      viewId: givenViewId,
      onRender: onRender,
      onPageChanged: onPageChanged,
      onError: onError,
      onPageError: onPageError,
      onZoomChanged: onZoomChanged,
      onLinkHandle: onLinkHandle,
      onTap: onTap,
    );
  }

  setUp(() async {
    fakeAlhPdfViewPlatform = FakeAlhPdfViewPlatform();
    AlhPdfViewPlatform.instance = fakeAlhPdfViewPlatform;

    await setUpController();
  });

  group('#stream', () {
    test(
        'GIVEN onRender '
        'WHEN adding OnRenderEvent with pageCount = 45 '
        'THEN should call onRender', () async {
      // given
      final completer = Completer();
      const givenPageCount = 45;

      int? actualPageCount;
      await setUpController(
        onRender: (pagesCount) {
          actualPageCount = pagesCount;
          completer.complete();
        },
      );

      // when
      fakeAlhPdfViewPlatform.addOnRenderEvent(
        viewId: givenViewId,
        pageCount: givenPageCount,
      );

      // then
      await completer.future;
      expect(actualPageCount, equals(givenPageCount));
    });

    test(
        'GIVEN onPageChanged '
        'WHEN adding OnPageChangedEvent with page and total '
        'THEN should call onPageChanged', () async {
      // given
      final completer = Completer();
      const givenPage = 45;
      const givenTotal = 45;

      int? actualPage;
      int? actualTotal;
      await setUpController(
        onPageChanged: (page, total) {
          actualPage = page;
          actualTotal = total;
          completer.complete();
        },
      );

      // when
      fakeAlhPdfViewPlatform.addOnPageChangedEvent(
        viewId: givenViewId,
        page: givenPage,
        total: givenTotal,
      );

      // then
      await completer.future;
      expect(actualPage, equals(givenPage));
      expect(actualTotal, equals(givenTotal));
    });

    test(
        'GIVEN onError '
        'WHEN adding OnErrorEvent with error '
        'THEN should call onError', () async {
      // given
      final completer = Completer();
      const givenError = 'error error';

      String? actualError;
      await setUpController(
        onError: (error) {
          actualError = error;
          completer.complete();
        },
      );

      // when
      fakeAlhPdfViewPlatform.addOnErrorEvent(
        viewId: givenViewId,
        error: givenError,
      );

      // then
      await completer.future;
      expect(actualError, equals(givenError));
    });

    test(
        'GIVEN onPageError '
        'WHEN adding OnPageErrorEvent with page and error '
        'THEN should call onPageError', () async {
      // given
      final completer = Completer();
      const givenPage = 234;
      const givenError = 'error error';

      int? actualPage;
      String? actualError;
      await setUpController(
        onPageError: (page, error) {
          actualPage = page;
          actualError = error;
          completer.complete();
        },
      );

      // when
      fakeAlhPdfViewPlatform.addOnPageErrorEvent(
        viewId: givenViewId,
        page: givenPage,
        error: givenError,
      );

      // then
      await completer.future;
      expect(actualPage, equals(givenPage));
      expect(actualError, equals(givenError));
    });

    test(
        'GIVEN onZoomChanged '
        'WHEN adding OnZoomChangedEvent with page and error '
        'THEN should call onZoomChanged', () async {
      // given
      final completer = Completer();
      const givenZoom = 234.123;

      double? actualZoom;
      await setUpController(
        onZoomChanged: (zoom) {
          actualZoom = zoom;
          completer.complete();
        },
      );

      // when
      fakeAlhPdfViewPlatform.addOnZoomChangedEvent(
        viewId: givenViewId,
        zoom: givenZoom,
      );

      // then
      await completer.future;
      expect(actualZoom, equals(givenZoom));
    });

    test(
        'GIVEN onLinkHandle '
        'WHEN adding OnLinkHandleEvent with page and error '
        'THEN should call onLinkHandle', () async {
      // given
      final completer = Completer();
      const givenLink = 'link';

      String? actualLink;
      await setUpController(
        onLinkHandle: (link) {
          actualLink = link;
          completer.complete();
        },
      );

      // when
      fakeAlhPdfViewPlatform.addOnLinkHandleEvent(
        viewId: givenViewId,
        link: givenLink,
      );

      // then
      await completer.future;
      expect(actualLink, equals(givenLink));
    });

    test(
        'GIVEN onTap '
        'WHEN adding OnTapEvent with page and error '
        'THEN should call onTap', () async {
      // given
      final completer = Completer();

      int callbackCounter = 0;
      await setUpController(
        onTap: () {
          callbackCounter++;
          completer.complete();
        },
      );

      // when
      fakeAlhPdfViewPlatform.addOnTapEvent(
        viewId: givenViewId,
      );

      // then
      await completer.future;
      expect(callbackCounter, equals(1));
    });
  });

  group('@overrides', () {
    test(
        'GIVEN instance returns pageCount '
        'WHEN calling getPageCount '
        'THEN should return given pageCount', () async {
      // given
      const givenPageCount = 123;
      fakeAlhPdfViewPlatform.setUpGetPageCount(pageCount: givenPageCount);

      // when
      final actual = await controller.getPageCount();

      // then
      expect(actual, equals(givenPageCount));
      fakeAlhPdfViewPlatform.verifyGetPageCount();
    });

    test(
        'GIVEN instance returns page '
        'WHEN calling getCurrentPage '
        'THEN should return given page', () async {
      // given
      const givenPage = 321;
      fakeAlhPdfViewPlatform.setUpGetCurrentPage(page: givenPage);

      // when
      final actual = await controller.getCurrentPage();

      // then
      expect(actual, equals(givenPage));
      fakeAlhPdfViewPlatform.verifyGetCurrentPage();
    });

    group('#setPage', () {
      test(
          'GIVEN only required values and instance returns true '
          'WHEN calling setPage '
          'THEN should return true', () async {
        // given
        const givenPage = 5443;
        fakeAlhPdfViewPlatform.setUpSetPage(result: true);

        // when
        final actual = await controller.setPage(page: givenPage);

        // then
        expect(actual, isTrue);
        fakeAlhPdfViewPlatform.verifySetPage(
          page: givenPage,
          withAnimation: true,
        );
      });

      test(
          'GIVEN all values and instance returns false '
          'WHEN calling setPage '
          'THEN should return false', () async {
        // given
        const givenPage = 5443;
        fakeAlhPdfViewPlatform.setUpSetPage(result: false);

        // when
        final actual = await controller.setPage(
          page: givenPage,
          withAnimation: false,
        );

        // then
        expect(actual, isFalse);
        fakeAlhPdfViewPlatform.verifySetPage(
          page: givenPage,
          withAnimation: false,
        );
      });
    });

    group('#goToNextPage', () {
      test(
          'GIVEN instance returns true '
          'WHEN calling goToNextPage '
          'THEN should return true', () async {
        // given
        fakeAlhPdfViewPlatform.setUpGoToNextPage(result: true);

        // when
        final actual = await controller.goToNextPage();

        // then
        expect(actual, isTrue);
        fakeAlhPdfViewPlatform.verifyGoToNextPage(withAnimation: true);
      });

      test(
          'GIVEN withAnimation = false and instance returns false '
          'WHEN calling goToNextPage '
          'THEN should return false', () async {
        // given
        fakeAlhPdfViewPlatform.setUpGoToNextPage(result: false);

        // when
        final actual = await controller.goToNextPage(withAnimation: false);

        // then
        expect(actual, isFalse);
        fakeAlhPdfViewPlatform.verifyGoToNextPage(withAnimation: false);
      });
    });

    group('#goToPreviousPage', () {
      test(
          'GIVEN instance returns true '
          'WHEN calling goToPreviousPage '
          'THEN should return true', () async {
        // given
        fakeAlhPdfViewPlatform.setUpGoToPreviousPage(result: true);

        // when
        final actual = await controller.goToPreviousPage();

        // then
        expect(actual, isTrue);
        fakeAlhPdfViewPlatform.verifyGoToPreviousPage(withAnimation: true);
      });

      test(
          'GIVEN withAnimation = false and instance returns false '
          'WHEN calling goToPreviousPage '
          'THEN should return false', () async {
        // given
        fakeAlhPdfViewPlatform.setUpGoToPreviousPage(result: false);

        // when
        final actual = await controller.goToPreviousPage(withAnimation: false);

        // then
        expect(actual, isFalse);
        fakeAlhPdfViewPlatform.verifyGoToPreviousPage(withAnimation: false);
      });
    });

    test(
        'GIVEN - '
        'WHEN calling resetZoom '
        'THEN should call instance', () async {
      // given

      // when
      await controller.resetZoom();

      // then
      fakeAlhPdfViewPlatform.verifyResetZoom();
    });

    test(
        'GIVEN zoom '
        'WHEN calling setZoom '
        'THEN should call instance with given zoom', () async {
      // given
      const givenZoom = 132.4543;

      // when
      await controller.setZoom(zoom: givenZoom);

      // then
      fakeAlhPdfViewPlatform.verifySetZoom(zoom: givenZoom);
    });

    test(
        'GIVEN zoom '
        'WHEN calling getZoom '
        'THEN should call instance with given zoom', () async {
      // given
      const givenZoom = 132.4543;
      fakeAlhPdfViewPlatform.setUpGetZoom(zoom: givenZoom);

      // when
      final actual = await controller.getZoom();

      // then
      expect(actual, equals(givenZoom));
      fakeAlhPdfViewPlatform.verifyGetZoom();
    });

    test(
        'GIVEN page and instance returns pageSize '
        'WHEN calling getPageSize '
        'THEN should return pageSize', () async {
      // given
      const givenPage = 2;
      const givenPageSize = Size(123.456, 789.123);
      fakeAlhPdfViewPlatform.setUpGetPageSize(pageSize: givenPageSize);

      // when
      final actual = await controller.getPageSize(page: givenPage);

      // then
      expect(actual, equals(givenPageSize));
      fakeAlhPdfViewPlatform.verifyGetPageSize(page: givenPage);
    });

    group('#setOrientation', () {
      test(
          'GIVEN platform = .iOS '
          'WHEN calling setOrientation '
          'THEN should do nothing', () async {
        // given
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

        const givenCreationParams = {'hallo': 123};
        const givenOrientation = Orientation.landscape;

        // when
        await controller.setOrientation(
          creationParams: givenCreationParams,
          orientation: givenOrientation,
        );

        // then
        fakeAlhPdfViewPlatform.verifySetOrientation(called: 0);

        debugDefaultTargetPlatformOverride = null;
      });

      test(
          'GIVEN platform = .android '
          'WHEN calling setOrientation '
          'THEN should call setOrientation of instance', () async {
        // given
        debugDefaultTargetPlatformOverride = TargetPlatform.android;

        const givenCreationParams = {'hallo': 123};
        const givenOrientation = Orientation.landscape;

        // when
        await controller.setOrientation(
          creationParams: givenCreationParams,
          orientation: givenOrientation,
        );

        // then
        fakeAlhPdfViewPlatform.verifySetOrientation(
          orientation: givenOrientation,
          creationParams: givenCreationParams,
        );

        debugDefaultTargetPlatformOverride = null;
      });
    });

    group('#updateCreationParams', () {
      test(
          'GIVEN platform = .android '
          'WHEN calling updateCreationParams '
          'THEN should do nothing', () async {
        // given
        debugDefaultTargetPlatformOverride = TargetPlatform.android;

        const givenCreationParams = {'hallo': 123};

        // when
        await controller.updateCreationParams(
          creationParams: givenCreationParams,
        );

        // then
        fakeAlhPdfViewPlatform.verifyUpdateCreationParams(called: 0);

        debugDefaultTargetPlatformOverride = null;
      });

      test(
          'GIVEN platform = .iOS '
          'WHEN calling updateCreationParams '
          'THEN should call updateCreationParams of instance', () async {
        // given
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

        const givenCreationParams = {'hallo': 123};

        // when
        await controller.updateCreationParams(
          creationParams: givenCreationParams,
        );

        // then
        fakeAlhPdfViewPlatform.verifyUpdateCreationParams(
          creationParams: givenCreationParams,
        );

        debugDefaultTargetPlatformOverride = null;
      });
    });

    test(
        'GIVEN - '
        'WHEN calling dispose '
        'THEN should call dispose of instance', () async {
      // given

      // when
      controller.dispose();

      // then
      fakeAlhPdfViewPlatform.verifyDispose();
    });
  });
}
