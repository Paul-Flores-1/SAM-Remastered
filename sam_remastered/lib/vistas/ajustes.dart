import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sam_remastered/vistas/perfil.dart';
import 'package:sam_remastered/vistas/privacidad.dart';
import 'package:sam_remastered/vistas/terminos.dart';

// --- NUEVOS IMPORTS PARA CERRAR SESIÓN ---
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sam_remastered/main.dart'; 

class PantallaAjustes extends StatefulWidget {
  const PantallaAjustes({super.key});

  @override
  State<PantallaAjustes> createState() => _PantallaAjustesState();
}

class _PantallaAjustesState extends State<PantallaAjustes> {
  // --- VARIABLES DE ESTADO PARA LOS AJUSTES ---
  bool _temaOscuro = false;
  bool _sistemaMetrico = true; // true = Km/h, false = Mph

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], 
      appBar: AppBar(
        title: Text(
          "Configuración", 
          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 18)
        ),
        centerTitle: true,
        backgroundColor: Colors.grey[50],
        foregroundColor: const Color(0xFF1A237E),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // --- GRUPO 1: PREFERENCIAS (NUEVO) ---
            _buildTituloSeccion("Preferencias"),
            _buildTarjetaGrupo(
              children: [
                _buildItemSwitch(
                  titulo: "Tema Oscuro", 
                  subtitulo: "Cambiar la apariencia de la aplicación",
                  icono: Icons.dark_mode_rounded, 
                  colorIcono: Colors.deepPurple,
                  valor: _temaOscuro,
                  onChanged: (val) {
                    setState(() => _temaOscuro = val);
                    // Aquí iría la lógica para cambiar el Theme de tu MaterialApp
                  }
                ),
                _buildDivider(),
                _buildItemSwitch(
                  titulo: "Sistema Métrico", 
                  subtitulo: _sistemaMetrico ? "Usando Kilómetros (Km/h)" : "Usando Millas (Mph)",
                  icono: Icons.speed_rounded, 
                  colorIcono: Colors.teal,
                  valor: _sistemaMetrico,
                  onChanged: (val) {
                    setState(() => _sistemaMetrico = val);
                    // Aquí guardarías esta preferencia para la pantalla de telemetría
                  }
                ),
              ]
            ),

            const SizedBox(height: 25),

            // --- GRUPO 2: CUENTA Y PRIVACIDAD ---
            _buildTituloSeccion("Cuenta"),
            _buildTarjetaGrupo(
              children: [
                _buildItemNavegacion(
                  titulo: "Editar Perfil", 
                  icono: Icons.person_outline_rounded, 
                  colorIcono: const Color(0xFF1A237E),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PantallaPerfil()),
                    );
                  }
                ),
                _buildItemNavegacion(
  titulo: "Privacidad y Datos", 
  icono: Icons.lock_outline_rounded, 
  colorIcono: Colors.grey.shade700,
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PantallaPrivacidad()),
    );
  }
),
                _buildItemNavegacion(
  titulo: "Términos y Condiciones", 
  icono: Icons.description_outlined, 
  colorIcono: Colors.grey.shade700,
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PantallaTerminos()),
    );
  }
),
              ]
            ),

            const SizedBox(height: 40),

            // --- BOTÓN CERRAR SESIÓN FUNCIONAL ---
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () async {
                  // 1. Mostrar circulo de carga
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const Center(child: CircularProgressIndicator(color: Color(0xFF1A237E))),
                  );

                  // 2. Cerrar sesión en Firebase
                  await FirebaseAuth.instance.signOut();

                  // 3. Navegar a la pantalla inicial borrando el historial
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const OnboardingScreen()), 
                      (route) => false,
                    );
                  }
                },
                icon: const Icon(Icons.logout_rounded),
                label: const Text("CERRAR SESIÓN", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade50,
                  foregroundColor: Colors.red,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.red.shade100, width: 2)
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Versión de la app
            Center(
              child: Text(
                "SAM Remastered (Build 2)\nDesarrollado por PaulDev",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS AUXILIARES DE DISEÑO ---

  Widget _buildTituloSeccion(String titulo) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, bottom: 10),
      child: Text(
        titulo,
        style: GoogleFonts.montserrat(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: Colors.grey.shade600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildTarjetaGrupo({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ]
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 60),
      child: Divider(height: 1, color: Colors.grey.shade100),
    );
  }

  Widget _buildItemNavegacion({
    required String titulo, 
    required IconData icono, 
    required Color colorIcono,
    required VoidCallback onTap, 
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap, 
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorIcono.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icono, color: colorIcono, size: 22),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(titulo, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black87)),
              ),
              Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }

  // Elemento interactivo con interruptor (Switch)
  Widget _buildItemSwitch({
    required String titulo, 
    required String subtitulo, 
    required IconData icono, 
    required Color colorIcono,
    required bool valor,
    required Function(bool) onChanged
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorIcono.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icono, color: colorIcono, size: 22),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black87)),
                Text(subtitulo, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
              ],
            ),
          ),
          Switch.adaptive(
            value: valor,
            onChanged: onChanged,
            activeThumbColor: const Color(0xFF1A237E), 
            activeTrackColor: const Color(0xFF1A237E).withValues(alpha: 0.4),
          ),
        ],
      ),
    );
  }
}