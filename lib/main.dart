import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'config/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_colors.dart';
import 'screens/home_screen.dart';
import 'screens/favourites_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/account_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAuth.instance.signInAnonymously();
  runApp(const NasaApp());
}

class NasaApp extends StatefulWidget {
  const NasaApp({super.key});

  @override
  State<NasaApp> createState() => _NasaAppState();
}

class _NasaAppState extends State<NasaApp> {
  bool _darkMode = true;
  bool _largeText = false;
  bool _hapticFeedback = true;

  void updateDarkMode(bool val) => setState(() => _darkMode = val);
  void updateLargeText(bool val) => setState(() => _largeText = val);
  void updateHapticFeedback(bool val) => setState(() => _hapticFeedback = val);

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: _largeText
            ? const TextScaler.linear(1.25)
            : const TextScaler.linear(1.0),
      ),
      child: MaterialApp(
        title: 'NASA Explorer',
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(_darkMode),
        home: MainScreen(
          darkMode: _darkMode,
          largeText: _largeText,
          hapticFeedback: _hapticFeedback,
          onDarkModeChanged: updateDarkMode,
          onLargeTextChanged: updateLargeText,
          onHapticFeedbackChanged: updateHapticFeedback,
        ),
      ),
    );
  }

  ThemeData _buildTheme(bool dark) {
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

class MainScreen extends StatefulWidget {
  final bool darkMode;
  final bool largeText;
  final bool hapticFeedback;
  final ValueChanged<bool> onDarkModeChanged;
  final ValueChanged<bool> onLargeTextChanged;
  final ValueChanged<bool> onHapticFeedbackChanged;

  const MainScreen({
    super.key,
    required this.darkMode,
    required this.largeText,
    required this.hapticFeedback,
    required this.onDarkModeChanged,
    required this.onLargeTextChanged,
    required this.onHapticFeedbackChanged,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(hapticFeedback: widget.hapticFeedback),
      const FavouritesScreen(),
      SettingsScreen(
        darkMode: widget.darkMode,
        largeText: widget.largeText,
        hapticFeedback: widget.hapticFeedback,
        onDarkModeChanged: widget.onDarkModeChanged,
        onLargeTextChanged: widget.onLargeTextChanged,
        onHapticFeedbackChanged: widget.onHapticFeedbackChanged,
      ),
      const AccountScreen(),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (widget.hapticFeedback) HapticFeedback.selectionClick();
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
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}