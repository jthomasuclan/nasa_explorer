import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/apod_data.dart';
import '../services/favourites_service.dart';
import '../theme/app_colors.dart';

class DetailScreen extends StatefulWidget {
  final ApodData apod;

  const DetailScreen({super.key, required this.apod});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool _isFavourited = false;

  @override
  void initState() {
    super.initState();
    _checkFavourite();
  }

  Future<void> _checkFavourite() async {
    final fav = await FavouritesService.isFavourite(widget.apod.date);
    setState(() => _isFavourited = fav);
  }

  Future<void> _toggleFavourite() async {
    HapticFeedback.lightImpact();
    if (_isFavourited) {
      await FavouritesService.removeFavourite(widget.apod.date);
    } else {
      await FavouritesService.saveFavourite(widget.apod);
    }
    setState(() => _isFavourited = !_isFavourited);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: widget.apod.mediaType == 'image' ? 350 : 0,
            pinned: true,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.deepSpace.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 18),
              ),
            ),
            actions: [
              GestureDetector(
                onTap: _toggleFavourite,
                child: Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.deepSpace.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isFavourited
                        ? Icons.favorite_rounded
                        : Icons.favorite_outline_rounded,
                    color: _isFavourited ? AppColors.red : Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
            flexibleSpace: widget.apod.mediaType == 'image'
                ? FlexibleSpaceBar(
                    background: Hero(
                      tag: 'apod_image_${widget.apod.date}',
                      child: Image.network(
                        widget.apod.url,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: AppColors.spaceBlue,
                          child: const Center(
                            child: Icon(Icons.broken_image_outlined,
                                color: AppColors.moonGrey, size: 60),
                          ),
                        ),
                      ),
                    ),
                  )
                : null,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.apod.title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.starWhite : AppColors.spaceBlue,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: AppColors.accent.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.calendar_today_outlined,
                                size: 12, color: AppColors.accentGlow),
                            const SizedBox(width: 6),
                            Text(
                              widget.apod.date,
                              style: const TextStyle(
                                color: AppColors.accentGlow,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.moonGrey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: AppColors.moonGrey.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              widget.apod.mediaType == 'image'
                                  ? Icons.image_outlined
                                  : Icons.videocam_outlined,
                              size: 12,
                              color: AppColors.moonGrey,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              widget.apod.mediaType == 'image'
                                  ? 'Image'
                                  : 'Video',
                              style: const TextStyle(
                                color: AppColors.moonGrey,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Divider(color: AppColors.divider.withOpacity(0.5)),
                  const SizedBox(height: 20),
                  const Text(
                    'EXPLANATION',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.moonGrey,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.apod.explanation,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.8,
                      color: isDark ? AppColors.moonGrey : Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDark : Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColors.divider.withOpacity(0.5)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.satellite_alt_rounded,
                            color: AppColors.accentGlow, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Image credit: NASA APOD — api.nasa.gov',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? AppColors.moonGrey
                                  : Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
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