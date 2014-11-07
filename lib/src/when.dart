
library when;

import 'dart:async';

/// Calls [callback] and registers callbacks on the result, which are fired
/// asynchronously if it's a [Future] and synchronously otherwise.
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
        onError(e);
      } else if (onError is _Binary) {
        onError(e, s);
      } else {
        throw new ArgumentError(
            '"onError" callback must accept 1 or 2 arguments: $onError');
      }
      result = onError(e);
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
