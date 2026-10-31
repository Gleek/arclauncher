import 'package:flauncher/l10n/app_localizations.dart';
import 'package:flauncher/providers/settings_service.dart';
import 'package:flauncher/providers/wallpaper_service.dart';
import 'package:flauncher/widgets/rounded_switch_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'feed_refresh_tile.dart';
import 'focusable_settings_tile.dart';
import 'settings_theme.dart';

class GistWallpaperPanelPage extends StatefulWidget {
  static const routeName = 'gist_wallpaper_panel';
  const GistWallpaperPanelPage({super.key});
  @override
  State<GistWallpaperPanelPage> createState() => _GistWallpaperPanelPageState();
}

class _GistWallpaperPanelPageState extends State<GistWallpaperPanelPage> {
  bool _loading = false;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final settings = context.watch<SettingsService>();
    final wallpaper = context.read<WallpaperService>();
    return Column(
      children: [
        SettingsPageHeader(title: l.gistWallpaper),
        Expanded(
          child: ListView(
            children: [
              RoundedSwitchListTile(
                autofocus: true,
                title: Text(l.gistWallpaperEnable),
                secondary: const Icon(Icons.cloud_outlined),
                value: settings.gistWallpaperEnabled,
                onChanged: settings.setGistWallpaperEnabled,
              ),
              FeedRefreshTile(feed: wallpaper.gistFeed, title: l.feedRefresh),
              Padding(padding: const EdgeInsets.all(24), child: Text(l.gistWallpaperHelp)),
              FocusableSettingsTile(
                leading: const Icon(Icons.timer_outlined),
                title: Text(l.unsplashInterval),
                trailing: Text(l.unsplashIntervalMinutes(settings.gistIntervalMinutes)),
                onPressed: () {
                  const choices = SettingsService.redditIntervalChoices;
                  settings.setGistIntervalMinutes(
                    choices[(choices.indexOf(settings.gistIntervalMinutes) + 1) % choices.length],
                  );
                },
              ),
              FocusableSettingsTile(
                leading: const Icon(Icons.skip_next),
                title: Text(l.wallhavenNextWallpaper),
                trailing: _loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator()) : null,
                onPressed: !settings.gistWallpaperEnabled || _loading
                    ? null
                    : () async {
                        setState(() => _loading = true);
                        final success = await wallpaper.advanceGistWallpaper();
                        if (!mounted) return;
                        setState(() => _loading = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(success ? l.redditWallpaperUpdated : l.gistWallpaperFailed)),
                        );
                      },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
