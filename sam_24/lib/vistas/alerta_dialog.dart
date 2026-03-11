import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DialogoAlerta extends StatefulWidget {
  const DialogoAlerta({super.key});

  @override
  State<DialogoAlerta> createState() => _DialogoAlertaState();
}

class _DialogoAlertaState extends State<DialogoAlerta> {
  int _segundos = 5;
  Timer? _timer;
  
  // NUEVO: Variable para controlar el estado visual de la ventana
  bool _alertaEnviada = false; 

  @override
  void initState() {
    super.initState();
    _iniciarCuentaRegresiva();
  }

  void _iniciarCuentaRegresiva() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_segundos > 1) {
        setState(() {
          _segundos--;
        });
      } else {
        _timer?.cancel();
        _enviarAlerta();
      }
    });
  }

  void _enviarAlerta() {
    // 1. Transformamos la interfaz al estado de Éxito
    setState(() {
      _alertaEnviada = true; 
    });
    
    // (AQUÍ IRÁ LA LÓGICA DE FIREBASE Y SMS)

    // 2. Esperamos 2.5 segundos para que el usuario lea la confirmación y cerramos
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }

  void _cancelarAlerta() {
    _timer?.cancel(); 
    Navigator.pop(context); 
  }

  @override
  void dispose() {
    _timer?.cancel(); 
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Detectamos si estamos en modo oscuro
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0), 
      child: Dialog(
        backgroundColor: Colors.transparent, 
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                // La sombra del diálogo cambia de rojo a verde cuando se envía
                color: _alertaEnviada 
                    ? Colors.green.withValues(alpha: 0.2) 
                    : Colors.red.withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 5,
              )
            ]
          ),
          // AnimatedSwitcher hace una transición moderna (fade y scale) entre los dos estados
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(scale: animation, child: child),
              );
            },
            // Decide qué pantalla mostrar basándose en la variable _alertaEnviada
            child: _alertaEnviada 
                ? _buildExitoUI(isDark) 
                : _buildCuentaRegresivaUI(isDark),
          ),
        ),
      ),
    );
  }

  // --- INTERFAZ 1: LA CUENTA REGRESIVA ---
  Widget _buildCuentaRegresivaUI(bool isDark) {
    return Column(
      key: const ValueKey(1), // Key necesaria para que Flutter sepa que es un widget distinto
      mainAxisSize: MainAxisSize.min, 
      children: [
        const Icon(Icons.warning_rounded, color: Colors.redAccent, size: 80),
        const SizedBox(height: 15),
        Text(
          "¡EMERGENCIA!",
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.redAccent,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          "Enviando ubicación y alerta de auxilio a tus contactos en:",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: isDark ? Colors.grey[300] : Colors.black87),
        ),
        const SizedBox(height: 15),
        
        Text(
          "$_segundos",
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            fontSize: 65,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        
        const SizedBox(height: 25),
        
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: _cancelarAlerta,
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? Colors.grey[800] : Colors.grey.shade200,
              foregroundColor: isDark ? Colors.white : Colors.black87,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text("CANCELAR", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        )
      ],
    );
  }

  // --- INTERFAZ 2: ÉXITO (MODERNA) ---
  Widget _buildExitoUI(bool isDark) {
    return Column(
      key: const ValueKey(2),
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 70),
        ),
        const SizedBox(height: 20),
        Text(
          "¡Alerta Enviada!",
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          "Tus contactos han recibido tu mensaje SOS junto con tu ubicación GPS exacta.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: isDark ? Colors.grey[300] : Colors.black87, height: 1.5),
        ),
        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              if (mounted) Navigator.pop(context); // Cierre manual por si no quiere esperar
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text("ENTENDIDO", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
          ),
        )
      ],
    );
  }
}