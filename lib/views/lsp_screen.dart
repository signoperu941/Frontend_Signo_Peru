import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:signo_peru_app/components/atoms/background.dart';
import 'package:signo_peru_app/components/organisms/topbar.dart';
import 'package:signo_peru_app/components/organisms/my_camara.dart';
import 'package:signo_peru_app/components/organisms/my_translations.dart';
import 'package:signo_peru_app/model/video_model.dart';
import 'package:signo_peru_app/view_model/video_viewmodel.dart';

class LspScreen extends StatefulWidget {
  const LspScreen({super.key});

  @override
  State<StatefulWidget> createState() => _LspScreenState();
}

class _LspScreenState extends State<LspScreen> with SingleTickerProviderStateMixin {
  VideoViewModel? _viewModel;
  final VideoModel _videoModel = VideoModel();
  late AnimationController _blinkController;

  @override
  void initState() {
    super.initState();
    _viewModel = VideoViewModel(_videoModel);
    _blinkController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _videoModel.disposeModel();
    _blinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenHeight = size.height;
    final screenWidth = size.width;
    final camHeightPortrait = screenHeight * 0.55;

    return Scaffold(
      appBar: Topbar(title: "Señas a Texto"),
      body: AppBackground(
        child: ChangeNotifierProvider<VideoViewModel>.value(
          value: _viewModel!,
          child: Consumer<VideoViewModel>(
            builder: (context, viewModel, child) {

              // Mostrar snackbar cuando empieza a procesar
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (viewModel.isProcessing) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
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
                        color: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                        child: Text(
                          "Haz tu seña frente a la cámara",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),

                      // Cámara con badge REC
                      SizedBox(
                        height: camHeightPortrait,
                        width: double.infinity,
                        child: Stack(
                          children: [
                            MyCamara(
                              viewModel: _viewModel!,
                              targetHeight: camHeightPortrait,
                              targetWidth: screenWidth,
                              marginVertical: 0,
                              marginHorizontal: 0,
                              radius: 0,
                              isPortrait: true,
                            ),

                            // Badge REC parpadeante
                            if (viewModel.isRecording)
                              Positioned(
                                top: 12,
                                right: 12,
                                child: FadeTransition(
                                  opacity: _blinkController,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.6),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
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

                      Expanded(
                        child: Container(
                          color: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          child: Column(
                            children: [
                              MyTranslations(
                                viewModel: _viewModel!,
                                targetWidth: screenWidth,
                                marginVertical: 0,
                                marginHorizontal: 0,
                              ),
                              SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton(
                                  onPressed: (viewModel.isRecording || viewModel.isProcessing)
                                      ? null
                                      : () => viewModel.start(),
                                  child: Text("Traducir seña"),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Overlay cuenta regresiva
                  if (viewModel.count > 0)
                    Container(
                      color: Colors.black.withOpacity(0.8),
                      width: double.infinity,
                      height: double.infinity,
                      child: Center(
                        child: Text(
                          "${viewModel.count}",
                          style: TextStyle(
                            fontSize: 120,
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