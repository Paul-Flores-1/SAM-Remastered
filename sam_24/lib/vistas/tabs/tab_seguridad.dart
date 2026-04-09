import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Firebase
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Importamos la nueva pantalla que vamos a crear
import 'package:sam_remastered/vistas/incidentes.dart';

class TabSeguridad extends StatelessWidget {
  const TabSeguridad({super.key});

  // --- PALETA DE COLORES OFICIALES ---
  final Color azulApp = const Color(0xFF1A237E);
  final Color ambarApp = const Color(0xFFFF6F00);

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Center(
        child: Text(
          "No hay sesión iniciada", 
          style: TextStyle(color: isDark ? Colors.white : Colors.black)
        )
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('usuarios').doc(user.uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: azulApp));
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Center(
            child: Text(
              "No hay datos de telemetría disponibles", 
              style: TextStyle(color: isDark ? Colors.white : Colors.black)
            )
          );
        }

        var datos = snapshot.data!.data() as Map<String, dynamic>;
        var telemetria = datos['telemetria'] as Map<String, dynamic>?;

        int puntuacion = telemetria?['puntuacion'] ?? 0;
        String scoreTexto = puntuacion > 0 ? puntuacion.toString() : "--";
        String velMax = telemetria?['velocidadMax']?.toString() ?? "--";
        String incMax = telemetria?['inclinacionMax']?.toString() ?? "--";
        String incTotales = telemetria?['incidentesTotales']?.toString() ?? "--";
        String velMin = telemetria?['velocidadMin']?.toString() ?? "--";
        
        List<dynamic> historial = telemetria?['historial'] ?? [];

        Color colorPuntuacion = Colors.greenAccent;
        String textoPuntuacion = "Conductor Excelente";
        
        if (puntuacion > 0 && puntuacion < 80) {
          colorPuntuacion = Colors.redAccent;
          textoPuntuacion = "Precaución Sugerida";
        } else if (puntuacion >= 80 && puntuacion < 90) {
          colorPuntuacion = ambarApp; // Usamos tu ámbar para precaución
          textoPuntuacion = "Conductor Bueno";
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Text(
              "¿Qué tan bien conduces?", 
              style: GoogleFonts.montserrat(
                fontSize: 18, 
                fontWeight: FontWeight.bold, 
                color: isDark ? Colors.white : Colors.black87
              )
            ),
            const SizedBox(height: 15),
            
            // TARJETA DE PUNTUACIÓN DE SEGURIDAD
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [azulApp, const Color(0xFF3949AB)], 
                  begin: Alignment.topLeft, 
                  end: Alignment.bottomRight
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: azulApp.withValues(alpha: 0.3), 
                    blurRadius: 10, 
                    offset: const Offset(0, 5)
                  )
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Puntuación de Seguridad", 
                        style: TextStyle(color: Colors.white70, fontSize: 12)
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "$scoreTexto / 100", 
                        style: const TextStyle(
                          color: Colors.white, 
                          fontSize: 32, 
                          fontWeight: FontWeight.bold
                        )
                      ),
                      const SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: colorPuntuacion.withValues(alpha: 0.2), 
                          borderRadius: BorderRadius.circular(10)
                        ),
                        child: Text(
                          textoPuntuacion, 
                          style: TextStyle(
                            color: colorPuntuacion, 
                            fontWeight: FontWeight.bold, 
                            fontSize: 12
                          )
                        ),
                      ),
                    ],
                  ),
                  const Icon(Icons.shield_rounded, color: Colors.white, size: 60),
                ],
              ),
            ),
            
            const SizedBox(height: 25),
            
            // ESTADÍSTICAS RÁPIDAS
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    "Velocidad Máx", velMax, "km/h", 
                    Icons.speed_rounded, ambarApp, isDark
                  )
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildStatCard(
                    "Inclinación Máx", incMax, "grados", 
                    Icons.screen_rotation_alt_rounded, azulApp, isDark
                  )
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    "Incidentes", incTotales, "totales", 
                    Icons.warning_amber_rounded, Colors.red, isDark
                  )
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildStatCard(
                    "Vel. Mínima", velMin, "km/h", 
                    Icons.moving_rounded, Colors.teal, isDark
                  )
                ),
              ],
            ),
            
            const SizedBox(height: 30),
            
            // SECCIÓN DE HISTORIAL MODIFICADA (AHORA ES UN BOTÓN)
            Text(
              "Historial de Incidentes", 
              style: GoogleFonts.montserrat(
                fontSize: 18, 
                fontWeight: FontWeight.bold, 
                color: isDark ? Colors.white : Colors.black87
              )
            ),
            const SizedBox(height: 15),
            
            _buildBotonElegante(
              context: context,
              titulo: "Ver Registro Completo",
              subtitulo: "${historial.length} eventos detectados por SAM",
              icon: Icons.history_rounded,
              colorIcono: ambarApp,
              isDark: isDark,
              onTap: () {
                Navigator.push(
                  context, 
                  MaterialPageRoute(
                    builder: (context) => PantallaHistorialIncidentes(historial: historial)
                  )
                );
              }
            ),
            
            const SizedBox(height: 30),
          ],
        );
      }
    );
  }

  // --- WIDGETS REUTILIZABLES INTERNOS ---

  Widget _buildStatCard(String titulo, String valor, String unidad, IconData icono, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
        boxShadow: [
          if (!isDark) BoxShadow(
            color: Colors.black.withValues(alpha: 0.03), 
            blurRadius: 10, 
            offset: const Offset(0, 4)
          )
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, color: color, size: 24),
          const SizedBox(height: 10),
          Text(
            titulo, 
            style: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[600], 
              fontSize: 12, 
              fontWeight: FontWeight.bold
            )
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                valor, 
                style: TextStyle(
                  fontWeight: FontWeight.bold, 
                  fontSize: 24, 
                  color: isDark ? Colors.white : Colors.black87
                )
              ),
              const SizedBox(width: 4),
              Text(
                unidad, 
                style: TextStyle(
                  color: isDark ? Colors.grey[500] : Colors.grey[500], 
                  fontSize: 12
                )
              ),
            ],
          )
        ],
      ),
    );
  }

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
            color: colorIcono.withValues(alpha: 0.1), 
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
}