import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../content_sources.dart';

/// Accept raw URLs or a public Gist page (optionally with ?file=filename).
Uri feedUri(String url) {
  final uri = Uri.parse(url.trim());
  if (uri.scheme != 'https' || uri.host.isEmpty) throw const FormatException('Use an HTTPS URL');
  if (uri.host == 'gist.github.com' && uri.pathSegments.length >= 2) {
    return Uri.https(
      'gist.githubusercontent.com',
      '/${uri.pathSegments.take(2).join('/')}/raw${uri.queryParameters['file'] == null ? '' : '/${uri.queryParameters['file']}'}',
    );
  }
  // Raw links copied from GitHub often pin a revision. Follow the latest instead.
  if (uri.host == 'gist.githubusercontent.com' &&
      uri.pathSegments.length >= 4 &&
      uri.pathSegments[2] == 'raw' &&
      RegExp(r'^[a-f0-9]{40}$').hasMatch(uri.pathSegments[3])) {
    final parts = uri.pathSegments.toList()..removeAt(3);
    return uri.replace(pathSegments: parts);
  }
  return uri;
}

/// An independently refreshed text/JSON feed with a validated offline fallback.
class RemoteFeed<T> extends ChangeNotifier {
  final String url;
  final String _cacheName;
  final T Function(String) _parse;
  final http.Client _client;
  final Future<Directory> Function() _directory;
  String? _text;
  bool _disposed = false;
  T? value;
  int revision = 0;
  bool loading = false;
  bool hasError = false;

  RemoteFeed(this.url, this._cacheName, this._parse, {http.Client? client, Future<Directory> Function()? directory})
    : _client = client ?? http.Client(),
      _directory = directory ?? getApplicationSupportDirectory {
    if (url.isNotEmpty) refresh(loadCache: true);
  }

  Future<File> _file() async => File('${(await _directory()).path}/$_cacheName');

  void _accept(String text) {
    if (text == _text) return;
    final parsed = _parse(text);
    _text = text;
    value = parsed;
    revision++;
    notifyListeners();
  }

  Future<bool> refresh({bool loadCache = false}) async {
    if (_disposed || loading || url.isEmpty) return false;
    bool current() => !_disposed;
    loading = true;
    hasError = false;
    notifyListeners();
    try {
      if (loadCache) {
        try {
          final saved = jsonDecode(await (await _file()).readAsString()) as Map<String, dynamic>;
          if (current() && saved['url'] == url) _accept(saved['text'] as String);
        } catch (_) {
          /* Missing or invalid cache: try the network. */
        }
      }
      if (!current()) return false;
      final uri = feedUri(url);
      final response = await _client
          .get(
            uri.replace(
              queryParameters: {...uri.queryParameters, '_refresh': DateTime.now().millisecondsSinceEpoch.toString()},
            ),
            headers: {'Cache-Control': 'no-cache'},
          )
          .timeout(const Duration(seconds: 30));
      if (!current()) return false;
      if (response.statusCode != 200) throw const FormatException('Feed unavailable');
      final text = utf8.decode(response.bodyBytes);
      _accept(text);
      try {
        final file = await _file();
        if (!current()) return false;
        await file.parent.create(recursive: true);
        final tmp = File('${file.path}.part');
        await tmp.writeAsString(jsonEncode({'url': url, 'text': text}), flush: true);
        if (current()) {
          await tmp.rename(file.path);
        } else {
          await tmp.delete();
        }
      } catch (_) {
        /* Valid content can still be used when the cache cannot be saved. */
      }
      return true;
    } catch (_) {
      if (current()) hasError = true;
      return false;
    } finally {
      if (current()) {
        loading = false;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _client.close();
    super.dispose();
  }
}

List<Uri> parseWallpaperFeed(String text) {
  final urls = <Uri>{};
  for (final line in const LineSplitter().convert(text)) {
    final value = line.trim();
    if (value.isEmpty || value.startsWith('#')) continue;
    final uri = Uri.parse(value);
    if (uri.scheme != 'https' || uri.host.isEmpty || value.contains(RegExp(r'\s'))) {
      throw const FormatException('Each line must be a direct HTTPS image or video URL');
    }
    urls.add(uri);
  }
  if (urls.isEmpty) throw const FormatException('No wallpapers in this feed');
  return urls.toList();
}

List<dynamic> parseAyahFeed(String text) {
  final data = jsonDecode(text) as Map<String, dynamic>;
  final passages = data['passages'] as List<dynamic>;
  if (passages.isEmpty) throw const FormatException('No ayahs in this feed');
  for (final passage in passages) {
    if (passage['reference'] is! String || passage['surahName'] is! String || (passage['verses'] as List).isEmpty)
      throw const FormatException('Invalid passage');
    for (final verse in passage['verses']) {
      if (verse['arabic'] is! String ||
          (verse['arabic'] as String).trim().isEmpty ||
          verse['translation'] is! String ||
          (verse['translation'] as String).trim().isEmpty) {
        throw const FormatException('Invalid verse');
      }
      final runs = verse['qcfV2'];
      if (runs != null) {
        if (runs is! List || runs.isEmpty) throw const FormatException('Invalid glyphs');
        for (final run in runs) {
          if (run['page'] is! int ||
              run['page'] < 1 ||
              run['page'] > 604 ||
              run['text'] is! String ||
              (run['text'] as String).isEmpty) {
            throw const FormatException('Invalid glyphs');
          }
        }
      }
    }
  }
  return passages;
}

class WallpaperFeed extends RemoteFeed<List<Uri>> {
  WallpaperFeed({String url = wallpaperGistUrl, http.Client? client, Future<Directory> Function()? directory})
    : super(url, 'wallpaper-feed.json', parseWallpaperFeed, client: client, directory: directory);
}

class AyahFeed extends RemoteFeed<List<dynamic>> {
  AyahFeed({String url = ayahGistUrl, http.Client? client, Future<Directory> Function()? directory})
    : super(url, 'ayah-feed.json', parseAyahFeed, client: client, directory: directory);
}
