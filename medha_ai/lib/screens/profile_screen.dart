import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.network(
              'https://assets10.lottiefiles.com/packages/lf20_pqpmxbxp.json',
              width: 160,
              repeat: true,
            ),
            const SizedBox(height: 16),
            const Text('⚠️ UNDER DEVELOPMENT ⚠️', style: TextStyle(color: Colors.red, fontSize: 18)),
            const SizedBox(height: 8),
            const Text('Contact: legionkoushik3@gmail.com'),
          ],
        ),
      ),
    );
  }
}
