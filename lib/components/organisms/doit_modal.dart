import 'package:flutter/material.dart';
import 'package:signo_peru_app/components/atoms/video_play.dart';
import 'package:video_player/video_player.dart';

class DoitModal extends StatelessWidget {
 final VideoPlayerController ctrl;
 final String word;
 final bool? validation;
 final double? certeza;

 const DoitModal({
   super.key,
   required this.ctrl,
   required this.word,
   this.validation,
   this.certeza,
 });

 @override
 Widget build(BuildContext context) {
   final size = MediaQuery.of(context).size;
   final screenHeight = size.height;
   final screenWidth = size.width;
   final camHeightPortrait = screenHeight * (304 / 844);
   
   return SizedBox(
     width: screenWidth,
     child: AlertDialog(
       contentPadding: const EdgeInsets.all(10),
       content: Column(
         mainAxisSize: MainAxisSize.min,
         mainAxisAlignment: MainAxisAlignment.center,
         children: [
           Padding(
             padding: const EdgeInsets.all(5),
             child: Text(
               "Reproduce la seña $word",
               style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
             ),
           ),
           const SizedBox(height: 5),
           VideoPlay(
             controller: ctrl,
             targetHeight: camHeightPortrait,
             targetWidth: screenWidth,
             marginVertical: 5,
             marginHorizontal: 5,
             radius: 20,
           ),
           const SizedBox(height: 5),
           Padding(
             padding: const EdgeInsets.all(5),
             child: Text(
               // CAMBIO: Ahora usa el parámetro validation dinámicamente
               validation == true 
               ? "CORRECTO ${certeza != null ? '(${certeza!.toStringAsFixed(1)}%)' : ''}"
               : "INCORRECTO",
               style: TextStyle(
                 fontSize: 28,
                 fontWeight: FontWeight.bold,
                 color: validation == true ? Colors.green : Colors.red,
               ),
             ),
           ),
         ],
       ),
       actions: [
         FilledButton(
           onPressed: () {
             Future.delayed(Duration.zero, () async {
               await ctrl.dispose();
             });
             Navigator.of(context).pop();
           },
           style: const ButtonStyle(
             fixedSize: WidgetStatePropertyAll(Size(150, 50)),
             enableFeedback: true,
           ),
           child: const Text("Cerrar"),
         ),
       ],
     ),
   );
 }
}