import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../models/calendar_event.dart';
import 'settings_service.dart';

class CalendarService extends ChangeNotifier with WidgetsBindingObserver {
  final SettingsService _settings;
  final http.Client _client;
  final Future<Directory> Function() _directory;
  late final Timer _timer;
  String _url = '';
  bool _enabled = false;
  bool _disposed = false;
  int _request = 0;
  DateTime? _lastAttempt;
  List<CalendarEvent> events = [];
  bool loading = false;
  bool hasError = false;
  bool usingCache = false;
  DateTime? updatedAt;

  CalendarService(
    this._settings, {
    http.Client? client,
    Future<Directory> Function()? directory,
  }) : _client = client ?? http.Client(),
       _directory = directory ?? getApplicationSupportDirectory {
    _settings.addListener(_configurationChanged);
    WidgetsBinding.instance.addObserver(this);
    _timer = Timer.periodic(const Duration(minutes: 15), (_) {
      if (WidgetsBinding.instance.lifecycleState != AppLifecycleState.paused)
        refresh();
    });
    _configurationChanged();
  }

  void _configurationChanged() {
    final url = _settings.calendarUrl;
    final enabled = _settings.calendarEnabled;
    if (url == _url && enabled == _enabled) return;
    _url = url;
    _enabled = enabled;
    _request++;
    events = [];
    loading = false;
    hasError = false;
    usingCache = false;
    updatedAt = null;
    if (enabled && url.isNotEmpty) {
      refresh(loadCache: true);
    } else {
      notifyListeners();
    }
  }

  Future<File> _cacheFile() async =>
      File('${(await _directory()).path}/calendar-cache.json');

  Future<void> refresh({bool loadCache = false}) async {
    if (!_enabled || _url.isEmpty || loading || _disposed) return;
    final request = ++_request;
    final url = _url;
    bool current() => !_disposed && request == _request;
    loading = true;
    hasError = false;
    _lastAttempt = DateTime.now();
    notifyListeners();

    if (loadCache) {
      try {
        final saved =
            jsonDecode(await (await _cacheFile()).readAsString())
                as Map<String, dynamic>;
        if (saved['url'] == url) {
          final cached = await compute(parseCalendarEvents, (
            saved['feed'] as String,
            DateTime.now(),
          ));
          if (!current()) return;
          events = cached;
          usingCache = true;
          updatedAt = DateTime.tryParse(saved['updatedAt'] as String);
          notifyListeners();
        }
      } catch (_) {
        // A missing or invalid cache should not prevent a network refresh.
      }
    }

    try {
      final uri = calendarFeedUri(url);
      if (uri == null) throw const FormatException('Invalid calendar URL');
      final response = await _client
          .get(uri)
          .timeout(const Duration(seconds: 20));
      if (response.statusCode != 200)
        throw const FormatException('Calendar unavailable');
      final feed = utf8.decode(response.bodyBytes);
      final parsed = await compute(parseCalendarEvents, (feed, DateTime.now()));
      if (!current()) return;
      events = parsed;
      usingCache = false;
      updatedAt = DateTime.now();
      try {
        final file = await _cacheFile();
        if (!current()) return;
        await file.writeAsString(
          jsonEncode({
            'url': url,
            'feed': feed,
            'updatedAt': updatedAt!.toIso8601String(),
          }),
        );
      } catch (_) {
        // Display a valid feed even if the device cannot save its cache.
      }
    } catch (_) {
      if (current()) {
        hasError = true;
        usingCache = updatedAt != null;
      }
    } finally {
      if (current()) {
        loading = false;
        notifyListeners();
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        (_lastAttempt == null ||
            DateTime.now().difference(_lastAttempt!) >=
                const Duration(minutes: 15))) {
      refresh();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _request++;
    _timer.cancel();
    _settings.removeListener(_configurationChanged);
    WidgetsBinding.instance.removeObserver(this);
    _client.close();
    super.dispose();
  }
}
