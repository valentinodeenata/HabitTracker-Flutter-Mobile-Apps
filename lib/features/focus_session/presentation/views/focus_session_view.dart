import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:habit_flow/core/theme/app_colors.dart';
import 'package:habit_flow/features/focus_session/presentation/controllers/focus_session_controller.dart';
import 'package:habit_flow/features/focus_session/presentation/widgets/habit_animation_mapper.dart';

class FocusSessionView extends GetView<FocusSessionController> {
  const FocusSessionView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop && controller.isRunning.value) {
          Future.microtask(() {
            Get.snackbar(
              'Focus session running',
              'Timer continues in the notification. Open Focus again to pause or stop.',
              snackPosition: SnackPosition.BOTTOM,
              margin: const EdgeInsets.all(16),
              duration: const Duration(seconds: 3),
            );
          });
        }
      },
      child: Scaffold(
      backgroundColor: colorScheme.surface.withValues(alpha: 0.98),
      appBar: AppBar(
        title: const Text('Focus mode'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _confirmExit(context),
        ),
      ),
      body: Obx(() {
        final h = controller.habit.value;
        if (h == null) {
          return const Center(child: Text('No habit selected'));
        }

        final percent = (controller.progress * 100).round();

        return Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top: focus goal stats
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Text(
                          'FOCUS GOAL',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                letterSpacing: 1.2,
                                color: colorScheme.primary,
                              ),
                        ),
                        const SizedBox(height: 4),
                        RichText(
                          text: TextSpan(
                            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                            children: [
                              TextSpan(text: '$percent'),
                              TextSpan(
                                text: '  %',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        _MetricRow(
                          icon: Icons.local_fire_department_outlined,
                          iconColor: Colors.orange,
                          label: 'Elapsed',
                          value: '${controller.elapsedMinutes} min',
                        ),
                        const SizedBox(height: 12),
                        _MetricRow(
                          icon: Icons.timer_outlined,
                          iconColor: colorScheme.primary,
                          label: 'Total',
                          value: '${controller.totalMinutes} min',
                        ),
                        const SizedBox(height: 12),
                        Builder(
                          builder: (context) {
                            final isRunning = controller.isRunning.value;
                            final isPaused = controller.isPaused.value;
                            final statusText = isRunning
                                ? (isPaused ? 'Paused' : 'In progress')
                                : 'Ready';
                            final statusColor = isRunning
                                ? (isPaused ? AppColors.warning : AppColors.success)
                                : Theme.of(context).colorScheme.onSurfaceVariant;
                            return _MetricRow(
                              icon: Icons.check_circle_outline,
                              iconColor: statusColor,
                              label: 'Status',
                              value: statusText,
                              highlightColor: statusColor,
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Illustration + single progress ring (ring sits outside the art, no overlap)
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final size = constraints.biggest.shortestSide;
                          final base = size * 0.92;
                          final inner = base * 0.74;
                          final stroke = (base * 0.038).clamp(3.0, 8.0);
                          return Center(
                            child: SizedBox(
                              width: base,
                              height: base,
                              child: Stack(
                                alignment: Alignment.center,
                                clipBehavior: Clip.none,
                                children: [
                                  SizedBox.expand(
                                    child: CircularProgressIndicator(
                                      value: controller.progress.clamp(0.0, 1.0),
                                      strokeWidth: stroke,
                                      strokeCap: StrokeCap.round,
                                      backgroundColor:
                                          colorScheme.outline.withValues(alpha: 0.14),
                                      color: colorScheme.primary.withValues(alpha: 0.95),
                                    ),
                                  ),
                                  _HabitCharacter(
                                    color: h.color,
                                    icon: h.icon,
                                    isActive: controller.isRunning.value &&
                                        !controller.isPaused.value,
                                    dimension: inner,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom card: habit info + timer + controls
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOut,
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 16 * (1 - value)),
                      child: child,
                    ),
                  );
                },
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                color: h.color.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(h.icon, color: h.color),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    h.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                  const SizedBox(height: 2),
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 250),
                                    child: Text(
                                      controller.isRunning.value
                                          ? (controller.isPaused.value
                                              ? 'Paused · Tap resume to continue'
                                              : 'Stay focused until the timer ends')
                                          : 'Choose duration then start your focus',
                                      key: ValueKey<bool>(
                                        controller.isRunning.value && controller.isPaused.value,
                                      ),
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              controller.formattedTime,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontFeatures: const [FontFeature.tabularFigures()],
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (!controller.isRunning.value) ...[
                          _DurationSelector(
                            selectedMinutes: controller.totalMinutes,
                            onSelected: (min) {
                              HapticFeedback.selectionClick();
                              controller.setDurationMinutes(min);
                            },
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: () {
                                if (controller.totalMinutes == 0) {
                                  controller.setDurationMinutes(25);
                                }
                                controller.start();
                              },
                              child: const Text('Start focus'),
                            ),
                          ),
                        ] else ...[
                          Row(
                            children: [
                              Expanded(
                                child: FilledButton.tonalIcon(
                                  onPressed: controller.isPaused.value ? controller.resume : controller.pause,
                                  icon: Icon(controller.isPaused.value ? Icons.play_arrow : Icons.pause),
                                  label: Text(controller.isPaused.value ? 'Resume' : 'Pause'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: controller.stop,
                                  icon: const Icon(Icons.stop),
                                  label: const Text('Stop'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
      ),
    );
  }

  void _confirmExit(BuildContext context) {
    Get.back();
  }
}

class _DurationSelector extends StatelessWidget {
  final int selectedMinutes;
  final ValueChanged<int> onSelected;

  const _DurationSelector({
    required this.selectedMinutes,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final items = const [15, 25, 45];
    final isPresetSelected = items.contains(selectedMinutes);
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.16),
        ),
      ),
      child: Row(
        children: [
          ...items.map((min) {
            final isSelected = selectedMinutes == min;
            return Expanded(
              child: _DurationPill(
                label: '$min min',
                isSelected: isSelected,
                onTap: () => onSelected(min),
              ),
            );
          }),
          Expanded(
            child: _DurationPill(
              label: isPresetSelected ? 'Custom' : '$selectedMinutes min',
              isSelected: !isPresetSelected,
              onTap: () async {
                final chosen = await _showCustomMinutesPicker(
                  context,
                  initialMinutes: selectedMinutes,
                );
                if (chosen != null) onSelected(chosen);
              },
            ),
          ),
        ],
      ),
    );
  }
}

Future<int?> _showCustomMinutesPicker(
  BuildContext context, {
  required int initialMinutes,
}) async {
  final cs = Theme.of(context).colorScheme;
  int temp = initialMinutes.clamp(1, 180);
  return await showModalBottomSheet<int>(
    context: context,
    showDragHandle: true,
    useSafeArea: true,
    backgroundColor: cs.surface,
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Custom duration',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              'Pick any duration from 1 to 180 minutes.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 18),
            StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    Row(
                      children: [
                        IconButton.filledTonal(
                          onPressed: temp > 1
                              ? () => setState(() => temp = (temp - 1).clamp(1, 180))
                              : null,
                          icon: const Icon(Icons.remove),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                '$temp min',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.5,
                                    ),
                              ),
                              Slider(
                                value: temp.toDouble(),
                                min: 1,
                                max: 180,
                                divisions: 179,
                                onChanged: (v) => setState(() => temp = v.round()),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        IconButton.filledTonal(
                          onPressed: temp < 180
                              ? () => setState(() => temp = (temp + 1).clamp(1, 180))
                              : null,
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () => Navigator.of(context).pop(temp),
                        child: const Text('Use this duration'),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      );
    },
  );
}

class _DurationPill extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _DurationPill({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_DurationPill> createState() => _DurationPillState();
}

class _DurationPillState extends State<_DurationPill> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bg = widget.isSelected ? cs.primary : Colors.transparent;
    final fg = widget.isSelected ? Colors.white : cs.onSurface;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: widget.isSelected
                  ? cs.primary.withValues(alpha: 0.9)
                  : cs.outline.withValues(alpha: 0.10),
              width: 1,
            ),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: cs.primary.withValues(alpha: 0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              style: Theme.of(context).textTheme.labelLarge!.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                    color: fg.withValues(alpha: widget.isSelected ? 1 : 0.9),
                  ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Text(
                    widget.label,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final Color? highlightColor;

  const _MetricRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Text(
                value,
                key: ValueKey<String>(value),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: highlightColor,
                    ),
              ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ],
    );
  }
}

class _HabitCharacter extends StatelessWidget {
  final Color color;
  final IconData icon;
  final bool isActive;
  final double dimension;

  const _HabitCharacter({
    required this.color,
    required this.icon,
    required this.isActive,
    this.dimension = 260,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FocusSessionController>();
    final habit = controller.habit.value;
    final category = habit?.category;
    final asset =
        category == null ? 'assets/animations/have_fun.json' : lottieForCategory(category);
    final radius = (dimension * 0.154).clamp(20.0, 44.0);

    return Material(
      color: Colors.transparent,
      child: Container(
        width: dimension,
        height: dimension,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(radius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Lottie.asset(
          asset,
          repeat: true,
          animate: isActive,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
