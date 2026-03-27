import 'package:flutter/material.dart';
import 'package:signo_peru_app/config/env.dart';
import 'package:signo_peru_app/services/cache_service.dart';
import 'dart:async';
import 'package:signo_peru_app/views/esp_lsp_screen.dart';
import 'package:signo_peru_app/views/learn_doit_screen.dart';
import 'package:signo_peru_app/views/learn_menu.dart';
import 'package:signo_peru_app/views/lsp_screen.dart';
import 'package:signo_peru_app/views/onboarding.dart';
import 'package:flutter/services.dart';
import 'package:signo_peru_app/views/subcat_select.dart';
import 'package:signo_peru_app/views/word_select.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CacheService.initialize();
  await Env.init(fileName: ".env");
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const MyApp());
}

Route _errorRoute() {
  return MaterialPageRoute(
    builder: (_) => Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: const Center(child: Text('Ruta no válida')),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Iniciar cache en background 8 segundos después de que cargue la app
    Timer(const Duration(seconds: 8), () {
      print('[Main] Iniciando cache en background');
      CacheService.startBackgroundCaching();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.light(
          primary: Color(0xFFf58b2a),
          onPrimary: Color(0xFFF2EEEE),
          surface: Color(0xFFF2EEEE),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFFf58b2a),
          foregroundColor: Color(0xFFE7E0EC),
        ),
        scaffoldBackgroundColor: Color(0xFFE7E0EC),
        dropdownMenuTheme: DropdownMenuThemeData(
          textStyle: TextStyle(color: Color(0xFFE7E0EC)),
          inputDecorationTheme: InputDecorationTheme(
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            suffixIconColor: Color(0xFFF2EEEE),
            prefixIconColor: Color(0xFFF2EEEE),
            iconColor: Color(0xFFF2EEEE),
          ),
          menuStyle: MenuStyle(
            backgroundColor: WidgetStateProperty.all(Color(0xFFF2EEEE)),
            fixedSize: WidgetStateProperty.all(Size(150, double.infinity)),
            padding: WidgetStateProperty.all(EdgeInsetsGeometry.all(10)),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: ButtonStyle(
            fixedSize: WidgetStatePropertyAll(Size(300, 50)),
            backgroundColor: WidgetStateProperty.all(Color(0xFFFFFFFF)),
            foregroundColor: WidgetStateProperty.all(Color(0xFF36343B)),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(
                side: BorderSide(color: Color(0xFFf58b2a), width: 2),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            elevation: WidgetStatePropertyAll(5),
            enableFeedback: true,
          ),
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.dark(
          primary: Color(0xFFf58b2a),
          onPrimary: Color(0xFF625B71),
          primaryContainer: Color(0xFF625B71),
          surface: Color(0xFF625B71),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFFf58b2a),
          foregroundColor: Color(0xFFE7E0EC),
        ),
        dropdownMenuTheme: DropdownMenuThemeData(
          inputDecorationTheme: InputDecorationTheme(
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
          ),
          menuStyle: MenuStyle(
            padding: WidgetStateProperty.all(EdgeInsetsGeometry.all(10)),
            fixedSize: WidgetStateProperty.all(Size(150, double.infinity)),
          ),
        ),
        scaffoldBackgroundColor: Color(0xFF36343B),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: "/",
      routes: {
        "/": (context) => Onboarding(),
        "/lsp": (context) => LspScreen(),
        "/esp-lsp": (context) => EspLspScreen(),
        "/learn": (context) => LearnMenuScreen(),
      },
      onGenerateRoute: (RouteSettings settings) {
        final args = settings.arguments;

        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => Onboarding());
          case '/lsp':
            return MaterialPageRoute(builder: (_) => LspScreen());
          case '/esp-lsp':
            return MaterialPageRoute(builder: (_) => EspLspScreen());
          case '/learn':
            return MaterialPageRoute(builder: (_) => LearnMenuScreen());
          case '/learn-cat':
            if (args is Map<String, dynamic>) {
              return MaterialPageRoute(
                builder: (_) => SubcatSelectScreen(cat: args),
              );
            }
            return _errorRoute();
          case '/learn-word':
            if (args is List<dynamic>) {
              return MaterialPageRoute(
                builder: (_) => WordSelectScreen(word: args),
              );
            }
            return _errorRoute();
          case '/doit':
            if (args is Map<String, dynamic>) {
              return MaterialPageRoute(
                builder: (_) => DoitScreen(wordData: args),
              );
            }
            return _errorRoute();

          default:
            return _errorRoute();
        }
      },
    );
  }
}
