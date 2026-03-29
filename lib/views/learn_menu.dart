import 'package:flutter/material.dart';
import 'package:signo_peru_app/components/atoms/background.dart';
import 'package:signo_peru_app/components/organisms/topbar.dart';
import 'package:signo_peru_app/config/backend_client.dart';
import 'package:dio/dio.dart';

class LearnMenuScreen extends StatefulWidget {
  const LearnMenuScreen({super.key});

  @override
  State<StatefulWidget> createState() => _LearnMenuScreenState();
}

class _LearnMenuScreenState extends State<LearnMenuScreen>
    with TickerProviderStateMixin {
  late Future<List<Map<String, dynamic>>> _categories;
  final Dio _dio = BackendClient.createDioClient();
  Map<String, dynamic>? _datosCompletos;
  late AnimationController _animationController;

  final List<String> _categoriasReto = [];
  final List<String> _categoriasDificil = [
    'VERBOS',
  ];

  final Map<String, IconData> _categoryIcons = {
    'CONCEPTOS_Y_ESTADOS': Icons.psychology,
    'CUALIDADES_Y_PERCEPCIONES': Icons.auto_awesome,
    'PALABRAS_FUNCIONALES': Icons.spellcheck,
    'LUGARES_Y_GEOGRAFIA': Icons.map,
    'PERSONAS_Y_CARACTERISTICAS_FISICAS': Icons.people,
    'VERBOS': Icons.directions_run,
    'OBJETOS_Y_TECNOLOGIA': Icons.devices,
  };


  @override
  void initState() {
    super.initState();
    _categories = _loadCategories();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200), // aumentado para cubrir todas
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> _loadCategories() async {
    try {
      final response = await _dio.get('/busqueda/learn-data');
      final data = response.data;
      _datosCompletos = data['datos_completos'];
      return List<Map<String, dynamic>>.from(data['categorias']);
    } catch (e) {
      throw Exception('Error cargando categorías: $e');
    }
  }

  double _clampOpacity(double value) => value.clamp(0.0, 1.0);
  double _clampScale(double value) => value.clamp(0.1, 1.0);

  Color _getCardColor(bool isDifficult, bool isReto) {
    if (isReto) return const Color(0xFFFFEBEE);
    if (isDifficult) return const Color(0xFFFFF5EE);
    return Colors.white;
  }

  Color _getShadowColor(bool isDifficult, bool isReto) {
    if (isReto) return const Color(0x40FF5722);
    if (isDifficult) return const Color(0x40FF8C00);
    return const Color(0x20000000);
  }

  Color _getBorderColor(bool isDifficult, bool isReto) {
    if (isReto) return Colors.red.shade300;
    if (isDifficult) return Colors.orange.shade300;
    return const Color(0xFFf58b2a);
  }

  Color _getIconBackgroundColor(bool isDifficult, bool isReto, String nombre) {
    if (isReto) return Colors.red.shade600;
    if (isDifficult) return Colors.orange.shade600;
    return const Color(0xFFf58b2a);
  }

  IconData _getCategoryIcon(String categoryName) {
    return _categoryIcons[categoryName] ?? Icons.category;
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> categoria, int index) {
    final nombre = categoria['nombre'].toString();
    final isReto = _categoriasReto.contains(nombre);
    final isDifficult = _categoriasDificil.contains(nombre);

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final rawValue = _animationController.value - (index * 0.10); // reducido de 0.15 a 0.10
        final clampedValue = rawValue.clamp(0.0, 1.0);
        final curvedValue = Curves.easeOutQuart.transform(clampedValue);

        final safeOpacity = _clampOpacity(curvedValue);
        final safeScale = _clampScale(0.8 + (curvedValue * 0.2));
        final safeTranslateY = 30.0 * (1.0 - curvedValue);

        return Transform.scale(
          scale: safeScale,
          child: Transform.translate(
            offset: Offset(0, safeTranslateY),
            child: Opacity(
              opacity: safeOpacity,
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: Material(
                  color: _getCardColor(isDifficult, isReto),
                  elevation: isDifficult || isReto ? 6 : 4,
                  shadowColor: _getShadowColor(isDifficult, isReto),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      color: _getBorderColor(isDifficult, isReto),
                      width: isDifficult || isReto ? 3 : 2,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/learn-cat',
                        arguments: _datosCompletos![nombre],
                      );
                    },
                    borderRadius: BorderRadius.circular(20),
                    splashColor: const Color(0x33f58b2a),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // Icono
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _getIconBackgroundColor(isDifficult, isReto, nombre),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Icon(
                              _getCategoryIcon(nombre),
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Contenido
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        nombre.replaceAll('_', ' '),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                    if (isReto)
                                      _buildBadge('RETO', Colors.red.shade600),
                                    if (isDifficult && !isReto)
                                      _buildBadge('DIFÍCIL', Colors.orange.shade600),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.library_books,
                                      size: 16,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      "${categoria['total_palabras']} palabras",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    if (isReto) ...[
                                      const Spacer(),
                                      Icon(
                                        Icons.local_fire_department,
                                        color: Colors.red,
                                        size: 16,
                                      ),
                                      Text(
                                        " Nivel Avanzado",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.red.shade700,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Flecha
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.grey[400],
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Topbar(title: "Aprende LSP"),
      body: AppBackground(
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _categories,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFFf58b2a),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      "Cargando categorías...",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
            }

            if (snap.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    Text(
                      'Error cargando categorías',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${snap.error}',
                      style: const TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _categories = _loadCategories();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFf58b2a),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("Reintentar"),
                    ),
                  ],
                ),
              );
            }

            final allCategories = snap.data!;

            return LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 32.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: allCategories
                            .asMap()
                            .entries
                            .map((entry) =>
                                _buildCategoryCard(entry.value, entry.key))
                            .toList(),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}