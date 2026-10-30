import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/calendar_event.dart';
import '../providers/calendar_service.dart';
import '../providers/settings_service.dart';

class CalendarPanel extends StatelessWidget {
  static const double height = 136;

  const CalendarPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final calendar = context.watch<CalendarService>();
    final timeFormat = context.select<SettingsService, String>(
      (s) => s.timeFormat,
    );
    final now = DateTime.now();
    final events = calendar.events
        .where((e) => e.end.isAfter(now) || !e.start.isBefore(now))
        .take(3)
        .toList();
    return SizedBox(
      height: height,
      child: Container(
        margin: const EdgeInsets.fromLTRB(40, 8, 40, 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 17),
                const SizedBox(width: 8),
                Text(
                  strings.calendar,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                if (calendar.usingCache)
                  Text(
                    strings.calendarCached,
                    style: const TextStyle(fontSize: 11, color: Colors.white70),
                  ),
                if (calendar.loading) ...[
                  const SizedBox(width: 8),
                  const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: events.isEmpty
                  ? Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        calendar.loading
                            ? strings.calendarLoading
                            : calendar.hasError && calendar.updatedAt == null
                            ? strings.calendarLoadFailed
                            : strings.calendarNoEvents,
                      ),
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (var i = 0; i < events.length; i++) ...[
                          if (i > 0)
                            const VerticalDivider(
                              width: 28,
                              color: Colors.white24,
                            ),
                          Expanded(
                            child: _event(context, events[i], timeFormat),
                          ),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _event(BuildContext context, CalendarEvent event, String timeFormat) {
    final strings = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final date = DateFormat('EEE d MMM', locale).format(event.start);
    final time = event.allDay
        ? strings.calendarAllDay
        : DateFormat(timeFormat, locale).format(event.start);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$date · $time',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12, color: Colors.white70),
        ),
        const SizedBox(height: 5),
        Expanded(
          child: Text(
            event.title.isEmpty ? strings.calendarUntitled : event.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}
