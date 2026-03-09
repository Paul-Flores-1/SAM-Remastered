import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sam_remastered/vistas/principal.dart';
import 'package:sam_remastered/main.dart'; 
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PantallaRegistro extends StatefulWidget {
  const PantallaRegistro({super.key});

  @override
  State<PantallaRegistro> createState() => _PantallaRegistroState();
}

class _PantallaRegistroState extends State<PantallaRegistro> {
  int _pasoActual = 0; 

  final _formKeyPersonal = GlobalKey<FormState>();
  final _formKeyMedico = GlobalKey<FormState>();
  final _formKeyContactos = GlobalKey<FormState>();

  final _nombreController = TextEditingController();
  final _emailController = TextEditingController(); 
  final _telefonoController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController(); 
  final _fechaNacController = TextEditingController();
  final _alergiasController = TextEditingController(); 
  
  final _contacto1NombreController = TextEditingController();
  final _contacto1TelController = TextEditingController();
  final _contacto2NombreController = TextEditingController();
  final _contacto2TelController = TextEditingController();

  String? _tipoSangreSeleccionado;
  String? _sexoSeleccionado;
  
  bool _ocultarPassword = true;
  final List<String> _listaAlergias = []; 

  final List<String> _tiposSangre = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
  final List<String> _sexos = ['Masculino', 'Femenino'];

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose(); 
    _fechaNacController.dispose();
    _alergiasController.dispose();
    _contacto1NombreController.dispose();
    _contacto1TelController.dispose();
    _contacto2NombreController.dispose();
    _contacto2TelController.dispose();
    super.dispose();
  }

  void _siguientePaso() {
    FocusScope.of(context).unfocus(); 
    
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
        setState(() => _pasoActual++);
      } else {
        _mostrarDialogoConfirmacion();
      }
    }
  }

  void _pasoAnterior() {
    FocusScope.of(context).unfocus(); 
    
    if (_pasoActual > 0) {
      setState(() => _pasoActual--);
    } else {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const OnboardingScreen()));
      }
    }
  }

  void _mostrarDialogoConfirmacion() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => DialogoConfirmacionRegistro(
        onConfirmar: _ejecutarRegistroFinal, 
      ),
    );
  }

  // ==========================================================
  // LÓGICA DE SEGURIDAD: VERIFICACIÓN POR CORREO (FIREBASE)
  // ==========================================================
  Future<void> _ejecutarRegistroFinal() async {
    // Pantalla de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // 1. Crear usuario con Correo y Contraseña
      UserCredential credenciales = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 2. Enviar el correo de verificación nativo de Firebase
      await credenciales.user!.sendEmailVerification();

      // 3. Subir datos a Firestore
      String uid = credenciales.user!.uid; 
      await FirebaseFirestore.instance.collection('usuarios').doc(uid).set({
        'nombre': _nombreController.text.trim(),
        'email': _emailController.text.trim(),
        'telefono': _telefonoController.text.trim(),
        'fechaNacimiento': _fechaNacController.text.trim(),
        'sexo': _sexoSeleccionado,
        'tipoSangre': _tipoSangreSeleccionado,
        'alergias': _listaAlergias.isEmpty ? 'Ninguna' : _listaAlergias.join(", "),
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

      if (mounted) Navigator.pop(context); // Quita el loading inicial

      // 4. Mostrar el nuevo diálogo bloqueante para que confirme el correo
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => DialogoEsperandoVerificacion(
            email: _emailController.text.trim(),
          ),
        );
      }

    } on FirebaseAuthException catch (e) {
      if (mounted) Navigator.pop(context); 
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${e.message}"), backgroundColor: Colors.red));
    }
  }


  Widget _obtenerVistaPasoActual() {
    if (_pasoActual == 0) return Container(key: const ValueKey(0), child: _buildPaso1Personal());
    if (_pasoActual == 1) return Container(key: const ValueKey(1), child: _buildPaso2Medico());
    return Container(key: const ValueKey(2), child: _buildPaso3Contactos());
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _pasoActual == 0, 
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _pasoAnterior(); 
      },
      child: Scaffold(
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
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20), onPressed: _pasoAnterior),
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOutCubic,
                      child: LinearProgressIndicator(
                        value: (_pasoActual + 1) / 3,
                        backgroundColor: Colors.grey.shade200,
                        color: Theme.of(context).colorScheme.secondary,
                        minHeight: 8, 
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350), 
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(begin: const Offset(0.02, 0.0), end: Offset.zero).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: _obtenerVistaPasoActual(),
                  ),
                ),

                Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))]
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
                        style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
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
            
            _buildCampoTexto(_nombreController, "Nombre Completo", Icons.person_rounded, maximo: 40),
            const SizedBox(height: 20),
            _buildCampoTexto(
              _emailController, 
              "Correo Electrónico", 
              Icons.email_rounded, 
              tipoTeclado: TextInputType.emailAddress, 
              validadorExtra: (valor) {
                // Validación de formato de correo real
                final RegExp emailRegex = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9-]+\.[a-zA-Z]+");
                if (!emailRegex.hasMatch(valor!.trim())) {
                  return 'Ingresa un correo válido';
                }
                // Validación de longitud (máximo 30 caracteres antes del @)
                final partes = valor.trim().split('@');
                if (partes[0].length > 30) {
                  return 'Máximo 30 caracteres antes del @';
                }
                return null;
              }
            ),
            const SizedBox(height: 20),
            
            _buildCampoTexto(_telefonoController, "Número de Celular", Icons.phone_android_rounded, tipoTeclado: TextInputType.phone, maximo: 10),
            const SizedBox(height: 20),
            
            _buildCampoTexto(
              _passwordController, 
              "Contraseña (Mín. 9 + Letra + Símbolo)", 
              Icons.lock_rounded, 
              esPassword: true, 
              maximo: 30,
              validadorExtra: (valor) {
                if (valor!.length < 9) return 'Mínimo 9 caracteres';
                if (!RegExp(r'[a-zA-Z]').hasMatch(valor)) return 'Debe incluir al menos una letra';
                if (!RegExp(r'[^a-zA-Z0-9]').hasMatch(valor)) return 'Debe incluir al menos un símbolo';
                return null;
              }
            ),
            const SizedBox(height: 20),
            
            _buildCampoTexto(
              _confirmPasswordController, 
              "Confirmar Contraseña", 
              Icons.lock_clock_rounded, 
              esPassword: true,
              maximo: 30,
              validadorExtra: (valor) {
                if (valor != _passwordController.text) return 'Las contraseñas no coinciden';
                return null;
              }
            ),
            const SizedBox(height: 20),
            
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _seleccionarFecha(context),
                    child: AbsorbPointer(child: _buildCampoTexto(_fechaNacController, "Nacimiento", Icons.cake_rounded)),
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
            
            const Text("Alergias o Condiciones (Opcional)", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 10),
            
            Row(
              children: [
                Expanded(
                  child: _buildCampoTexto(_alergiasController, "Ej. Penicilina, Asma...", Icons.medical_information_rounded, maximo: 50),
                ),
                const SizedBox(width: 10),
                Container(
                  decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, borderRadius: BorderRadius.circular(15)),
                  child: IconButton(
                    icon: const Icon(Icons.add_rounded, color: Colors.white),
                    onPressed: () {
                      if (_alergiasController.text.trim().isNotEmpty && _listaAlergias.length < 10) {
                        setState(() {
                          _listaAlergias.add(_alergiasController.text.trim());
                          _alergiasController.clear();
                        });
                      }
                    },
                  ),
                )
              ],
            ),
            const SizedBox(height: 15),

            Wrap(
              spacing: 8.0, 
              runSpacing: 4.0, 
              children: _listaAlergias.map((alergia) {
                return Chip(
                  label: Text(alergia, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
                  backgroundColor: Colors.red.shade50,
                  side: BorderSide(color: Colors.red.shade200),
                  deleteIconColor: Colors.red.shade700,
                  onDeleted: () => setState(() => _listaAlergias.remove(alergia)),
                );
              }).toList(),
            ),
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
            _buildCampoTexto(_contacto1NombreController, "Nombre (Ej. Mamá)", Icons.person_outline_rounded, maximo: 40),
            const SizedBox(height: 15),
            _buildCampoTexto(_contacto1TelController, "Teléfono", Icons.phone_rounded, tipoTeclado: TextInputType.phone, maximo: 10),

            const SizedBox(height: 35),

            _buildSubtitulo("Contacto Secundario"),
            const SizedBox(height: 15),
            _buildCampoTexto(_contacto2NombreController, "Nombre", Icons.person_outline_rounded, maximo: 40),
            const SizedBox(height: 15),
            _buildCampoTexto(_contacto2TelController, "Teléfono", Icons.phone_rounded, tipoTeclado: TextInputType.phone, maximo: 10),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS AUXILIARES ---

  Widget _buildTitulo(String texto) {
    return Text(texto, style: GoogleFonts.montserrat(fontSize: 28, fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.primary, letterSpacing: -0.5));
  }

  Widget _buildSubtitulo(String texto) {
    return Text(texto, style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87));
  }

  Widget _buildCampoTexto(TextEditingController controller, String label, IconData icono, {bool esPassword = false, TextInputType tipoTeclado = TextInputType.text, int lineas = 1, String? Function(String?)? validadorExtra, int? maximo}) {
    return TextFormField(
      controller: controller,
      obscureText: esPassword ? _ocultarPassword : false, 
      keyboardType: tipoTeclado, 
      maxLines: lineas,
      maxLength: maximo, 
      style: const TextStyle(fontWeight: FontWeight.w500),
      validator: (value) {
        if (label.contains("Opcional") || label.contains("Ej. Penicilina")) return null;
        if (value == null || value.trim().isEmpty) return 'Obligatorio';
        
        // Esta validación ya se encarga de obligar a que sean exactamente 10 dígitos 
        // para cualquier campo que sea tipo teléfono (tanto el tuyo como el de tus contactos)
        if (tipoTeclado == TextInputType.phone) {
          if (!RegExp(r'^[0-9]{10}$').hasMatch(value.trim())) return 'Ingresa exactamente 10 números';
        }

        if (validadorExtra != null) return validadorExtra(value);
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade600),
        prefixIcon: Icon(icono, color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7)),
        counterText: "", 
        suffixIcon: esPassword ? IconButton(
          icon: Icon(_ocultarPassword ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: Colors.grey.shade600),
          onPressed: () => setState(() => _ocultarPassword = !_ocultarPassword),
        ) : null,
        filled: true,
        fillColor: Colors.grey.shade100, 
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.red.shade300, width: 1)),
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
      items: _tiposSangre.map((String sangre) => DropdownMenuItem(value: sangre, child: Text(sangre, style: const TextStyle(fontWeight: FontWeight.w500)))).toList(),
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
      items: _sexos.map((String sexo) => DropdownMenuItem(value: sexo, child: Text(sexo, style: const TextStyle(fontWeight: FontWeight.w500)))).toList(),
      onChanged: (val) => setState(() => _sexoSeleccionado = val),
      validator: (val) => val == null ? 'Requerido' : null,
    );
  }

  Future<void> _seleccionarFecha(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context, initialDate: DateTime(2000), firstDate: DateTime(1950), lastDate: DateTime.now(),
      builder: (context, child) => Theme(data: Theme.of(context).copyWith(colorScheme: ColorScheme.light(primary: Theme.of(context).colorScheme.primary)), child: child!),
    );
    if (picked != null) setState(() => _fechaNacController.text = "${picked.day}/${picked.month}/${picked.year}");
  }
}

// WIDGET 1: Cuadro de Confirmación de Datos
class DialogoConfirmacionRegistro extends StatefulWidget {
  final VoidCallback onConfirmar;
  const DialogoConfirmacionRegistro({super.key, required this.onConfirmar});

  @override
  State<DialogoConfirmacionRegistro> createState() => _DialogoConfirmacionRegistroState();
}

class _DialogoConfirmacionRegistroState extends State<DialogoConfirmacionRegistro> {
  int _segundos = 5;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_segundos > 0) {
        setState(() => _segundos--);
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 30), const SizedBox(width: 10),
          Expanded(child: Text("¿Datos correctos?", style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 18))),
        ],
      ),
      content: const Text("Tus contactos y perfil médico deben ser precisos. Te enviaremos un enlace a tu correo electrónico para verificar la cuenta.", style: TextStyle(fontSize: 14, height: 1.5)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("REVISAR DATOS", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
        ElevatedButton(
          onPressed: _segundos == 0 ? () { Navigator.pop(context); widget.onConfirmar(); } : null,
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A237E), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
          child: Text(_segundos > 0 ? "CONFIRMAR EN $_segundos..." : "SÍ, CREAR CUENTA", style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}

// WIDGET 2: Nuevo Cuadro Esperando Verificación
class DialogoEsperandoVerificacion extends StatefulWidget {
  final String email;
  const DialogoEsperandoVerificacion({super.key, required this.email});

  @override
  State<DialogoEsperandoVerificacion> createState() => _DialogoEsperandoVerificacionState();
}

class _DialogoEsperandoVerificacionState extends State<DialogoEsperandoVerificacion> {
  bool _verificando = false;

  Future<void> _comprobarVerificacion() async {
    setState(() => _verificando = true);
    
    User? usuarioActual = FirebaseAuth.instance.currentUser;
    await usuarioActual?.reload(); 
    
    usuarioActual = FirebaseAuth.instance.currentUser;

    setState(() => _verificando = false);

    if (usuarioActual != null && usuarioActual.emailVerified) {
      if (mounted) {
        Navigator.pop(context); 
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const PantallaPrincipal()), (route) => false);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Aún no detectamos la confirmación. Por favor, revisa tu bandeja de entrada o spam."),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 4),
          )
        );
      }
    }
  }

  Future<void> _hacerloMasTarde() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pop(context);
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const OnboardingScreen()), (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Column(
        children: [
          const Icon(Icons.mark_email_unread_rounded, color: Color(0xFF1A237E), size: 50),
          const SizedBox(height: 15),
          Text("¡Verifica tu correo!", style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 20), textAlign: TextAlign.center),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Hemos enviado un enlace a:", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade700)),
          const SizedBox(height: 5),
          Text(widget.email, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 15),
          const Text("Abre tu correo, haz clic en el enlace y luego presiona el botón de abajo.", textAlign: TextAlign.center, style: TextStyle(fontSize: 14)),
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _verificando ? null : _comprobarVerificacion,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A237E), 
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
              ),
              child: _verificando 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text("YA HE CONFIRMADO EL CORREO", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            TextButton(
              onPressed: _verificando ? null : _hacerloMasTarde, 
              child: const Text("Lo haré más tarde", style: TextStyle(color: Colors.grey))
            ),
          ],
        )
      ],
    );
  }
}