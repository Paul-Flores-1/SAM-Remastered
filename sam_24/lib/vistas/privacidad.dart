import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PantallaPrivacidad extends StatefulWidget {
  const PantallaPrivacidad({super.key});

  @override
  State<PantallaPrivacidad> createState() => _PantallaPrivacidadState();
}

class _PantallaPrivacidadState extends State<PantallaPrivacidad> {
  // Opciones de privacidad configurables por el usuario
  bool _telemetriaAnonima = true;
  bool _ubicacionSegundoPlano = true;

  @override
  Widget build(BuildContext context) {
    // --- DETECCIÓN DEL MODO OSCURO ---
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          "Privacidad y Datos", 
          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 18)
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : const Color(0xFF1A237E),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icono y encabezado
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.blueAccent.withValues(alpha: 0.1) : const Color(0xFF1A237E).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.security_rounded, size: 50, color: isDark ? Colors.lightBlueAccent : const Color(0xFF1A237E)),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    "Tu seguridad es privada",
                    style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "En SAM protegemos tu información médica y de ubicación. Solo se comparte cuando tu vida corre peligro.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey.shade600, fontSize: 14),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 35),

            // --- SECCIÓN: CÓMO USAMOS TUS DATOS ---
            _buildTituloSeccion("CÓMO USAMOS TUS DATOS", isDark),
            _buildInfoCard(
              icono: Icons.medical_information_rounded,
              colorIcono: Colors.redAccent,
              titulo: "Perfil Médico",
              descripcion: "Tus alergias y tipo de sangre están encriptados. Solo se acceden mediante tu código QR o al enviar una alerta SMS.",
              isDark: isDark
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              icono: Icons.location_on_rounded,
              colorIcono: Colors.greenAccent,
              titulo: "Ubicación y GPS",
              descripcion: "No rastreamos tus viajes. El GPS solo se activa temporalmente para enviar las coordenadas a tus contactos si detectamos un accidente.",
              isDark: isDark
            ),

            const SizedBox(height: 35),

            // --- SECCIÓN: PERMISOS ---
            _buildTituloSeccion("CONTROL DE PERMISOS", isDark),
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDark ? Colors.white10 : Colors.transparent),
                boxShadow: [
                  if (!isDark) BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))
                ]
              ),
              child: Column(
                children: [
                  _buildSwitchRow(
                    titulo: "Telemetría Anónima",
                    subtitulo: "Ayúdanos a mejorar SAM compartiendo datos de inclinación de la moto de forma anónima.",
                    valor: _telemetriaAnonima,
                    isDark: isDark,
                    onChanged: (val) => setState(() => _telemetriaAnonima = val),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 60),
                    child: Divider(height: 1, color: isDark ? Colors.white10 : Colors.grey.shade100),
                  ),
                  _buildSwitchRow(
                    titulo: "Ubicación en 2do Plano",
                    subtitulo: "Permite que SAM detecte accidentes incluso si la pantalla de tu celular está apagada.",
                    valor: _ubicacionSegundoPlano,
                    isDark: isDark,
                    onChanged: (val) => setState(() => _ubicacionSegundoPlano = val),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // --- ZONA DE PELIGRO ---
            _buildTituloSeccion("ZONA DE PELIGRO", isDark),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDark ? Colors.redAccent.withValues(alpha: 0.3) : Colors.red.shade100),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    _mostrarDialogoEliminar(context, isDark);
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: isDark ? Colors.red.withValues(alpha: 0.2) : Colors.red.shade50, shape: BoxShape.circle),
                          child: Icon(Icons.delete_forever_rounded, color: isDark ? Colors.redAccent : Colors.red),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Eliminar mi cuenta y datos", style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.redAccent : Colors.red, fontSize: 16)),
                              const SizedBox(height: 4),
                              Text("Esta acción borrará todo permanentemente.", style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey, fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS AUXILIARES ---

  Widget _buildTituloSeccion(String titulo, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, bottom: 15),
      child: Text(
        titulo,
        style: GoogleFonts.montserrat(
          fontWeight: FontWeight.bold,
          fontSize: 13,
          color: isDark ? Colors.grey[400] : Colors.grey.shade500,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildInfoCard({required IconData icono, required Color colorIcono, required String titulo, required String descripcion, required bool isDark}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          if(!isDark) BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))
        ],
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: colorIcono.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
            child: Icon(icono, color: colorIcono, size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : Colors.black87)),
                const SizedBox(height: 6),
                Text(descripcion, style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey.shade600, fontSize: 13, height: 1.4)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSwitchRow({required String titulo, required String subtitulo, required bool valor, required bool isDark, required Function(bool) onChanged}) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: isDark ? Colors.white : Colors.black87)),
                const SizedBox(height: 4),
                Text(subtitulo, style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey.shade500, fontSize: 12, height: 1.3)),
              ],
            ),
          ),
          const SizedBox(width: 15),
          Switch.adaptive(
            value: valor,
            onChanged: onChanged,
            activeTrackColor: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoEliminar(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
            const SizedBox(width: 10),
            Text("¿Eliminar cuenta?", style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 18)),
          ],
        ),
        content: Text(
          "Si eliminas tu cuenta, perderás todo tu perfil médico, contactos de emergencia y telemetría de la moto. Esta acción no se puede deshacer.",
          style: TextStyle(fontSize: 14, color: isDark ? Colors.grey[300] : Colors.black87, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("CANCELAR", style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Aquí irá la lógica de Firebase: user.delete() y borrar su documento
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Función en desarrollo..."), backgroundColor: Colors.red));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: const Text("ELIMINAR", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}