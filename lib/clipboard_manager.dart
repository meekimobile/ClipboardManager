import 'dart:async';
import 'package:flutter/services.dart';

class ClipboardManager {
  static const MethodChannel _channel = const MethodChannel('clipboard_manager');

  static Future<bool> copyToClipBoard(dynamic content, String contentType) async {
    final dynamic result = await _channel.invokeMethod('copyToClipBoard', <String, dynamic>{'content': content, 'contentType': contentType});
    return result;
  }

  static Future<dynamic> pasteFromClipBoard() async {
    final dynamic result = await _channel.invokeMethod('pasteFromClipBoard');
    return result;
  }
}
