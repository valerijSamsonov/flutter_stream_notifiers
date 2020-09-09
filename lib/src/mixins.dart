import 'dart:async';

import 'package:flutter/foundation.dart';

/// A mixin on [ValueNotifier] that streams a value on a change notification.
mixin ValueStream<T> on ValueNotifier<T> {
  /// Stream of [value] on a [value] change notification.
  ///
  /// A latest value is delivered on listen immediately.
  /// It allows multiple stream listeners.
  /// All streams are closed on [dispose].
  /// After it is disposed, any new stream is closed immediately
  /// without any values.
  Stream<T> get stream {
    return Stream.multi((controller) {
      if (_isDisposed) {
        controller.close();
        return;
      }

      final callback = () => controller.add(value);
      addListener(callback);
      controller
        ..onCancel = () {
          removeListener(callback);
          controller.close();
          controllers.remove(controller);
        }
        ..add(value);
      controllers.add(controller);
    });
  }

  /// Do super.dispose and close all the streams.
  ///
  /// The returned future completes when the all streams are closed.
  ///
  /// The return type is FutureOr<void>, because it respects the super class's
  /// behavior. By FutureOr<void>, No "unawaited_futures" static warning
  /// is reported if a client does not add "await" keyword.
  @override
  FutureOr<void> dispose() {
    super.dispose();

    final controllers = this.controllers;
    this.controllers = null;

    return Future.wait(controllers.map((c) {
      c.onCancel = null;
      return c.close();
    }));
  }

  @visibleForTesting
  // ignore: public_member_api_docs
  Set<MultiStreamController<T>> controllers = {};
  bool get _isDisposed => controllers == null;
}

/// A mixin on [ChangeNotifier] that streams a [T] extending [ChangeNotifier]
/// on a change notification.
mixin ChangeNotifierStream<T extends ChangeNotifier> on ChangeNotifier {
  /// Stream of [T] extending [ChangeNotifier], on a change notification.
  ///
  /// A latest value is delivered on listen immediately.
  /// It allows multiple stream listeners.
  /// All streams are closed on [dispose].
  /// After it is disposed, any new stream is closed immediately
  /// without any values.
  Stream<T> get stream {
    return Stream.multi((controller) {
      if (_isDisposed) {
        controller.close();
        return;
      }

      final callback = () {
        controller.add(this as T);
      };
      addListener(callback);
      controller
        ..onCancel = () {
          removeListener(callback);
          controller.close();
          controllers.remove(controller);
        }
        ..add(this as T);
      controllers.add(controller);
    });
  }

  /// Do super.dispose and close all the streams.
  ///
  /// The returned future completes when the all streams are closed.
  ///
  /// The return type is FutureOr<void>, because it respects the super class's
  /// behavior. By FutureOr<void>, No "unawaited_futures" static warning
  /// is reported if a client does not add "await" keyword.
  @override
  FutureOr<void> dispose() {
    super.dispose();

    final controllers = this.controllers;
    this.controllers = null;

    return Future.wait(controllers.map((c) {
      c.onCancel = null;
      return c.close();
    }));
  }

  @visibleForTesting
  // ignore: public_member_api_docs
  Set<MultiStreamController<T>> controllers = {};
  bool get _isDisposed => controllers == null;
}
