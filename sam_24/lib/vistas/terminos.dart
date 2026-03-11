import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sam_remastered/vistas/registro.dart'; 

class PantallaTerminos extends StatefulWidget {
  // Variable para saber si venimos de Ajustes o de Registro
  final bool soloLectura;
  
  // Por defecto es false (asume que viene de registro)
  const PantallaTerminos({super.key, this.soloLectura = false});

  @override
  State<PantallaTerminos> createState() => _PantallaTerminosState();
}

class _PantallaTerminosState extends State<PantallaTerminos> {
  bool _aceptaTerminos = false;

  @override
  Widget build(BuildContext context) {
    // --- DETECCIÓN DEL MODO OSCURO ---
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          "Términos y Condiciones",
          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 18)
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : const Color(0xFF1A237E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context), 
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.blueAccent.withValues(alpha: 0.1) : const Color(0xFF1A237E).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.description_rounded, size: 50, color: isDark ? Colors.lightBlueAccent : const Color(0xFF1A237E)),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Center(
                    child: Text(
                      "Acuerdo de Usuario de SAM",
                      style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      "Última actualización: Marzo 2026",
                      style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey.shade600, fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 30),

                  _buildSeccionTermino(
                    "1. Naturaleza del Servicio",
                    "SAM Remastered es una herramienta tecnológica de asistencia diseñada para enviar alertas a tus contactos en caso de posibles accidentes de motocicleta. NO es un dispositivo médico, ni sustituye a los servicios de emergencia profesionales (como el 911 o la Cruz Roja).",
                    isDark
                  ),
                  _buildSeccionTermino(
                    "2. Disponibilidad de Red y Batería",
                    "El envío de alertas SMS y coordenadas GPS depende enteramente de la conexión a la nube, cobertura de red móvil, saldo disponible y batería en los dispositivos. SAM no garantiza el envío si el hardware o el teléfono se encuentran sin señal, apagados o destruidos tras el impacto.",
                    isDark
                  ),
                  _buildSeccionTermino(
                    "3. Responsabilidad del Usuario",
                    "El conductor es el único responsable de manejar con precaución, portar el equipo de seguridad adecuado y respetar el reglamento de tránsito. SAM no previene accidentes, únicamente asiste en la notificación de los mismos.",
                    isDark
                  ),
                  _buildSeccionTermino(
                    "4. Tiempos de Respuesta y Falsos Positivos",
                    "El sistema cuenta con dos protocolos de emergencia:\n\n• Alerta Manual: Dispone de una cuenta regresiva de 5 segundos para que el usuario pueda cancelar el envío si fue presionada por error.\n\n• Alerta Automática (Sensor): Al detectar un accidente mediante el sensor externo, la alerta de auxilio se enviará INSTANTÁNEAMENTE para reducir el tiempo de respuesta. Si el conductor se encuentra a salvo o fue un falso positivo, la aplicación habilitará un botón especial durante 10 segundos posteriores para enviar un segundo mensaje aclarando a sus contactos que se encuentra bien.",
                    isDark
                  ),
                  _buildSeccionTermino(
                    "5. Limitación de Responsabilidad",
                    "El equipo desarrollador de SAM queda exento de cualquier responsabilidad legal, penal o civil por daños físicos, materiales, lesiones o fallos en el envío de mensajes de emergencia derivados del uso de la aplicación y su hardware. El usuario utiliza este sistema bajo su propio riesgo.",
                    isDark
                  ),
                  _buildSeccionTermino(
                    "6. Uso y Protección de Datos Personales",
                    "Tus datos médicos, ubicación GPS y contactos de emergencia se almacenan de forma segura y encriptada en nuestros servidores. Esta información será utilizada ÚNICA Y EXCLUSIVAMENTE para brindarte asistencia vital en caso de detectar un accidente. SAM jamás venderá, alquilará ni compartirá tu información personal con terceros para fines comerciales o de lucro.",
                    isDark
                  ),
                  _buildSeccionTermino(
                    "7. Propiedad y Seguridad del Sensor",
                    "La vinculación del dispositivo físico SAM se realiza mediante el escaneo de un código QR único, estableciendo una conexión encriptada con la nube. Al vincular un sensor, el usuario se convierte en el único administrador autorizado del mismo. Para garantizar la seguridad contra robos o manipulaciones, el sistema bloqueará intentos de vinculación de terceros y registrará escaneos no autorizados. Para transferir el hardware a un nuevo propietario, el administrador actual debe desvincular el sensor manualmente desde los ajustes de su cuenta en la aplicación.",
                    isDark
                  ),

                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),

          // LÓGICA CONDICIONAL: Solo mostramos la barra inferior si NO es modo lectura
          if (!widget.soloLectura)
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                boxShadow: [
                  if (!isDark) BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))
                ],
                border: Border(top: BorderSide(color: isDark ? Colors.white10 : Colors.transparent)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: _aceptaTerminos,
                        activeColor: Theme.of(context).colorScheme.primary,
                        onChanged: (bool? valor) {
                          setState(() {
                            _aceptaTerminos = valor ?? false;
                          });
                        },
                      ),
                      Expanded(
                        child: Text(
                          "He leído y acepto los términos y condiciones de uso y privacidad.",
                          style: TextStyle(fontSize: 13, color: isDark ? Colors.grey[300] : Colors.black87),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _aceptaTerminos 
                        ? () {
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const PantallaRegistro()));
                          }
                        : null, 
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        disabledBackgroundColor: isDark ? Colors.grey[800] : Colors.grey.shade300,
                        foregroundColor: Colors.white,
                        disabledForegroundColor: isDark ? Colors.grey[500] : Colors.grey.shade600,
                        elevation: _aceptaTerminos ? 5 : 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text("CONTINUAR AL REGISTRO", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 1)),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSeccionTermino(String titulo, String contenido, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          if (!isDark) BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))
        ],
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : Colors.black87)),
          const SizedBox(height: 10),
          Text(contenido, style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey.shade600, fontSize: 14, height: 1.5)),
        ],
      ),
    );
  }
}