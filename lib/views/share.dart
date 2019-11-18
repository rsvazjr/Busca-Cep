import 'dart:async';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:meta/meta.dart' show visibleForTesting;

class Share {
  @visibleForTesting
  static const MethodChannel channel =
      MethodChannel('plugins.flutter.io/share');

  static Future<void> share(
    String text, {
    Rect sharePositionOrigin,
  }) {
    assert(text != null);
    assert(text.isNotEmpty);
    final Map<String, dynamic> params = <String, dynamic>{
      'text': text
    };

    if (sharePositionOrigin != null) {
      params['originX'] = sharePositionOrigin.left;
      params['originY'] = sharePositionOrigin.top;
      params['originWidth'] = sharePositionOrigin.width;
      params['originHeight'] = sharePositionOrigin.height;
    }

    return channel.invokeMethod<void>('share', params);
  }
}
