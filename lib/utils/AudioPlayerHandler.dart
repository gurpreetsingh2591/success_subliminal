import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:success_subliminal/utils/constant.dart';

Future<AudioHandler> initAudioService(String url) async {
  return AudioService.init(
    builder: () => AudioPlayerHandler(url),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.success.subliminal.audio',
      androidNotificationChannelName: 'Audio Service Demo',
    ),
  );
}

final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
late final MediaItem? mediaItem;

class AudioPlayerHandler extends BaseAudioHandler with SeekHandler {
  String audioUrl = "";

  @override
  AudioPlayerHandler(String url) {
    audioUrl = url;
    player.playbackEventStream.listen((PlaybackEvent event) {
      final playing = player.playing;
      playbackState.add(playbackState.value.copyWith(
        controls: [
          MediaControl.pause,
          MediaControl.play,
          MediaControl.stop,
        ],
        processingState: const {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[player.processingState]!,
        playing: playing,
        updatePosition: player.position,
        bufferedPosition: player.bufferedPosition,
        queueIndex: event.currentIndex,
      ));
    });
  }

  @override
  Future<void> play() async {
    playbackState.add(playbackState.value.copyWith(
      playing: true,
      controls: [MediaControl.pause],
    ));

    await player.play();
  }

  @override
  Future<void> pause() async {
    playbackState.add(playbackState.value.copyWith(
      playing: false,
      controls: [MediaControl.play],
    ));

    await player.pause();
  }

  @override
  Future<void> stop() async {
    // Release any audio decoders back to the system
    await player.stop();

    playbackState.add(playbackState.value.copyWith(
      processingState: AudioProcessingState.idle,
    ));
  }

  @override
  Future<void> seek(Duration position) async {
    playbackState.add(playbackState.value.copyWith());
    chnageDutaion();
    player.seek(position);
  }

  chnageDutaion() {
    StreamBuilder<Duration?>(
      stream: player.durationStream,
      builder: (context, snapshotDuration) {
        final duration = snapshotDuration.data ?? Duration.zero;

        return StreamBuilder<Duration>(
          stream: player.positionStream,
          builder: (context, snapshot) {
            final position = snapshot.data ?? Duration.zero;
            return Slider(
              value: position.inSeconds.toDouble(),
              min: 0.0,
              max: duration.inSeconds.toDouble(),
              onChanged: (double value) {
                player.seek(Duration(seconds: value.toInt()));
              },
            );
          },
        );
      },
    );
  }
}
