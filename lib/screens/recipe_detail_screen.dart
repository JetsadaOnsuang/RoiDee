import 'package:flutter/material.dart';

import '../models/recipe.dart';
import '../services/recipe_store.dart';
import '../utils/recipe_labels.dart';
import '../utils/recipe_translations.dart';
import '../widgets/recipe_image.dart';
import 'add_recipe_screen.dart';

class RecipeDetailScreen extends StatelessWidget {
  const RecipeDetailScreen({
    super.key,
    required this.recipe,
    required this.store,
    required this.onToggleFavorite,
  });

  final Recipe recipe;
  final RecipeStore store;
  final ValueChanged<Recipe> onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, child) {
        final currentRecipe = store.recipeById(recipe.id) ?? recipe;
        final isFavorite = store.isFavorite(currentRecipe);
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 340,
                backgroundColor: const Color(0xFFFBF8F2),
                surfaceTintColor: Colors.transparent,
                leading: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Material(
                    color: Colors.white.withValues(alpha: 0.95),
                    shape: const CircleBorder(),
                    child: IconButton(
                      tooltip: 'กลับ',
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                  ),
                ),
                actions: [
                  if (currentRecipe.isCustom)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Material(
                        color: Colors.white.withValues(alpha: 0.95),
                        shape: const CircleBorder(),
                        child: IconButton(
                          tooltip: 'แก้ไขสูตรอาหาร',
                          onPressed: () => Navigator.of(context).push<void>(
                            MaterialPageRoute<void>(
                              builder: (context) => AddRecipeScreen(
                                store: store,
                                initialRecipe: currentRecipe,
                              ),
                            ),
                          ),
                          icon: const Icon(Icons.edit_outlined),
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Material(
                      color: Colors.white.withValues(alpha: 0.95),
                      shape: const CircleBorder(),
                      child: IconButton(
                        tooltip: isFavorite
                            ? 'นำออกจากเมนูโปรด'
                            : 'บันทึกเป็นเมนูโปรด',
                        onPressed: () => onToggleFavorite(currentRecipe),
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite
                              ? const Color(0xFFD96B3B)
                              : const Color(0xFF524A42),
                        ),
                      ),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      RecipeImage(imageUrl: currentRecipe.image),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.transparent, Color(0x70202E24)],
                            begin: Alignment.center,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 24,
                        bottom: 24,
                        child: _Tag(
                          label: currentRecipe.isCustom
                              ? 'สูตรจากครัวของฉัน'
                              : cuisineLabel(currentRecipe.cuisine),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 820),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(22, 26, 22, 48),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _Tag(
                                label: currentRecipe.isCustom
                                    ? 'สูตรของฉัน'
                                    : cuisineLabel(currentRecipe.cuisine),
                                light: true,
                              ),
                              if (currentRecipe.difficulty.isNotEmpty)
                                _Tag(
                                  label: difficultyLabel(
                                    currentRecipe.difficulty,
                                  ),
                                  light: true,
                                  green: true,
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            recipeNameLabel(currentRecipe.name),
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  color: const Color(0xFF26382E),
                                  fontWeight: FontWeight.w800,
                                  height: 1.1,
                                  letterSpacing: -0.6,
                                ),
                          ),
                          const SizedBox(height: 18),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              _InfoItem(
                                icon: Icons.schedule_rounded,
                                label: 'ใช้เวลาทั้งหมด',
                                value: '${currentRecipe.totalTimeMinutes} นาที',
                              ),
                              _InfoItem(
                                icon: Icons.restaurant_menu_rounded,
                                label: 'จำนวนที่ได้',
                                value: '${currentRecipe.servings}',
                              ),
                              if (!currentRecipe.isCustom &&
                                  currentRecipe.rating > 0)
                                _InfoItem(
                                  icon: Icons.star_rounded,
                                  label: 'คะแนน',
                                  value: currentRecipe.rating.toStringAsFixed(
                                    1,
                                  ),
                                  iconColor: const Color(0xFFE2A33A),
                                ),
                            ],
                          ),
                          const SizedBox(height: 30),
                          _SectionTitle(
                            title: 'วัตถุดิบ',
                            subtitle:
                                '${currentRecipe.ingredients.length} รายการ',
                          ),
                          const SizedBox(height: 12),
                          if (currentRecipe.ingredients.isEmpty)
                            const _EmptyText(text: 'ยังไม่มีข้อมูลวัตถุดิบ')
                          else
                          _IngredientList(
                            ingredients: currentRecipe.ingredients
                                .map(ingredientLabel)
                                .toList(growable: false),
                          ),
                          const SizedBox(height: 30),
                          _SectionTitle(
                            title: 'วิธีทำ',
                            subtitle:
                                '${currentRecipe.instructions.length} ขั้นตอน',
                          ),
                          const SizedBox(height: 12),
                          if (currentRecipe.instructions.isEmpty)
                            const _EmptyText(text: 'ยังไม่มีวิธีทำ')
                          else
                            _InstructionList(
                              instructions: currentRecipe.instructions
                                  .map(instructionLabel)
                                  .toList(growable: false),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, this.light = false, this.green = false});

  final String label;
  final bool light;
  final bool green;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: light
            ? green
                  ? const Color(0xFFEAF0E7)
                  : const Color(0xFFFFEEE3)
            : Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        child: Text(
          label.toUpperCase(),
          style: TextStyle(
            color: green ? const Color(0xFF536C54) : const Color(0xFFB85C24),
            fontWeight: FontWeight.w800,
            fontSize: 10,
            letterSpacing: 0.6,
          ),
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor = const Color(0xFFD96B3B),
  });

  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 112),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEAE5DC)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 19, color: iconColor),
          const SizedBox(width: 9),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                difficultyLabel(label),
                style: const TextStyle(color: Color(0xFF81786F), fontSize: 11),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: Color(0xFF26382E),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: const Color(0xFF26382E),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Text(
          subtitle,
          style: const TextStyle(
            color: Color(0xFF81786F),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _IngredientList extends StatelessWidget {
  const _IngredientList({required this.ingredients});

  final List<String> ingredients;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEAE5DC)),
      ),
      child: Column(
        children: ingredients.indexed.map((entry) {
          final index = entry.$1;
          final ingredient = entry.$2;
          return Padding(
            padding: EdgeInsets.fromLTRB(
              17,
              index == 0 ? 15 : 11,
              17,
              index == ingredients.length - 1 ? 15 : 11,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.circle, size: 8, color: Color(0xFFD96B3B)),
                const SizedBox(width: 13),
                Expanded(
                  child: Text(
                    ingredient,
                    style: const TextStyle(fontSize: 15, height: 1.4),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _InstructionList extends StatelessWidget {
  const _InstructionList({required this.instructions});

  final List<String> instructions;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: instructions.indexed.map((entry) {
        final step = entry.$1 + 1;
        final instruction = entry.$2;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFEAE5DC)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEAF0E7),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$step',
                      style: const TextStyle(
                        color: Color(0xFF536C54),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        instruction,
                        style: const TextStyle(fontSize: 15, height: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _EmptyText extends StatelessWidget {
  const _EmptyText({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(text, style: const TextStyle(color: Color(0xFF81786F))),
    );
  }
}
