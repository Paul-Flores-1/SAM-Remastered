import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sam_remastered/vistas/perfil.dart';
import 'package:sam_remastered/vistas/privacidad.dart';
import 'package:sam_remastered/vistas/terminos.dart';
import 'package:shared_preferences/shared_preferences.dart'; // IMPORTANTE PARA GUARDAR
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sam_remastered/main.dart'; 

class PantallaAjustes extends StatefulWidget {
  const PantallaAjustes({super.key});

  @override
  State<PantallaAjustes> createState() => _PantallaAjustesState();
}

class _PantallaAjustesState extends State<PantallaAjustes> {
  // Ahora estas variables leen el valor real desde las globales de main.dart
  late bool _temaOscuro;
  late bool _sistemaMetrico;

  @override
  void initState() {
    super.initState();
    // Inicializamos el estado de los switches con la memoria global
    _temaOscuro = themeNotifier.value == ThemeMode.dark;
    _sistemaMetrico = metricNotifier.value;
  }

  // --- FUNCIÓN PARA CAMBIAR Y GUARDAR TEMA ---
  void _cambiarTema(bool val) async {
    setState(() => _temaOscuro = val);
    themeNotifier.value = val ? ThemeMode.dark : ThemeMode.light; // Repinta toda la app al instante
    
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDark', val); // Guarda en el disco duro
  }

  // --- FUNCIÓN PARA CAMBIAR Y GUARDAR MÉTRICA ---
  void _cambiarMetrica(bool val) async {
    setState(() => _sistemaMetrico = val);
    metricNotifier.value = val;
    
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isMetric', val); // Guarda en el disco duro
  }

  @override
  Widget build(BuildContext context) {
    // Detectamos el color del fondo actual para adaptar el diseño
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface, 
      appBar: AppBar(
        title: Text(
          "Configuración", 
          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 18)
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            _buildTituloSeccion("Preferencias"),
            _buildTarjetaGrupo(
              isDark: isDark,
              children: [
                _buildItemSwitch(
                  titulo: "Tema Oscuro", 
                  subtitulo: "Cambiar la apariencia de la aplicación",
                  icono: Icons.dark_mode_rounded, 
                  colorIcono: Colors.deepPurple,
                  valor: _temaOscuro,
                  onChanged: _cambiarTema, // Conectado a la memoria
                  isDark: isDark,
                ),
                _buildDivider(isDark),
                _buildItemSwitch(
                  titulo: "Sistema Métrico", 
                  subtitulo: _sistemaMetrico ? "Usando Kilómetros (Km/h)" : "Usando Millas (Mph)",
                  icono: Icons.speed_rounded, 
                  colorIcono: Colors.teal,
                  valor: _sistemaMetrico,
                  onChanged: _cambiarMetrica, // Conectado a la memoria
                  isDark: isDark,
                ),
              ]
            ),

            const SizedBox(height: 25),

            _buildTituloSeccion("Cuenta"),
            _buildTarjetaGrupo(
              isDark: isDark,
              children: [
                _buildItemNavegacion(
                  titulo: "Editar Perfil", 
                  icono: Icons.person_outline_rounded, 
                  colorIcono: Theme.of(context).colorScheme.primary,
                  isDark: isDark,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PantallaPerfil())),
                ),
                _buildItemNavegacion(
                  titulo: "Privacidad y Datos", 
                  icono: Icons.lock_outline_rounded, 
                  colorIcono: Colors.grey.shade500,
                  isDark: isDark,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PantallaPrivacidad())),
                ),
                _buildItemNavegacion(
                  titulo: "Términos y Condiciones", 
                  icono: Icons.description_outlined, 
                  colorIcono: Colors.grey.shade500,
                  isDark: isDark,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PantallaTerminos(soloLectura: true))),
                ),
              ]
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () async {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary)),
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
                icon: const Icon(Icons.logout_rounded),
                label: const Text("CERRAR SESIÓN", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? Colors.red.withValues(alpha: 0.2) : Colors.red.shade50,
                  foregroundColor: Colors.redAccent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: isDark ? Colors.red.withValues(alpha: 0.5) : Colors.red.shade100, width: 2)
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 30),
            Center(
              child: Text(
                "SAM Remastered (Build 2)\nDesarrollado por PaulDev",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTituloSeccion(String titulo) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, bottom: 10),
      child: Text(
        titulo,
        style: GoogleFonts.montserrat(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: Colors.grey.shade500,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildTarjetaGrupo({required List<Widget> children, required bool isDark}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          if (!isDark) BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))
        ]
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 60),
      child: Divider(height: 1, color: isDark ? Colors.white10 : Colors.grey.shade100),
    );
  }

  Widget _buildItemNavegacion({required String titulo, required IconData icono, required Color colorIcono, required VoidCallback onTap, required bool isDark}) {
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
                decoration: BoxDecoration(color: colorIcono.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(icono, color: colorIcono, size: 22),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(titulo, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: isDark ? Colors.white : Colors.black87)),
              ),
              Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemSwitch({required String titulo, required String subtitulo, required IconData icono, required Color colorIcono, required bool valor, required Function(bool) onChanged, required bool isDark}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: colorIcono.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icono, color: colorIcono, size: 22),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: isDark ? Colors.white : Colors.black87)),
                Text(subtitulo, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
              ],
            ),
          ),
          Switch.adaptive(
            value: valor,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }
}