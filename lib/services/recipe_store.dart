import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/recipe.dart';
import 'recipe_service.dart';

class RecipeStore extends ChangeNotifier {
  RecipeStore({RecipeService? recipeService})
    : _recipeService = recipeService ?? RecipeService();

  static const _customRecipesKey = 'custom_recipes';
  static const _favoriteIdsKey = 'favorite_recipe_ids';

  final RecipeService _recipeService;
  List<Recipe> _apiRecipes = [];
  List<Recipe> _customRecipes = [];
  Set<int> _favoriteIds = {};
  bool _isLoading = true;
  String? _apiError;
  String? _storageError;

  List<Recipe> get recipes => [..._customRecipes, ..._apiRecipes];
  List<Recipe> get favoriteRecipes =>
      recipes.where((recipe) => _favoriteIds.contains(recipe.id)).toList();
  Recipe? recipeById(int id) {
    for (final recipe in _customRecipes) {
      if (recipe.id == id) return recipe;
    }
    for (final recipe in _apiRecipes) {
      if (recipe.id == id) return recipe;
    }
    return null;
  }

  bool get isLoading => _isLoading;
  String? get apiError => _apiError;
  String? get storageError => _storageError;

  bool isFavorite(Recipe recipe) => _favoriteIds.contains(recipe.id);

  @override
  void dispose() {
    _recipeService.close();
    super.dispose();
  }

  Future<void> load() async {
    _isLoading = true;
    _apiError = null;
    notifyListeners();

    try {
      final preferences = await SharedPreferences.getInstance();
      final customJson = preferences.getString(_customRecipesKey);
      if (customJson != null) {
        final decoded = jsonDecode(customJson);
        if (decoded is! List) {
          throw const FormatException('Saved recipes have an invalid format.');
        }
        _customRecipes = decoded
            .whereType<Map<String, dynamic>>()
            .map(Recipe.fromJson)
            .toList();
      }

      final favoriteJson = preferences.getStringList(_favoriteIdsKey) ?? [];
      _favoriteIds = favoriteJson.map(int.parse).toSet();
      _storageError = null;
    } catch (error) {
      _storageError = 'โหลดสูตรที่บันทึกไว้ไม่สำเร็จ';
    }

    try {
      _apiRecipes = await _recipeService.fetchRecipes();
      _apiError = null;
    } catch (error) {
      _apiError = 'โหลดสูตรอาหารไม่สำเร็จ กรุณาตรวจสอบอินเทอร์เน็ตแล้วลองใหม่';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(Recipe recipe) async {
    final updated = Set<int>.from(_favoriteIds);
    if (!updated.add(recipe.id)) updated.remove(recipe.id);

    try {
      final preferences = await SharedPreferences.getInstance();
      final saved = await preferences.setStringList(
        _favoriteIdsKey,
        updated.map((id) => id.toString()).toList(),
      );
      if (!saved) throw StateError('อุปกรณ์ไม่สามารถบันทึกรายการโปรดได้');
      _favoriteIds = updated;
      notifyListeners();
    } catch (error) {
      throw StateError('บันทึกรายการโปรดไม่สำเร็จ');
    }
  }

  Future<void> addCustomRecipe({
    required String name,
    required String cuisine,
    String image = '',
    required List<String> ingredients,
    required List<String> instructions,
    required int prepTimeMinutes,
    required int cookTimeMinutes,
    required int servings,
  }) async {
    final recipe = Recipe(
      id: -DateTime.now().microsecondsSinceEpoch,
      name: name,
      image: image,
      ingredients: ingredients,
      instructions: instructions,
      prepTimeMinutes: prepTimeMinutes,
      cookTimeMinutes: cookTimeMinutes,
      servings: servings,
      cuisine: cuisine.isEmpty ? 'Homemade' : cuisine,
      rating: 0,
      isCustom: true,
    );
    final updated = [..._customRecipes, recipe];

    try {
      final preferences = await SharedPreferences.getInstance();
      final saved = await preferences.setString(
        _customRecipesKey,
        jsonEncode(updated.map((item) => item.toJson()).toList()),
      );
      if (!saved) throw StateError('อุปกรณ์ไม่สามารถบันทึกสูตรอาหารได้');
      _customRecipes = updated;
      notifyListeners();
    } catch (error) {
      throw StateError('บันทึกสูตรอาหารไม่สำเร็จ');
    }
  }

  Future<void> updateCustomRecipe({
    required int id,
    required String name,
    required String cuisine,
    required String image,
    required List<String> ingredients,
    required List<String> instructions,
    required int prepTimeMinutes,
    required int cookTimeMinutes,
    required int servings,
  }) async {
    final index = _customRecipes.indexWhere((recipe) => recipe.id == id);
    if (index == -1) throw StateError('ไม่พบสูตรอาหารที่ต้องการแก้ไข');

    final updatedRecipe = Recipe(
      id: id,
      name: name,
      image: image,
      ingredients: ingredients,
      instructions: instructions,
      prepTimeMinutes: prepTimeMinutes,
      cookTimeMinutes: cookTimeMinutes,
      servings: servings,
      cuisine: cuisine.isEmpty ? 'Homemade' : cuisine,
      rating: _customRecipes[index].rating,
      difficulty: _customRecipes[index].difficulty,
      isCustom: true,
    );
    final updated = [..._customRecipes]..[index] = updatedRecipe;

    try {
      final preferences = await SharedPreferences.getInstance();
      final saved = await preferences.setString(
        _customRecipesKey,
        jsonEncode(updated.map((item) => item.toJson()).toList()),
      );
      if (!saved) throw StateError('อุปกรณ์ไม่สามารถบันทึกสูตรอาหารได้');
      _customRecipes = updated;
      notifyListeners();
    } catch (error) {
      throw StateError('แก้ไขสูตรอาหารไม่สำเร็จ');
    }
  }
}
