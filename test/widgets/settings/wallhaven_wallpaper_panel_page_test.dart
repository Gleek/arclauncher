import 'package:flauncher/l10n/app_localizations.dart';
import 'package:flauncher/providers/settings_service.dart';
import 'package:flauncher/providers/wallpaper_service.dart';
import 'package:flauncher/widgets/settings/wallhaven_wallpaper_panel_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../mocks.mocks.dart';

void main() {
  testWidgets('configure comma-separated terms, enable, change interval and request next', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final settings = SettingsService(await SharedPreferences.getInstance());
    final wallpaper = MockWallpaperService();
    when(wallpaper.advanceWallhavenWallpaper()).thenAnswer((_) async => true);
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<SettingsService>.value(value: settings),
          ChangeNotifierProvider<WallpaperService>.value(value: wallpaper),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: WallhavenWallpaperPanelPage()),
        ),
      ),
    );
    expect(find.byIcon(Icons.key), findsNothing);

    await tester.tap(find.text('Search terms'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), ' forest, ocean, , forest ');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(settings.wallhavenSearchTerms, 'forest, ocean');

    await tester.tap(find.text('Show Wallhaven wallpapers'));
    await tester.pumpAndSettle();
    expect(settings.wallhavenWallpaperEnabled, isTrue);
    await tester.tap(find.text('Change every'));
    await tester.pumpAndSettle();
    expect(settings.wallhavenIntervalMinutes, 30);
    final next = find.text('Next wallpaper');
    await tester.ensureVisible(next);
    await tester.tap(next);
    await tester.pumpAndSettle();
    verify(wallpaper.advanceWallhavenWallpaper()).called(1);
    expect(find.text('Wallpaper updated successfully'), findsOneWidget);
  });
}
