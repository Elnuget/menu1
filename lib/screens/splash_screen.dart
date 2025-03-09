import 'package:flutter/material.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    
    // Configurar animación
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    
    _controller.forward();
    _navigateToHome();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue[800]!,
              Colors.blue[400]!,
            ],
          ),
        ),
        child: Center(
          child: ScaleTransition(
            scale: _animation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.restaurant,
                  size: 120,
                  color: Colors.white,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Mi Restaurante',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Bienvenidos',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.fastfood, color: Colors.white, size: 28),
                    SizedBox(width: 16),
                    Icon(Icons.local_bar, color: Colors.white, size: 28),
                    SizedBox(width: 16),
                    Icon(Icons.local_dining, color: Colors.white, size: 28),
                    SizedBox(width: 16),
                    Icon(Icons.cake, color: Colors.white, size: 28),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
