import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/category_model.dart';

class CategoryNotifier extends Notifier<List<Category>> {
  @override
  List<Category> build() => [
    ...buildSeedExpenseCategories(),
    ...buildSeedIncomeCategories(),
  ];

  void addCategory(Category category) {
    state = [...state, category];
  }

  void updateCategory(Category updated) {
    state = [
      for (final c in state)
        if (c.id == updated.id) updated else c,
    ];
  }

  void deleteCategory(String id) {
    state = state.where((c) => c.id != id).toList();
  }
}

final categoryProvider = NotifierProvider<CategoryNotifier, List<Category>>(
  CategoryNotifier.new,
);
