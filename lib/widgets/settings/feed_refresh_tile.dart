import 'package:flauncher/l10n/app_localizations.dart';
import 'package:flauncher/providers/remote_feed.dart';
import 'package:flutter/material.dart';
import 'focusable_settings_tile.dart';

class FeedRefreshTile extends StatelessWidget {
  final RemoteFeed<Object?> feed;
  final String title;
  const FeedRefreshTile({super.key, required this.feed, required this.title});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return ListenableBuilder(
      listenable: feed,
      builder: (context, _) => FocusableSettingsTile(
        leading: const Icon(Icons.sync),
        title: Text(title),
        subtitle: feed.hasError ? Text(l.feedRefreshFailed) : null,
        trailing: feed.loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator()) : null,
        onPressed: feed.loading
            ? null
            : () async {
                final success = await feed.refresh();
                if (context.mounted)
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(success ? l.feedRefreshed : l.feedRefreshFailed)));
              },
      ),
    );
  }
}
