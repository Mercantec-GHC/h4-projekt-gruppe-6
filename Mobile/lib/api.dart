import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

enum ApiService {
  auth,
  app,
}

Future<String?> request(BuildContext? context, ApiService service, String method, String path, Object? body) async {
  final messenger = context != null ? ScaffoldMessenger.of(context) : null;
  final prefs = await SharedPreferences.getInstance();

  final host = switch (service) {
    ApiService.auth => const String.fromEnvironment('AUTH_SERVICE_HOST'),
    ApiService.app => const String.fromEnvironment('APP_SERVICE_HOST'),
  };

  final token = prefs.getString('token');
  final Map<String, String> headers = {};
  if (token != null) headers.addAll({'Authorization': 'Bearer $token'});

  final http.Response response;

  try {
    if (method == 'GET') {
      response = await http.get(Uri.parse(host + path), headers: headers);
    } else {
      final function = switch (method) {
        'POST' => http.post,
        'PUT' => http.put,
        'DELETE' => http.delete,
        _ => throw const FormatException('Invalid method'),
      };

      headers.addAll({'Content-Type': 'application/json'});

      response = await function(
        Uri.parse(host + path),
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );
    }
  } catch (e) {
    debugPrint(e.toString());
    messenger?.showSnackBar(const SnackBar(content: Text('Unable to connect to server')));
    return null;
  }

  if (response.statusCode < 200 || response.statusCode >= 300) {
    try {
      final json = jsonDecode(response.body);
      messenger?.showSnackBar(SnackBar(content: Text(json['message'])));
      debugPrint('API error: ' + json['message']);
    } catch (e) {
      debugPrint(e.toString());
      messenger?.showSnackBar(SnackBar(content: Text('Something went wrong (HTTP ${response.statusCode})')));
    }
    return null;
  }

  return utf8.decode(response.bodyBytes);
}

Future<bool> isLoggedIn(BuildContext context) async {
  final messenger = ScaffoldMessenger.of(context);
  final prefs = await SharedPreferences.getInstance();

  final token = prefs.getString('token');
  if (token == null) {
    prefs.remove('id');
    return false;
  }

  try {
    String base64 = token.split('.')[1];
    base64 += List.filled(base64.length % 4 == 0 ? 0 : 4 - base64.length % 4, '=').join();

    final payload = jsonDecode(String.fromCharCodes(base64Decode(base64)));

    if (payload['exp'] < DateTime.now().millisecondsSinceEpoch / 1000) {
      messenger.showSnackBar(const SnackBar(content: Text('Token expired, please sign in again')));
      prefs.remove('token');
      return false;
    }
  } catch (e) {
    messenger.showSnackBar(const SnackBar(content: Text('Invalid token, please sign in again')));
    prefs.remove('token');
    debugPrint(e.toString());
    return false;
  }

  return true;
}
