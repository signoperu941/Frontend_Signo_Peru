import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:signo_peru_app/components/atoms/background.dart';
import 'package:signo_peru_app/components/organisms/doit_modal.dart';
import 'package:signo_peru_app/components/organisms/my_camara.dart';
import 'package:signo_peru_app/components/organisms/topbar.dart';
import 'package:signo_peru_app/model/video_model.dart';
import 'package:signo_peru_app/services/cache_service.dart';
import 'package:signo_peru_app/view_model/video_viewmodel.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';

class DoitScreen extends StatefulWidget {
  final Map<String, dynamic> wordData;
  const DoitScreen({super.key, required this.wordData});

  @override
  State<StatefulWidget> createState() => _DoitScreenState();
}

class _DoitScreenState extends State<DoitScreen> with SingleTickerProviderStateMixin {
  VideoViewModel? _viewModel;
  final VideoModel _videoModel = VideoModel();
  VideoPlayerController? controller;
  bool _isVideoLoading = true;
  bool _hasVideoError = false;
  late AnimationController _blinkController;

  String get palabra => widget.wordData['palabra'] ?? 'Sin nombre';
  String get enlaceVideo => widget.wordData['enlace'] ?? '';

  @override
  void initState() {
    super.initState();
    _viewModel = VideoViewModel(_videoModel);
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
    Future.delayed(Duration.zero, () async {
      await initializeController();
      if (mounted) showVideoDialog();
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    _videoModel.disposeModel();
    _blinkController.dispose();
    CacheService.resumeBackgroundCaching();
    super.dispose();
  }

  Future<void> initializeController() async {
    setState(() {
      _isVideoLoading = true;
      _hasVideoError = false;
    });

    try {
      CacheService.pauseBackgroundCaching();

      final cachedPath = await CacheService.getCachedVideoPath(palabra);

      if (cachedPath != null) {
        print('[DoitScreen] Usando cache: $cachedPath');
        controller = VideoPlayerController.file(File(cachedPath));
      } else {
        print('[DoitScreen] Descargando desde backend: $enlaceVideo');
        controller = VideoPlayerController.networkUrl(Uri.parse(enlaceVideo));

        // Cachear en background para la próxima vez
        CacheService.cacheVideo(videoUrl: enlaceVideo, palabra: palabra)
            .catchError((e) => print('[DoitScreen] Error cacheando: $e'));
      }

      await controller!.setLooping(true);
      await controller!.initialize();
      await controller!.play();
    } catch (e) {
      setState(() => _hasVideoError = true);
      CacheService.resumeBackgroundCaching();
    } finally {
      if (mounted) setState(() => _isVideoLoading = false);
    }
  }

  void showVideoDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Reproduce la seña",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFf58b2a)),
              ),
              const SizedBox(height: 8),
              Text(
                palabra,
                style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Container(
                height: 300,
                width: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[100],
                  border: Border.all(color: const Color(0xFFf58b2a), width: 2),
                ),
                child: _isVideoLoading
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: Color(0xFFf58b2a), strokeWidth: 3),
                            SizedBox(height: 16),
                            Text("Cargando...", style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      )
                    : _hasVideoError
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.wifi_off_rounded, color: Colors.grey, size: 48),
                                SizedBox(height: 8),
                                Text("No se pudo cargar el video", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
                              ],
                            ),
                          )
                        : controller != null && controller!.value.isInitialized
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: SizedBox.expand(
                                  child: FittedBox(
                                    fit: BoxFit.cover,
                                    child: SizedBox(
                                      width: controller!.value.size.width,
                                      height: controller!.value.size.height,
                                      child: VideoPlayer(controller!),
                                    ),
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFf58b2a),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Cerrar", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final camHeightPortrait = size.height * 0.55;

    return Scaffold(
      appBar: Topbar(title: "Hazlo tu mismo"),
      body: AppBackground(
        child: ChangeNotifierProvider<VideoViewModel>.value(
          value: _viewModel!,
          child: Consumer<VideoViewModel>(
            builder: (context, viewModel, child) {

              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (viewModel.isProcessing) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Row(
                        children: [
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          ),
                          SizedBox(width: 12),
                          Text("Analizando seña..."),
                        ],
                      ),
                      duration: Duration(seconds: 30),
                      backgroundColor: Color(0xFFf58b2a),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                }
              });

              return Stack(
                children: [
                  Column(
                    children: [
                      Container(
                        width: double.infinity,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(color: Colors.white),
                        padding: const EdgeInsets.all(20),
                        child: const Text(
                          "Acércate para realizar la seña",
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                        ),
                      ),

                      SizedBox(
                        height: camHeightPortrait,
                        width: double.infinity,
                        child: Stack(
                          children: [
                            MyCamara(
                              viewModel: _viewModel!,
                              targetHeight: camHeightPortrait,
                              targetWidth: size.width,
                              marginVertical: 0,
                              marginHorizontal: 0,
                              radius: 0,
                              isPortrait: true,
                            ),

                            if (viewModel.isRecording)
                              Positioned(
                                top: 12,
                                right: 12,
                                child: FadeTransition(
                                  opacity: _blinkController,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.6),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        CircleAvatar(radius: 4, backgroundColor: Colors.red),
                                        SizedBox(width: 6),
                                        Text(
                                          "REC",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      Container(
                        width: double.infinity,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(color: Colors.white),
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          "Realiza la seña: $palabra",
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                        ),
                      ),

                      FilledButton(
                        onPressed: (viewModel.isRecording || viewModel.isProcessing)
                            ? null
                            : () {
                                Future.delayed(Duration.zero, () async {
                                  await viewModel.start();
                                  await viewModel.validation(palabra);
                                  await initializeController();
                                }).whenComplete(() {
                                  if (context.mounted) {
                                    showDialog(
                                      context: context,
                                      builder: (context) => DoitModal(
                                        ctrl: controller!,
                                        word: palabra,
                                        validation: viewModel.isCorrect,
                                        certeza: viewModel.certeza,
                                      ),
                                    );
                                  }
                                });
                              },
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Traducir Texto     "),
                            Opacity(
                              opacity: (viewModel.isRecording || viewModel.isProcessing) ? 0.38 : 1.0,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  if (viewModel.count != 0)
                    Container(
                      color: Colors.black.withValues(alpha: 0.3),
                      child: Center(
                        child: Text(
                          "${viewModel.count}",
                          style: const TextStyle(
                            fontSize: 36,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
