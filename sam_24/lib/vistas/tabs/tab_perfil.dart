import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Para rootBundle
import 'package:google_fonts/google_fonts.dart';

// Firebase
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Importación de tu vista de perfil
import 'package:sam_remastered/vistas/perfil.dart';

// Paquetes para QR y PDF
import 'package:qr_flutter/qr_flutter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class TabPerfil extends StatelessWidget {
  const TabPerfil({super.key});

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
          return Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary));
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Center(
            child: Text(
              "No se encontraron datos del usuario.", 
              style: TextStyle(color: isDark ? Colors.white : Colors.black)
            )
          );
        }

        var userData = snapshot.data!.data() as Map<String, dynamic>;
        String nombre = userData['nombre'] ?? 'Usuario';
        
        var c1 = userData['contactoPrincipal'] as Map<String, dynamic>?;
        var c2 = userData['contactoSecundario'] as Map<String, dynamic>?;
        
        String n1 = (c1?['nombre']?.toString().isNotEmpty == true) ? c1!['nombre'] : 'Sin asignar';
        String t1 = (c1?['telefono']?.toString().isNotEmpty == true) ? c1!['telefono'] : '';
        
        String n2 = (c2?['nombre']?.toString().isNotEmpty == true) ? c2!['nombre'] : 'Sin asignar';
        String t2 = (c2?['telefono']?.toString().isNotEmpty == true) ? c2!['telefono'] : '';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _tarjetaPerfilElegante(context, nombre, isDark),
            const SizedBox(height: 25),
            
            Text(
              "Gestión de Seguridad", 
              style: GoogleFonts.montserrat(
                fontSize: 16, 
                fontWeight: FontWeight.bold, 
                color: isDark ? Colors.grey[300] : Colors.grey[800]
              )
            ),
            const SizedBox(height: 15),
            
            _buildBotonElegante(
              titulo: "Contactos de Emergencia",
              subtitulo: "1. $n1\n2. $n2".trim(),
              icon: Icons.group_add_rounded,
              colorIcono: isDark ? Colors.blueAccent : const Color(0xFF1A237E),
              isDark: isDark,
              onTap: () => _mostrarContactosDialog(context, n1, t1, n2, t2, isDark),
            ),
            const SizedBox(height: 15),
            
            _buildBotonElegante(
              titulo: "Mi Código QR Médico",
              subtitulo: "Comparte tus datos vitales al instante",
              icon: Icons.qr_code_scanner_rounded,
              colorIcono: isDark ? Colors.purpleAccent : const Color(0xFF6200EA),
              isDark: isDark,
              onTap: () => _mostrarCodigoQR(context, userData, isDark),
            ),
            const SizedBox(height: 30),
            
            Text(
              "Artículos Recientes", 
              style: GoogleFonts.montserrat(
                fontSize: 18, 
                fontWeight: FontWeight.bold, 
                color: isDark ? Colors.white : Colors.black87
              )
            ),
            const SizedBox(height: 15),
            
            _buildArticuloCard(
              "Mantenimiento Básico", 
              "Aprende a revisar los frenos de tu moto antes de salir.", 
              Icons.build_circle_outlined, 
              isDark
            ),
          ],
        );
      }
    );
  }

  // --- WIDGETS DE INTERFAZ ---

  Widget _tarjetaPerfilElegante(BuildContext context, String nombre, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade100),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: const Color(0xFF1A237E),
            child: Text(
              nombre.isNotEmpty ? nombre[0].toUpperCase() : 'U', 
              style: const TextStyle(color: Colors.white, fontSize: 24)
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
                    fontSize: 18, 
                    fontWeight: FontWeight.bold, 
                    color: isDark ? Colors.white : Colors.black87
                  )
                ),
                const Text(
                  "Piloto Activo", 
                  style: TextStyle(
                    color: Colors.greenAccent, 
                    fontSize: 13, 
                    fontWeight: FontWeight.w500
                  )
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => const PantallaPerfil())
              );
            },
            icon: Icon(
              Icons.arrow_forward_ios_rounded, 
              size: 18, 
              color: isDark ? Colors.grey[600] : Colors.grey[300]
            ),
          )
        ],
      ),
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

  // --- LÓGICA DE DIÁLOGOS ---

  void _mostrarContactosDialog(BuildContext context, String n1, String t1, String n2, String t2, bool isDark) {
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
                    Text(
                      "Red de Apoyo", 
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.bold, 
                        fontSize: 18, 
                        color: isDark ? Colors.white : Colors.black87
                      )
                    ),
                  ],
                ),
                Divider(height: 30, color: isDark ? Colors.white10 : Colors.grey.shade300),
                
                const Text("CONTACTO PRINCIPAL", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: isDark ? Colors.red.withValues(alpha: 0.2) : Colors.red.shade50, 
                    child: const Icon(Icons.favorite, color: Colors.red, size: 20)
                  ),
                  title: Text(n1, style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                  subtitle: Text(t1, style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700])),
                ),
                
                const SizedBox(height: 10),
                
                const Text("CONTACTO SECUNDARIO", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: isDark ? Colors.blue.withValues(alpha: 0.2) : Colors.blue.shade50, 
                    child: const Icon(Icons.person, color: Colors.blue, size: 20)
                  ),
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
                      elevation: 0
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

  void _mostrarCodigoQR(BuildContext context, Map<String, dynamic> userData, bool isDark) {
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
        
    String datosQR = "SAM24 - EMERGENCIA MEDICA\nPaciente: $nombre\nSangre: $tipoSangre\nAlergias: $alergias\nCONTACTOS:\n1) $n1: $t1\n2) $n2: $t2";

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
                  Text(
                    "Identidad SAM", 
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.bold, 
                      fontSize: 22, 
                      color: Theme.of(context).colorScheme.primary
                    )
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Descarga tu código, imprímelo como calcomanía y pégalo en tu moto.", 
                    textAlign: TextAlign.center, 
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600], 
                      fontSize: 13
                    )
                  ),
                  const SizedBox(height: 25),
                  
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white, 
                      borderRadius: BorderRadius.circular(20), 
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1), 
                          blurRadius: 15, 
                          spreadRadius: 5
                        )
                      ]
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        QrImageView(
                          data: datosQR, 
                          version: QrVersions.auto, 
                          size: 180.0, 
                          errorCorrectionLevel: QrErrorCorrectLevel.H
                        ),
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(
                            color: Colors.white, 
                            shape: BoxShape.circle
                          ),
                          child: Image.asset(
                            'assets/images/cruz_roja.png', 
                            width: 35, 
                            height: 35, 
                            fit: BoxFit.contain, 
                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, color: Colors.red)
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  Text(
                    nombre, 
                    style: TextStyle(
                      fontWeight: FontWeight.bold, 
                      fontSize: 18, 
                      color: isDark ? Colors.white : Colors.black87
                    ), 
                    textAlign: TextAlign.center
                  ),
                  const SizedBox(height: 4),
                  Text(
                    textoMedico, 
                    style: const TextStyle(
                      color: Colors.redAccent, 
                      fontWeight: FontWeight.bold, 
                      fontSize: 14
                    ), 
                    textAlign: TextAlign.center
                  ),
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
                      label: const Text(
                        "DESCARGAR STICKER", 
                        style: TextStyle(
                          fontWeight: FontWeight.bold, 
                          fontSize: 14, 
                          letterSpacing: 1, 
                          color: Colors.white
                        )
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700, 
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), 
                        elevation: 0
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
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
                borderRadius: pw.BorderRadius.circular(20)
              ),
              padding: const pw.EdgeInsets.all(25),
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text("SAM24", style: pw.TextStyle(fontSize: 32, fontWeight: pw.FontWeight.bold, color: PdfColors.red700)),
                  pw.Text("ASISTENCIA MEDICA", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, letterSpacing: 2)),
                  pw.SizedBox(height: 25),
                  pw.Stack(
                    alignment: pw.Alignment.center,
                    children: [
                      pw.BarcodeWidget(
                        barcode: pw.Barcode.qrCode(errorCorrectLevel: pw.BarcodeQRCorrectionLevel.high), 
                        data: datosQR, 
                        width: 180, 
                        height: 180
                      ),
                      pw.Container(
                        padding: const pw.EdgeInsets.all(4), 
                        decoration: const pw.BoxDecoration(
                          color: PdfColors.white, 
                          shape: pw.BoxShape.circle
                        ), 
                        child: pw.Image(cruzRojaPdf, width: 35, height: 35)
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
      name: 'Sticker_SAM24_$nombre.pdf'
    );
  }
}