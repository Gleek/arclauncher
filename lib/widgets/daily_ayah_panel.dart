import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;

import '../actions.dart';
import 'qcf_ayah_text.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/remote_feed.dart';
import 'package:flutter/services.dart';

const _gold = Color(0xFFE1C58A);

/// Uses calendar dates rather than elapsed local hours, so DST cannot skip a day.
int dailyAyahIndex(DateTime date, int count) =>
    DateTime.utc(
      date.year,
      date.month,
      date.day,
    ).difference(DateTime.utc(2026)).inDays %
    count;

class DailyAyahPanel extends StatefulWidget {
  static const double height = 160;
  final VoidCallback? onFocused;

  const DailyAyahPanel({super.key, this.onFocused});

  @override
  State<DailyAyahPanel> createState() => _DailyAyahPanelState();
}

class _DailyAyahPanelState extends State<DailyAyahPanel>
    with WidgetsBindingObserver {
  late final Future<List<dynamic>> _passages = rootBundle
      .loadString('assets/daily_ayahs.json')
      .then(
        (text) =>
            (jsonDecode(text) as Map<String, dynamic>)['passages']
                as List<dynamic>,
      );
  Timer? _midnight;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scheduleMidnight();
  }

  void _scheduleMidnight() {
    _midnight?.cancel();
    final now = DateTime.now();
    _midnight = Timer(
      DateTime(now.year, now.month, now.day + 1).difference(now),
      () {
        setState(() {});
        _scheduleMidnight();
      },
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setState(() {});
      _scheduleMidnight();
    }
  }

  @override
  void dispose() {
    _midnight?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final remotePassages = context.watch<AyahFeed?>()?.value;
    return Focus(
    canRequestFocus: false,
    onKeyEvent: (_, event) {
      if (event is! KeyUpEvent &&
          event.logicalKey == LogicalKeyboardKey.arrowUp) {
        Actions.maybeInvoke(context, const MoveFocusToSettingsIntent());
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    },
    child: SizedBox(
      height: DailyAyahPanel.height,
      child: FutureBuilder<List<dynamic>>(
        future: _passages,
        builder: (context, snapshot) {
          final passages = remotePassages ?? snapshot.data;
          if (passages == null || passages.isEmpty) return const SizedBox.shrink();
          final passage =
              passages[dailyAyahIndex(DateTime.now(), passages.length)]
                  as Map<String, dynamic>;
          final verses = passage['verses'] as List<dynamic>;
          final first = verses.first as Map<String, dynamic>;
          return Padding(
            padding: const EdgeInsets.fromLTRB(40, 6, 40, 6),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.26),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _focused
                          ? _gold
                          : Colors.white.withValues(alpha: 0.16),
                    ),
                  ),
                  child: Focus(
                    onFocusChange: (focused) {
                      setState(() => _focused = focused);
                      if (focused) {
                        widget.onFocused?.call();
                        // Calendar and ayah share the top of the home screen.
                        final position = Scrollable.maybeOf(context)?.position;
                        position?.animateTo(
                          position.minScrollExtent,
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOut,
                        );
                      }
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.auto_stories_outlined,
                              color: _gold,
                              size: 14,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'AYAH OF THE DAY',
                              style: TextStyle(
                                color: _gold,
                                fontSize: 10,
                                letterSpacing: 1.6,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${passage['surahName']} · ${passage['reference']}',
                              style: const TextStyle(
                                color: _gold,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  first['translation'] as String,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    height: 1.45,
                                    color: Color(0xFFF1EEE4),
                                  ),
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 56,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                color: Colors.white24,
                              ),
                              Expanded(child: QcfAyahText(verse: first)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    ),
  );
  }
}
