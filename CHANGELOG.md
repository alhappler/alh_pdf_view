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
