import 'package:ari/domain/usecases/playback_permission_usecase.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ari/providers/playback/playback_state_provider.dart';
import 'package:ari/domain/entities/track.dart';
import 'package:ari/presentation/widgets/common/custom_toast.dart';
import 'package:dio/dio.dart';
import 'package:ari/data/models/api_response.dart';
import 'package:ari/providers/global_providers.dart';

class AudioService {
  final AudioPlayer audioPlayer = AudioPlayer();
  final ConcatenatingAudioSource _playlistSource = ConcatenatingAudioSource(
    children: [],
  );

  Stream<Duration> get onPositionChanged => audioPlayer.positionStream;
  Stream<Duration?> get onDurationChanged => audioPlayer.durationStream;

  AudioService() {
    _initializePlayer();
  }

  void _initializePlayer() {
    audioPlayer.playerStateStream.listen((state) async {
      if (state.processingState == ProcessingState.completed) {
        await audioPlayer.seekToNext();
        await audioPlayer.play();
      }
    });
  }

  Future<void> playFullTrackList({
    required WidgetRef ref,
    required BuildContext context,
    required List<Track> tracks,
  }) async {
    if (tracks.isEmpty) {
      context.showToast('재생할 트랙이 없습니다.');
      return;
    }

    final permissionUsecase = ref.read(playbackPermissionUsecaseProvider);
    final dio = ref.read(dioProvider);
    final allowedTracks = <Track>[];

    for (final track in tracks) {
      final result = await permissionUsecase.check(
        track.albumId,
        track.trackId,
      );
      if (!result.isError) {
        allowedTracks.add(track);
      }
    }

    if (allowedTracks.isEmpty) {
      context.showToast('⛔ 재생 가능한 트랙이 없습니다.');
      return;
    }

    final firstTrack = allowedTracks.first;

    try {
      final track = await _fetchPlayableTrack(
        ref,
        dio,
        firstTrack.albumId,
        firstTrack.trackId,
        context,
      );
      await _playAndSetState(ref, track);
    } catch (e) {
      context.showToast(e.toString());
      return;
    }

    _playlistSource.clear();
    for (final track in allowedTracks) {
      _playlistSource.add(AudioSource.uri(Uri.parse(track.trackFileUrl ?? '')));
    }
    await audioPlayer.setAudioSource(_playlistSource, initialIndex: 0);
  }

  Future<void> playSingleTrackWithPermission(
    WidgetRef ref,
    Track track,
    BuildContext context,
  ) async {
    final dio = ref.read(dioProvider);
    final permissionUsecase = ref.read(playbackPermissionUsecaseProvider);
    final permissionResult = await permissionUsecase.check(
      track.albumId,
      track.trackId,
    );

    if (permissionResult.isError) {
      context.showToast(permissionResult.message ?? '재생 권한 오류');
      return;
    }

    final playableTrack = await _fetchPlayableTrack(
      ref,
      dio,
      track.albumId,
      track.trackId,
      context,
    );
    await _playAndSetState(ref, playableTrack);
  }

  Future<void> playFromQueueSubset(
    BuildContext context,
    WidgetRef ref,
    List<Track> fullQueue,
    Track selectedTrack,
  ) async {
    final permissionUsecase = ref.read(playbackPermissionUsecaseProvider);
    final dio = ref.read(dioProvider);
    final allowedTracks = <Track>[];

    for (final track in fullQueue) {
      final result = await permissionUsecase.check(
        track.albumId,
        track.trackId,
      );
      if (!result.isError) {
        allowedTracks.add(track);
      }
    }

    if (allowedTracks.isEmpty) {
      context.showToast('⛔ 재생 가능한 트랙이 없습니다.');
      return;
    }

    final initialIndex = allowedTracks.indexWhere(
      (t) => t.trackId == selectedTrack.trackId,
    );

    if (initialIndex == -1) {
      context.showToast('선택한 트랙은 재생할 수 없습니다.');
      return;
    }

    try {
      final playableTrack = await _fetchPlayableTrack(
        ref,
        dio,
        selectedTrack.albumId,
        selectedTrack.trackId,
        context,
      );
      await _playAndSetState(ref, playableTrack);
    } catch (e) {
      context.showToast(e.toString());
      return;
    }

    _playlistSource.clear();
    for (final track in allowedTracks) {
      _playlistSource.add(AudioSource.uri(Uri.parse(track.trackFileUrl ?? '')));
    }

    await audioPlayer.setAudioSource(
      _playlistSource,
      initialIndex: initialIndex,
    );
  }

  Future<void> playPlaylistFromTrack(
    WidgetRef ref,
    List<Track> playlist,
    Track startTrack,
    BuildContext context,
  ) async {
    final permissionUsecase = ref.read(playbackPermissionUsecaseProvider);
    final dio = ref.read(dioProvider);
    final allowedTracks = <Track>[];

    for (final track in playlist) {
      final result = await permissionUsecase.check(
        track.albumId,
        track.trackId,
      );
      if (!result.isError) {
        allowedTracks.add(track);
      }
    }

    if (allowedTracks.isEmpty) {
      context.showToast('⛔ 재생 가능한 트랙이 없습니다.');
      return;
    }

    final initialIndex = allowedTracks.indexWhere(
      (t) => t.trackId == startTrack.trackId,
    );
    if (initialIndex == -1) {
      context.showToast('선택한 트랙은 재생할 수 없습니다.');
      return;
    }

    try {
      final track = await _fetchPlayableTrack(
        ref,
        dio,
        startTrack.albumId,
        startTrack.trackId,
        context,
      );
      await _playAndSetState(ref, track);
    } catch (e) {
      context.showToast(e.toString());
    }

    _playlistSource.clear();
    for (final track in allowedTracks) {
      _playlistSource.add(AudioSource.uri(Uri.parse(track.trackFileUrl ?? '')));
    }
    await audioPlayer.setAudioSource(
      _playlistSource,
      initialIndex: initialIndex,
    );
  }

  Future<void> _playAndSetState(WidgetRef ref, Track track) async {
    await _playSingleTrack(ref, track);
    final uniqueId = "track_${track.trackId}";

    ref
        .read(playbackProvider.notifier)
        .updateTrackInfo(
          trackTitle: track.trackTitle,
          artist: track.artistName,
          coverImageUrl: track.coverUrl ?? '',
          lyrics: track.lyric ?? '',
          currentTrackId: track.trackId,
          albumId: track.albumId,
          trackUrl: track.trackFileUrl ?? '',
          isLiked: false,
          currentQueueItemId: uniqueId,
        );
    ref.read(playbackProvider.notifier).updatePlaybackState(true);
  }

  Future<Track> _fetchPlayableTrack(
    WidgetRef ref,
    Dio dio,
    int albumId,
    int trackId,
    BuildContext context,
  ) async {
    try {
      final response = await dio.post(
        '/api/v1/albums/$albumId/tracks/$trackId',
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (data) => data as Map<String, dynamic>,
      );

      if (apiResponse.data == null) {
        final code = response.data['error']?['code'];
        final message = switch (code) {
          'S001' => '🔒 구독권이 없습니다. 구독 후 이용해 주세요.',
          'S002' => '🚫 현재 구독권으로는 재생할 수 없습니다.',
          'S003' => '⚠️ 로그인 후 이용해 주세요.',
          _ => '❌ 알 수 없는 오류가 발생했습니다.',
        };

        context.showToast(message);
        return Future.error(message);
      }

      final data = apiResponse.data!;
      return Track(
        trackId: trackId,
        albumId: albumId,
        trackTitle: data['title'] ?? '',
        artistName: data['artist'] ?? '',
        lyric: data['lyrics'] ?? '',
        trackFileUrl: data['trackFileUrl'] ?? '',
        coverUrl: data['coverImageUrl'] ?? '',
        trackNumber: 0,
        commentCount: 0,
        lyricist: [''],
        composer: [''],
        comments: [],
        createdAt: DateTime.now().toString(),
        trackLikeCount: 0,
        albumTitle: '',
        genreName: '',
      );
    } on DioException catch (e) {
      final code = e.response?.data['error']?['code'];
      final message = switch (code) {
        'S001' => '🔒 구독권이 없습니다. 구독 후 이용해 주세요.',
        'S002' => '🚫 현재 구독권으로는 재생할 수 없습니다.',
        'S003' => '⚠️ 로그인 후 이용해 주세요.',
        _ => '❌ 알 수 없는 오류가 발생했습니다.',
      };

      context.showToast(message);
      return Future.error(message); // 흐름 중단
    }
  }

  Future<void> _playSingleTrack(WidgetRef ref, Track track) async {
    final url = track.trackFileUrl ?? '';
    final source = AudioSource.uri(Uri.parse(url));
    try {
      print('[DEBUG] 🎧 setAudioSource 시도 중... URL: $url');
      final duration = await audioPlayer.setAudioSource(source);
      print('[DEBUG] ✅ AudioSource 세팅 완료, duration: $duration');

      await audioPlayer.setVolume(1.0);
      print('[DEBUG] 🎚 볼륨 설정 완료');

      await audioPlayer.play();
      print('[DEBUG] 🔊 오디오 재생 시작됨');

      // 플레이어 상태 실시간 확인
      audioPlayer.playerStateStream.listen((state) {
        print(
          '[DEBUG] 📡 상태 업데이트: playing=${state.playing}, processingState=${state.processingState}',
        );
      });

      audioPlayer.playbackEventStream.listen((event) {
        print('[DEBUG] 🎵 PlaybackEvent: $event');
      });
    } catch (e) {
      print('[ERROR] 오디오 재생 중 오류 발생: $e');
      throw Exception('오디오 재생 중 오류 발생: $e');
    }
  }

  Future<void> resume(WidgetRef ref) async {
    await audioPlayer.play();
    ref.read(playbackProvider.notifier).updatePlaybackState(true);
  }

  Future<void> pause(WidgetRef ref) async {
    await audioPlayer.pause();
    ref.read(playbackProvider.notifier).updatePlaybackState(false);
  }

  Future<void> seekTo(Duration position) async {
    await audioPlayer.seek(position);
  }

  Future<void> playNext() async {
    await audioPlayer.seekToNext();
    await audioPlayer.play();
  }

  Future<void> playPrevious() async {
    await audioPlayer.seekToPrevious();
    await audioPlayer.play();
  }

  Future<void> toggleShuffle() async {
    final enabled = audioPlayer.shuffleModeEnabled;
    await audioPlayer.setShuffleModeEnabled(!enabled);
  }

  Future<void> setLoopMode(LoopMode loopMode) async {
    await audioPlayer.setLoopMode(loopMode);
  }
}

final audioServiceProvider = Provider<AudioService>((ref) => AudioService());
