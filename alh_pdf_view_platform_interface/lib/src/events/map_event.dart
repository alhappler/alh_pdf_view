import 'package:alh_pdf_view_platform_interface/src/types/map_event/page_changed_object.dart';
import 'package:alh_pdf_view_platform_interface/src/types/map_event/page_error_object.dart';

/// This class is used to notify method calls from the native part.
class MapEvent<T> {
  MapEvent(this.viewId, this.value);

  final int viewId;

  final T value;
}

class OnRenderEvent extends MapEvent<int> {
  OnRenderEvent(super.viewId, super.pageCount);
}

class OnPageChangedEvent extends MapEvent<PageChangedObject> {
  OnPageChangedEvent(super.viewId, super.pageChangedObject);
}

class OnErrorEvent extends MapEvent<String> {
  OnErrorEvent(super.viewId, super.error);
}

class OnPageErrorEvent extends MapEvent<PageErrorObject> {
  OnPageErrorEvent(super.viewId, super.pageErrorObject);
}

class OnZoomChangedEvent extends MapEvent<double> {
  OnZoomChangedEvent(super.viewId, super.zoom);
}

class OnLinkHandleEvent extends MapEvent<String> {
  OnLinkHandleEvent(super.viewId, super.url);
}
