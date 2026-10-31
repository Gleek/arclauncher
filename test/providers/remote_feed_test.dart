import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flauncher/providers/remote_feed.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

Future<void> feedSettled(RemoteFeed<Object?> feed) {
  if (!feed.loading) return Future.value();
  final done = Completer<void>();
  void changed() {
    if (!feed.loading) {
      feed.removeListener(changed);
      done.complete();
    }
  }

  feed.addListener(changed);
  return done.future;
}

Map<String, dynamic> ayahData(String translation) => {
  'passages': [
    {
      'reference': '2:21',
      'surahName': 'Al-Baqarah',
      'verses': [
        <String, dynamic>{'arabic': 'نص عربي', 'translation': translation},
      ],
    },
  ],
};

void main() {
  late Directory dir;
  setUp(() async => dir = await Directory.systemTemp.createTemp('remote_feed'));
  tearDown(() async => dir.delete(recursive: true));

  test('public and revision-pinned Gist URLs resolve to the latest raw content', () {
    expect(
      feedUri('https://gist.github.com/umar/abc?file=wallpapers.txt').toString(),
      'https://gist.githubusercontent.com/umar/abc/raw/wallpapers.txt',
    );
    expect(
      feedUri('https://gist.githubusercontent.com/umar/abc/raw/${'a' * 40}/ayahs.json').path,
      '/umar/abc/raw/ayahs.json',
    );
    expect(() => feedUri('http://example.com/feed'), throwsFormatException);
  });

  test('wallpaper format is one URL per line, with comments, blank lines and duplicates ignored', () {
    expect(
      parseWallpaperFeed('# Nature\n\nhttps://cdn.example/a.mp4\nhttps://cdn.example/b.jpg\nhttps://cdn.example/a.mp4'),
      [Uri.parse('https://cdn.example/a.mp4'), Uri.parse('https://cdn.example/b.jpg')],
    );
    expect(() => parseWallpaperFeed('# empty'), throwsFormatException);
    expect(() => parseWallpaperFeed('video https://example.com/a.mp4'), throwsFormatException);
  });

  test('refresh updates the list; invalid updates and offline restarts keep the last good feed', () async {
    var body = 'https://cdn.example/a.mp4';
    final client = MockClient((request) async {
      expect(request.headers['Cache-Control'], 'no-cache');
      expect(request.url.queryParameters.containsKey('_refresh'), isTrue);
      return http.Response(body, 200);
    });
    final feed = WallpaperFeed(url: 'https://example.com/wallpapers.txt', client: client, directory: () async => dir);
    await feedSettled(feed);
    expect(feed.value!.single.path, '/a.mp4');
    body = 'https://cdn.example/b.jpg';
    expect(await feed.refresh(), isTrue);
    body = '<html>Unavailable</html>';
    expect(await feed.refresh(), isFalse);
    expect(feed.value!.single.path, '/b.jpg');
    feed.dispose();
    final offline = WallpaperFeed(
      url: 'https://example.com/wallpapers.txt',
      client: MockClient((_) async => http.Response('', 503)),
      directory: () async => dir,
    );
    addTearDown(offline.dispose);
    await feedSettled(offline);
    expect(offline.value!.single.path, '/b.jpg');
    expect(offline.hasError, isTrue);
  });

  test('ayah updates are independent and invalid JSON keeps the last good passage', () async {
    var body = jsonEncode(ayahData('First'));
    final ayahs = AyahFeed(
      url: 'https://example.com/ayahs.json',
      client: MockClient(
        (_) async => http.Response(body, 200, headers: {'content-type': 'application/json; charset=utf-8'}),
      ),
      directory: () async => dir,
    );
    addTearDown(ayahs.dispose);
    await feedSettled(ayahs);
    expect(ayahs.value!.single['verses'][0]['translation'], 'First');
    body = jsonEncode(ayahData('Updated'));
    expect(await ayahs.refresh(), isTrue);
    body = '{"passages": []}';
    expect(await ayahs.refresh(), isFalse);
    expect(ayahs.value!.single['verses'][0]['translation'], 'Updated');
  });

  test('ayah validation rejects missing translations and invalid QCF pages', () {
    final invalid = ayahData('Text');
    invalid['passages'][0]['verses'][0]['qcfV2'] = [
      {'page': 605, 'text': 'glyph'},
    ];
    expect(() => parseAyahFeed(jsonEncode(invalid)), throwsFormatException);
    invalid['passages'][0]['verses'][0].remove('qcfV2');
    invalid['passages'][0]['verses'][0].remove('translation');
    expect(() => parseAyahFeed(jsonEncode(invalid)), throwsFormatException);
  });
}
