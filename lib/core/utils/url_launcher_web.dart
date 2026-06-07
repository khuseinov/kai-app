import 'dart:js_interop';

@JS('window.open')
external void _jsWindowOpen(JSString url, JSString target);

/// Cross-platform launcher implementation for web using pure JS interop.
void launchUrlString(String url) {
  _jsWindowOpen(url.toJS, '_blank'.toJS);
}
