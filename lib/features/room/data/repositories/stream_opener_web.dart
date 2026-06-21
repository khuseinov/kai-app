import 'dart:async';
import 'dart:js_util' as js_util;
import 'dart:typed_data';

Stream<List<int>> openWebStream(
  String url,
  String bodyJson,
  Map<String, String> headers,
) async* {
  final jsHeaders = js_util.newObject();
  headers.forEach((key, val) {
    js_util.setProperty(jsHeaders, key, val);
  });

  final jsOptions = js_util.newObject();
  js_util.setProperty(jsOptions, 'method', 'POST');
  js_util.setProperty(jsOptions, 'headers', jsHeaders);
  js_util.setProperty(jsOptions, 'body', bodyJson);

  final window = js_util.globalThis;
  final fetchPromise = js_util.callMethod<dynamic>(window, 'fetch', [url, jsOptions]);
  final response = await js_util.promiseToFuture<dynamic>(fetchPromise);

  final ok = js_util.getProperty<bool>(response, 'ok');
  if (!ok) {
    final status = js_util.getProperty<int>(response, 'status');
    throw Exception('HTTP $status');
  }

  final body = js_util.getProperty<dynamic>(response, 'body');
  if (body == null) return;

  final reader = js_util.callMethod<dynamic>(body, 'getReader', []);

  while (true) {
    final readPromise = js_util.callMethod<dynamic>(reader, 'read', []);
    final result = await js_util.promiseToFuture<dynamic>(readPromise);
    final done = js_util.getProperty<bool>(result, 'done');
    if (done) break;

    final value = js_util.getProperty<dynamic>(result, 'value');
    if (value != null) {
      final length = js_util.getProperty<int>(value, 'length');
      final list = Uint8List(length);
      for (var i = 0; i < length; i++) {
        list[i] = js_util.getProperty<int>(value, i);
      }
      yield list;
    }
  }
}
