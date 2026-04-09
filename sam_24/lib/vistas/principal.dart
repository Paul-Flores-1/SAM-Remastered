import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

// Importaciones de tus vistas
import 'package:sam_remastered/vistas/ajustes.dart';
import 'package:sam_remastered/vistas/alerta_dialog.dart';

// Importaciones de las nuevas pestañas modulares
import 'package:sam_remastered/vistas/tabs/tab_perfil.dart';
import 'package:sam_remastered/vistas/tabs/tab_moto.dart';
import 'package:sam_remastered/vistas/tabs/tab_viajes.dart';
import 'package:sam_remastered/vistas/tabs/tab_seguridad.dart';

class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  int _tabSeleccionada = 0;
  final Completer<GoogleMapController> _controller = Completer();
  bool _permisoConcedido = false;

  static const CameraPosition _posicionInicial = CameraPosition(
    target: LatLng(16.8531, -99.8237),
    zoom: 14.0,
  );

  @override
  void initState() {
    super.initState();
    _obtenerUbicacionActual();
  }

  Future<void> _obtenerUbicacionActual() async {
    bool servicioHabilitado = await Geolocator.isLocationServiceEnabled();
    if (!servicioHabilitado) return;

    LocationPermission permiso = await Geolocator.checkPermission();
    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
      if (permiso == LocationPermission.denied) return;
    }
    if (permiso == LocationPermission.deniedForever) return;

    setState(() => _permisoConcedido = true);

    Position posicion = await Geolocator.getCurrentPosition(locationSettings: const LocationSettings(
    accuracy: LocationAccuracy.high,
  ),
);
    final GoogleMapController controlador = await _controller.future;
    controlador.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: LatLng(posicion.latitude, posicion.longitude), zoom: 16.5),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // MAPA DE FONDO
          SizedBox(
            height: size.height,
            width: double.infinity,
            child: GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: _posicionInicial,
              myLocationEnabled: _permisoConcedido,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              compassEnabled: false,
              onMapCreated: (controller) => _controller.complete(controller),
            ),
          ),

          // BOTONES SUPERIORES FLOTANTES
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _botonCircular(Icons.settings_outlined, () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const PantallaAjustes()));
                  }, isDark),
                  
                  _etiquetaUbicacion(isDark),

                  _botonCircular(Icons.warning_amber_rounded, () {
                    showDialog(
                      context: context,
                      barrierColor: Colors.black.withValues(alpha: 0.4),
                      barrierDismissible: false,
                      builder: (context) => const DialogoAlerta(),
                    );
                  }, isDark, esAlerta: true),
                ],
              ),
            ),
          ),

          // PANEL DESLIZABLE MODERNIZADO
          DraggableScrollableSheet(
            initialChildSize: 0.42,
            minChildSize: 0.15,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF121212) : Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(35)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.1), blurRadius: 20, offset: const Offset(0, -5))
                  ],
                ),
                child: CustomScrollView(
                  controller: scrollController,
                  slivers: [
                    SliverToBoxAdapter(
                      child: Center(
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 12),
                          height: 5,
                          width: 40,
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey[800] : Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[100],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              _tabItem(0, Icons.person_outline_rounded, isDark),
                              _tabItem(1, Icons.motorcycle_rounded, isDark),
                              _tabItem(2, Icons.route_outlined, isDark),
                              _tabItem(3, Icons.shield_outlined, isDark),
                            ],
                          ),
                        ),
                      ),
                    ),

                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: _construirContenidoPanel(),
                          ),
                          const SizedBox(height: 100),
                        ]),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _tabItem(int index, IconData icon, bool isDark) {
    bool seleccionado = _tabSeleccionada == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tabSeleccionada = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: seleccionado ? (isDark ? Colors.white : const Color(0xFF1A237E)) : Colors.transparent,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(
            icon,
            color: seleccionado ? (isDark ? Colors.black : Colors.white) : (isDark ? Colors.grey[600] : Colors.grey[500]),
            size: 24,
          ),
        ),
      ),
    );
  }

  // AQUI CONECTAMOS LOS ARCHIVOS SEPARADOS
  Widget _construirContenidoPanel() {
    switch (_tabSeleccionada) {
      case 0: return const TabPerfil(key: ValueKey<int>(0));
      case 1: return const TabMoto(key: ValueKey<int>(1));
      case 2: return const TabViajes(key: ValueKey<int>(2));
      case 3: return const TabSeguridad(key: ValueKey<int>(3));
      default: return const TabPerfil(key: ValueKey<int>(0));
    }
  }

  Widget _etiquetaUbicacion(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: isDark ? Colors.black.withValues(alpha: 0.7) : Colors.white.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(30), boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)]),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.location_on, color: Colors.redAccent, size: 18),
          const SizedBox(width: 6),
          Text("Acapulco, Gro.", style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black87)),
        ],
      ),
    );
  }

  Widget _botonCircular(IconData icon, VoidCallback onTap, bool isDark, {bool esAlerta = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        width: 50,
        decoration: BoxDecoration(
          color: esAlerta ? Colors.redAccent : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
          shape: BoxShape.circle,
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))],
        ),
        child: Icon(icon, color: esAlerta ? Colors.white : (isDark ? Colors.white : const Color(0xFF1A237E)), size: 26),
      ),
    );
  }
}