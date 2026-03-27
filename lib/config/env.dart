import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static final Env _instance = Env._internal();

  // Constructor privado
  Env._internal();

  // Constructor público que devuelve la única instancia
  factory Env() => _instance;

  /// Carga el archivo .env una vez
  static Future<void> init({String fileName = '.env'}) async {
    await dotenv.load(fileName: fileName);
  }

  /// Permite usar env['KEY']
  String require(String key) =>
      dotenv.env[key] ?? (throw Exception('La variable $key no está definida.'));

}