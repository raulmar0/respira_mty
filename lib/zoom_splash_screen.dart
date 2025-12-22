import 'package:flutter/material.dart';

class ZoomSplashScreen extends StatefulWidget {
  const ZoomSplashScreen({super.key});

  @override
  State<ZoomSplashScreen> createState() => _ZoomSplashScreenState();
}

class _ZoomSplashScreenState extends State<ZoomSplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // 1. Configurar el controlador de tiempo
    // Define cuánto durará la animación (ej. 3 segundos)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // 2. Definir el rango del Zoom
    // begin: 1.0 es el tamaño normal.
    // end: 1.2 significa que crecerá un 20% más de su tamaño original.
    _scaleAnimation = Tween<double>(begin: 1, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut), // Curva suave
    );

    // 3. Iniciar la animación y navegar al terminar
    _controller.forward().whenComplete(() {
      // AQUÍ defines a dónde ir después.
      // Asegúrate de tener esta ruta definida en tu main.dart o usa MaterialPageRoute.
      Navigator.of(context).pushReplacementNamed('/home');
    });
  }

  @override
  void dispose() {
    // Importante limpiar el controlador para liberar memoria
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Color de fondo por si acaso
      body: SizedBox.expand( // Asegura que ocupe toda la pantalla
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            // Aplica la escala actual de la animación al "child"
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            );
          },
          // Definimos la imagen como "child" estático para que Flutter
          // no la reconstruya en cada frame, solo la transforme. Eficiencia.
          child: Image.asset(
            'assets/fondo_splash.png', // <-- CAMBIA ESTO POR LA RUTA DE TU IMAGEN
            fit: BoxFit.cover, // Cubre toda la pantalla sin deformarse
          ),
        ),
      ),
    );
  }
}