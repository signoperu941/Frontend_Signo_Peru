import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:signo_peru_app/config/backend_client.dart';
import 'package:signo_peru_app/services/translate_service.dart';
import 'package:http_parser/http_parser.dart';

class VideoModel {
  CameraController? cameraController;
  XFile? videoFile;
  
  late final Dio _dio;
  late final TranslateService _translateService;

  VideoModel(){
    _dio = BackendClient.createDioClient();
    _translateService = TranslateService(dio: _dio);
  }

  void disposeModel() {
    cameraController!.dispose();
  }

Future<Map<String, dynamic>> sendVideoToServer(XFile file) async {
  final multipartFile = await MultipartFile.fromFile(
    file.path,
    contentType: MediaType('video', 'mp4'),
  );

  return await _translateService.translate(multipartFile);
}
}