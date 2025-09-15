![Pub Version](https://img.shields.io/pub/v/alh_pdf_view?color=%23397ab6&style=flat-square)
![GitHub branch checks state](https://img.shields.io/github/checks-status/alhappler/alh_pdf_view/master?style=flat-square)

With this widget, you can display a PDF with bytes or a path.

## Index
- [Introduction](#introduction)
- [Example](#example)
- [Parameters](#parameters)
- [AlhPdfViewController](#alh-pdf-view-controller)

## Introduction
The package `alh_pdf_view` includes:
- Displays PDF with bytes or path

See more about the functionalities in the parameter section.

### Android
- implemented in Kotlin with the dependency [AndroidPdfViewer](https://github.com/barteksc/AndroidPdfViewer) of **barteksc**
- supports Android 16 KB memory page size

### iOS
- implemented in Swift with the dependency [PDFKit](https://developer.apple.com/documentation/pdfkit)

## Example
___
```dart
import 'package:alh_pdf_view/alh_pdf_view.dart';
import 'package:flutter/material.dart';

class AlhPdfViewExample extends StatelessWidget {
  const AlhPdfViewExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PDF Example')),
      body: const AlhPdfView(
        filePath: 'ADD_PATH_TO_FILE',
      ),
    );
  }
}
```

### Parameters
This is a list of all parameters that can be used for this widget. Consider that some paremters only work for one platform.

| **Parameter**               | **Description**                                                                          |    **Default Value**     |
|:----------------------------|:-----------------------------------------------------------------------------------------|:------------------------:|
| `filePath`                  | Optional path to load PDF file.                                                          |          **-**           |
| `bytes`                     | Optional bytes to load PDF file.                                                         |          **-**           |
| `fitPolicy`                 | Defines how the PDF should fit inside the widget.                                        |   **`FitPolicy.both`**   |
| `fitEachPage`               | Each page of the PDF will fit inside the given space. (only Android)                     |        **`true`**        |
| `enableSwipe`               | The current page will be changed when swiping.                                           |        **`true`**        |
| `swipeHorizontal`           | If true, all pages are displayed in horizontal direction.                                |       **`false`**        |
| `nightMode`                 | Inverting colors of pages to have the look of a dark mode. (only Android)                |       **`false`**        |
| `autoSpacing`               | If true, spacing will be added to fit each page on its own on the screen. (only Android) |        **`true`**        |
| `pageFling`                 | Making a fling change.                                                                   |        **`true`**        |
| `pageSnap`                  | Snap pages to screen boundaries when changing the current page. (only Android)           |        **`true`**        |
| `defaultPage`               | Describes which page should be shown at first.                                           |         **`0`**          |
| `defaultZoomFactor`         | Defines how much the displayed PDF page should zoomed when rendered.                     |        **`1.0`**         |
| `backgroundColor`           | Setting backgroundColor of remaining space around the pdf view.                          | **`Colors.transparent`** |
| `password`                  | Unlocks PDF page with this password.                                                     |         **`""`**         |
| `enableDoubleTap`           | When double tapping, the zoom of the page changes. (only Android)                        |        **`1.0`**         |
| `minZoom`                   | Min zoom value that the user can reach while zooming.                                    |        **`0.5`**         |
| `maxZoom`                   | Max zoom value that the user can reach while zooming.                                    |        **`4.0`**         |
| `enableDefaultScrollHandle` | Adds a button to scroll faster through the document. (only Android)                      |        **false**         |
| `showScrollbar`             | If true, a Scrollbar is visible for the Pdf View (only iOS).                             |         **true**         |
| `spacing`                   | Spacing between pdf pages.                                                               |          **0**           |

This is a list of functional parameters.

| **Parameter**        | **Description**                                                       |    **Default Value**     |
|:---------------------|:----------------------------------------------------------------------|:------------------------:|
| `gestureRecognizers` | Which gestures should be consumed by the pdf view.                    | **-** |
| `onViewCreated`      | If not null invoked once the native view is created.                  | **-** |
| `onRender`           | Callback once the PDF page was loaded.                                | **-** |
| `onPageChanged`      | When changing the page, this method will be called with the new page. | **-** |
| `onZoomChanged`      | Called when changing the zoom.                                        | **-** |
| `onError`            | When there are errors happening, this methods returns a message.      | **-** |
| `onLinkHandle`       | Called when tapping a link in PDF. (only iOS)                         | **-** |


### AlhPdfViewController

If you want to start specific actions for the displayed PDF file, you can use `AlhPdfViewController`.
This controller contains some functionalities to update your view. Here is a list of them.

| **Parameter**          | **Description**                                                                                                                |
|:-----------------------|:-------------------------------------------------------------------------------------------------------------------------------|
| `getPageCount`         | Returns the number of pages for the PDF.                                                                                       |
| `getCurrentPage`       | Returns the current displayed page.                                                                                            |
| `setPage`              | Jumping to the page optionally animated.                                                                                       |
| `goToNextPage`         | Navigates to the next page of the PDF.                                                                                         |
| `goToPreviousPage`     | Navigates to the previous page of the PDF.                                                                                     |
| `resetZoom`            | Setting the scale factor to the default zoom factor.                                                                           |
| `setZoom`              | Zooming to the given zoom.                                                                                                     |
| `getZoom`              | Returns the current zoom value.                                                                                                |
| `getPageSize`          | Returns the size of the given [page] index. (only iOS)                                                                         |
| `setOrientation`       | Rebuilds pdf after the orientation was changed to ensure it is correctly displayed. (only Android for internal use)            |
| `updateCreationParams` | Reacts to any changes for `bytes`, `filePath`, `fitPolicy` and `showScrollbar`. (only for internal use)                        |
| `dispose`              | Called to cancel all subscription and disposing on the native part after the `AlhPdfView` was disposed (only for internal use) |

