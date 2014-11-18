
library when;

import 'dart:async';

/// Registers callbacks on the result of a [callback], which may or may not be
/// a [Future].
///
/// If the value is a Future, [onSuccess], [onError], and [onComplete] are
/// registered on it, and the resulting future is returned.
///
/// If [callback] returns a future, any callbacks are registered on the Future,
/// and the resulting future is returned.
///
/// Otherwise, if [callback] threw, [onError] is called synchronously with the
/// error, and the return value captured.  Otherwise [onSuccess] is called, and
/// the return value captured.  [onComplete] is then called.  The captured
/// value is then returned.
///
/// [onError] can take either just an error, or a stack trace as well.
when(callback, onSuccess(result), {onError, onComplete}) {
  var result, hasResult = false;

  try {
    result = callback();
    hasResult = true;
  } catch (e, s) {
    if (onError != null) {
      if (onError is _Unary) {
        result = onError(e);
      } else if (onError is _Binary) {
        result = onError(e, s);
      } else {
        throw new ArgumentError(
            '"onError" callback must accept 1 or 2 arguments: $onError');
      }
    } else {
      rethrow;
    }
  } finally {
    if (result is Future) {
      result = result.then(onSuccess, onError: onError);
      if (onComplete != null) result = result.whenComplete(onComplete);
    } else {
      if (hasResult) {
        result = onSuccess(result);
      }
      if (onComplete != null) onComplete();
    }
  }

  return result;
}

typedef _Unary(x);
typedef _Binary(x, y);
