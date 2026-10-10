import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/recipe.dart';

class RecipeService {
  RecipeService({http.Client? client}) : _client = client ?? http.Client();

  static final Uri _recipesUri = Uri.https('dummyjson.com', '/recipes');
  final http.Client _client;

  void close() => _client.close();

  Future<List<Recipe>> fetchRecipes() async {
    final response = await _client
        .get(_recipesUri)
        .timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      throw RecipeApiException(
        'Recipe service returned status ${response.statusCode}.',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic> || decoded['recipes'] is! List) {
      throw const FormatException('Recipe service returned invalid data.');
    }
    return (decoded['recipes'] as List)
        .whereType<Map<String, dynamic>>()
        .map(Recipe.fromJson)
        .toList(growable: false);
  }
}

class RecipeApiException implements Exception {
  const RecipeApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
