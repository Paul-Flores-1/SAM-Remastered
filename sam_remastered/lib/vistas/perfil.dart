import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PantallaPerfil extends StatelessWidget {
  const PantallaPerfil({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Mi Perfil SAM", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF1A237E),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            //FOTO Y NOMBRE
            const Center(
              child: Hero(
                tag: 'avatar_perfil',
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Color(0xFF1A237E),
                  child: Text("P", style: TextStyle(fontSize: 40, color: Colors.white)),
                ),
              ),
            ),
            const SizedBox(height: 15),
            Text(
              "Paul Flores",
              style: GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text("paul.flores@email.com", style: TextStyle(color: Colors.grey)),
            
            const SizedBox(height: 30),

            //TARJETA MÉDICA
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
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("TIPO DE SANGRE", style: TextStyle(color: Colors.white70, fontSize: 12)),
                      Text("O+", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      Text("ALERGIAS", style: TextStyle(color: Colors.white70, fontSize: 12)),
                      Text("Penicilina", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Icon(Icons.medical_services_outlined, color: Colors.white.withValues(alpha: 0.2), size: 80),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // DATOS DE CONTACTO DE EMERGENCIA
            _buildSeccion("Contactos de Emergencia"),
            _buildItemInfo(Icons.phone, "Mamá", "744 123 4567"),
            _buildItemInfo(Icons.phone, "Hermano", "744 987 6543"),

            const SizedBox(height: 20),
            
            // DATOS DE CUENTA
            _buildSeccion("Información de Cuenta"),
            _buildItemInfo(Icons.cake, "Fecha de Nacimiento", "12/05/2001"),
            _buildItemInfo(Icons.smartphone, "Teléfono", "744 555 5555"),

            const SizedBox(height: 30),

            // BOTÓN CERRAR SESIÓN
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () {
                  
                  Navigator.pop(context); 
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))
                ),
                child: const Text("CERRAR SESIÓN"),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

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