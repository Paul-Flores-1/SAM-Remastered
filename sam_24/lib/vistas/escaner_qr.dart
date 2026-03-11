import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:google_fonts/google_fonts.dart';

class PantallaEscanerQR extends StatefulWidget {
  const PantallaEscanerQR({super.key});

  @override
  State<PantallaEscanerQR> createState() => _PantallaEscanerQRState();
}

class _PantallaEscanerQRState extends State<PantallaEscanerQR> {
  // Candado de seguridad: evita que lea el mismo QR 100 veces por segundo
  bool _escaneado = false; 

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text("Vincular Sensor", style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : const Color(0xFF1A237E),
        elevation: 0,
      ),
      body: Stack(
        children: [
          // 1. EL LECTOR DE CÁMARA
          MobileScanner(
            onDetect: (capture) {
              if (!_escaneado) {
                final List<Barcode> barcodes = capture.barcodes;
                for (final barcode in barcodes) {
                  if (barcode.rawValue != null) {
                    setState(() => _escaneado = true); // Cerramos el candado
                    final String codigoLeido = barcode.rawValue!;
                    
                    // Regresamos a la pantalla principal enviando el código
                    Navigator.pop(context, codigoLeido);
                    break;
                  }
                }
              }
            },
          ),
          
          // 2. MARCO GUÍA VISUAL
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.redAccent, width: 4),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          
          // 3. TEXTO DE INSTRUCCIÓN
          Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "Apunta al código QR de tu dispositivo SAM",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}