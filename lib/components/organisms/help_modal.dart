import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:signo_peru_app/components/atoms/video_play.dart';
import 'package:signo_peru_app/view_model/onboarding_viewmodel.dart';

class HelpModal extends StatefulWidget {
  final OnboardingViewmodel viewModel;
  const HelpModal({super.key, required this.viewModel});

  @override
  State<HelpModal> createState() => _HelpModalState();
}

class _HelpModalState extends State<HelpModal> {
  bool _isMuted = false;

  static const _orange = Color(0xFFf58b2a);

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
    });
    widget.viewModel.controller.setVolume(_isMuted ? 0.0 : 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<OnboardingViewmodel>.value(
      value: widget.viewModel,
      child: Consumer<OnboardingViewmodel>(
        builder: (context, viewModel, child) {
          final ctrl = viewModel.controller;
          final title = viewModel.currentTitle;
          final text = viewModel.currentText;
          final size = MediaQuery.of(context).size;

          final videoWidth = size.width - 20;
          final videoHeight = size.height * 0.42;

          return Dialog(
            backgroundColor: Colors.white,
            insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: size.height * 0.92),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                  // Video
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: SizedBox(
                            width: videoWidth,
                            height: videoHeight,
                            child: VideoPlay(
                              controller: ctrl,
                              targetHeight: videoHeight,
                              targetWidth: videoWidth,
                              marginVertical: 0,
                              marginHorizontal: 0,
                              radius: 16,
                            ),
                          ),
                        ),

                        // Botones superpuestos sobre el video
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: Row(
                            children: [
                              // Boton mute/unmute
                              GestureDetector(
                                onTap: _toggleMute,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.5),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    _isMuted
                                        ? Icons.volume_off_rounded
                                        : Icons.volume_up_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Boton replay
                              GestureDetector(
                                onTap: () => viewModel.replayVideo(),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.5),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.replay_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Texto scrolleable
                  Flexible(
                    child: Scrollbar(
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ..._buildParagraphs(text),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Boton entendido
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          viewModel.disposeVModel();
                          Navigator.of(context).pop();
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: _orange,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          "Entendido",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildParagraphs(String text) {
    final paragraphs = text
        .split('\n\n')
        .map((p) => p.replaceAll('\n', ' ').trim())
        .where((p) => p.isNotEmpty)
        .toList();

    return paragraphs.map((paragraph) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(
          paragraph,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black54,
            height: 1.6,
          ),
          textAlign: TextAlign.justify,
        ),
      );
    }).toList();
  }
}