import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path/path.dart' as p;

enum ApiService {
  auth,
  app,
}

Future<String?> request(BuildContext? context, ApiService service, String method, String path, dynamic body) async {
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
        body: body is Uint8List ? body : (body is Object ? jsonEncode(body) : null),
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
      messenger?.showSnackBar(SnackBar(content: Text(json['message'] ?? json['title'])));
      debugPrint('API error: ' + json['message']);
    } catch (e) {
      debugPrint(e.toString());
      messenger?.showSnackBar(SnackBar(content: Text('Something went wrong (HTTP ${response.statusCode})')));
    }
    return null;
  }

  return utf8.decode(response.bodyBytes);
}

Future<String?> putUser(
  BuildContext? context,
  ApiService service,
  String method,
  String path,
  Map<String, dynamic> body,
  File? profilePicture // The image file
) async {
  final messenger = context != null ? ScaffoldMessenger.of(context) : null;
  final prefs = await SharedPreferences.getInstance();
  final host = const String.fromEnvironment('AUTH_SERVICE_HOST');

  final token = prefs.getString('token');
  final Map<String, String> headers = {};
  if (token != null) headers.addAll({'Authorization': 'Bearer $token'});

  // Create the Uri
  var uri = Uri.parse(host + path);

  // Create a MultipartRequest
  var request = http.MultipartRequest('PUT', uri);
  request.headers.addAll(headers);

  // Add form fields
  request.fields['id'] = body['id'];
  request.fields['username'] = body['username'];
  request.fields['email'] = body['email'];
  request.fields['password'] = body['password'];

  // Attach the file to the request (if provided)
  if (profilePicture != null) {
    var fileStream = http.ByteStream(profilePicture.openRead());
    var length = await profilePicture.length();
    var multipartFile = http.MultipartFile(
      'ProfilePicture', // field name matches your backend DTO
      fileStream,
      length,
      filename: p.basename(profilePicture.path),
    );
    request.files.add(multipartFile);
  }

  try {
    // Send the request
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    // Handle non-success responses
    if (response.statusCode < 200 || response.statusCode >= 300) {
      try {
        final json = jsonDecode(response.body);
        messenger?.showSnackBar(SnackBar(content: Text(json['message'] ?? json['title'])));
        debugPrint('API error: ' + json['message']);
      } catch (e) {
        debugPrint(e.toString());
        messenger?.showSnackBar(SnackBar(content: Text('Something went wrong (HTTP ${response.statusCode})')));
      }
      return null;
    }

    return utf8.decode(response.bodyBytes);
  } catch (e) {
    debugPrint(e.toString());
    messenger?.showSnackBar(const SnackBar(content: Text('Unable to connect to server')));
    return null;
  }
}


Future<File> _compressImage(File file) async {
    final filePath = file.absolute.path;
    final lastIndex = filePath.lastIndexOf(RegExp(r'.jp'));
    final splitted = filePath.substring(0, lastIndex);
    final outPath = "${splitted}_compressed.jpg";

    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      outPath,
      quality: 80,
      minWidth: 1024,
      minHeight: 1024,
    );

    return File(result!.path);
  }

Future<bool> isLoggedIn(BuildContext context) async {
  final messenger = ScaffoldMessenger.of(context);
  final prefs = await SharedPreferences.getInstance();

  final token = prefs.getString('token');
  if (token == null) {
    logout();
    return false;
  }

  try {
    String base64 = token.split('.')[1];
    base64 += List.filled(base64.length % 4 == 0 ? 0 : 4 - base64.length % 4, '=').join();

    final payload = jsonDecode(String.fromCharCodes(base64Decode(base64)));

    if (payload['exp'] < DateTime.now().millisecondsSinceEpoch / 1000) {
      messenger.showSnackBar(const SnackBar(content: Text('Token expired, please sign in again')));

      logout();
      return false;
    }
  } catch (e) {
    messenger.showSnackBar(const SnackBar(content: Text('Invalid token, please sign in again')));
    debugPrint(e.toString());

    logout();
    return false;
  }

  return true;
}

void logout() async {
  final prefs = await SharedPreferences.getInstance();

  prefs.remove('token');
  prefs.remove('refresh-token');
  prefs.remove('id');
}
