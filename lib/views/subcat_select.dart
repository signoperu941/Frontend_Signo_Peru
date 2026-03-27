import 'package:flutter/material.dart';
import 'package:signo_peru_app/components/atoms/background.dart';
import 'package:signo_peru_app/components/organisms/topbar.dart';

class SubcatSelectScreen extends StatefulWidget {
  final Map<String, dynamic> cat;
  const SubcatSelectScreen({super.key, required this.cat});

  @override
  State<StatefulWidget> createState() => _SubcatSelectScreenState();
}

class _SubcatSelectScreenState extends State<SubcatSelectScreen> 
    with TickerProviderStateMixin {
  late List<String> subcategories;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    subcategories = widget.cat.keys.toList();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Función para validar valores de animación
  double _clampOpacity(double value) {
    return value.clamp(0.0, 1.0);
  }

  double _clampScale(double value) {
    return value.clamp(0.1, 1.0);
  }

  Widget _buildSubcategoryItem(String subcategoryName, int index) {
    final wordCount = widget.cat[subcategoryName] is List 
        ? (widget.cat[subcategoryName] as List).length 
        : 1;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        // Cálculo seguro de la animación
        final rawAnimationValue = _animationController.value - (index * 0.1);
        final clampedValue = rawAnimationValue.clamp(0.0, 1.0);
        final curvedValue = Curves.easeOutQuart.transform(clampedValue);
        
        // Valores seguros para las transformaciones
        final safeOpacity = _clampOpacity(curvedValue);
        final safeScale = _clampScale(0.9 + (curvedValue * 0.1));
        final safeTranslateY = 20.0 * (1.0 - curvedValue);
        
        return Transform.scale(
          scale: safeScale,
          child: Transform.translate(
            offset: Offset(0, safeTranslateY),
            child: Opacity(
              opacity: safeOpacity,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Material(
                  color: Colors.white,
                  elevation: 2,
                  shadowColor: Color(0x20000000),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: Color(0xFFf58b2a),
                      width: 1.5,
                    ),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    splashColor: Color(0x33f58b2a), // Color seguro sin withValues
                    onTap: () {
                      // Debug log removido para producción
                      Navigator.pushNamed(
                        context,
                        '/learn-word',
                        arguments: widget.cat[subcategoryName],
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // Círculo con inicial de la subcategoría
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Color(0xFFf58b2a),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                subcategoryName.isNotEmpty 
                                    ? subcategoryName[0].toUpperCase() 
                                    : '?',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          
                          // Contenido principal
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  subcategoryName.replaceAll('_', ' '),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.library_books,
                                      size: 14,
                                      color: Colors.grey[600],
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      "$wordCount palabra${wordCount != 1 ? 's' : ''}",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          
                          // Flecha
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Color(0xFFf58b2a),
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            return ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 16),
                itemCount: subcategories.length,
                itemBuilder: (context, index) {
                  return _buildSubcategoryItem(subcategories[index], index);
                },
              ),
            );
          },
        ),
      ),
    );
  }
}