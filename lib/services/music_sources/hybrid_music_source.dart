import '../../models/track.dart';
import '../storage/storage_service.dart';
import 'jamendo_source.dart';
import 'music_source.dart';
import 'youtube_source.dart';

/// Unified music source that bridges JioSaavn and YouTube.
/// Provides access to JioSaavn's catalog along with YouTube's vast library
/// so users can find every song without restriction.
class HybridMusicSource implements MusicSource {
  final JamendoSource _jioSaavnSource = JamendoSource();
  final YouTubeSource _youTubeSource = YouTubeSource();

  @override
  Future<List<Track>> searchTracks(String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) return [];

    final mode = StorageService.getMusicSourceMode();
    print('[AURA-HYBRID] searchTracks mode="$mode" for: "$cleanQuery"');

    // 1. YouTube only mode
    if (mode == 'youtube') {
      return _youTubeSource.searchTracks(cleanQuery);
    }

    // 2. JioSaavn only mode
    if (mode == 'jiosaavn') {
      return _jioSaavnSource.searchTracks(cleanQuery);
    }

    // 3. Hybrid mode (Default): Search both JioSaavn and YouTube
    try {
      final jioFuture = _jioSaavnSource.searchTracks(cleanQuery);
      final ytFuture = _youTubeSource.searchTracks(cleanQuery);

      final jioResults = await jioFuture;
      final ytResults = await ytFuture;

      if (jioResults.isEmpty) {
        return ytResults;
      }
      if (ytResults.isEmpty) {
        return jioResults;
      }

      // Merge results avoiding duplicate song titles
      final List<Track> combined = List.from(jioResults);
      final Set<String> existingKeys = jioResults.map((t) => _normalizeSongKey(t.title, t.artist)).toSet();

      for (final ytTrack in ytResults) {
        final key = _normalizeSongKey(ytTrack.title, ytTrack.artist);
        if (!existingKeys.contains(key)) {
          combined.add(ytTrack);
          existingKeys.add(key);
        }
      }

      return combined;
    } catch (e) {
      print('[AURA-HYBRID] Error in hybrid search: $e');
      final yt = await _youTubeSource.searchTracks(cleanQuery);
      if (yt.isNotEmpty) return yt;
      return _jioSaavnSource.searchTracks(cleanQuery);
    }
  }

  String _normalizeSongKey(String title, String artist) {
    final cleanT = title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    final cleanA = artist.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    return '${cleanT}_$cleanA';
  }

  @override
  Future<List<Track>> getTrendingTracks() async {
    final mode = StorageService.getMusicSourceMode();
    if (mode == 'youtube') {
      return _youTubeSource.getTrendingTracks();
    }
    return _jioSaavnSource.getTrendingTracks();
  }

  @override
  Future<List<Track>> getTracksByGenre(String genre) async {
    final mode = StorageService.getMusicSourceMode();
    if (mode == 'youtube') {
      return _youTubeSource.getTracksByGenre(genre);
    }
    return _jioSaavnSource.getTracksByGenre(genre);
  }

  @override
  Future<List<Track>> getDynamicRecommendations() async {
    final mode = StorageService.getMusicSourceMode();
    if (mode == 'youtube') {
      return _youTubeSource.getDynamicRecommendations();
    }
    return _jioSaavnSource.getDynamicRecommendations();
  }
}
