import 'dart:async';
import 'package:dio/dio.dart';

class YouTubeAudioResolver {
  static final YouTubeAudioResolver instance = YouTubeAudioResolver._();
  YouTubeAudioResolver._();

  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 6),
    receiveTimeout: const Duration(seconds: 8),
    sendTimeout: const Duration(seconds: 5),
  ));

  // In-memory cache: videoId -> (url, expiry)
  final Map<String, ({String url, DateTime expiresAt})> _cache = {};

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

  /// Resolves direct, playable audio stream URL for a given YouTube video ID.
  Future<String?> resolve(String rawVideoId) async {
    final videoId = extractVideoId(rawVideoId) ?? rawVideoId.replaceAll('yt_', '').replaceAll('yt://', '');
    if (videoId.isEmpty) return null;

    // Check memory cache
    final cached = _cache[videoId];
    if (cached != null && DateTime.now().isBefore(cached.expiresAt)) {
      print('[AURA-YT-RESOLVER] Cache hit for $videoId');
      return cached.url;
    }

    // Strategy 1: YouTube Android Innertube Player API (unthrottled, unencrypted GoogleVideo CDN streams)
    try {
      final innertubeUrl = await _resolveFromInnertube(videoId);
      if (innertubeUrl != null && innertubeUrl.isNotEmpty) {
        _cache[videoId] = (url: innertubeUrl, expiresAt: DateTime.now().add(const Duration(hours: 4)));
        print('[AURA-YT-RESOLVER] Strategy 1 (Innertube Android) SUCCESS for $videoId');
        return innertubeUrl;
      }
    } catch (e) {
      print('[AURA-YT-RESOLVER] Strategy 1 Innertube error: $e');
    }

    // Strategy 2: Piped API mirrors
    for (final mirror in _pipedMirrors) {
      try {
        final url = '$mirror/streams/$videoId';
        final response = await _dio.get(
          url,
          options: Options(
            headers: {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)'},
          ),
        );
        if (response.statusCode == 200 && response.data != null) {
          final data = response.data;
          if (data is Map && data['audioStreams'] is List) {
            final streams = (data['audioStreams'] as List)
                .whereType<Map>()
                .where((s) => s['url'] != null)
                .toList();
            if (streams.isNotEmpty) {
              streams.sort((a, b) {
                final int bitA = (a['bitrate'] as num?)?.toInt() ?? 0;
                final int bitB = (b['bitrate'] as num?)?.toInt() ?? 0;
                return bitB.compareTo(bitA);
              });
              final streamUrl = streams.first['url']?.toString();
              if (streamUrl != null && streamUrl.isNotEmpty) {
                _cache[videoId] = (url: streamUrl, expiresAt: DateTime.now().add(const Duration(hours: 4)));
                print('[AURA-YT-RESOLVER] Strategy 2 (Piped: $mirror) SUCCESS for $videoId');
                return streamUrl;
              }
            }
          }
        }
      } catch (_) {}
    }

    // Strategy 3: Invidious API mirrors
    for (final mirror in _invidiousMirrors) {
      try {
        final url = '$mirror/api/v1/videos/$videoId';
        final response = await _dio.get(
          url,
          options: Options(
            headers: {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)'},
          ),
        );
        if (response.statusCode == 200 && response.data != null) {
          final data = response.data;
          if (data is Map && data['adaptiveFormats'] is List) {
            final audioFormats = (data['adaptiveFormats'] as List)
                .whereType<Map>()
                .where((f) => (f['type']?.toString().startsWith('audio/') ?? false) && f['url'] != null)
                .toList();
            if (audioFormats.isNotEmpty) {
              audioFormats.sort((a, b) {
                final int bitA = int.tryParse(a['bitrate']?.toString() ?? '0') ?? 0;
                final int bitB = int.tryParse(b['bitrate']?.toString() ?? '0') ?? 0;
                return bitB.compareTo(bitA);
              });
              final directUrl = audioFormats.first['url']?.toString();
              if (directUrl != null && directUrl.isNotEmpty) {
                _cache[videoId] = (url: directUrl, expiresAt: DateTime.now().add(const Duration(hours: 4)));
                print('[AURA-YT-RESOLVER] Strategy 3 (Invidious: $mirror) SUCCESS for $videoId');
                return directUrl;
              }
            }
          }
        }
      } catch (_) {}
    }

    // Strategy 4: Invidious latest_version redirect URL
    for (final mirror in _invidiousMirrors.take(2)) {
      final directStream = '$mirror/latest_version?id=$videoId&itag=140';
      _cache[videoId] = (url: directStream, expiresAt: DateTime.now().add(const Duration(hours: 2)));
      return directStream;
    }

    return null;
  }

  Future<String?> _resolveFromInnertube(String videoId) async {
    const endpoint = 'https://www.youtube.com/youtubei/v1/player?prettyPrint=false';
    final payload = {
      'context': {
        'client': {
          'clientName': 'ANDROID',
          'clientVersion': '19.09.37',
          'androidSdkVersion': 30,
          'hl': 'en',
          'gl': 'US',
        }
      },
      'videoId': videoId,
      'playbackContext': {
        'contentPlaybackContext': {
          'html5Preference': 'HTML5_PREF_WANTS'
        }
      }
    };

    final response = await _dio.post(
      endpoint,
      data: payload,
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': 'com.google.android.youtube/19.09.37 (Linux; U; Android 11) gzip',
          'X-YouTube-Client-Name': '3',
          'X-YouTube-Client-Version': '19.09.37',
        },
      ),
    );

    if (response.statusCode == 200 && response.data != null) {
      final data = response.data;
      if (data is Map && data['streamingData'] is Map) {
        final streamingData = data['streamingData'] as Map;
        final adaptiveFormats = streamingData['adaptiveFormats'];
        if (adaptiveFormats is List) {
          final audioList = adaptiveFormats
              .whereType<Map>()
              .where((f) =>
                  (f['mimeType']?.toString().startsWith('audio/') ?? false) &&
                  f['url'] != null &&
                  f['url'].toString().startsWith('http'))
              .toList();

          if (audioList.isNotEmpty) {
            audioList.sort((a, b) {
              final int bitA = (a['bitrate'] as num?)?.toInt() ?? 0;
              final int bitB = (b['bitrate'] as num?)?.toInt() ?? 0;
              return bitB.compareTo(bitA);
            });
            return audioList.first['url']?.toString();
          }
        }
      }
    }
    return null;
  }

  /// Search YouTube for a query and resolve its top audio URL
  Future<String?> resolveByQuery(String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) return null;
    print('[AURA-YT-RESOLVER] resolveByQuery for: "$cleanQuery"');

    // 1. Try Piped search
    for (final mirror in _pipedMirrors.take(2)) {
      try {
        final searchUrl = '$mirror/search?q=${Uri.encodeComponent(cleanQuery)}&filter=music_songs';
        final response = await _dio.get(searchUrl);
        if (response.statusCode == 200 && response.data != null) {
          final items = response.data['items'];
          if (items is List && items.isNotEmpty) {
            for (final item in items) {
              if (item is Map && item['url'] != null) {
                final urlStr = item['url'].toString();
                final videoId = urlStr.contains('v=') ? urlStr.split('v=').last : urlStr.replaceAll('/watch?v=', '');
                if (videoId.isNotEmpty) {
                  final streamUrl = await resolve(videoId);
                  if (streamUrl != null) return streamUrl;
                }
              }
            }
          }
        }
      } catch (_) {}
    }

    // 2. Try Invidious search
    for (final mirror in _invidiousMirrors.take(2)) {
      try {
        final searchUrl = '$mirror/api/v1/search?q=${Uri.encodeComponent(cleanQuery)}&type=video';
        final response = await _dio.get(searchUrl);
        if (response.statusCode == 200 && response.data is List) {
          final list = response.data as List;
          if (list.isNotEmpty) {
            for (final item in list) {
              if (item is Map && item['videoId'] != null) {
                final videoId = item['videoId'].toString();
                if (videoId.isNotEmpty) {
                  final streamUrl = await resolve(videoId);
                  if (streamUrl != null) return streamUrl;
                }
              }
            }
          }
        }
      } catch (_) {}
    }

    return null;
  }

  static String? extractVideoId(String input) {
    final clean = input.trim();
    if (clean.startsWith('yt_')) return clean.substring(3);
    if (clean.startsWith('yt://')) return clean.substring(5);
    final uri = Uri.tryParse(clean);
    if (uri != null) {
      if (uri.host.contains('youtube.com')) return uri.queryParameters['v'];
      if (uri.host.contains('youtu.be') && uri.pathSegments.isNotEmpty) return uri.pathSegments.first;
    }
    if (RegExp(r'^[a-zA-Z0-9_-]{11}$').hasMatch(clean)) return clean;
    return null;
  }
}
