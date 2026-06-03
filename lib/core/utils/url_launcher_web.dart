import 'dart:js_interop';

@JS('window.open')
external void _jsWindowOpen(String url, String target);

/// Cross-platform launcher implementation for web using pure JS interop.
void launchUrlString(String url) {
  _jsWindowOpen(url, '_blank');
}
