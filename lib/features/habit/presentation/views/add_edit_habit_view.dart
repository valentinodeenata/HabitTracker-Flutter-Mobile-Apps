import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_flow/core/theme/app_colors.dart';
import 'package:habit_flow/features/habit/data/habit_category.dart';
import 'package:habit_flow/features/habit/data/habit_model.dart';
import 'package:habit_flow/features/habit/presentation/controllers/habit_controller.dart';
import 'package:uuid/uuid.dart';

class AddEditHabitView extends GetView<HabitController> {
  final bool isEdit;

  const AddEditHabitView({super.key, required this.isEdit});

  @override
  Widget build(BuildContext context) {
    HabitModel? initial;
    if (isEdit) {
      initial = Get.arguments as HabitModel?;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit habit' : 'Add habit'),
        actions: [
          if (isEdit && initial != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                final ok = await Get.dialog<bool>(
                  AlertDialog(
                    title: const Text('Delete habit?'),
                    content: const Text(
                      'This will remove the habit and its history. This cannot be undone.',
                    ),
                    actions: [
                      TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
                      FilledButton(
                        onPressed: () => Get.back(result: true),
                        style: FilledButton.styleFrom(backgroundColor: AppColors.error),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
                if (ok == true && initial != null) {
                  await controller.deleteHabit(initial.id);
                  Get.back();
                }
              },
            ),
        ],
      ),
      body: _HabitForm(initial: initial, isEdit: isEdit),
    );
  }
}

class _HabitForm extends StatefulWidget {
  final HabitModel? initial;
  final bool isEdit;

  const _HabitForm({this.initial, required this.isEdit});

  @override
  State<_HabitForm> createState() => _HabitFormState();
}

class _HabitFormState extends State<_HabitForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late int _iconCodePoint;
  late int _colorValue;
  late HabitFrequency _frequency;
  late List<int> _customDays;
  late int _dailyTarget;
  late HabitCategory _category;
  bool _isSaving = false;

  static final List<IconData> _icons = [
    Icons.fitness_center,
    Icons.menu_book,
    Icons.water_drop,
    Icons.nightlight_round,
    Icons.self_improvement,
    Icons.code,
    Icons.directions_walk,
    Icons.volunteer_activism,
  ];

  @override
  void initState() {
    super.initState();
    final h = widget.initial;
    _nameController = TextEditingController(text: h?.name ?? '');
    _iconCodePoint = h?.iconCodePoint ?? _icons.first.codePoint;
    _colorValue = h?.colorValue ?? AppColors.habitColors.first.toARGB32();
    _frequency = h?.frequency ?? HabitFrequency.daily;
    _customDays = List.from(h?.customDays ?? []);
    _dailyTarget = h?.dailyTarget ?? 1;
    _category = h?.category ?? HabitCategory.haveFun;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<HabitController>();
    final cs = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Form(
      key: _formKey,
      child: Stack(
        children: [
          // Subtle background tint for light mode (avoid feeling flat)
          if (isLight)
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        cs.primary.withValues(alpha: 0.05),
                        cs.surface,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
            children: [
              _SectionCard(
                title: 'Details',
                subtitle: 'Give your habit a clear name',
                child: TextFormField(
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Habit name',
                    hintText: 'e.g. Read 30 min',
                    prefixIcon: Icon(Icons.edit_outlined),
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Enter a name' : null,
                ),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Icon',
                subtitle: 'Pick something that feels right',
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _icons.map((IconData icon) {
                    final selected = icon.codePoint == _iconCodePoint;
                    return GestureDetector(
                      onTap: () => setState(() => _iconCodePoint = icon.codePoint),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: selected
                              ? Color(_colorValue).withValues(alpha: 0.14)
                              : cs.surfaceContainerHighest.withValues(alpha: isLight ? 0.55 : 0.25),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: selected
                                ? Color(_colorValue).withValues(alpha: 0.35)
                                : cs.outline.withValues(alpha: 0.22),
                          ),
                          boxShadow: selected
                              ? [
                                  BoxShadow(
                                    color: Color(_colorValue).withValues(alpha: 0.20),
                                    blurRadius: 18,
                                    offset: const Offset(0, 10),
                                  ),
                                ]
                              : null,
                        ),
                        child: Icon(
                          icon,
                          color: selected ? Color(_colorValue) : cs.onSurfaceVariant,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Color',
                subtitle: 'A little identity goes a long way',
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: AppColors.habitColors.map((Color color) {
                    final selected = color.toARGB32() == _colorValue;
                    return GestureDetector(
                      onTap: () => setState(() => _colorValue = color.toARGB32()),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: selected
                                ? Colors.white.withValues(alpha: 0.95)
                                : Colors.white.withValues(alpha: 0.18),
                            width: selected ? 2 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: color.withValues(alpha: selected ? 0.30 : 0.14),
                              blurRadius: selected ? 20 : 12,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: selected
                            ? const Icon(Icons.check, color: Colors.white, size: 20)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Category',
                subtitle: 'This chooses the focus animation',
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: HabitCategory.values.map((cat) {
                    final selected = _category == cat;
                    final label = switch (cat) {
                      HabitCategory.coding => 'Coding',
                      HabitCategory.reading => 'Reading',
                      HabitCategory.walking => 'Walking',
                      HabitCategory.run => 'Run',
                      HabitCategory.swimming => 'Swimming',
                      HabitCategory.prayer => 'Prayer',
                      HabitCategory.study => 'Study',
                      HabitCategory.gaming => 'Gaming',
                      HabitCategory.haveFun => 'Have fun',
                    };
                    return ChoiceChip(
                      label: Text(label),
                      selected: selected,
                      onSelected: (_) => setState(() => _category = cat),
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: selected ? cs.onPrimary : cs.onSurface,
                      ),
                      selectedColor: cs.primary,
                      backgroundColor: cs.surfaceContainerHighest.withValues(alpha: isLight ? 0.55 : 0.25),
                      side: BorderSide(
                        color: selected
                            ? cs.primary.withValues(alpha: 0.6)
                            : cs.outline.withValues(alpha: 0.22),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      showCheckmark: true,
                      checkmarkColor: cs.onPrimary,
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Schedule',
                subtitle: 'Choose days and set a daily target',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _PrettySegmented(
                      value: _frequency,
                      onChanged: (v) => setState(() => _frequency = v),
                    ),
                    if (_frequency == HabitFrequency.custom) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [1, 2, 3, 4, 5, 6, 7].map((day) {
                          const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                          final selected = _customDays.contains(day);
                          return _DayPill(
                            label: labels[day - 1],
                            selected: selected,
                            onTap: () {
                              setState(() {
                                if (selected) {
                                  _customDays.remove(day);
                                } else {
                                  _customDays.add(day);
                                  _customDays.sort();
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ],
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      initialValue: _dailyTarget.clamp(1, 10),
                      decoration: const InputDecoration(
                        labelText: 'Daily target',
                        prefixIcon: Icon(Icons.flag_outlined),
                      ),
                      items: List.generate(10, (i) => i + 1)
                          .map((v) => DropdownMenuItem(value: v, child: Text('$v per day')))
                          .toList(),
                      onChanged: (v) => setState(() => _dailyTarget = v ?? 1),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 18,
            child: SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: cs.surface.withValues(alpha: isLight ? 0.9 : 0.75),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: cs.outline.withValues(alpha: 0.18)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 24,
                      offset: const Offset(0, 16),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _isSaving
                        ? null
                        : () async {
                      if (!_formKey.currentState!.validate()) return;
                      if (_frequency == HabitFrequency.custom && _customDays.isEmpty) {
                        Get.snackbar('Error', 'Select at least one day');
                        return;
                      }
                      setState(() => _isSaving = true);
                      final now = DateTime.now();
                      final habit = HabitModel(
                        id: widget.initial?.id ?? const Uuid().v4(),
                        name: _nameController.text.trim(),
                        iconCodePoint: _iconCodePoint,
                        colorValue: _colorValue,
                        category: _category,
                        frequency: _frequency,
                        customDays: _customDays,
                        dailyTarget: _dailyTarget,
                        createdAt: widget.initial?.createdAt ?? now,
                        reminderTime: widget.initial?.reminderTime,
                      );
                      try {
                        if (widget.isEdit) {
                          await c.updateHabit(habit);
                          if (mounted) {
                            Get.back();
                            Get.snackbar(
                              'Saved',
                              '${habit.name} updated',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: AppColors.success.withValues(alpha: 0.92),
                              colorText: Colors.white,
                              duration: const Duration(seconds: 2),
                              margin: const EdgeInsets.all(16),
                            );
                          }
                        } else {
                          await c.addHabit(habit);
                          if (mounted) {
                            Get.back();
                            Get.snackbar(
                              'Habit added',
                              '${habit.name} is ready to track',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: cs.primary.withValues(alpha: 0.95),
                              colorText: Colors.white,
                              duration: const Duration(seconds: 2),
                              margin: const EdgeInsets.all(16),
                            );
                          }
                        }
                      } finally {
                        if (mounted) setState(() => _isSaving = false);
                      }
                    },
                    icon: Icon(widget.isEdit ? Icons.check : Icons.add),
                    label: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: _isSaving
                          ? const Text('Saving…', key: ValueKey('saving'))
                          : Text(
                              widget.isEdit ? 'Save changes' : 'Create habit',
                              key: const ValueKey('idle'),
                            ),
                    ),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;

  const _SectionCard({
    required this.title,
    this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                  ),
                ),
              ],
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
              ),
            ],
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _PrettySegmented extends StatelessWidget {
  final HabitFrequency value;
  final ValueChanged<HabitFrequency> onChanged;

  const _PrettySegmented({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDaily = value == HabitFrequency.daily;
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outline.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SegmentPill(
              icon: Icons.today,
              label: 'Daily',
              selected: isDaily,
              onTap: () => onChanged(HabitFrequency.daily),
            ),
          ),
          Expanded(
            child: _SegmentPill(
              icon: Icons.calendar_view_week,
              label: 'Custom',
              selected: !isDaily,
              onTap: () => onChanged(HabitFrequency.custom),
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SegmentPill({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? cs.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: cs.primary.withValues(alpha: 0.25),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: selected ? cs.onPrimary : cs.onSurface,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: selected ? cs.onPrimary : cs.onSurface,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _DayPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? cs.secondary.withValues(alpha: 0.95)
              : cs.surfaceContainerHighest.withValues(alpha: 0.60),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? cs.secondary.withValues(alpha: 0.6)
                : cs.outline.withValues(alpha: 0.22),
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: selected ? cs.onSecondary : cs.onSurfaceVariant,
              ),
        ),
      ),
    );
  }
}
