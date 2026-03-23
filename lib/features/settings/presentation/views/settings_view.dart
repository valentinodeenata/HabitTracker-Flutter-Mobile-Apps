import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_flow/core/theme/app_colors.dart';
import 'package:habit_flow/core/services/notification_service.dart';
import 'package:habit_flow/core/services/system_ringtone_picker.dart';
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
                    icon: Icons.dark_mode_outlined,
                    title: 'Dark mode',
                    subtitle: 'Use dark theme',
                    trailing: Switch(
                      value: c.isDarkMode,
                      onChanged: c.setDarkMode,
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
                    icon: Icons.notifications_outlined,
                    title: 'Reminders',
                    subtitle: 'Daily habit reminders',
                    trailing: Switch(
                      value: c.notificationsEnabled,
                      onChanged: c.setNotificationsEnabled,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Focus complete',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    letterSpacing: 0.5,
                  ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SwitchListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 6),
                      secondary: Icon(
                        Icons.volume_up_outlined,
                        color: AppColors.primary.withValues(alpha: 0.9),
                      ),
                      title: const Text('Aktif'),
                      subtitle: const Text('Play sound & heads-up saat selesai'),
                      value: c.focusCompleteEnabled,
                      onChanged: c.setFocusCompleteEnabled,
                    ),
                    const Divider(height: 1),
                    const SizedBox(height: 6),
                    Text(
                      'Sound',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 8),

                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 6),
                      leading: Icon(
                        Icons.music_note_outlined,
                        color: AppColors.primary.withValues(alpha: 0.9),
                      ),
                      title: Text(
                        c.focusCompleteSoundUri.isEmpty
                            ? 'System default'
                            : (c.focusCompleteSoundTitle.trim().isEmpty ||
                                    c.focusCompleteSoundTitle
                                        .trim()
                                        .contains('content://') ||
                                    c.focusCompleteSoundTitle
                                        .trim()
                                        .contains('/') ||
                                    c.focusCompleteSoundTitle.trim().length > 28
                                ? 'Custom sound'
                                : c.focusCompleteSoundTitle.trim()),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: const Text('Choose alarm / notification tone'),
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: c.focusCompleteEnabled
                                ? () async {
                                    final picked = await SystemRingtonePicker
                                        .pickAlarmSound();
                                    if (picked == null) return;
                                    c.setFocusCompleteSoundUri(
                                      picked.uri,
                                      picked.title,
                                    );
                                  }
                                : null,
                            icon: const Icon(Icons.music_note_rounded),
                            label: const Text('Pick sound'),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.tonalIcon(
                        onPressed: c.focusCompleteEnabled
                            ? c.useSystemDefaultFocusCompleteSound
                            : null,
                        icon: const Icon(Icons.volume_up_rounded),
                        label: const Text('Use system default'),
                      ),
                    ),

                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: c.focusCompleteEnabled
                            ? () async {
                                await NotificationService.to
                                    .showFocusCompleteNow(
                                  habitId: 'test',
                                  habitName: 'HabitFlow',
                                  minutesLogged: 1,
                                );
                              }
                            : null,
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text('Test sound'),
                      ),
                    ),

                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Text(
                        'Volume mengikuti pengaturan Alarm Android (system).',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color:
                                  Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                'Applies when a focus session ends. On Android, choose tone here; heads-up style uses your selected channel.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
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
