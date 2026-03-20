import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/apod_data.dart';
import '../services/favourites_service.dart';
import '../theme/app_colors.dart';
import 'detail_screen.dart';

class FavouritesScreen extends StatefulWidget {
  const FavouritesScreen({super.key});

  @override
  State<FavouritesScreen> createState() => _FavouritesScreenState();
}

class _FavouritesScreenState extends State<FavouritesScreen> {
  List<ApodData> _favourites = [];

  @override
  void initState() {
    super.initState();
    _loadFavourites();
  }

  Future<void> _loadFavourites() async {
    final favs = await FavouritesService.loadFavourites();
    setState(() => _favourites = favs);
  }

  Future<void> _removeFavourite(ApodData apod) async {
    HapticFeedback.lightImpact();
    await FavouritesService.removeFavourite(apod.date);
    _loadFavourites();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.favorite_rounded, color: AppColors.red, size: 18),
            SizedBox(width: 8),
            Text('FAVOURITES', style: TextStyle(letterSpacing: 2, fontSize: 15)),
          ],
        ),
      ),
      body: _favourites.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.divider, width: 1.5),
                    ),
                    child: const Icon(Icons.favorite_outline_rounded,
                        size: 48, color: AppColors.moonGrey),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'No favourites yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.starWhite : AppColors.spaceBlue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tap the heart on an image to save it here',
                    style: TextStyle(color: AppColors.moonGrey, fontSize: 14),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _favourites.length,
              itemBuilder: (context, index) {
                final apod = _favourites[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.divider.withOpacity(0.5)),
                    boxShadow: isDark
                        ? []
                        : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: apod.mediaType == 'image'
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              apod.url,
                              width: 64,
                              height: 64,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 64,
                                height: 64,
                                color: AppColors.spaceBlue,
                                child: const Icon(Icons.broken_image_outlined,
                                    color: AppColors.moonGrey),
                              ),
                            ),
                          )
                        : Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: AppColors.spaceBlue,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.play_circle_outline,
                                color: AppColors.accentGlow, size: 32),
                          ),
                    title: Text(
                      apod.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: isDark ? AppColors.starWhite : AppColors.spaceBlue,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        apod.date,
                        style: const TextStyle(
                            color: AppColors.moonGrey, fontSize: 12),
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline_rounded,
                          color: AppColors.red, size: 20),
                      onPressed: () => _removeFavourite(apod),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailScreen(apod: apod),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}