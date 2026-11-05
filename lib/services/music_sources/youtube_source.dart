import 'dart:convert';
import 'package:dio/dio.dart';
import '../../models/track.dart';
import '../storage/storage_service.dart';
import 'music_source.dart';
import 'youtube_audio_resolver.dart';

class YouTubeSource implements MusicSource {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 6),
    receiveTimeout: const Duration(seconds: 8),
    sendTimeout: const Duration(seconds: 5),
  ));

  static const List<String> _pipedMirrors = [
    'https://pipedapi.kavin.rocks',
    'https://api.piped.private.coffee',
    'https://pipedapi.tokhmi.xyz',
    'https://piped-api.lunar.icu',
    'https://api.piped.projectsegfau.lt',
  ];

  static const List<String> _invidiousMirrors = [
    'https://inv.tux.pizza',
    'https://invidious.nerdvpn.de',
    'https://vid.puffyan.us',
    'https://invidious.jing.rocks',
  ];

  @override
  Future<List<Track>> searchTracks(String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) return [];
    print('[AURA-YT-SOURCE] searchTracks for: "$cleanQuery"');

    // Strategy 1: YouTube Music Innertube search
    try {
      final innertubeTracks = await _searchInnertube(cleanQuery);
      if (innertubeTracks.isNotEmpty) {
        print('[AURA-YT-SOURCE] Strategy 1 (Innertube) found ${innertubeTracks.length} tracks');
        return innertubeTracks;
      }
    } catch (e) {
      print('[AURA-YT-SOURCE] Strategy 1 error: $e');
    }

    // Strategy 2: Piped API search
    for (final mirror in _pipedMirrors) {
      try {
        final url = '$mirror/search?q=${Uri.encodeComponent(cleanQuery)}&filter=music_songs';
        final response = await _dio.get(
          url,
          options: Options(
            headers: {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)'},
          ),
        );
        if (response.statusCode == 200 && response.data != null) {
          final items = response.data['items'];
          if (items is List && items.isNotEmpty) {
            final tracks = _parsePipedItems(items);
            if (tracks.isNotEmpty) {
              print('[AURA-YT-SOURCE] Strategy 2 (Piped: $mirror) found ${tracks.length} tracks');
              return tracks;
            }
          }
        }
      } catch (_) {}
    }

    // Strategy 3: Invidious API search
    for (final mirror in _invidiousMirrors) {
      try {
        final url = '$mirror/api/v1/search?q=${Uri.encodeComponent(cleanQuery)}&type=video';
        final response = await _dio.get(
          url,
          options: Options(
            headers: {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)'},
          ),
        );
        if (response.statusCode == 200 && response.data is List) {
          final items = response.data as List;
          if (items.isNotEmpty) {
            final tracks = _parseInvidiousItems(items);
            if (tracks.isNotEmpty) {
              print('[AURA-YT-SOURCE] Strategy 3 (Invidious: $mirror) found ${tracks.length} tracks');
              return tracks;
            }
          }
        }
      } catch (_) {}
    }

    return [];
  }

  Future<List<Track>> _searchInnertube(String query) async {
    const endpoint = 'https://music.youtube.com/youtubei/v1/search?prettyPrint=false';
    final payload = {
      'context': {
        'client': {
          'clientName': 'WEB_REMIX',
          'clientVersion': '1.20240101.01.00',
          'hl': 'en',
        }
      },
      'query': query,
    };

    final response = await _dio.post(
      endpoint,
      data: payload,
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        },
      ),
    );

    if (response.statusCode == 200 && response.data != null) {
      final List<Track> tracks = [];
      _extractTracksFromInnertubeResponse(response.data, tracks);
      return tracks;
    }
    return [];
  }

  void _extractTracksFromInnertubeResponse(dynamic node, List<Track> tracks) {
    if (tracks.length >= 25) return;
    if (node is Map) {
      if (node.containsKey('musicResponsiveListItemRenderer')) {
        final item = node['musicResponsiveListItemRenderer'];
        final track = _parseInnertubeMusicItem(item);
        if (track != null) tracks.add(track);
        return;
      }
      for (final value in node.values) {
        _extractTracksFromInnertubeResponse(value, tracks);
      }
    } else if (node is List) {
      for (final item in node) {
        _extractTracksFromInnertubeResponse(item, tracks);
      }
    }
  }

  Track? _parseInnertubeMusicItem(dynamic item) {
    if (item is! Map) return null;
    try {
      String videoId = item['playlistItemData']?['videoId']?.toString() ?? '';
      if (videoId.isEmpty) {
        final overlay = item['overlay']?['musicItemThumbnailOverlayRenderer']?['content']?['musicPlayButtonRenderer'];
        final playEndpoint = overlay?['playNavigationEndpoint']?['watchEndpoint']?['videoId'];
        if (playEndpoint != null) videoId = playEndpoint.toString();
      }
      if (videoId.isEmpty) return null;

      String title = 'Unknown Title';
      String artist = 'YouTube';
      String duration = '3:30';

      final flexColumns = item['flexColumns'];
      if (flexColumns is List && flexColumns.isNotEmpty) {
        final col0 = flexColumns[0]?['musicResponsiveListItemFlexColumnRenderer']?['text']?['runs'];
        if (col0 is List && col0.isNotEmpty) {
          title = col0.map((r) => r['text']?.toString() ?? '').join().trim();
        }
        if (flexColumns.length > 1) {
          final col1 = flexColumns[1]?['musicResponsiveListItemFlexColumnRenderer']?['text']?['runs'];
          if (col1 is List && col1.isNotEmpty) {
            final parts = col1.map((r) => r['text']?.toString() ?? '').toList();
            if (parts.isNotEmpty) artist = parts[0].trim();
            for (final p in parts) {
              if (RegExp(r'^\d+:\d+$').hasMatch(p.trim())) {
                duration = p.trim();
              }
            }
          }
        }
      }

      String artworkUrl = 'https://i.ytimg.com/vi/$videoId/hqdefault.jpg';
      final thumbs = item['thumbnail']?['musicThumbnailRenderer']?['thumbnail']?['thumbnails'];
      if (thumbs is List && thumbs.isNotEmpty) {
        final lastThumb = thumbs.last['url']?.toString();
        if (lastThumb != null && lastThumb.isNotEmpty) artworkUrl = lastThumb;
      }

      return Track(
        id: 'yt_$videoId',
        title: title,
        artist: artist,
        album: 'YouTube',
        duration: duration,
        artworkUrl: artworkUrl,
        audioUrl: 'yt://$videoId',
        genre: 'YouTube',
      );
    } catch (_) {
      return null;
    }
  }

  List<Track> _parsePipedItems(List items) {
    final List<Track> tracks = [];
    for (final item in items) {
      if (item is! Map) continue;
      final url = item['url']?.toString() ?? '';
      String videoId = '';
      if (url.contains('v=')) {
        videoId = url.split('v=').last;
      } else if (url.contains('/watch?v=')) {
        videoId = url.replaceAll('/watch?v=', '');
      } else if (url.startsWith('/watch/')) {
        videoId = url.replaceAll('/watch/', '');
      }
      if (videoId.isEmpty) continue;

      final title = item['title']?.toString() ?? 'Unknown Title';
      final artist = item['uploaderName']?.toString() ?? 'YouTube';
      final rawDuration = (item['duration'] as num?)?.toInt() ?? 0;
      final duration = rawDuration > 0
          ? '${rawDuration ~/ 60}:${(rawDuration % 60).toString().padLeft(2, '0')}'
          : '3:30';
      final artworkUrl = item['thumbnail']?.toString() ?? 'https://i.ytimg.com/vi/$videoId/hqdefault.jpg';

      tracks.add(Track(
        id: 'yt_$videoId',
        title: title,
        artist: artist,
        album: 'YouTube',
        duration: duration,
        artworkUrl: artworkUrl,
        audioUrl: 'yt://$videoId',
        genre: 'YouTube',
      ));
    }
    return tracks;
  }

  List<Track> _parseInvidiousItems(List items) {
    final List<Track> tracks = [];
    for (final item in items) {
      if (item is! Map) continue;
      final videoId = item['videoId']?.toString() ?? '';
      if (videoId.isEmpty) continue;

      final title = item['title']?.toString() ?? 'Unknown Title';
      final artist = item['author']?.toString() ?? 'YouTube';
      final rawDuration = (item['lengthSeconds'] as num?)?.toInt() ?? 0;
      final duration = rawDuration > 0
          ? '${rawDuration ~/ 60}:${(rawDuration % 60).toString().padLeft(2, '0')}'
          : '3:30';

      String artworkUrl = 'https://i.ytimg.com/vi/$videoId/hqdefault.jpg';
      final thumbs = item['videoThumbnails'];
      if (thumbs is List && thumbs.isNotEmpty) {
        final lastThumb = thumbs.first['url']?.toString();
        if (lastThumb != null && lastThumb.isNotEmpty) artworkUrl = lastThumb;
      }

      tracks.add(Track(
        id: 'yt_$videoId',
        title: title,
        artist: artist,
        album: 'YouTube',
        duration: duration,
        artworkUrl: artworkUrl,
        audioUrl: 'yt://$videoId',
        genre: 'YouTube',
      ));
    }
    return tracks;
  }

  @override
  Future<List<Track>> getTrendingTracks() async {
    final preferredLangs = StorageService.getPreferredLanguages();
    String query = 'trending hit songs';
    if (preferredLangs.isNotEmpty) {
      query = 'top ${preferredLangs.first.toLowerCase()} trending songs';
    }
    return searchTracks(query);
  }

  @override
  Future<List<Track>> getTracksByGenre(String genre) async {
    return searchTracks('top $genre songs hits');
  }

  @override
  Future<List<Track>> getDynamicRecommendations() async {
    final artists = StorageService.getPreferredArtists();
    if (artists.isNotEmpty) {
      return searchTracks('${artists.first} top songs');
    }
    return getTrendingTracks();
  }
}
