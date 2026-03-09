import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sam_remastered/vistas/principal.dart';
import 'package:sam_remastered/vistas/terminos.dart';

// IMPORTANTE: Agregamos Firebase Auth
import 'package:firebase_auth/firebase_auth.dart';

class PantallaLogin extends StatefulWidget {
  const PantallaLogin({super.key});

  @override
  State<PantallaLogin> createState() => _PantallaLoginState();
}

class _PantallaLoginState extends State<PantallaLogin> {
  
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _ocultarPassword = true; 

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ==========================================================
  // LÓGICA DE INICIO DE SESIÓN CON FIREBASE
  // ==========================================================
  Future<void> _iniciarSesion() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // 1. Validar que no envíen campos vacíos
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor, ingresa tu correo y contraseña."), backgroundColor: Colors.orange),
      );
      return;
    }

    // 2. Pantalla de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: Color(0xFF1A237E))),
    );

    try {
      // 3. Petición a Firebase
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Si fue exitoso, cerramos la carga y vamos al Mapa
      if (mounted) Navigator.pop(context);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const PantallaPrincipal()),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) Navigator.pop(context); // Cerramos la carga si hay error
      
      // Manejo de errores amigable para el usuario
      String mensajeError = "Ocurrió un error al iniciar sesión.";
      if (e.code == 'invalid-credential' || e.code == 'user-not-found' || e.code == 'wrong-password') {
        mensajeError = 'Correo o contraseña incorrectos.';
      } else if (e.code == 'invalid-email') {
        mensajeError = 'El formato del correo no es válido.';
      } else if (e.code == 'user-disabled') {
        mensajeError = 'Esta cuenta ha sido deshabilitada.';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(mensajeError), backgroundColor: Colors.red.shade600),
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error de conexión: $e"), backgroundColor: Colors.red.shade600),
        );
      }
    }
  }

  // ==========================================================
  // LÓGICA DE RECUPERACIÓN DE CONTRASEÑA
  // ==========================================================
  Future<void> _recuperarPassword() async {
    final email = _emailController.text.trim();
    
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Escribe tu correo arriba y presiona este botón para enviarte un enlace de recuperación."), backgroundColor: Colors.orange),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("¡Correo de recuperación enviado! Revisa tu bandeja de entrada o spam."), 
            backgroundColor: Colors.green.shade600
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error al enviar el correo. Verifica que esté bien escrito."), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    
    final size = MediaQuery.of(context).size;
    final double alto = size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: alto * 0.05),
      
                // LOGO Y BIENVENIDA
                Image.asset(
                  "assets/images/logo samR.png",
                  height: alto * 0.12, 
                  fit: BoxFit.contain,
                  gaplessPlayback: true,
                ),
                const SizedBox(height: 20),
                Text(
                  "Bienvenido a SAM",
                  style: GoogleFonts.montserrat(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const Text(
                  "Inicia sesión para continuar",
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
      
                SizedBox(height: alto * 0.08),
      
                // Email
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: "Correo Electrónico",
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
      
                // Contraseña
                TextField(
                  controller: _passwordController,
                  obscureText: _ocultarPassword,
                  decoration: InputDecoration(
                    labelText: "Contraseña",
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _ocultarPassword ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _ocultarPassword = !_ocultarPassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
      
                // Link de Olvidé contraseña
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _recuperarPassword, // AHORA ESTÁ CONECTADO A FIREBASE
                    child: const Text("¿Olvidaste tu contraseña?"),
                  ),
                ),
      
                SizedBox(height: alto * 0.05),
      
                // BOTÓN INGRESAR
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _iniciarSesion, // CONECTADO A LA FUNCIÓN DE ARRIBA
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 5,
                    ),
                    child: const Text(
                      "INGRESAR",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
      
                const SizedBox(height: 20),
      
                //SEPARADOR
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text("O", style: TextStyle(color: Colors.grey[600])),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
      
                const SizedBox(height: 20),
      
                //IR A REGISTRO
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("¿No tienes cuenta? ", style: TextStyle(fontSize: 16)),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const PantallaTerminos())
                        );
                      },
                      child: Text(
                        "Regístrate aquí",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}