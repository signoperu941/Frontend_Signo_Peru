import 'package:dio/dio.dart';
import 'package:signo_peru_app/config/env.dart';
import 'package:signo_peru_app/config/env_variables.dart';

class TranslateService {
  final Dio _dio;

  TranslateService({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: '',
              connectTimeout: Duration(seconds: 60),
              receiveTimeout: Duration(seconds: 60),
            ));

  
  Future<Map<String, dynamic>> translate(MultipartFile file) async {
    await Env.init();
    final endpoint = '${EnvVariables.baseUrl}/video/predict';
    final formData = FormData.fromMap({'video': file});

    try {
      final response = await _dio.post(
        endpoint,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          headers: {
            'Accept': 'application/json',
            'User-Agent': 'Flutter-App/1.0',
          },
        ),
      );

      if (response.statusCode == 200 && response.data is Map) {
        final data = response.data as Map;
        return {
          'prediccion': data['prediccion']?.toString() ?? 'Sin prediccion',
          'certeza': (data['certeza'] as num?)?.toDouble() ?? 0.0,
        };
      }

      return _error('Error: Status ${response.statusCode}');

    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        return _error('Error: Servidor no responde');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        return _error('Error: Respuesta muy lenta');
      } else if (e.type == DioExceptionType.connectionError) {
        return _error('Error: Sin conexion');
      }
      return _error('Error de conexion');

    } catch (e) {
      return _error('Error inesperado');
    }
    }

  
  Map<String, dynamic> _error(String msg) => {
    'prediccion': msg,
    'certeza': 0.0,
   };
}