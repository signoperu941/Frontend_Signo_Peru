import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import '../model/cached_video.dart';

class StorageService {
  static const String _cacheDir = 'lsp_videos';

  static Future<Directory> getCacheDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory('${appDir.path}/$_cacheDir');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  /// Nombre del archivo: palabra normalizada sin tildes ni espacios.
  static String _fileName(String palabra) {
    final clean = palabra
        .toLowerCase()
        .replaceAll(RegExp(r'[áàäâã]'), 'a')
        .replaceAll(RegExp(r'[éèëê]'), 'e')
        .replaceAll(RegExp(r'[íìïî]'), 'i')
        .replaceAll(RegExp(r'[óòöôõ]'), 'o')
        .replaceAll(RegExp(r'[úùüû]'), 'u')
        .replaceAll(RegExp(r'[ñ]'), 'n')
        .replaceAll(RegExp(r'[^a-z0-9]'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
    return '$clean.mp4';
  }

  static Future<File> _videoFile(String palabra) async {
    final dir = await getCacheDirectory();
    return File('${dir.path}/${_fileName(palabra)}');
  }

  static Future<bool> videoExists(String palabra) async {
    try {
      final file = await _videoFile(palabra);
      if (!await file.exists()) return false;
      return (await file.stat()).size > 0;
    } catch (_) {
      return false;
    }
  }

  static Future<String?> getCachedVideoPath(String palabra) async {
    try {
      final file = await _videoFile(palabra);
      if (await file.exists() && (await file.stat()).size > 0) {
        return file.path;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<CachedVideo> downloadAndSave({
    required String videoUrl,
    required String palabra,
    void Function(int downloaded, int total)? onProgress,
  }) async {
    final file = await _videoFile(palabra);

    if (await videoExists(palabra)) {
      return CachedVideo(
        palabra: palabra,
        originalUrl: videoUrl,
        localPath: file.path,
        downloadedAt: (await file.stat()).modified,
      );
    }

    print('[Storage] Descargando: $palabra');
    final bytes = await _download(videoUrl, onProgress);
    await file.writeAsBytes(bytes);
    print('[Storage] Guardado: ${file.path} (${bytes.length} bytes)');

    return CachedVideo(
      palabra: palabra,
      originalUrl: videoUrl,
      localPath: file.path,
      downloadedAt: DateTime.now(),
    );
  }

  static Future<Uint8List> _download(
    String url,
    void Function(int, int)? onProgress,
  ) async {
    final request = http.Request('GET', Uri.parse(url));
    final response = await http.Client().send(request).timeout(
      const Duration(minutes: 2),
    );

    if (response.statusCode != 200) {
      throw HttpException('HTTP ${response.statusCode} al descargar $url');
    }

    final total = response.contentLength ?? 0;
    final bytes = <int>[];

    await for (final chunk in response.stream) {
      bytes.addAll(chunk);
      onProgress?.call(bytes.length, total);
    }

    return Uint8List.fromList(bytes);
  }

  static Future<bool> deleteVideo(String palabra) async {
    try {
      final file = await _videoFile(palabra);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> clearAll() async {
    try {
      final dir = await getCacheDirectory();
      await for (final entity in dir.list()) {
        if (entity is File) await entity.delete();
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<String> getCacheSizeFormatted() async {
    try {
      final dir = await getCacheDirectory();
      int total = 0;
      await for (final entity in dir.list()) {
        if (entity is File) total += (await entity.stat()).size;
      }
      if (total >= 1024 * 1024) return '${(total / (1024 * 1024)).toStringAsFixed(1)} MB';
      if (total >= 1024) return '${(total / 1024).toStringAsFixed(1)} KB';
      return '$total bytes';
    } catch (_) {
      return '0 bytes';
    }
  }
}
