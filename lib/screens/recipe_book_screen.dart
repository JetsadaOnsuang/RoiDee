import 'package:flutter/material.dart';

import '../models/recipe.dart';
import '../services/recipe_store.dart';
import 'add_recipe_screen.dart';
import 'favorite_screen.dart';
import 'home_screen.dart';
import 'recipe_detail_screen.dart';

class RecipeBookScreen extends StatefulWidget {
  const RecipeBookScreen({super.key, required this.store});

  final RecipeStore store;

  @override
  State<RecipeBookScreen> createState() => _RecipeBookScreenState();
}

class _RecipeBookScreenState extends State<RecipeBookScreen> {
  int _selectedIndex = 0;

  Future<void> _openRecipe(Recipe recipe) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => RecipeDetailScreen(
          recipe: recipe,
          store: widget.store,
          onToggleFavorite: _toggleFavorite,
        ),
      ),
    );
  }

  Future<void> _toggleFavorite(Recipe recipe) async {
    try {
      await widget.store.toggleFavorite(recipe);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Bad state: ', '')),
        ),
      );
    }
  }

  Future<void> _openAddRecipe() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => AddRecipeScreen(store: widget.store),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 680;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: isWide ? 28 : 20,
        title: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFE8D9), Color(0xFFFFF1E7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.restaurant_menu_rounded,
                size: 23,
                color: Color(0xFFD96B3B),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'อร่อยดี',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.6,
                  ),
                ),
                if (isWide)
                  const Text(
                    'สมุดรวมสูตรอาหารของคุณ',
                    style: TextStyle(
                      color: Color(0xFF8B8177),
                      fontSize: 9,
                      letterSpacing: 1.15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
          ],
        ),
        actions: [
          if (isWide)
            Padding(
              padding: const EdgeInsets.only(right: 24),
              child: FilledButton.icon(
                onPressed: _openAddRecipe,
                icon: const Icon(Icons.add_rounded, size: 19),
                label: const Text('เพิ่มสูตรอาหาร'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF26382E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 13,
                  ),
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: IconButton.filledTonal(
                tooltip: 'เพิ่มสูตรอาหาร',
                onPressed: _openAddRecipe,
                icon: const Icon(Icons.add_rounded),
              ),
            ),
        ],
      ),
      body: AnimatedBuilder(
        animation: widget.store,
        builder: (context, child) => IndexedStack(
          index: _selectedIndex,
          children: [
            HomeScreen(
              store: widget.store,
              onOpenRecipe: _openRecipe,
              onToggleFavorite: _toggleFavorite,
            ),
            FavoriteScreen(
              store: widget.store,
              onOpenRecipe: _openRecipe,
              onToggleFavorite: _toggleFavorite,
            ),
          ],
        ),
      ),
      floatingActionButton: _selectedIndex == 0 && !isWide
          ? FloatingActionButton.extended(
              onPressed: _openAddRecipe,
              backgroundColor: const Color(0xFF26382E),
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_rounded),
              label: const Text('เพิ่มสูตร'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore_rounded),
            label: 'เมนูทั้งหมด',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border_rounded),
            selectedIcon: Icon(Icons.favorite_rounded),
            label: 'เมนูโปรด',
          ),
        ],
      ),
    );
  }
}
