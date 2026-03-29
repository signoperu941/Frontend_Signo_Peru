import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';
import 'package:signo_peru_app/services/donation_service.dart';

enum DonationCameraState {
  uninitialized,
  loading,
  idle,
  countdown,
  recording,
  recorded,
  submitting,
  submitted,
  error,
}

enum SignType { diccionario, nueva }

class DonationViewModel with ChangeNotifier {
  final DonationService _service = DonationService();

  // ── Cámara ──────────────────────────────────────────────────────────────────
  CameraController? cameraController;
  DonationCameraState cameraState = DonationCameraState.uninitialized;
  bool isFrontCamera = true;
  int countdownValue = 0;
  XFile? recordedFile;
  String? cameraError;

  // ── Selección de seña ────────────────────────────────────────────────────────
  SignType signType = SignType.diccionario;
  String? selectedSign;
  String newSignName = '';
  bool isNewSignConfirmed = false;

  // ── Palabras del diccionario ─────────────────────────────────────────────────
  List<String> allWords = [];
  bool isLoadingWords = false;

  // ── Video de referencia ──────────────────────────────────────────────────────
  VideoPlayerController? referenceVideoController;
  bool isLoadingReferenceVideo = false;
  bool referenceVideoNotFound = false;

  // ── Consentimiento ───────────────────────────────────────────────────────────
  bool hasConsented = false;
  Map<String, dynamic>? consentData;

  // ── Envío ────────────────────────────────────────────────────────────────────
  String? submitMessage;
  bool? submitSuccess;

  // ── Palabras ─────────────────────────────────────────────────────────────────

  Future<void> fetchWords() async {
    isLoadingWords = true;
    notifyListeners();
    allWords = await _service.fetchAllWords();
    isLoadingWords = false;
    notifyListeners();
  }

  // ── Referencia de video ──────────────────────────────────────────────────────

  Future<void> fetchReferenceVideo(String word) async {
    selectedSign = word;
    referenceVideoNotFound = false;
    isLoadingReferenceVideo = true;
    await referenceVideoController?.dispose();
    referenceVideoController = null;
    notifyListeners();

    final url = await _service.fetchVideoUrl(word);
    if (url != null) {
      try {
        final ctrl = VideoPlayerController.networkUrl(Uri.parse(url));
        await ctrl.initialize();
        ctrl.setLooping(true);
        ctrl.play();
        referenceVideoController = ctrl;
      } catch (_) {
        referenceVideoNotFound = true;
      }
    } else {
      referenceVideoNotFound = true;
    }

    isLoadingReferenceVideo = false;
    notifyListeners();
  }

  // ── Selección de tipo de seña ────────────────────────────────────────────────

  void setSignType(SignType type) {
    signType = type;
    selectedSign = null;
    newSignName = '';
    isNewSignConfirmed = false;
    referenceVideoController?.dispose();
    referenceVideoController = null;
    referenceVideoNotFound = false;
    notifyListeners();
  }

  void updateNewSignName(String name) {
    newSignName = name;
    if (isNewSignConfirmed) isNewSignConfirmed = false;
    notifyListeners();
  }

  void confirmNewSign() {
    if (newSignName.trim().isNotEmpty) {
      isNewSignConfirmed = true;
      notifyListeners();
    }
  }

  // ── Consentimiento ───────────────────────────────────────────────────────────

  void applyConsent(Map<String, dynamic> data) {
    consentData = data;
    hasConsented = true;
    notifyListeners();
    _initCamera();
  }

  // ── Cámara ───────────────────────────────────────────────────────────────────

  Future<void> _initCamera() async {
    cameraState = DonationCameraState.loading;
    cameraError = null;
    notifyListeners();

    final camStatus = await Permission.camera.request();
    final micStatus = await Permission.microphone.request();

    if (!camStatus.isGranted || !micStatus.isGranted) {
      cameraState = DonationCameraState.error;
      cameraError = 'Se necesitan permisos de cámara y micrófono.';
      notifyListeners();
      return;
    }

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        cameraState = DonationCameraState.error;
        cameraError = 'No se encontró ninguna cámara.';
        notifyListeners();
        return;
      }
      final selected = cameras.firstWhere(
        (c) => c.lensDirection ==
            (isFrontCamera
                ? CameraLensDirection.front
                : CameraLensDirection.back),
        orElse: () => cameras.first,
      );
      cameraController = CameraController(
        selected,
        ResolutionPreset.high,
        fps: 30,
      );
      await cameraController!.initialize();
      cameraState = DonationCameraState.idle;
    } catch (_) {
      cameraState = DonationCameraState.error;
      cameraError = 'No se pudo inicializar la cámara.';
    }
    notifyListeners();
  }

  Future<void> toggleCamera() async {
    isFrontCamera = !isFrontCamera;
    await cameraController?.dispose();
    cameraController = null;
    cameraState = DonationCameraState.loading;
    notifyListeners();
    await _initCamera();
  }

  Future<void> startRecording() async {
    if (!canRecord) return;

    submitMessage = null;
    submitSuccess = null;
    recordedFile = null;

    // Countdown 3 → 1
    for (int i = 3; i >= 1; i--) {
      cameraState = DonationCameraState.countdown;
      countdownValue = i;
      notifyListeners();
      await Future.delayed(const Duration(seconds: 1));
    }

    cameraState = DonationCameraState.recording;
    countdownValue = 0;
    notifyListeners();

    try {
      await cameraController!.startVideoRecording();
      await Future.delayed(const Duration(seconds: 4));
      final file = await cameraController!.stopVideoRecording();
      recordedFile = file;
      cameraState = DonationCameraState.recorded;
    } catch (_) {
      cameraState = DonationCameraState.error;
      cameraError = 'Ocurrió un error durante la grabación.';
    }
    notifyListeners();
  }

  void retryRecording() {
    recordedFile = null;
    submitMessage = null;
    submitSuccess = null;
    cameraState = DonationCameraState.idle;
    notifyListeners();
  }

  // ── Envío ────────────────────────────────────────────────────────────────────

  String? get finalSign {
    if (signType == SignType.diccionario) return selectedSign;
    if (signType == SignType.nueva && isNewSignConfirmed) {
      return newSignName.trim();
    }
    return null;
  }

  bool get hasVideoReady => recordedFile != null;

  bool get canRecord {
    if (!hasConsented) return false;
    if (cameraState != DonationCameraState.idle) return false;
    return finalSign != null;
  }

  Future<void> submitDonation() async {
    if (!hasVideoReady || !hasConsented || consentData == null) return;
    final sign = finalSign;
    if (sign == null) return;

    cameraState = DonationCameraState.submitting;
    submitMessage = null;
    notifyListeners();

    try {
      await _service.submitDonation(
        nombre: consentData!['nombre'],
        correo: consentData!['correo'],
        dni: consentData!['dni'],
        telefono: consentData!['telefono'],
        sena: sign,
        firmaBase64: consentData!['firma'] ?? '',
        videoPath: recordedFile!.path,
      );
      recordedFile = null;
      if (signType == SignType.nueva) {
        newSignName = '';
        isNewSignConfirmed = false;
      }
      cameraState = DonationCameraState.submitted;
      submitMessage = '¡Excelente! Tu donación se ha enviado correctamente.';
      submitSuccess = true;
    } catch (e) {
      cameraState = DonationCameraState.recorded;
      submitMessage = 'Error al enviar. Inténtalo de nuevo.';
      submitSuccess = false;
    }
    notifyListeners();
  }

  void resetAfterSubmit() {
    cameraState = DonationCameraState.idle;
    recordedFile = null;
    selectedSign = null;
    submitMessage = null;
    submitSuccess = null;
    notifyListeners();
  }

  @override
  void dispose() {
    cameraController?.dispose();
    referenceVideoController?.dispose();
    super.dispose();
  }
}
