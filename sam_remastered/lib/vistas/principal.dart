import 'dart:async'; 
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; 
import 'package:sam_remastered/vistas/perfil.dart';
import 'package:sam_remastered/vistas/ajustes.dart';


class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  int _tabSeleccionada = 0;
  final Completer<GoogleMapController> _controller = Completer();
  
  static const CameraPosition _posicionInicial = CameraPosition(
    target: LatLng(16.8531, -99.8237), 
    zoom: 14.0,
  );

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            height: size.height,
            width: double.infinity,
            child: GoogleMap(
              mapType: MapType.normal, 
              initialCameraPosition: _posicionInicial,
              trafficEnabled: false,      
              buildingsEnabled: false,    
              indoorViewEnabled: false,   
              mapToolbarEnabled: false,   
              liteModeEnabled: false,
              zoomControlsEnabled: false, 
              myLocationButtonEnabled: false, 
              compassEnabled: false,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  
                  // Botón del Engrane (Arriba a la izquierda)
                  _botonCircular(Icons.settings, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PantallaAjustes()),
                    );
                  }),
                  
                  // Indicador negro "Acapulco, Gro." (Centro arriba)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6), 
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.white, size: 16),
                        SizedBox(width: 5),
                        Text(
                          "Acapulco, Gro.",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),

                  // Botón de Alerta con el triángulo (Arriba a la derecha)
                  _botonCircular(Icons.warning_amber_rounded, () {
                    debugPrint("ALERTA MANUAL");
                  }, esAlerta: true),
                ],
              ),
            ),
          ),

          DraggableScrollableSheet(
            initialChildSize: 0.45, 
            minChildSize: 0.12,     
            maxChildSize: 0.85,     
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white, 
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 20, spreadRadius: 5)
                  ],
                ),
                child: SingleChildScrollView(
                  controller: scrollController, 
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      Center(
                        child: Container(
                          height: 5,
                          width: 50,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            //  Las 3 Pestañas (Usuario, Moto, Escudo)
                            _construirTab(0, Icons.person),
                            _construirTab(1, Icons.motorcycle), 
                            _construirTab(2, Icons.security), 
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      Container(
                        constraints: BoxConstraints(
                          minHeight: size.height * 0.8, 
                        ),
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          children: [
                             const SizedBox(height: 10),
                             AnimatedSwitcher(
                               duration: const Duration(milliseconds: 300),
                               child: _construirContenidoPanel(),
                             ),
                             const SizedBox(height: 100), 
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _construirContenidoPanel() {
    switch (_tabSeleccionada) {
      case 0: return _vistaUsuario();
      case 1: return _vistaMoto();
      case 2: return _vistaSeguridad();
      default: return _vistaUsuario();
    }
  }

  // --- 1. PESTAÑA USUARIO ---
  Widget _vistaUsuario() {
    return Column(
      key: const ValueKey<int>(0),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),

        // Tarjeta Principal de Perfil
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade100),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PantallaPerfil()),
              );
            },
            child: Row(
              children: [
                const Hero(
                  tag: 'avatar_perfil',
                  child: CircleAvatar(
                    radius: 35,
                    backgroundColor: Color(0xFF1A237E),
                    child: Text("P", style: TextStyle(color: Colors.white, fontSize: 28)),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Paul Flores",
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.bold, 
                          fontSize: 20,
                          color: Colors.black87
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6F00).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "Dispositivo Desactivado",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[300]),
              ],
            ),
          ),
        ),

        const SizedBox(height: 25),

        Text(
          "Gestión de Seguridad",
          style: GoogleFonts.montserrat(
            fontSize: 16, 
            fontWeight: FontWeight.bold,
            color: Colors.grey[800]
          ),
        ),
        const SizedBox(height: 15),

        _buildBotonElegante(
          titulo: "Contactos de Emergencia",
          subtitulo: "Define a quién avisar en caso de accidente",
          icon: Icons.group_add_rounded,
          colorIcono: const Color(0xFF1A237E), 
          onTap: () {},
        ),

        const SizedBox(height: 15),

        // Boton QR
        _buildBotonElegante(
          titulo: "Mi Código QR Médico",
          subtitulo: "Comparte tus datos vitales al instante",
          icon: Icons.qr_code_scanner_rounded,
          colorIcono: const Color(0xFF6200EA), 
          onTap: () {
             _mostrarCodigoQR(context); 
          },
        ),

        const SizedBox(height: 30),

        Text(
          "Artículos Recientes",
          style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),
        
        _buildArticuloCard(
          "Mantenimiento Básico", 
          "Aprende a revisar los frenos de tu moto antes de salir.",
          Icons.build_circle_outlined
        ),
        
        const SizedBox(height: 50),
      ],
    );
  }

  void _mostrarCodigoQR(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: Colors.white,
          elevation: 10,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Identidad SAM", style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 22, color: const Color(0xFF1A237E))),
                const SizedBox(height: 8),
                Text("Escanea para ver el perfil médico en caso de emergencia.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                const SizedBox(height: 25),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 15, spreadRadius: 5)],
                  ),
                  child: const Icon(Icons.qr_code_2_rounded, size: 180, color: Colors.black87),
                ),
                const SizedBox(height: 25),
                const Text("Paul Flores", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const Text("O+ | Alergia: Penicilina", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 55, 
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[100],
                      foregroundColor: Colors.black87,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: const Text("CERRAR", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  // --- 2. PESTAÑA MOTO ---
  Widget _vistaMoto() {
    return Column(
      key: const ValueKey<int>(1),
      children: [
        const SizedBox(height: 20),
        const Icon(Icons.two_wheeler, size: 80, color: Colors.grey),
        const SizedBox(height: 10),
        Text("Estado de tu Moto", style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        const Text("Sensor Bluetooth: Desconectado", style: TextStyle(color: Colors.red)),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {}, 
          child: const Text("Conectar Sensor")
        )
      ],
    );
  }

  // --- 3. PESTAÑA SEGURIDAD / TELEMETRÍA (NUEVA) ---
  Widget _vistaSeguridad() {
    return Column(
      key: const ValueKey<int>(2),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Text(
          "¿Qué tan bien conduces?", 
          style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold)
        ),
        const SizedBox(height: 15),

        // Tarjeta de Puntuación (Score)
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1A237E), Color(0xFF3949AB)], 
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1A237E).withValues(alpha: 0.3), 
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
                  const Text("Puntuación de Seguridad", style: TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 5),
                  const Text("95 / 100", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.greenAccent.withValues(alpha: 0.2), 
                      borderRadius: BorderRadius.circular(10)
                    ),
                    child: const Text("Conductor Excelente", style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ],
              ),
              const Icon(Icons.shield_rounded, color: Colors.white, size: 60),
            ],
          ),
        ),

        const SizedBox(height: 25),

        // Grid de Telemetría (Velocidades e Inclinación)
        Row(
          children: [
            Expanded(child: _buildStatCard("Velocidad Máx", "110", "km/h", Icons.speed_rounded, Colors.orange)),
            const SizedBox(width: 15),
            Expanded(child: _buildStatCard("Inclinación Máx", "42", "grados", Icons.screen_rotation_alt_rounded, Colors.blue)),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(child: _buildStatCard("Incidentes", "1", "totales", Icons.warning_amber_rounded, Colors.red)),
            const SizedBox(width: 15),
            Expanded(child: _buildStatCard("Vel. Mínima", "15", "km/h", Icons.moving_rounded, Colors.teal)),
          ],
        ),

        const SizedBox(height: 30),

        // Historial de Incidentes
        Text(
          "Historial de Incidentes", 
          style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold)
        ),
        const SizedBox(height: 15),
        
        _buildIncidenteItem(fecha: "24 Feb 2026", detalle: "Sin incidentes recientes", esPositivo: true),
        _buildIncidenteItem(fecha: "12 Feb 2026", detalle: "Inclinación crítica (45°)", esPositivo: false),
        _buildIncidenteItem(fecha: "05 Ene 2026", detalle: "Frenado brusco detectado", esPositivo: false),

        const SizedBox(height: 50),
      ],
    );
  }
  
  //WIDGETS AUXILIARES
  
  Widget _buildBotonElegante({
    required String titulo, 
    required String subtitulo, 
    required IconData icon, 
    required Color colorIcono,
    required VoidCallback onTap
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
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
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: colorIcono, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titulo,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitulo,
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[300]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildArticuloCard(String titulo, String resumen, IconData icono) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50], 
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icono, size: 40, color: Colors.grey[400]),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text(resumen, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          )
        ],
      ),
    );
  }

  // Para la Cuadrícula de Telemetría
  Widget _buildStatCard(String titulo, String valor, String unidad, IconData icono, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
           BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, color: color, size: 24),
          const SizedBox(height: 10),
          Text(titulo, style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.bold)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(valor, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
              const SizedBox(width: 4),
              Text(unidad, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
            ],
          )
        ],
      ),
    );
  }

  // Para la Lista de Historial
  Widget _buildIncidenteItem({required String fecha, required String detalle, required bool esPositivo}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: esPositivo ? Colors.green.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              esPositivo ? Icons.check_circle_outline : Icons.warning_amber_rounded, 
              color: esPositivo ? Colors.green : Colors.orange,
              size: 20
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(detalle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 2),
                Text(fecha, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _botonCircular(IconData icon, VoidCallback onPressed, {bool esAlerta = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 5, offset: const Offset(0, 2)),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: const Color(0xFF1A237E)),
        iconSize: 28,
        onPressed: onPressed,
      ),
    );
  }

  Widget _construirTab(int index, IconData icon) {
    bool activo = _tabSeleccionada == index;
    return GestureDetector(
      onTap: () => setState(() => _tabSeleccionada = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 90,
        height: 45,
        decoration: BoxDecoration(
          color: activo ? const Color(0xFF1A237E) : const Color(0xFF9FA8DA),
          borderRadius: BorderRadius.circular(25),
          boxShadow: activo ? [
             BoxShadow(color: const Color(0xFF1A237E).withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 4))
          ] : [],
        ),
        child: Icon(icon, color: Colors.white, size: 28),
      ),
    );
  }
}