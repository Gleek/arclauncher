import 'dart:io';
import 'package:flauncher/l10n/app_localizations.dart';
import 'package:flauncher/providers/remote_feed.dart';
import 'package:flauncher/providers/settings_service.dart';
import 'package:flauncher/providers/wallpaper_service.dart';
import 'package:flauncher/widgets/settings/gist_wallpaper_panel_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../mocks.mocks.dart';

void main() {
  testWidgets('Gist settings enable, refresh and pick randomly without URL configuration', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final settings = SettingsService(await SharedPreferences.getInstance());
    final dir = Directory.systemTemp.createTempSync('gist_ui');
    var requests = 0;
    late WallpaperFeed feed;
    await tester.runAsync(() async {
      feed = WallpaperFeed(
        url: 'https://example.com/wallpapers.txt',
        client: MockClient((_) async {
          requests++;
          return http.Response('https://cdn.example/wallpaper.mp4', 200);
        }),
        directory: () async => dir,
      );
      while (feed.loading) {
        await Future<void>.delayed(const Duration(milliseconds: 1));
      }
    });
    final wallpaper = MockWallpaperService();
    when(wallpaper.gistFeed).thenReturn(feed);
    when(wallpaper.advanceGistWallpaper()).thenAnswer((_) async => true);
    addTearDown(() async {
      feed.dispose();
      dir.deleteSync(recursive: true);
    });
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<SettingsService>.value(value: settings),
          ChangeNotifierProvider<WallpaperService>.value(value: wallpaper),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: GistWallpaperPanelPage()),
        ),
      ),
    );
    expect(find.text('Feed URL'), findsNothing);
    await tester.tap(find.text('Use wallpapers from Gist'));
    await tester.pumpAndSettle();
    expect(settings.gistWallpaperEnabled, isTrue);
    await tester.runAsync(() async {
      await tester.tap(find.text('Refresh content'));
      while (feed.loading) {
        await Future<void>.delayed(const Duration(milliseconds: 1));
      }
    });
    await tester.pumpAndSettle();
    expect(requests, 2);
    final next = find.text('Next wallpaper');
    await tester.ensureVisible(next);
    await tester.tap(next);
    await tester.pumpAndSettle();
    verify(wallpaper.advanceGistWallpaper()).called(1);
  });
}
