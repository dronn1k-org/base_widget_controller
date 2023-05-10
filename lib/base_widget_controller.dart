library base_widget_controller;

import 'dart:async';

import 'package:base_widget_controller/enum/widget_state.dart';
import 'package:flutter/material.dart';
import 'package:reactive_variables/reactive_variables.dart';

/// Базовый класс для создания контроллеров к виджетам, способным обновлять своё состояние самостоятельно.
abstract class BaseWidgetController<T> {
  WidgetState _widgetState = WidgetState.loading;

  /// Состояние виджета для которого описан контроллер
  WidgetState get widgetState => _widgetState;
  final _widgetStateStreamCtrl = StreamController<WidgetState>.broadcast();

  bool get isWidgetReady => _widgetState == WidgetState.ready;

  T? _lastVariable;

  late Rv<T> _currentVariable;

  Rv<T> get reactive => _currentVariable;

  /// Текущее значение контроллера
  T get currentValue => _currentVariable.value;

  @mustCallSuper
  BaseWidgetController({required T initialValue}) {
    _currentVariable = Rv<T>(initialValue);
    listenForWidgetState((state) {
      _widgetState = state;
      if (state == WidgetState.ready && _lastVariable != null) {
        _currentVariable.value = _lastVariable as T;
        _lastVariable = null;
      }
    });
  }

  /// Не используйте этот метод вне виджета для которого описан контроллер.
  ///
  /// Его нужно вызвать в виджете для которого написан этот контроллер:
  ///  * в самом начале `initState` (первой строкой) со значением [WidgetState.loading],
  ///  * в конце `initState` (последней строкой) со значением [WidgetState.ready],
  ///  * в методе `dispose` со значением [WidgetState.disposed].
  void changeWidgetSate(WidgetState state) => _widgetStateStreamCtrl.add(state);

  /// Изменяет значение контроллера
  void changeValue(T newValue, [bool shouldTrigger = false]) {
    if (!isWidgetReady) {
      _lastVariable = newValue;
      return;
    }
    shouldTrigger
        ? _currentVariable.trigger(newValue)
        : _currentVariable(newValue);
  }

  StreamSubscription<WidgetState> listenForWidgetState(
    void Function(WidgetState state) listener, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) =>
      _widgetStateStreamCtrl.stream.listen(
        listener,
        onDone: onDone,
        onError: onError,
        cancelOnError: cancelOnError,
      );

  /// Подписка на изменение значения контроллера.
  /// Используете как внутри виджета для изменения состояния виджета при изменении значения контроллера,
  /// так и вне виджета, если потребуется.
  StreamSubscription<T> listenForValue(
    void Function(T value) listener, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) =>
      _currentVariable.listen(
        listener,
        onDone: onDone,
        onError: onError,
        cancelOnError: cancelOnError,
      );
}
