import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/constant.dart';
import '../utils/shared_prefs.dart';

class AudioPlayerController extends StatefulWidget {
  final String subName;
  final String subAudio;
  final String subImage;
  final int subId;
  final bool isLocal;

  const AudioPlayerController(
      {Key? key,
      required this.subAudio,
      required this.subName,
      required this.subImage,
      required this.subId,
      required this.isLocal})
      : super(key: key);

  @override
  _AudioPlayerScreen createState() => _AudioPlayerScreen();
}

class _AudioPlayerScreen extends State<AudioPlayerController> {
  String formatTime(int seconds) {
    return '${(Duration(seconds: seconds))}'.split('.')[0].padLeft(8, '0');
  }

  Duration durations = Duration.zero;
  Duration positions = Duration.zero;
  int maxduration = 100;
  int currentpos = 0;
  late AudioHandler audioHandler;
  bool isPrepare = false;
  bool isStoped = false;
  bool isPaused = false;

  late Uint8List audiobytes;
  var playbackRate;
  var playerStatus = "stop";

  changeDuration(Duration dur) {
    setState(() {
      durations = dur;
    });
  }

  changePos(Duration pos) {
    setState(() {
      positions = pos;
    });
  }

  @override
  void initState() {
    super.initState();
    _listenForDurationChanges();
    _listenForPositionChanges();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    return Container(
      constraints: BoxConstraints(
        maxHeight: mq.height,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [backgroundDark, backgroundDark],
          stops: [0.5, 1.5],
        ),
      ),
      child: Wrap(children: [
        buildTopBarContainer(context, mq),
        Container(
            margin: const EdgeInsets.only(bottom: 30, top: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.only(
                      bottom: 30, top: 20, left: 25, right: 25),
                  height: 250,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15.0),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: widget.subImage != ""
                          ? Image.network(
                              widget.subImage,
                              fit: BoxFit.contain,
                              loadingBuilder: (BuildContext context,
                                  Widget child,
                                  ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                );
                              },
                            )
                          : Image.asset(
                              'assets/images/bg_logo_image.png',
                              fit: BoxFit.contain,
                            ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.only(left: 15, bottom: 10),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            widget.subName,
                            style: const TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontFamily: 'DPClear',
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                      _seekBar(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: Text(
                              formatTime(positions.inSeconds)
                                  .toString()
                                  .split('.')[0],
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 25),
                            child: Text(
                              formatTime((durations - positions).inSeconds)
                                  .toString()
                                  .split('.')[0],
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 37),
                      child: playButton(),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 37),
                      child: stopButton(),
                    ),
                  ],
                )
              ],
            ))
      ]),
    );
  }

  Widget playButton() {
    return GestureDetector(
      onTap: () => {
        setState(() {
          playerState();
          if (widget.isLocal) {
            if (isStoped) {
              player.setUrl(widget.subAudio);
              player.play();
              SharedPrefs().setIsSubPlaying(true);
              isStoped = false;
              buttonPlaying = "Stop Now";
            } else {
              if (SharedPrefs().isSubPlaying()) {
                // if (widget.subId == SharedPrefs().getSubPlayingId()) {
                player.pause();
                isStoped = false;
                buttonPlaying = "Listen now";
                SharedPrefs().setIsSubPlaying(false);
              } else {
                //  player.stop();
                // player.setAsset(widget.subAudio);
                player.play();
                isStoped = false;
                // advancedPlayer.stop();
                //advancedPlayer.play(DeviceFileSource(widget.subAudio));
                buttonPlaying = "Stop Now";
                SharedPrefs().setIsSubPlaying(true);
              }
            }
          } else {
            if (isStoped) {
              player.setUrl(widget.subAudio);
              player.play();
              SharedPrefs().setIsSubPlaying(true);
              buttonPlaying = "Stop Now";
              isStoped = false;
            } else {
              if (SharedPrefs().isSubPlaying()) {
                //if (widget.subId == SharedPrefs().getSubPlayingId()) {
                player.pause();
                isStoped = false;
                buttonPlaying = "Listen now";
                SharedPrefs().setIsSubPlaying(false);
              } else {
                // player.stop();
                // player.setUrl(widget.subAudio);
                player.play();
                isStoped = false;
                buttonPlaying = "Stop Now";
                SharedPrefs().setIsSubPlaying(true);
              }
            }
          }
        })
      },
      child: Column(children: [
        !SharedPrefs().isSubPlaying()
            ? Image.asset(
                'assets/images/ic_play_button_white.png',
                color: Colors.white,
                scale: 9,
              )
            : Image.asset('assets/images/ic_pause_white.png',
                color: Colors.white, scale: 9)
      ]),
    );
  }

  _seekBar() {
    return Column(
      children: [
        StreamBuilder<Duration?>(
          stream: player.durationStream,
          builder: (context, snapshotDuration) {
            durations = snapshotDuration.data ?? Duration.zero;

            return StreamBuilder<Duration>(
              stream: player.positionStream,
              builder: (context, snapshot) {
                positions = snapshot.data ?? Duration.zero;

                if (positions > durations) {
                  positions = durations;
                }
                return Slider(
                  value: positions.inSeconds.toDouble(),
                  min: 0.0,
                  max: durations.inSeconds.toDouble(),
                  onChanged: (double value) {
                    setState(() {
                      changeToSecond(value.toInt(), snapshotDuration.data!,
                          snapshot.data!);
                      value = value;
                    });

                    // player.seek(Duration(seconds: value.toInt()));
                  },
                );
              },
            );
          },
        ),

        /*Slider(
          activeColor: Colors.purpleAccent,
          inactiveColor: Colors.grey,
          value: position.inSeconds.toDouble(),
          min: 0.0,
          max: duration.inSeconds.toDouble(),
          divisions: maxduration,
          onChanged: (double value) {
            setState(() {
              changeToSecond(value.toInt());
              value = value;
            });
          },
        ),*/
      ],
    );
  }

  void _listenForDurationChanges() {
    player.durationStream.listen((duration) {
      changeDuration(duration!);

      if (kDebugMode) {
        print("dur---$duration");
      }
    });
  }

  void _listenForPositionChanges() {
    player.positionStream.listen((position) {
      changePos(position);

      if (position == durations) {
        player.stop();
        durations = Duration.zero;
        positions = Duration.zero;
      }

      if (kDebugMode) {
        print("pos---$position");
      }
    });
  }

  Widget buildTopBarContainer(BuildContext context, Size mq) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => {Navigator.pop(context)},
          child: Container(
            padding: const EdgeInsets.only(left: 10, top: 10),
            child: Align(
              alignment: Alignment.topLeft,
              child: Image.asset('assets/images/ic_close_icon.png', scale: 3),
            ),
          ),
        ),
      ],
    );
  }

  Widget stopButton() {
    return GestureDetector(
      onTap: () => {
        setState(() {
          playerState();
          player.stop();
          buttonPlaying = "Listen Now";
          SharedPrefs().setIsSubPlaying(false);
          durations = Duration.zero;
          positions = Duration.zero;
          currentpos = 0;
          isStoped = true;
        })
      },
      child: Container(
        margin: const EdgeInsets.only(left: 20),
        child: Column(
          children: [
            Align(
              alignment: Alignment.center,
              child: Image.asset(
                'assets/images/ic_stop_icon_white.png',
                color: Colors.white,
                scale: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void changeToSecond(int second, Duration dur, Duration pos) {
    Duration newDuration = Duration(seconds: second);
    player.seek(newDuration);
    durations = dur;
    positions = pos;
  }

  void playerState() {
    setState(() {
      playerStatus = player.processingState.name;

      if (kDebugMode) {
        print('Current player state:$playerStatus');
      }
      if (kDebugMode) {
        print('playerStatus:$playerStatus');
      }
    });
  }
}
