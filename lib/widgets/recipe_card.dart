import 'package:flutter/material.dart';

import '../models/recipe.dart';
import '../utils/recipe_labels.dart';
import '../utils/recipe_translations.dart';
import 'recipe_image.dart';

class RecipeCard extends StatelessWidget {
  const RecipeCard({
    super.key,
    required this.recipe,
    required this.isFavorite,
    required this.onTap,
    required this.onFavorite,
  });

  final Recipe recipe;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavorite;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(23),
        side: const BorderSide(color: Color(0xFFEAE5DC)),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 7,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  RecipeImage(imageUrl: recipe.image),
                  Positioned(
                    left: 12,
                    bottom: 12,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.94),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              recipe.isCustom
                                  ? Icons.edit_note_rounded
                                  : Icons.public_rounded,
                              size: 14,
                              color: const Color(0xFF52664F),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              recipe.isCustom
                                  ? 'สูตรของฉัน'
                                  : cuisineLabel(recipe.cuisine),
                              style: const TextStyle(
                                color: Color(0xFF465448),
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 11,
                    right: 11,
                    child: Material(
                      color: Colors.white.withValues(alpha: 0.96),
                      shape: const CircleBorder(),
                      child: IconButton(
                        tooltip: isFavorite
                            ? 'นำออกจากรายการโปรด'
                            : 'บันทึกเป็นรายการโปรด',
                        onPressed: onFavorite,
                        visualDensity: VisualDensity.compact,
                        iconSize: 20,
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
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 11),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      recipeNameLabel(recipe.name),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleSmall?.copyWith(
                        color: const Color(0xFF26382E),
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (!recipe.isCustom && recipe.rating > 0) ...[
                          const Icon(
                            Icons.star_rounded,
                            size: 15,
                            color: Color(0xFFE2A33A),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            recipe.rating.toStringAsFixed(1),
                            style: textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF554B3D),
                            ),
                          ),
                          const SizedBox(width: 10),
                        ],
                        const Icon(
                          Icons.schedule_rounded,
                          size: 14,
                          color: Color(0xFF8B8177),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            '${recipe.totalTimeMinutes} นาที',
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.labelSmall?.copyWith(
                              color: const Color(0xFF81786F),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
