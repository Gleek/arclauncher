import 'dart:io';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'unsplash_slideshow.dart';

class GistWallpaper {
  final File file;
  bool get isVideo => file.path.endsWith('.mp4');
  GistWallpaper(this.file);
}

class GistSlideshow {
  final Directory cacheDir;
  final http.Client _client;
  GistSlideshow(this.cacheDir, {http.Client? client}) : _client = client ?? http.Client();

  GistWallpaper? get cached {
    if (!cacheDir.existsSync()) return null;
    final files =
        cacheDir.listSync().whereType<File>().where((f) => f.path.endsWith('.jpg') || f.path.endsWith('.mp4')).toList()
          ..sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
    return files.isEmpty ? null : GistWallpaper(files.first);
  }

  Future<GistWallpaper?> next(List<Uri> urls, {Random? random}) async {
    if (urls.isEmpty) return null;
    File? pending;
    try {
      // Clean up files left behind if the app was killed during a download.
      await pruneCache(cacheDir, keep: slideshowMaxCachedFiles);
      final uri = urls[(random ?? Random()).nextInt(urls.length)];
      final response = await _client.send(http.Request('GET', uri)).timeout(const Duration(seconds: 30));
      if (response.statusCode != 200) {
        await response.stream.drain<void>();
        return null;
      }
      final type = response.headers['content-type']?.split(';').first ?? '';
      final extension = uri.path.toLowerCase().split('.').last;
      final video =
          type.startsWith('video/') ||
          (type == 'application/octet-stream' && ['mp4', 'webm', 'm4v', 'mov'].contains(extension));
      final image =
          type.startsWith('image/') ||
          (type == 'application/octet-stream' && ['jpg', 'jpeg', 'png', 'webp'].contains(extension));
      if (!video && !image) {
        await response.stream.drain<void>();
        return null;
      }
      await cacheDir.create(recursive: true);
      final path = '${cacheDir.path}/${DateTime.now().microsecondsSinceEpoch}';
      final tmp = File('$path.part');
      pending = tmp;
      // Stream videos to disk so their size does not determine RAM use.
      await response.stream.timeout(const Duration(seconds: 30)).pipe(tmp.openWrite());
      if (await tmp.length() == 0) return null;
      final file = await tmp.rename('$path.${video ? 'mp4' : 'jpg'}');
      await pruneCache(cacheDir, keep: slideshowMaxCachedFiles, newest: file);
      return GistWallpaper(file);
    } catch (_) {
      return null;
    } finally {
      try {
        if (pending != null && await pending.exists()) await pending.delete();
      } catch (_) {
        /* A later successful download also prunes abandoned temp files. */
      }
    }
  }

  void dispose() => _client.close();
}
