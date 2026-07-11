import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// Returns a debounced [callback] that delays invocation until [duration]
/// has elapsed since the last call.
///
/// Pending timers are cancelled when the widget is disposed.
/// Call [DebouncedCallback.cancel] to drop a pending invocation early
/// (e.g. when clearing a search field immediately).
DebouncedCallback<T> useDebouncedCallback<T>(
  void Function(T value) callback, {
  Duration duration = const Duration(milliseconds: 300),
}) {
  final timerRef = useRef<Timer?>(null);
  final callbackRef = useRef(callback);
  callbackRef.value = callback;

  useEffect(() {
    return () => timerRef.value?.cancel();
  }, const []);

  return DebouncedCallback<T>(
    call: (value) {
      timerRef.value?.cancel();
      timerRef.value = Timer(duration, () => callbackRef.value(value));
    },
    cancel: () => timerRef.value?.cancel(),
  );
}

/// Handle returned by [useDebouncedCallback].
class DebouncedCallback<T> {
  const DebouncedCallback({
    required this.call,
    required this.cancel,
  });

  final void Function(T value) call;
  final VoidCallback cancel;
}
