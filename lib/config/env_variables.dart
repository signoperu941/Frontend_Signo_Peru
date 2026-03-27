import 'package:signo_peru_app/config/env.dart';

class EnvVariables {
  static String get baseUrl => Env().require('BASE_URL');
}