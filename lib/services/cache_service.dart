import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signo_peru_app/config/backend_client.dart';
import 'package:dio/dio.dart';
import '../model/cached_video.dart';
import 'storage_service.dart';

class CacheService {
  static const String _prefsKey = 'cached_videos_v2';

  static final Map<String, CachedVideo> _cache = {};
  static bool _initialized = false;
  static bool _backgroundActive = false;
  static bool _paused = false;

  static final Dio _dio = BackendClient.createDioClient();

  // ── Inicialización ─────────────────────────────────────────────────────────

  static Future<void> initialize() async {
    if (_initialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw != null) {
        final list = json.decode(raw) as List<dynamic>;
        for (final item in list) {
          final video = CachedVideo.fromJson(item as Map<String, dynamic>);
          _cache[_key(video.palabra)] = video;
        }
      }
      print('[Cache] Inicializado: ${_cache.length} videos en cache');
    } catch (e) {
      print('[Cache] Error al inicializar: $e');
    }
    _initialized = true;
  }

  // ── API pública ────────────────────────────────────────────────────────────

  static Future<bool> isVideoCached(String palabra) async {
    _ensureInit();
    if (_cache.containsKey(_key(palabra))) return true;
    return await StorageService.videoExists(palabra);
  }

  static Future<String?> getCachedVideoPath(String palabra) async {
    _ensureInit();
    final cached = _cache[_key(palabra)];
    if (cached != null) return cached.localPath;
    return await StorageService.getCachedVideoPath(palabra);
  }

  static Future<CachedVideo?> cacheVideo({
    required String videoUrl,
    required String palabra,
    void Function(int downloaded, int total)? onProgress,
  }) async {
    _ensureInit();
    if (await isVideoCached(palabra)) {
      return _cache[_key(palabra)];
    }

    try {
      final video = await StorageService.downloadAndSave(
        videoUrl: videoUrl,
        palabra: palabra,
        onProgress: onProgress,
      );
      _cache[_key(palabra)] = video;
      await _persist();
      print('[Cache] Cacheado: $palabra');
      return video;
    } catch (e) {
      print('[Cache] Error cacheando $palabra: $e');
      return null;
    }
  }

  // ── Cache en background ────────────────────────────────────────────────────

  static Future<void> startBackgroundCaching() async {
    if (_backgroundActive) return;
    _backgroundActive = true;
    _paused = false;
    print('[Cache] Iniciando cache en background...');
    _runBackground();
  }

  static void pauseBackgroundCaching() {
    _paused = true;
    print('[Cache] Background pausado');
  }

  static void resumeBackgroundCaching() {
    _paused = false;
    print('[Cache] Background reanudado');
  }

  static void stopBackgroundCaching() {
    _backgroundActive = false;
    _paused = false;
    print('[Cache] Background detenido');
  }

  static Future<void> clearAll() async {
    await StorageService.clearAll();
    _cache.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
    print('[Cache] Cache limpiado');
  }

  static Future<String> getCacheSize() => StorageService.getCacheSizeFormatted();

  // ── Privados ───────────────────────────────────────────────────────────────

  static String _key(String palabra) => palabra.trim().toLowerCase();

  static void _ensureInit() {
    if (!_initialized) initialize();
  }

  static Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = _cache.values.map((v) => v.toJson()).toList();
      await prefs.setString(_prefsKey, json.encode(list));
    } catch (e) {
      print('[Cache] Error persistiendo: $e');
    }
  }

  static Future<void> _runBackground() async {
    try {
      final response = await _dio.get('/busqueda/learn-data');
      final datos = response.data['datos_completos'] as Map<String, dynamic>;

      for (final catData in datos.values) {
        if (!_backgroundActive) break;
        if (catData is! Map<String, dynamic>) continue;

        for (final items in catData.values) {
          if (!_backgroundActive) break;
          if (items is! List) continue;

          for (final item in items) {
            // Pausar si hay reproducción activa
            while (_paused && _backgroundActive) {
              await Future.delayed(const Duration(seconds: 2));
            }
            if (!_backgroundActive) break;

            if (item is Map<String, dynamic> &&
                item['palabra'] != null &&
                item['ruta_local'] != null) {
              final palabra = item['palabra'] as String;
              final enlace = '${_dio.options.baseUrl}${item['ruta_local']}';

              if (!await isVideoCached(palabra)) {
                await cacheVideo(videoUrl: enlace, palabra: palabra);
                await Future.delayed(const Duration(milliseconds: 500));
              }
            }
          }
        }
      }

      print('[Cache] Background completado');
    } catch (e) {
      print('[Cache] Error en background: $e');
    } finally {
      _backgroundActive = false;
    }
  }
}
