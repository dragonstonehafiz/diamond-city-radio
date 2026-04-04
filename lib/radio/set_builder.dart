import '../audio/radio_player_service.dart';
import '../models/song_model.dart';
import 'song_bank.dart';
import 'report_bank.dart';
import '../data/song_repository.dart';
import '../data/report_repository.dart';
import '../models/app_config.dart';

class SetBuilder {
  static List<RadioQueueItem> buildSet(
    SongBank songBank,
    ReportBank reportBank,
    SongRepository songs,
    ReportRepository reports,
    AppConfig config,
  ) {

    // Draw songs from bank
    final drawn = <SongModel>[];
    for (int i = 0; i < config.songsPerSet && songBank.bankLength > 0; i++) {
      drawn.add(songBank.draw());
    }

    if (drawn.isEmpty) {
      return [];
    }

    // Ensure first song has intros, last has outros
    _satisfyConstraints(drawn);

    // Build queue items
    final queue = <RadioQueueItem>[];

    // Intro
    if (drawn[0].intros.isNotEmpty) {
      queue.add(RadioQueueItem(
        itemId: drawn[0].id,
        clipType: RadioClipType.intro,
      ));
    }

    // Songs
    for (final song in drawn) {
      queue.add(RadioQueueItem(
        itemId: song.id,
        clipType: RadioClipType.song,
      ));
    }

    // Outro
    if (drawn[drawn.length - 1].outros.isNotEmpty) {
      queue.add(RadioQueueItem(
        itemId: drawn[drawn.length - 1].id,
        clipType: RadioClipType.outro,
      ));
    }

    // Report
    assert(reportBank.bankLength > 0, 'ReportBank.draw() called with empty bank');
    final report = reportBank.draw();
    queue.add(RadioQueueItem(
      itemId: report.id,
      clipType: RadioClipType.report,
    ));

    return queue;
  }

  static void _satisfyConstraints(List<SongModel> drawn) {
    if (drawn.isEmpty) return;

    // Find a song with intros for the first slot
    if (!drawn[0].hasIntros) {
      int? foundIdx;
      for (int i = 1; i < drawn.length; i++) {
        if (drawn[i].hasIntros) {
          foundIdx = i;
          break;
        }
      }
      if (foundIdx != null) {
        // Swap
        final tmp = drawn[0];
        drawn[0] = drawn[foundIdx];
        drawn[foundIdx] = tmp;
      }
      // If no valid candidate, keep drawn[0] as fallback (no intro will be played)
    }

    // Find a song with outros for the last slot
    final lastIdx = drawn.length - 1;
    if (!drawn[lastIdx].hasOutros) {
      int? foundIdx;
      for (int i = lastIdx - 1; i >= 0; i--) {
        if (drawn[i].hasOutros) {
          foundIdx = i;
          break;
        }
      }
      if (foundIdx != null && foundIdx != lastIdx) {
        // Swap
        final tmp = drawn[lastIdx];
        drawn[lastIdx] = drawn[foundIdx];
        drawn[foundIdx] = tmp;
      }
      // If no valid candidate, keep drawn[lastIdx] as fallback (no outro from song, will use general)
    }
  }
}
