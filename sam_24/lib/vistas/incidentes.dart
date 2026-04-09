import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PantallaHistorialIncidentes extends StatefulWidget {
  final List<dynamic> historial;

  const PantallaHistorialIncidentes({super.key, required this.historial});

  @override
  State<PantallaHistorialIncidentes> createState() =>
      _PantallaHistorialIncidentesState();
}

class _PantallaHistorialIncidentesState
    extends State<PantallaHistorialIncidentes> {
  // --- PALETA DE COLORES OFICIALES SAM24 ---
  final Color azulApp = const Color(0xFF1A237E);
  final Color ambarApp = const Color(0xFFFF6F00);

  final Color colorAccidente = const Color(0xFFFF4D4D);
  final Color colorFrenazo = const Color(0xFFFF6F00);
  final Color colorBache = const Color(0xFF4C8EEA);
  final Color colorCaida = const Color(0xFF9C6FE4);

  String filtroSeleccionado = "Todos";

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bgPage = isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA);
    final Color bgCard = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color borderCard = isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFEBEBF0);

    // Conteos
    int countAccidentes = widget.historial.where((e) => e['tipo'] == 'accidente').length;
    int countFrenazos = widget.historial.where((e) => e['tipo'] == 'frenazo').length;
    int countBaches = widget.historial.where((e) => e['tipo'] == 'bache').length;
    int countCaidas = widget.historial.where((e) => e['tipo'] == 'caida').length;

    // Filtrado
    List<dynamic> listaFiltrada = switch (filtroSeleccionado) {
      "Accidentes" => widget.historial.where((e) => e['tipo'] == 'accidente').toList(),
      "Frenazos" => widget.historial.where((e) => e['tipo'] == 'frenazo').toList(),
      "Baches" => widget.historial.where((e) => e['tipo'] == 'bache').toList(),
      "Caídas" => widget.historial.where((e) => e['tipo'] == 'caida').toList(),
      _ => widget.historial,
    };

    return Scaffold(
      backgroundColor: bgPage,
      appBar: AppBar(
        backgroundColor: bgPage,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : azulApp),
        title: Text(
          "Historial de Incidentes",
          style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: isDark ? Colors.white : azulApp),
        ),
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── NUEVA TARJETA MASTER DE ESTADÍSTICAS (Estilo Captura) ────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [azulApp, const Color(0xFF3949AB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: azulApp.withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Dashboard de Seguridad",
                              style: GoogleFonts.montserrat(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              "Resumen de últimos 30 días",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const Icon(Icons.analytics_outlined, color: Colors.white, size: 30),
                      ],
                    ),
                    const SizedBox(height: 25),
                    // Fila de Contadores Integrados
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatItem("Accidentes", countAccidentes, colorAccidente),
                        _buildStatItem("Frenazos", countFrenazos, ambarApp),
                        _buildStatItem("Baches", countBaches, colorBache),
                        _buildStatItem("Caídas", countCaidas, colorCaida),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── FILTROS ─────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "Filtrar por categoría",
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : azulApp,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        _buildFilterPill("Todos", isDark),
                        const SizedBox(width: 8),
                        _buildFilterPill("Accidentes", isDark),
                        const SizedBox(width: 8),
                        _buildFilterPill("Frenazos", isDark),
                        const SizedBox(width: 8),
                        _buildFilterPill("Baches", isDark),
                        const SizedBox(width: 8),
                        _buildFilterPill("Caídas", isDark),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── LISTADO ─────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 15, 16, 10),
              child: Text(
                "Eventos recientes",
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : azulApp,
                ),
              ),
            ),
          ),

          listaFiltrada.isEmpty
              ? const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: Text("No hay registros disponibles")),
                )
              : SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final item = listaFiltrada[index];
                        return _buildEventCard(
                          tipo: item['tipo'] ?? 'evento',
                          fecha: item['fecha'] ?? '--/--/--',
                          detalle: item['detalle'] ?? '',
                          isDark: isDark,
                          bgCard: bgCard,
                          borderCard: borderCard,
                        );
                      },
                      childCount: listaFiltrada.length,
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  // Widget auxiliar para los items dentro de la Card Azul
  Widget _buildStatItem(String label, int value, Color colorPoint) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: colorPoint, shape: BoxShape.circle),
            ),
            const SizedBox(width: 5),
            Text(
              value.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterPill(String label, bool isDark) {
    final bool active = filtroSeleccionado == label;
    return GestureDetector(
      onTap: () => setState(() => filtroSeleccionado = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: active ? ambarApp : (isDark ? Colors.white10 : const Color(0xFFEEF0F8)),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : (isDark ? Colors.grey : const Color(0xFF6B7A99)),
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildEventCard({
    required String tipo,
    required String fecha,
    required String detalle,
    required bool isDark,
    required Color bgCard,
    required Color borderCard,
  }) {
    late Color colorTipo;
    late IconData iconoTipo;

    switch (tipo) {
      case 'accidente': colorTipo = colorAccidente; iconoTipo = Icons.error_outline_rounded; break;
      case 'frenazo': colorTipo = ambarApp; iconoTipo = Icons.speed_rounded; break;
      case 'bache': colorTipo = colorBache; iconoTipo = Icons.waves_rounded; break;
      case 'caida': colorTipo = colorCaida; iconoTipo = Icons.phonelink_erase_rounded; break;
      default: colorTipo = azulApp; iconoTipo = Icons.notifications_none_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderCard),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: colorTipo.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(iconoTipo, color: colorTipo, size: 22),
        ),
        title: Text(
          detalle,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: isDark ? Colors.white : azulApp,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(fecha, style: const TextStyle(fontSize: 12, color: Color(0xFF9098B1))),
        ),
        trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: isDark ? Colors.white24 : Colors.grey[300]),
      ),
    );
  }
}