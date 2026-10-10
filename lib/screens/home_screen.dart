import 'package:flutter/material.dart';

import '../models/recipe.dart';
import '../services/recipe_store.dart';
import '../utils/recipe_labels.dart';
import '../utils/recipe_translations.dart';
import '../widgets/recipe_card.dart';
import '../widgets/recipe_image.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.store,
    required this.onOpenRecipe,
    required this.onToggleFavorite,
  });

  final RecipeStore store;
  final ValueChanged<Recipe> onOpenRecipe;
  final ValueChanged<Recipe> onToggleFavorite;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  String? _selectedCuisine;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recipes = widget.store.recipes;
    final cuisines = [
      'ทั้งหมด',
      ...recipes
          .map((recipe) => recipe.cuisine)
          .toSet()
          .where((cuisine) => cuisine.isNotEmpty && cuisine != 'ทั้งหมด'),
    ];
    final query = _searchController.text.trim().toLowerCase();
    final filteredRecipes = recipes.where((recipe) {
      final matchesQuery =
          recipe.name.toLowerCase().contains(query) ||
          recipeNameLabel(recipe.name).toLowerCase().contains(query) ||
          recipe.ingredients.any(
            (ingredient) =>
                ingredient.toLowerCase().contains(query) ||
                ingredientLabel(ingredient).toLowerCase().contains(query),
          );
      final matchesCuisine =
          _selectedCuisine == null || recipe.cuisine == _selectedCuisine;
      return matchesQuery && matchesCuisine;
    }).toList();

    final featuredRecipes = recipes.where((recipe) => !recipe.isCustom).toList()
      ..sort((a, b) => b.rating.compareTo(a.rating));
    final featuredRecipe = featuredRecipes.isEmpty
        ? null
        : featuredRecipes.first;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final sidePadding = screenWidth > 1240 ? (screenWidth - 1160) / 2 : 22.0;

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(sidePadding, 8, sidePadding, 18),
          sliver: SliverToBoxAdapter(
            child: _FeaturedRecipeBanner(
              recipe: featuredRecipe,
              isLoading: widget.store.isLoading,
              onTap: featuredRecipe == null
                  ? null
                  : () => widget.onOpenRecipe(featuredRecipe),
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: sidePadding),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'รวมสูตรอาหาร',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: const Color(0xFFC66B45),
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.35,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'มื้อนี้ ทำเมนูอะไรดี?',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  color: const Color(0xFF26382E),
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.65,
                                ),
                          ),
                        ],
                      ),
                    ),
                    if (screenWidth >= 600)
                      _RecipeCountBadge(count: recipes.length),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'ค้นหาเมนู อาหาร หรือวัตถุดิบ',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _searchController.text.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'ล้างคำค้นหา',
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                            icon: const Icon(Icons.close_rounded),
                          ),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: cuisines.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final cuisine = cuisines[index];
                      final selected =
                          _selectedCuisine == cuisine ||
                          (cuisine == 'ทั้งหมด' && _selectedCuisine == null);
                      return ChoiceChip(
                        label: Text(
                          cuisine == 'ทั้งหมด'
                              ? 'ทั้งหมด'
                              : cuisineLabel(cuisine),
                        ),
                        selected: selected,
                        showCheckmark: false,
                        onSelected: (_) => setState(
                          () => _selectedCuisine = cuisine == 'ทั้งหมด'
                              ? null
                              : cuisine,
                        ),
                        backgroundColor: Colors.white,
                        selectedColor: const Color(0xFF26382E),
                        labelStyle: TextStyle(
                          color: selected
                              ? Colors.white
                              : const Color(0xFF625A51),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                        side: BorderSide(
                          color: selected
                              ? const Color(0xFF26382E)
                              : const Color(0xFFECE6DE),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        if (widget.store.storageError != null)
          SliverPadding(
            padding: EdgeInsets.fromLTRB(sidePadding, 12, sidePadding, 0),
            sliver: SliverToBoxAdapter(
              child: _InlineNotice(
                message: widget.store.storageError!,
                icon: Icons.warning_amber_rounded,
              ),
            ),
          ),
        if (widget.store.apiError != null)
          SliverPadding(
            padding: EdgeInsets.fromLTRB(sidePadding, 12, sidePadding, 0),
            sliver: SliverToBoxAdapter(
              child: _InlineNotice(
                message: widget.store.apiError!,
                icon: Icons.cloud_off_rounded,
                action: TextButton(
                  onPressed: widget.store.load,
                  child: const Text('ลองอีกครั้ง'),
                ),
              ),
            ),
          ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(sidePadding, 24, sidePadding, 12),
          sliver: SliverToBoxAdapter(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedCuisine == null
                        ? 'สูตรอาหารทั้งหมด'
                        : 'สูตรอาหาร${cuisineLabel(_selectedCuisine!)}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: const Color(0xFF26382E),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  'พบ ${filteredRecipes.length} เมนู',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF81786F),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (widget.store.isLoading && recipes.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: CircularProgressIndicator()),
          )
        else if (filteredRecipes.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: _EmptyResults(
              hasError: widget.store.apiError != null,
              onRetry: widget.store.load,
            ),
          )
        else
          SliverLayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.crossAxisExtent >= 1050
                  ? 4
                  : constraints.crossAxisExtent >= 650
                  ? 3
                  : 2;
              return SliverPadding(
                padding: EdgeInsets.fromLTRB(sidePadding, 0, sidePadding, 30),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: columns == 2 ? 0.78 : 0.82,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final recipe = filteredRecipes[index];
                    return RecipeCard(
                      recipe: recipe,
                      isFavorite: widget.store.isFavorite(recipe),
                      onTap: () => widget.onOpenRecipe(recipe),
                      onFavorite: () => widget.onToggleFavorite(recipe),
                    );
                  }, childCount: filteredRecipes.length),
                ),
              );
            },
          ),
      ],
    );
  }
}

class _FeaturedRecipeBanner extends StatelessWidget {
  const _FeaturedRecipeBanner({
    required this.recipe,
    required this.isLoading,
    required this.onTap,
  });

  final Recipe? recipe;
  final bool isLoading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final height = width < 600 ? 205.0 : 250.0;
    return SizedBox(
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (recipe != null)
              RecipeImage(imageUrl: recipe!.image)
            else
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF45624C), Color(0xFF26382E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xE61C3028),
                    Color(0xA61C3028),
                    Color(0x201C3028),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
            Positioned(
              right: -18,
              top: -24,
              child: Icon(
                Icons.soup_kitchen_rounded,
                size: height + 24,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(width < 600 ? 20 : 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E8).withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white30),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 6,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.auto_awesome_rounded,
                            size: 14,
                            color: Color(0xFFFFD08A),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isLoading ? 'กำลังเตรียมเมนู' : 'เมนูแนะนำ',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: width < 600 ? width * 0.77 : 560,
                    ),
                    child: Text(
                      (recipe == null
                          ? null
                          : recipeNameLabel(recipe!.name)) ??
                          (isLoading
                              ? 'เมนูอร่อยกำลังมาแล้ว'
                              : 'เริ่มต้นวันดี ๆ ด้วยมื้ออร่อย'),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: Colors.white,
                            height: 1.08,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                          ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (recipe != null) ...[
                        const Icon(
                          Icons.star_rounded,
                          color: Color(0xFFFFD17A),
                          size: 17,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          recipe!.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Icon(
                          Icons.schedule_rounded,
                          color: Colors.white70,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${recipe!.totalTimeMinutes} นาที',
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(width: 14),
                        Flexible(
                          child: Text(
                            cuisineLabel(recipe!.cuisine),
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ),
                      ] else
                        const Text(
                          'หาไอเดียเมนูอร่อย ๆ ได้ทุกวัน',
                          style: TextStyle(color: Colors.white70),
                        ),
                      const Spacer(),
                      if (onTap != null)
                        FilledButton.tonalIcon(
                          onPressed: onTap,
                          icon: const Icon(
                            Icons.arrow_outward_rounded,
                            size: 17,
                          ),
                          label: const Text('ดูสูตร'),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF26382E),
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecipeCountBadge extends StatelessWidget {
  const _RecipeCountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF1EADF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.menu_book_rounded,
            size: 16,
            color: Color(0xFF53634F),
          ),
          const SizedBox(width: 6),
          Text(
            '$count สูตร',
            style: const TextStyle(
              color: Color(0xFF53634F),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineNotice extends StatelessWidget {
  const _InlineNotice({required this.message, required this.icon, this.action});

  final String message;
  final IconData icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1E7),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFB85C24), size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(message, style: const TextStyle(fontSize: 12))),
          ?action,
        ],
      ),
    );
  }
}

class _EmptyResults extends StatelessWidget {
  const _EmptyResults({required this.hasError, required this.onRetry});

  final bool hasError;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: const BoxDecoration(
              color: Color(0xFFF1EADF),
              shape: BoxShape.circle,
            ),
            child: Icon(
              hasError ? Icons.cloud_off_rounded : Icons.search_off_rounded,
              size: 32,
              color: const Color(0xFF75816F),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            hasError ? 'โหลดเมนูไม่สำเร็จ' : 'ไม่พบเมนูที่ค้นหา',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 5),
          Text(
            hasError
                ? 'ตรวจสอบอินเทอร์เน็ต แล้วกด “ลองอีกครั้ง”'
                : 'ลองพิมพ์คำอื่น หรือเลือกประเภทอาหารอื่น',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF81786F)),
          ),
          if (hasError) ...[
            const SizedBox(height: 14),
            FilledButton.tonal(
              onPressed: onRetry,
              child: const Text('ลองอีกครั้ง'),
            ),
          ],
        ],
      ),
    );
  }
}
