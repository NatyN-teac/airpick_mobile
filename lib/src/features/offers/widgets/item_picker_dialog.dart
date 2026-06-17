import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/state_message.dart';
import '../../items/models/item_models.dart';

// ── Entry point — cubit-agnostic ──────────────────────────────────────────────
//
// Accepts the data it needs as plain parameters so it works with any cubit
// that manages items (CreateOfferCubit, CreateOfferRequestCubit, etc.).

Future<List<ItemModel>> showItemPickerDialog(
  BuildContext context, {
  required List<ItemModel> availableItems,
  required bool isLoading,
  String? itemsError,
  required VoidCallback onRetry,
  required Future<ItemModel?> Function(String name, ItemCategory category)
  onCreate,
}) async {
  final result = await showDialog<List<ItemModel>>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.55),
    builder: (_) => ItemPickerDialog(
      availableItems: availableItems,
      isLoading: isLoading,
      itemsError: itemsError,
      onRetry: onRetry,
      onCreate: onCreate,
    ),
  );
  return result ?? [];
}

// ── Dialog ────────────────────────────────────────────────────────────────────

class ItemPickerDialog extends StatefulWidget {
  final List<ItemModel> availableItems;
  final bool isLoading;
  final String? itemsError;
  final VoidCallback onRetry;
  final Future<ItemModel?> Function(String name, ItemCategory category)
  onCreate;

  const ItemPickerDialog({
    super.key,
    required this.availableItems,
    required this.isLoading,
    required this.itemsError,
    required this.onRetry,
    required this.onCreate,
  });

  @override
  State<ItemPickerDialog> createState() => _ItemPickerDialogState();
}

class _ItemPickerDialogState extends State<ItemPickerDialog> {
  final _searchCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  String _query = '';
  bool _showCreate = false;
  ItemCategory _newCategory = ItemCategory.electronics;
  bool _creating = false;
  String? _createError;
  final Set<String> _selectedIds = {};

  @override
  void dispose() {
    _searchCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  List<ItemModel> _filtered(List<ItemModel> all) {
    if (_query.isEmpty) return all;
    final q = _query.toLowerCase();
    return all.where((i) => i.name.toLowerCase().contains(q)).toList();
  }

  Map<ItemCategory, List<ItemModel>> _grouped(List<ItemModel> items) {
    final map = <ItemCategory, List<ItemModel>>{};
    for (final item in items) {
      (map[item.category] ??= []).add(item);
    }
    return map;
  }

  Future<void> _submit() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    setState(() {
      _creating = true;
      _createError = null;
    });
    final item = await widget.onCreate(name, _newCategory);
    if (!mounted) return;
    if (item != null) {
      setState(() {
        _creating = false;
        _selectedIds.add(item.id);
        _showCreate = false;
        _nameCtrl.clear();
        _query = '';
        _searchCtrl.clear();
      });
    } else {
      setState(() {
        _creating = false;
        _createError = 'Failed to create item. Try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkSurface : Colors.white;
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.textSecondary;
    final surface = isDark ? AppColors.darkBackground : AppColors.surface;
    final border = isDark ? AppColors.darkBorder : AppColors.border;

    final filtered = _filtered(widget.availableItems);
    final grouped = _grouped(filtered);

    return Dialog(
      backgroundColor: bg,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        child: Column(
          children: [
            // ── Header ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 8, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _showCreate ? 'Add Custom Item' : 'Select Item',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  if (_showCreate)
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back_rounded,
                        color: textSecondary,
                        size: 20,
                      ),
                      onPressed: () => setState(() {
                        _showCreate = false;
                        _createError = null;
                        _nameCtrl.clear();
                      }),
                    )
                  else
                    IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        color: textSecondary,
                        size: 20,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            if (!_showCreate) ...[
              // ── Search ───────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _query = v),
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 13,
                    color: textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search items…',
                    hintStyle: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 13,
                      color: isDark
                          ? AppColors.darkTextTertiary
                          : AppColors.textTertiary,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      size: 18,
                      color: isDark
                          ? AppColors.darkTextTertiary
                          : AppColors.textTertiary,
                    ),
                    filled: true,
                    fillColor: surface,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // ── List / loading / error ────────────────────────────
              Expanded(
                child: widget.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      )
                    : widget.itemsError != null
                    ? AppErrorState(
                        title: 'Could not load items',
                        message: widget.itemsError!,
                        onRetry: widget.onRetry,
                        padding: const EdgeInsets.all(24),
                      )
                    : filtered.isEmpty
                    ? AppEmptyState(
                        icon: Icons.inventory_2_outlined,
                        title: _query.isEmpty
                            ? 'No items available'
                            : 'No matching items',
                        message: _query.isEmpty
                            ? 'Items will appear here when they are available.'
                            : 'No results for "$_query". Try another item name.',
                        padding: const EdgeInsets.all(24),
                      )
                    : _ItemList(
                        grouped: grouped,
                        selectedIds: _selectedIds,
                        isDark: isDark,
                        onToggle: (item) => setState(() {
                          if (_selectedIds.contains(item.id)) {
                            _selectedIds.remove(item.id);
                          } else {
                            _selectedIds.add(item.id);
                          }
                        }),
                      ),
              ),

              // ── Footer: Done + Add custom ─────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _selectedIds.isEmpty
                          ? null
                          : () {
                              final selected = widget.availableItems
                                  .where((i) => _selectedIds.contains(i.id))
                                  .toList();
                              Navigator.of(context).pop(selected);
                            },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          gradient: _selectedIds.isNotEmpty
                              ? AppColors.primaryGradient
                              : null,
                          color: _selectedIds.isEmpty
                              ? (isDark
                                    ? AppColors.darkBorder
                                    : const Color(0xFFE2E8F0))
                              : null,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _selectedIds.isEmpty
                              ? 'Select items to continue'
                              : 'Done  (${_selectedIds.length} selected)',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _selectedIds.isNotEmpty
                                ? Colors.white
                                : AppColors.textDisabled,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => setState(() => _showCreate = true),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_rounded,
                            size: 14,
                            color: AppColors.primary,
                          ),
                          SizedBox(width: 4),
                          Text(
                            "Can't find it? Add custom",
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // ── Create custom item form ───────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _DialogLabel('Item name', isDark: isDark),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _nameCtrl,
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 13,
                          color: textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'e.g. Nike Air Max',
                          hintStyle: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 13,
                            color: isDark
                                ? AppColors.darkTextTertiary
                                : AppColors.textTertiary,
                          ),
                          filled: true,
                          fillColor: surface,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _DialogLabel('Category', isDark: isDark),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<ItemCategory>(
                        key: ValueKey(_newCategory),
                        initialValue: _newCategory,
                        dropdownColor: isDark
                            ? AppColors.darkSurface
                            : Colors.white,
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 13,
                          color: textPrimary,
                        ),
                        icon: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 18,
                          color: textSecondary,
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: surface,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 1.5,
                            ),
                          ),
                        ),
                        items: ItemCategory.values
                            .map(
                              (c) => DropdownMenuItem(
                                value: c,
                                child: Text(c.label),
                              ),
                            )
                            .toList(),
                        onChanged: (v) {
                          if (v != null) {
                            setState(() => _newCategory = v);
                          }
                        },
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              size: 14,
                              color: AppColors.primary.withValues(alpha: 0.7),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Measured in ${_newCategory.defaultMeasurement.$2.label}',
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 12,
                                color: AppColors.primary.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_createError != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          _createError!,
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 12,
                            color: AppColors.error,
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: GestureDetector(
                          onTap: _creating ? null : _submit,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: _creating
                                ? const Center(
                                    child: SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                                : const Text(
                                    'Add Item',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: 'Manrope',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Item list ─────────────────────────────────────────────────────────────────

class _ItemList extends StatelessWidget {
  final Map<ItemCategory, List<ItemModel>> grouped;
  final Set<String> selectedIds;
  final bool isDark;
  final ValueChanged<ItemModel> onToggle;

  const _ItemList({
    required this.grouped,
    required this.selectedIds,
    required this.isDark,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.textSecondary;
    final textTertiary = isDark
        ? AppColors.darkTextTertiary
        : AppColors.textTertiary;
    final border = isDark ? AppColors.darkBorder : AppColors.border;
    final categories = grouped.keys.toList();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: categories.fold<int>(
        0,
        (sum, cat) => sum + 1 + (grouped[cat]?.length ?? 0),
      ),
      itemBuilder: (_, index) {
        int cursor = 0;
        for (final cat in categories) {
          if (index == cursor) {
            return Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 6),
              child: Text(
                cat.label.toUpperCase(),
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: textTertiary,
                ),
              ),
            );
          }
          cursor++;
          final items = grouped[cat]!;
          if (index < cursor + items.length) {
            final item = items[index - cursor];
            final selected = selectedIds.contains(item.id);
            return GestureDetector(
              onTap: () => onToggle(item),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.primary.withValues(alpha: 0.07)
                      : Colors.transparent,
                  border: Border.all(
                    color: selected ? AppColors.primary : border,
                    width: selected ? 1.5 : 1,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.primary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: selected
                              ? AppColors.primary
                              : (isDark
                                    ? AppColors.darkBorder
                                    : AppColors.border),
                        ),
                      ),
                      child: selected
                          ? const Icon(
                              Icons.check_rounded,
                              size: 13,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item.name,
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      item.measurementUnit.label,
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 11,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          cursor += items.length;
        }
        return const SizedBox.shrink();
      },
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _DialogLabel extends StatelessWidget {
  final String text;
  final bool isDark;
  const _DialogLabel(this.text, {required this.isDark});

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: TextStyle(
      fontFamily: 'Manrope',
      fontSize: 11,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.3,
      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
    ),
  );
}
