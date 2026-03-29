import 'package:dio/dio.dart';
import 'package:signo_peru_app/config/env.dart';
import 'package:signo_peru_app/config/env_variables.dart';

class DonationService {
  final Dio _dio;

  DonationService()
      : _dio = Dio(BaseOptions(
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 60),
        ));

  Future<List<String>> fetchAllWords() async {
    await Env.init();
    final baseUrl = EnvVariables.baseUrl;
    try {
      final res = await _dio.get('$baseUrl/busqueda/palabras-categorizadas');
      final data = res.data as Map<String, dynamic>;
      final categorias = data['categorias'] as Map<String, dynamic>;
      final words = <String>{};
      for (final cat in categorias.values) {
        if (cat is Map<String, dynamic>) {
          for (final sub in cat.values) {
            if (sub is List) {
              for (final p in sub) {
                if (p is Map<String, dynamic> && p['palabra'] != null) {
                  words.add(p['palabra'].toString());
                }
              }
            }
          }
        }
      }
      return words.toList()..sort();
    } catch (_) {
      return [];
    }
  }

  Future<String?> fetchVideoUrl(String word) async {
    await Env.init();
    final baseUrl = EnvVariables.baseUrl;
    try {
      final res = await _dio.get(
        '$baseUrl/busqueda/',
        queryParameters: {'q': word},
      );
      final data = res.data as Map<String, dynamic>;
      if (data['encontrada'] == true && data['url_streaming'] != null) {
        String url = data['url_streaming'].toString();
        if (url.contains('localhost') || url.contains('127.0.0.1')) {
          try {
            final uri = Uri.parse(url);
            url = '$baseUrl${uri.path}${uri.query.isNotEmpty ? '?${uri.query}' : ''}';
          } catch (_) {}
        } else if (url.startsWith('/')) {
          url = '$baseUrl$url';
        }
        return url;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> submitDonation({
    required String nombre,
    required String correo,
    required String dni,
    required String telefono,
    required String sena,
    required String firmaBase64,
    required String videoPath,
  }) async {
    await Env.init();
    final baseUrl = EnvVariables.baseUrl;

    final formData = FormData.fromMap({
      'nombre': nombre,
      'correo': correo,
      'dni': dni,
      'telefono': telefono,
      'sena': sena,
      'firma_base64': firmaBase64,
      'video': await MultipartFile.fromFile(
        videoPath,
        filename: 'grabacion_movil.mp4',
      ),
    });

    final response = await _dio.post(
      '$baseUrl/donacion/subir',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );

    if (response.statusCode != null &&
        response.statusCode! >= 400) {
      throw Exception('Error del servidor: ${response.statusCode}');
    }
  }
}
