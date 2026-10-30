import 'dart:async';
import 'dart:io';

import 'package:flauncher/models/calendar_event.dart';
import 'package:flauncher/providers/calendar_service.dart';
import 'package:flauncher/providers/settings_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

String feed(String events) =>
    'BEGIN:VCALENDAR\nVERSION:2.0\nPRODID:-//Arc Test//EN\n$events\nEND:VCALENDAR';
String event(String lines) =>
    'BEGIN:VEVENT\nDTSTAMP:20261001T000000Z\n$lines\nEND:VEVENT';

Future<void> settled(CalendarService service) async {
  await Future.doWhile(() async {
    await Future<void>.delayed(const Duration(milliseconds: 10));
    return service.loading;
  }).timeout(const Duration(seconds: 10));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'expands recurring meetings with exclusions, moved and cancelled instances',
    () {
      final source = feed(
        [
          event(
            'UID:meeting\nDTSTART;TZID=Asia/Kolkata:20261028T090000\n'
            'DTEND;TZID=Asia/Kolkata:20261028T100000\nRRULE:FREQ=DAILY;COUNT=5\n'
            'EXDATE;TZID=Asia/Kolkata:20261030T090000\nSUMMARY:Standup',
          ),
          event(
            'UID:meeting\nRECURRENCE-ID;TZID=Asia/Kolkata:20261031T090000\n'
            'DTSTART;TZID=Asia/Kolkata:20261031T120000\n'
            'DTEND;TZID=Asia/Kolkata:20261031T130000\nSUMMARY:Moved standup',
          ),
          event(
            'UID:meeting\nRECURRENCE-ID;TZID=Asia/Kolkata:20261101T090000\nSTATUS:CANCELLED',
          ),
        ].join('\n'),
      );
      final events = parseCalendarEvents((
        source,
        DateTime.utc(2026, 10, 30, 4),
      ));
      expect(events.map((e) => e.title), ['Moved standup']);
      expect(events.single.start.toUtc(), DateTime.utc(2026, 10, 31, 6, 30));
      expect(events.single.end.toUtc(), DateTime.utc(2026, 10, 31, 7, 30));
    },
  );

  test('keeps all-day and ongoing multi-day events, skips finished events', () {
    final source = feed(
      [
        event('UID:day\nDTSTART;VALUE=DATE:20261030\nSUMMARY:Holiday'),
        event(
          'UID:trip\nDTSTART:20261028T060000Z\nDTEND:20261031T060000Z\nSUMMARY:Trip',
        ),
        event(
          'UID:finished\nDTSTART:20261030T010000Z\nDTEND:20261030T020000Z\nSUMMARY:Finished',
        ),
      ].join('\n'),
    );
    final events = parseCalendarEvents((
      source,
      DateTime.utc(2026, 10, 30, 12),
    ));
    expect(events.map((e) => e.title), ['Trip', 'Holiday']);
    expect(events.last.allDay, isTrue);
    final tomorrow = parseCalendarEvents((
      source,
      DateTime.utc(2026, 10, 31, 12),
    ));
    expect(tomorrow, isEmpty);
  });

  test(
    'normalizes webcal URLs and rejects webpages without HTTPS or a host',
    () {
      expect(
        calendarFeedUri(' webcal://calendar.example.test/feed.ics ')!.scheme,
        'https',
      );
      expect(
        calendarFeedUri('https://calendar.example.test/feed.ics')!.host,
        'calendar.example.test',
      );
      expect(calendarFeedUri('file:///private/feed.ics'), isNull);
      expect(calendarFeedUri('not a URL'), isNull);
      expect(calendarFeedUri('https:///'), isNull);
    },
  );

  test('reports invalid feed data rather than an empty calendar', () {
    expect(
      () => parseCalendarEvents(('<html>Sign in</html>', DateTime.now())),
      throwsFormatException,
    );
  });

  test(
    'loads a feed, preserves events after network failure, and hides URL errors',
    () async {
      SharedPreferences.setMockInitialValues({
        'calendar_enabled': true,
        'calendar_url': 'https://calendar.example.test/feed.ics',
      });
      final settings = SettingsService(await SharedPreferences.getInstance());
      var offline = false;
      final now = DateTime.now().toUtc();
      final tomorrow = now.add(const Duration(days: 1));
      final stamp = tomorrow
          .toIso8601String()
          .replaceAll(RegExp('[-:]'), '')
          .split('.')
          .first;
      final service = CalendarService(
        settings,
        client: MockClient(
          (_) async => offline
              ? http.Response('Unavailable', 503)
              : http.Response(
                  feed(
                    event('UID:next\nDTSTART:${stamp}Z\nSUMMARY:Next meeting'),
                  ),
                  200,
                ),
        ),
        directory: () => Future<Directory>.error(
          const FileSystemException('No cache storage'),
        ),
      );
      addTearDown(service.dispose);
      await settled(service);
      expect(service.events.single.title, 'Next meeting');
      expect(service.hasError, isFalse);
      offline = true;
      await service.refresh();
      expect(service.events.single.title, 'Next meeting');
      expect(service.hasError, isTrue);
      expect(service.usingCache, isTrue);
    },
  );

  test(
    'changing the URL ignores a late response from the previous calendar',
    () async {
      SharedPreferences.setMockInitialValues({
        'calendar_enabled': true,
        'calendar_url': 'https://calendar.example.test/old.ics',
      });
      final settings = SettingsService(await SharedPreferences.getInstance());
      final old = Completer<http.Response>();
      final service = CalendarService(
        settings,
        client: MockClient(
          (request) async => request.url.path == '/old.ics'
              ? old.future
              : http.Response(feed(''), 200),
        ),
        directory: () => Future<Directory>.error(
          const FileSystemException('No cache storage'),
        ),
      );
      addTearDown(service.dispose);
      await Future<void>.delayed(const Duration(milliseconds: 20));
      await settings.setCalendarUrl('https://calendar.example.test/new.ics');
      await settled(service);
      old.complete(http.Response('Invalid old response', 500));
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(service.hasError, isFalse);
      expect(service.events, isEmpty);
    },
  );
}
