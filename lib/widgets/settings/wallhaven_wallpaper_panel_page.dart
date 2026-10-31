import 'package:flauncher/l10n/app_localizations.dart';
import 'package:flauncher/providers/settings_service.dart';
import 'package:flauncher/providers/wallpaper_service.dart';
import 'package:flauncher/widgets/rounded_switch_list_tile.dart';
import 'package:flauncher/widgets/settings/focusable_settings_tile.dart';
import 'package:flauncher/widgets/settings/settings_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WallhavenWallpaperPanelPage extends StatefulWidget {
  static const routeName = 'wallhaven_wallpaper_panel';

  const WallhavenWallpaperPanelPage({super.key});

  @override
  State<WallhavenWallpaperPanelPage> createState() => _WallhavenWallpaperPanelPageState();
}

class _WallhavenWallpaperPanelPageState extends State<WallhavenWallpaperPanelPage> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Consumer<SettingsService>(
      builder: (context, settings, _) {
        Future<void> editTerms() async {
          final terms = await _askText(
            l.wallhavenSearchTerms,
            settings.wallhavenSearchTerms,
            l.wallhavenSearchTermsHelp,
          );
          if (terms != null) await settings.setWallhavenSearchTerms(terms);
        }

        return Column(
          children: [
            SettingsPageHeader(title: l.wallhavenWallpaper),
            Expanded(
              child: ListView(
                children: [
                  RoundedSwitchListTile(
                    autofocus: true,
                    title: Text(l.wallhavenEnable),
                    secondary: const Icon(Icons.wallpaper),
                    value: settings.wallhavenWallpaperEnabled,
                    onChanged: (value) async {
                      if (value && settings.wallhavenSearchTerms.isEmpty) {
                        await editTerms();
                      } else {
                        await settings.setWallhavenWallpaperEnabled(value);
                      }
                    },
                  ),
                  FocusableSettingsTile(
                    leading: const Icon(Icons.search),
                    title: Text(l.wallhavenSearchTerms),
                    subtitle: Text(
                      settings.wallhavenSearchTerms.isEmpty ? l.unsplashNotSet : settings.wallhavenSearchTerms,
                    ),
                    onPressed: editTerms,
                  ),
                  FocusableSettingsTile(
                    leading: const Icon(Icons.timer_outlined),
                    title: Text(l.unsplashInterval),
                    trailing: Text(l.unsplashIntervalMinutes(settings.wallhavenIntervalMinutes)),
                    onPressed: () {
                      const choices = SettingsService.redditIntervalChoices;
                      settings.setWallhavenIntervalMinutes(
                        choices[(choices.indexOf(settings.wallhavenIntervalMinutes) + 1) % choices.length],
                      );
                    },
                  ),
                  FocusableSettingsTile(
                    leading: const Icon(Icons.refresh),
                    title: Text(l.wallhavenNextWallpaper),
                    trailing: _loading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator())
                        : null,
                    onPressed: !settings.wallhavenWallpaperEnabled || _loading
                        ? null
                        : () async {
                            setState(() => _loading = true);
                            final success = await context.read<WallpaperService>().advanceWallhavenWallpaper();
                            if (!mounted) return;
                            setState(() => _loading = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(success ? l.redditWallpaperUpdated : l.wallhavenWallpaperFailed)),
                            );
                          },
                  ),
                  Padding(padding: const EdgeInsets.all(24), child: SelectableText(l.wallhavenAttribution)),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Future<String?> _askText(String title, String initial, String help) => showDialog<String>(
    context: context,
    builder: (context) => SimpleDialog(
      insetPadding: const EdgeInsets.only(bottom: 120),
      contentPadding: const EdgeInsets.all(24),
      title: Text(title),
      children: [
        Padding(padding: const EdgeInsets.only(bottom: 16), child: Text(help)),
        TextFormField(
          autofocus: true,
          initialValue: initial,
          autocorrect: false,
          onFieldSubmitted: (value) => Navigator.of(context).pop(value),
        ),
      ],
    ),
  );
}
