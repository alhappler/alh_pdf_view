typedef RenderCallback = void Function(int pages);
typedef PageChangedCallback = void Function(int page, int total);
typedef ZoomChangedCallback = void Function(double zoom);
typedef ErrorCallback = void Function(dynamic error);
typedef PageErrorCallback = void Function(int page, dynamic error);
typedef LinkHandleCallback = void Function(String url);
