class Recipe {
  const Recipe({
    required this.id,
    required this.name,
    required this.image,
    required this.ingredients,
    required this.instructions,
    required this.prepTimeMinutes,
    required this.cookTimeMinutes,
    required this.servings,
    required this.cuisine,
    required this.rating,
    this.difficulty = '',
    this.isCustom = false,
  });

  final int id;
  final String name;
  final String image;
  final List<String> ingredients;
  final List<String> instructions;
  final int prepTimeMinutes;
  final int cookTimeMinutes;
  final int servings;
  final String cuisine;
  final double rating;
  final String difficulty;
  final bool isCustom;

  int get totalTimeMinutes => prepTimeMinutes + cookTimeMinutes;

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: _asInt(json['id']),
      name: json['name'] as String? ?? 'ไม่มีชื่อเมนู',
      image: json['image'] as String? ?? '',
      ingredients: _asStringList(json['ingredients']),
      instructions: _asStringList(json['instructions']),
      prepTimeMinutes: _asInt(json['prepTimeMinutes']),
      cookTimeMinutes: _asInt(json['cookTimeMinutes']),
      servings: _asInt(json['servings'], fallback: 1),
      cuisine: json['cuisine'] as String? ?? 'Homemade',
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      difficulty: json['difficulty'] as String? ?? '',
      isCustom: json['isCustom'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'image': image,
    'ingredients': ingredients,
    'instructions': instructions,
    'prepTimeMinutes': prepTimeMinutes,
    'cookTimeMinutes': cookTimeMinutes,
    'servings': servings,
    'cuisine': cuisine,
    'rating': rating,
    'difficulty': difficulty,
    'isCustom': isCustom,
  };

  static int _asInt(dynamic value, {int fallback = 0}) {
    return value is num ? value.toInt() : fallback;
  }

  static List<String> _asStringList(dynamic value) {
    if (value is! List) return const [];
    return value.whereType<String>().toList(growable: false);
  }
}
