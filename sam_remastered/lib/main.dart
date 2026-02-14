import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sam_remastered/vistas/iniciosesion.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(); 
  runApp(const SamApp());
}

class SamApp extends StatelessWidget {
  const SamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SAM - Seguridad Vial',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: Color(0xFF1A237E),
          onPrimary: Colors.white,
          secondary: Color(0xFFFF6F00),
          onSecondary: Colors.black,
          surface: Colors.white,
          onSurface: Colors.black,
          error: Color(0xFFB00020),
          onError: Colors.white,
        ),
        textTheme: GoogleFonts.robotoTextTheme(),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1A237E),
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
      home: const OnboardingScreen(),
    );
  }
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _paginaActual = 0;
  Timer? _timer;

  // Usamos 'const' donde sea posible para optimizar memoria
  final List<Map<String, String>> _datosOnboarding = const [
    {
      "imagen": "assets/images/carru1.jpg",
      "texto": "Respetá los límites de velocidad, en tu casa te esperan."
    },
    {
      "imagen": "assets/images/carru2.jpg",
      "texto": "Tu seguridad es nuestra prioridad. SAM te cuida en cada ruta."
    },
    {
      "imagen": "assets/images/carru3.jpg",
      "texto": "Usa tu casco y equipo de seguridad al salir."
    },
  ];

  @override
  void initState() {
    super.initState();
    _iniciarTimer();
  }

  // OPTIMIZACIÓN 1: Precargar imágenes en memoria para evitar tirones
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    for (var dato in _datosOnboarding) {
      precacheImage(AssetImage(dato["imagen"]!), context);
    }
  }

  // OPTIMIZACIÓN 2: Lógica centralizada del Timer
  void _iniciarTimer() {
    _timer?.cancel(); // Cancelamos cualquier timer previo para evitar conflictos
    _timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      if (_paginaActual < _datosOnboarding.length - 1) {
        _paginaActual++;
      } else {
        _paginaActual = 0;
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _paginaActual,
          // OPTIMIZACIÓN 3: Curva más suave y natural
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic, 
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double alto = size.height;

    return Scaffold(
      // Listener para detectar si el usuario toca la pantalla
      body: Listener(
        onPointerDown: (_) {
          // Si el usuario toca, paramos el timer para no pelear con él
          _timer?.cancel();
        },
        onPointerUp: (_) {
          // Cuando suelta, reiniciamos el timer
          _iniciarTimer();
        },
        child: Stack(
          children: [
            // 1. CAPA DE FONDO
            PageView.builder(
              controller: _pageController,
              itemCount: _datosOnboarding.length,
              onPageChanged: (index) {
                setState(() {
                  _paginaActual = index;
                });
              },
              itemBuilder: (context, index) {
                return Image.asset(
                  _datosOnboarding[index]["imagen"]!,
                  fit: BoxFit.cover,
                  // GaplessPlayback evita parpadeos blancos al cambiar rápido
                  gaplessPlayback: true, 
                  color: Colors.black.withValues(alpha: 0.5),
                  colorBlendMode: BlendMode.darken,
                );
              },
            ),

            // 2. CAPA DE CONTENIDO
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                child: Column(
                  children: [

                    const Spacer(flex: 1),

                    // --- LOGO Y MARCA ---
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 20,
                                spreadRadius: 5,
                              )
                            ]
                          ),
                          child: Image.asset(
                            "assets/images/logo samR.png",
                            height: alto * 0.15, 
                            width: alto * 0.15,
                            fit: BoxFit.contain,
                            // GaplessPlayback también aquí por si acaso
                            gaplessPlayback: true,
                          ),
                        ),
                        SizedBox(height: alto * 0.02),
                        Text(
                          "SAM24",
                          style: GoogleFonts.montserrat(
                            fontSize: alto * 0.05,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 2.0,
                            shadows: [
                               const Shadow(
                                offset: Offset(0, 2),
                                blurRadius: 4.0,
                                color: Colors.black54,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const Spacer(flex: 10),

                    // TEXTO DEL CARRUSEL (Con animación suave)
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                      child: Text(
                        _datosOnboarding[_paginaActual]["texto"]!,
                        key: ValueKey<int>(_paginaActual),
                        style: GoogleFonts.montserrat(
                          fontSize: alto * 0.03,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                          height: 1.3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    SizedBox(height: alto * 0.05),

                    // INDICADORES
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _datosOnboarding.length,
                        (index) => _buildPunto(index),
                      ),
                    ),

                    SizedBox(height: alto * 0.03),

                    // BOTÓN PRINCIPAL
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () {
                          // Reiniciamos el timer al interactuar
                          _iniciarTimer(); 
                          if (_paginaActual == _datosOnboarding.length - 1) {
                            _irALogin();
                          } else {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 600),
                              curve: Curves.easeInOutCubic,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          elevation: 5,
                        ),
                        child: Text(
                          _paginaActual == _datosOnboarding.length - 1 
                              ? "EMPEZAR" 
                              : "SIGUIENTE",
                        ),
                      ),
                    ),

                    SizedBox(height: alto * 0.02),

                    // ENLACE A LOGIN
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "¿Ya tienes cuenta? ",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        GestureDetector(
                          onTap: _irALogin,
                          child: Text(
                            "Iniciar sesión",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPunto(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300), // Suavizado
      curve: Curves.easeOut, // Curva suave
      margin: const EdgeInsets.symmetric(horizontal: 5),
      height: 10,
      width: _paginaActual == index ? 25 : 10,
      decoration: BoxDecoration(
        color: _paginaActual == index 
            ? Theme.of(context).colorScheme.secondary 
            : Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }

  void _irALogin() {
    _timer?.cancel();
    Navigator.pushReplacement(
      context, 
      MaterialPageRoute(builder: (context) => const PantallaLogin()),
    );
  }
}