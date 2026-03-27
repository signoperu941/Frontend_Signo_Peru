import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';

class VideoPlay extends StatelessWidget {
  final VideoPlayerController controller;
  final double targetHeight;
  final double targetWidth;
  final double marginVertical;
  final double marginHorizontal;
  final double radius;

  const VideoPlay({
    super.key,
    required this.controller,
    required this.targetHeight,
    required this.targetWidth,
    required this.marginVertical,
    required this.marginHorizontal,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: targetWidth,
      height: targetHeight,
      margin: EdgeInsets.symmetric(
        vertical: marginVertical,
        horizontal: marginHorizontal,
      ),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(radius)),
      clipBehavior: Clip.hardEdge,
      child: AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: ClipRect(
          clipper: _RightEdgeClipper(clipPixels: 10),
          child: VideoPlayer(controller),
        ),
      ),
    );
  }
}

// Clase fuera de VideoPlay
class _RightEdgeClipper extends CustomClipper<Rect> {
  final double clipPixels;

  _RightEdgeClipper({required this.clipPixels});

  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(0, 0, size.width - clipPixels, size.height);
  }

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) => false;
}