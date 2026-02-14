import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// Importamos las otras pantallas para poder navegar
import 'package:sam_remastered/vistas/registro.dart';
import 'package:sam_remastered/vistas/principal.dart';

class PantallaLogin extends StatefulWidget {
  const PantallaLogin({super.key});

  @override
  State<PantallaLogin> createState() => _PantallaLoginState();
}

class _PantallaLoginState extends State<PantallaLogin> {
  // Controladores para capturar el texto
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _ocultarPassword = true; // Variable para el "ojito" de la contraseña

  // OPTIMIZACIÓN: Liberar memoria al salir de esta pantalla
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Obtenemos el tamaño de la pantalla para hacerlo responsivo
    final size = MediaQuery.of(context).size;
    final double alto = size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      // GESTURE DETECTOR: Cierra el teclado si tocas cualquier parte vacía
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: alto * 0.05),
      
                // --- 1. LOGO Y BIENVENIDA ---
                Image.asset(
                  "assets/images/logo samR.png",
                  height: alto * 0.12, // El logo ocupa el 12% de la altura
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
      
                // --- 2. CAMPOS DE TEXTO ---
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
                    // Botón del ojito
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
                    onPressed: () {
                      // Aquí iría la lógica de recuperación
                    },
                    child: const Text("¿Olvidaste tu contraseña?"),
                  ),
                ),
      
                SizedBox(height: alto * 0.05),
      
                // --- 3. BOTÓN INGRESAR ---
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      // AQUÍ CONECTAREMOS CON FIREBASE AUTH MÁS ADELANTE
                      debugPrint("Email: ${_emailController.text}");
                      debugPrint("Pass: ${_passwordController.text}");

                      // NAVEGACIÓN A LA PANTALLA PRINCIPAL (MAPA)
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const PantallaPrincipal()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary, // Azul SAM
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 5,
                    ),
                    child: const Text(
                      "INGRESAR",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
      
                const SizedBox(height: 20),
      
                // --- 4. SEPARADOR ---
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
      
                // --- 5. IR A REGISTRO ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("¿No tienes cuenta? ", style: TextStyle(fontSize: 16)),
                    GestureDetector(
                      onTap: () {
                        // Navegar a la pantalla de Registro
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const PantallaRegistro())
                        );
                      },
                      child: Text(
                        "Regístrate aquí",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary, // Naranja SAM
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