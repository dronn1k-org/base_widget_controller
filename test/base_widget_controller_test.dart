import 'package:base_widget_controller/enum/widget_state.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:base_widget_controller/base_widget_controller.dart';

class IntCtrl extends BaseWidgetController<int> {
  IntCtrl({required super.initialValue});
}

void main() {
  late IntCtrl ctrl;

  setUpAll(() {
    ctrl = IntCtrl(initialValue: 0);
  });
  test('some tests', () {
    expect(ctrl.widgetState, WidgetState.loading);
    expect(ctrl.currentValue, 0);
    ctrl.changeValue(1);
    expect(ctrl.currentValue, 0);
    ctrl.changeWidgetSate(WidgetState.ready);
    expect(ctrl.widgetState, WidgetState.ready);
    expect(ctrl.currentValue, 1);
    ctrl.changeValue(2);
    expect(ctrl.currentValue, 2);
  });
}
