import 'package:dio/dio.dart';
import 'package:signo_peru_app/config/env_variables.dart';

class BackendClient {
  static final env = EnvVariables.baseUrl;
  static Dio createDioClient() {

    final options = BaseOptions(
      baseUrl: env,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    final dio = Dio(options);

    return dio;
  }
}