import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PantallaRegistro extends StatefulWidget {
  const PantallaRegistro({super.key});

  @override
  State<PantallaRegistro> createState() => _PantallaRegistroState();
}

class _PantallaRegistroState extends State<PantallaRegistro> {
  // Clave para validar el formulario
  final _formKey = GlobalKey<FormState>();

  // --- CONTROLADORES (Para capturar el texto) ---
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController(); 
  final _telefonoController = TextEditingController(); // NUEVO: Tu número
  final _passwordController = TextEditingController();
  final _fechaNacController = TextEditingController();
  final _alergiasController = TextEditingController();
  
  // Contactos de Emergencia
  final _contacto1NombreController = TextEditingController();
  final _contacto1TelController = TextEditingController();
  final _contacto2NombreController = TextEditingController();
  final _contacto2TelController = TextEditingController();

  // Variables para los Dropdowns (Selectores)
  String? _tipoSangreSeleccionado;
  String? _sexoSeleccionado;

  // Listas de opciones
  final List<String> _tiposSangre = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
  final List<String> _sexos = ['Masculino', 'Femenino'];

  // OPTIMIZACIÓN 1: Liberar los 10 controladores de memoria
  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _telefonoController.dispose(); // NUEVO
    _passwordController.dispose();
    _fechaNacController.dispose();
    _alergiasController.dispose();
    _contacto1NombreController.dispose();
    _contacto1TelController.dispose();
    _contacto2NombreController.dispose();
    _contacto2TelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Crear Cuenta SAM", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Theme.of(context).colorScheme.primary, // Icono de atrás azul
        elevation: 0,
      ),
      // OPTIMIZACIÓN 2: Cerrar teclado al tocar fuera
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitulo("Datos Personales"),
                  
                  // Nombre Completo
                  _buildCampoTexto(_nombreController, "Nombre Completo", Icons.person),
                  const SizedBox(height: 15),
      
                  // Email
                  _buildCampoTexto(_emailController, "Correo Electrónico", Icons.email, tipoTeclado: TextInputType.emailAddress),
                  const SizedBox(height: 15),

                  // NUEVO: Tu Teléfono
                  _buildCampoTexto(_telefonoController, "Tu Número de Celular", Icons.phone_android, tipoTeclado: TextInputType.phone),
                  const SizedBox(height: 15),

                  // Contraseña
                  _buildCampoTexto(_passwordController, "Contraseña", Icons.lock, esPassword: true),
      
                  const SizedBox(height: 15),
      
                  // Fila: Fecha Nacimiento y Sexo
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _seleccionarFecha(context),
                          child: AbsorbPointer( // Evita que salga el teclado
                            child: _buildCampoTexto(_fechaNacController, "Fecha Nac.", Icons.calendar_today),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _buildDropdownSexo(),
                      ),
                    ],
                  ),
      
                  const SizedBox(height: 30),
                  _buildTitulo("Información Médica (Para Emergencias)"),
                  
                  // Tipo de Sangre
                  _buildDropdownSangre(),
                  const SizedBox(height: 15),
                  
                  // Alergias
                  _buildCampoTexto(_alergiasController, "Alergias o Padecimientos (Opcional)", Icons.medical_services, lineas: 2),
      
                  const SizedBox(height: 30),
                  _buildTitulo("Contactos de Emergencia"),
                  const Text("Avisaremos a estas personas si el sensor detecta un accidente.", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 15),
      
                  // Contacto 1
                  const Text("Contacto Principal", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Expanded(flex: 2, child: _buildCampoTexto(_contacto1NombreController, "Nombre", Icons.person_outline)),
                      const SizedBox(width: 10),
                      Expanded(flex: 3, child: _buildCampoTexto(_contacto1TelController, "Teléfono", Icons.phone, tipoTeclado: TextInputType.phone)),
                    ],
                  ),
      
                  const SizedBox(height: 15),
      
                  // Contacto 2
                  const Text("Contacto Secundario", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Expanded(flex: 2, child: _buildCampoTexto(_contacto2NombreController, "Nombre", Icons.person_outline)),
                      const SizedBox(width: 10),
                      Expanded(flex: 3, child: _buildCampoTexto(_contacto2TelController, "Teléfono", Icons.phone, tipoTeclado: TextInputType.phone)),
                    ],
                  ),
      
                  const SizedBox(height: 40),
      
                  // BOTÓN REGISTRAR
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _registrarUsuario,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        elevation: 5,
                      ),
                      child: const Text("TERMINAR REGISTRO", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGETS AUXILIARES (Para no repetir código) ---

  Widget _buildTitulo(String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Text(
        texto,
        style: GoogleFonts.montserrat(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.secondary, // Naranja
        ),
      ),
    );
  }

  Widget _buildCampoTexto(TextEditingController controller, String label, IconData icono, {bool esPassword = false, TextInputType tipoTeclado = TextInputType.text, int lineas = 1}) {
    return TextFormField(
      controller: controller,
      obscureText: esPassword,
      keyboardType: tipoTeclado,
      maxLines: lineas,
      validator: (value) {
        if (value == null || value.isEmpty) return 'Campo requerido';
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icono, color: Colors.grey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      ),
    );
  }

  Widget _buildDropdownSangre() {
    return DropdownButtonFormField<String>(
      value: _tipoSangreSeleccionado,
      decoration: InputDecoration(
        labelText: "Tipo de Sangre",
        prefixIcon: const Icon(Icons.bloodtype, color: Colors.red),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      ),
      items: _tiposSangre.map((String sangre) {
        return DropdownMenuItem(value: sangre, child: Text(sangre));
      }).toList(),
      onChanged: (val) => setState(() => _tipoSangreSeleccionado = val),
      validator: (val) => val == null ? 'Selecciona uno' : null,
    );
  }

  Widget _buildDropdownSexo() {
    return DropdownButtonFormField<String>(
      value: _sexoSeleccionado,
      decoration: InputDecoration(
        labelText: "Sexo",
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      ),
      items: _sexos.map((String sexo) {
        return DropdownMenuItem(value: sexo, child: Text(sexo));
      }).toList(),
      onChanged: (val) => setState(() => _sexoSeleccionado = val),
      validator: (val) => val == null ? 'Requerido' : null,
    );
  }

  // --- LÓGICA ---

  Future<void> _seleccionarFecha(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        // Formato simple DD/MM/AAAA
        _fechaNacController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  void _registrarUsuario() {
    if (_formKey.currentState!.validate()) {
      // AQUÍ SE ENVIARÁN LOS DATOS A FIREBASE
      debugPrint("Registrando a: ${_nombreController.text}");
      debugPrint("Teléfono: ${_telefonoController.text}"); // NUEVO
      debugPrint("Sangre: $_tipoSangreSeleccionado");
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Procesando registro...")),
      );
    }
  }
}