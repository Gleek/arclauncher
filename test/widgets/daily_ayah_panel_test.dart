import 'dart:convert';

import 'package:flauncher/widgets/daily_ayah_panel.dart';
import 'package:flauncher/widgets/qcf_ayah_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('daily selection stays fixed all day and repeats after 100 days', () {
    final start = DateTime(2026, 10, 31);
    expect(
      dailyAyahIndex(start, 100),
      dailyAyahIndex(DateTime(2026, 10, 31, 23, 59), 100),
    );
    expect(
      dailyAyahIndex(DateTime(2026, 11, 1), 100),
      (dailyAyahIndex(start, 100) + 1) % 100,
    );
    expect(
      dailyAyahIndex(start.add(const Duration(days: 100)), 100),
      dailyAyahIndex(start, 100),
    );
  });

  testWidgets(
    'all 100 ayahs fit the Arabic column with their actual QCF V2 fonts',
    (tester) async {
      final data = jsonDecode(
        await tester.runAsync(
              () => rootBundle.loadString('assets/daily_ayahs.json'),
            ) ??
            '{}',
      );
      final passages = data['passages'] as List<dynamic>;
      expect(passages, hasLength(100));
      expect(passages.map((p) => p['reference']).toSet(), hasLength(100));
      expect(
        passages.every((p) {
          final surah = int.parse((p['reference'] as String).split(':').first);
          return surah > 1 && surah < 105;
        }),
        isTrue,
      );
      await tester.runAsync(() async {
        for (final passage in passages) {
          await QcfAyahText.loadFonts(
            passage['verses'][0] as Map<String, dynamic>,
          );
        }
      });
      for (final passage in passages) {
        expect(passage['verses'], hasLength(1));
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Align(
                alignment: Alignment.topLeft,
                child: SizedBox(
                  width: 403,
                  height: 106,
                  child: QcfAyahText(verse: passage['verses'][0]),
                ),
              ),
            ),
          ),
        );
        await tester.runAsync(() async => Future<void>.delayed(Duration.zero));
        await tester.pump();
        final text = find.descendant(
          of: find.byType(QcfAyahText),
          matching: find.byType(Text),
        );
        expect(text, findsOneWidget, reason: passage['reference']);
        expect(
          tester.getRect(text).width,
          lessThanOrEqualTo(403.1),
          reason: passage['reference'],
        );
        expect(
          tester.getRect(text).height,
          lessThanOrEqualTo(106.1),
          reason: passage['reference'],
        );
        expect(tester.widget<Text>(text).maxLines, isNull);
        expect(tester.takeException(), isNull, reason: passage['reference']);
      }
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
  testWidgets('daily ayah displays in full using the bundled QCF V2 font', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final data = jsonDecode(
      await tester.runAsync(
            () => rootBundle.loadString('assets/daily_ayahs.json'),
          ) ??
          '{}',
    );
    final passage = data['passages'][dailyAyahIndex(DateTime.now(), 100)];
    final scroll = ScrollController();
    addTearDown(scroll.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomScrollView(
            controller: scroll,
            slivers: const [
              SliverToBoxAdapter(
                child: SizedBox(key: Key('calendar-space'), height: 220),
              ),
              SliverToBoxAdapter(child: DailyAyahPanel()),
              SliverToBoxAdapter(child: SizedBox(height: 600)),
            ],
          ),
        ),
      ),
    );
    await tester.runAsync(
      () async => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pumpAndSettle();
    expect(find.text('AYAH OF THE DAY'), findsOneWidget);
    expect(find.text(passage['verses'][0]['translation']), findsOneWidget);
    expect(tester.takeException(), isNull);
    expect(find.text('Read full passage'), findsNothing);
    expect(find.textContaining('The Clear Quran'), findsNothing);
    expect(find.byType(BackdropFilter), findsOneWidget);
    expect(tester.getSize(find.byType(DailyAyahPanel)).height, 160);
    expect(find.byType(QcfAyahText), findsOneWidget);
    await tester.runAsync(
      () async => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pumpAndSettle();
    final arabic = tester.widget<Text>(
      find.descendant(
        of: find.byType(QcfAyahText),
        matching: find.byType(Text),
      ),
    );
    expect(arabic.maxLines, isNull);
    expect(arabic.semanticsLabel, passage['verses'][0]['arabic']);
    scroll.jumpTo(180);
    await tester.pump();
    Focus.of(tester.element(find.text('AYAH OF THE DAY'))).requestFocus();
    await tester.pump();
    expect(
      find.descendant(
        of: find.byType(QcfAyahText),
        matching: find.byType(Text),
      ),
      findsOneWidget,
      reason: 'Arabic must remain visible on the first focus frame',
    );
    await tester.pumpAndSettle();
    expect(scroll.offset, 0);
    expect(
      tester.getTopLeft(find.byKey(const Key('calendar-space'))).dy,
      greaterThanOrEqualTo(0),
    );
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
