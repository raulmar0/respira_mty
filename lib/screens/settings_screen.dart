import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGray, // Mismo fondo gris claro
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () {},
        ),
        title: Text(
          "Ajustes",
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 24),
        ),
        centerTitle: false,
        titleSpacing: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Tarjeta de Perfil
            const _ProfileCard(),
            const SizedBox(height: 25),

            // 2. Sección Notificaciones
            const _SectionHeader(title: "NOTIFICACIONES"),
            _SettingsGroup(
              children: [
                _SettingsTile(
                  icon: Icons.warning_amber_rounded,
                  iconColor: Colors.redAccent,
                  iconBg: const Color(0xFFFDE8E8),
                  title: "Alertas Críticas",
                  subtitle: "Notificar cuando el aire sea peligroso",
                  trailing: Switch(
                    value: true,
                    activeThumbColor: Colors.white,
                    activeTrackColor: const Color(0xFF5CE57E),
                    onChanged: (v) {},
                  ),
                ),
                const _CustomDivider(),
                _SettingsTile(
                  icon: Icons.wb_sunny_outlined,
                  iconColor: Colors.blueAccent,
                  iconBg: const Color(0xFFE3F2FD),
                  title: "Reporte Diario",
                  subtitle: "Resumen a las 8:00 AM",
                  trailing: Switch(
                    value: false,
                    onChanged: (v) {},
                  ),
                ),
                const _CustomDivider(),
                const _SettingsTile(
                  icon: Icons.tune,
                  iconColor: Colors.purple,
                  iconBg: Color(0xFFF3E5F5),
                  title: "Umbral de Alerta",
                  trailingText: "100 IMECA",
                  showArrow: true,
                ),
              ],
            ),
            const SizedBox(height: 25),

            // 3. Sección Visualización
            const _SectionHeader(title: "VISUALIZACIÓN"),
            _SettingsGroup(
              children: [
                const _SettingsTile(
                  icon: Icons.bar_chart_rounded,
                  iconColor: Colors.green,
                  iconBg: Color(0xFFE8F5E9),
                  title: "Unidades",
                  trailingText: "IMECA",
                  showArrow: true,
                ),
                const _CustomDivider(),
                const _SettingsTile(
                  icon: Icons.location_on,
                  iconColor: Colors.orange,
                  iconBg: Color(0xFFFFF3E0),
                  title: "Estación Favorita",
                  trailingText: "Obispado",
                  showArrow: true,
                ),
                const _CustomDivider(),
                _SettingsTile(
                  icon: Icons.dark_mode_outlined,
                  iconColor: Colors.blueGrey,
                  iconBg: const Color(0xFFECEFF1),
                  title: "Modo Oscuro",
                  trailing: Switch(
                    value: false,
                    onChanged: (v) {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),

            // 4. Sección Información
            const _SectionHeader(title: "INFORMACIÓN"),
            const _SettingsGroup(
              children: [
                _SettingsTile(
                  title: "Política de Privacidad",
                  showArrow: true,
                ),
                _CustomDivider(),
                _SettingsTile(
                  title: "Acerca de la App",
                  showArrow: true,
                ),
              ],
            ),
            const SizedBox(height: 30),

            // 5. Botón Cerrar Sesión
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFFFFEBEE), // Rojo muy claro
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  "Cerrar Sesión",
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 6. Footer Versión
            Center(
              child: Column(
                children: [
                  Text("Versión 1.0.2", style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cloud, size: 12, color: Colors.grey[400]),
                      const SizedBox(width: 4),
                      Text("Datos provistos por SIMA N.L.", style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// --- WIDGETS AUXILIARES PARA LIMPIEZA DEL CÓDIGO ---

class _ProfileCard extends StatelessWidget {
  const _ProfileCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              const CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11'), // Placeholder imagen
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFF5CE57E),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit, size: 12, color: Colors.white),
                ),
              )
            ],
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Roberto Martínez", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text("roberto@example.com", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.grey,
          fontWeight: FontWeight.bold,
          fontSize: 11,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final List<Widget> children;
  const _SettingsGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData? icon;
  final Color? iconColor;
  final Color? iconBg;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final String? trailingText;
  final bool showArrow;

  const _SettingsTile({
    this.icon,
    this.iconColor,
    this.iconBg,
    required this.title,
    this.subtitle,
    this.trailing,
    this.trailingText,
    this.showArrow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(subtitle!, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                  ),
              ],
            ),
          ),
          if (trailingText != null)
            Text(trailingText!, style: TextStyle(color: Colors.grey[500], fontSize: 14, fontWeight: FontWeight.w500)),
          if (trailing != null) trailing!,
          if (showArrow) ...[
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, size: 20, color: Colors.grey[400]),
          ]
        ],
      ),
    );
  }
}

class _CustomDivider extends StatelessWidget {
  const _CustomDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(height: 1, thickness: 0.5, color: Colors.grey[200], indent: 60, endIndent: 0);
  }
}
