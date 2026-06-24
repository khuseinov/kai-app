import 'dart:convert';
import 'dart:typed_data';

import 'package:json_annotation/json_annotation.dart';

/// Decodes a base64-encoded audio string into [Uint8List].
class Base64AudioConverter implements JsonConverter<Uint8List, String> {
  const Base64AudioConverter();

  @override
  Uint8List fromJson(String json) => base64Decode(json);

  @override
  String toJson(Uint8List object) => base64Encode(object);
}
