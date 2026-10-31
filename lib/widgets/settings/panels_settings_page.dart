import 'package:flauncher/l10n/app_localizations.dart';
import 'package:flauncher/providers/settings_service.dart';
import 'package:flauncher/widgets/rounded_switch_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'calendar_panel_page.dart';
import 'feed_refresh_tile.dart';
import '../../providers/remote_feed.dart';
import 'focusable_settings_tile.dart';
import 'settings_theme.dart';

class PanelsSettingsPage extends StatelessWidget {
  static const routeName = 'panels_settings';

  const PanelsSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final settings = context.watch<SettingsService>();
    final ayahs = context.watch<AyahFeed?>();
    return Column(
      children: [
        SettingsPageHeader(title: strings.panels),
        Expanded(
          child: ListView(
            children: [
              RoundedSwitchListTile(
                autofocus: true,
                value: settings.showDailyAyah,
                onChanged: settings.setShowDailyAyah,
                title: Text(
                  strings.showDailyAyah,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                secondary: const Icon(Icons.auto_stories_outlined),
              ),
              if (ayahs != null) FeedRefreshTile(feed: ayahs, title: strings.refreshAyahs),
              FocusableSettingsTile(
                showChevron: true,
                leading: const Icon(Icons.calendar_today_outlined),
                title: Text(
                  strings.calendar,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                onPressed: () => Navigator.of(
                  context,
                ).pushNamed(CalendarPanelPage.routeName),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
