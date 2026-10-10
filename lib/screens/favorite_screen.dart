import 'package:flutter/material.dart';

import '../models/recipe.dart';
import '../services/recipe_store.dart';
import '../widgets/recipe_card.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({
    super.key,
    required this.store,
    required this.onOpenRecipe,
    required this.onToggleFavorite,
  });

  final RecipeStore store;
  final ValueChanged<Recipe> onOpenRecipe;
  final ValueChanged<Recipe> onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    final recipes = store.favoriteRecipes;
    if (recipes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFEEE3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.favorite_border_rounded,
                  size: 36,
                  color: Color(0xFFE87532),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'ยังไม่มีเมนูที่บันทึกไว้',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              const Text(
                'แตะรูปหัวใจบนเมนูที่ชอบ เพื่อบันทึกไว้ดูภายหลัง',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF81786F)),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'เมนูโปรดของฉัน',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'บันทึกไว้แล้ว ${recipes.length} เมนู',
                style: const TextStyle(color: Color(0xFF81786F)),
              ),
            ],
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 650 ? 3 : 2;
              return GridView.builder(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: columns == 2 ? 0.78 : 0.86,
                ),
                itemCount: recipes.length,
                itemBuilder: (context, index) {
                  final recipe = recipes[index];
                  return RecipeCard(
                    recipe: recipe,
                    isFavorite: true,
                    onTap: () => onOpenRecipe(recipe),
                    onFavorite: () => onToggleFavorite(recipe),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
