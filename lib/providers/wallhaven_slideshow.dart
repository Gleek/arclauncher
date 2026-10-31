import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flauncher/providers/unsplash_slideshow.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class WallhavenSlideshow {
  final Directory cacheDir;
  final http.Client _client;

  WallhavenSlideshow(this.cacheDir, {http.Client? client}) : _client = client ?? http.Client();

  void dispose() => _client.close();

  /// Picks a term, then a wallpaper from a randomized search page, without a key.
  /// Failures leave the current cached wallpaper in place.
  Future<(File, String)?> next(String searchTerms, {Random? random}) async {
    final terms = searchTerms.split(',').map((term) => term.trim()).where((term) => term.isNotEmpty).toSet().toList();
    if (terms.isEmpty) return null;
    final rng = random ?? Random();
    try {
      final response = await _client
          .get(
            Uri.https('wallhaven.cc', '/api/v1/search', {
              'q': terms[rng.nextInt(terms.length)],
              'categories': '100',
              'purity': '100',
              'sorting': 'random',
              'atleast': '1920x1080',
              'ratios': '16x9',
            }),
          )
          .timeout(const Duration(seconds: 30));
      if (response.statusCode != 200) return null;
      final wallpapers = (jsonDecode(response.body) as Map<String, dynamic>)['data'] as List;
      if (wallpapers.isEmpty) return null;
      final wallpaper = wallpapers[rng.nextInt(wallpapers.length)] as Map<String, dynamic>;
      final id = wallpaper['id'] as String;
      final image = await _client.get(Uri.parse(wallpaper['path'] as String)).timeout(const Duration(seconds: 30));
      if (image.statusCode != 200 || image.bodyBytes.isEmpty) return null;

      await cacheDir.create(recursive: true);
      // A new filename also avoids stale Flutter image-cache entries on repeats.
      final path = '${cacheDir.path}/${id}_${DateTime.now().microsecondsSinceEpoch}';
      final extension = wallpaper['file_type'] == 'image/png' ? 'png' : 'jpg';
      final tmp = File('$path.part');
      await tmp.writeAsBytes(image.bodyBytes, flush: true);
      final file = await tmp.rename('$path.$extension');
      await pruneCache(cacheDir, keep: slideshowMaxCachedFiles, newest: file);
      return (file, id);
    } catch (e) {
      debugPrint('Wallhaven slideshow: $e');
      return null;
    }
  }
}
