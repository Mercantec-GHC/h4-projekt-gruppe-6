import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

enum ApiService {
  auth,
  app,
}

Future<String?> request(BuildContext context, ApiService service, String method, String path, Object? body) async {
  final messenger = ScaffoldMessenger.of(context);

  final host = switch (service) {
    ApiService.auth => const String.fromEnvironment('AUTH_SERVICE_HOST'),
    ApiService.app => const String.fromEnvironment('APP_SERVICE_HOST'),
  };

  final http.Response response;

  try {
    if (method == 'GET') {
      response = await http.get(Uri.parse(host + path));
    } else {
      final function = switch (method) {
        'POST' => http.post,
        'PUT' => http.put,
        'DELETE' => http.delete,
        _ => throw const FormatException('Invalid method'),
      };

      response = await function(
        Uri.parse(host + path),
        headers: {'Content-Type': 'application/json'},
        body: body != null ? jsonEncode(body) : null,
      );
    }
  } catch (_) {
    messenger.showSnackBar(const SnackBar(content: Text('Unable to connect to server')));
    return null;
  }

  if (response.statusCode < 200 || response.statusCode >= 300) {
    try {
      final json = jsonDecode(response.body);
      messenger.showSnackBar(SnackBar(content: Text(json['message'])));
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text('Something went wrong (HTTP ${response.statusCode})')));
    }
    return null;
  }

  return response.body;
}