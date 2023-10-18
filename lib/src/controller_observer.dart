part of '../reactive_widget_controller.dart';

class RWCObserver<T> extends StatefulWidget {
  final BaseWidgetController<T> controller;
  final Widget child;

  const RWCObserver({
    super.key,
    required this.controller,
    required this.child,
  });

  @override
  State<RWCObserver<T>> createState() => _RWCObserverState<T>();
}

class _RWCObserverState<T> extends State<RWCObserver<T>> {
  StreamSubscription<T>? _stateListener;

  @override
  void initState() {
    super.initState();
    _stateListener = widget.controller.listenForStateChanges((value) {
      if (mounted) setState(() {});
    });
    widget.controller._changeWidgetSate(_WidgetState.ready);
  }

  @override
  void dispose() {
    widget.controller._changeWidgetSate(_WidgetState.disposed);
    _stateListener?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
