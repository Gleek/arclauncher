import 'dart:io';
import 'dart:math';
import 'package:flauncher/providers/gist_slideshow.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  late Directory dir;
  setUp(() async => dir = await Directory.systemTemp.createTemp('gist_slideshow'));
  tearDown(() async => dir.delete(recursive: true));

  test('randomly picks both images and videos, streams them to disk and limits the cache', () async {
    final picked = <String>{};
    final slideshow = GistSlideshow(
      dir,
      client: MockClient((request) async {
        picked.add(request.url.path);
        return http.Response.bytes(
          [1, 2, 3],
          200,
          headers: {'content-type': request.url.path.endsWith('.mp4') ? 'video/mp4' : 'image/jpeg'},
        );
      }),
    );
    addTearDown(slideshow.dispose);
    final urls = [Uri.parse('https://cdn.example/a.mp4'), Uri.parse('https://cdn.example/b.jpg')];
    final random = Random(42);
    for (var i = 0; i < 12; i++) {
      final media = (await slideshow.next(urls, random: random))!;
      expect(await media.file.readAsBytes(), [1, 2, 3]);
    }
    expect(picked, {'/a.mp4', '/b.jpg'});
    expect(dir.listSync().length, 2);
  });

  test('video type comes from Content-Type even without a filename extension and survives restart', () async {
    final slideshow = GistSlideshow(
      dir,
      client: MockClient((_) async => http.Response.bytes([1, 2, 3], 200, headers: {'content-type': 'video/mp4'})),
    );
    addTearDown(slideshow.dispose);
    final media = (await slideshow.next([Uri.parse('https://cdn.example/download?id=123')]))!;
    expect(media.isVideo, isTrue);
    expect(slideshow.cached!.file.path, media.file.path);
    expect(slideshow.cached!.isVideo, isTrue);
  });

  test('an abandoned partial download is purged even when the next request fails', () async {
    final current = await File('${dir.path}/current.jpg').writeAsBytes([9]);
    await File('${dir.path}/interrupted.part').writeAsBytes([1, 2, 3]);
    final slideshow = GistSlideshow(dir, client: MockClient((_) async => http.Response('', 503)));
    addTearDown(slideshow.dispose);
    expect(await slideshow.next([Uri.parse('https://cdn.example/a.mp4')]), isNull);
    expect(dir.listSync().map((f) => f.path).toList(), [current.path]);
  });

  test('HTML, failed or empty downloads keep the previous wallpaper', () async {
    final current = await File('${dir.path}/current.jpg').writeAsBytes([9]);
    for (final response in [
      http.Response('', 500),
      http.Response('<html></html>', 200, headers: {'content-type': 'text/html'}),
      http.Response('', 200, headers: {'content-type': 'video/mp4'}),
    ]) {
      final slideshow = GistSlideshow(dir, client: MockClient((_) async => response));
      expect(await slideshow.next([Uri.parse('https://cdn.example/a.mp4')]), isNull);
      expect(slideshow.cached!.file.path, current.path);
      expect(await current.readAsBytes(), [9]);
      expect(dir.listSync().map((f) => f.path).toList(), [current.path]);
      slideshow.dispose();
    }
  });
}
