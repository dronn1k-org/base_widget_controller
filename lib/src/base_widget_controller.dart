part of '../reactive_widget_controller.dart';

enum _WidgetState { ready, loading, disposed }

/// Базовый класс для создания контроллеров к виджетам, способным обновлять своё состояние самостоятельно.
abstract base class BaseWidgetController<T> {
  _WidgetState _widgetState = _WidgetState.loading;

  final _widgetStateStreamCtrl = StreamController<_WidgetState>.broadcast();

  bool get isWidgetReady => _widgetState == _WidgetState.ready;

  T? _lastVariable;

  late Rv<T> _currentVariable;

  Rv<T> get reactive => _currentVariable;

  /// Текущее значение контроллера
  T get currentState => _currentVariable.value;

  BaseWidgetController({required T initialValue}) {
    _currentVariable = Rv<T>(initialValue);
    _listenForWidgetState((state) {
      _widgetState = state;
      if (state == _WidgetState.ready && _lastVariable != null) {
        _currentVariable.value = _lastVariable as T;
        _lastVariable = null;
      }
    });
  }

  /// Не используйте этот метод вне виджета для которого описан контроллер.
  ///
  /// Его нужно вызвать в виджете для которого написан этот контроллер:
  ///  * в самом начале `initState` (первой строкой) со значением [_WidgetState.loading],
  ///  * в конце `initState` (последней строкой) со значением [_WidgetState.ready],
  ///  * в методе `dispose` со значением [_WidgetState.disposed].
  void _changeWidgetSate(_WidgetState state) =>
      _widgetStateStreamCtrl.add(state);

  /// Изменяет значение контроллера
  void changeState(T newValue, [bool shouldTrigger = false]) {
    if (!isWidgetReady) {
      _lastVariable = newValue;
      return;
    }
    shouldTrigger
        ? _currentVariable.trigger(newValue)
        : _currentVariable(newValue);
  }

  StreamSubscription<_WidgetState> _listenForWidgetState(
    void Function(_WidgetState state) listener, {
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
  StreamSubscription<T> listenForStateChanges(
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
