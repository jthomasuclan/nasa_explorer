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
      } else {
        developer.log('API error: ${response.statusCode}', name: 'NasaApiService');
        return null;
      }
    } catch (e) {
      developer.log('Network error: $e', name: 'NasaApiService');
      return null;
    }
  }
}

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

class NasaApp extends StatefulWidget {
  const NasaApp({super.key});

  @override
  State<NasaApp> createState() => _NasaAppState();
}

class _NasaAppState extends State<NasaApp> {
  bool _darkMode = false;
  bool _largeText = false;

  void updateDarkMode(bool val) => setState(() => _darkMode = val);
  void updateLargeText(bool val) => setState(() => _largeText = val);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NASA Explorer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0B3D91),
          brightness: _darkMode ? Brightness.dark : Brightness.light,
        ),
        useMaterial3: true,
        textTheme: _largeText
            ? const TextTheme(
                bodyMedium: TextStyle(fontSize: 17),
                bodyLarge: TextStyle(fontSize: 19),
                titleLarge: TextStyle(fontSize: 24),
              )
            : null,
      ),
      home: MainScreen(
        darkMode: _darkMode,
        largeText: _largeText,
        onDarkModeChanged: updateDarkMode,
        onLargeTextChanged: updateLargeText,
      ),
    );
  }
}

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
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: const Color(0xFF0B3D91),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favourites'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}

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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'NASA Picture of the Day',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF0B3D91),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_noConnection) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No Internet Connection',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please check your connection and try again',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0B3D91),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF0B3D91)),
            SizedBox(height: 16),
            Text('Fetching from NASA...'),
          ],
        ),
      );
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Could not load NASA data',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Check your API key or try again later',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0B3D91),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    if (_apod == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_apod!.mediaType == 'image')
            Image.network(
              _apod!.url,
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Container(
                  width: double.infinity,
                  height: 250,
                  color: Colors.grey[300],
                  child: const Center(
                    child: CircularProgressIndicator(color: Color(0xFF0B3D91)),
                  ),
                );
              },
              errorBuilder: (context, error, stack) {
                return Container(
                  width: double.infinity,
                  height: 250,
                  color: Colors.grey[300],
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.broken_image, size: 60, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('Image unavailable',
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                );
              },
            )
          else
            Container(
              width: double.infinity,
              height: 250,
              color: Colors.grey[300],
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.videocam, size: 60, color: Colors.grey),
                    SizedBox(height: 8),
                    Text("Today's content is a video",
                        style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _apod!.title,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Date: ${_apod!.date}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                const SizedBox(height: 12),
                Text(
                  _apod!.explanation,
                  style: const TextStyle(fontSize: 15, height: 1.5),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    IconButton(
                      onPressed: _toggleFavourite,
                      icon: Icon(
                        _isFavourited
                            ? Icons.favorite
                            : Icons.favorite_border,
                      ),
                      color: Colors.red,
                      iconSize: 32,
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.share),
                      color: const Color(0xFF0B3D91),
                      iconSize: 32,
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetailScreen(apod: _apod!),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0B3D91),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('View Details'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DetailScreen extends StatelessWidget {
  final ApodData apod;

  const DetailScreen({super.key, required this.apod});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(apod.title),
        backgroundColor: const Color(0xFF0B3D91),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (apod.mediaType == 'image')
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  apod.url,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 16),
            Text(
              apod.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(apod.date, style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 16),
            Text(
              apod.explanation,
              style: const TextStyle(fontSize: 15, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}

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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Favourites',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF0B3D91),
        foregroundColor: Colors.white,
      ),
      body: _favourites.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No favourites yet',
                      style: TextStyle(fontSize: 18, color: Colors.grey)),
                  SizedBox(height: 8),
                  Text('Like an image to save it here',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _favourites.length,
              itemBuilder: (context, index) {
                final apod = _favourites[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: apod.mediaType == 'image'
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.network(
                              apod.url,
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.broken_image),
                            ),
                          )
                        : const Icon(Icons.videocam, size: 40),
                    title: Text(
                      apod.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(apod.date),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF0B3D91),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'APPEARANCE',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                letterSpacing: 1.2,
              ),
            ),
          ),
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Switch to dark theme'),
            secondary: const Icon(Icons.dark_mode),
            value: widget.darkMode,
            activeColor: const Color(0xFF0B3D91),
            onChanged: (val) {
              if (_hapticFeedback) HapticFeedback.lightImpact();
              widget.onDarkModeChanged(val);
            },
          ),
          SwitchListTile(
            title: const Text('Large Text'),
            subtitle: const Text('Increase text size'),
            secondary: const Icon(Icons.text_fields),
            value: widget.largeText,
            activeColor: const Color(0xFF0B3D91),
            onChanged: (val) {
              if (_hapticFeedback) HapticFeedback.lightImpact();
              widget.onLargeTextChanged(val);
            },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(
              'INTERACTION',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                letterSpacing: 1.2,
              ),
            ),
          ),
          SwitchListTile(
            title: const Text('Haptic Feedback'),
            subtitle: const Text('Vibrate on interactions'),
            secondary: const Icon(Icons.vibration),
            value: _hapticFeedback,
            activeColor: const Color(0xFF0B3D91),
            onChanged: (val) => setState(() => _hapticFeedback = val),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            subtitle: const Text('About NASA Explorer'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
        backgroundColor: const Color(0xFF0B3D91),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Icon(
                Icons.rocket_launch,
                size: 80,
                color: Color(0xFF0B3D91),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'NASA Explorer',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Version 1.0.0'),
            const SizedBox(height: 24),
            const Text(
              'About this App',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'NASA Explorer displays the NASA Picture of the Day using NASA\'s public APOD API. Every day NASA publishes a new image of our universe with an explanation by a professional astronomer.',
              style: TextStyle(fontSize: 15, height: 1.6),
            ),
            const SizedBox(height: 24),
            const Text(
              'Data Source',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'All images and data are sourced from NASA\'s APOD API at api.nasa.gov',
              style: TextStyle(fontSize: 15, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}