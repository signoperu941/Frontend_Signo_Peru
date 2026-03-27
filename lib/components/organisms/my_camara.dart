import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:signo_peru_app/view_model/video_viewmodel.dart';

class MyCamara extends StatelessWidget {
  final VideoViewModel viewModel;
  final double targetHeight;
  final double targetWidth;
  final double marginVertical;
  final double marginHorizontal;
  final double radius;
  final bool isPortrait;

  const MyCamara({
    super.key,
    required this.viewModel,
    required this.targetHeight,
    required this.targetWidth,
    required this.marginVertical,
    required this.marginHorizontal,
    required this.radius,
    required this.isPortrait,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<VideoViewModel>.value(
      value: viewModel,
      child: Consumer<VideoViewModel>(
        builder: (context, viewModel, child) {
          final ctrl = viewModel.videoModel.cameraController;

          if (ctrl == null || !ctrl.value.isInitialized) {
            return _buildLoadingState();
          }

          return _buildCameraState(ctrl, viewModel);
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: targetHeight,
      width: targetWidth,
      decoration: BoxDecoration(
        color: Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.camera_alt_outlined,
            color: Colors.white24,
            size: 48,
          ),
          SizedBox(height: 16),
          CircularProgressIndicator(
            color: Color(0xFFf58b2a),
            strokeWidth: 2,
          ),
          SizedBox(height: 12),
          Text(
            "Inicializando cámara...",
            style: TextStyle(
              color: Colors.white38,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraState(CameraController ctrl, VideoViewModel viewModel) {
    return Container(
      height: targetHeight,
      width: targetWidth,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(radius),
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          SizedBox(
            height: targetHeight,
            width: targetWidth,
            child: CameraPreview(ctrl),
          ),
          Positioned(
            bottom: 12,
            right: 12,
            child: GestureDetector(
              onTap: () => viewModel.setCamera(),
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white24,
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.flip_camera_ios_outlined,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}