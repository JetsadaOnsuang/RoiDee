import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:recipe_book/models/recipe.dart';
import 'package:recipe_book/screens/add_recipe_screen.dart';
import 'package:recipe_book/screens/recipe_book_screen.dart';
import 'package:recipe_book/screens/recipe_detail_screen.dart';
import 'package:recipe_book/services/recipe_service.dart';
import 'package:recipe_book/services/recipe_store.dart';
import 'package:recipe_book/utils/recipe_content_translations.dart';
import 'package:recipe_book/utils/recipe_translations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('explore displays recipes and favorites can be saved', (
    tester,
  ) async {
    final recipe = _sampleRecipe();
    final store = RecipeStore(recipeService: _FakeRecipeService([recipe]));
    await tester.pumpWidget(MaterialApp(home: RecipeBookScreen(store: store)));
    await store.load();
    await tester.pumpAndSettle();
    expect(find.text('Sunday pancakes'), findsOneWidget);

    await tester.drag(
      find.byType(CustomScrollView).first,
      const Offset(0, -600),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byTooltip('บันทึกเป็นรายการโปรด'));
    await tester.tap(find.byTooltip('บันทึกเป็นรายการโปรด'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('เมนูโปรด'));
    await tester.pumpAndSettle();

    expect(find.text('Sunday pancakes'), findsOneWidget);
    expect(store.isFavorite(recipe), isTrue);
    store.dispose();
  });

  testWidgets('add recipe form validates required fields', (tester) async {
    final store = RecipeStore(recipeService: _FakeRecipeService([]));
    await tester.pumpWidget(MaterialApp(home: AddRecipeScreen(store: store)));

    await tester.ensureVisible(find.text('บันทึกสูตรอาหาร'));
    await tester.tap(find.text('บันทึกสูตรอาหาร'));
    await tester.pumpAndSettle();

    expect(find.text('กรุณาใส่ชื่อเมนู'), findsOneWidget);
    expect(find.text('กรุณาใส่วัตถุดิบอย่างน้อย 1 อย่าง'), findsOneWidget);
    expect(find.text('กรุณาใส่วิธีทำอย่างน้อย 1 ขั้นตอน'), findsOneWidget);
    expect(find.text('รูปอาหาร (ไม่บังคับ)'), findsOneWidget);
    expect(find.text('เลือกรูปจากเครื่อง'), findsOneWidget);
    store.dispose();
  });

  test(
    'custom recipes can be edited and persist with an optional image',
    () async {
      final store = RecipeStore(recipeService: _FakeRecipeService([]));
      await store.addCustomRecipe(
        name: 'Garden pasta',
        cuisine: 'Italian',
        ingredients: ['Pasta', 'Tomatoes'],
        instructions: ['Boil pasta', 'Stir in tomatoes'],
        prepTimeMinutes: 10,
        cookTimeMinutes: 15,
        servings: 3,
      );
      final recipeId = store.recipes.single.id;
      await store.updateCustomRecipe(
        id: recipeId,
        name: 'Garden pasta deluxe',
        cuisine: 'Italian',
        image: 'data:image/jpeg;base64,YWJj',
        ingredients: ['Pasta', 'Tomatoes', 'Basil'],
        instructions: ['Boil pasta', 'Stir in tomatoes and basil'],
        prepTimeMinutes: 12,
        cookTimeMinutes: 18,
        servings: 4,
      );
      expect(store.recipeById(recipeId)?.name, 'Garden pasta deluxe');
      store.dispose();

      final reloadedStore = RecipeStore(recipeService: _FakeRecipeService([]));
      await reloadedStore.load();

      expect(reloadedStore.recipes.single.name, 'Garden pasta deluxe');
      expect(reloadedStore.recipes.single.image, 'data:image/jpeg;base64,YWJj');
      expect(reloadedStore.recipes.single.ingredients, [
        'Pasta',
        'Tomatoes',
        'Basil',
      ]);
      reloadedStore.dispose();
    },
  );

  testWidgets('custom recipe can be edited from its detail screen', (
    tester,
  ) async {
    final store = RecipeStore(recipeService: _FakeRecipeService([]));
    await store.addCustomRecipe(
      name: 'ข้าวผัดบ้านฉัน',
      cuisine: 'อาหารไทย',
      ingredients: ['ข้าว', 'ไข่'],
      instructions: ['ผัดทุกอย่างให้เข้ากัน'],
      prepTimeMinutes: 10,
      cookTimeMinutes: 15,
      servings: 2,
    );
    final recipe = store.recipes.single;
    await tester.pumpWidget(
      MaterialApp(
        home: RecipeDetailScreen(
          recipe: recipe,
          store: store,
          onToggleFavorite: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('แก้ไขสูตรอาหาร'));
    await tester.pumpAndSettle();
    expect(find.text('แก้ไขสูตรอาหาร'), findsOneWidget);
    expect(find.text('เลือกรูปจากเครื่อง'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).first, 'ข้าวผัดสูตรใหม่');
    await tester.ensureVisible(find.text('บันทึกสูตรอาหาร'));
    await tester.tap(find.text('บันทึกสูตรอาหาร'));
    await tester.pumpAndSettle();

    expect(store.recipeById(recipe.id)?.name, 'ข้าวผัดสูตรใหม่');
    expect(find.text('ข้าวผัดสูตรใหม่'), findsOneWidget);
    store.dispose();
  });

  test('API service parses recipe results and reports HTTP errors', () async {
    final client = MockClient((request) async {
      expect(request.url.host, 'dummyjson.com');
      expect(request.url.path, '/recipes');
      return http.Response(
        jsonEncode({
          'recipes': [
            {
              'id': 7,
              'name': 'Tomato soup',
              'ingredients': ['Tomatoes', 'Stock'],
              'instructions': ['Simmer'],
              'prepTimeMinutes': 5,
              'cookTimeMinutes': 20,
              'servings': 2,
              'cuisine': 'French',
              'rating': 4.5,
              'image': 'https://example.com/soup.jpg',
            },
          ],
        }),
        200,
      );
    });
    final service = RecipeService(client: client);

    final recipes = await service.fetchRecipes();

    expect(recipes, hasLength(1));
    expect(recipes.single.name, 'Tomato soup');
    expect(recipes.single.totalTimeMinutes, 25);
    service.close();

    final failingService = RecipeService(
      client: MockClient((request) async => http.Response('Unavailable', 503)),
    );
    await expectLater(
      failingService.fetchRecipes(),
      throwsA(isA<RecipeApiException>()),
    );
    failingService.close();
  });

  test('favorite state persists between store instances', () async {
    final recipe = _sampleRecipe();
    final firstStore = RecipeStore(recipeService: _FakeRecipeService([recipe]));
    await firstStore.load();
    await firstStore.toggleFavorite(recipe);
    firstStore.dispose();

    final reloadedStore = RecipeStore(
      recipeService: _FakeRecipeService([recipe]),
    );
    await reloadedStore.load();

    expect(reloadedStore.favoriteRecipes.single.name, recipe.name);
    reloadedStore.dispose();
  });

  testWidgets('recipe details show ingredients and cooking instructions', (
    tester,
  ) async {
    final recipe = _sampleRecipe();
    final store = RecipeStore(recipeService: _FakeRecipeService([recipe]));
    await store.load();
    await tester.pumpWidget(MaterialApp(home: RecipeBookScreen(store: store)));
    await tester.pumpAndSettle();

    await tester.drag(
      find.byType(CustomScrollView).first,
      const Offset(0, -600),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Sunday pancakes'));
    await tester.tap(find.text('Sunday pancakes'));
    await tester.pumpAndSettle();

    expect(find.text('วัตถุดิบ'), findsOneWidget);
    expect(find.text('แป้ง'), findsOneWidget);
    expect(find.text('วิธีทำ'), findsOneWidget);
    expect(find.text('Mix and cook'), findsOneWidget);
    store.dispose();
  });

  testWidgets('API recipe screen translates the vegetarian stir-fry to Thai', (
    tester,
  ) async {
    const recipe = Recipe(
      id: 2,
      name: 'Vegetarian Stir-Fry',
      image: '',
      ingredients: [
        'Tofu, cubed',
        'Broccoli florets',
        'Carrots, sliced',
        'Bell peppers, sliced',
        'Soy sauce',
        'Ginger, minced',
        'Garlic, minced',
        'Sesame oil',
        'Cooked rice for serving',
      ],
      instructions: [
        'In a wok, heat sesame oil over medium-high heat.',
        'Add minced ginger and garlic, sauté until fragrant.',
        'Add cubed tofu and stir-fry until golden brown.',
        'Add broccoli, carrots, and bell peppers. Cook until vegetables are tender-crisp.',
        'Pour soy sauce over the stir-fry and toss to combine.',
        'Serve over cooked rice.',
      ],
      prepTimeMinutes: 5,
      cookTimeMinutes: 10,
      servings: 2,
      cuisine: 'Asian',
      rating: 4.7,
      difficulty: 'Medium',
    );
    final store = RecipeStore(recipeService: _FakeRecipeService([recipe]));
    await store.load();
    await tester.pumpWidget(MaterialApp(home: RecipeBookScreen(store: store)));
    await tester.pumpAndSettle();

    expect(find.text('ผัดผักรวมเต้าหู้'), findsOneWidget);
    await tester.tap(find.text('ดูสูตร'));
    await tester.pumpAndSettle();

    expect(find.text('ผัดผักรวมเต้าหู้'), findsOneWidget);
    await tester.ensureVisible(find.text('เต้าหู้หั่นเต๋า'));
    expect(find.text('เต้าหู้หั่นเต๋า'), findsOneWidget);
    await tester.ensureVisible(
      find.text('ตั้งกระทะให้ร้อน ใส่น้ำมันงา ใช้ไฟกลางค่อนแรง'),
    );
    expect(
      find.text('ตั้งกระทะให้ร้อน ใส่น้ำมันงา ใช้ไฟกลางค่อนแรง'),
      findsOneWidget,
    );
    expect(find.text('Serve over cooked rice.'), findsNothing);
    store.dispose();
  });

  test('API ingredient and instruction translations are Thai', () {
    expect(recipeIngredientTranslations.length, greaterThanOrEqualTo(239));
    expect(recipeInstructionTranslations.length, greaterThanOrEqualTo(255));

    for (final translation in [
      ...recipeIngredientTranslations.values,
      ...recipeInstructionTranslations.values,
    ]) {
      expect(
        RegExp(r'[A-Za-z]').hasMatch(translation),
        isFalse,
        reason: 'Unexpected English in Thai translation: $translation',
      );
    }
    expect(ingredientLabel('Tofu, cubed'), 'เต้าหู้หั่นเต๋า');
    expect(
      instructionLabel('Serve over cooked rice.'),
      'ตักเสิร์ฟพร้อมข้าวสวย',
    );
  });

  testWidgets('valid recipe submitted through the form is saved', (
    tester,
  ) async {
    final store = RecipeStore(recipeService: _FakeRecipeService([]));
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => AddRecipeScreen(store: store),
                  ),
                ),
                child: const Text('Open form'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open form'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'Garden pasta');
    await tester.enterText(find.byType(TextFormField).at(1), 'Italian');
    await tester.enterText(find.byType(TextFormField).at(2), 'Pasta\nTomatoes');
    await tester.enterText(
      find.byType(TextFormField).at(3),
      'Boil pasta\nStir in tomatoes',
    );
    await tester.ensureVisible(find.text('บันทึกสูตรอาหาร'));
    await tester.tap(find.text('บันทึกสูตรอาหาร'));
    await tester.pumpAndSettle();

    expect(store.recipes.single.name, 'Garden pasta');
    expect(find.text('Open form'), findsOneWidget);
    store.dispose();
  });
}

Recipe _sampleRecipe() => const Recipe(
  id: 1,
  name: 'Sunday pancakes',
  image: '',
  ingredients: ['Flour', 'Milk'],
  instructions: ['Mix and cook'],
  prepTimeMinutes: 5,
  cookTimeMinutes: 10,
  servings: 2,
  cuisine: 'American',
  rating: 4.8,
);

class _FakeRecipeService extends RecipeService {
  _FakeRecipeService(this.recipes);

  final List<Recipe> recipes;

  @override
  Future<List<Recipe>> fetchRecipes() async => recipes;
}
