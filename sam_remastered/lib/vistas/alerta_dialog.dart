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

  @override
  void initState() {
    super.initState();
    _iniciarCuentaRegresiva();
  }

  void _iniciarCuentaRegresiva() {
    // Un timer que se ejecuta cada 1 segundo
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_segundos > 1) {
        setState(() {
          _segundos--;
        });
      } else {
        // Cuando llega a 0
        _timer?.cancel();
        _enviarAlerta();
      }
    });
  }

  void _enviarAlerta() {
    Navigator.pop(context); // Cierra la ventana
    
    // Mostramos un mensaje verde de éxito (AQUÍ IRA LA LÓGICA DEL SMS DESPUÉS)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 10),
            Text("¡Alerta enviada a tus contactos!", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _cancelarAlerta() {
    _timer?.cancel(); // Detenemos el reloj
    Navigator.pop(context); // Cerramos la ventana
  }

  @override
  void dispose() {
    _timer?.cancel(); // Buena práctica para evitar fugas de memoria
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // BackdropFilter es el que hace la magia del desenfoque
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0), // Intensidad del blur
      child: Dialog(
        backgroundColor: Colors.transparent, // Transparente para que se vea el blur
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 5,
              )
            ]
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Para que la caja se ajuste al contenido
            children: [
              // Ícono que palpita o simplemente estático
              const Icon(Icons.warning_rounded, color: Colors.red, size: 80),
              const SizedBox(height: 15),
              Text(
                "¡EMERGENCIA!",
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Colors.red.shade700,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Enviando ubicación y alerta de auxilio a tus contactos en:",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 15),
              
              // El número gigante que cambia
              Text(
                "$_segundos",
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  fontSize: 65,
                  color: Colors.black87,
                ),
              ),
              
              const SizedBox(height: 25),
              
              // Botón de Cancelar
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _cancelarAlerta,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade200,
                    foregroundColor: Colors.black87,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text("CANCELAR", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}