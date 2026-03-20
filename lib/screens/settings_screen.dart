import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import 'about_screen.dart';

class SettingsScreen extends StatelessWidget {
  final bool darkMode;
  final bool largeText;
  final bool hapticFeedback;
  final ValueChanged<bool> onDarkModeChanged;
  final ValueChanged<bool> onLargeTextChanged;
  final ValueChanged<bool> onHapticFeedbackChanged;

  const SettingsScreen({
    super.key,
    required this.darkMode,
    required this.largeText,
    required this.hapticFeedback,
    required this.onDarkModeChanged,
    required this.onLargeTextChanged,
    required this.onHapticFeedbackChanged,
  });

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.moonGrey,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    Color iconColor = AppColors.accentGlow,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider.withOpacity(0.4)),
      ),
      child: SwitchListTile(
        secondary: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: isDark ? AppColors.starWhite : AppColors.spaceBlue,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: AppColors.moonGrey, fontSize: 12),
        ),
        value: value,
        onChanged: (val) {
          if (hapticFeedback) HapticFeedback.lightImpact();
          onChanged(val);
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SETTINGS',
            style: TextStyle(letterSpacing: 2, fontSize: 15)),
      ),
      body: ListView(
        children: [
          _buildSectionLabel('APPEARANCE'),
          _buildSettingsTile(
            context,
            icon: Icons.dark_mode_rounded,
            title: 'Dark Mode',
            subtitle: 'Switch to space-dark theme',
            value: darkMode,
            onChanged: onDarkModeChanged,
            iconColor: const Color(0xFF9575CD),
          ),
          _buildSettingsTile(
            context,
            icon: Icons.text_fields_rounded,
            title: 'Large Text',
            subtitle: 'Increase text size for readability',
            value: largeText,
            onChanged: onLargeTextChanged,
            iconColor: AppColors.accentGlow,
          ),
          _buildSectionLabel('INTERACTION'),
          _buildSettingsTile(
            context,
            icon: Icons.vibration_rounded,
            title: 'Haptic Feedback',
            subtitle: 'Vibrate on interactions',
            value: hapticFeedback,
            onChanged: onHapticFeedbackChanged,
            iconColor: const Color(0xFF81C784),
          ),
          _buildSectionLabel('INFO'),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.divider.withOpacity(0.4)),
            ),
            child: ListTile(
              leading: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.rocket_launch_rounded,
                    color: AppColors.accent, size: 18),
              ),
              title: Text(
                'About',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: isDark ? AppColors.starWhite : AppColors.spaceBlue,
                ),
              ),
              subtitle: const Text('About NASA Explorer',
                  style: TextStyle(color: AppColors.moonGrey, fontSize: 12)),
              trailing: const Icon(Icons.chevron_right_rounded,
                  color: AppColors.moonGrey),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AboutScreen()),
                );
              },
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}