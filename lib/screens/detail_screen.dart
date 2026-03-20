import 'package:flutter/material.dart';
import '../models/apod_data.dart';
import '../theme/app_colors.dart';

class DetailScreen extends StatelessWidget {
  final ApodData apod;

  const DetailScreen({super.key, required this.apod});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: apod.mediaType == 'image' ? 350 : 0,
            pinned: true,
            flexibleSpace: apod.mediaType == 'image'
                ? FlexibleSpaceBar(
                    background: Image.network(
                      apod.url,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.spaceBlue,
                        child: const Center(
                          child: Icon(Icons.broken_image_outlined,
                              color: AppColors.moonGrey, size: 60),
                        ),
                      ),
                    ),
                  )
                : null,
            title: Text(
              apod.title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    apod.title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.starWhite : AppColors.spaceBlue,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.accent.withOpacity(0.3)),
                    ),
                    child: Text(
                      apod.date,
                      style: const TextStyle(
                        color: AppColors.accentGlow,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    apod.explanation,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.8,
                      color: isDark ? AppColors.moonGrey : Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}