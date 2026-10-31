import 'package:flauncher/l10n/app_localizations.dart';
import 'package:flauncher/providers/settings_service.dart';
import 'package:flauncher/widgets/daily_ayah_panel.dart';
import 'package:flauncher/widgets/settings/panels_settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Panels toggle hides the ayah panel and saves the choice', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final settings = SettingsService(preferences);
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: settings,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Consumer<SettingsService>(
            builder: (_, settings, _) => Scaffold(
              body: Column(
                children: [
                  const Expanded(child: PanelsSettingsPage()),
                  if (settings.showDailyAyah) const DailyAyahPanel(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    expect(find.byType(DailyAyahPanel), findsOneWidget);
    await tester.ensureVisible(find.text('Show ayah of the day'));
    await tester.tap(find.text('Show ayah of the day'));
    await tester.pumpAndSettle();
    expect(find.byType(DailyAyahPanel), findsNothing);
    expect(SettingsService(preferences).showDailyAyah, isFalse);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
