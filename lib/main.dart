import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

void main() {
  runApp(const NasaApp());
}

// ─────────────────────────────────────────────────────────────────────────────
// THEME CONSTANTS
// ─────────────────────────────────────────────────────────────────────────────

class AppColors {
  static const Color deepSpace = Color(0xFF030B1A);
  static const Color spaceBlue = Color(0xFF0B1E3D);
  static const Color nebulaPurple = Color(0xFF1A1040);
  static const Color cosmicBlue = Color(0xFF0B3D91);
  static const Color starWhite = Color(0xFFE8F0FE);
  static const Color moonGrey = Color(0xFF8A9BB5);
  static const Color accent = Color(0xFF4A90E2);
  static const Color accentGlow = Color(0xFF64B5F6);
  static const Color cardDark = Color(0xFF0D1F3C);
  static const Color divider = Color(0xFF1E3A5F);
  static const Color red = Color(0xFFE57373);
}

// ─────────────────────────────────────────────────────────────────────────────
// MODEL
// ─────────────────────────────────────────────────────────────────────────────

class ApodData {
  final String title;
  final String date;
  final String explanation;
  final String url;
  final String mediaType;

  ApodData({
    required this.title,
    required this.date,
    required this.explanation,
    required this.url,
    required this.mediaType,
  });

  factory ApodData.fromJson(Map<String, dynamic> json) {
    return ApodData(
      title: json['title'] ?? '',
      date: json['date'] ?? '',
      explanation: json['explanation'] ?? '',
      url: json['url'] ?? '',
      mediaType: json['media_type'] ?? 'image',
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'date': date,
        'explanation': explanation,
        'url': url,
        'mediaType': mediaType,
      };

  static ApodData fromMap(Map<String, dynamic> map) => ApodData(
        title: map['title'],
        date: map['date'],
        explanation: map['explanation'],
        url: map['url'],
        mediaType: map['mediaType'],
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// NASA API SERVICE
// ─────────────────────────────────────────────────────────────────────────────

class NasaApiService {
  static const String _apiKey = 'pHbr4P1TZskz5z89E2DUZ3Tihu8RFaOpNtw89EZ7';
  static const String _baseUrl = 'https://api.nasa.gov/planetary/apod';

  static Future<ApodData?> fetchApod() async {
    try {
      final uri = Uri.parse('$_baseUrl?api_key=$_apiKey');
      developer.log('Fetching APOD: $uri', name: 'NasaApiService');
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      developer.log('Status: ${response.statusCode}', name: 'NasaApiService');
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return ApodData.fromJson(json);
      }
      return null;
    } catch (e) {
      developer.log('Network error: $e', name: 'NasaApiService');
      return null;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LOCAL STORAGE SERVICE
// ─────────────────────────────────────────────────────────────────────────────

class FavouritesService {
  static const String _key = 'favourites';

  static Future<List<ApodData>> loadFavourites() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> stored = prefs.getStringList(_key) ?? [];
    return stored.map((s) => ApodData.fromMap(jsonDecode(s))).toList();
  }

  static Future<void> saveFavourite(ApodData apod) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> stored = prefs.getStringList(_key) ?? [];
    if (!stored.any((s) => jsonDecode(s)['date'] == apod.date)) {
      stored.add(jsonEncode(apod.toMap()));
      await prefs.setStringList(_key, stored);
    }
  }

  static Future<void> removeFavourite(String date) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> stored = prefs.getStringList(_key) ?? [];
    stored.removeWhere((s) => jsonDecode(s)['date'] == date);
    await prefs.setStringList(_key, stored);
  }

  static Future<bool> isFavourite(String date) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> stored = prefs.getStringList(_key) ?? [];
    return stored.any((s) => jsonDecode(s)['date'] == date);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// APP ROOT
// ─────────────────────────────────────────────────────────────────────────────

class NasaApp extends StatefulWidget {
  const NasaApp({super.key});

  @override
  State<NasaApp> createState() => _NasaAppState();
}

class _NasaAppState extends State<NasaApp> {
  bool _darkMode = true;
  bool _largeText = false;

  void updateDarkMode(bool val) => setState(() => _darkMode = val);
  void updateLargeText(bool val) => setState(() => _largeText = val);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NASA Explorer',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(_darkMode, _largeText),
      home: MainScreen(
        darkMode: _darkMode,
        largeText: _largeText,
        onDarkModeChanged: updateDarkMode,
        onLargeTextChanged: updateLargeText,
      ),
    );
  }

  ThemeData _buildTheme(bool dark, bool largeText) {
    return ThemeData(
      useMaterial3: true,
      brightness: dark ? Brightness.dark : Brightness.light,
      colorScheme: dark
          ? const ColorScheme.dark(
              primary: AppColors.accent,
              secondary: AppColors.accentGlow,
              surface: AppColors.cardDark,
              background: AppColors.deepSpace,
            )
          : ColorScheme.fromSeed(
              seedColor: AppColors.cosmicBlue,
              brightness: Brightness.light,
            ),
      scaffoldBackgroundColor:
          dark ? AppColors.deepSpace : const Color(0xFFF0F4FF),
      appBarTheme: AppBarTheme(
        backgroundColor: dark ? AppColors.spaceBlue : AppColors.cosmicBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: dark ? AppColors.spaceBlue : AppColors.cosmicBlue,
        selectedItemColor: AppColors.accentGlow,
        unselectedItemColor: dark ? AppColors.moonGrey : Colors.white60,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      textTheme: largeText
          ? const TextTheme(
              bodyMedium: TextStyle(fontSize: 17),
              bodyLarge: TextStyle(fontSize: 19),
              titleLarge: TextStyle(fontSize: 24),
            )
          : null,
      cardTheme: CardThemeData(
        color: dark ? AppColors.cardDark : Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      dividerColor: dark ? AppColors.divider : Colors.grey[300],
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith(
          (states) => states.contains(MaterialState.selected)
              ? AppColors.accentGlow
              : Colors.grey,
        ),
        trackColor: MaterialStateProperty.resolveWith(
          (states) => states.contains(MaterialState.selected)
              ? AppColors.accent.withOpacity(0.5)
              : Colors.grey.withOpacity(0.3),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MAIN SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class MainScreen extends StatefulWidget {
  final bool darkMode;
  final bool largeText;
  final ValueChanged<bool> onDarkModeChanged;
  final ValueChanged<bool> onLargeTextChanged;

  const MainScreen({
    super.key,
    required this.darkMode,
    required this.largeText,
    required this.onDarkModeChanged,
    required this.onLargeTextChanged,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      const HomeScreen(),
      const FavouritesScreen(),
      SettingsScreen(
        darkMode: widget.darkMode,
        largeText: widget.largeText,
        onDarkModeChanged: widget.onDarkModeChanged,
        onLargeTextChanged: widget.onLargeTextChanged,
      ),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          HapticFeedback.selectionClick();
          setState(() => _currentIndex = index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.rocket_launch_outlined),
            activeIcon: Icon(Icons.rocket_launch),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outline),
            activeIcon: Icon(Icons.favorite),
            label: 'Favourites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.tune_outlined),
            activeIcon: Icon(Icons.tune),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HOME SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

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
    HapticFeedback.lightImpact();
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
            backgroundColor:
                isDark ? AppColors.spaceBlue : AppColors.cosmicBlue,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome,
                    color: AppColors.accentGlow, size: 18),
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
            Icon(Icons.wifi_off_rounded, size: 64, color: AppColors.moonGrey),
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
            Icon(Icons.error_outline_rounded,
                size: 64, color: AppColors.moonGrey),
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
        padding:
            const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
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
        // Hero image
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
            // Gradient overlay at bottom of image
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
                      isDark
                          ? AppColors.deepSpace
                          : const Color(0xFFF0F4FF),
                    ],
                  ),
                ),
              ),
            ),
            // Date badge
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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

        // Content card
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
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

              // Action row
              Row(
                children: [
                  // Favourite button
                  GestureDetector(
                    onTap: _toggleFavourite,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isFavourited
                            ? AppColors.red.withOpacity(0.15)
                            : (isDark
                                ? AppColors.cardDark
                                : Colors.grey[100]),
                        border: Border.all(
                          color: _isFavourited
                              ? AppColors.red
                              : AppColors.divider,
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        _isFavourited
                            ? Icons.favorite_rounded
                            : Icons.favorite_outline_rounded,
                        color: _isFavourited
                            ? AppColors.red
                            : AppColors.moonGrey,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Share button
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark ? AppColors.cardDark : Colors.grey[100],
                      border: Border.all(
                          color: AppColors.divider, width: 1.5),
                    ),
                    child: const Icon(
                      Icons.share_outlined,
                      color: AppColors.moonGrey,
                      size: 22,
                    ),
                  ),
                  const Spacer(),

                  // View Details button
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
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

              // Description preview
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

// ─────────────────────────────────────────────────────────────────────────────
// DETAIL SCREEN
// ─────────────────────────────────────────────────────────────────────────────

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
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w700),
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
                      color: isDark
                          ? AppColors.starWhite
                          : AppColors.spaceBlue,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: AppColors.accent.withOpacity(0.3)),
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
                      color: isDark
                          ? AppColors.moonGrey
                          : Colors.grey[700],
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

// ─────────────────────────────────────────────────────────────────────────────
// FAVOURITES SCREEN
// ─────────────────────────────────────────────────────────────────────────────

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
            Text('FAVOURITES',
                style: TextStyle(letterSpacing: 2, fontSize: 15)),
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
                      border: Border.all(
                          color: AppColors.divider, width: 1.5),
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
                      color: isDark
                          ? AppColors.starWhite
                          : AppColors.spaceBlue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tap the heart on an image to save it here',
                    style: TextStyle(
                        color: AppColors.moonGrey, fontSize: 14),
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
                    color:
                        isDark ? AppColors.cardDark : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: AppColors.divider.withOpacity(0.5)),
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
                                child: const Icon(
                                    Icons.broken_image_outlined,
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
                        color: isDark
                            ? AppColors.starWhite
                            : AppColors.spaceBlue,
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

// ─────────────────────────────────────────────────────────────────────────────
// SETTINGS SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class SettingsScreen extends StatefulWidget {
  final bool darkMode;
  final bool largeText;
  final ValueChanged<bool> onDarkModeChanged;
  final ValueChanged<bool> onLargeTextChanged;

  const SettingsScreen({
    super.key,
    required this.darkMode,
    required this.largeText,
    required this.onDarkModeChanged,
    required this.onLargeTextChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _hapticFeedback = true;

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

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    Color iconColor = AppColors.accentGlow,
  }) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border:
            Border.all(color: AppColors.divider.withOpacity(0.4)),
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
          style: const TextStyle(
              color: AppColors.moonGrey, fontSize: 12),
        ),
        value: value,
        onChanged: (val) {
          if (_hapticFeedback) HapticFeedback.lightImpact();
          onChanged(val);
        },
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
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
            icon: Icons.dark_mode_rounded,
            title: 'Dark Mode',
            subtitle: 'Switch to space-dark theme',
            value: widget.darkMode,
            onChanged: widget.onDarkModeChanged,
            iconColor: const Color(0xFF9575CD),
          ),
          _buildSettingsTile(
            icon: Icons.text_fields_rounded,
            title: 'Large Text',
            subtitle: 'Increase text size for readability',
            value: widget.largeText,
            onChanged: widget.onLargeTextChanged,
            iconColor: AppColors.accentGlow,
          ),
          _buildSectionLabel('INTERACTION'),
          _buildSettingsTile(
            icon: Icons.vibration_rounded,
            title: 'Haptic Feedback',
            subtitle: 'Vibrate on interactions',
            value: _hapticFeedback,
            onChanged: (val) => setState(() => _hapticFeedback = val),
            iconColor: const Color(0xFF81C784),
          ),
          _buildSectionLabel('INFO'),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: AppColors.divider.withOpacity(0.4)),
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
                  color: isDark
                      ? AppColors.starWhite
                      : AppColors.spaceBlue,
                ),
              ),
              subtitle: const Text('About NASA Explorer',
                  style: TextStyle(
                      color: AppColors.moonGrey, fontSize: 12)),
              trailing: const Icon(Icons.chevron_right_rounded,
                  color: AppColors.moonGrey),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const AboutScreen()),
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

// ─────────────────────────────────────────────────────────────────────────────
// ABOUT SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ABOUT',
            style: TextStyle(letterSpacing: 2, fontSize: 15)),
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
                  color: isDark
                      ? AppColors.starWhite
                      : AppColors.spaceBlue,
                ),
              ),
            ),
            const SizedBox(height: 4),
            const Center(
              child: Text(
                'Version 1.0.0',
                style: TextStyle(
                    color: AppColors.moonGrey, fontSize: 13),
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

  Widget _buildInfoCard(BuildContext context, bool isDark,
      {required IconData icon,
      required String title,
      required String content}) {
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
                    color: isDark
                        ? AppColors.starWhite
                        : AppColors.spaceBlue,
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