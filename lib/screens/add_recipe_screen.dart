import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../models/recipe.dart';
import '../services/recipe_store.dart';
import '../widgets/recipe_image.dart';

class AddRecipeScreen extends StatefulWidget {
  const AddRecipeScreen({super.key, required this.store, this.initialRecipe});

  final RecipeStore store;
  final Recipe? initialRecipe;

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cuisineController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _prepTimeController = TextEditingController(text: '10');
  final _cookTimeController = TextEditingController(text: '20');
  final _servingsController = TextEditingController(text: '2');
  final _imagePicker = ImagePicker();
  String _imageData = '';
  bool _isPickingImage = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final recipe = widget.initialRecipe;
    if (recipe == null) return;
    _nameController.text = recipe.name;
    _cuisineController.text = recipe.cuisine == 'Homemade'
        ? ''
        : recipe.cuisine;
    _ingredientsController.text = recipe.ingredients.join('\n');
    _instructionsController.text = recipe.instructions.join('\n');
    _prepTimeController.text = recipe.prepTimeMinutes.toString();
    _cookTimeController.text = recipe.cookTimeMinutes.toString();
    _servingsController.text = recipe.servings.toString();
    _imageData = recipe.image;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cuisineController.dispose();
    _ingredientsController.dispose();
    _instructionsController.dispose();
    _prepTimeController.dispose();
    _cookTimeController.dispose();
    _servingsController.dispose();
    super.dispose();
  }

  Future<void> _saveRecipe() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      final recipe = widget.initialRecipe;
      final name = _nameController.text.trim();
      final cuisine = _cuisineController.text.trim();
      final ingredients = _lines(_ingredientsController.text);
      final instructions = _lines(_instructionsController.text);
      final prepTimeMinutes = _number(_prepTimeController.text);
      final cookTimeMinutes = _number(_cookTimeController.text);
      final servings = _number(_servingsController.text, fallback: 1);
      if (recipe == null) {
        await widget.store.addCustomRecipe(
          name: name,
          cuisine: cuisine,
          image: _imageData,
          ingredients: ingredients,
          instructions: instructions,
          prepTimeMinutes: prepTimeMinutes,
          cookTimeMinutes: cookTimeMinutes,
          servings: servings,
        );
      } else {
        await widget.store.updateCustomRecipe(
          id: recipe.id,
          name: name,
          cuisine: cuisine,
          image: _imageData,
          ingredients: ingredients,
          instructions: instructions,
          prepTimeMinutes: prepTimeMinutes,
          cookTimeMinutes: cookTimeMinutes,
          servings: servings,
        );
      }
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            recipe == null ? 'บันทึกสูตรอาหารแล้ว' : 'แก้ไขสูตรอาหารแล้ว',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${widget.initialRecipe == null ? 'บันทึก' : 'แก้ไข'}ไม่สำเร็จ: '
            '${error.toString().replaceFirst('Bad state: ', '')}',
          ),
        ),
      );
      setState(() => _isSaving = false);
    }
  }

  Future<void> _pickImage() async {
    setState(() => _isPickingImage = true);
    try {
      final file = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1280,
        maxHeight: 1280,
        imageQuality: 75,
      );
      if (file == null || !mounted) return;
      final bytes = await file.readAsBytes();
      final mimeType = file.mimeType ?? 'image/jpeg';
      setState(
        () => _imageData = 'data:$mimeType;base64,${base64Encode(bytes)}',
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('เลือกรูปไม่สำเร็จ: $error')));
    } finally {
      if (mounted) setState(() => _isPickingImage = false);
    }
  }

  List<String> _lines(String value) => value
      .split('\n')
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .toList();

  int _number(String value, {int fallback = 0}) =>
      int.tryParse(value.trim()) ?? fallback;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.initialRecipe == null ? 'เพิ่มสูตรอาหาร' : 'แก้ไขสูตรอาหาร',
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFEAF0E7), Color(0xFFF4F1E9)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(17),
                        ),
                        child: const Icon(
                          Icons.menu_book_rounded,
                          color: Color(0xFF536C54),
                          size: 27,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.initialRecipe == null
                                  ? 'เพิ่มสูตรโปรดของคุณ'
                                  : 'แก้ไขสูตรโปรดของคุณ',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    color: const Color(0xFF26382E),
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            const SizedBox(height: 3),
                            const Text(
                              'เก็บเมนูที่ชอบไว้ทำครั้งต่อไป',
                              style: TextStyle(color: Color(0xFF687467)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                _FieldLabel('ชื่อเมนู *'),
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.restaurant_rounded),
                    hintText: 'เช่น ข้าวผัดบ้านฉัน',
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'กรุณาใส่ชื่อเมนู'
                      : null,
                ),
                const SizedBox(height: 16),
                _FieldLabel('ประเภทอาหาร (ไม่บังคับ)'),
                TextFormField(
                  controller: _cuisineController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.public_rounded),
                    hintText: 'เช่น อาหารไทย, เมนูครอบครัว',
                  ),
                ),
                const SizedBox(height: 16),
                _FieldLabel('รูปอาหาร (ไม่บังคับ)'),
                if (_imageData.isEmpty)
                  OutlinedButton.icon(
                    onPressed: _isPickingImage ? null : _pickImage,
                    icon: _isPickingImage
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.add_photo_alternate_outlined),
                    label: Text(
                      _isPickingImage
                          ? 'กำลังเลือกรูป...'
                          : 'เลือกรูปจากเครื่อง',
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(54),
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  )
                else
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      children: [
                        AspectRatio(
                          aspectRatio: 16 / 9,
                          child: RecipeImage(imageUrl: _imageData),
                        ),
                        Positioned(
                          right: 10,
                          top: 10,
                          child: Row(
                            children: [
                              IconButton.filled(
                                tooltip: 'เปลี่ยนรูป',
                                onPressed: _isPickingImage ? null : _pickImage,
                                icon: const Icon(Icons.edit_rounded),
                              ),
                              const SizedBox(width: 6),
                              IconButton.filled(
                                tooltip: 'ลบรูป',
                                onPressed: () =>
                                    setState(() => _imageData = ''),
                                icon: const Icon(Icons.delete_outline_rounded),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                _FieldLabel('วัตถุดิบ *'),
                TextFormField(
                  controller: _ingredientsController,
                  minLines: 3,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    hintText: 'พิมพ์วัตถุดิบทีละอย่าง คนละบรรทัด',
                    alignLabelWithHint: true,
                  ),
                  validator: (value) => _lines(value ?? '').isEmpty
                      ? 'กรุณาใส่วัตถุดิบอย่างน้อย 1 อย่าง'
                      : null,
                ),
                const SizedBox(height: 16),
                _FieldLabel('วิธีทำ *'),
                TextFormField(
                  controller: _instructionsController,
                  minLines: 4,
                  maxLines: 8,
                  decoration: const InputDecoration(
                    hintText: 'เขียนวิธีทำทีละขั้นตอน คนละบรรทัด',
                    alignLabelWithHint: true,
                  ),
                  validator: (value) => _lines(value ?? '').isEmpty
                      ? 'กรุณาใส่วิธีทำอย่างน้อย 1 ขั้นตอน'
                      : null,
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _NumberField(
                        label: 'เตรียม (นาที)',
                        controller: _prepTimeController,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _NumberField(
                        label: 'ปรุง (นาที)',
                        controller: _cookTimeController,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _NumberField(
                        label: 'จำนวนที่ได้',
                        controller: _servingsController,
                        minimum: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 26),
                FilledButton.icon(
                  onPressed: _isSaving || _isPickingImage ? null : _saveRecipe,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.bookmark_add_outlined),
                  label: Text(_isSaving ? 'กำลังบันทึก...' : 'บันทึกสูตรอาหาร'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF26382E),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.label,
    required this.controller,
    this.minimum = 0,
  });

  final String label;
  final TextEditingController controller;
  final int minimum;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          textAlign: TextAlign.center,
          decoration: const InputDecoration(contentPadding: EdgeInsets.all(14)),
          validator: (value) {
            final parsed = int.tryParse(value?.trim() ?? '');
            if (parsed == null || parsed < minimum) {
              return minimum == 0
                  ? 'กรุณาใส่ตัวเลข'
                  : 'ต้องไม่น้อยกว่า $minimum';
            }
            return null;
          },
        ),
      ],
    );
  }
}
