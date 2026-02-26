import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PantallaTerminos extends StatelessWidget {
  const PantallaTerminos({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          "Términos y Condiciones",
          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 18)
        ),
        centerTitle: true,
        backgroundColor: Colors.grey[50],
        foregroundColor: const Color(0xFF1A237E),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- ENCABEZADO ---
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A237E).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.description_rounded, size: 50, color: Color(0xFF1A237E)),
              ),
            ),
            const SizedBox(height: 15),
            Center(
              child: Text(
                "Acuerdo de Usuario de SAM",
                style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                "Última actualización: Febrero 2026",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
            ),
            const SizedBox(height: 30),

            // --- BLOQUES DE TÉRMINOS LEGALES ---
            _buildSeccionTermino(
              "1. Naturaleza del Servicio",
              "SAM Remastered es una herramienta tecnológica de asistencia diseñada para enviar alertas a tus contactos en caso de posibles accidentes de motocicleta. NO es un dispositivo médico, ni sustituye a los servicios de emergencia profesionales (como el 911 o la Cruz Roja)."
            ),
            _buildSeccionTermino(
              "2. Disponibilidad de Red y Batería",
              "El envío de alertas SMS y coordenadas GPS depende enteramente de la cobertura de red móvil, saldo disponible y batería en tu dispositivo. SAM no garantiza el envío si el teléfono se encuentra sin señal, apagado o destruido tras el impacto."
            ),
            _buildSeccionTermino(
              "3. Responsabilidad del Usuario",
              "El conductor es el único responsable de manejar con precaución, portar el equipo de seguridad adecuado y respetar el reglamento de tránsito. SAM no previene accidentes, únicamente asiste en la notificación de los mismos."
            ),
            // --- SECCIÓN 4 MODIFICADA CON TU LÓGICA DE ALERTA ---
            _buildSeccionTermino(
              "4. Tiempos de Respuesta y Falsos Positivos",
              "El sistema cuenta con dos protocolos de emergencia:\n\n"
              "• Alerta Manual: Dispone de una cuenta regresiva de 5 segundos para que el usuario pueda cancelar el envío si fue presionada por error.\n\n"
              "• Alerta Automática (Sensor): Al detectar un accidente mediante el sensor externo, la alerta de auxilio se enviará INSTANTÁNEAMENTE para reducir el tiempo de respuesta. Si el conductor se encuentra a salvo o fue un falso positivo, la aplicación habilitará un botón especial durante 10 segundos posteriores para enviar un segundo mensaje aclarando a sus contactos que se encuentra bien."
            ),
            _buildSeccionTermino(
              "5. Limitación de Responsabilidad",
              "El equipo desarrollador de SAM queda exento de cualquier responsabilidad legal, penal o civil por daños físicos, materiales, lesiones o fallos en el envío de mensajes de emergencia derivados del uso de la aplicación y su hardware. El usuario utiliza este sistema bajo su propio riesgo."
            ),

            const SizedBox(height: 30),

            // --- BOTÓN DE ACEPTAR / REGRESAR ---
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A237E),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text("HE LEÍDO Y ENTIENDO", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 1)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- WIDGET AUXILIAR PARA LAS TARJETAS ---
  Widget _buildSeccionTermino(String titulo, String contenido) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
          ),
          const SizedBox(height: 10),
          Text(
            contenido,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }
}