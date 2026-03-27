import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:signo_peru_app/config/backend_client.dart';
import 'package:signo_peru_app/services/cache_service.dart';
import 'package:dio/dio.dart';
import 'dart:io';

class EspLspViewModel with ChangeNotifier {
  String sentence = "";
  VideoPlayerController? controller;
  Map<String, dynamic> signosData = {};
  bool isLoading = false;
  String? errorMessage;
  final Dio _dio = BackendClient.createDioClient();

  EspLspViewModel() {
    _loadSignosData();
  }

  Future<void> _loadSignosData() async {
    try {
      isLoading = true;
      notifyListeners();

      final response = await _dio.get('/busqueda/palabras-categorizadas');
      signosData = response.data['categorias'];

      isLoading = false;
      errorMessage = null;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      errorMessage = "Error al cargar datos de señas: $e";
      notifyListeners();
    }
  }

  Future<String?> findVideoUrl(String palabra) async {
    try {
      final response = await _dio.get('/busqueda/', queryParameters: {'q': palabra});
      final data = response.data;
      if (data['encontrada']) {
        final rutaRelativa = data['url_streaming'] as String;
        return '${BackendClient.env}$rutaRelativa';
      }
      return null;
    } catch (e) {
      print('[ViewModel] Error buscando video: $e');
      return null;
    }
  }

  void translate() async {
    if (sentence.trim().isEmpty) {
      errorMessage = "Por favor ingresa una palabra";
      notifyListeners();
      return;
    }

    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final String? videoUrl = await findVideoUrl(sentence);

      if (videoUrl == null) {
        isLoading = false;
        errorMessage = "La palabra '$sentence' no se encontró en el diccionario";
        controller = null;
        notifyListeners();
        return;
      }

      await _disposeController();
      CacheService.pauseBackgroundCaching();

      final cachedPath = await CacheService.getCachedVideoPath(sentence.trim());

      if (cachedPath != null) {
        print('[ViewModel] Usando cache: $cachedPath');
        controller = VideoPlayerController.file(File(cachedPath));
      } else {
        print('[ViewModel] Descargando desde backend: $videoUrl');
        controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));

        // Cachear en background para la próxima vez
        CacheService.cacheVideo(videoUrl: videoUrl, palabra: sentence.trim())
            .catchError((e) => print('[ViewModel] Error cacheando: $e'));
      }

      await controller!.initialize();
      controller!.play();

      controller!.addListener(() {
        if (controller!.value.position >= controller!.value.duration &&
            !controller!.value.isPlaying) {
          CacheService.resumeBackgroundCaching();
        }
      });

      isLoading = false;
      errorMessage = null;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      errorMessage = "Error al cargar el video: $e";
      controller = null;
      CacheService.resumeBackgroundCaching();
      notifyListeners();
    }
  }

  void updateSentence(String text) {
    sentence = text;
    notifyListeners();
  }

  Future<void> _disposeController() async {
    if (controller != null) {
      await controller!.dispose();
      controller = null;
      CacheService.resumeBackgroundCaching();
    }
  }

  Future<void> disposeModel() async {
    await _disposeController();
    notifyListeners();
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }
}
