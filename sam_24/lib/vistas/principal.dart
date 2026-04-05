import 'dart:async'; 
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; 
import 'package:geolocator/geolocator.dart'; 
import 'package:sam_remastered/vistas/perfil.dart';
import 'package:sam_remastered/vistas/ajustes.dart';
import 'package:sam_remastered/vistas/alerta_dialog.dart';
import 'package:sam_remastered/vistas/escaner_qr.dart'; // <-- IMPORT DEL ESCÁNER

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:qr_flutter/qr_flutter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

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
    bool servicioHabilitado;
    LocationPermission permiso;

    servicioHabilitado = await Geolocator.isLocationServiceEnabled();
    if (!servicioHabilitado) return;

    permiso = await Geolocator.checkPermission();
    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
      if (permiso == LocationPermission.denied) return;
    }
    
    if (permiso == LocationPermission.deniedForever) return;

    setState(() {
      _permisoConcedido = true;
    });

    Position posicion = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final GoogleMapController controlador = await _controller.future;
    controlador.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(posicion.latitude, posicion.longitude),
          zoom: 16.5, 
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // --- DETECCIÓN DEL MODO OSCURO GLOBAL ---
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // 1. MAPA DE FONDO
          SizedBox(
            height: size.height,
            width: double.infinity,
            child: GoogleMap(
              mapType: MapType.normal, 
              initialCameraPosition: _posicionInicial,
              myLocationEnabled: _permisoConcedido, 
              myLocationButtonEnabled: false,       
              trafficEnabled: false,      
              buildingsEnabled: false,    
              indoorViewEnabled: false,   
              mapToolbarEnabled: false,   
              liteModeEnabled: false,
              zoomControlsEnabled: false, 
              compassEnabled: false,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
            ),
          ),

          // 2. BOTONES SUPERIORES FLOTANTES
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  
                  _botonCircular(Icons.settings, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PantallaAjustes()),
                    );
                  }, isDark),
                  
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.black.withValues(alpha: 0.8) : Colors.black.withValues(alpha: 0.6), 
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

          // 3. PANEL DESLIZABLE
          DraggableScrollableSheet(
            initialChildSize: 0.45, 
            minChildSize: 0.12,     
            maxChildSize: 0.85,     
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF121212) : Colors.white, 
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(color: isDark ? Colors.black54 : Colors.black12, blurRadius: 8, offset: const Offset(0, -3))
                  ],
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  child: ListView(
                    controller: scrollController, 
                    padding: EdgeInsets.zero, 
                    physics: const ClampingScrollPhysics(), 
                    children: [
                      const SizedBox(height: 10),
                      
                      Center(
                        child: Container(
                          height: 5,
                          width: 50,
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey[700] : Colors.grey[300],
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
                            _construirTab(0, Icons.person, isDark),
                            _construirTab(1, Icons.motorcycle, isDark), 
                            _construirTab(2, Icons.security, isDark), 
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: _construirContenidoPanel(isDark),
                        ),
                      ),
                      
                      const SizedBox(height: 100), 
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

  Widget _construirContenidoPanel(bool isDark) {
    switch (_tabSeleccionada) {
      case 0: return _vistaUsuario(isDark);
      case 1: return _vistaMoto(isDark);
      case 2: return _vistaSeguridad(isDark);
      default: return _vistaUsuario(isDark);
    }
  }

  // --- 1. PESTAÑA USUARIO ---
  Widget _vistaUsuario(bool isDark) {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Center(child: Text("No hay sesión iniciada", style: TextStyle(color: isDark ? Colors.white : Colors.black)));
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('usuarios').doc(user.uid).snapshots(),
      builder: (context, snapshot) {
        
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary));
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Center(child: Text("No se encontraron datos del usuario.", style: TextStyle(color: isDark ? Colors.white : Colors.black)));
        }

        var userData = snapshot.data!.data() as Map<String, dynamic>;
        String nombre = userData['nombre'] ?? 'Usuario';
        String inicial = nombre.isNotEmpty ? nombre[0].toUpperCase() : 'U';

        var c1 = userData['contactoPrincipal'] as Map<String, dynamic>?;
        var c2 = userData['contactoSecundario'] as Map<String, dynamic>?;
        
        String n1 = (c1?['nombre']?.toString().isNotEmpty == true) ? c1!['nombre'] : 'Sin asignar';
        String t1 = (c1?['telefono']?.toString().isNotEmpty == true) ? c1!['telefono'] : '';
        
        String n2 = (c2?['nombre']?.toString().isNotEmpty == true) ? c2!['nombre'] : 'Sin asignar';
        String t2 = (c2?['telefono']?.toString().isNotEmpty == true) ? c2!['telefono'] : '';

        String subtituloContactos = "1. $n1 ($t1)\n2. $n2 ($t2)".trim();

        return Column(
          key: const ValueKey<int>(0),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            // Tarjeta Principal de Perfil
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade100),
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
                    Hero(
                      tag: 'avatar_perfil',
                      child: CircleAvatar(
                        radius: 35,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: Text(inicial, style: const TextStyle(color: Colors.white, fontSize: 28)),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nombre,
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.bold, 
                              fontSize: 20,
                              color: isDark ? Colors.white : Colors.black87
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
                    Icon(Icons.arrow_forward_ios, size: 16, color: isDark ? Colors.grey[600] : Colors.grey[300]),
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
                color: isDark ? Colors.grey[300] : Colors.grey[800]
              ),
            ),
            const SizedBox(height: 15),

            _buildBotonElegante(
              titulo: "Contactos de Emergencia",
              subtitulo: subtituloContactos, 
              icon: Icons.group_add_rounded,
              colorIcono: isDark ? Colors.blueAccent : const Color(0xFF1A237E), 
              isDark: isDark,
              onTap: () {
                _mostrarContactosDialog(context, n1, t1, n2, t2);
              },
            ),

            const SizedBox(height: 15),

            _buildBotonElegante(
              titulo: "Mi Código QR Médico",
              subtitulo: "Comparte tus datos vitales al instante",
              icon: Icons.qr_code_scanner_rounded,
              colorIcono: isDark ? Colors.purpleAccent : const Color(0xFF6200EA), 
              isDark: isDark,
              onTap: () {
                 _mostrarCodigoQR(context, userData); 
              },
            ),

            const SizedBox(height: 30),

            Text(
              "Artículos Recientes",
              style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
            ),
            const SizedBox(height: 15),
            
            _buildArticuloCard(
              "Mantenimiento Básico", 
              "Aprende a revisar los frenos de tu moto antes de salir.",
              Icons.build_circle_outlined,
              isDark
            ),
            
            const SizedBox(height: 50),
          ],
        );
      }
    );
  }

  // --- POPUPS ---
  
  void _mostrarContactosDialog(BuildContext context, String n1, String t1, String n2, String t2) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.group_rounded, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 10),
                    Text("Red de Apoyo", style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 18, color: isDark ? Colors.white : Colors.black87)),
                  ],
                ),
                Divider(height: 30, color: isDark ? Colors.white10 : Colors.grey.shade300),
                
                const Text("CONTACTO PRINCIPAL", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(backgroundColor: isDark ? Colors.red.withValues(alpha: 0.2) : Colors.red.shade50, child: const Icon(Icons.favorite, color: Colors.red, size: 20)),
                  title: Text(n1, style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                  subtitle: Text(t1, style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700])),
                ),
                
                const SizedBox(height: 10),

                const Text("CONTACTO SECUNDARIO", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(backgroundColor: isDark ? Colors.blue.withValues(alpha: 0.2) : Colors.blue.shade50, child: const Icon(Icons.person, color: Colors.blue, size: 20)),
                  title: Text(n2, style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                  subtitle: Text(t2, style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700])),
                ),

                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? Colors.grey[800] : Colors.grey[100],
                      foregroundColor: isDark ? Colors.white : Colors.black87,
                      elevation: 0,
                    ),
                    child: const Text("CERRAR"),
                  ),
                )
              ],
            ),
          ),
        );
      }
    );
  }

  void _mostrarCodigoQR(BuildContext context, Map<String, dynamic> userData) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    String nombre = userData['nombre'] ?? 'Usuario';
    String tipoSangre = userData['tipoSangre'] ?? 'N/A';
    String alergias = userData['alergias'] ?? 'Ninguna';
    
    var c1 = userData['contactoPrincipal'] as Map<String, dynamic>?;
    var c2 = userData['contactoSecundario'] as Map<String, dynamic>?;
    String n1 = c1?['nombre'] ?? 'No asignado';
    String t1 = c1?['telefono'] ?? '---';
    String n2 = c2?['nombre'] ?? 'No asignado';
    String t2 = c2?['telefono'] ?? '---';

    String textoMedico = alergias == 'Ninguna' || alergias.isEmpty 
        ? "$tipoSangre | Sin alergias registradas" 
        : "$tipoSangre | Alergia: $alergias";

    String datosQR = """
🚨 SAM24 - EMERGENCIA MÉDICA 🚨
Paciente: $nombre
Sangre: $tipoSangre
Alergias: $alergias

📞 CONTACTOS DE EMERGENCIA:
1) $n1: $t1
2) $n2: $t2
""";

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          elevation: 10,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Identidad SAM", style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 22, color: Theme.of(context).colorScheme.primary)),
                  const SizedBox(height: 8),
                  Text("Descarga tu código, imprímelo como calcomanía y pégalo en tu moto o casco.", textAlign: TextAlign.center, style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 13)),
                  const SizedBox(height: 25),
                  
                  // EL CONTENEDOR DEL QR SIEMPRE DEBE SER BLANCO PARA LOS ESCÁNERES
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 15, spreadRadius: 5)],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        QrImageView(
                          data: datosQR,
                          version: QrVersions.auto,
                          size: 180.0,
                          errorCorrectionLevel: QrErrorCorrectLevel.H, 
                        ),
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Image.asset(
                            'assets/images/cruz_roja.png',
                            width: 35,
                            height: 35,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 25),
                  Text(nombre, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: isDark ? Colors.white : Colors.black87), textAlign: TextAlign.center),
                  const SizedBox(height: 4),
                  Text(textoMedico, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 14), textAlign: TextAlign.center),
                  
                  const SizedBox(height: 30),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context); 
                        _generarYMostrarPDF(nombre, tipoSangre, alergias, n1, t1, n2, t2, datosQR);
                      },
                      icon: const Icon(Icons.print_rounded, color: Colors.white),
                      label: const Text("DESCARGAR STICKER", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 0,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    height: 50, 
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? Colors.grey[800] : Colors.grey[100],
                        foregroundColor: isDark ? Colors.white : Colors.black87,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: const Text("CERRAR", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    );
  }

  Future<void> _generarYMostrarPDF(String nombre, String sangre, String alergias, String nc1, String tc1, String nc2, String tc2, String datosQR) async {
    final pdf = pw.Document();
    final ByteData bytesImagen = await rootBundle.load('assets/images/cruz_roja.png');
    final cruzRojaPdf = pw.MemoryImage(bytesImagen.buffer.asUint8List());

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Container(
              width: 280,
              height: 380,
              decoration: pw.BoxDecoration(
                color: PdfColors.white,
                border: pw.Border.all(color: PdfColors.red700, width: 4),
                borderRadius: pw.BorderRadius.circular(20),
              ),
              padding: const pw.EdgeInsets.all(25),
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text("SAM24", style: pw.TextStyle(fontSize: 32, fontWeight: pw.FontWeight.bold, color: PdfColors.red700)),
                  pw.Text("ASISTENCIA MÉDICA", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, letterSpacing: 2)),
                  
                  pw.SizedBox(height: 25),
                  
                  pw.Stack(
                    alignment: pw.Alignment.center,
                    children: [
                      pw.BarcodeWidget(
                        barcode: pw.Barcode.qrCode(errorCorrectLevel: pw.BarcodeQRCorrectionLevel.high),
                        data: datosQR,
                        width: 180,
                        height: 180,
                      ),
                      pw.Container(
                        padding: const pw.EdgeInsets.all(4),
                        decoration: const pw.BoxDecoration(
                          color: PdfColors.white,
                          shape: pw.BoxShape.circle,
                        ),
                        child: pw.Image(cruzRojaPdf, width: 35, height: 35),
                      ),
                    ],
                  ),

                  pw.SizedBox(height: 25),
                  
                  pw.Text("ESCANEAR EN CASO", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.red700)),
                  pw.Text("DE EMERGENCIA", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.red700)),
                  
                  pw.SizedBox(height: 15),
                  pw.Text(nombre.toUpperCase(), style: pw.TextStyle(fontSize: 10, color: PdfColors.grey800)),
                  pw.Text("SANGRE: $sangre", style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.black)),
                ],
              ),
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Sticker_SAM24_$nombre.pdf', 
    );
  }

  // --- 2. PESTAÑA MOTO ---
  Widget _vistaMoto(bool isDark) {
    return Column(
      key: const ValueKey<int>(1),
      children: [
        const SizedBox(height: 10),
        
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.qr_code_scanner_rounded, size: 50, color: Theme.of(context).colorScheme.primary),
        ),
        const SizedBox(height: 15),
        Text(
          "Vincula tu Sensor SAM",
          style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isDark ? Colors.red.withValues(alpha: 0.2) : Colors.red.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isDark ? Colors.red.withValues(alpha: 0.5) : Colors.red.shade200)
          ),
          child: const Text(
            "Estado: Sin vincular",
            style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
        const SizedBox(height: 35),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Column(
            children: [
              _buildPasoInstruccion(
                Icons.search_rounded, 
                "Localiza el QR", 
                "Encuentra la etiqueta de seguridad impresa en la carcasa de tu dispositivo SAM.",
                isDark
              ),
              const SizedBox(height: 20),
              _buildPasoInstruccion(
                Icons.lock_person_rounded, 
                "Escanea y Protege", 
                "Vincúlalo a tu cuenta para registrarte como el único administrador autorizado.",
                isDark
              ),
              const SizedBox(height: 20),
              _buildPasoInstruccion(
                Icons.cloud_done_rounded, 
                "Monitoreo 24/7", 
                "Activa la conexión a la nube para recibir alertas de movimiento en tiempo real.",
                isDark
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 40),

        // --- BOTÓN PRINCIPAL PARA ABRIR LA CÁMARA ---
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton.icon(
            onPressed: () async {
              // 1. Navegamos al escáner y esperamos a que nos devuelva un dato
              final resultado = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PantallaEscanerQR()),
              );

              // 2. Si el usuario escaneó algo (y no solo le dio a regresar)
              if (resultado != null) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("ID escaneado: $resultado", style: const TextStyle(fontWeight: FontWeight.bold)),
                      backgroundColor: Colors.green.shade600,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            icon: const Icon(Icons.camera_alt_rounded, color: Colors.white),
            label: const Text(
              "ABRIR LECTOR QR",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1, color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
          ),
        ),
        const SizedBox(height: 10),
        
        // --- BOTÓN SECUNDARIO PARA ENTRADA MANUAL ---
        TextButton(
          onPressed: () {
            // TODO: Mostrar popup para escribir el ID a mano
          },
          child: Text(
            "¿No puedes escanear? Ingresa el ID manualmente",
            style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey.shade600, decoration: TextDecoration.underline, fontSize: 12),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  // --- 3. PESTAÑA SEGURIDAD / TELEMETRÍA (CONECTADA A FIREBASE) ---
  Widget _vistaSeguridad(bool isDark) {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return Center(child: Text("No hay sesión", style: TextStyle(color: isDark ? Colors.white : Colors.black)));

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('usuarios').doc(user.uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary));
        if (!snapshot.hasData || !snapshot.data!.exists) return Center(child: Text("No hay datos de telemetría", style: TextStyle(color: isDark ? Colors.white : Colors.black)));

        var datos = snapshot.data!.data() as Map<String, dynamic>;
        var telemetria = datos['telemetria'] as Map<String, dynamic>?;

        // Extraemos variables. Si no existen, mostramos "--"
        int puntuacion = telemetria?['puntuacion'] ?? 0;
        String scoreTexto = puntuacion > 0 ? puntuacion.toString() : "--";
        String velMax = telemetria?['velocidadMax']?.toString() ?? "--";
        String incMax = telemetria?['inclinacionMax']?.toString() ?? "--";
        String incTotales = telemetria?['incidentesTotales']?.toString() ?? "--";
        String velMin = telemetria?['velocidadMin']?.toString() ?? "--";
        
        List<dynamic> historial = telemetria?['historial'] ?? [];

        // Lógica de colores para la puntuación
        Color colorPuntuacion = Colors.greenAccent;
        String textoPuntuacion = "Conductor Excelente";
        
        if (puntuacion > 0 && puntuacion < 80) {
          colorPuntuacion = Colors.redAccent;
          textoPuntuacion = "Precaución Sugerida";
        } else if (puntuacion >= 80 && puntuacion < 90) {
          colorPuntuacion = Colors.orangeAccent;
          textoPuntuacion = "Conductor Bueno";
        }

        return Column(
          key: const ValueKey<int>(2),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Text(
              "¿Qué tan bien conduces?", 
              style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)
            ),
            const SizedBox(height: 15),

            // Tarjeta de Puntuación
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
                      Text("$scoreTexto / 100", style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: colorPuntuacion.withValues(alpha: 0.2), 
                          borderRadius: BorderRadius.circular(10)
                        ),
                        child: Text(textoPuntuacion, style: TextStyle(color: colorPuntuacion, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ],
                  ),
                  const Icon(Icons.shield_rounded, color: Colors.white, size: 60),
                ],
              ),
            ),

            const SizedBox(height: 25),

            Row(
              children: [
                Expanded(child: _buildStatCard("Velocidad Máx", velMax, "km/h", Icons.speed_rounded, Colors.orange, isDark)),
                const SizedBox(width: 15),
                Expanded(child: _buildStatCard("Inclinación Máx", incMax, "grados", Icons.screen_rotation_alt_rounded, Colors.blue, isDark)),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(child: _buildStatCard("Incidentes", incTotales, "totales", Icons.warning_amber_rounded, Colors.red, isDark)),
                const SizedBox(width: 15),
                Expanded(child: _buildStatCard("Vel. Mínima", velMin, "km/h", Icons.moving_rounded, Colors.teal, isDark)),
              ],
            ),

            const SizedBox(height: 30),

            Text(
              "Historial de Incidentes", 
              style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)
            ),
            const SizedBox(height: 15),
            
            // Renderizamos la lista de historial desde Firebase
            if (historial.isEmpty)
               _buildIncidenteItem(fecha: "Hoy", detalle: "Sin incidentes recientes", esPositivo: true, isDark: isDark)
            else
              ...historial.map((incidente) {
                return _buildIncidenteItem(
                  fecha: incidente['fecha'] ?? 'Fecha desc.', 
                  detalle: incidente['detalle'] ?? 'Detalle desc.', 
                  esPositivo: incidente['esPositivo'] ?? true, 
                  isDark: isDark
                );
              }),

            const SizedBox(height: 50),
          ],
        );
      }
    );
  }
  
  // --- WIDGETS AUXILIARES ---

  Widget _buildPasoInstruccion(IconData icono, String titulo, String descripcion, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isDark ? Colors.blue.withValues(alpha: 0.1) : Colors.blue.shade50,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icono, color: isDark ? Colors.lightBlueAccent : Colors.blue.shade700, size: 22),
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
  
  Widget _buildBotonElegante({
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
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: isDark ? Colors.white : Colors.black87),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitulo,
                        style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[500], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, size: 14, color: isDark ? Colors.grey[700] : Colors.grey[300]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildArticuloCard(String titulo, String resumen, IconData icono, bool isDark) {
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
          Icon(icono, size: 40, color: isDark ? Colors.grey[600] : Colors.grey[400]),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : Colors.black87)),
                const SizedBox(height: 4),
                Text(resumen, style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 12)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatCard(String titulo, String valor, String unidad, IconData icono, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
        boxShadow: [
           if(!isDark) BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, color: color, size: 24),
          const SizedBox(height: 10),
          Text(titulo, style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 12, fontWeight: FontWeight.bold)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(valor, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: isDark ? Colors.white : Colors.black87)),
              const SizedBox(width: 4),
              Text(unidad, style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[500], fontSize: 12)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildIncidenteItem({required String fecha, required String detalle, required bool esPositivo, required bool isDark}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
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
                Text(detalle, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : Colors.black87)),
                const SizedBox(height: 2),
                Text(fecha, style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[500], fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _botonCircular(IconData icon, VoidCallback onPressed, bool isDark, {bool esAlerta = false}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: isDark ? Colors.white10 : Colors.transparent),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 5, offset: const Offset(0, 2)),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: esAlerta && isDark ? Colors.redAccent : (isDark ? Colors.white : const Color(0xFF1A237E))),
        iconSize: 28,
        onPressed: onPressed,
      ),
    );
  }

  Widget _construirTab(int index, IconData icon, bool isDark) {
    bool activo = _tabSeleccionada == index;
    return GestureDetector(
      onTap: () => setState(() => _tabSeleccionada = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 90,
        height: 45,
        decoration: BoxDecoration(
          color: activo ? Theme.of(context).colorScheme.primary : (isDark ? Colors.grey[800] : const Color(0xFF9FA8DA)),
          borderRadius: BorderRadius.circular(25),
          boxShadow: activo ? [
             BoxShadow(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 4))
          ] : [],
        ),
        child: Icon(icon, color: activo ? Colors.white : (isDark ? Colors.grey[400] : Colors.white), size: 28),
      ),
    );
  }
}