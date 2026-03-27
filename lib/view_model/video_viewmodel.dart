import 'dart:io';
import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:signo_peru_app/model/video_model.dart';
import 'package:signo_peru_app/services/translate_service.dart';

class VideoViewModel with ChangeNotifier {
  final VideoModel videoModel;
  final TranslateService service = TranslateService();

  bool _isRecording = false;
  bool get isRecording => _isRecording;

  bool _isProcessing = false;
  bool get isProcessing => _isProcessing;

  String res = "";
  double certeza = 0.0;
  int count = 0;
  bool isFrontCamera = true;

  double _recordingDuration = 3.0;
  double get recordingDuration => _recordingDuration;
  bool _isCorrect = false;
  bool get isCorrect => _isCorrect;

  Future<void> validation(String word) async {
    _isCorrect = res.toLowerCase() == word.toLowerCase();
    notifyListeners();
  }

  VideoViewModel(this.videoModel) {
    _initController();
  }

  void setRecordingDuration(double value) {
    _recordingDuration = value;
    notifyListeners();
  }

  Future<void> _initController() async {
    await Permission.camera.request();
    final cameras = await availableCameras();
    final selectedCamera = cameras.firstWhere(
      (camera) => camera.lensDirection ==
          (isFrontCamera ? CameraLensDirection.front : CameraLensDirection.back),
    );
    videoModel.cameraController = CameraController(
      selectedCamera,
      ResolutionPreset.high,
      fps: 30,
    );
    await videoModel.cameraController!.initialize();
    notifyListeners();
  }

  void setCamera() async {
    isFrontCamera = !isFrontCamera;
    await videoModel.cameraController!.dispose();
    await _initController();
    notifyListeners();
  }

  Future<void> start() async {
    res = "";
    count = 3;
    notifyListeners();

    for (int i = 3; i >= 1; i--) {
      await Future.delayed(Duration(seconds: 1));
      count--;
      notifyListeners();
    }

    await startRecording();
    count = 0;
    notifyListeners();
  }

  Future<void> startRecording() async {
    if (_isRecording) return;

    _isRecording = true;
    notifyListeners();

    try {
      if (videoModel.cameraController == null ||
          !videoModel.cameraController!.value.isInitialized) {
        throw Exception("Camera controller is not initialized");
      }

      await videoModel.cameraController!.startVideoRecording();
      await Future.delayed(Duration(milliseconds: (_recordingDuration * 1000).toInt()));
      await _stopRecording();

    } catch (e) {
      res = "Error: $e";
      _isRecording = false;
      notifyListeners();
    }
  }

  Future<void> _stopRecording() async {
    try {
      final XFile recordedFile = await videoModel.cameraController!.stopVideoRecording();
      _isRecording = false;
      _isProcessing = true;
      notifyListeners();

      final file = File(recordedFile.path);
      final multipartFile = await MultipartFile.fromFile(
        file.path,
        filename: file.uri.pathSegments.last,
      );

      final result = await service.translate(multipartFile);
      res = result['prediccion'];
      certeza = (result['certeza'] as num).toDouble();

    } catch (e) {
      res = "Error: $e";
      certeza = 0.0;
    } finally {
      _isRecording = false;
      _isProcessing = false;
      notifyListeners();
    }
  }

  Future<void> disposeModel() async {
    await videoModel.cameraController?.dispose();
    notifyListeners();
  }
}