import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class OAuthScreen extends StatefulWidget {
  const OAuthScreen({super.key, required this.onSignedIn});
  final VoidCallback onSignedIn;

  @override
  State<OAuthScreen> createState() => _OAuthScreenState();
}

class _OAuthScreenState extends State<OAuthScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: CurvedAnimation(
                parent: _controller,
                curve: Curves.easeOutBack,
              ),
              child: CircleAvatar(
                radius: 48,
                backgroundColor: Colors.black,
                child: Text('G',
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 24),
            Text('SuvyAIkth', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('Prototype 1 • by Team Shasakkta!!',
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 24),
            Lottie.network(
              'https://assets2.lottiefiles.com/packages/lf20_jbrw3hcz.json',
              width: 140,
              repeat: true,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: widget.onSignedIn,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
              child: const Text('Sign in with Google (mock)'),
            ),
          ],
        ),
      ),
    );
  }
}
