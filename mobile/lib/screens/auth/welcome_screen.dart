import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:memoire/constants/app_theme.dart';
import 'package:memoire/widgets/auth_widgets/login_button.dart';
import 'package:memoire/widgets/auth_widgets/register_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      body: Stack(
        children: [
          // 🔹 Image de fond nette et responsive
          Positioned.fill(
            child: Image.asset(
              'assets/images/ITMA.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // 🔹 Overlay assombri
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
            ),
          ),

          // 🔹 Contenu principal
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 🔹 Texte animé "Bienvenue sur AlumniFy 🎓"
                    SizedBox(
                      width: size.width * 0.9,
                      child: DefaultTextStyle(
                        style: textTheme.displaySmall!.copyWith(
                          fontFamily: 'serif',
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: size.width < 600 ? 28 : 40,
                        ),
                        child: AnimatedTextKit(
                          animatedTexts: [
                            TypewriterAnimatedText(
                              'Bienvenue sur AlumniFy 🎓',
                              speed: const Duration(milliseconds: 80),
                            ),
                          ],
                          totalRepeatCount: 1,
                          pause: const Duration(milliseconds: 1000),
                          displayFullTextOnTap: true,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 🔹 Sous-texte explicatif
                    Text(
                      'Rejoignez une communauté dynamique\net connectez-vous avec les anciens de votre filière.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: size.width < 600 ? 14 : 16,
                        fontFamily: 'serif',
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 60),

                    // 🔹 Boutons
                    SizedBox(
                      width: double.infinity,
                      child: LoginButton(),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: RegisterButton(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
