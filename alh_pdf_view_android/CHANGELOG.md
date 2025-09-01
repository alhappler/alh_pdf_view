## 2.3.3
* Added support for Android 16 KB memory page size in PDF handling (Issue [#69](https://github.com/alhappler/alh_pdf_view/issues/69) from `E2-venkat`)
* Migrated native PDF library from "com.github.mhiew:android-pdf-viewer:3.2.0-beta.2" to "com.github.marain87:AndroidPdfViewer:3.2.8".
* Introduced jitpack package for "com.github.marain87:AndroidPdfViewer:3.2.8".

## 2.3.1
* updated `updateBytes` to `refreshPdf` to react also to path updates

## 2.3.0
* removed `onPageError` which was replaced with `onError`
* updated logs which come with `onError` in `AlhPdfView`
  
## 2.2.0
* Added `updateBytes`
* Removed `updateCreationParams`

## 2.1.0
* Added `onTap` as callback for Android when tapping pdf suggested by https://github.com/alhappler/alh_pdf_view/pull/36.

## 2.0.1
* Since flutter version 3.24.0, the pdf which was opened can have a blank screen.
  * fixed by calling `zoomWithAnimation` with the default zoom factor

## 2.0.0

* Added Android implementation, see more on changelogs in [alh_pdf_view](https://pub.dev/packages/alh_pdf_view/changelog)

## 1.3.0
⚽️ **Features**
* better error handling on iOS
* added new parameter `spacing` (Issue [#35](https://github.com/alhappler/alh_pdf_view/issues/35) from `SpirikleOfficial`)
  * adds space between pdf pages

## 1.2.1

🐛 **Bugfix**
* double tap on first zoom didn't work properly on iOS (Issue [#39](https://github.com/alhappler/alh_pdf_view/issues/39) from `https://github.com/mirkancal`)

## 1.2.0

⚽️ **Features**
* added `showScrollbar` (Issue [#33](https://github.com/alhappler/alh_pdf_view/issues/33) from `mirkancal`)
  * default value is true
  * if false you can hide the Scrollbar
  * this solution only works for iOS
  * on Android, you can use `enableDefaultScrollHandle` to hide the scrolling indicator

## 1.1.0

⚽️ **Features**
* added `onLinkHandle` as callback for iOS when tapping on a link inside the PDF (Issue [#22](https://github.com/alhappler/alh_pdf_view/issues/22) from `shubhamsinha2009`)

## 1.0.0

⚽️ **Features**
* added two new functions for Android and iOS (Issue [#18](https://github.com/alhappler/alh_pdf_view/issues/18) from `carman247`)
  * goToNextPage to navigate to the next page (optionally animated)
  * goToPreviousPage to navigate to the previous page (optionally animated)
* added `withAnimation` also for iOS when changing the page

⚡️ **Breaking changes**
* removed function `setPageWithAnimation`
  * use instead `setPage` and use the parameter `withAnimation`
* updated to flutter `3.3.0` and dart `2.18.0`
  * minVersion for iOS is now `11.0`

## 0.3.4
🐛 **Bugfix**

* fixed multiple calls on `onPageChanged` during page change on android (issue [#17](https://github.com/alhappler/alh_pdf_view/issues/17))

## 0.3.3

⚽️ **Features**

* added `enableDefaultScrollHandle` for Android to have an extra scroll button (issue [#16](https://github.com/alhappler/alh_pdf_view/issues/16))

## 0.3.2

🏆 **Improvement**

* min sdk version of dart changed from `2.15` to `2.14` (issue [#12](https://github.com/alhappler/alh_pdf_view/issues/12))

## 0.3.1

🐛 **Bugfixes**

* fixed white-screen-bug using proguard (issue [#7](https://github.com/alhappler/alh_pdf_view/issues/7))

## 0.3.0

⚽️ **Features**

* added `onZoomChanged` callback for android

🐛 **Bugfixes**

* fixed crash for android when pdf is loaded and widget disposed

## 0.2.0

* Removed warnings for flutter upgrade `3.0.0`

## 0.1.4

* Static analyzes to 130 points

## 0.1.3

🏆 **Improvement**

* Removed delay on android when orientation changes and PDF is rebuilding
* Minor coding changes

## 0.1.2

🐛 **Bugfixes**

* Pdf View disappearing when opening Keyboard on Android

## 0.1.1

⚽️ New Feature:

* added parameter `minZoom` and `maxZoom`

## 0.1.0

🐛 Fixed some bugs:

* onZoomChanged removed for Android
* Fixed rotation bug
  * Android: resulting to a white screen
  * iOS: resetting the pdf
* FitPolicy can be updated on Android and iOS

## 0.0.1

* New Package containing the funcitonality to load PDF with bytes or file path
