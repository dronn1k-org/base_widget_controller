part of '../reactive_widget_controller.dart';

extension RWCOnWidgetExt on Widget {
  Widget control<T>(BaseWidgetController<T> controller) =>
      RWCObserver(controller: controller, builder: (context, state) => this);
}
