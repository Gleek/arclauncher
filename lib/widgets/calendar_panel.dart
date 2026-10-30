import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/calendar_event.dart';
import '../providers/calendar_service.dart';
import '../providers/settings_service.dart';
import 'settings/settings_theme.dart';

class CalendarPanel extends StatelessWidget {
  static const double height = 320;
  final VoidCallback? onFocused;

  const CalendarPanel({super.key, this.onFocused});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final calendar = context.watch<CalendarService>();
    final timeFormat = context.select<SettingsService, String>(
      (s) => s.timeFormat,
    );
    final locale = Localizations.localeOf(context).toLanguageTag();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final last = DateTime(now.year, now.month, now.day + 6);
    final events = calendar.events
        .where((e) => e.end.isAfter(now) || !e.start.isBefore(now))
        .toList();
    final status = calendar.loading
        ? strings.calendarLoading
        : calendar.usingCache
        ? strings.calendarCached
        : calendar.hasError
        ? strings.calendarLoadFailed
        : '';

    return SizedBox(
      height: height,
      child: Container(
        margin: const EdgeInsets.fromLTRB(40, 8, 40, 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 17),
                const SizedBox(width: 8),
                Text(
                  strings.calendar,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 14),
                Text(
                  '${DateFormat('d MMM', locale).format(today)} – ${DateFormat('d MMM', locale).format(last)}',
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    status,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontSize: 11, color: Colors.white70),
                  ),
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
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: List.generate(7, (index) {
                  final day = DateTime(
                    today.year,
                    today.month,
                    today.day + index,
                  );
                  final next = DateTime(
                    today.year,
                    today.month,
                    today.day + index + 1,
                  );
                  final items =
                      events
                          .where(
                            (e) =>
                                e.start.isBefore(next) &&
                                (e.end.isAfter(day) ||
                                    e.start.isAtSameMomentAs(day)),
                          )
                          .toList()
                        ..sort(
                          (a, b) => a.allDay == b.allDay
                              ? a.start.compareTo(b.start)
                              : a.allDay
                              ? -1
                              : 1,
                        );
                  return Expanded(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border(
                          right: index < 6
                              ? const BorderSide(color: Colors.white12)
                              : BorderSide.none,
                        ),
                      ),
                      child: SettingsFocusCard(
                        key: ValueKey('calendar-day-$index'),
                        autofocus: index == 0,
                        margin: EdgeInsets.zero,
                        padding: const EdgeInsets.all(7),
                        radius: 0,
                        onPressed: () =>
                            _showDay(context, day, items, timeFormat),
                        onFocusChange: (focused) {
                          if (focused) {
                            onFocused?.call();
                            Scrollable.ensureVisible(
                              context,
                              alignment: 0,
                              duration: const Duration(milliseconds: 200),
                            );
                          }
                        },
                        builder: (context, highlighted) => Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    DateFormat('EEE', locale).format(day),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: index == 0
                                        ? Colors.redAccent
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    DateFormat(
                                      day.day == 1 ? 'd MMM' : 'd',
                                      locale,
                                    ).format(day),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      height: 1.2,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            if (items.isEmpty)
                              Text(
                                strings.calendarDayEmpty,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.white38,
                                ),
                              ),
                            for (final event in items.take(7))
                              _eventBar(context, event, day, timeFormat),
                            if (items.length > 7)
                              Text(
                                '+${items.length - 7}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.white70,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _eventBar(
    BuildContext context,
    CalendarEvent event,
    DateTime day,
    String format,
  ) {
    final strings = AppLocalizations.of(context)!;
    final title = event.title.isEmpty ? strings.calendarUntitled : event.title;
    return Container(
      height: 22,
      margin: const EdgeInsets.only(bottom: 2),
      padding: event.allDay
          ? const EdgeInsets.symmetric(horizontal: 4)
          : EdgeInsets.zero,
      decoration: event.allDay
          ? BoxDecoration(
              color: const Color(0xFFAD8251).withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(4),
            )
          : null,
      child: event.allDay
          ? Align(
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11.5),
              ),
            )
          : Row(
              children: [
                Container(
                  width: 3,
                  height: 13,
                  decoration: BoxDecoration(
                    color: const Color(0xFFA69BFF),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                const SizedBox(width: 3),
                Text(
                  _time(context, event, day, format),
                  style: const TextStyle(fontSize: 9.5, color: Colors.white60),
                ),
              ],
            ),
    );
  }

  String _time(
    BuildContext context,
    CalendarEvent event,
    DateTime day,
    String format,
  ) {
    final strings = AppLocalizations.of(context)!;
    if (event.allDay) return strings.calendarAllDay;
    if (event.start.isBefore(day)) return strings.calendarContinues;
    return DateFormat(
      format,
      Localizations.localeOf(context).toLanguageTag(),
    ).format(event.start);
  }

  void _showDay(
    BuildContext context,
    DateTime day,
    List<CalendarEvent> events,
    String format,
  ) {
    final strings = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toLanguageTag();
    showDialog<void>(
      context: context,
      builder: (context) => Shortcuts(
        shortcuts: const {
          SingleActivator(LogicalKeyboardKey.arrowDown): NextFocusIntent(),
          SingleActivator(LogicalKeyboardKey.arrowUp): PreviousFocusIntent(),
        },
        child: FocusTraversalGroup(
          policy: WidgetOrderTraversalPolicy(),
          child: AlertDialog(
            title: Text(DateFormat('EEEE d MMMM', locale).format(day)),
            content: SizedBox(
              width: 500,
              height: MediaQuery.sizeOf(context).height * 0.55,
              child: events.isEmpty
                  ? Text(strings.calendarDayEmpty)
                  : SingleChildScrollView(
                      child: Column(
                        children: List.generate(events.length, (index) {
                          final event = events[index];
                          return Builder(
                            builder: (itemContext) => SettingsFocusCard(
                              autofocus: index == 0,
                              onFocusChange: (focused) {
                                if (focused)
                                  Scrollable.ensureVisible(
                                    itemContext,
                                    duration: const Duration(milliseconds: 200),
                                  );
                              },
                              builder: (context, highlighted) => Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    event.title.isEmpty
                                        ? strings.calendarUntitled
                                        : event.title,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    event.allDay
                                        ? strings.calendarAllDay
                                        : '${_time(context, event, day, format)} – ${DateFormat(format, locale).format(event.end)}',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(strings.calendarClose),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
