import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/calendar_event.dart';
import '../../providers/calendar_service.dart';
import '../../providers/settings_service.dart';
import '../rounded_switch_list_tile.dart';
import 'focusable_settings_tile.dart';
import 'settings_theme.dart';

class CalendarPanelPage extends StatelessWidget {
  static const routeName = 'calendar_panel';

  const CalendarPanelPage({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final settings = context.watch<SettingsService>();
    final calendar = context.watch<CalendarService>();
    return Column(
      children: [
        SettingsPageHeader(title: strings.calendar),
        Expanded(
          child: ListView(
            children: [
              RoundedSwitchListTile(
                autofocus: true,
                title: Text(strings.calendarShow),
                secondary: const Icon(Icons.calendar_today_outlined),
                value: settings.calendarEnabled,
                onChanged: (enabled) async {
                  if (enabled && settings.calendarUrl.isEmpty)
                    await _editUrl(context);
                  if (settings.calendarUrl.isNotEmpty)
                    await settings.setCalendarEnabled(enabled);
                },
              ),
              FocusableSettingsTile(
                leading: const Icon(Icons.link),
                title: Text(strings.calendarUrl),
                subtitle: Text(
                  settings.calendarUrl.isEmpty
                      ? strings.calendarNotConfigured
                      : strings.calendarConfigured,
                ),
                onPressed: () => _editUrl(context),
              ),
              FocusableSettingsTile(
                leading: const Icon(Icons.refresh),
                title: Text(strings.calendarRefresh),
                subtitle: Text(
                  calendar.loading
                      ? strings.calendarLoading
                      : calendar.hasError
                      ? strings.calendarLoadFailed
                      : calendar.updatedAt != null
                      ? strings.calendarUpdated
                      : strings.calendarNotConfigured,
                ),
                onPressed: settings.calendarEnabled && !calendar.loading
                    ? () => calendar.refresh()
                    : null,
              ),
              if (settings.calendarUrl.isNotEmpty)
                FocusableSettingsTile(
                  leading: const Icon(Icons.link_off),
                  title: Text(strings.calendarRemove),
                  onPressed: () async {
                    await settings.setCalendarEnabled(false);
                    await settings.setCalendarUrl('');
                  },
                ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(strings.calendarHelp),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _editUrl(BuildContext context) async {
    final settings = context.read<SettingsService>();
    final strings = AppLocalizations.of(context)!;
    var draft = settings.calendarUrl;
    final form = GlobalKey<FormState>();
    void save(BuildContext dialogContext) {
      if (form.currentState!.validate())
        Navigator.pop(dialogContext, calendarFeedUri(draft).toString());
    }

    final url = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(strings.calendarUrl),
        content: Form(
          key: form,
          child: TextFormField(
            initialValue: draft,
            onChanged: (value) => draft = value,
            autofocus: true,
            obscureText: true,
            autocorrect: false,
            enableSuggestions: false,
            keyboardType: TextInputType.url,
            decoration: const InputDecoration(hintText: 'https://…/basic.ics'),
            validator: (value) => calendarFeedUri(value ?? '') == null
                ? strings.calendarInvalidUrl
                : null,
            onFieldSubmitted: (_) => save(dialogContext),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(strings.calendarCancel),
          ),
          TextButton(
            onPressed: () => save(dialogContext),
            child: Text(strings.save),
          ),
        ],
      ),
    );
    if (url != null) await settings.setCalendarUrl(url);
  }
}
