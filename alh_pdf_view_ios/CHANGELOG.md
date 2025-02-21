## 2.3.2
* fixed autozoom issue, thanks to `E2-venkat` for opening the issue (Issue [#62](https://github.com/alhappler/alh_pdf_view/issues/62))

## 2.3.1
* updated `updateBytes` to `refreshPdf` to react also to path updates

## 2.3.0
* removed `onPageError` which was never used
* Added more error logs if something was not alright
  * these errors can be logged using `onError` in `AlhPdfView`

## 2.2.0
* Added `updateBytes`, `updateFitPolicy` and `updateScrollbar`
* Removed `updateCreationParams`

## 2.1.0
* Added `onTap` as callback for iOS when tapping pdf suggested by https://github.com/alhappler/alh_pdf_view/pull/36.

## 2.0.0

* Added iOS implementation, see more on changelogs in [alh_pdf_view](https://pub.dev/packages/alh_pdf_view/changelog)
