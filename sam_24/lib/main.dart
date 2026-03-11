import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

// --- NUEVO IMPORT PARA MEMORIA LOCAL ---
import 'package:shared_preferences/shared_preferences.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart'; 

import 'package:sam_remastered/vistas/iniciosesion.dart';
import 'package:sam_remastered/vistas/principal.dart';
import 'package:sam_remastered/vistas/terminos.dart'; 

// ==========================================================
// VARIABLES GLOBALES DE ESTADO (Escuchan en tiempo real)
// ==========================================================
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);
final ValueNotifier<bool> metricNotifier = ValueNotifier(true); // true = Km/h

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // --- LEER PREFERENCIAS GUARDADAS ANTES DE ARRANCAR ---
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isDark = prefs.getBool('isDark') ?? false;
  bool isMetric = prefs.getBool('isMetric') ?? true;
  
  // Asignamos lo que encontramos en memoria
  themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
  metricNotifier.value = isMetric;

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

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
    // ValueListenableBuilder repinta TODA la app cuando themeNotifier cambia
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          title: 'SAM - Seguridad Vial',
          debugShowCheckedModeBanner: false,
          themeMode: currentMode, // AQUÍ SE APLICA EL TEMA EN TIEMPO REAL
          
          // --- TEMA CLARO ---
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1A237E),
              onPrimary: Colors.white,
              secondary: Color(0xFFFF6F00),
              surface: Colors.white,
            ),
            textTheme: GoogleFonts.robotoTextTheme(),
            elevatedButtonTheme: _botonStyle(const Color(0xFF1A237E), Colors.white),
          ),
          
          // --- TEMA OSCURO ---
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF5C6BC0), // Azul más claro para que resalte en negro
              onPrimary: Colors.white,
              secondary: Color(0xFFFF8F00),
              surface: Color(0xFF121212), // Fondo casi negro (estándar de Material Design)
            ),
            textTheme: GoogleFonts.robotoTextTheme(ThemeData.dark().textTheme),
            elevatedButtonTheme: _botonStyle(const Color(0xFF5C6BC0), Colors.white),
          ),

          home: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator(color: Color(0xFF1A237E))),
                );
              }
              if (snapshot.hasData) {
                return const PantallaPrincipal();
              }
              return const OnboardingScreen();
            }
          ),
        );
      },
    );
  }

  // Helper para no repetir código del botón
  ElevatedButtonThemeData _botonStyle(Color bg, Color fg) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: fg,
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        padding: const EdgeInsets.symmetric(vertical: 15),
      ),
    );
  }
}

// ==========================================================
// PANTALLA ONBOARDING (Se mantiene igual a tu código)
// ==========================================================
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _paginaActual = 0;
  Timer? _timer;

  final List<Map<String, String>> _datosOnboarding = const [
    {"imagen": "assets/images/carru10.png", "texto": "Respetá los límites de velocidad, en tu casa te esperan."},
    {"imagen": "assets/images/carru20.png", "texto": "Tu seguridad es nuestra prioridad. SAM te cuida en cada ruta."},
    {"imagen": "assets/images/carru30.png", "texto": "Usa tu casco y equipo de seguridad al salir."},
    {"imagen": "assets/images/carru40.png", "texto": "SAM24. Te cuida las 24 horas del día."},
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
        onPointerDown: (_) => _timer?.cancel(),
        onPointerUp: (_) => _iniciarTimer(),
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: _datosOnboarding.length,
              onPageChanged: (index) => setState(() => _paginaActual = index),
              itemBuilder: (context, index) {
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(_datosOnboarding[index]["imagen"]!, fit: BoxFit.cover, gaplessPlayback: true),
                    Container(color: Colors.black.withValues(alpha: 0.5)),
                  ],
                );
              },
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                child: Column(
                  children: [
                    const Spacer(flex: 1),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 20, spreadRadius: 5)]
                          ),
                          child: Image.asset("assets/images/logo.png", height: alto * 0.15, width: alto * 0.15, fit: BoxFit.contain, gaplessPlayback: true),
                        ),
                        SizedBox(height: alto * 0.02),
                        Text(
                          "SAM24",
                          style: GoogleFonts.montserrat(
                            fontSize: alto * 0.05, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 2.0,
                            shadows: [const Shadow(offset: Offset(0, 2), blurRadius: 4.0, color: Colors.black54)],
                          ),
                        ),
                      ],
                    ),
                    const Spacer(flex: 10),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
                      child: Text(
                        _datosOnboarding[_paginaActual]["texto"]!,
                        key: ValueKey<int>(_paginaActual),
                        style: GoogleFonts.montserrat(fontSize: alto * 0.03, fontWeight: FontWeight.w400, color: Colors.white, height: 1.3),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: alto * 0.05),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_datosOnboarding.length, (index) => _buildPunto(index)),
                    ),
                    SizedBox(height: alto * 0.03),
                    SizedBox(
                      width: double.infinity, height: 55,
                      child: ElevatedButton(
                        onPressed: _irARegistro, 
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A237E), elevation: 5),
                        child: const Text("EMPEZAR", style: TextStyle(color: Colors.white)), 
                      ),
                    ),
                    SizedBox(height: alto * 0.02),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("¿Ya tienes cuenta? ", style: TextStyle(color: Colors.white, fontSize: 16)),
                        GestureDetector(
                          onTap: _irALogin,
                          child: const Text("Iniciar sesión", style: TextStyle(color: Color(0xFFFF6F00), fontWeight: FontWeight.bold, fontSize: 16)),
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
        color: _paginaActual == index ? const Color(0xFFFF6F00) : Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }

  void _irALogin() {
    _timer?.cancel();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const PantallaLogin()));
  }

  void _irARegistro() {
    _timer?.cancel();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const PantallaTerminos()));
  }
}