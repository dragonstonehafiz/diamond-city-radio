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
    final drawn = <SongModel>[];

    // Draw first song with intros guaranteed
    if (songBank.bankLength > 0) {
      final withIntro = songBank.drawWithIntro(1);
      drawn.addAll(withIntro);
    }

    // Draw middle songs (any songs)
    final middleCount = config.songsPerSet - 2;
    if (middleCount > 0 && songBank.bankLength > 0) {
      final middle = songBank.draw(middleCount);
      drawn.addAll(middle);
    }

    // Draw last song with outros guaranteed
    if (songBank.bankLength > 0) {
      final withOutro = songBank.drawWithOutro(1);
      drawn.addAll(withOutro);
    }

    if (drawn.isEmpty) {
      return [];
    }

    // Build queue items
    final queue = <RadioQueueItem>[];

    // Intro (guaranteed since first song was drawn with intro)
    queue.add(RadioQueueItem(
      itemId: drawn[0].id,
      clipType: RadioClipType.intro,
    ));

    // Songs
    for (final song in drawn) {
      queue.add(RadioQueueItem(
        itemId: song.id,
        clipType: RadioClipType.song,
      ));
    }

    // Outro (guaranteed since last song was drawn with outro)
    queue.add(RadioQueueItem(
      itemId: drawn[drawn.length - 1].id,
      clipType: RadioClipType.outro,
    ));

    // Report
    assert(reportBank.bankLength > 0, 'ReportBank.draw() called with empty bank');
    final report = reportBank.draw();
    queue.add(RadioQueueItem(
      itemId: report.id,
      clipType: RadioClipType.report,
    ));

    return queue;
  }
}
