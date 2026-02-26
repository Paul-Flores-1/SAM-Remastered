import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sam_remastered/vistas/principal.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PantallaRegistro extends StatefulWidget {
  const PantallaRegistro({super.key});

  @override
  State<PantallaRegistro> createState() => _PantallaRegistroState();
}

class _PantallaRegistroState extends State<PantallaRegistro> {
  // CONTROL DE PASOS
  final PageController _pageController = PageController();
  int _pasoActual = 0; 

  // Claves para validar
  final _formKeyPersonal = GlobalKey<FormState>();
  final _formKeyMedico = GlobalKey<FormState>();
  final _formKeyContactos = GlobalKey<FormState>();

  // CONTROLADORES 
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController(); 
  final _telefonoController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fechaNacController = TextEditingController();
  final _alergiasController = TextEditingController();
  
  final _contacto1NombreController = TextEditingController();
  final _contacto1TelController = TextEditingController();
  final _contacto2NombreController = TextEditingController();
  final _contacto2TelController = TextEditingController();

  String? _tipoSangreSeleccionado;
  String? _sexoSeleccionado;

  final List<String> _tiposSangre = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
  final List<String> _sexos = ['Masculino', 'Femenino'];

  @override
  void dispose() {
    _pageController.dispose();
    _nombreController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    _passwordController.dispose();
    _fechaNacController.dispose();
    _alergiasController.dispose();
    _contacto1NombreController.dispose();
    _contacto1TelController.dispose();
    _contacto2NombreController.dispose();
    _contacto2TelController.dispose();
    super.dispose();
  }

  void _siguientePaso() {
    bool esValido = false;
    if (_pasoActual == 0) {
      esValido = _formKeyPersonal.currentState!.validate();
    } else if (_pasoActual == 1) {
      esValido = _formKeyMedico.currentState!.validate();
    } else if (_pasoActual == 2) {
      esValido = _formKeyContactos.currentState!.validate();
    }

    if (esValido) {
      if (_pasoActual < 2) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic, 
        );
        setState(() => _pasoActual++);
      } else {
        _registrarUsuario(); // Llama a la funcion de Firebase
      }
    }
  }

  void _pasoAnterior() {
    if (_pasoActual > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
      setState(() => _pasoActual--);
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Paso ${_pasoActual + 1} de 3", 
          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 18)
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: _pasoAnterior,
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: Column(
            children: [
              //BARRA DE PROGRESO
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: (_pasoActual + 1) / 3,
                    backgroundColor: Colors.grey.shade200,
                    color: Theme.of(context).colorScheme.secondary,
                    minHeight: 8, 
                  ),
                ),
              ),

              //CONTENIDO DESLIZABLE
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(), 
                  children: [
                    _buildPaso1Personal(),
                    _buildPaso2Medico(),
                    _buildPaso3Contactos(),
                  ],
                ),
              ),

              //BOTÓN INFERIOR
              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    )
                  ]
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _siguientePaso,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), 
                      elevation: 0, 
                    ),
                    child: Text(
                      _pasoActual == 2 ? "FINALIZAR REGISTRO" : "CONTINUAR",
                      style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- VISTAS POR PASOS ---

  Widget _buildPaso1Personal() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
      child: Form(
        key: _formKeyPersonal,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitulo("Tus Datos"),
            const Text("Comencemos con lo básico para crear tu perfil.", style: TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 30),
            
            _buildCampoTexto(_nombreController, "Nombre Completo", Icons.person_rounded),
            const SizedBox(height: 20),
            _buildCampoTexto(_emailController, "Correo Electrónico", Icons.email_rounded, tipoTeclado: TextInputType.emailAddress),
            const SizedBox(height: 20),
            // MODIFICACIÓN AQUI: Teclado de teléfono
            _buildCampoTexto(_telefonoController, "Número de Celular", Icons.phone_android_rounded, tipoTeclado: TextInputType.phone),
            const SizedBox(height: 20),
            _buildCampoTexto(_passwordController, "Contraseña", Icons.lock_rounded, esPassword: true),
            const SizedBox(height: 20),
            
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _seleccionarFecha(context),
                    child: AbsorbPointer(
                      child: _buildCampoTexto(_fechaNacController, "Nacimiento", Icons.cake_rounded),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(child: _buildDropdownSexo()),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildPaso2Medico() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
      child: Form(
        key: _formKeyMedico,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitulo("Perfil Médico"),
            const Text("Información vital en caso de una emergencia.", style: TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 30),

            _buildDropdownSangre(),
            const SizedBox(height: 20),
            _buildCampoTexto(_alergiasController, "Alergias o Condiciones (Opcional)", Icons.medical_information_rounded, lineas: 4),
          ],
        ),
      ),
    );
  }

  Widget _buildPaso3Contactos() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
      child: Form(
        key: _formKeyContactos,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitulo("Red de Apoyo"),
            const Text("Notificaremos a estas personas automáticamente si detectamos un incidente.", style: TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 30),

            _buildSubtitulo("Contacto Principal"),
            const SizedBox(height: 15),
            _buildCampoTexto(_contacto1NombreController, "Nombre (Ej. Mamá)", Icons.person_outline_rounded),
            const SizedBox(height: 15),
            // MODIFICACIÓN AQUI: Teclado de teléfono
            _buildCampoTexto(_contacto1TelController, "Teléfono", Icons.phone_rounded, tipoTeclado: TextInputType.phone),

            const SizedBox(height: 35),

            _buildSubtitulo("Contacto Secundario"),
            const SizedBox(height: 15),
            _buildCampoTexto(_contacto2NombreController, "Nombre", Icons.person_outline_rounded),
            const SizedBox(height: 15),
            // MODIFICACIÓN AQUI: Teclado de teléfono
            _buildCampoTexto(_contacto2TelController, "Teléfono", Icons.phone_rounded, tipoTeclado: TextInputType.phone),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS AUXILIARES REDISEÑADOS ---

  Widget _buildTitulo(String texto) {
    return Text(
      texto,
      style: GoogleFonts.montserrat(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: Theme.of(context).colorScheme.primary,
        letterSpacing: -0.5,
      ),
    );
  }

  Widget _buildSubtitulo(String texto) {
    return Text(
      texto,
      style: GoogleFonts.montserrat(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildCampoTexto(TextEditingController controller, String label, IconData icono, {bool esPassword = false, TextInputType tipoTeclado = TextInputType.text, int lineas = 1}) {
    return TextFormField(
      controller: controller,
      obscureText: esPassword,
      keyboardType: tipoTeclado, // <- Aquí aplica el tipo de teclado numérico si se pasa
      maxLines: lineas,
      style: const TextStyle(fontWeight: FontWeight.w500),
      validator: (value) {
        if (label.contains("Opcional")) return null;
        if (value == null || value.isEmpty) return 'Este campo es necesario';
        // Validación básica extra para teléfono
        if (tipoTeclado == TextInputType.phone && value.length < 10) {
           return 'Ingresa al menos 10 dígitos';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade600),
        prefixIcon: Icon(icono, color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7)),
        filled: true,
        fillColor: Colors.grey.shade100, 
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none, 
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.red.shade300, width: 1),
        ),
      ),
    );
  }

  Widget _buildDropdownSangre() {
    return DropdownButtonFormField<String>(
      initialValue: _tipoSangreSeleccionado, 
      icon: const Icon(Icons.keyboard_arrow_down_rounded),
      decoration: InputDecoration(
        labelText: "Tipo de Sangre",
        labelStyle: TextStyle(color: Colors.grey.shade600),
        prefixIcon: const Icon(Icons.bloodtype_rounded, color: Colors.redAccent),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5)),
      ),
      items: _tiposSangre.map((String sangre) {
        return DropdownMenuItem(value: sangre, child: Text(sangre, style: const TextStyle(fontWeight: FontWeight.w500)));
      }).toList(),
      onChanged: (val) => setState(() => _tipoSangreSeleccionado = val),
      validator: (val) => val == null ? 'Selecciona uno' : null,
    );
  }

  Widget _buildDropdownSexo() {
    return DropdownButtonFormField<String>(
      initialValue: _sexoSeleccionado, 
      icon: const Icon(Icons.keyboard_arrow_down_rounded),
      decoration: InputDecoration(
        labelText: "Sexo",
        labelStyle: TextStyle(color: Colors.grey.shade600),
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 18),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5)),
      ),
      items: _sexos.map((String sexo) {
        return DropdownMenuItem(value: sexo, child: Text(sexo, style: const TextStyle(fontWeight: FontWeight.w500)));
      }).toList(),
      onChanged: (val) => setState(() => _sexoSeleccionado = val),
      validator: (val) => val == null ? 'Requerido' : null,
    );
  }

  Future<void> _seleccionarFecha(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _fechaNacController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  // --- FUNCIÓN REAL DE REGISTRO EN FIREBASE ---
  Future<void> _registrarUsuario() async {
    // 1. Mostrar un indicador de carga en la pantalla
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // 2. CREAR EL USUARIO EN FIREBASE AUTH
      UserCredential credenciales = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 3. GUARDAR EL PERFIL MÉDICO EN FIRESTORE
      String uid = credenciales.user!.uid; 
      
      await FirebaseFirestore.instance.collection('usuarios').doc(uid).set({
        'nombre': _nombreController.text.trim(),
        'email': _emailController.text.trim(),
        'telefono': _telefonoController.text.trim(),
        'fechaNacimiento': _fechaNacController.text.trim(),
        'sexo': _sexoSeleccionado,
        'tipoSangre': _tipoSangreSeleccionado,
        'alergias': _alergiasController.text.trim(),
        'contactoPrincipal': {
          'nombre': _contacto1NombreController.text.trim(),
          'telefono': _contacto1TelController.text.trim(),
        },
        'contactoSecundario': {
          'nombre': _contacto2NombreController.text.trim(),
          'telefono': _contacto2TelController.text.trim(),
        },
        'fechaRegistro': FieldValue.serverTimestamp(), 
      });

      // 4. Quitar el circulo de carga
      if (mounted) Navigator.pop(context);

      // 5. Mostrar mensaje de éxito y Navegar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 10),
                Text("¡Cuenta creada y datos guardados!", style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const PantallaPrincipal()),
          (route) => false, 
        );
      }

    } on FirebaseAuthException catch (e) {
      // Si falla Firebase Auth (ej. contraseña corta, correo repetido)
      if (mounted) Navigator.pop(context); // Quitar carga
      
      String mensajeError = "Ocurrió un error al registrarse.";
      if (e.code == 'weak-password') {
        mensajeError = 'La contraseña es muy débil (Mínimo 6 caracteres).';
      } else if (e.code == 'email-already-in-use') {
        mensajeError = 'Este correo ya está registrado en otra cuenta.';
      } else if (e.code == 'invalid-email') {
        mensajeError = 'El formato del correo no es válido.';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(mensajeError), backgroundColor: Colors.red.shade600),
        );
      }
    } catch (e) {
      // Si falla Firestore o el internet
      if (mounted) Navigator.pop(context); 
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error de conexión: $e"), backgroundColor: Colors.red.shade600),
        );
      }
    }
  }
}