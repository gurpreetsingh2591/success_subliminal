import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/AudioPlayerHandler.dart';
import '../utils/constant.dart';
import '../utils/shared_prefs.dart';
import '../widget/BottomBarStateFullWidget.dart';
import 'audio_player_page.dart';

class DownloadedSubPage extends StatefulWidget {
  const DownloadedSubPage({Key? key}) : super(key: key);

  @override
  DownloadedSub createState() => DownloadedSub();
}

class DownloadedSub extends State<DownloadedSubPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  var refreshKey = GlobalKey<RefreshIndicatorState>();
  late List<dynamic> subliminalList = [];
  String selectedSubliminal = "";
  double bottomMargin = 80;
  int subId = 0;
  String subName = "";
  bool isLoading = false;
  final AudioPlayerHandler _audioHandler = AudioPlayerHandler("");
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  Map<String, dynamic> _deviceData = <String, dynamic>{};

  // PlayerState playerState = PlayerState.playing;

  var playerStatus = "stop";
  bool? isExist = false;
  bool isListen = false;

  /*@override
  void dispose() {
    player.dispose();

    super.dispose();
  }
*/
  void _startPlaybackStateListener() {
    _audioHandler.playbackState.listen((state) {
      // Access the play button value from the playback state
      bool isPlaying = state.playing;

      if (kDebugMode) {
        print(isPlaying.toString());
      }
      setState(() {
        if (isPlaying) {
          changeName("Stop Now", true);
        } else {
          changeName("Listen Now", false);
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getDeviceInfo();
    _startPlaybackStateListener();

    initializePreference().whenComplete(() {
      setState(() {
        SharedPrefs().isSubPlaying() ? isListen = true : isListen = false;
        SharedPrefs().isSubPlaying() ? bottomMargin = 170 : bottomMargin = 80;

        if (!SharedPrefs().isSubPlaying()) {
          changeName("Listen Now", false);
        } else {
          changeName("Stop Now", true);
        }
      });
    });
    getAllData();
  }

  getAllData() {
    if (subliminalList.isNotEmpty) {
      if (!SharedPrefs().isSubPlaying()) {
        selectedSubliminal = subliminalList[0];
        isListen = false;
        isListen
            ? SharedPrefs().isSubPlaying()
                ? bottomMargin = 170
                : bottomMargin = 80
            : bottomMargin = 80;
      } else {
        bool isFlag = false;
        for (int i = 0; i < subliminalList.length; i++) {
          if (SharedPrefs().getSubPlayingId() == splitId(subliminalList[i])) {
            selectedSubliminal = subliminalList[i];
            isFlag = true;
            break;
          }
          isFlag ? isListen = true : isListen = false;
          isListen
              ? SharedPrefs().isSubPlaying()
                  ? bottomMargin = 170
                  : bottomMargin = 80
              : bottomMargin = 80;
        }
      }
    }
  }

  String splitName(String subliminal) {
    List<String> myName = [];
    if (Platform.isAndroid) {
      if (int.parse(_deviceData["version.release"]) > 12) {
        List<String> myStrings = subliminal.split("u-");
        List<String> splitUserId = myStrings[1].split("/");
        String nameSplit = splitUserId[1];
        myName = nameSplit.split("_");
      } else {
        List<String> myStrings = subliminal.split("SuccessSubliminal/u-");
        List<String> splitUserId = myStrings[1].split("/");
        String nameSplit = splitUserId[1];
        myName = nameSplit.split("_");
      }
    } else {
      List<String> myStrings = subliminal.split("Documents/u-");
      List<String> splitUserId = myStrings[1].split("/");
      String nameSplit = splitUserId[1];
      myName = nameSplit.split("_");
      /* List<String> myStrings = subliminal.split("Documents/");
      String nameSplit = myStrings[1];
      myName = nameSplit.split("_");*/
    }

    return myName[0].toString();
  }

  int splitId(String subliminal) {
    List<String> subId = [];
    if (Platform.isAndroid) {
      if (int.parse(_deviceData["version.release"]) > 12) {
        List<String> myStrings = subliminal.split("u-");
        String nameSplit = myStrings[1];
        List<String> myName = nameSplit.split("_");
        String splitId = myName[1];
        subId = splitId.split(".");
      } else {
        List<String> myStrings = subliminal.split("SuccessSubliminal/u-");
        String nameSplit = myStrings[1];
        List<String> myName = nameSplit.split("_");
        String splitId = myName[1];
        subId = splitId.split(".");
      }
    } else {
      List<String> myStrings = subliminal.split("Documents/u-");
      String nameSplit = myStrings[1];
      List<String> myName = nameSplit.split("_");
      String splitId = myName[1];
      subId = splitId.split(".");
    }

    return int.parse(subId[0]);
  }

  getFiles(int version) async {
    isExist = await isFileExistsInDownloads(version);
    if (isExist!) {
      getAllData();
      if (kDebugMode) {
        print('The file exists in the download directory.');
      }
    } else {
      if (kDebugMode) {
        print('The file does not exist in the download directory.');
      }
    }
  }

  changeName(String name, bool isPlay) {
    setState(() {
      buttonPlaying = name;
      SharedPrefs().setIsSubPlaying(isPlay);
    });
  }

  Future<void> initializePreference() async {
    SharedPrefs.init(await SharedPreferences.getInstance());
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(0),
          child: AppBar(
            flexibleSpace: Container(
              decoration: const BoxDecoration(gradient: statusBarGradient),
            ),
          ),
        ),
        body: RefreshIndicator(
          key: refreshKey,
          color: Colors.black,
          onRefresh: () async {
            getDeviceInfo();
            _startPlaybackStateListener();
            setState(() {});
          },
          child: SafeArea(
            // child: SingleChildScrollView(
            child: Container(
              constraints: BoxConstraints(
                maxHeight: mq.height,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [backgroundDark, backgroundDark],
                  stops: [0.5, 1.5],
                ),
              ),
              child: Stack(
                children: <Widget>[
                  /* Image.asset(
                    'assets/images/ic_bg_dark_blue.png',
                    fit: BoxFit.cover,
                    height: double.infinity,
                    width: double.infinity,
                    alignment: Alignment.center,
                  ),*/
                  buildTopBarContainer(context, mq),
                  const BottomBarStateFull(
                      screen: "download", isUserLogin: true),
                  selectedSubliminal.isNotEmpty
                      ? Visibility(
                          visible: isListen,
                          child: buildPlayerBottomContainer(
                              context, selectedSubliminal))
                      : const Text(""),
                  Container(
                    margin: EdgeInsets.only(bottom: bottomMargin, top: 70),
                    child: ListView(
                      shrinkWrap: true,
                      primary: false,
                      children: [buildSubliminalListContainer(context, mq)],
                    ),
                  )
                ],
              ),
            ),
          ),
        )

        //),
        );
  }

  Widget buildSubliminalListContainer(BuildContext contexts, Size mq) {
    return Container(
      margin: const EdgeInsets.only(left: 5, right: 5, top: 15, bottom: 5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          (subliminalList.isNotEmpty)
              ? ListView.builder(
                  shrinkWrap: true,
                  primary: false,
                  itemCount: subliminalList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return buildSubliminalItemContainer(
                        contexts, subliminalList[index], index);
                  })
              : const Align(
                  alignment: Alignment.center,
                  child: Text(
                    "No Subliminal!",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontFamily: 'DPClear',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget buildTopBarContainer(BuildContext context, Size mq) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => {
            setState(() {
              Navigator.pop(context);
            })
          },
          child: Container(
            padding: const EdgeInsets.only(left: 10, top: 10),
            child: Align(
              alignment: Alignment.topLeft,
              child: Image.asset('assets/images/ic_arrow_left.png', scale: 1.5),
            ),
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.only(left: 15, top: 15),
            child: const Align(
              alignment: Alignment.topLeft,
              child: Text(
                'Downloaded Subliminal',
                maxLines: 2,
                style: TextStyle(
                    fontSize: 26,
                    color: Colors.white,
                    fontFamily: 'DPClear',
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildSubliminalItemContainer(
      BuildContext context, String subliminal, int index) {
    return Container(
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.only(left: 10, right: 10, top: 10),
      decoration: kAllCornerBoxDecoration2,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: SizedBox(
                  width: 100,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15.0),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Image.asset(
                        'assets/images/bg_logo_image.png',
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 5,
                child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.only(
                          left: 25,
                          bottom: 10,
                        ),
                        alignment: Alignment.topLeft,
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            splitName(subliminal).replaceAll("-", ""),
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontFamily: 'DPClear',
                              fontWeight: FontWeight.w600,
                            ),
                            softWrap: true,
                          ),
                        ),
                      ),
                      buildListenButton(context, subliminal),
                    ]),
              )

              //
            ],
          ),
        ],
      ),
    );
  }

  Widget buildListenButton(BuildContext context, String subliminal) {
    return ConstrainedBox(
        constraints: const BoxConstraints(minWidth: double.infinity),
        child: Container(
          margin: const EdgeInsets.only(top: 20, left: 25),
          height: 40,
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                isListen = true;
                bottomMargin = 170;
                selectedSubliminal = subliminal;
              });

              setState(() {
                if (kDebugMode) {
                  print(subliminalList);
                }

                if (!SharedPrefs().isSubPlaying()) {
                  changeName("Stop Now", true);
                  SharedPrefs().setPlayingSubId(splitId(subliminal));
                  SharedPrefs().setPlayingSubName(splitName(subliminal));

                  player.setFilePath(subliminal);
                  //  player.play();
                  if (kDebugMode) {
                    print("path---$subliminal");
                  }
                  isLoading = true;
                  Future.delayed(const Duration(seconds: 2))
                      .then((value) => setState(() {
                            player.play();
                            isLoading = false;
                          }));
                } else {
                  if (SharedPrefs().getSubPlayingId() == splitId(subliminal)) {
                    SharedPrefs().setPlayingSubId(splitId(subliminal));
                    SharedPrefs().setPlayingSubName(splitName(subliminal));
                    changeName("Listen Now", false);
                    player.stop();
                    isLoading = false;
                  } else {
                    player.stop();
                    SharedPrefs().setPlayingSubId(splitId(subliminal));
                    SharedPrefs().setPlayingSubName(splitName(subliminal));
                    changeName("Stop Now", true);
                    player.setFilePath(subliminal);
                    if (kDebugMode) {
                      print("path---$subliminal");
                    }
                    player.play();

                    //advancedPlayer.setSource(DeviceFileSource(subliminal));
                    isLoading = true;
                    Future.delayed(const Duration(seconds: 1))
                        .then((value) => setState(() {
                              player.play();
                              /*advancedPlayer.play(DeviceFileSource(subliminal));*/
                              isLoading = false;
                            }));
                  }
                }
              });
            },
            style: ElevatedButton.styleFrom(
              primary: kButtonColor1,
              onPrimary: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10), // <-- Radius
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 10),
                  child: Align(
                    alignment: Alignment.center,
                    child: SharedPrefs().getSubPlayingId() ==
                            splitId(subliminal)
                        ? !SharedPrefs().isSubPlaying()
                            ? Image.asset('assets/images/ic_play.png',
                                scale: 1.5)
                            : Image.asset('assets/images/ic_stop.png',
                                scale: 1.5)
                        : Image.asset('assets/images/ic_play.png', scale: 1.5),
                  ),
                ),
                Text(
                    SharedPrefs().getSubPlayingId() == splitId(subliminal)
                        ? buttonPlaying.toUpperCase()
                        : 'Listen Now'.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 15,
                      fontFamily: 'DPClear',
                      fontWeight: FontWeight.w600,
                    ))
              ],
            ),
          ),
        ));
  }

  Widget buildPlayerBottomContainer(BuildContext context, String subliminal) {
    return Positioned(
        bottom: 0,
        width: MediaQuery.of(context).size.width,
        child: GestureDetector(
            onTap: () => {
                  setState(() {
                    _showBottomDialog(context, splitName(subliminal),
                        subliminal, "", splitId(subliminal));
                  }),
                },
            child: Container(
                height: 90,
                margin: const EdgeInsets.only(bottom: 70),
                padding: const EdgeInsets.only(
                    left: 15, right: 15, top: 10, bottom: 10),
                decoration: kBottomBarBgDecoration,
                child: Row(
                  children: [
                    Expanded(
                        flex: 2,
                        child: SizedBox(
                          width: 30,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: Align(
                              alignment: Alignment.center,
                              child: Image.asset(
                                'assets/images/bg_logo_image.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        )),
                    Expanded(
                        flex: 6,
                        child: Container(
                          alignment: Alignment.topLeft,
                          padding: const EdgeInsets.only(top: 10),
                          margin: const EdgeInsets.only(left: 10, right: 5),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                splitName(subliminal),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontFamily: 'DPClear',
                                  fontWeight: FontWeight.w500,
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
                              if (!SharedPrefs().isSubPlaying()) {
                                player.play();
                                changeName("Stop Now", true);
                              } else {
                                player.pause();
                                changeName("Listen Now", false);
                              }
                            }),
                          },
                          child: !isLoading
                              ? !SharedPrefs().isSubPlaying()
                                  ? Image.asset(
                                      'assets/images/ic_play_icon.png',
                                      color: Colors.white,
                                      scale: 15,
                                    )
                                  : Image.asset(
                                      'assets/images/ic_pause_icon.png',
                                      color: Colors.white,
                                      scale: 14,
                                    )
                              : Center(
                                  child: Container(
                                      padding: const EdgeInsets.all(5),
                                      child:
                                          const CircularProgressIndicator())),
                        ))
                  ],
                ))));
  }

  Future<String?> getAppDirectoryPath() async {
    Directory? directory;
    try {
      directory = await getApplicationDocumentsDirectory();

      "${directory.path}/SuccessSubliminal";
      // Put file in global download folder, if for an unknown reason it didn't exist, we fallback
      // ignore: avoid_slow_async_io
      if (!await directory.exists()) {
        directory = await getExternalStorageDirectory();
      }
      if (kDebugMode) {
        print(directory?.path);
      }
    } catch (err, stack) {
      if (kDebugMode) {
        print("Cannot get download folder path");
      }
    }
    return directory?.path;
  }

  Future<void> getDeviceInfo() async {
    if (Platform.isAndroid) {
      _deviceData = _readAndroidBuildData(await deviceInfoPlugin.androidInfo);
      if (int.parse(_deviceData["version.release"]) > 12) {
        getFiles(13);
      } else {
        getFiles(12);
      }
    } else {
      getFiles(13);
    }
  }

  Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'version.release': build.version.release,
      'version.codename': build.version.codename,
      'version.baseOS': build.version.baseOS,
      'device': build.device,
      'fingerprint': build.fingerprint,
      'id': build.id,
      'model': build.model,
    };
  }

  Future<bool?> isFileExistsInDownloads(int version) async {
    Directory? directory;
    try {
      if (Platform.isIOS) {
        directory = Directory(
            "${(await getApplicationDocumentsDirectory()).path}/u-${SharedPrefs().getUserId()}");
        /* directory = await getApplicationDocumentsDirectory();*/
      } else {
        if (version == 13) {
          directory = Directory(
              "${(await getExternalStorageDirectory())!.path}/u-${SharedPrefs().getUserId()}");
        } else {
          directory = Directory(
              '/storage/emulated/0/Download/SuccessSubliminal/u-${SharedPrefs().getUserId()}');
        }
      }

      final files = directory.listSync();
      if (kDebugMode) {
        print(files.length);
      }
      if (files.isNotEmpty) {
        for (var file in files) {
          setState(() {
            subliminalList.add(file.path);
            if (kDebugMode) {
              print(file.path);
            }
          });
        }
        return true;
      } else {
        return false;
      }
    } catch (err, stack) {
      if (kDebugMode) {
        print("Cannot get download folder path");
      }
    }
    return false;

    /*final downloadsPath = await getApplicationDocumentsDirectory();
    final downloadsDir = Directory(downloadsPath.path);
    final files = downloadsDir.listSync();
    print(files.length);
    if (files.isNotEmpty) {
      for (var file in files) {
        setState(() {
          subliminalList.add(file.path);
          print(file.path);
        });
      }
      return true;
    }
    return false;*/
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
