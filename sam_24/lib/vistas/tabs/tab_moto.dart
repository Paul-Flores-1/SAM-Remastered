import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sam_remastered/vistas/escaner_qr.dart';

class TabMoto extends StatefulWidget {
  const TabMoto({super.key});

  @override
  State<TabMoto> createState() => _TabMotoState();
}

class _TabMotoState extends State<TabMoto> {
  // Variable para controlar si mostramos la explicación o las estadísticas
  bool _viajeActivo = false;

  // --- PALETA DE COLORES OFICIALES ---
  final Color azulApp = const Color(0xFF1A237E);   // TU COLOR AZUL OFICIAL
  final Color ambarApp = const Color(0xFFFF6F00);  // TU COLOR ÁMBAR OFICIAL
  final Color negroFondo = const Color(0xFF121212);

  // Variables de telemetría locales (placeholders)
  String maxSpeed = "0 km/h";
  String minSpeed = "0 km/h";
  String avgSpeed = "0 km/h";
  String maxTilt = "0°";
  String emergencyBrakes = "0";

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        const SizedBox(height: 10),
        
        // Icono y título de la vista de viaje
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: azulApp.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.route_rounded, size: 50, color: azulApp),
        ),
        const SizedBox(height: 15),
        Text(
          "Viaje Protegido",
          style: GoogleFonts.montserrat(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : azulApp),
        ),
        const SizedBox(height: 15),

        // --- TARJETA DE VINCULACIÓN DEL SENSOR (ÁMBAR OFICIAL #FF6F00) ---
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: ambarApp.withValues(alpha: isDark ? 0.3 : 0.5)),
            boxShadow: [
              if (!isDark) BoxShadow(color: ambarApp.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: ambarApp.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.qr_code_scanner_rounded, color: ambarApp, size: 24),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Sensor Físico SAM", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: isDark ? Colors.white : Colors.black87)),
                    const SizedBox(height: 2),
                    Text("Estado: Sin vincular", style: TextStyle(color: ambarApp, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  // Lógica para abrir tu escáner QR
                  final resultado = await Navigator.push(context, MaterialPageRoute(builder: (context) => const PantallaEscanerQR()));
                  if (resultado != null && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("ID escaneado: $resultado", style: const TextStyle(fontWeight: FontWeight.bold)), 
                        backgroundColor: Colors.green.shade600, 
                        behavior: SnackBarBehavior.floating
                      )
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ambarApp,
                  foregroundColor: Colors.white, 
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 0,
                ),
                child: const Text("VINCULAR", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 0.5)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // --- TARJETA DE MONITOREO CONTINUO (AZUL OFICIAL #1A237E) ---
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade100),
            boxShadow: [
              if (!isDark) BoxShadow(color: Colors.grey.withValues(alpha: 0.08), blurRadius: 10, offset: const Offset(0, 4))
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: azulApp.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.security_rounded, color: azulApp, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Monitoreo Continuo", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : Colors.black87)),
                    const SizedBox(height: 8),
                    Text(
                      "SAM24 protege tu camino automáticamente.\n\nUtiliza el botón inferior únicamente si deseas visualizar en tiempo real tu telemetría de viaje (velocidad, inclinación y frenados).",
                      style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 13, height: 1.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),

        // LÓGICA DINÁMICA
        if (!_viajeActivo) ...[
          
          // ESTADO 1: VIAJE NO INICIADO (Botón Azul Oficial)
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _viajeActivo = true;
                });
              },
              icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
              label: const Text("INICIAR VIAJE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                  backgroundColor: azulApp,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0),
            ),
          ),
          
        ] else ...[
          
          // ESTADO 2: VIAJE INICIADO (Mostrar Estadísticas)
          Column(
            children: [
              _buildPasoInstruccion(Icons.speed_rounded, "Velocidad Máxima", maxSpeed, isDark),
              const SizedBox(height: 15),
              _buildPasoInstruccion(Icons.moving_rounded, "Velocidad Mínima", minSpeed, isDark),
              const SizedBox(height: 15),
              _buildPasoInstruccion(Icons.access_time_filled_rounded, "Velocidad Media", avgSpeed, isDark), 
              const SizedBox(height: 15),
              _buildPasoInstruccion(Icons.screen_rotation_alt_rounded, "Ángulo Máx Inclinación", maxTilt, isDark),
              const SizedBox(height: 15),
              _buildPasoInstruccion(Icons.warning_amber_rounded, "Frenados Emergencia", emergencyBrakes, isDark),
            ],
          ),
          const SizedBox(height: 30),

          // Botón para Detener el Viaje Visual
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _viajeActivo = false;
                });
              },
              icon: const Icon(Icons.stop_rounded, color: Colors.white),
              label: const Text("FINALIZAR VIAJE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0),
            ),
          ),
        ],
        
        const SizedBox(height: 20),
      ],
    );
  }

  // --- WIDGET REUTILIZABLE (USANDO EL AZUL OFICIAL #1A237E) ---
  Widget _buildPasoInstruccion(IconData icono, String titulo, String descripcion, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: azulApp.withValues(alpha: 0.1), 
            borderRadius: BorderRadius.circular(10)
          ),
          child: Icon(icono, color: isDark ? const Color(0xFF9FA8DA) : azulApp, size: 22),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titulo, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: isDark ? Colors.white : Colors.black87)),
              const SizedBox(height: 4),
              Text(descripcion, style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 13, height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }
}