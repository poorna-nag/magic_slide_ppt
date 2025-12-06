import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class DownloadService {
  final Dio _dio = Dio();

  Future<String> downloadFile(String url, String filename) async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        throw Exception('Storage permission denied');
      }
    }

    final dir = await getApplicationDocumentsDirectory();
    final filePath = '${dir.path}/$filename';
    final resp = await _dio.download(url, filePath);
    if (resp.statusCode == 200) {
      return filePath;
    } else {
      throw Exception('Failed to download file: ${resp.statusCode}');
    }
  }
}