import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

/// QCF V2 encodes whole words as glyphs in a different font for each Mushaf page.
class QcfAyahText extends StatefulWidget {
  final Map<String, dynamic> verse;
  static final _fonts = <int, Future<void>>{};

  const QcfAyahText({super.key, required this.verse});

  static String _family(int page) => 'QcfV2p$page';

  static Future<ByteData> _fontData(int page) async {
    try {
      return await rootBundle.load('assets/fonts/qcf_v2/p$page.ttf');
    } catch (_) {
      final dir = await getApplicationSupportDirectory();
      final file = File('${dir.path}/qcf-fonts/p$page.ttf');
      if (await file.exists()) return ByteData.sublistView(await file.readAsBytes());
      final response = await http.get(Uri.https('verses.quran.foundation',
          '/fonts/quran/hafs/v2/ttf/p$page.ttf')).timeout(const Duration(seconds: 30));
      if (response.statusCode != 200 || response.bodyBytes.isEmpty) throw StateError('Font unavailable');
      await file.parent.create(recursive: true);
      final tmp = File('${file.path}.part');
      await tmp.writeAsBytes(response.bodyBytes, flush: true);
      await tmp.rename(file.path);
      return ByteData.sublistView(response.bodyBytes);
    }
  }

  static Future<void> _loadFont(int page) => _fonts.putIfAbsent(page, () async {
    try {
      final loader = FontLoader(_family(page))..addFont(_fontData(page));
      await loader.load();
    } catch (_) {
      _fonts.remove(page); // Allow a later retry; the panel uses Arabic text meanwhile.
      rethrow;
    }
  });

  static Future<List<void>> loadFonts(Map<String, dynamic> verse) =>
      Future.wait(
        (verse['qcfV2'] as List<dynamic>? ?? []).map(
          (run) => _loadFont(run['page'] as int),
        ),
      );

  @override
  State<QcfAyahText> createState() => _QcfAyahTextState();
}

class _QcfAyahTextState extends State<QcfAyahText> {
  late Future<List<void>> _fontsReady = QcfAyahText.loadFonts(widget.verse);

  @override
  void didUpdateWidget(QcfAyahText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.verse != widget.verse) {
      _fontsReady = QcfAyahText.loadFonts(widget.verse);
    }
  }

  @override
  Widget build(BuildContext context) {
    final verse = widget.verse;
    final runs = (verse['qcfV2'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
    return FutureBuilder<List<void>>(
      future: _fontsReady,
      builder: (context, snapshot) {
        if (runs.isNotEmpty && snapshot.connectionState != ConnectionState.done)
          return const SizedBox.shrink();
        return LayoutBuilder(
          builder: (context, constraints) => FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: constraints.maxWidth,
              child: Text.rich(
                TextSpan(
                  children: [
                    if (runs.isEmpty || snapshot.hasError) TextSpan(text: verse['arabic'] as String)
                    else for (final run in runs)
                      TextSpan(
                        text: '${run['text']} ',
                        style: TextStyle(
                          fontFamily: QcfAyahText._family(run['page'] as int),
                        ),
                      ),
                  ],
                ),
                semanticsLabel: verse['arabic'] as String,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.right,
                locale: const Locale('ar'),
                textHeightBehavior: const TextHeightBehavior(
                  applyHeightToFirstAscent: false,
                  applyHeightToLastDescent: false,
                ),
                style: const TextStyle(
                  fontSize: 22,
                  height: 1.9,
                  color: Color(0xFFFFF7E4),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
