import 'package:flutter/material.dart';

import '../pages/audio_player_page.dart';
import '../utils/constant.dart';
import '../utils/shared_prefs.dart';

class BottomAudioPlayerScreen extends StatefulWidget {
  final dynamic subliminal;
  final bool isLoading;
  final double padding;
  final VoidCallback onAddTap;

  const BottomAudioPlayerScreen(
      {super.key,
      required this.subliminal,
      required this.isLoading,
      required this.padding,
      required this.onAddTap});

  @override
  BottomAudioPlayerState createState() => BottomAudioPlayerState();
}

class BottomAudioPlayerState extends State<BottomAudioPlayerScreen> {
  @override
  Widget build(BuildContext context) {
    return Positioned(
        bottom: 0,
        width: MediaQuery.of(context).size.width,
        child: GestureDetector(
            onTap: () => {
                  setState(() {
                    var cover = "";
                    if (widget.subliminal['cover_path'] != "") {
                      cover = widget.subliminal['cover_path'];
                    }
                    _showBottomDialog(
                        context,
                        widget.subliminal['title'],
                        widget.subliminal['audio_path'],
                        cover,
                        widget.subliminal['id']);
                  }),
                },
            child: Container(
                height: 90,
                margin: EdgeInsets.only(
                    bottom: 80,
                    left: widget.padding + 10,
                    right: widget.padding + 10),
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                decoration: kAllCornerBoxDecoration2,
                child: Row(
                  children: [
                    Expanded(
                        flex: 1,
                        child: Container(
                          margin: const EdgeInsets.only(left: 20, right: 10),
                          width: 80,
                          height: 80,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20.0),
                            child: Align(
                              alignment: Alignment.center,
                              child: widget.subliminal['cover_path'] != ""
                                  ? Image.network(
                                      widget.subliminal['cover_path'],
                                      fit: BoxFit.contain,
                                      loadingBuilder: (BuildContext context,
                                          Widget child,
                                          ImageChunkEvent? loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Center(
                                          child: Container(
                                              padding: const EdgeInsets.all(5),
                                              child: CircularProgressIndicator(
                                                value: loadingProgress
                                                            .expectedTotalBytes !=
                                                        null
                                                    ? loadingProgress
                                                            .cumulativeBytesLoaded /
                                                        loadingProgress
                                                            .expectedTotalBytes!
                                                    : null,
                                              )),
                                        );
                                      },
                                    )
                                  : Image.asset(
                                      'assets/images/bg_logo_image.png',
                                      fit: BoxFit.contain,
                                    ),
                            ),
                          ),
                        )),
                    Expanded(
                        flex: 7,
                        child: Container(
                          alignment: Alignment.topLeft,
                          padding: const EdgeInsets.only(top: 10),
                          margin: const EdgeInsets.only(left: 60, right: 5),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.subliminal['title'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontFamily: 'DPClear',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(top: 5),
                                child: Text(
                                  widget.subliminal['description'],
                                  maxLines: 2,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white54,
                                    fontFamily: 'DPClear',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                    Expanded(
                        flex: 2,
                        child: GestureDetector(
                            onTap: () => {
                                  setState(() {
                                    widget.onAddTap();
                                  }),
                                },
                            child: Container(
                              child: !widget.isLoading
                                  ? !SharedPrefs().isSubPlaying()
                                      ? Image.asset(
                                          'assets/images/ic_play_button_white.png',
                                          color: Colors.white,
                                          scale: 15,
                                        )
                                      : Image.asset(
                                          'assets/images/ic_pause_white.png',
                                          color: Colors.white,
                                          scale: 15,
                                        )
                                  : Center(
                                      child: Container(
                                          padding: const EdgeInsets.all(5),
                                          child:
                                              const CircularProgressIndicator())),
                            )))
                  ],
                ))));
  }

  void _showBottomDialog(BuildContext context, String subName, String subAudio,
      String subImage, int subId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Column(mainAxisSize: MainAxisSize.min, children: [
          AudioPlayerController(
              subName: subName,
              subAudio: subAudio,
              subImage: subImage,
              subId: subId,
              isLocal: true),
        ]);
      },
    );
  }
}
