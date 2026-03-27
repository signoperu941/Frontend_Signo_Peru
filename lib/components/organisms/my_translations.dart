import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:signo_peru_app/view_model/video_viewmodel.dart';

class MyTranslations extends StatelessWidget {
  final VideoViewModel viewModel;
  final double targetWidth;
  final double marginVertical;
  final double marginHorizontal;

  const MyTranslations({
    super.key,
    required this.viewModel,
    required this.targetWidth,
    required this.marginVertical,
    required this.marginHorizontal,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<VideoViewModel>.value(
      value: viewModel,
      child: Consumer<VideoViewModel>(
        builder: (context, viewModel, child) {
          final hasResult = viewModel.res.isNotEmpty;

          return Container(
            width: targetWidth,
            margin: EdgeInsets.symmetric(
              vertical: marginVertical,
              horizontal: marginHorizontal,
            ),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: hasResult
                  ? Color(0xFFf58b2a).withOpacity(0.1)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasResult ? Color(0xFFf58b2a) : Colors.grey.shade300,
                width: 1.5,
              ),
            ),
            child: hasResult
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Palabra detectada",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        viewModel.res,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFf58b2a),
                        ),
                      ),
                      SizedBox(height: 4),  
                      Text(                  
                        "Certeza: ${viewModel.certeza.toStringAsFixed(1)}%",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  )
                : Text(
                    "Presiona el botón para traducir una seña",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
          );
        },
      ),
    );
  }
}