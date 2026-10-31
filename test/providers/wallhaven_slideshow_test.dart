import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flauncher/providers/wallhaven_slideshow.dart';
import 'package:flauncher/providers/unsplash_slideshow.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  late Directory dir;
  setUp(() async => dir = await Directory.systemTemp.createTemp('wallhaven_test'));
  tearDown(() async => dir.delete(recursive: true));

  test('randomly selects a term and a wallpaper without credentials, filters for TV and caps cache', () async {
    final terms = <String>{};
    final ids = <String>{};
    final client = MockClient((req) async {
      expect(req.headers.containsKey('Authorization'), isFalse);
      expect(req.headers.containsKey('X-API-Key'), isFalse);
      expect(req.url.queryParameters.containsKey('apikey'), isFalse);
      if (req.url.host == 'wallhaven.cc') {
        expect(req.url.path, '/api/v1/search');
        expect(req.url.queryParameters['sorting'], 'random');
        expect(req.url.queryParameters['categories'], '100');
        expect(req.url.queryParameters['purity'], '100');
        expect(req.url.queryParameters['atleast'], '1920x1080');
        expect(req.url.queryParameters['ratios'], '16x9');
        terms.add(req.url.queryParameters['q']!);
        return http.Response(
          jsonEncode({
            'data': [
              for (var i = 0; i < 3; i++)
                {'id': 'wall$i', 'path': 'https://w.wallhaven.cc/full/wall$i.jpg', 'file_type': 'image/jpeg'},
            ],
          }),
          200,
        );
      }
      expect(req.url.host, 'w.wallhaven.cc');
      return http.Response.bytes([1, 2, 3], 200);
    });
    final slideshow = WallhavenSlideshow(dir, client: client);
    addTearDown(slideshow.dispose);
    final random = Random(42);
    for (var i = 0; i < 20; i++) {
      final (file, id) = (await slideshow.next(' mountains, , ocean, ', random: random))!;
      expect(await file.readAsBytes(), [1, 2, 3]);
      expect(file.path, endsWith('.jpg'));
      ids.add(id);
    }
    expect(terms, {'mountains', 'ocean'});
    expect(ids, {'wall0', 'wall1', 'wall2'});
    expect(dir.listSync().length, 2);
  });

  test('PNG wallpapers remain available from cache on restart', () async {
    final slideshow = WallhavenSlideshow(
      dir,
      client: MockClient(
        (req) async => req.url.host == 'wallhaven.cc'
            ? http.Response(
                '{"data":[{"id":"abc123","path":"https://w.wallhaven.cc/a.png","file_type":"image/png"}]}',
                200,
              )
            : http.Response.bytes([1, 2, 3], 200),
      ),
    );
    addTearDown(slideshow.dispose);
    final (file, id) = (await slideshow.next('nature'))!;
    expect(id, 'abc123');
    expect(file.path, endsWith('.png'));
    expect(newestCachedImage(dir)!.path, file.path);
  });

  test('empty terms makes no requests', () async {
    final slideshow = WallhavenSlideshow(dir, client: MockClient((_) async => fail('Unexpected request')));
    addTearDown(slideshow.dispose);
    expect(await slideshow.next(' , , '), isNull);
  });

  test('empty results, API errors, malformed responses and download failures keep cache', () async {
    final current = await File('${dir.path}/current.jpg').writeAsBytes([9]);
    for (final response in [
      http.Response('rate limited', 429),
      http.Response('{"data":[]}', 200),
      http.Response('invalid', 200),
      http.Response('{"data":[{"id":"abc123","path":"https://w.wallhaven.cc/a.jpg"}]}', 200),
    ]) {
      final slideshow = WallhavenSlideshow(
        dir,
        client: MockClient((req) async => req.url.host == 'wallhaven.cc' ? response : http.Response('', 500)),
      );
      expect(await slideshow.next('nature'), isNull);
      slideshow.dispose();
      expect(await current.readAsBytes(), [9]);
      expect(dir.listSync().length, 1);
    }
  });
}
