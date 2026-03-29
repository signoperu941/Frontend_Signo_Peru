import 'package:flutter/material.dart';
import 'package:signo_peru_app/components/atoms/background.dart';
import 'package:signo_peru_app/components/organisms/topbar.dart';

class DonaScreen extends StatelessWidget {
  const DonaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Topbar(title: "Dona tu Seña"),
      body: AppBackground(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: const Color(0xFFf58b2a).withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.construction_rounded,
                    size: 72,
                    color: Color(0xFFf58b2a),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  "Próximamente",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFf58b2a),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Estamos trabajando para que puedas donar tus propias señas y contribuir al aprendizaje del LSP.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 40),
                OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Color(0xFFf58b2a)),
                  label: const Text(
                    "Volver",
                    style: TextStyle(color: Color(0xFFf58b2a)),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFf58b2a)),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
