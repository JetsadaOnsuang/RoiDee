import 'package:flutter/material.dart';

import 'screens/recipe_book_screen.dart';
import 'services/recipe_store.dart';
import 'utils/register_image_picker_stub.dart'
    if (dart.library.js_interop) 'utils/register_image_picker_web.dart'
    as web_image_picker;

void main() {
  web_image_picker.registerImagePicker();
  runApp(const RecipeBookApp());
}

class RecipeBookApp extends StatefulWidget {
  const RecipeBookApp({super.key});

  @override
  State<RecipeBookApp> createState() => _RecipeBookAppState();
}

class _RecipeBookAppState extends State<RecipeBookApp> {
  late final RecipeStore _store;

  @override
  void initState() {
    super.initState();
    _store = RecipeStore()..load();
  }

  @override
  void dispose() {
    _store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const seedColor = Color(0xFFD96B3B);
    const inkColor = Color(0xFF26382E);
    return MaterialApp(
      title: 'อร่อยดี - สมุดสูตรอาหาร',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          surface: const Color(0xFFFBF8F2),
        ),
        scaffoldBackgroundColor: const Color(0xFFFBF8F2),
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFBF8F2),
          foregroundColor: inkColor,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          toolbarHeight: 72,
          titleTextStyle: TextStyle(
            color: inkColor,
            fontSize: 17,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.7,
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: const BorderSide(color: Color(0xFFECE7DE)),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          height: 72,
          backgroundColor: const Color(0xFFFFFDF9),
          indicatorColor: const Color(0xFFFFE6D9),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            return TextStyle(
              fontSize: 12,
              fontWeight: states.contains(WidgetState.selected)
                  ? FontWeight.w700
                  : FontWeight.w500,
            );
          }),
          elevation: 8,
          shadowColor: const Color(0x1A26382E),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 17,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFECE6DE)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: seedColor, width: 1.6),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFBE4A3A)),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFBE4A3A), width: 1.6),
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      home: RecipeBookScreen(store: _store),
    );
  }
}
