import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_flow/core/routes/app_routes.dart';
import 'package:habit_flow/core/theme/app_colors.dart';
import 'package:habit_flow/features/habit/data/habit_model.dart';
import 'package:habit_flow/features/habit/presentation/controllers/habit_controller.dart';

class HomeView extends GetView<HabitController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.todayHabits.isEmpty) {
          return _EmptyState(onAdd: () => Get.toNamed(AppRoutes.addHabit));
        }
        final completed = controller.todayHabits
            .where((h) => controller.isCompletedToday(h.id))
            .length;
        final total = controller.todayHabits.length;
        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: _ProgressCard(
                  completed: completed,
                  total: total,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final habit = controller.todayHabits[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _HabitTile(
                        habit: habit,
                        isCompleted: controller.isCompletedToday(habit.id),
                        streak: controller.getStreak(habit.id),
                        onToggle: () => controller.toggleComplete(habit.id),
                        onFocus: () => Get.toNamed(
                          AppRoutes.focusSession,
                          arguments: habit,
                        ),
                        onEdit: () => Get.toNamed(AppRoutes.editHabit, arguments: habit),
                      ),
                    );
                  },
                  childCount: controller.todayHabits.length,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        );
      }),
      appBar: AppBar(
        title: const Text('HabitFlow'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart_rounded),
            onPressed: () => Get.toNamed(AppRoutes.stats),
          ),
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () => Get.toNamed(AppRoutes.settings),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(AppRoutes.addHabit),
        icon: const Icon(Icons.add),
        label: const Text('Add habit'),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.8, end: 1),
              duration: const Duration(milliseconds: 600),
              curve: Curves.elasticOut,
              builder: (context, value, child) => Transform.scale(
                scale: value,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Icon(
                    Icons.auto_awesome,
                    size: 48,
                    color: AppColors.primary.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No habits for today',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first habit and start building\nyour daily routine',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add habit'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final int completed;
  final int total;

  const _ProgressCard({required this.completed, required this.total});

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? completed / total : 0.0;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Today's progress",
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          letterSpacing: 0.5,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$completed / $total habits',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 64,
              height: 64,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: progress),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) => CircularProgressIndicator(
                  value: value,
                  strokeWidth: 6,
                  backgroundColor: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest
                      .withValues(alpha: 0.5),
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HabitTile extends StatelessWidget {
  final HabitModel habit;
  final bool isCompleted;
  final int streak;
  final VoidCallback onToggle;
  final VoidCallback onFocus;
  final VoidCallback onEdit;

  const _HabitTile({
    required this.habit,
    required this.isCompleted,
    required this.streak,
    required this.onToggle,
    required this.onFocus,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: habit.color.withValues(alpha: isCompleted ? 0.15 : 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(habit.icon, color: habit.color, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        decoration: isCompleted ? TextDecoration.lineThrough : null,
                        color: isCompleted
                            ? Theme.of(context).colorScheme.onSurfaceVariant
                            : null,
                      ),
                    ),
                    if (streak > 0) ...[
                      const SizedBox(height: 4),
                      Text(
                        '🔥 $streak day streak',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.warning,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton.filled(
                onPressed: onFocus,
                icon: const Icon(Icons.timer_outlined, size: 20),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                  foregroundColor: AppColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 20),
              ),
              const SizedBox(width: 4),
              Checkbox(
                value: isCompleted,
                onChanged: (_) => onToggle(),
                activeColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
