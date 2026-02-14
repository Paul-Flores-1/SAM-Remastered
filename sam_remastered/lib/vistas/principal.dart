import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  // Variable para controlar qué pestaña del panel está activa (0: Usuario, 1: Moto, 2: Seguridad)
  int _tabSeleccionada = 0;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      // Usamos Stack para poner el panel SOBRE el mapa
      body: Stack(
        children: [
          // 1. FONDO (Simulación de Mapa Oscuro)
          // Aquí iría el GoogleMap(...) real más adelante
          Container(
            height: size.height,
            width: double.infinity,
            color: const Color(0xFF0F172A), // Azul muy oscuro (estilo mapa nocturno)
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map, size: 100, color: Colors.white.withValues(alpha: 0.1)),
                  const SizedBox(height: 10),
                  Text(
                    "Vista de Mapa",
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                  )
                ],
              ),
            ),
          ),

          // 2. BOTONES FLOTANTES SUPERIORES (Ajustes y Alerta)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Botón Configuración (Izquierda)
                  _botonCircular(Icons.settings, () {
                    // Acción configuración
                  }),

                  // Texto Central (Ubicación simulada)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "Pueblo Nuevo",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                    ),
                  ),

                  // Botón Alerta (Derecha)
                  _botonCircular(Icons.warning_amber_rounded, () {
                    // Acción alerta
                  }, esAlerta: true),
                ],
              ),
            ),
          ),

          // 3. PANEL INFERIOR (Bottom Sheet)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: size.height * 0.45, // Ocupa el 45% de la pantalla abajo
              decoration: const BoxDecoration(
                color: Color(0xFFE0E0E0), // Gris claro de fondo general del panel
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(color: Colors.black26, blurRadius: 10, spreadRadius: 2)
                ],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  
                  // Manija (Handle) gris pequeña
                  Container(
                    height: 5,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  
                  const SizedBox(height: 15),

                  // --- PESTAÑAS (Usuario, Moto, Escudo) ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _construirTab(0, Icons.person),
                        _construirTab(1, Icons.motorcycle),
                        _construirTab(2, Icons.security),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // --- CONTENIDO DEL PANEL ---
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      // El fondo blanco que envuelve la info del usuario
                      decoration: const BoxDecoration(
                        color: Colors.white, // Fondo blanco para la lista
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          
                          // ITEM 1: USUARIO ACTUAL
                          Row(
                            children: [
                              // Avatar
                              const CircleAvatar(
                                radius: 25,
                                backgroundColor: Color(0xFF1A237E), // Azul oscuro
                                child: Text("P", style: TextStyle(color: Colors.white, fontSize: 24)),
                              ),
                              const SizedBox(width: 15),
                              // Textos
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Paul Flores",
                                      style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.black,
                                      ),
                                    ),
                                    Text(
                                      "Dispositivo Desactivado",
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.secondary, // Naranja
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const Text(
                                      "Ultima actualización a las 5:35 p. m.",
                                      style: TextStyle(color: Colors.grey, fontSize: 10),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),
                          const Divider(),
                          const SizedBox(height: 10),

                          // ITEM 2: AGREGAR PERSONA
                          InkWell( // Hace que sea cliqueable
                            onTap: (){},
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 25,
                                  backgroundColor: const Color(0xFF1A237E).withValues(alpha: 0.2), // Azul clarito
                                  child: const Icon(Icons.person_add, color: Color(0xFF1A237E)),
                                ),
                                const SizedBox(width: 15),
                                Text(
                                  "Agregar una persona",
                                  style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: const Color(0xFF1A237E), // Azul
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 30),

                          // TITULO: ARTICULOS
                          Text(
                            "Artículos",
                            style: GoogleFonts.montserrat(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGETS PERSONALIZADOS ---

  Widget _botonCircular(IconData icon, VoidCallback onPressed, {bool esAlerta = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: esAlerta ? const Color(0xFF1A237E) : const Color(0xFF1A237E)),
        iconSize: 28,
        onPressed: onPressed,
      ),
    );
  }

  Widget _construirTab(int index, IconData icon) {
    bool activo = _tabSeleccionada == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _tabSeleccionada = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 90,
        height: 45,
        decoration: BoxDecoration(
          // Si está activo usa azul fuerte, si no azul suave
          color: activo ? const Color(0xFF1A237E) : const Color(0xFF9FA8DA),
          borderRadius: BorderRadius.circular(25),
          boxShadow: activo ? [
             BoxShadow(color: const Color(0xFF1A237E).withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 4))
          ] : [],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}