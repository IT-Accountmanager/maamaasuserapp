import 'package:flutter/services.dart';

class ApiKeyService {
  static const MethodChannel _channel = MethodChannel('com.maamaas.app/maps');

  static Future<String> getApiKey() async {
    final key = await _channel.invokeMethod<String>('getApiKey');
    return key ?? '';
  }
}