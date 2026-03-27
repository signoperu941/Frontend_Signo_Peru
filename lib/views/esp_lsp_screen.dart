import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:signo_peru_app/components/atoms/background.dart';
import 'package:signo_peru_app/components/atoms/video_play.dart';
import 'package:signo_peru_app/components/organisms/topbar.dart';
import 'package:signo_peru_app/view_model/esp_lsp_viewmodel.dart';

class EspLspScreen extends StatefulWidget {
  const EspLspScreen({super.key});

  @override
  State<StatefulWidget> createState() => _EspLspScreenState();
}

class _EspLspScreenState extends State<EspLspScreen> {
  EspLspViewModel? _viewModel;
  TextEditingController? _controller;
  final FocusNode _searchFocusNode = FocusNode();

  String? _selectedCategory;
  String? _selectedSubcategory;
  List<String> _suggestions = [];
  bool _showSuggestions = false;

  static const _orange = Color(0xFFf58b2a);
  static const _orangeLight = Color(0xFFFFF3E8);
  static const _orangeSoft = Color(0xFFFFE0BC);

  @override
  void initState() {
    super.initState();
    _viewModel = EspLspViewModel();
    _controller = TextEditingController(text: _viewModel?.sentence ?? '');
    _searchFocusNode.addListener(() {
      if (!_searchFocusNode.hasFocus) {
        setState(() => _showSuggestions = false);
      }
    });
  }
  @override
  void dispose() {
    _controller?.dispose();
    _searchFocusNode.dispose();
    _viewModel?.disposeModel();
    super.dispose();
  }

 
  List<String> _getAllWords(EspLspViewModel viewModel) {
    final words = <String>[];
    viewModel.signosData.forEach((_, categoryData) {
      if (categoryData is Map<String, dynamic>) {
        categoryData.forEach((_, subcategoryData) {
          if (subcategoryData is List) {
            for (final item in subcategoryData) {
              if (item is Map<String, dynamic> && item['palabra'] != null) {
                words.add(item['palabra'].toString());
              }
            }
          }
        });
      }
    });
    return words;
  }

  void _updateSuggestions(String input, EspLspViewModel viewModel) {
    if (input.isEmpty) {
      setState(() { _suggestions = []; _showSuggestions = false; });
      return;
    }
    final filtered = _getAllWords(viewModel)
        .where((w) => w.toLowerCase().startsWith(input.toLowerCase()))
        .take(6)
        .toList();
    setState(() {
      _suggestions = filtered;
      _showSuggestions = filtered.isNotEmpty;
    });
  }

  List<String> _getCategories(EspLspViewModel viewModel) =>
      viewModel.signosData.keys.toList();

  List<String> _getSubcategories(EspLspViewModel viewModel, String category) {
    final cat = viewModel.signosData[category];
    if (cat is Map<String, dynamic>) return cat.keys.toList();
    return [];
  }

  bool get _hasActiveFilter => _selectedCategory != null || _selectedSubcategory != null;

  String get _filterLabel {
    if (_selectedCategory == null) return "Categorías";
    if (_selectedSubcategory == null) return _selectedCategory!.replaceAll('_', ' ');
    return "${_selectedCategory!.replaceAll('_', ' ')} · ${_selectedSubcategory!.replaceAll('_', ' ')}";
  }

  // Abre el modal de selección de categoría y subcategoría
  void _showFilterModal(BuildContext context, EspLspViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final categories = _getCategories(viewModel);
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.55,
              maxChildSize: 0.85,
              minChildSize: 0.35,
              builder: (context, scrollController) {
                return Column(
                  children: [
                    // Handle
                    Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 8),
                      width: 40, height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Row(
                        children: [
                          const Text("Filtrar por categoría",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const Spacer(),
                          TextButton(
                            onPressed: () {
                              setState(() { _selectedCategory = null; _selectedSubcategory = null; });
                              Navigator.pop(context);
                            },
                            child: const Text("Ver todas", style: TextStyle(color: _orange)),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: ListView(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        children: categories.map((cat) {
                          final subcategories = _getSubcategories(viewModel, cat);
                          final isCatSelected = _selectedCategory == cat;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Fila de categoría
                              InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () {
                                  setModalState(() {});
                                  setState(() {
                                    _selectedCategory = isCatSelected ? null : cat;
                                    _selectedSubcategory = null;
                                  });
                                  if (subcategories.isEmpty) Navigator.pop(context);
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(vertical: 4),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: isCatSelected ? _orange : _orangeLight,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isCatSelected ? _orange : _orangeSoft,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.folder_outlined,
                                          size: 18, color: isCatSelected ? Colors.white : _orange),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(cat.replaceAll('_', ' '),
                                          style: TextStyle(
                                            fontSize: 14, fontWeight: FontWeight.w600,
                                            color: isCatSelected ? Colors.white : Colors.black87,
                                          ),
                                        ),
                                      ),
                                      Icon(
                                        isCatSelected ? Icons.expand_less : Icons.expand_more,
                                        color: isCatSelected ? Colors.white : _orange, size: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Subcategorías desplegables
                              if (isCatSelected && subcategories.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(left: 16, bottom: 4),
                                  child: Column(
                                    children: subcategories.map((sub) {
                                      final isSubSelected = _selectedSubcategory == sub;
                                      return InkWell(
                                        borderRadius: BorderRadius.circular(10),
                                        onTap: () {
                                          setState(() {
                                            _selectedSubcategory = isSubSelected ? null : sub;
                                          });
                                          Navigator.pop(context);
                                        },
                                        child: Container(
                                          margin: const EdgeInsets.only(bottom: 4),
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                          decoration: BoxDecoration(
                                            color: isSubSelected ? _orange.withOpacity(0.15) : Colors.white,
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(
                                              color: isSubSelected ? _orange : Colors.grey.shade200,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(Icons.subdirectory_arrow_right,
                                                  size: 14, color: Colors.grey.shade400),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(sub.replaceAll('_', ' '),
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: isSubSelected ? FontWeight.bold : FontWeight.w400,
                                                    color: isSubSelected ? _orange : Colors.black87,
                                                  ),
                                                ),
                                              ),
                                              if (isSubSelected)
                                                const Icon(Icons.check_rounded, color: _orange, size: 16),
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final videoHeight = size.height * 0.32;

    return Scaffold(
      appBar: Topbar(title: "Texto a Señas"),
      resizeToAvoidBottomInset: false,
      body: AppBackground(
        child: ChangeNotifierProvider<EspLspViewModel>.value(
          value: _viewModel!,
          child: Consumer<EspLspViewModel>(
            builder: (context, viewModel, child) {
              return SafeArea(
                child: Column(
                  children: [
                    // Sección superior blanca
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                      child: Column(
                        children: [
                          // Buscador
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: _orangeLight,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: _orangeSoft, width: 1.5),
                                ),
                                child: Row(
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.only(left: 14),
                                      child: Icon(Icons.search_rounded, color: _orange, size: 22),
                                    ),
                                    Expanded(
                                      child: TextField(
                                        controller: _controller,
                                        focusNode: _searchFocusNode,
                                        onChanged: (text) {
                                          viewModel.updateSentence(text);
                                          _updateSuggestions(text, viewModel);
                                        },
                                        maxLines: 1,
                                        style: const TextStyle(
                                          color: Colors.black87,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        decoration: const InputDecoration(
                                          hintText: 'Escribe una seña...',
                                          hintStyle: TextStyle(color: Colors.black38),
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                        ),
                                      ),
                                    ),
                                    if (viewModel.sentence.isNotEmpty)
                                      IconButton(
                                        icon: const Icon(Icons.close_rounded, color: _orange, size: 20),
                                        onPressed: () {
                                          _controller?.clear();
                                          viewModel.updateSentence('');
                                          setState(() { _suggestions = []; _showSuggestions = false; });
                                        },
                                      ),
                                  ],
                                ),
                              ),

                              // Sugerencias
                              if (_showSuggestions && _suggestions.isNotEmpty)
                                Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: _orangeSoft),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.08),
                                        blurRadius: 8, offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: _suggestions.map((word) => InkWell(
                                      onTap: () {
                                        _controller?.text = word;
                                        viewModel.updateSentence(word);
                                        viewModel.translate();
                                        _searchFocusNode.unfocus();
                                        setState(() { _suggestions = []; _showSuggestions = false; });
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.play_arrow_rounded, color: _orange, size: 16),
                                            const SizedBox(width: 10),
                                            Text(word, style: const TextStyle(
                                              fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87,
                                            )),
                                          ],
                                        ),
                                      ),
                                    )).toList(),
                                  ),
                                ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // Video centrado
                          Center(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                width: size.width * 0.88,
                                height: videoHeight,
                                color: _orangeLight,
                                child: viewModel.controller == null
                                    ? Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.play_circle_outline_rounded,
                                              color: _orange.withOpacity(0.4), size: 52),
                                          const SizedBox(height: 8),
                                          Text(
                                            "Selecciona una palabra para ver la seña",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: _orange.withOpacity(0.6),
                                              fontSize: 13, fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      )
                                    : Stack(
                                        children: [
                                          VideoPlay(
                                            controller: viewModel.controller!,
                                            targetHeight: videoHeight,
                                            targetWidth: size.width * 0.88,
                                            marginVertical: 0,
                                            marginHorizontal: 0,
                                            radius: 16,
                                          ),
                                          if (viewModel.sentence.isNotEmpty)
                                            Positioned(
                                              bottom: 10, left: 10,
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                decoration: BoxDecoration(
                                                  color: Colors.black.withOpacity(0.55),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  viewModel.sentence,
                                                  style: const TextStyle(
                                                    color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 14),
                        ],
                      ),
                    ),

                    // Barra de filtros: botón categorías + botón reset
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              // Botón desplegable de categorías
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => _showFilterModal(context, viewModel),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: _hasActiveFilter ? _orange : _orangeLight,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: _hasActiveFilter ? _orange : _orangeSoft,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.filter_list_rounded,
                                            size: 18,
                                            color: _hasActiveFilter ? Colors.white : _orange),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            _filterLabel,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            softWrap: true,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: _hasActiveFilter ? Colors.white : _orange,
                                            ),
                                          ),
                                        ),
                                        Icon(Icons.keyboard_arrow_down_rounded,
                                            size: 18,
                                            color: _hasActiveFilter ? Colors.white : _orange),
                                      ],
                                    ),
                                  ),
                                ),
                              ),


                            ],
                          ),

                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Text("PALABRAS DISPONIBLES", style: TextStyle(
                                fontSize: 10, fontWeight: FontWeight.w700,
                                color: Colors.grey.shade400, letterSpacing: 1.2,
                              )),
                              const SizedBox(width: 8),
                              Expanded(child: Container(height: 1, color: _orangeSoft)),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Lista filtrada
                    Expanded(child: _buildWordsList(viewModel)),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildWordsList(EspLspViewModel viewModel) {
    if (viewModel.signosData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.hourglass_empty_rounded, color: Colors.grey.shade300, size: 40),
            const SizedBox(height: 8),
            Text("Cargando palabras...", style: TextStyle(fontSize: 14, color: Colors.grey.shade400)),
          ],
        ),
      );
    }
    return Container(color: Colors.grey.shade50, child: _buildCategorizedWordsList(viewModel));
  }

  Widget _buildCategorizedWordsList(EspLspViewModel viewModel) {
    final List<Widget> widgets = [];

    viewModel.signosData.forEach((categoryName, categoryData) {
      if (_selectedCategory != null && _selectedCategory != categoryName) return;
      if (categoryData is Map<String, dynamic>) {
        categoryData.forEach((subcategoryName, subcategoryData) {
          if (_selectedSubcategory != null && _selectedSubcategory != subcategoryName) return;
          if (subcategoryData is List && subcategoryData.isNotEmpty) {
            widgets.add(_buildSubcategorySection(categoryName, subcategoryName, subcategoryData, viewModel));
          }
        });
      }
    });

    if (widgets.isEmpty) {
      return Center(child: Text("No hay palabras en esta categoría",
          style: TextStyle(fontSize: 14, color: Colors.grey.shade400)));
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: widgets,
    );
  }

  Widget _buildSubcategorySection(String categoryName, String subcategoryName,
      List subcategoryData, EspLspViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 14, bottom: 8),
          child: Row(
            children: [
              Container(width: 3, height: 14,
                decoration: BoxDecoration(color: _orange, borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "${categoryName.replaceAll('_', ' ')} · ${subcategoryName.replaceAll('_', ' ')}",
                  maxLines: 2,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600, letterSpacing: 0.3),
                ),
              ),
            ],
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 3.2,
          ),
          itemCount: subcategoryData.length,
          itemBuilder: (context, index) {
            final item = subcategoryData[index];
            if (item is Map<String, dynamic> && item['palabra'] != null) {
              return _buildWordChip(item['palabra'], viewModel);
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildWordChip(String palabra, EspLspViewModel viewModel) {
    final isActive = viewModel.sentence.toLowerCase() == palabra.toLowerCase();

    return GestureDetector(
      onTap: () {
        _controller?.text = palabra;
        viewModel.updateSentence(palabra);
        viewModel.translate();
        _searchFocusNode.unfocus();
        setState(() { _suggestions = []; _showSuggestions = false; });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: isActive ? _orange : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isActive ? _orange : Colors.grey.shade200, width: isActive ? 0 : 1),
          boxShadow: isActive
              ? [BoxShadow(color: _orange.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))]
              : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 1))],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: [
            Icon(Icons.play_arrow_rounded, size: 16, color: isActive ? Colors.white : _orange),
            const SizedBox(width: 6),
            Expanded(
              child: Text(palabra,
                maxLines: 1, overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                  color: isActive ? Colors.white : Colors.black87)),
            ),
          ],
        ),
      ),
    );
  }
}