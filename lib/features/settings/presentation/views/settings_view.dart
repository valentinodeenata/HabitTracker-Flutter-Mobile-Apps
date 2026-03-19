import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_flow/core/theme/app_colors.dart';
import 'package:habit_flow/features/settings/presentation/controllers/settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: GetBuilder<SettingsController>(
        builder: (c) => ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Appearance',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    letterSpacing: 0.5,
                  ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: [
                  _SettingsTile(
                    icon: Icons.dark_mode_rounded,
                    title: 'Dark mode',
                    subtitle: 'Use dark theme',
                    trailing: Switch(
                      value: c.isDarkMode,
                      onChanged: c.setDarkMode,
                      activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Notifications',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    letterSpacing: 0.5,
                  ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: [
                  _SettingsTile(
                    icon: Icons.notifications_rounded,
                    title: 'Reminders',
                    subtitle: 'Daily habit reminders',
                    trailing: Switch(
                      value: c.notificationsEnabled,
                      onChanged: c.setNotificationsEnabled,
                      activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.primary, size: 22),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
      trailing: trailing,
    );
  }
}
