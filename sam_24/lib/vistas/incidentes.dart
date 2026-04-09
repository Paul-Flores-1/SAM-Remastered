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

  // Colores de categoría
  final Color colorAccidente = const Color(0xFFFF4D4D);
  final Color colorFrenazo = const Color(0xFFFF6F00);
  final Color colorBache = const Color(0xFF4C8EEA);
  final Color colorCaida = const Color(0xFF9C6FE4);

  String filtroSeleccionado = "Todos";

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final Color bgPage =
        isDark ? const Color(0xFF121212) : const Color(0xFFF4F6FB);
    final Color bgCard = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color borderCard = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : const Color(0xFFEEF0F8);

    // Conteos
    int countAccidentes =
        widget.historial.where((e) => e['tipo'] == 'accidente').length;
    int countFrenazos =
        widget.historial.where((e) => e['tipo'] == 'frenazo').length;
    int countBaches =
        widget.historial.where((e) => e['tipo'] == 'bache').length;
    int countCaidas =
        widget.historial.where((e) => e['tipo'] == 'caida').length;

    // Filtrado
    List<dynamic> listaFiltrada = switch (filtroSeleccionado) {
      "Accidentes" =>
        widget.historial.where((e) => e['tipo'] == 'accidente').toList(),
      "Frenazos" =>
        widget.historial.where((e) => e['tipo'] == 'frenazo').toList(),
      _ => widget.historial,
    };

    return Scaffold(
      backgroundColor: bgPage,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── CABECERA ────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 110.0,
            pinned: true,
            elevation: 0,
            backgroundColor: isDark ? const Color(0xFF1E1E1E) : azulApp,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              titlePadding:
                  const EdgeInsets.symmetric(horizontal: 60, vertical: 14),
              title: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Dashboard de seguridad",
                    style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Últimos 30 días",
                    style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w400,
                        fontSize: 11,
                        color: Colors.white60),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded,
                    color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),

          // ── CONTADORES ──────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: Row(
                children: [
                  _buildStatCard("Accidentes", countAccidentes, colorAccidente,
                      bgCard, borderCard),
                  const SizedBox(width: 10),
                  _buildStatCard("Frenazos", countFrenazos, colorFrenazo,
                      bgCard, borderCard),
                  const SizedBox(width: 10),
                  _buildStatCard(
                      "Baches", countBaches, colorBache, bgCard, borderCard),
                  const SizedBox(width: 10),
                  _buildStatCard(
                      "Caídas", countCaidas, colorCaida, bgCard, borderCard),
                ],
              ),
            ),
          ),

          // ── FILTROS ─────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Filtrar eventos",
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: azulApp,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildFilterPill("Todos", isDark),
                      const SizedBox(width: 8),
                      _buildFilterPill("Accidentes", isDark),
                      const SizedBox(width: 8),
                      _buildFilterPill("Frenazos", isDark),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── HEADER LISTA ────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Eventos recientes",
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: azulApp,
                    ),
                  ),
                  Text(
                    "Ver todo",
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: ambarApp,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── LISTADO ─────────────────────────────────────────────────
          listaFiltrada.isEmpty
              ? SliverFillRemaining(
                  child: Center(
                    child: Text(
                      "No hay registros en esta categoría",
                      style: TextStyle(
                          color: isDark ? Colors.grey : Colors.black45,
                          fontSize: 13),
                    ),
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 28),
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

  // ── STAT CARD ──────────────────────────────────────────────────────────────
  Widget _buildStatCard(String titulo, int cantidad, Color color,
      Color bgCard, Color borderCard) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderCard),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration:
                  BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(height: 6),
            Text(
              cantidad.toString(),
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: color,
                  height: 1),
            ),
            const SizedBox(height: 4),
            Text(
              titulo,
              style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF9098B1),
                  letterSpacing: 0.3),
            ),
          ],
        ),
      ),
    );
  }

  // ── FILTER PILL ────────────────────────────────────────────────────────────
  Widget _buildFilterPill(String label, bool isDark) {
    final bool active = filtroSeleccionado == label;
    return GestureDetector(
      onTap: () => setState(() => filtroSeleccionado = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
        decoration: BoxDecoration(
          color: active
              ? ambarApp
              : (isDark ? Colors.white10 : const Color(0xFFEEF0F8)),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active
                ? Colors.white
                : (isDark ? Colors.grey : const Color(0xFF6B7A99)),
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  // ── EVENT CARD ─────────────────────────────────────────────────────────────
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
    late String labelTipo;

    switch (tipo) {
      case 'accidente':
        colorTipo = colorAccidente;
        iconoTipo = Icons.error_outline_rounded;
        labelTipo = 'accidente';
      case 'frenazo':
        colorTipo = colorFrenazo;
        iconoTipo = Icons.speed_rounded;
        labelTipo = 'frenazo';
      case 'bache':
        colorTipo = colorBache;
        iconoTipo = Icons.waves_rounded;
        labelTipo = 'bache';
      case 'caida':
        colorTipo = colorCaida;
        iconoTipo = Icons.phonelink_erase_rounded;
        labelTipo = 'caída';
      default:
        colorTipo = azulApp;
        iconoTipo = Icons.notifications_none_rounded;
        labelTipo = tipo;
    }

    // Color de badge: fondo muy claro + texto más oscuro del mismo tono
    final Color badgeBg = colorTipo.withValues(alpha: 0.10);
    final Color badgeText = colorTipo.withValues(alpha: 0.85);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderCard),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: colorTipo.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(iconoTipo, color: colorTipo, size: 20),
        ),
        title: Text(
          detalle,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: isDark ? Colors.white : const Color(0xFF1A1F36),
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Text(
            fecha,
            style: const TextStyle(
                fontSize: 11, color: Color(0xFF9098B1)),
          ),
        ),
        trailing: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: badgeBg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            labelTipo,
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: badgeText),
          ),
        ),
      ),
    );
  }
}