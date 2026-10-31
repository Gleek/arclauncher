import 'dart:convert';
import 'dart:io';
import 'package:flauncher/providers/remote_feed.dart';
import 'package:flauncher/widgets/daily_ayah_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('refreshing the ayah JSON updates the visible passage without restarting the app', (tester) async {
    final dir = Directory.systemTemp.createTempSync('ayah_ui');
    var translation = 'First remote translation';
    late AyahFeed feed;
    await tester.runAsync(() async {
      feed = AyahFeed(
        url: 'https://example.com/ayahs.json',
        client: MockClient(
          (_) async => http.Response(
            jsonEncode({
              'passages': [
                {
                  'reference': '2:21',
                  'surahName': 'Al-Baqarah',
                  'verses': [
                    {'arabic': 'نص عربي', 'translation': translation},
                  ],
                },
              ],
            }),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          ),
        ),
        directory: () async => dir,
      );
      while (feed.loading) {
        await Future<void>.delayed(const Duration(milliseconds: 1));
      }
    });
    addTearDown(() async {
      feed.dispose();
      dir.deleteSync(recursive: true);
    });
    await tester.pumpWidget(
      ChangeNotifierProvider<AyahFeed>.value(
        value: feed,
        child: const MaterialApp(home: Scaffold(body: DailyAyahPanel())),
      ),
    );
    await tester.runAsync(() async {
      while (feed.loading) {
        await Future<void>.delayed(const Duration(milliseconds: 1));
      }
    });
    await tester.pumpAndSettle();
    expect(find.text('First remote translation'), findsOneWidget);
    translation = 'Updated remote translation';
    await tester.runAsync(() => feed.refresh());
    await tester.pumpAndSettle();
    expect(find.text('Updated remote translation'), findsOneWidget);
    expect(find.text('First remote translation'), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
