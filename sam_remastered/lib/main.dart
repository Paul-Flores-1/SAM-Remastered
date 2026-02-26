import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

// --- IMPORTS DE FIREBASE Y TUS VISTAS ---
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart'; 

import 'package:sam_remastered/vistas/iniciosesion.dart';
import 'package:sam_remastered/vistas/registro.dart';
import 'package:sam_remastered/vistas/principal.dart'; // Importante para que el StreamBuilder te lleve al mapa

void main() async {
  // Asegura que los widgets estén listos antes de arrancar los paquetes nativos
  WidgetsFlutterBinding.ensureInitialized();

  // --- INICIALIZAR FIREBASE ---
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Bloquea la rotacion de pantalla :3
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Optimización de mapas para Android
  final GoogleMapsFlutterPlatform mapsImplementation = GoogleMapsFlutterPlatform.instance;
  if (mapsImplementation is GoogleMapsFlutterAndroid) {
    mapsImplementation.useAndroidViewSurface = true;
  }

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
      // --- LÓGICA DE INICIO DE SESIÓN AUTOMÁTICO ---
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // 1. Mientras revisa si hay alguien guardado en memoria
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              backgroundColor: Colors.white,
              body: Center(child: CircularProgressIndicator(color: Color(0xFF1A237E))),
            );
          }
          
          // 2. Si encontró una sesión activa, nos vamos directo al Mapa
          if (snapshot.hasData) {
            return const PantallaPrincipal();
          }
          
          // 3. Si no hay sesión, mostramos las motitos (Onboarding)
          return const OnboardingScreen();
        }
      ),
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

  // Lista con 4 imágenes
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
    {
      "imagen": "assets/images/carru4.jpg",
      "texto": "SAM24. Te cuida las 24 horas del día."
    },
  ];

  @override
  void initState() {
    super.initState();
    _iniciarTimer();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    for (var dato in _datosOnboarding) {
      precacheImage(AssetImage(dato["imagen"]!), context);
    }
  }

  void _iniciarTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      if (_paginaActual < _datosOnboarding.length - 1) {
        _paginaActual++;
      } else {
        _paginaActual = 0;
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _paginaActual,
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
      body: Listener(
        onPointerDown: (_) {
          _timer?.cancel();
        },
        onPointerUp: (_) {
          _iniciarTimer();
        },
        child: Stack(
          children: [
            // CAPA DE FONDO
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
                  gaplessPlayback: true, 
                  color: Colors.black.withValues(alpha: 0.5),
                  colorBlendMode: BlendMode.darken,
                );
              },
            ),

            // CAPA DE CONTENIDO
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
                            "assets/images/logo.png", 
                            height: alto * 0.15, 
                            width: alto * 0.15,
                            fit: BoxFit.contain,
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

                    // TEXTO DEL CARRUSEL
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
                        onPressed: _irARegistro, 
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          elevation: 5,
                        ),
                        child: const Text("EMPEZAR"), 
                      ),
                    ),

                    SizedBox(height: alto * 0.02),

                    //ENLACE A LOGIN
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
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
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

  // Navegación al Login (Botón de texto abajo)
  void _irALogin() {
    _timer?.cancel();
    Navigator.pushReplacement(
      context, 
      MaterialPageRoute(builder: (context) => const PantallaLogin()),
    );
  }

  // Navegación al Registro (Botón Grande "Empezar")
  void _irARegistro() {
    _timer?.cancel();
    Navigator.pushReplacement(
      context, 
      MaterialPageRoute(builder: (context) => const PantallaRegistro()),
    );
  }
}