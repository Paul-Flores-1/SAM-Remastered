import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sam_remastered/main.dart'; 

// --- IMPORTAMOS TU NUEVO MOTOR DE DATOS ---
import '../services/contactos_service.dart';

class PantallaPerfil extends StatelessWidget {
  const PantallaPerfil({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    // --- DETECCIÓN DEL MODO OSCURO ---
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mi Perfil SAM", style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        // Adaptamos el color del AppBar al tema
        foregroundColor: isDark ? Colors.white : const Color(0xFF1A237E),
      ),
      body: user == null 
        ? const Center(child: Text("No hay sesión iniciada"))
        : StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('usuarios').doc(user.uid).snapshots(),
            builder: (context, snapshot) {
              
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary));
              }

              if (!snapshot.hasData || !snapshot.data!.exists) {
                return const Center(child: Text("No se encontró la información del perfil."));
              }

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
                          backgroundColor: Theme.of(context).colorScheme.primary,
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
                    Text(email, style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey)),
                    
                    const SizedBox(height: 30),

                    // TARJETA MÉDICA (Esta no cambia porque el rojo y el blanco contrastan bien en ambos modos)
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

                    // --- DATOS DE CONTACTO DE EMERGENCIA ---
                    _buildSeccion("Contactos de Emergencia (Toca para editar)", isDark),
                    _buildContactoItem(context, "Contacto Principal", n1, t1, true, isDark),
                    _buildContactoItem(context, "Contacto Secundario", n2, t2, false, isDark),

                    const SizedBox(height: 20),
                    
                    // DATOS DE CUENTA (ESTÁTICOS)
                    _buildSeccion("Información de Cuenta", isDark),
                    _buildItemInfo(Icons.cake, "Fecha de Nacimiento", fechaNac, isDark),
                    _buildItemInfo(Icons.smartphone, "Teléfono", telefono, isDark),

                    const SizedBox(height: 40),

                    // BOTÓN CERRAR SESIÓN
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () async {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => const Center(child: CircularProgressIndicator()),
                          );
                          await FirebaseAuth.instance.signOut();
                          if (context.mounted) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => const OnboardingScreen()), 
                              (route) => false,
                            );
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.redAccent,
                          side: BorderSide(color: isDark ? Colors.redAccent.withValues(alpha: 0.5) : Colors.red),
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

  // --- WIDGETS AUXILIARES ADAPTADOS ---

  Widget _buildSeccion(String titulo, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          titulo, 
          style: TextStyle(
            fontSize: 14, 
            fontWeight: FontWeight.bold, 
            color: isDark ? Colors.blue.shade200 : const Color(0xFF1A237E)
          )
        ),
      ),
    );
  }

  Widget _buildItemInfo(IconData icon, String titulo, String dato, bool isDark) {
    return Card(
      elevation: 0,
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15), 
        side: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade200)
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.grey),
        title: Text(titulo, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        subtitle: Text(dato, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: isDark ? Colors.white : Colors.black)),
      ),
    );
  }

  Widget _buildContactoItem(BuildContext context, String titulo, String nombre, String telefono, bool esPrincipal, bool isDark) {
    return Card(
      elevation: 0,
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15), 
        side: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade200)
      ),
      child: InkWell( 
        borderRadius: BorderRadius.circular(15),
        onTap: () {
          _mostrarModalContacto(context, esPrincipal, nombre, telefono, titulo, isDark);
        },
        child: ListTile(
          leading: Icon(Icons.phone, color: esPrincipal ? Colors.red.shade400 : Colors.blue.shade400),
          title: Text(titulo, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          subtitle: Text("$nombre\n$telefono", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black87)),
          trailing: const Icon(Icons.edit_rounded, size: 20, color: Colors.grey),
          isThreeLine: true,
        ),
      ),
    );
  }

  // --- BOTTOM SHEET ADAPTADO ---
  void _mostrarModalContacto(BuildContext context, bool esPrincipal, String nombreActual, String telActual, String titulo, bool isDark) {
    TextEditingController nombreCtrl = TextEditingController(text: nombreActual == 'No asignado' ? '' : nombreActual);
    TextEditingController telCtrl = TextEditingController(text: telActual == '--' ? '' : telActual);
    final ContactosService contactosService = ContactosService();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, 
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white, // Fondo inteligente
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24, right: 24, top: 24
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, 
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 5,
                  decoration: BoxDecoration(color: isDark ? Colors.grey.shade800 : Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 20),
              
              Text("Editar $titulo", style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              
              TextField(
                controller: nombreCtrl,
                decoration: InputDecoration(
                  labelText: "Nombre del familiar/amigo",
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
              const SizedBox(height: 15),

              TextField(
                controller: telCtrl,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: "Número de Teléfono",
                  prefixIcon: const Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
              const SizedBox(height: 25),

              Row(
                children: [
                  if (nombreActual != 'No asignado')
                    Expanded(
                      flex: 1,
                      child: OutlinedButton(
                        onPressed: () async {
                          await contactosService.eliminarContacto(esPrincipal: esPrincipal);
                          if (context.mounted) Navigator.pop(context); 
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.redAccent,
                          side: BorderSide(color: isDark ? Colors.redAccent.withValues(alpha: 0.5) : Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        child: const Icon(Icons.delete_outline),
                      ),
                    ),
                  
                  if (nombreActual != 'No asignado') const SizedBox(width: 10),

                  Expanded(
                    flex: 3,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (nombreCtrl.text.isEmpty || telCtrl.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Llena ambos campos")));
                          return;
                        }
                        ContactoEmergencia nuevoContacto = ContactoEmergencia(nombre: nombreCtrl.text, telefono: telCtrl.text);
                        await contactosService.guardarContacto(contacto: nuevoContacto, esPrincipal: esPrincipal);
                        
                        if (context.mounted) Navigator.pop(context); 
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: const Text("GUARDAR CONTACTO", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }
}