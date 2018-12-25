import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/services.dart';

class ClipboardManager {
  static const MethodChannel _channel =
      const MethodChannel('clipboard_manager');

  static Future<bool> copyToClipBoard(dynamic content,
      [String contentType = 'text/plain']) async {
    if (content is String) {
      return await _channel.invokeMethod(
          'copyToClipBoard', <String, dynamic>{'content': content});
    }

    if (!contentType.startsWith('text/') && content is Uint8List) {
      return await _channel.invokeMethod('copyToClipBoard',
          <String, dynamic>{'content': content, 'content_type': contentType});
    }

    return false;
  }

  static Future<dynamic> pasteFromClipBoard() async {
    final dynamic result = await _channel.invokeMethod('pasteFromClipBoard');
    return result;
  }
}
