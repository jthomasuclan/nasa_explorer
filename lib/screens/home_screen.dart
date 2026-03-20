import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/apod_data.dart';
import '../services/nasa_api.dart';
import '../services/favourites_service.dart';
import '../theme/app_colors.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final bool hapticFeedback;

  const HomeScreen({super.key, required this.hapticFeedback});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ApodData? _apod;
  bool _isLoading = true;
  bool _hasError = false;
  bool _noConnection = false;
  bool _isFavourited = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _noConnection = false;
    });

    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) {
      setState(() {
        _isLoading = false;
        _noConnection = true;
      });
      return;
    }

    final data = await NasaApiService.fetchApod();
    if (data != null) {
      final fav = await FavouritesService.isFavourite(data.date);
      setState(() {
        _apod = data;
        _isFavourited = fav;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  Future<void> _toggleFavourite() async {
    if (_apod == null) return;
    if (widget.hapticFeedback) HapticFeedback.lightImpact();
    if (_isFavourited) {
      await FavouritesService.removeFavourite(_apod!.date);
    } else {
      await FavouritesService.saveFavourite(_apod!);
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
            expandedHeight: 60,
            floating: true,
            snap: true,
            backgroundColor: isDark ? AppColors.spaceBlue : AppColors.cosmicBlue,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome, color: AppColors.accentGlow, size: 18),
                const SizedBox(width: 8),
                const Text(
                  'NASA EXPLORER',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                onPressed: _loadData,
              ),
            ],
          ),
          SliverToBoxAdapter(child: _buildBody(isDark)),
        ],
      ),
    );
  }

  Widget _buildBody(bool isDark) {
    if (_noConnection) return _buildNoConnection();
    if (_isLoading) return _buildLoading();
    if (_hasError) return _buildError();
    if (_apod == null) return const SizedBox.shrink();
    return _buildContent(isDark);
  }

  Widget _buildLoading() {
    return SizedBox(
      height: 600,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.accent, width: 2),
              ),
              child: const Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(
                  color: AppColors.accentGlow,
                  strokeWidth: 2,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'CONNECTING TO NASA',
              style: TextStyle(
                color: AppColors.moonGrey,
                fontSize: 12,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoConnection() {
    return SizedBox(
      height: 600,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 64, color: AppColors.moonGrey),
            const SizedBox(height: 20),
            const Text(
              'NO SIGNAL',
              style: TextStyle(
                color: AppColors.starWhite,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Check your connection and try again',
              style: TextStyle(color: AppColors.moonGrey, fontSize: 14),
            ),
            const SizedBox(height: 32),
            _buildGlowButton('RETRY', _loadData),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return SizedBox(
      height: 600,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 64, color: AppColors.moonGrey),
            const SizedBox(height: 20),
            const Text(
              'TRANSMISSION FAILED',
              style: TextStyle(
                color: AppColors.starWhite,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Could not reach NASA servers',
              style: TextStyle(color: AppColors.moonGrey, fontSize: 14),
            ),
            const SizedBox(height: 32),
            _buildGlowButton('RETRY', _loadData),
          ],
        ),
      ),
    );
  }

  Widget _buildGlowButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppColors.accent, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.accentGlow,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildContent(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            if (_apod!.mediaType == 'image')
              Image.network(
                _apod!.url,
                width: double.infinity,
                height: 300,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    width: double.infinity,
                    height: 300,
                    color: AppColors.spaceBlue,
                    child: const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.accentGlow, strokeWidth: 2),
                    ),
                  );
                },
                errorBuilder: (_, __, ___) => Container(
                  width: double.infinity,
                  height: 300,
                  color: AppColors.spaceBlue,
                  child: const Center(
                    child: Icon(Icons.broken_image_outlined,
                        size: 60, color: AppColors.moonGrey),
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,
                height: 300,
                color: AppColors.spaceBlue,
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.play_circle_outline,
                          size: 64, color: AppColors.accentGlow),
                      SizedBox(height: 8),
                      Text("Today's content is a video",
                          style: TextStyle(color: AppColors.moonGrey)),
                    ],
                  ),
                ),
              ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      isDark ? AppColors.deepSpace : const Color(0xFFF0F4FF),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.deepSpace.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: AppColors.accent.withOpacity(0.5), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 12, color: AppColors.accentGlow),
                    const SizedBox(width: 6),
                    Text(
                      _apod!.date,
                      style: const TextStyle(
                        color: AppColors.starWhite,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _apod!.title,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.starWhite : AppColors.spaceBlue,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  GestureDetector(
                    onTap: _toggleFavourite,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isFavourited
                            ? AppColors.red.withOpacity(0.15)
                            : (isDark ? AppColors.cardDark : Colors.grey[100]),
                        border: Border.all(
                          color: _isFavourited ? AppColors.red : AppColors.divider,
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        _isFavourited
                            ? Icons.favorite_rounded
                            : Icons.favorite_outline_rounded,
                        color: _isFavourited ? AppColors.red : AppColors.moonGrey,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark ? AppColors.cardDark : Colors.grey[100],
                      border: Border.all(color: AppColors.divider, width: 1.5),
                    ),
                    child: const Icon(
                      Icons.share_outlined,
                      color: AppColors.moonGrey,
                      size: 22,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      if (widget.hapticFeedback) HapticFeedback.lightImpact();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailScreen(apod: _apod!),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        gradient: const LinearGradient(
                          colors: [AppColors.cosmicBlue, AppColors.accent],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accent.withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'View Details',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(width: 6),
                          Icon(Icons.arrow_forward_rounded,
                              color: Colors.white, size: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Divider(color: AppColors.divider.withOpacity(0.5)),
              const SizedBox(height: 16),
              Text(
                _apod!.explanation.length > 300
                    ? '${_apod!.explanation.substring(0, 300)}...'
                    : _apod!.explanation,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.7,
                  color: isDark ? AppColors.moonGrey : Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetailScreen(apod: _apod!),
                    ),
                  );
                },
                child: const Text(
                  'Read more →',
                  style: TextStyle(
                    color: AppColors.accentGlow,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ],
    );
  }
}