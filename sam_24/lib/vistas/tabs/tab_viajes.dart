import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TabViajes extends StatelessWidget {
  const TabViajes({super.key});

  // --- PALETA DE COLORES OFICIALES ---
  final Color azulApp = const Color(0xFF1A237E);   // Azul Oficial SAM24
  final Color ambarApp = const Color(0xFFFF6F00);  // Ámbar Oficial SAM24

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Planificador SAM", 
          style: GoogleFonts.montserrat(
            fontSize: 20, 
            fontWeight: FontWeight.bold, 
            // Usa el azul oficial en modo claro, y blanco en oscuro
            color: isDark ? Colors.white : azulApp 
          )
        ),
        const SizedBox(height: 15),
        
        _buildBotonElegante(
          context: context,
          titulo: "Iniciar Nuevo Viaje",
          subtitulo: "Establece tu destino y monitorea la ruta",
          icon: Icons.add_location_alt_rounded,
          colorIcono: ambarApp, // <-- Ámbar para llamar a la acción
          isDark: isDark,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                  "Configurando enlace con el mapa...", 
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)
                ),
                backgroundColor: azulApp, // <-- Notificación en azul oficial
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              )
            );
            // Navegación a la pantalla de viaje:
            // Navigator.push(context, MaterialPageRoute(builder: (context) => const PantallaViaje()));
          },
        ),
        
        const SizedBox(height: 30),
        
        Text(
          "Historial de Rutas", 
          style: GoogleFonts.montserrat(
            fontSize: 18, 
            fontWeight: FontWeight.bold, 
            color: isDark ? Colors.white : azulApp // <-- Azul oficial
          )
        ),
        const SizedBox(height: 15),
        
        _buildArticuloCard(
          "Costera Miguel Alemán", 
          "12.5 km - 25 min", 
          Icons.history_rounded, 
          azulApp, // <-- Pasamos el azul a los iconos
          isDark
        ),
        _buildArticuloCard(
          "Av. Cuauhtémoc", 
          "5.2 km - 10 min", 
          Icons.history_rounded, 
          azulApp, // <-- Pasamos el azul a los iconos
          isDark
        ),
      ],
    );
  }

  // --- WIDGETS REUTILIZABLES INTERNOS ---

  Widget _buildBotonElegante({
    required BuildContext context,
    required String titulo, 
    required String subtitulo, 
    required IconData icon, 
    required Color colorIcono, 
    required bool isDark, 
    required VoidCallback onTap
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white10 : Colors.transparent),
        boxShadow: [
          if (!isDark) BoxShadow(
            color: colorIcono.withValues(alpha: 0.1), // Sombra con un toque del color principal
            blurRadius: 10, 
            offset: const Offset(0, 4)
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10), 
                  decoration: BoxDecoration(
                    color: colorIcono.withValues(alpha: 0.1), 
                    shape: BoxShape.circle
                  ), 
                  child: Icon(icon, color: colorIcono, size: 24)
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titulo, 
                        style: TextStyle(
                          fontWeight: FontWeight.bold, 
                          fontSize: 15, 
                          color: isDark ? Colors.white : Colors.black87
                        )
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitulo, 
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[500], 
                          fontSize: 12
                        )
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios, 
                  size: 14, 
                  color: isDark ? Colors.grey[700] : Colors.grey[300]
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildArticuloCard(String titulo, String resumen, IconData icono, Color colorIcono, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorIcono.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            // Icono en azul o un tono adaptado al modo oscuro
            child: Icon(icono, size: 24, color: isDark ? const Color(0xFF9FA8DA) : colorIcono),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo, 
                  style: TextStyle(
                    fontWeight: FontWeight.bold, 
                    fontSize: 14, 
                    color: isDark ? Colors.white : Colors.black87
                  )
                ),
                const SizedBox(height: 4),
                Text(
                  resumen, 
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[600], 
                    fontSize: 12
                  )
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}