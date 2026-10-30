import 'package:firstfloor_calendar/firstfloor_calendar.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

Uri? calendarFeedUri(String value) {
  final url = value.trim().replaceFirst(
    RegExp(r'^webcal://', caseSensitive: false),
    'https://',
  );
  final uri = Uri.tryParse(url);
  return uri != null && uri.scheme == 'https' && uri.host.isNotEmpty
      ? uri
      : null;
}

class CalendarEvent {
  final String title;
  final DateTime start;
  final DateTime end;
  final bool allDay;

  const CalendarEvent(this.title, this.start, this.end, this.allDay);
}

// Runs in a background isolate so large Google Calendar feeds do not stall Home.
List<CalendarEvent> parseCalendarEvents((String, DateTime) input) {
  tzdata.initializeTimeZones();
  final (feed, now) = input;
  if (!feed.trimLeft().startsWith('BEGIN:VCALENDAR')) {
    throw const FormatException('Not an iCalendar feed');
  }
  final document = DocumentParser().parse(feed);
  // Google can omit DTSTART on a cancelled occurrence. Give the parser its
  // original start so we can suppress it without displaying the cancellation.
  final normalized = CalendarDocument(
    properties: document.properties,
    components: document.components.map((component) {
      final recurrence = component.propertiesNamed('RECURRENCE-ID').firstOrNull;
      if (component.name != 'VEVENT' ||
          component.value('STATUS') != 'CANCELLED' ||
          component.value('DTSTART') != null ||
          recurrence == null)
        return component;
      return CalendarDocumentComponent(
        name: component.name,
        components: component.components,
        properties: [
          ...component.properties,
          CalendarProperty(
            name: 'DTSTART',
            parameters: recurrence.parameters,
            value: recurrence.value,
          ),
        ],
      );
    }).toList(),
  );
  final calendar = CalendarParser().parse(normalized);
  final overrides = <String>{};
  for (final event in calendar.events) {
    final property = event.properties['RECURRENCE-ID']?.first.property;
    if (property == null) continue;
    var date = DateTime.parse(property.value);
    final zone = property.parameters['TZID']?.first;
    if (!date.isUtc && zone != null) {
      date = tz.TZDateTime(
        tz.getLocation(zone),
        date.year,
        date.month,
        date.day,
        date.hour,
        date.minute,
        date.second,
      );
    }
    overrides.add('${event.uid}/${date.millisecondsSinceEpoch}');
  }

  final until = DateTime(now.year, now.month, now.day + 7);
  final occurrences = calendar.events
      .where((event) => event.status != EventStatus.cancelled)
      .occurrences(
        start: CalDateTime.local(now.year, now.month, now.day),
        end: CalDateTime.local(until.year, until.month, until.day),
      );
  final result = <CalendarEvent>[];
  for (final item in occurrences) {
    final event = item.event;
    final occurrence = item.occurrence;
    if (event.recurrenceId == null &&
        overrides.contains(
          '${event.uid}/${occurrence.native.millisecondsSinceEpoch}',
        )) {
      continue;
    }
    // TZDateTime.toLocal() uses the library's zone, not the TV's system zone.
    final start = DateTime.fromMillisecondsSinceEpoch(
      occurrence.native.millisecondsSinceEpoch,
    );
    final endDate = event.effectiveDuration != null
        ? occurrence.addDuration(event.effectiveDuration!).native
        : start.add(event.isAllDay ? const Duration(days: 1) : Duration.zero);
    final end = DateTime.fromMillisecondsSinceEpoch(
      endDate.millisecondsSinceEpoch,
    );
    if (!start.isBefore(until) || (!end.isAfter(now) && start.isBefore(now)))
      continue;
    result.add(
      CalendarEvent(event.summary?.trim() ?? '', start, end, event.isAllDay),
    );
    if (result.length == 500) break;
  }
  return result;
}
