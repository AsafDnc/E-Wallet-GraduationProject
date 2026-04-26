import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';

import '../domain/category_model.dart';
import '../providers/category_provider.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: cs.surface,
        appBar: AppBar(
          backgroundColor: cs.surface,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.pop(),
          ),
          title: const Text(
            'Categories',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          bottom: TabBar(
            labelColor: cs.primary,
            unselectedLabelColor: cs.onSurfaceVariant,
            indicatorColor: cs.primary,
            indicatorSize: TabBarIndicatorSize.label,
            tabs: CategoryType.values.map((t) => Tab(text: t.label)).toList(),
          ),
        ),
        body: TabBarView(
          children: CategoryType.values
              .map((type) => _CategoryTabList(type: type))
              .toList(),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showCategoryDialog(context, ref),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add Category'),
        ),
      ),
    );
  }
}

// ─── Tab list ─────────────────────────────────────────────────────────────────

class _CategoryTabList extends ConsumerWidget {
  const _CategoryTabList({required this.type});

  final CategoryType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final categories = ref.watch(
      categoryProvider.select(
        (cats) => cats.where((c) => c.type == type).toList(),
      ),
    );

    if (categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.category_outlined,
              size: 52,
              color: cs.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            Text(
              'No ${type.label.toLowerCase()} categories yet',
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 15),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: categories.length,
      itemBuilder: (context, i) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: _CategoryTile(
          category: categories[i],
          onEdit: () =>
              _showCategoryDialog(context, ref, existing: categories[i]),
          onDelete: () => ref
              .read(categoryProvider.notifier)
              .deleteCategory(categories[i].id),
        ),
      ),
    );
  }
}

// ─── Single tile ──────────────────────────────────────────────────────────────

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.category,
    required this.onEdit,
    required this.onDelete,
  });

  final Category category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Slidable(
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.25,
        children: [
          SlidableAction(
            onPressed: (_) => onDelete(),
            backgroundColor: cs.errorContainer,
            foregroundColor: cs.onErrorContainer,
            icon: Icons.delete_outline_rounded,
            label: 'Delete',
            borderRadius: BorderRadius.circular(14),
          ),
        ],
      ),
      child: Material(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onEdit,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: category.displayColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    category.displayIcon,
                    color: category.displayColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    category.name,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: cs.onSurfaceVariant,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Add / Edit dialog ────────────────────────────────────────────────────────

void _showCategoryDialog(
  BuildContext context,
  WidgetRef ref, {
  Category? existing,
}) {
  showDialog<void>(
    context: context,
    builder: (ctx) => _CategoryDialog(ref: ref, existing: existing),
  );
}

class _CategoryDialog extends StatefulWidget {
  const _CategoryDialog({required this.ref, this.existing});

  final WidgetRef ref;
  final Category? existing;

  @override
  State<_CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends State<_CategoryDialog> {
  late final TextEditingController _nameCtrl;
  late CategoryType _type;
  late int _iconCode;
  late int _colorValue;

  static final _icons = <IconData>[
    Icons.restaurant_rounded,
    Icons.directions_car_rounded,
    Icons.shopping_bag_rounded,
    Icons.receipt_long_rounded,
    Icons.subscriptions_rounded,
    Icons.movie_rounded,
    Icons.local_hospital_rounded,
    Icons.account_balance_wallet_rounded,
    Icons.work_rounded,
    Icons.trending_up_rounded,
    Icons.card_giftcard_rounded,
    Icons.home_rounded,
    Icons.sports_soccer_rounded,
    Icons.local_cafe_rounded,
    Icons.flight_rounded,
    Icons.school_rounded,
    Icons.pets_rounded,
    Icons.fitness_center_rounded,
    Icons.music_note_rounded,
    Icons.computer_rounded,
    Icons.phone_android_rounded,
    Icons.more_horiz_rounded,
  ];

  static final _colors = <Color>[
    const Color(0xFFE57373),
    const Color(0xFF64B5F6),
    const Color(0xFF81C784),
    const Color(0xFFFFB74D),
    const Color(0xFFBA68C8),
    const Color(0xFF4FC3F7),
    const Color(0xFFF06292),
    const Color(0xFFFFD54F),
    const Color(0xFFAED581),
    const Color(0xFF90A4AE),
    const Color(0xFF4DB6AC),
    const Color(0xFFFF8A65),
  ];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.existing?.name ?? '');
    _type = widget.existing?.type ?? CategoryType.expense;
    _iconCode = widget.existing?.iconCode ?? _icons.first.codePoint;
    _colorValue = widget.existing?.colorValue ?? _colors.first.toARGB32();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;

    final id =
        widget.existing?.id ?? 'cat_${DateTime.now().microsecondsSinceEpoch}';
    final cat = Category(
      id: id,
      name: name,
      iconCode: _iconCode,
      colorValue: _colorValue,
      type: _type,
    );

    if (widget.existing != null) {
      widget.ref.read(categoryProvider.notifier).updateCategory(cat);
    } else {
      widget.ref.read(categoryProvider.notifier).addCategory(cat);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final selColor = Color(_colorValue);
    final selIcon = IconData(_iconCode, fontFamily: 'MaterialIcons');
    final isEdit = widget.existing != null;

    return AlertDialog(
      title: Text(isEdit ? 'Edit Category' : 'Add Category'),
      contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Preview chip
            Center(
              child: Container(
                width: 64,
                height: 64,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: selColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(selIcon, color: selColor, size: 30),
              ),
            ),

            // Name field
            TextField(
              controller: _nameCtrl,
              autofocus: !isEdit,
              decoration: InputDecoration(
                labelText: 'Category Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Type toggle
            Text(
              'Type',
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            SegmentedButton<CategoryType>(
              segments: CategoryType.values
                  .map(
                    (t) => ButtonSegment<CategoryType>(
                      value: t,
                      label: Text(t.label),
                    ),
                  )
                  .toList(),
              selected: {_type},
              onSelectionChanged: (s) => setState(() => _type = s.first),
            ),
            const SizedBox(height: 16),

            // Icon picker
            Text(
              'Icon',
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 168,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _icons.length,
                itemBuilder: (_, i) {
                  final icon = _icons[i];
                  final selected = icon.codePoint == _iconCode;
                  return GestureDetector(
                    onTap: () => setState(() => _iconCode = icon.codePoint),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      decoration: BoxDecoration(
                        color: selected
                            ? cs.primaryContainer
                            : cs.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(10),
                        border: selected
                            ? Border.all(color: cs.primary, width: 2)
                            : null,
                      ),
                      child: Icon(
                        icon,
                        size: 20,
                        color: selected
                            ? cs.onPrimaryContainer
                            : cs.onSurfaceVariant,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Color picker
            Text(
              'Color',
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _colors.map((c) {
                final selected = c.toARGB32() == _colorValue;
                return GestureDetector(
                  onTap: () => setState(() => _colorValue = c.toARGB32()),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: selected
                          ? Border.all(color: cs.onSurface, width: 2.5)
                          : null,
                    ),
                    child: selected
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _save, child: Text(isEdit ? 'Save' : 'Add')),
      ],
    );
  }
}
