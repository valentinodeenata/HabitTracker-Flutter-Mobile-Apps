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
    return Scaffold(
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
                          icon: Icons.local_fire_department_rounded,
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

                    // Big character + rings under status
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final size = constraints.biggest.shortestSide;
                          final base = size * 0.9;
                          return Center(
                            child: SizedBox(
                              width: base,
                              height: base,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  _Ring(
                                    size: base,
                                    color: colorScheme.primary.withValues(alpha: 0.22),
                                    value: controller.progress,
                                  ),
                                  _Ring(
                                    size: base * 0.78,
                                    color: Colors.deepOrangeAccent.withValues(alpha: 0.24),
                                    value: controller.progress * 0.9,
                                    rotateTurns: 0.15,
                                  ),
                                  _Ring(
                                    size: base * 0.6,
                                    color: Colors.purpleAccent.withValues(alpha: 0.26),
                                    value: controller.progress * 0.8,
                                    rotateTurns: -0.2,
                                  ),
                                  _HabitCharacter(
                                    color: h.color,
                                    icon: h.icon,
                                    isActive:
                                        controller.isRunning.value && !controller.isPaused.value,
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
    );
  }

  void _confirmExit(BuildContext context) {
    if (controller.isRunning.value) {
      Get.dialog(
        AlertDialog(
          title: const Text('End focus session?'),
          content: const Text('Progress will not be saved.'),
          actions: [
            TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                Get.back();
                controller.stop();
              },
              child: const Text('End'),
            ),
          ],
        ),
      );
    } else {
      Get.back();
    }
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
        children: items.map((min) {
          final isSelected = selectedMinutes == min;
          return Expanded(
            child: _DurationPill(
              label: '$min min',
              isSelected: isSelected,
              onTap: () => onSelected(min),
            ),
          );
        }).toList(),
      ),
    );
  }
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
              child: Text(widget.label),
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

class _Ring extends StatelessWidget {
  final double size;
  final Color color;
  final double value;
  final double rotateTurns;

  const _Ring({
    required this.size,
    required this.color,
    required this.value,
    this.rotateTurns = 0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Transform.rotate(
        angle: rotateTurns * 3.14159 * 2,
        child: CircularProgressIndicator(
          value: value.clamp(0.0, 1.0),
          strokeWidth: size * 0.08,
          backgroundColor: Colors.transparent,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ),
    );
  }
}

class _HabitCharacter extends StatelessWidget {
  final Color color;
  final IconData icon;
  final bool isActive;

  const _HabitCharacter({
    required this.color,
    required this.icon,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FocusSessionController>();
    final habit = controller.habit.value;
    final category = habit?.category;
    final asset =
        category == null ? 'assets/animations/have_fun.json' : lottieForCategory(category);

    return FittedBox(
      fit: BoxFit.contain,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Lottie.asset(
              asset,
              repeat: true,
              animate: isActive,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}
