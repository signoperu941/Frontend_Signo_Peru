import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class OnboardingViewmodel extends ChangeNotifier {
  final List<String> videoAssets = [
    "assets/VIDEO.mp4",
  ];

  final List<String> text = [
    "Bienvenido a Signo Peru, un aplicativo creado para acercar la lengua de señas peruana a todas las personas. En el Peru, la comunidad sorda enfrenta barreras de comunicacion que dificultan su inclusion en la vida cotidiana. Por eso, con el apoyo y financiamiento del IDIC, desarrollamos esta herramienta que busca reducir esas barreras y promover una sociedad mas inclusiva. Con Signo Peru puedes traducir señas a texto, buscar como se realiza cada seña, y aprender lengua de señas paso a paso. Te mostramos como funciona.\n\nLa primera funcion es Señas a Texto. Al ingresar, tendras acceso directo a tu camara. Presiona el boton de traducir y aparecera una cuenta regresiva para que te prepares. Realiza la seña frente a la camara. Una vez que termines, la aplicacion analizara tu seña y mostrara la palabra detectada en pantalla.\n\nLa segunda funcion es Texto a Señas. Aqui encontraras un buscador con un amplio catalogo de videos de señas. Escribe la palabra que quieres aprender y se reproducira un video mostrando como realizar la seña correctamente. Ideal para consultar cualquier palabra en cualquier momento.\n\nLa tercera funcion es Aprende LSP. Veras distintas categorias con palabras organizadas para facilitar tu aprendizaje. Selecciona una categoria, elige una palabra y primero veras un video de muestra para conocer como se realiza la seña de forma correcta. Despues, presiona el boton traducir texto. Aparecera una cuenta regresiva para que te pongas en posicion. Realiza la seña y la app te indicara si la hiciste correctamente.\n\nEso es todo. Prueba Signo Peru y empieza a comunicarte con lengua de señas peruana. Gracias por ver este video.",
  ];

  final List<String> title = [
    "Bienvenidos",
  ];

  int currentIndex = 0;
  late VideoPlayerController controller;

  OnboardingViewmodel();

  int get totalSteps => videoAssets.length;
  bool get isLast => currentIndex >= totalSteps - 1;

  String get currentVideoAsset => videoAssets[currentIndex];
  String get currentTitle => title[currentIndex];
  String get currentText => text[currentIndex];

  Future<void> initializeController() async {
    controller = VideoPlayerController.asset(currentVideoAsset);
    await controller.initialize();
    await controller.setLooping(true);
    await controller.setVolume(1.0); // Asegura que el volumen este activo
    await controller.play();
    notifyListeners();
  }

  Future<void> replayVideo() async {
    await controller.seekTo(Duration.zero);
    await controller.setVolume(1.0); // Mantiene volumen al repetir
    await controller.play();
    notifyListeners();
  }

  Future<void> disposeVModel() async {
    await controller.pause();
    notifyListeners();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}