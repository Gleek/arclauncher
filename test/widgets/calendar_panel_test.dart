import 'package:flauncher/l10n/app_localizations.dart';
import 'package:flauncher/models/calendar_event.dart';
import 'package:flauncher/providers/calendar_service.dart';
import 'package:flauncher/providers/settings_service.dart';
import 'package:flauncher/widgets/calendar_panel.dart';
import 'package:flauncher/widgets/settings/calendar_panel_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('compact week is display-only and leaves remote focus on apps', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});
    final settings = SettingsService(await SharedPreferences.getInstance());
    final calendar = CalendarService(settings);
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1, 9);
    final holiday = DateTime(tomorrow.year, tomorrow.month, tomorrow.day);
    calendar.events = [
      CalendarEvent(
        'School meeting with a very long title that must truncate gracefully',
        tomorrow,
        tomorrow.add(const Duration(hours: 1)),
        false,
      ),
      CalendarEvent(
        'Family holiday',
        holiday,
        DateTime(holiday.year, holiday.month, holiday.day + 1),
        true,
      ),
      CalendarEvent(
        'Dinner',
        tomorrow,
        tomorrow.add(const Duration(hours: 1)),
        false,
      ),
      for (var i = 4; i <= 8; i++)
        CalendarEvent(
          'Event $i',
          tomorrow.add(Duration(hours: i)),
          tomorrow.add(Duration(hours: i + 1)),
          false,
        ),
    ];
    var launches = 0;
    await tester.pumpWidget(
      _app(
        settings,
        calendar,
        Column(
          children: [
            const CalendarPanel(),
            TextButton(
              autofocus: true,
              onPressed: () => launches++,
              child: const Text('App shortcut'),
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Family holiday'), findsOneWidget);
    for (var i = 0; i < 7; i++) {
      expect(find.byKey(ValueKey('calendar-day-$i')), findsOneWidget);
    }
    expect(find.text('+4'), findsOneWidget);
    expect(find.text('Event 8'), findsNothing);
    expect(tester.takeException(), isNull);
    expect(
      tester.getSize(find.byType(CalendarPanel)).height,
      lessThanOrEqualTo(240),
    );
    expect(
      find.descendant(
        of: find.byType(CalendarPanel),
        matching: find.byType(Focus),
      ),
      findsNothing,
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(launches, 1);
    await tester.tap(
      find.byKey(const ValueKey('calendar-day-1')),
      warnIfMissed: false,
    );
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(launches, 1);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    calendar.dispose();
  });

  testWidgets('settings mask the URL and can disconnect the calendar', (
    tester,
  ) async {
    const url = 'https://calendar.example.test/private-secret/basic.ics';
    SharedPreferences.setMockInitialValues({'calendar_url': url});
    final settings = SettingsService(await SharedPreferences.getInstance());
    final calendar = CalendarService(settings);
    await tester.pumpWidget(
      _app(settings, calendar, const CalendarPanelPage()),
    );
    expect(find.text(url), findsNothing);
    expect(find.text('Calendar URL saved'), findsOneWidget);
    final disconnect = find.text('Disconnect calendar');
    await tester.ensureVisible(disconnect);
    await tester.tap(disconnect);
    await tester.pumpAndSettle();
    expect(settings.calendarUrl, isEmpty);
    expect(settings.calendarEnabled, isFalse);
    await tester.pumpWidget(const SizedBox.shrink());
    calendar.dispose();
  });
}

Widget _app(SettingsService settings, CalendarService calendar, Widget child) =>
    MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsService>.value(value: settings),
        ChangeNotifierProvider<CalendarService>.value(value: calendar),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: child),
      ),
    );
