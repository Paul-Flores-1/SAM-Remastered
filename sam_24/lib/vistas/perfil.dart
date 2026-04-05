import 'dart:math'; 
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sam_remastered/main.dart'; 

import '../services/contactos_service.dart';

class PantallaPerfil extends StatefulWidget {
  const PantallaPerfil({super.key});

  @override
  State<PantallaPerfil> createState() => _PantallaPerfilState();
}

class _PantallaPerfilState extends State<PantallaPerfil> {
  
  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text("Mi Perfil SAM", style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.transparent,
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
                      style: GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
                      textAlign: TextAlign.center,
                    ),
                    Text(email, style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey)),
                    
                    const SizedBox(height: 30),

                    // --- TARJETA MÉDICA (AHORA EDITABLE) ---
                    GestureDetector(
                      onTap: () => _mostrarModalMedico(context, user.uid, tipoSangre, alergias, isDark),
                      child: Container(
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
                        child: Stack(
                          children: [
                            Row(
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
                            // Iconito de editar en la esquina superior derecha
                            const Positioned(
                              top: 0, right: 0,
                              child: Icon(Icons.edit_rounded, color: Colors.white70, size: 20),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text("Toca la tarjeta médica para actualizar tus datos", style: TextStyle(color: Colors.grey, fontSize: 11)),
                    ),

                    const SizedBox(height: 30),

                    // CONTACTOS DE EMERGENCIA
                    _buildSeccion("Contactos de Emergencia", isDark),
                    _buildContactoItem(context, user.uid, "Contacto Principal", n1, t1, true, isDark),
                    _buildContactoItem(context, user.uid, "Contacto Secundario", n2, t2, false, isDark),

                    const SizedBox(height: 20),
                    
                    // DATOS DE CUENTA
                    _buildSeccion("Información de Cuenta", isDark),
                    _buildItemInfoEstatico(Icons.cake, "Fecha de Nacimiento", fechaNac, isDark),
                    _buildItemTelefonoEditable(context, user.uid, telefono, isDark),

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

  // ==========================================================
  // WIDGETS AUXILIARES DE LA INTERFAZ
  // ==========================================================

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

  Widget _buildItemInfoEstatico(IconData icon, String titulo, String dato, bool isDark) {
    return Card(
      elevation: 0,
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade200)),
      child: ListTile(
        leading: Icon(icon, color: Colors.grey),
        title: Text(titulo, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        subtitle: Text(dato, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: isDark ? Colors.white : Colors.black)),
      ),
    );
  }

  Widget _buildItemTelefonoEditable(BuildContext context, String uid, String telefonoActual, bool isDark) {
    return Card(
      elevation: 0,
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade200)),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () => _mostrarModalTelefono(context, uid, isDark),
        child: ListTile(
          leading: const Icon(Icons.smartphone, color: Colors.grey),
          title: const Text("Teléfono Personal (Toca para editar)", style: TextStyle(fontSize: 12, color: Colors.grey)),
          subtitle: Text(telefonoActual, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
          trailing: const Icon(Icons.edit_rounded, size: 20, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildContactoItem(BuildContext context, String uid, String titulo, String nombre, String telefono, bool esPrincipal, bool isDark) {
    return Card(
      elevation: 0,
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade200)),
      child: InkWell( 
        borderRadius: BorderRadius.circular(15),
        onTap: () => _mostrarModalContacto(context, uid, esPrincipal, nombre, telefono, titulo, isDark),
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


  // ==========================================================
  // MOTOR DE SEGURIDAD GLOBAL (CÓDIGO DE 6 DÍGITOS)
  // ==========================================================
  
  /// Esta función congela cualquier acción de guardado, pide el código por correo
  /// y solo ejecuta la actualización de Firebase si el usuario acierta el código.
  void _iniciarVerificacionYEjecutar(BuildContext context, String uid, bool isDark, Future<void> Function() funcionDeGuardado) async {
    // 1. Generamos un código de 6 dígitos
    String codigoGenerado = (100000 + Random().nextInt(900000)).toString();

    // 2. Lo guardamos en Firestore temporalmente
    await FirebaseFirestore.instance.collection('usuarios').doc(uid).update({
      'codigoSeguridad': codigoGenerado,
    });

    // 3. Abrimos la ventana emergente para que el usuario escriba el código
    if (context.mounted) {
      _mostrarDialogoVerificacion(context, uid, isDark, funcionDeGuardado);
    }
  }

  void _mostrarDialogoVerificacion(BuildContext context, String uid, bool isDark, Future<void> Function() funcionDeGuardado) {
    TextEditingController codigoCtrl = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false, 
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.security_rounded, color: Colors.orange),
              const SizedBox(width: 10),
              Expanded(child: Text("Verifica tu identidad", style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold, fontSize: 16))),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Ingresa el código de 6 dígitos que enviamos a tu correo electrónico para autorizar este cambio.",
                style: TextStyle(fontSize: 13, color: isDark ? Colors.grey[400] : Colors.grey[700]),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: codigoCtrl,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, letterSpacing: 10, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  counterText: "",
                  hintText: "000000",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                // Si cancela, limpiamos el código de la BD
                await FirebaseFirestore.instance.collection('usuarios').doc(uid).update({
                  'codigoSeguridad': FieldValue.delete(),
                });
                if (context.mounted) Navigator.pop(context); // Cierra este diálogo de verificación
              },
              child: const Text("CANCELAR", style: TextStyle(color: Colors.redAccent)),
            ),
            ElevatedButton(
              onPressed: () async {
                // Verificamos si el código ingresado coincide con el de la BD
                DocumentSnapshot doc = await FirebaseFirestore.instance.collection('usuarios').doc(uid).get();
                String codigoGuardado = doc['codigoSeguridad'] ?? '';

                if (codigoCtrl.text == codigoGuardado && codigoGuardado.isNotEmpty) {
                  // ¡ÉXITO! Borramos el código de seguridad
                  await FirebaseFirestore.instance.collection('usuarios').doc(uid).update({
                    'codigoSeguridad': FieldValue.delete(),
                  });
                  
                  if (context.mounted) Navigator.pop(context); // Cierra el diálogo de verificación

                  // EJECUTAMOS LA ACCIÓN PROTEGIDA (Ej. Actualizar alergias, teléfono, etc.)
                  await funcionDeGuardado(); 
                  
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("¡Perfil actualizado con éxito!"), backgroundColor: Colors.green));
                  }
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Código incorrecto, intenta de nuevo."), backgroundColor: Colors.red));
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
              child: const Text("VERIFICAR"),
            ),
          ],
        );
      }
    );
  }

  // ==========================================================
  // VENTANAS DE EDICIÓN (TODAS PROTEGIDAS POR EL MOTOR)
  // ==========================================================

  // 1. EDICIÓN DEL TELÉFONO PERSONAL
  void _mostrarModalTelefono(BuildContext context, String uid, bool isDark) {
    TextEditingController telefonoCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text("Nuevo Teléfono", style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 18, fontWeight: FontWeight.bold)),
          content: TextField(
            controller: telefonoCtrl,
            keyboardType: TextInputType.phone,
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
            decoration: InputDecoration(
              labelText: "Ingresa el nuevo número",
              prefixIcon: const Icon(Icons.phone_android),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("CANCELAR", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                if (telefonoCtrl.text.length < 10) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ingresa un número válido a 10 dígitos")));
                  return;
                }
                
                // Disparamos la seguridad
                _iniciarVerificacionYEjecutar(context, uid, isDark, () async {
                  await FirebaseFirestore.instance.collection('usuarios').doc(uid).update({
                    'telefono': telefonoCtrl.text,
                  });
                  if (context.mounted) Navigator.pop(context); // Cierra la ventana de editar teléfono
                });
              },
              style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary, foregroundColor: Colors.white),
              child: const Text("GUARDAR"),
            ),
          ],
        );
      }
    );
  }

  // 2. EDICIÓN DE CONTACTOS DE EMERGENCIA
  void _mostrarModalContacto(BuildContext context, String uid, bool esPrincipal, String nombreActual, String telActual, String titulo, bool isDark) {
    TextEditingController nombreCtrl = TextEditingController(text: nombreActual == 'No asignado' ? '' : nombreActual);
    TextEditingController telCtrl = TextEditingController(text: telActual == '--' ? '' : telActual);
    final ContactosService contactosService = ContactosService();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, 
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
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
              Center(child: Container(width: 40, height: 5, decoration: BoxDecoration(color: isDark ? Colors.grey.shade800 : Colors.grey.shade300, borderRadius: BorderRadius.circular(10)))),
              const SizedBox(height: 20),
              
              Text("Editar $titulo", style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
              const SizedBox(height: 20),
              
              TextField(
                controller: nombreCtrl,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(labelText: "Nombre del familiar", prefixIcon: const Icon(Icons.person_outline), border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
              ),
              const SizedBox(height: 15),

              TextField(
                controller: telCtrl,
                keyboardType: TextInputType.phone,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(labelText: "Número de Teléfono", prefixIcon: const Icon(Icons.phone_outlined), border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
              ),
              const SizedBox(height: 25),

              Row(
                children: [
                  if (nombreActual != 'No asignado')
                    Expanded(
                      flex: 1,
                      child: OutlinedButton(
                        onPressed: () {
                          // SEGURIDAD: Eliminar contacto
                          _iniciarVerificacionYEjecutar(context, uid, isDark, () async {
                            await contactosService.eliminarContacto(esPrincipal: esPrincipal);
                            if (context.mounted) Navigator.pop(context); 
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.redAccent, side: BorderSide(color: isDark ? Colors.redAccent.withValues(alpha: 0.5) : Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        child: const Icon(Icons.delete_outline),
                      ),
                    ),
                  
                  if (nombreActual != 'No asignado') const SizedBox(width: 10),

                  Expanded(
                    flex: 3,
                    child: ElevatedButton(
                      onPressed: () {
                        if (nombreCtrl.text.isEmpty || telCtrl.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Llena ambos campos")));
                          return;
                        }
                        
                        // SEGURIDAD: Guardar contacto modificado
                        _iniciarVerificacionYEjecutar(context, uid, isDark, () async {
                          ContactoEmergencia nuevoContacto = ContactoEmergencia(nombre: nombreCtrl.text, telefono: telCtrl.text);
                          await contactosService.guardarContacto(contacto: nuevoContacto, esPrincipal: esPrincipal);
                          if (context.mounted) Navigator.pop(context); 
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary, foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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

  // 3. EDICIÓN DE DATOS MÉDICOS (SANGRE Y ALERGIAS)
  void _mostrarModalMedico(BuildContext context, String uid, String sangreActual, String alergiasActual, bool isDark) {
    // Lista de tipos de sangre oficiales
    final List<String> tiposDeSangre = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-', 'N/A'];
    
    // Si por alguna razón la BD tiene un valor raro, lo seteamos a N/A para evitar crasheos
    String sangreSeleccionada = tiposDeSangre.contains(sangreActual) ? sangreActual : 'N/A';
    TextEditingController alergiasCtrl = TextEditingController(text: alergiasActual == 'Ninguna' ? '' : alergiasActual);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, 
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) {
        // StatefulBuilder nos permite actualizar el Dropdown en tiempo real dentro del BottomSheet
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24, right: 24, top: 24
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min, 
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Container(width: 40, height: 5, decoration: BoxDecoration(color: isDark ? Colors.grey.shade800 : Colors.grey.shade300, borderRadius: BorderRadius.circular(10)))),
                  const SizedBox(height: 20),
                  
                  Text("Información Médica", style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                  const SizedBox(height: 20),
                  
                  // Dropdown para el Tipo de Sangre
                  DropdownButtonFormField<String>(
                    initialValue: sangreSeleccionada,
                    dropdownColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 16),
                    decoration: InputDecoration(
                      labelText: "Tipo de Sangre",
                      prefixIcon: const Icon(Icons.water_drop_outlined, color: Colors.redAccent),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    items: tiposDeSangre.map((String valor) {
                      return DropdownMenuItem<String>(
                        value: valor,
                        child: Text(valor),
                      );
                    }).toList(),
                    onChanged: (String? nuevoValor) {
                      setModalState(() {
                        sangreSeleccionada = nuevoValor!;
                      });
                    },
                  ),

                  const SizedBox(height: 15),

                  // TextField para las Alergias
                  TextField(
                    controller: alergiasCtrl,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: "Alergias Conocidas (Opcional)",
                      hintText: "Ej. Penicilina, Nuez, etc.",
                      prefixIcon: const Icon(Icons.medical_information_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                  ),

                  const SizedBox(height: 25),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        // SEGURIDAD: Guardar información médica
                        _iniciarVerificacionYEjecutar(context, uid, isDark, () async {
                          await FirebaseFirestore.instance.collection('usuarios').doc(uid).update({
                            'tipoSangre': sangreSeleccionada,
                            'alergias': alergiasCtrl.text.trim().isEmpty ? 'Ninguna' : alergiasCtrl.text.trim(),
                          });
                          if (context.mounted) Navigator.pop(context); // Cierra modal
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700, foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: const Text("ACTUALIZAR FICHA MÉDICA", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            );
          }
        );
      },
    );
  }
}