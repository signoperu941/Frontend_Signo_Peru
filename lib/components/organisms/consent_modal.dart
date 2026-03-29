import 'package:flutter/material.dart';
import 'package:signo_peru_app/components/atoms/signature_pad.dart';

/// Muestra el formulario de consentimiento informado como un bottom-sheet
/// scrollable de casi pantalla completa.
///
/// Retorna los datos del formulario mediante [onAccept] cuando el usuario
/// confirma, o cierra sin datos si cancela.
Future<void> showConsentModal(
  BuildContext context, {
  required void Function(Map<String, dynamic> data) onAccept,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _ConsentSheet(onAccept: onAccept),
  );
}

class _ConsentSheet extends StatefulWidget {
  final void Function(Map<String, dynamic> data) onAccept;

  const _ConsentSheet({required this.onAccept});

  @override
  State<_ConsentSheet> createState() => _ConsentSheetState();
}

class _ConsentSheetState extends State<_ConsentSheet> {
  static const Color _orange = Color(0xFFf58b2a);
  static const Color _red = Color(0xFFe74c3c);

  final _sigPadKey = GlobalKey<SignaturePadState>();

  // Campos
  String _nombre = '';
  String _correo = '';
  String _telefono = '';
  String _dni = '';
  String _firma = '';
  bool _accepted = false;

  // Errores
  String _errorNombre = '';
  String _errorCorreo = '';
  String _errorTelefono = '';
  String _errorDni = '';
  String _errorFirma = '';

  String get _fechaActual {
    final now = DateTime.now();
    return '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
  }

  bool get _isValid =>
      _nombre.trim().length >= 3 &&
      _errorNombre.isEmpty &&
      _correo.contains('@') &&
      _errorCorreo.isEmpty &&
      _telefono.length == 9 &&
      _errorTelefono.isEmpty &&
      _dni.length == 8 &&
      _errorDni.isEmpty &&
      _firma.isNotEmpty &&
      _accepted;

  // ── Validaciones ─────────────────────────────────────────────────────────────

  void _onNombreChanged(String v) {
    // Solo letras y espacios
    final clean = v.replaceAll(RegExp(r'[^a-zA-ZáéíóúÁÉÍÓÚñÑ\s]'), '');
    setState(() {
      _nombre = clean;
      _errorNombre = clean.trim().isNotEmpty && clean.trim().length < 3
          ? 'El nombre es muy corto.'
          : '';
    });
  }

  void _onCorreoChanged(String v) {
    setState(() {
      _correo = v;
      _errorCorreo = v.isNotEmpty &&
              !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(v)
          ? 'Formato de correo inválido.'
          : '';
    });
  }

  void _onTelefonoChanged(String v) {
    final digits = v.replaceAll(RegExp(r'\D'), '');
    final limited = digits.length > 9 ? digits.substring(0, 9) : digits;
    setState(() {
      _telefono = limited;
      if (limited.isNotEmpty && limited.length < 9) {
        _errorTelefono = 'El número debe tener 9 dígitos.';
      } else if (limited.isNotEmpty && !limited.startsWith('9')) {
        _errorTelefono = 'El número debe empezar con 9.';
      } else {
        _errorTelefono = '';
      }
    });
  }

  void _onDniChanged(String v) {
    final digits = v.replaceAll(RegExp(r'\D'), '');
    final limited = digits.length > 8 ? digits.substring(0, 8) : digits;
    setState(() {
      _dni = limited;
      _errorDni = limited.isNotEmpty && limited.length < 8
          ? 'El DNI debe tener 8 dígitos.'
          : '';
    });
  }

  void _onFirmaChanged(String b64) {
    setState(() {
      _firma = b64;
      _errorFirma = b64.isEmpty ? 'La firma es obligatoria.' : '';
    });
  }

  // ── UI helpers ────────────────────────────────────────────────────────────────

  InputDecoration _decoration(String hint, String error) => InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              BorderSide(color: error.isNotEmpty ? _red : Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              BorderSide(color: error.isNotEmpty ? _red : Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              BorderSide(color: error.isNotEmpty ? _red : _orange, width: 1.5),
        ),
        errorText: error.isNotEmpty ? error : null,
        errorStyle: const TextStyle(fontSize: 11, color: _red),
      );

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6, top: 12),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.93,
      maxChildSize: 0.97,
      minChildSize: 0.5,
      expand: false,
      builder: (ctx, scrollCtrl) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 4),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 12, 0),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Consentimiento Informado',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: _orange,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                      color: Colors.grey.shade600,
                    ),
                  ],
                ),
              ),

              // Form content
              Expanded(
                child: ListView(
                  controller: scrollCtrl,
                  padding: EdgeInsets.fromLTRB(
                      20, 8, 20, 24 + mq.viewInsets.bottom),
                  children: [
                    Text(
                      'Para continuar con la donación de tu seña, completa la siguiente información. Estos datos solo se usarán para fines de investigación.',
                      style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                          height: 1.5),
                    ),
                    const SizedBox(height: 4),

                    // Info sobre privacidad
                    _InfoBox(),

                    // ── Fecha ────────────────────────────────────────────────
                    _label('Fecha'),
                    TextFormField(
                      initialValue: _fechaActual,
                      readOnly: true,
                      style: TextStyle(
                          color: Colors.grey.shade500, fontSize: 14),
                      decoration: _decoration('', '').copyWith(
                        filled: true,
                        fillColor: Colors.grey.shade100,
                      ),
                    ),

                    // ── Nombre ───────────────────────────────────────────────
                    _label('Nombre Completo'),
                    TextFormField(
                      initialValue: _nombre,
                      onChanged: _onNombreChanged,
                      keyboardType: TextInputType.name,
                      textCapitalization: TextCapitalization.words,
                      style:
                          const TextStyle(fontSize: 14, color: Colors.black87),
                      decoration:
                          _decoration('Ej. Juan Pérez García', _errorNombre),
                    ),

                    // ── DNI ──────────────────────────────────────────────────
                    _label('DNI'),
                    TextFormField(
                      initialValue: _dni,
                      onChanged: _onDniChanged,
                      keyboardType: TextInputType.number,
                      maxLength: 8,
                      style:
                          const TextStyle(fontSize: 14, color: Colors.black87),
                      decoration: _decoration('Ej. 12345678', _errorDni)
                          .copyWith(counterText: ''),
                    ),

                    // ── Correo ───────────────────────────────────────────────
                    _label('Correo Electrónico'),
                    TextFormField(
                      initialValue: _correo,
                      onChanged: _onCorreoChanged,
                      keyboardType: TextInputType.emailAddress,
                      style:
                          const TextStyle(fontSize: 14, color: Colors.black87),
                      decoration:
                          _decoration('Ej. juan@correo.com', _errorCorreo),
                    ),

                    // ── Teléfono ─────────────────────────────────────────────
                    _label('Número de Teléfono (Perú)'),
                    TextFormField(
                      initialValue: _telefono,
                      onChanged: _onTelefonoChanged,
                      keyboardType: TextInputType.phone,
                      maxLength: 9,
                      style:
                          const TextStyle(fontSize: 14, color: Colors.black87),
                      decoration:
                          _decoration('Ej. 987654321', _errorTelefono)
                              .copyWith(counterText: ''),
                    ),

                    // ── Firma ────────────────────────────────────────────────
                    _label('Firma Digital'),
                    SignaturePad(
                      key: _sigPadKey,
                      onChanged: _onFirmaChanged,
                    ),
                    if (_errorFirma.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          _errorFirma,
                          style:
                              const TextStyle(fontSize: 11, color: _red),
                        ),
                      ),

                    const SizedBox(height: 16),

                    // ── Aceptación ───────────────────────────────────────────
                    GestureDetector(
                      onTap: () =>
                          setState(() => _accepted = !_accepted),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: _accepted
                              ? _orange.withOpacity(0.06)
                              : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _accepted
                                ? _orange.withOpacity(0.4)
                                : Colors.grey.shade200,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Checkbox(
                              value: _accepted,
                              onChanged: (v) =>
                                  setState(() => _accepted = v ?? false),
                              activeColor: _orange,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Acepto que mi información y el video grabado sean utilizados exclusivamente para fines de investigación y entrenamiento del modelo de IA de SignoPerú.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade700,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Botones ──────────────────────────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.grey.shade600,
                              side: BorderSide(color: Colors.grey.shade300),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Cancelar',
                                style: TextStyle(fontWeight: FontWeight.w700)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: _isValid
                                ? () {
                                    widget.onAccept({
                                      'nombre': _nombre.trim(),
                                      'correo': _correo.trim(),
                                      'dni': _dni,
                                      'telefono': _telefono,
                                      'fecha': _fechaActual,
                                      'firma': _firma,
                                    });
                                    Navigator.pop(context);
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _orange,
                              disabledBackgroundColor:
                                  Colors.grey.shade200,
                              foregroundColor: Colors.white,
                              disabledForegroundColor:
                                  Colors.grey.shade400,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Guardar y Continuar',
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _InfoBox extends StatefulWidget {
  @override
  State<_InfoBox> createState() => _InfoBoxState();
}

class _InfoBoxState extends State<_InfoBox> {
  bool _expanded = false;
  static const Color _orange = Color(0xFFf58b2a);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 4),
      decoration: BoxDecoration(
        color: _orange.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _orange.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      color: _orange, size: 18),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Ver más información sobre el uso de tus datos',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _orange,
                      ),
                    ),
                  ),
                  Icon(
                    _expanded
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    color: _orange,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 1),
                  const SizedBox(height: 10),
                  _infoItem(
                      'Tus datos serán almacenados de forma segura.'),
                  _infoItem(
                      'No compartiremos tu información con terceros no autorizados.'),
                  _infoItem(
                      'Puedes solicitar la eliminación de tus datos en cualquier momento enviando un correo a soporte@signoperu.com.'),
                  _infoItem(
                      'Las grabaciones se anonimizarán para el entrenamiento de la IA.'),
                  const SizedBox(height: 6),
                  Text(
                    'Ley de Protección de Datos Personales (Ley N° 29733) – Perú.',
                    style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                        fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _infoItem(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('• ',
                style:
                    TextStyle(color: _orange, fontWeight: FontWeight.bold)),
            Expanded(
              child: Text(
                text,
                style:
                    TextStyle(fontSize: 12, color: Colors.grey.shade700, height: 1.4),
              ),
            ),
          ],
        ),
      );
}
