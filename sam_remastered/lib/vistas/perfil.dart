import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// --- NUEVOS IMPORTS ---
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sam_remastered/main.dart'; // Para redirigir al Onboarding al cerrar sesión

class PantallaPerfil extends StatelessWidget {
  const PantallaPerfil({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Obtenemos el usuario actual
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Mi Perfil SAM", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF1A237E),
      ),
      // 2. StreamBuilder para leer los datos en tiempo real
      body: user == null 
        ? const Center(child: Text("No hay sesión iniciada"))
        : StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('usuarios').doc(user.uid).snapshots(),
            builder: (context, snapshot) {
              
              // Mientras carga
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFF1A237E)));
              }

              // Si hay error o no hay datos
              if (!snapshot.hasData || !snapshot.data!.exists) {
                return const Center(child: Text("No se encontró la información del perfil."));
              }

              // 3. Extraemos los datos de Firestore
              var datos = snapshot.data!.data() as Map<String, dynamic>;
              
              String nombre = datos['nombre'] ?? 'Usuario';
              String inicial = nombre.isNotEmpty ? nombre[0].toUpperCase() : 'U';
              String email = user.email ?? 'Sin correo';
              
              String tipoSangre = datos['tipoSangre'] ?? 'N/A';
              String alergias = (datos['alergias'] == null || datos['alergias'].toString().isEmpty) 
                  ? 'Ninguna' 
                  : datos['alergias'];
              
              String fechaNac = datos['fechaNacimiento'] ?? '--/--/----';
              String telefono = datos['telefono'] ?? 'Sin registrar';

              // Contactos
              var c1 = datos['contactoPrincipal'] as Map<String, dynamic>?;
              var c2 = datos['contactoSecundario'] as Map<String, dynamic>?;
              
              String n1 = c1?['nombre'] ?? 'No asignado';
              String t1 = c1?['telefono'] ?? '--';
              String n2 = c2?['nombre'] ?? 'No asignado';
              String t2 = c2?['telefono'] ?? '--';

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // FOTO Y NOMBRE
                    Center(
                      child: Hero(
                        tag: 'avatar_perfil',
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: const Color(0xFF1A237E),
                          child: Text(inicial, style: const TextStyle(fontSize: 40, color: Colors.white)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      nombre,
                      style: GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    Text(email, style: const TextStyle(color: Colors.grey)),
                    
                    const SizedBox(height: 30),

                    // TARJETA MÉDICA
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFEF5350), Color(0xFFB71C1C)], 
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: Colors.red.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 5))
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("TIPO DE SANGRE", style: TextStyle(color: Colors.white70, fontSize: 12)),
                                Text(tipoSangre, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 10),
                                const Text("ALERGIAS", style: TextStyle(color: Colors.white70, fontSize: 12)),
                                Text(alergias, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          Icon(Icons.medical_services_outlined, color: Colors.white.withValues(alpha: 0.2), size: 80),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // DATOS DE CONTACTO DE EMERGENCIA
                    _buildSeccion("Contactos de Emergencia"),
                    _buildItemInfo(Icons.phone, n1, t1),
                    _buildItemInfo(Icons.phone, n2, t2),

                    const SizedBox(height: 20),
                    
                    // DATOS DE CUENTA
                    _buildSeccion("Información de Cuenta"),
                    _buildItemInfo(Icons.cake, "Fecha de Nacimiento", fechaNac),
                    _buildItemInfo(Icons.smartphone, "Teléfono", telefono),

                    const SizedBox(height: 40),

                    // BOTÓN CERRAR SESIÓN
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () async {
                          // 1. Mostramos un mini dialogo de carga opcional
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => const Center(child: CircularProgressIndicator()),
                          );

                          // 2. Cerramos sesión en Firebase
                          await FirebaseAuth.instance.signOut();

                          // 3. Navegamos borrando todo el historial para que no pueda volver atrás con la flecha
                          if (context.mounted) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => const OnboardingScreen()), 
                              (route) => false,
                            );
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))
                        ),
                        child: const Text("CERRAR SESIÓN", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              );
            },
          ),
    );
  }

  // --- WIDGETS AUXILIARES ---

  Widget _buildSeccion(String titulo) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(titulo, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
      ),
    );
  }

  Widget _buildItemInfo(IconData icon, String titulo, String dato) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: Colors.grey.shade200)),
      child: ListTile(
        leading: Icon(icon, color: Colors.grey),
        title: Text(titulo, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        subtitle: Text(dato, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black)),
      ),
    );
  }
}