import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ABOUT', style: TextStyle(letterSpacing: 2, fontSize: 15)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [AppColors.cosmicBlue, AppColors.accent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withOpacity(0.4),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(Icons.rocket_launch_rounded,
                    size: 48, color: Colors.white),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                'NASA Explorer',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.starWhite : AppColors.spaceBlue,
                ),
              ),
            ),
            const SizedBox(height: 4),
            const Center(
              child: Text(
                'Version 1.0.0',
                style: TextStyle(color: AppColors.moonGrey, fontSize: 13),
              ),
            ),
            const SizedBox(height: 32),
            _buildInfoCard(
              context,
              isDark,
              icon: Icons.info_outline_rounded,
              title: 'About this App',
              content:
                  'NASA Explorer displays the NASA Picture of the Day using NASA\'s public APOD API. Every day NASA publishes a new image of our universe with an explanation by a professional astronomer.',
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              context,
              isDark,
              icon: Icons.satellite_alt_rounded,
              title: 'Data Source',
              content:
                  'All images and data are sourced from NASA\'s APOD API at api.nasa.gov. Data is free to use under NASA\'s open data policy.',
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              context,
              isDark,
              icon: Icons.school_rounded,
              title: 'Academic',
              content:
                  'Built for CO2404 Cross Platform Development at the University of Central Lancashire.',
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    bool isDark, {
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider.withOpacity(0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.accentGlow, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.starWhite : AppColors.spaceBlue,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.6,
                    color: AppColors.moonGrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}