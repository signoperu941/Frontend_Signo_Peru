import 'package:flutter/material.dart';
import 'package:signo_peru_app/components/atoms/background.dart';
import 'package:signo_peru_app/components/atoms/logo.dart';
import 'package:signo_peru_app/components/organisms/help_modal.dart';
import 'package:signo_peru_app/view_model/onboarding_viewmodel.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<StatefulWidget> createState() => SplashScreenState();
}

class SplashScreenState extends State<Onboarding> {
  OnboardingViewmodel? _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = OnboardingViewmodel();
  }

  Widget _buildButton({
    required String label,
    required Widget trailing,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      height: 65,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: const Color(0xFFf58b2a), width: 2.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFf58b2a).withOpacity(0.25),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(40),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                trailing,
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFf58b2a).withOpacity(0.3),
                      spreadRadius: 4,
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const CircleAvatar(
                  radius: 120,
                  backgroundColor: Color(0xFFf58b2a),
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Logo(
                      width: 180,
                      color: Color(0xFFE7E0EC),
                      location: 'assets/logo.png',
                      height: 180,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    _buildButton(
                      label: "Aprende LSP",
                      trailing: const Text("📖", style: TextStyle(fontSize: 28)),
                      onPressed: () => Navigator.pushNamed(context, "/learn"),
                    ),
                    const SizedBox(height: 20),
                    _buildButton(
                      label: "Texto a Señas",
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text("Aa", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, fontFamily: 'serif', color: Colors.black87)),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4),
                            child: Text("→", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black87)),
                          ),
                          SizedBox(
                            width: 48, height: 48,
                            child: Image.asset("assets/sena.png", fit: BoxFit.contain),
                          ),
                        ],
                      ),
                      onPressed: () => Navigator.pushNamed(context, "/esp-lsp"),
                    ),
                    const SizedBox(height: 20),
                    _buildButton(
                      label: "Señas a Texto",
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 48, height: 48,
                            child: Image.asset("assets/sena.png", fit: BoxFit.contain),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4),
                            child: Text("→", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black87)),
                          ),
                          const Text("Aa", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, fontFamily: 'serif', color: Colors.black87)),
                        ],
                      ),
                      onPressed: () => Navigator.pushNamed(context, "/lsp"),
                    ),
                    const SizedBox(height: 20),
                    _buildButton(
                      label: "Dona tu Seña",
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 48, height: 48,
                            child: Image.asset("assets/sena.png", fit: BoxFit.contain),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4),
                            child: Text("→", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black87)),
                          ),
                          const Text("🗄️", style: TextStyle(fontSize: 26)),
                        ],
                      ),
                      onPressed: () => Navigator.pushNamed(context, "/dona"),
                    ),
                    const SizedBox(height: 20),
                    _buildButton(
                      label: "Ayuda",
                      trailing: const Text("❓", style: TextStyle(fontSize: 28)),
                      onPressed: () {
                        _viewModel!.initializeController();
                        showDialog(
                          context: context,
                          builder: (context) =>
                              HelpModal(viewModel: _viewModel!),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
