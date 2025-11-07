import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class FileService {
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 12),
      receiveTimeout: const Duration(seconds: 30),
      followRedirects: true,
      headers: {
        'User-Agent':
            'Mozilla/5.0 (Linux; Android 14; MedhaAI) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0 Safari/537.36',
        'Accept': 'application/pdf,application/octet-stream,*/*',
      },
      responseType: ResponseType.bytes,
      validateStatus: (code) => code != null && code >= 200 && code < 400,
    ),
  );

  Future<Directory> _targetBaseDir() async {
    // Prefer app-scoped external files dir to avoid MANAGE_EXTERNAL_STORAGE requirements.
    try {
      final ext = await getExternalStorageDirectory();
      if (ext != null) {
        final appScoped = Directory('${ext.path}/MedhaAI');
        if (!await appScoped.exists()) {
          await appScoped.create(recursive: true);
        }
        return appScoped;
      }
    } catch (_) {}

    // Fallback to app documents directory.
    try {
      final docs = await getApplicationDocumentsDirectory();
      final fallback = Directory('${docs.path}/MedhaAI');
      if (!await fallback.exists()) await fallback.create(recursive: true);
      return fallback;
    } catch (_) {}

    // Last resort: public Documents (may fail without permission); attempt but ignore errors.
    final publicDocs = Directory('/storage/emulated/0/Documents/MedhaAI');
    if (!await publicDocs.exists()) {
      try { await publicDocs.create(recursive: true); } catch (_) {}
    }
    return publicDocs;
  }

  Future<String> ensureDownloaded({required String url, required String filename, void Function(int, int)? onProgress}) async {
    final dir = await _targetBaseDir();
    final filePath = '${dir.path}/$filename';
    final file = File(filePath);
    if (await file.exists() && await file.length() > 0) {
      return filePath;
    }
    final tmpPath = '$filePath.part';
    try {
      await _dio.download(url, tmpPath, onReceiveProgress: onProgress);
      final tmpFile = File(tmpPath);
      if (await tmpFile.exists()) {
        await tmpFile.rename(filePath);
      }
    } catch (e) {
      // Cleanup temp
      try { final f = File(tmpPath); if (await f.exists()) await f.delete(); } catch (_) {}
      rethrow;
    }
    return filePath;
  }

  Future<String> expectedPath(String filename) async {
    final dir = await _targetBaseDir();
    return '${dir.path}/$filename';
  }

  Future<bool> isDownloaded(String filename) async {
    final path = await expectedPath(filename);
    final f = File(path);
    return await f.exists() && await f.length() > 0;
  }
}
