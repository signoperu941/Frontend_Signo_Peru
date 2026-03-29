import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:signo_peru_app/components/atoms/background.dart';
import 'package:signo_peru_app/components/organisms/consent_modal.dart';
import 'package:signo_peru_app/components/organisms/topbar.dart';
import 'package:signo_peru_app/view_model/donation_viewmodel.dart';

class DonaScreen extends StatefulWidget {
  const DonaScreen({super.key});

  @override
  State<DonaScreen> createState() => _DonaScreenState();
}

class _DonaScreenState extends State<DonaScreen> {
  late final DonationViewModel _vm;
  final TextEditingController _searchCtrl = TextEditingController();
  final TextEditingController _newSignCtrl = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  List<String> _suggestions = [];
  bool _showSuggestions = false;

  static const Color _orange = Color(0xFFf58b2a);
  static const Color _orangeLight = Color(0xFFFFF3E8);

  @override
  void initState() {
    super.initState();
    _vm = DonationViewModel();
    _vm.fetchWords();
    _searchFocus.addListener(() {
      if (!_searchFocus.hasFocus) {
        setState(() => _showSuggestions = false);
      }
    });
  }

  @override
  void dispose() {
    _vm.dispose();
    _searchCtrl.dispose();
    _newSignCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _updateSuggestions(String input) {
    if (input.isEmpty || _vm.allWords.isEmpty) {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
      });
      return;
    }
    final filtered = _vm.allWords
        .where((w) => w.toLowerCase().contains(input.toLowerCase()))
        .take(8)
        .toList();
    setState(() {
      _suggestions = filtered;
      _showSuggestions = filtered.isNotEmpty;
    });
  }

  void _selectWord(String word) {
    _searchCtrl.text = word;
    _searchFocus.unfocus();
    setState(() {
      _suggestions = [];
      _showSuggestions = false;
    });
    _vm.fetchReferenceVideo(word);
  }

  Future<void> _openConsent() async {
    await showConsentModal(
      context,
      onAccept: (data) => _vm.applyConsent(data),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Build
  // ────────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Topbar(title: 'Dona tu Seña'),
      body: AppBackground(
        child: ChangeNotifierProvider<DonationViewModel>.value(
          value: _vm,
          child: Consumer<DonationViewModel>(
            builder: (context, vm, _) {
              return SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 20),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 20),
                      _buildSignSelectionSection(vm),
                      const SizedBox(height: 16),
                      _buildConsentSection(vm),
                      const SizedBox(height: 16),
                      _buildCameraSection(vm),
                      const SizedBox(height: 16),
                      if (vm.cameraState == DonationCameraState.recorded ||
                          vm.cameraState == DonationCameraState.submitted ||
                          vm.submitMessage != null)
                        _buildSubmitSection(vm),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Sección: Header
  // ────────────────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: const TextSpan(
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Colors.black87),
            children: [
              TextSpan(text: 'Ayúdanos a '),
              TextSpan(
                  text: 'mejorar',
                  style: TextStyle(color: _orange)),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Tu participación es clave para entrenar nuestro modelo de IA. '
          'Selecciona la seña que deseas donar y grábala siguiendo las instrucciones.',
          style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
              height: 1.5),
        ),
      ],
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Sección 1: Selección de seña
  // ────────────────────────────────────────────────────────────────────────────

  Widget _buildSignSelectionSection(DonationViewModel vm) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('1. ¿Qué seña vas a grabar?'),
          const SizedBox(height: 12),

          // Toggle diccionario / nueva
          Row(
            children: [
              Expanded(
                child: _ToggleBtn(
                  label: 'Del Diccionario',
                  selected: vm.signType == SignType.diccionario,
                  onTap: () {
                    vm.setSignType(SignType.diccionario);
                    _searchCtrl.clear();
                    _newSignCtrl.clear();
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ToggleBtn(
                  label: 'Seña Nueva',
                  selected: vm.signType == SignType.nueva,
                  onTap: () {
                    vm.setSignType(SignType.nueva);
                    _searchCtrl.clear();
                    _newSignCtrl.clear();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          if (vm.signType == SignType.diccionario)
            _buildDictionarySearch(vm)
          else
            _buildNewSignInput(vm),
        ],
      ),
    );
  }

  Widget _buildDictionarySearch(DonationViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Buscador
        Container(
          decoration: BoxDecoration(
            color: _orangeLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _orange.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 12),
                child: Icon(Icons.search_rounded, color: _orange, size: 20),
              ),
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  focusNode: _searchFocus,
                  onChanged: (v) {
                    _updateSuggestions(v);
                  },
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                  decoration: InputDecoration(
                    hintText: vm.isLoadingWords
                        ? 'Cargando palabras...'
                        : 'Busca una seña...',
                    hintStyle: TextStyle(
                        color: Colors.grey.shade400, fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 12),
                  ),
                ),
              ),
              if (_searchCtrl.text.isNotEmpty)
                IconButton(
                  icon:
                      Icon(Icons.close_rounded, color: _orange, size: 18),
                  onPressed: () {
                    _searchCtrl.clear();
                    setState(() {
                      _suggestions = [];
                      _showSuggestions = false;
                    });
                    vm.setSignType(SignType.diccionario);
                  },
                ),
            ],
          ),
        ),

        // Sugerencias
        if (_showSuggestions)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _orange.withOpacity(0.2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: _suggestions
                  .map(
                    (word) => InkWell(
                      onTap: () => _selectWord(word),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        child: Row(
                          children: [
                            Icon(Icons.play_arrow_rounded,
                                color: _orange, size: 16),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                word,
                                style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),

        // Seña seleccionada
        if (vm.selectedSign != null) ...[
          const SizedBox(height: 10),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.withOpacity(0.35)),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline_rounded,
                    color: Colors.green, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Seña seleccionada: ${vm.selectedSign!.replaceAll('_', ' ')}',
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.green),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _buildReferenceVideo(vm),
        ],
      ],
    );
  }

  Widget _buildNewSignInput(DonationViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _newSignCtrl,
                onChanged: vm.updateNewSignName,
                style:
                    const TextStyle(fontSize: 14, color: Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Escribe el nombre de la nueva seña...',
                  hintStyle: TextStyle(
                      color: Colors.grey.shade400, fontSize: 13),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: _orange, width: 1.5),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: vm.newSignName.trim().isNotEmpty
                  ? vm.confirmNewSign
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    vm.isNewSignConfirmed ? Colors.green : _orange,
                disabledBackgroundColor: Colors.grey.shade200,
                foregroundColor: Colors.white,
                disabledForegroundColor: Colors.grey.shade400,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              child: Text(
                vm.isNewSignConfirmed ? '✓' : 'Confirmar',
                style: const TextStyle(
                    fontWeight: FontWeight.w800, fontSize: 13),
              ),
            ),
          ],
        ),
        if (vm.isNewSignConfirmed) ...[
          const SizedBox(height: 8),
          Text(
            'Seña confirmada: "${vm.newSignName.trim()}"',
            style: const TextStyle(
                fontSize: 12,
                color: Colors.green,
                fontWeight: FontWeight.w600),
          ),
        ],
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _orange.withOpacity(0.06),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _orange.withOpacity(0.2)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline_rounded,
                  color: _orange, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Como es una seña nueva, no hay video de referencia. '
                  'Guíate por las instrucciones de grabación.',
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      height: 1.4),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReferenceVideo(DonationViewModel vm) {
    final w = MediaQuery.of(context).size.width - 64;
    final h = w * 0.6;

    if (vm.isLoadingReferenceVideo) {
      return Container(
        height: h,
        decoration: BoxDecoration(
          color: _orangeLight,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Center(
          child: CircularProgressIndicator(
              color: _orange, strokeWidth: 2),
        ),
      );
    }

    if (vm.referenceVideoNotFound ||
        vm.referenceVideoController == null) {
      return Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Center(
          child: Text(
            'No hay video de referencia disponible',
            style: TextStyle(
                fontSize: 13, color: Colors.grey.shade400),
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        width: w,
        height: h,
        child: AspectRatio(
          aspectRatio:
              vm.referenceVideoController!.value.aspectRatio,
          child: VideoPlayer(vm.referenceVideoController!),
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Sección 2: Consentimiento
  // ────────────────────────────────────────────────────────────────────────────

  Widget _buildConsentSection(DonationViewModel vm) {
    return _Card(
      borderColor: vm.hasConsented
          ? Colors.green.withOpacity(0.4)
          : _orange.withOpacity(0.2),
      backgroundColor: vm.hasConsented
          ? Colors.green.withOpacity(0.04)
          : null,
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: vm.hasConsented
                  ? Colors.green.withOpacity(0.12)
                  : _orange.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              vm.hasConsented
                  ? Icons.check_rounded
                  : Icons.description_outlined,
              color: vm.hasConsented ? Colors.green : _orange,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionLabel('2. Consentimiento Informado'),
                const SizedBox(height: 2),
                Text(
                  vm.hasConsented
                      ? 'Datos guardados correctamente.'
                      : 'Requerimos tus datos y consentimiento para guardar el video.',
                  style: TextStyle(
                    fontSize: 12,
                    color: vm.hasConsented
                        ? Colors.green
                        : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _openConsent,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: vm.hasConsented
                    ? Colors.green.withOpacity(0.12)
                    : _orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: vm.hasConsented
                      ? Colors.green.withOpacity(0.4)
                      : _orange.withOpacity(0.35),
                ),
              ),
              child: Text(
                vm.hasConsented ? 'Editar' : 'Completar',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: vm.hasConsented ? Colors.green : _orange,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Sección 3: Cámara
  // ────────────────────────────────────────────────────────────────────────────

  Widget _buildCameraSection(DonationViewModel vm) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('3. Graba tu Seña'),
          const SizedBox(height: 12),

          if (!vm.hasConsented)
            _buildLockedCamera()
          else
            _buildActiveCamera(vm),
        ],
      ),
    );
  }

  Widget _buildLockedCamera() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: Colors.grey.shade200, style: BorderStyle.solid),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.videocam_off_rounded,
              color: Colors.grey.shade300, size: 48),
          const SizedBox(height: 12),
          Text(
            'Cámara deshabilitada',
            style: TextStyle(
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w700,
                fontSize: 15),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Completa el consentimiento informado para activar la cámara.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.grey.shade400, fontSize: 12, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveCamera(DonationViewModel vm) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cameraWidth = screenWidth - 64;
    final cameraHeight = (cameraWidth * 4 / 3).clamp(200.0, 320.0);

    return Column(
      children: [
        // Vista de cámara
        Container(
          width: cameraWidth,
          height: cameraHeight,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(16),
          ),
          clipBehavior: Clip.hardEdge,
          child: _buildCameraPreview(vm, cameraWidth, cameraHeight),
        ),

        const SizedBox(height: 14),

        // Controles
        _buildCameraControls(vm),

        // Instrucciones
        if (vm.cameraState == DonationCameraState.idle ||
            vm.cameraState == DonationCameraState.loading) ...[
          const SizedBox(height: 14),
          _buildRecordingTips(),
        ],
      ],
    );
  }

  Widget _buildCameraPreview(
      DonationViewModel vm, double w, double h) {
    switch (vm.cameraState) {
      case DonationCameraState.loading:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
                color: _orange, strokeWidth: 2),
            const SizedBox(height: 12),
            const Text('Inicializando cámara...',
                style: TextStyle(color: Colors.white54, fontSize: 13)),
          ],
        );

      case DonationCameraState.error:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded,
                color: Colors.redAccent, size: 40),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                vm.cameraError ?? 'Error de cámara',
                style: const TextStyle(
                    color: Colors.white70, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        );

      case DonationCameraState.submitted:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline_rounded,
                color: Colors.green, size: 52),
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                '¡Donación enviada!',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        );

      case DonationCameraState.submitting:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
                color: _orange, strokeWidth: 2),
            const SizedBox(height: 12),
            const Text('Enviando donación...',
                style: TextStyle(color: Colors.white70, fontSize: 13)),
          ],
        );

      case DonationCameraState.recorded:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.videocam_rounded,
                color: Colors.green, size: 48),
            const SizedBox(height: 10),
            const Text(
              'Video grabado',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              'Listo para enviar',
              style:
                  TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
            ),
          ],
        );

      case DonationCameraState.countdown:
        return Stack(
          fit: StackFit.expand,
          children: [
            if (vm.cameraController?.value.isInitialized ?? false)
              CameraPreview(vm.cameraController!),
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.55),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${vm.countdownValue}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 42,
                        fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ),
          ],
        );

      case DonationCameraState.recording:
        return Stack(
          fit: StackFit.expand,
          children: [
            if (vm.cameraController?.value.isInitialized ?? false)
              CameraPreview(vm.cameraController!),
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.fiber_manual_record_rounded,
                        color: Colors.white, size: 10),
                    const SizedBox(width: 6),
                    const Text('Grabando...',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
          ],
        );

      // idle & uninitialized
      default:
        if (vm.cameraController?.value.isInitialized ?? false) {
          return Stack(
            fit: StackFit.expand,
            children: [
              CameraPreview(vm.cameraController!),
              // Botón voltear cámara
              Positioned(
                bottom: 10,
                right: 10,
                child: GestureDetector(
                  onTap: vm.toggleCamera,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.flip_camera_ios_outlined,
                        color: Colors.white, size: 20),
                  ),
                ),
              ),
            ],
          );
        }
        return const SizedBox.shrink();
    }
  }

  Widget _buildCameraControls(DonationViewModel vm) {
    switch (vm.cameraState) {
      case DonationCameraState.idle:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: vm.canRecord ? vm.startRecording : null,
            icon: const Icon(Icons.fiber_manual_record_rounded, size: 18),
            label: const Text('Iniciar Grabación (4 seg)',
                style: TextStyle(fontWeight: FontWeight.w700)),
            style: ElevatedButton.styleFrom(
              backgroundColor: _orange,
              disabledBackgroundColor: Colors.grey.shade200,
              foregroundColor: Colors.white,
              disabledForegroundColor: Colors.grey.shade400,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
          ),
        );

      case DonationCameraState.countdown:
      case DonationCameraState.recording:
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: _orange)),
              const SizedBox(width: 10),
              Text(
                vm.cameraState == DonationCameraState.countdown
                    ? 'Prepárate...'
                    : 'Grabando...',
                style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    fontSize: 14),
              ),
            ],
          ),
        );

      case DonationCameraState.recorded:
        return Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: vm.retryRecording,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Reintentar',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _orange,
                  side: const BorderSide(color: _orange),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: vm.submitDonation,
                icon: const Icon(Icons.upload_rounded, size: 18),
                label: const Text('Enviar Donación',
                    style: TextStyle(fontWeight: FontWeight.w800)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        );

      case DonationCameraState.submitted:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: vm.resetAfterSubmit,
            icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
            label: const Text('Donar otra seña',
                style: TextStyle(fontWeight: FontWeight.w700)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildRecordingTips() {
    final tips = [
      'Consulta los videos de referencia en el módulo Texto a Seña.',
      'Evita sombras fuertes y asegúrate de buena iluminación.',
      'Empieza en la posición inicial y mantén la postura final hasta terminar.',
      'Posiciónate para que tu torso y brazos estén dentro del encuadre.',
      'La grabación dura 4 segundos. Realiza la seña completa.',
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _orange.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _orange.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.videocam_outlined, color: _orange, size: 16),
              const SizedBox(width: 6),
              const Text(
                'INSTRUCCIONES DE GRABACIÓN',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: _orange,
                    letterSpacing: 0.8),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...tips.asMap().entries.map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: 7),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: _orange.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${e.key + 1}',
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: _orange),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          e.value,
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Sección 4: Estado del envío
  // ────────────────────────────────────────────────────────────────────────────

  Widget _buildSubmitSection(DonationViewModel vm) {
    if (vm.submitMessage == null) return const SizedBox.shrink();

    final isSuccess = vm.submitSuccess == true;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isSuccess
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSuccess
              ? Colors.green.withOpacity(0.35)
              : Colors.red.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isSuccess
                ? Icons.check_circle_outline_rounded
                : Icons.error_outline_rounded,
            color: isSuccess ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              vm.submitMessage!,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSuccess ? Colors.green : Colors.red,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Helpers
  // ────────────────────────────────────────────────────────────────────────────

  Widget _sectionLabel(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: Colors.black87,
          letterSpacing: 0.2,
        ),
      );
}

// ── Widgets reutilizables ─────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final Widget child;
  final Color? borderColor;
  final Color? backgroundColor;

  const _Card({
    required this.child,
    this.borderColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor ?? const Color(0xFFf58b2a).withOpacity(0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _ToggleBtn extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  static const Color _orange = Color(0xFFf58b2a);

  const _ToggleBtn({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? _orange.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color:
                selected ? _orange : Colors.grey.shade300,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: selected ? _orange : Colors.grey.shade500,
          ),
        ),
      ),
    );
  }
}
