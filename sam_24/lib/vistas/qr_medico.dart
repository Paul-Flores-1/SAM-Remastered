import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Necesario para leer la cruz roja en el PDF
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// IMPORTS DE QR Y PDF
import 'package:qr_flutter/qr_flutter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PantallaQRMedico extends StatelessWidget {
  const PantallaQRMedico({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("Mi QR Médico", style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF1A237E), // Azul oscuro institucional
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        centerTitle: true,
      ),
      body: user == null
          ? const Center(child: Text("Inicia sesión para ver tu QR"))
          : StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('usuarios').doc(user.uid).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF1A237E)));
                }
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Center(child: Text("No se encontraron datos médicos."));
                }

                // 1. EXTRAER DATOS
                var datos = snapshot.data!.data() as Map<String, dynamic>;
                String nombre = datos['nombre'] ?? 'Usuario';
                String tipoSangre = datos['tipoSangre'] ?? 'N/A';
                String alergias = datos['alergias'] ?? 'Ninguna';
                
                var c1 = datos['contactoPrincipal'] as Map<String, dynamic>?;
                var c2 = datos['contactoSecundario'] as Map<String, dynamic>?;
                String nc1 = c1?['nombre'] ?? 'No asignado';
                String tc1 = c1?['telefono'] ?? '---';
                String nc2 = c2?['nombre'] ?? 'No asignado';
                String tc2 = c2?['telefono'] ?? '---';

                String textoMedico = alergias == 'Ninguna' || alergias.isEmpty 
                    ? "$tipoSangre | Sin alergias registradas" 
                    : "$tipoSangre | Alergia: $alergias";

                // TEXTO OFFLINE DEL QR
                String datosQR = """
🚨 SAM24 - EMERGENCIA MÉDICA 🚨
Paciente: $nombre
Sangre: $tipoSangre
Alergias: $alergias

📞 CONTACTOS DE EMERGENCIA:
1) $nc1: $tc1
2) $nc2: $tc2
""";

                return Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Identidad SAM", 
                          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 24, color: const Color(0xFF1A237E))
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Descarga tu código, imprímelo como calcomanía y pégalo en tu moto o casco.", 
                          textAlign: TextAlign.center, 
                          style: TextStyle(color: Colors.grey[600], fontSize: 14)
                        ),
                        const SizedBox(height: 30),
                        
                        // TARJETA DEL QR
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, spreadRadius: 5)
                            ],
                          ),
                          child: Column(
                            children: [
                              // STACK PARA LA CRUZ ROJA EN LA APP
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  QrImageView(
                                    data: datosQR,
                                    version: QrVersions.auto,
                                    size: 200.0,
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
                                      width: 40,
                                      height: 40,
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Text(nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18), textAlign: TextAlign.center),
                              const SizedBox(height: 5),
                              Text(textoMedico, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 14), textAlign: TextAlign.center),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 40),
                        
                        // BOTÓN PARA GENERAR EL STICKER
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton.icon(
                            onPressed: () => _generarYMostrarPDF(nombre, tipoSangre, alergias, nc1, tc1, nc2, tc2, datosQR),
                            icon: const Icon(Icons.print_rounded, color: Colors.white),
                            label: const Text("DESCARGAR STICKER PDF", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 1, color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade700,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              elevation: 5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  // ==========================================================
  // LÓGICA DE GENERACIÓN DE PDF: EL STICKER PARA LA MOTO
  // ==========================================================
  Future<void> _generarYMostrarPDF(String nombre, String sangre, String alergias, String nc1, String tc1, String nc2, String tc2, String datosQR) async {
    final pdf = pw.Document();

    // Leemos tu cruz roja para inyectarla en el PDF
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
                  
                  // STACK DEL QR PARA EL PDF
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
}