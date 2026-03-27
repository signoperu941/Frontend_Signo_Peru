import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:signo_peru_app/components/atoms/background.dart';
import 'package:signo_peru_app/components/organisms/topbar.dart';
import 'package:signo_peru_app/components/organisms/my_camara.dart';
import 'package:signo_peru_app/components/organisms/my_translations.dart';
import 'package:signo_peru_app/model/video_model.dart';
import 'package:signo_peru_app/view_model/video_viewmodel.dart';

class LspLearnScreen extends StatefulWidget {
  final String word;

  const LspLearnScreen({super.key, required this.word});

  @override
  State<StatefulWidget> createState() => _LspLearnScreenState();
}

class _LspLearnScreenState extends State<LspLearnScreen> {
  VideoViewModel? _viewModel;
  final VideoModel _videoModel = VideoModel();

  @override
  void initState() {
    super.initState();
    _viewModel = VideoViewModel(_videoModel);
  }

  @override
  void dispose() {
    super.dispose();
    _videoModel.disposeModel();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenHeight = size.height;
    final screenWidth = size.width;
    final camHeightPortrait =
        screenHeight * (304 / 844); // 36 % del alto en portrait

    return Scaffold(
      appBar: Topbar(title: widget.word),
      body: AppBackground(
        child: ChangeNotifierProvider<VideoViewModel>.value(
          value: _viewModel!,
          child: Consumer<VideoViewModel>(
            builder: (context, viewModel, child) {
              return Stack(
                children: [
                  if (viewModel.count != 0)
                    Container(
                      color: Colors.black.withValues(alpha: 0.3),
                      child: Center(
                        child: Text(
                          "${viewModel.count}",
                          style: TextStyle(fontSize: 36, color: Colors.white),
                        ),
                      ),
                    ),
                  Column(
                    children: [
                      Container(
                        width: double.infinity,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: Colors.white),
                        padding: EdgeInsetsGeometry.all(20),
                        child: Text("Acercarse para expresion facial"),
                      ),
                      SizedBox(
                        height: camHeightPortrait,
                        width: double.infinity,
                        child: MyCamara(
                          viewModel: _viewModel!,
                          targetHeight: camHeightPortrait,
                          targetWidth: screenWidth,
                          marginVertical: 0,
                          marginHorizontal: 0,
                          radius: 0,
                          isPortrait: true,
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: Colors.white),
                        padding: EdgeInsetsGeometry.all(20),
                        child: Text("Realice una seña"),
                      ),
                      MyTranslations(
                        viewModel: _viewModel!,
                        targetHeight: 40,
                        targetWidth: screenWidth,
                        marginVertical: 20,
                        marginHorizontal: 20,
                      ),

                      FilledButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Ver de nuevo     "),
                            Image.asset(
                              "assets/help.png",
                              width: 30,
                              height: 30,
                            ), // Cambiar ruta del asset
                          ],
                        ),
                      ),
                    ],
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
