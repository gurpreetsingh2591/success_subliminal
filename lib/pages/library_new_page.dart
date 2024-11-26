import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_share_me/flutter_share_me.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:readmore/readmore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:success_subliminal/pages/downloaded_sub_page.dart';

import '../data/api/ApiService.dart';
import '../utils/AudioPlayerHandler.dart';
import '../utils/center_loader.dart';
import '../utils/constant.dart';
import '../utils/service_locator.dart';
import '../utils/shared_prefs.dart';
import '../utils/toast.dart';
import '../widget/BottomBarStateFullWidget.dart';
import '../widget/ButtonWidget.dart';
import 'audio_player_page.dart';

class LibraryNewPage extends StatefulWidget {
  const LibraryNewPage({Key? key}) : super(key: key);

  @override
  _LibraryNewPage createState() => _LibraryNewPage();
}

class _LibraryNewPage extends State<LibraryNewPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late List<dynamic> subliminalList = [];
  late List<dynamic> collectionList = [];
  late dynamic subliminal;
  late dynamic addToCollection;
  late dynamic collection;
  late dynamic createCollection;
  dynamic selectedSubliminal;
  dynamic deleteSubliminal;

  bool isLoading = false;
  bool isListen = false;
  bool isSubliminal = false;
  int isSelect = 0;
  int subIndex = 0;
  double bottomMargin = 80;
  late StateSetter _setState;
  final _nameText = TextEditingController();

  final FocusNode _nameFocus = FocusNode();

  String filter = "all";
  String filterAll = "wishlist=false&buy=false&my=true";

  String collectionId = "";

  var playerStatus = "stop";
  bool isPrepare = false;
  late String _downloadMessage;
  late double _downloadProgress;
  final AudioPlayerHandler _audioHandler = AudioPlayerHandler("");
  String androidDeviceOS = "";

  //get path => null;
  String? path;
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  Map<String, dynamic> _deviceData = <String, dynamic>{};
  bool isTrial = false;
  bool isTrialUsed = false;
  bool isSubscriptionActive = false;
  late dynamic usedFreeTrial;
  int difference = 0;
  bool? granted;

/*
  @override
  void dispose() {
    advancedPlayer.dispose();
    super.dispose();
  }
*/

  @override
  void initState() {
    super.initState();
    changeScreenName("library");
    getDeviceInfo();
    permission();
    permissionGranted();

    _startPlaybackStateListener();
    changeDuration();
    initializePreference().whenComplete(() {
      setState(() {
        isTrial = SharedPrefs().isFreeTrail();
        isTrialUsed = SharedPrefs().isFreeTrailUsed();
      });
      _getSubliminalListData(filterAll);

      setState(() {
        SharedPrefs().isSubPlaying() ? isListen = true : isListen = false;
        SharedPrefs().isSubPlaying() ? bottomMargin = 170 : bottomMargin = 80;

        if (!player.playing) {
          if (SharedPrefs().isFreeTrail() == true) {
            if (isTrialUsed) {
              changeName(kListenNow, false);
            } else {
              changeName(kListenWithTrial, false);
            }
          } else {
            changeName(kListenNow, false);
          }
        } else {
          changeName(kStopNow, true);
        }
      });
    });

    DateTime dateTime = DateTime.now();
    DateTime pickedDate = DateTime.parse(SharedPrefs().getTrialStartDate()!);

    difference = dateTime.difference(pickedDate).inDays;
  }

  changeScreenName(String name) {
    setState(() {
      screenName = name;
    });
  }

  void _getDeleteSubliminalListData(String subId) async {
    deleteSubliminal = await ApiService().getDeleteSubliminal(context, subId);

    Future.delayed(const Duration(seconds: 2)).then((value) => setState(() {
          setState(() {
            if (deleteSubliminal['http_code'] != 200) {
            } else {
              setState(() {
                if (deleteSubliminal['message'] == 'Item Deleted') {
                  _getSubliminalListData(filterAll);
                } else {
                  toast(deleteSubliminal['message'], false);
                }

                Future.delayed(const Duration(seconds: 3))
                    .then((value) => setState(() async {
                          setState(() {
                            Navigator.of(context, rootNavigator: true).pop();
                            Navigator.of(context, rootNavigator: true).pop();
                          });
                        }));
              });
            }
          });
        }));
  }

  void _startPlaybackStateListener() {
    _audioHandler.playbackState.listen((state) {
      // Access the play button value from the playback state
      bool isPlaying = state.playing;

      setState(() {
        if (isPlaying) {
          changeName("Stop Now", true);
        } else {
          changeName("Listen Now", false);
        }
      });
    });
  }

  void _getUsedFreeTrialData(
      BuildContext context, String status, String id) async {
    usedFreeTrial = await ApiService().getFreeTrialUsed(context, status, id);

    Future.delayed(const Duration(seconds: 2)).then((value) => setState(() {
          setState(() {
            if (usedFreeTrial['http_code'] != 200) {
            } else {
              if (usedFreeTrial['data']['free_trial_status'] == 'true') {
                setState(() {
                  SharedPrefs().setIsFreeTrail(true);
                  SharedPrefs().setIsFreeTrailUsed(true);

                  isTrial = SharedPrefs().isFreeTrail();
                  isTrialUsed = SharedPrefs().isFreeTrailUsed();
                  isSubscriptionActive = SharedPrefs().isSubscription();
                });
              }
            }
            if (kDebugMode) {
              print("size ----$usedFreeTrial");
            }
          });
        }));
  }

  changeDuration() {
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
                _audioHandler.seek(Duration(seconds: value.toInt()));
              },
            );
          },
        );
      },
    );
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

  changeName(String name, bool isPlay) {
    setState(() {
      buttonPlaying = name;
      SharedPrefs().setIsSubPlaying(isPlay);
    });
  }

  Future<void> initializePreference() async {
    SharedPrefs.init(await SharedPreferences.getInstance());
  }

  void _getSubliminalListData(String filter) async {
    subliminal = await ApiService().getLibrarySubliminalList(context, filter);

    Future.delayed(const Duration(seconds: 2)).then((value) => setState(() {
          setState(() {
            isSubliminal = true;
          });

          if (subliminal['http_code'] != 200) {
          } else {
            subliminalList.clear();

            subliminalList.addAll(subliminal['data']['subliminals']);
            bool isFlag = false;
            if (!SharedPrefs().isSubPlaying()) {
              selectedSubliminal = subliminalList[0];
              isListen = false;
              isListen
                  ? SharedPrefs().isSubPlaying()
                      ? bottomMargin = 170
                      : bottomMargin = 80
                  : bottomMargin = 80;
            } else {
              for (int i = 0; i < subliminalList.length; i++) {
                if (SharedPrefs().getSubPlayingId() ==
                    subliminalList[i]['id']) {
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
        }));
  }

  void _getAddWishListData(String subId) async {
    subliminal = await ApiService().getAddWishlist(subId, context);

    Future.delayed(const Duration(seconds: 2)).then((value) => setState(() {
          setState(() {
            if (subliminal['http_code'] != 200) {
            } else {
              _getSubliminalListData(filterAll);
            }
            Navigator.of(context, rootNavigator: true).pop();
            Navigator.of(context, rootNavigator: true).pop();
          });
        }));
  }

  void _getRemoveWishListData(String subId) async {
    subliminal = await ApiService().getRemoveWishlist(subId, context);

    Future.delayed(const Duration(seconds: 2)).then((value) => setState(() {
          setState(() {
            if (subliminal['http_code'] != 200) {
            } else {
              _getSubliminalListData(filterAll);
            }
            // print("size ----${subliminalList.length}");
            Navigator.of(context, rootNavigator: true).pop();
            Navigator.of(context, rootNavigator: true).pop();
          });
        }));
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
      body: SafeArea(
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
              const BottomBarStateFull(screen: "library", isUserLogin: true),
              selectedSubliminal != null
                  ? Visibility(
                      visible: isListen,
                      child: buildPlayerBottomContainer(
                          context, selectedSubliminal))
                  : const Text(""),
              Container(
                padding: EdgeInsets.only(bottom: bottomMargin),
                margin: const EdgeInsets.only(top: 70),
                child: ListView(
                  shrinkWrap: false,
                  primary: true,
                  children: [
                    buildFilterContainer(context),
                    isSubliminal
                        ? buildSubliminalListContainer(context, mq)
                        : const SizedBox(
                            height: 500,
                            child: Center(child: CircularProgressIndicator())),
                  ],
                ),
              )
            ],
          ),
        ),
      ),

      //),
    );
  }

  Widget buildFilterContainer(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 15, right: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
              onTap: () => {
                    setState(() {
                      filter = "all";
                      isSubliminal = false;
                      subliminalList.clear();
                      filterAll = "wishlist=false&buy=false&my=true";
                      _getSubliminalListData(filterAll);
                    })
                  },
              child: Container(
                child: filter == "all"
                    ? const Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          'All',
                          style: TextStyle(
                              fontSize: 16,
                              color: kTextColor,
                              fontFamily: 'DPClear',
                              fontWeight: FontWeight.w600),
                        ),
                      )
                    : const Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          'All',
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontFamily: 'DPClear',
                              fontWeight: FontWeight.w600),
                        ),
                      ),
              )),
          GestureDetector(
            onTap: () => {
              setState(() {
                filter = "wishlist";
                isSubliminal = false;
                subliminalList.clear();
                filterAll = "wishlist=true&buy=false&my=false";
                _getSubliminalListData(filterAll);
              })
            },
            child: Container(
              child: filter == "wishlist"
                  ? const Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        'Wishlist',
                        style: TextStyle(
                            fontSize: 16,
                            color: kTextColor,
                            fontFamily: 'DPClear',
                            fontWeight: FontWeight.w600),
                      ),
                    )
                  : const Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        'Wishlist',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontFamily: 'DPClear',
                            fontWeight: FontWeight.w600),
                      ),
                    ),
            ),
          ),
          GestureDetector(
              onTap: () => {
                    setState(() {
                      filter = "categories";
                      isSubliminal = false;
                      subliminalList.clear();
                      _getSubliminalListData(
                          "wishlist=false&buy=true&my=false");
                    })
                  },
              child: Container(
                child: filter == "categories"
                    ? const Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          'Categories',
                          style: TextStyle(
                              fontSize: 16,
                              color: kTextColor,
                              fontFamily: 'DPClear',
                              fontWeight: FontWeight.w600),
                        ),
                      )
                    : const Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          'Categories',
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontFamily: 'DPClear',
                              fontWeight: FontWeight.w600),
                        ),
                      ),
              )),
        ],
      ),
    );
  }

  Widget buildSubliminalListContainer(BuildContext contexts, Size mq) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          margin: const EdgeInsets.only(left: 5, right: 5, top: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              (subliminalList.isNotEmpty)
                  ? ListView.builder(
                      reverse: true,
                      shrinkWrap: true,
                      primary: false,
                      itemCount: subliminalList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return buildSubliminalItemContainer(
                          contexts,
                          kAddToCollectionText,
                          true,
                          subliminalList[index],
                        );
                      })
                  : const Align(
                      alignment: Alignment.center,
                      child: Text(
                        kComingSoon,
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
        ),
      ],
    );
  }

  Widget buildTopBarContainer(BuildContext context, Size mq) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.only(left: 15, top: 10),
          child: const Align(
            alignment: Alignment.topLeft,
            child: Text(
              'Library',
              style: TextStyle(
                  fontSize: 32,
                  color: Colors.white,
                  fontFamily: 'DPClear',
                  fontWeight: FontWeight.w500),
            ),
          ),
        ),
        GestureDetector(
          onTap: () => {
            _navigateToDownloadedController()
            //context.go(Routes.downloaded)
          },
          child: !kIsWeb
              ? Container(
                  padding: const EdgeInsets.only(left: 15, top: 15, right: 15),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Image.asset(
                      'assets/images/ic_download.png',
                      scale: 2,
                    ),
                  ),
                )
              : const SizedBox(),
        ),
      ],
    );
  }

  Widget buildSubliminalItemContainer(BuildContext context, String buttonName,
      bool isWish, dynamic subliminalList) {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 100,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: subliminalList['cover_path'] != ""
                        ? Image.network(
                            subliminalList['cover_path'],
                            fit: BoxFit.cover,
                            width: 100,
                            height: 100,
                            loadingBuilder: (BuildContext context, Widget child,
                                ImageChunkEvent? loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: Container(
                                    padding: const EdgeInsets.all(5),
                                    child: CircularProgressIndicator(
                                      value:
                                          loadingProgress.expectedTotalBytes !=
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
                            fit: BoxFit.cover,
                            width: 100,
                            height: 100,
                          ),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.only(
                            left: 15,
                            bottom: 10,
                          ),
                          alignment: Alignment.topLeft,
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              subliminalList['title'],
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontFamily: 'DPClear',
                                fontWeight: FontWeight.w500,
                              ),
                              softWrap: true,
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.only(
                            left: 15,
                            bottom: 10,
                          ),
                          alignment: Alignment.topLeft,
                          child: Align(
                              alignment: Alignment.topLeft,
                              child: ReadMoreText(subliminalList['description'],
                                  trimLines: 5,
                                  colorClickableText: Colors.red,
                                  trimMode: TrimMode.Line,
                                  trimCollapsedText: 'Show more',
                                  trimExpandedText: '  Show less',
                                  moreStyle: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w600),
                                  style: const TextStyle(
                                    fontSize: 12.0,
                                    color: Colors.white54,
                                    fontFamily: 'DPClear',
                                    fontWeight: FontWeight.w400,
                                  ))),
                        ),
                      )
                    ]),
              ),
              Expanded(
                flex: 1,
                child: GestureDetector(
                  onTap: () => {
                    setState(() {
                      _downloadMessage = 'Downloading...';
                      _downloadProgress = 0.0;
                      buildListItemDialogContainer(context, subliminalList);
                    })
                  },
                  child: Container(
                    height: 50,
                    decoration: kTransButtonBoxDecoration,
                    alignment: Alignment.topRight,
                    margin: const EdgeInsets.only(left: 5, right: 2),
                    child: Align(
                      alignment: Alignment.center,
                      child:
                          Image.asset('assets/images/ic_more.png', scale: 1.5),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildBuyNowButton(BuildContext context, dynamic subliminalList) {
    return ConstrainedBox(
        constraints: const BoxConstraints(minWidth: double.infinity),
        child: Container(
          margin: const EdgeInsets.only(top: 10),
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                Navigator.of(context, rootNavigator: true).pop();

                context.pushNamed('buy-subliminals', queryParameters: {
                  'subId': subliminalList['id'].toString(),
                  "subName": subliminalList['title'],
                  "catId": subliminalList['creator_id'].toString(),
                  "catName": subliminalList['category_name'],
                  "amount": subliminalList['price'].toString(),
                  "screen": 'library'
                });
                /* _navigateToBuySubliminalScreen(
                  context,
                  subliminalList['price'].toString(),
                  subliminalList['id'].toString(),
                  subliminalList['title'],
                  subliminalList['creator_id'].toString(),
                  subliminalList['category_name'],
                );*/
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kButtonColor1,
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
                      child: Image.asset('assets/images/ic_bag_tick.png',
                          scale: 1.5)),
                ),
                Text('Buy Now'.toUpperCase(),
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

  Widget buildListenButton(BuildContext context, dynamic subliminalList) {
    return ConstrainedBox(
        constraints: const BoxConstraints(minWidth: double.infinity),
        child: Container(
          margin: const EdgeInsets.only(top: 10),
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                isListen = true;
                bottomMargin = 170;
                Navigator.of(context, rootNavigator: true).pop();
                selectedSubliminal = subliminalList;

                setupServiceLocator(subliminalList['audio_path']);

                /* AudioService.init(
                  builder: () =>
                      AudioPlayerHandler(subliminalList['audio_path']),
                  config: const AudioServiceConfig(
                    androidNotificationChannelId:
                        'com.success.subliminal.audio',
                    androidNotificationChannelName: 'Audio Service Demo',
                    androidNotificationOngoing: true,
                    androidStopForegroundOnPause: true,
                  ),
                );*/
              });

              setState(() {
                if (kDebugMode) {
                  print(subliminalList['audio_path']);
                }

                if (!SharedPrefs().isSubPlaying()) {
                  changeName("Stop Now", true);
                  SharedPrefs().setPlayingSubId(subliminalList['id']);
                  SharedPrefs()
                      .setPlayingSubImage(subliminalList['cover_path']);
                  SharedPrefs().setPlayingSubUrl(subliminalList['audio_path']);
                  SharedPrefs().setPlayingSubName(subliminalList['title']);

                  /// advancedPlayer.setSourceUrl(subliminalList['audio_path']);
                  player.setUrl(subliminalList['audio_path']);

                  isLoading = true;
                  Future.delayed(const Duration(seconds: 3))
                      .then((value) => setState(() {
                            player.play();
                            isLoading = false;
                          }));

                  if (isTrial &&
                      !isTrialUsed &&
                      subliminalList['creator_id'].toString() !=
                          SharedPrefs().getUserId().toString()) {
                    _getUsedFreeTrialData(
                        context, "true", subliminalList['id'].toString());
                  }
                } else {
                  if (SharedPrefs().getSubPlayingId() == subliminalList['id']) {
                    SharedPrefs().setPlayingSubId(subliminalList['id']);
                    SharedPrefs()
                        .setPlayingSubImage(subliminalList['cover_path']);
                    SharedPrefs()
                        .setPlayingSubUrl(subliminalList['audio_path']);

                    isLoading = false;

                    changeName("Listen Now", false);

                    player.stop();

                    subliminalList['creator_id'].toString() !=
                            SharedPrefs().getUserId().toString()
                        ? setState(() {
                            SharedPrefs().setIsFreeTrailUsed(true);
                            isTrialUsed = true;
                          })
                        : isTrialUsed;
                  } else {
                    changeName("Stop Now", true);
                    SharedPrefs().setPlayingSubId(subliminalList['id']);
                    SharedPrefs()
                        .setPlayingSubImage(subliminalList['cover_path']);
                    SharedPrefs()
                        .setPlayingSubUrl(subliminalList['audio_path']);
                    SharedPrefs().setPlayingSubName(subliminalList['title']);

                    player.setUrl(subliminalList['audio_path']);

                    isLoading = true;

                    !isTrialUsed &&
                            subliminalList['creator_id'].toString() !=
                                SharedPrefs().getUserId().toString()
                        ? setState(() {
                            SharedPrefs().setIsFreeTrailUsed(true);
                            isTrialUsed = true;
                          })
                        : Future.delayed(const Duration(seconds: 3))
                            .then((value) => setState(() {
                                  player.play();
                                  isLoading = false;
                                }));
                  }
                }
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kButtonColor1,
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
                              subliminalList['id']
                          ? !SharedPrefs().isSubPlaying()
                              ? Image.asset('assets/images/ic_play.png',
                                  scale: 1.5)
                              : Image.asset('assets/images/ic_stop.png',
                                  scale: 1.5)
                          : Image.asset('assets/images/ic_play.png',
                              scale: 1.5)),
                ),
                Text(
                    SharedPrefs().getSubPlayingId() == subliminalList['id']
                        ? buttonPlaying.toUpperCase()
                        : isTrial &&
                                !isTrialUsed &&
                                subliminalList['creator_id'].toString() !=
                                    SharedPrefs().getUserId().toString() &&
                                subliminalList['Is_free_trial'] == 0 &&
                                filter != "all"
                            ? kListenWithTrial.toUpperCase()
                            : kListenNow.toUpperCase(),
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

  Widget buildCloseButton(BuildContext context) {
    return ConstrainedBox(
        constraints: const BoxConstraints(minWidth: double.infinity),
        child: Container(
          margin: const EdgeInsets.only(top: 20),
          height: 50,
          child: ElevatedButton(
            onPressed: () async {
              // player.stop();
              Navigator.pop(context);
              /* setState(() {
                changeName("Listen Now", false);
              });*/
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
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
                    child:
                        Image.asset('assets/images/ic_close.png', scale: 1.5),
                  ),
                ),
                Text('close'.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 15,
                      fontFamily: 'DPClear',
                      fontWeight: FontWeight.w600,
                    )),
              ],
            ),
          ),
        ));
  }

  buildListItemDialogContainer(BuildContext contexts, dynamic subliminalList) {
    if (kDebugMode) {
      print(subliminalList);
    }
    return showDialog(
        context: contexts,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0)),
            backgroundColor: kDialogBgColor,
            insetPadding: const EdgeInsets.all(15),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  (subliminalList['creator_id'].toString() !=
                          SharedPrefs().getUserId())
                      ? (isTrial && !isTrialUsed) && difference < 8 ||
                              subliminalList['buyed'] ||
                              subliminalList['Is_free_trial'] == 1
                          ? buildListenButton(contexts, subliminalList)
                          : buildBuyNowButton(contexts, subliminalList)
                      : buildListenButton(contexts, subliminalList),
                  (subliminalList['creator_id'].toString() ==
                              SharedPrefs().getUserId() &&
                          filter == 'all')
                      ? buildDeleteButton(context, subliminalList)
                      : const SizedBox(),
                  SharedPrefs().getUserId() !=
                              subliminalList['creator_id'].toString() &&
                          filter == 'wishlist'
                      ? GestureDetector(
                          onTap: () => {
                            setState(() {
                              showCenterLoader(context);
                              if (subliminalList['wishlist'] == true) {
                                _getRemoveWishListData(
                                    subliminalList['id'].toString());
                              } else {
                                _getAddWishListData(
                                    subliminalList['id'].toString());
                              }
                            })
                          },
                          child: Container(
                            height: 50,
                            decoration: kTransButtonBoxDecoration,
                            margin: const EdgeInsets.only(top: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Align(
                                  alignment: Alignment.center,
                                  child: subliminalList['wishlist']
                                      ? Image.asset(
                                          'assets/images/ic_heart_empty.png',
                                          color: kTextColor,
                                          scale: 1.5)
                                      : Image.asset(
                                          'assets/images/ic_heart_empty.png',
                                          scale: 1.5),
                                ),
                                Container(
                                  alignment: Alignment.center,
                                  margin: const EdgeInsets.only(left: 10),
                                  child: Text(
                                    !subliminalList['wishlist']
                                        ? "Add to wishlist".toUpperCase()
                                        : "Remove from wishlist".toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                      fontFamily: 'DPClear',
                                      fontWeight: FontWeight.w600,
                                    ),
                                    softWrap: true,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : const SizedBox(),
                  !kIsWeb && subliminalList['buyed'] == true ||
                          filter == 'all' && !kIsWeb
                      ? buildDownloadButton(subliminalList)
                      : const SizedBox(),
                  Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(left: 10, top: 30),
                    child: Text(
                      "share".toUpperCase(),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontFamily: 'DPClear',
                        fontWeight: FontWeight.w600,
                      ),
                      softWrap: true,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        GestureDetector(
                          onTap: () => {
                            toast("Copied", false),
                            Clipboard.setData(ClipboardData(
                                text:
                                    "${sharingContent1}https://successsubliminals.net/start-trial?subliminal_id=${subliminalList['id']}$sharingContent"))
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 10),
                            height: 60,
                            width: 60,
                            decoration: kTransButtonBoxDecoration,
                            alignment: Alignment.topRight,
                            child: Align(
                              alignment: Alignment.center,
                              child: Image.asset(
                                  'assets/images/ic_attachment.png',
                                  scale: 1.5),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => {
                            setState(() {
                              if (kIsWeb) {
                                String url =
                                    "https://successsubliminals.net/start-trial?subliminal_id=${subliminalList['id']}"; //subliminalList['audio_path'];
                                String title =
                                    "${sharingContent1}https://successsubliminals.net/start-trial?subliminal_id=${subliminalList['id']}$sharingContent"; //subliminalList['title'];

                                /* String url = subliminalList['audio_path'];
                                String title = subliminalList['title'];*/
                                launchFacebookURL(url, title);
                              } else {
                                String url =
                                    "https://successsubliminals.net/start-trial?subliminal_id=${subliminalList['id']}"; //subliminalList['audio_path'];
                                String title =
                                    "${sharingContent1}https://successsubliminals.net/start-trial?subliminal_id=${subliminalList['id']}$sharingContent2"; //subliminalList['title'];

                                /* FlutterShareMe()
                                    .shareToFacebook(url: "", msg: title);*/

                                FlutterShareMe()
                                    .shareToFacebook(url: url, msg: title);
                              }
                            })
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 10),
                            height: 60,
                            width: 60,
                            decoration: kTransButtonBoxDecoration,
                            alignment: Alignment.topRight,
                            child: Align(
                              alignment: Alignment.center,
                              child: Image.asset('assets/images/ic_fb.png',
                                  scale: 1.5),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => {
                            setState(() {
                              if (kIsWeb) {
                                String url =
                                    "https://successsubliminals.net/start-trial?subliminal_id=${subliminalList['id']}"; //subliminalList['audio_path'];
                                String title =
                                    "${sharingContent1}https://successsubliminals.net/start-trial?subliminal_id=${subliminalList['id']}$sharingContent2"; //subliminalList['title'];

                                /* String url = subliminalList['audio_path'];
                                String title = subliminalList['title'];*/
                                launchTwitterURL('', title);
                              } else {
                                String url =
                                    "https://successsubliminals.net/start-trial?subliminal_id=${subliminalList['id']}"; //subliminalList['audio_path'];
                                String title =
                                    "${sharingContent1}https://successsubliminals.net/start-trial?subliminal_id=${subliminalList['id']}$sharingContent2"; //subliminalList['title'];

                                FlutterShareMe().shareToSystem(msg: title);
                              }
                            })
                          },
                          child: Container(
                            height: 60,
                            width: 60,
                            decoration: kTransButtonBoxDecoration,
                            alignment: Alignment.topRight,
                            child: Align(
                              alignment: Alignment.center,
                              child: Image.asset('assets/images/ic_twitter.png',
                                  scale: 1.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  buildCloseButton(context)
                ],
              ),
            ),
          );
        });
  }

  Widget buildDeleteButton(BuildContext context, dynamic subliminalList) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      child: ButtonWidget(
        name: "Delete Subliminal",
        icon: "assets/images/ic_delete_white.png",
        visibility: true,
        padding: 20,
        onTap: () => {
          showCenterLoader(context),
          _getDeleteSubliminalListData(subliminalList['id'].toString())
        },
        size: 14,
        scale: 7,
        height: 50,
      ),
    );
  }

  Future<void> _requestPermission() async {
    final status = await Permission.storage.request();
    await Permission.manageExternalStorage.request();
    setState(() {
      granted = status.isGranted;
    });
  }

  Future<void> permission() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.manageExternalStorage,
      Permission.storage,
    ].request();

    permissionGranted();
  }

  Future<void> permissionGranted() async {
    final status = await Permission.storage.status;

    setState(() {
      granted = status.isGranted;
    });
  }

  Future<void> getDeviceInfo() async {
    if (Platform.isAndroid) {
      var deviceData =
          _readAndroidBuildData(await deviceInfoPlugin.androidInfo);

      setState(() {
        _deviceData = deviceData;
      });

      if (kDebugMode) {
        print(_deviceData["version.release"]);
      }
      if (int.parse(_deviceData["version.release"]) > 12) {
        getPath(13);
      } else {
        getPath(12);
      }
    } else {
      getPath(13);
    }
  }

  Future<void> getPath(int version) async {
    var downloadPath = await getDownloadPath(version);
    setState(() {
      path = downloadPath;
    });
  }

  Widget buildDownloadButton(dynamic subliminalList) {
    return GestureDetector(
      onTap: () => {
        setState(() {
          permission();
          _requestPermission();
          getDeviceInfo();
          permissionGranted();

          if (Platform.isAndroid) {
            if (kDebugMode) {
              print(_deviceData["version.release"]);
              print(_deviceData);
            }

            if (int.parse(_deviceData["version.release"]) > 12) {
              showProgressCenterLoader(
                context,
              );

              downloadFile1(
                subliminalList['audio_path'],
                '${subliminalList['title'].toString().trim().replaceAll(" ", "-")}${"_"}${subliminalList['id'].toString().trim()}.wav',
                path ?? "",
              );
            } else {
              permissionGranted();
              if (granted != null) {
                if (granted!) {
                  showProgressCenterLoader(
                    context,
                  );

                  downloadFile1(
                    subliminalList['audio_path'],
                    '${subliminalList['title'].toString().trim().replaceAll(" ", "-")}${"_"}${subliminalList['id'].toString().trim()}.wav',
                    path!,
                  );
                } else {
                  toast("Permission not granted", false);
                }
              } else {
                toast("Permission not granted", false);
              }
            }
          } else {
            showProgressCenterLoader(
              context,
            );

            downloadFile1(
              subliminalList['audio_path'],
              '${subliminalList['title'].toString().trim().replaceAll(" ", "-")}${"_"}${subliminalList['id'].toString().trim()}.wav',
              path!,
            );
          }
        })
      },
      child: Container(
        height: 50,
        decoration: kTransButtonBoxDecoration,
        alignment: Alignment.topRight,
        margin: const EdgeInsets.only(top: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(left: 10),
              child: Align(
                alignment: Alignment.center,
                child: Image.asset('assets/images/ic_download.png', scale: 2),
              ),
            ),
            Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.only(left: 10, right: 10),
              child: Text(
                "download".toUpperCase(),
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontFamily: 'DPClear',
                  fontWeight: FontWeight.w500,
                ),
                softWrap: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  showProgressCenterLoader(
    BuildContext context,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            _setState = setState;
            return Container(
                margin: const EdgeInsets.all(10),
                decoration: kTransButtonBoxDecoration,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    /* Container(
                      margin: const EdgeInsets.only(bottom: 40, right: 25),
                      alignment: Alignment.topRight,
                      child: GestureDetector(
                        onTap: () =>
                            {Navigator.of(context, rootNavigator: true).pop()},
                        child: Align(
                          alignment: Alignment.topRight,
                          child: Image.asset(
                            'assets/images/ic_close_bg.png',
                            scale: 5,
                          ),
                        ),
                      ),
                    ),*/
                    const SpinKitDualRing(
                      color: kBaseLightColor,
                      size: 50.0,
                    ),
                    const SizedBox(height: 16),
                    DefaultTextStyle(
                      style: const TextStyle(
                          fontSize: 16,
                          color: Colors.blueAccent,
                          fontFamily: 'DPClear'),
                      child: Text(_downloadMessage),
                    )
                  ],
                ));
          },
        );
      },
    );
  }

  Widget buildPlayerBottomContainer(BuildContext context, dynamic subliminal) {
    return Positioned(
        bottom: 0,
        width: MediaQuery.of(context).size.width,
        child: GestureDetector(
            onTap: () => {
                  setState(() {
                    /*  if (isFlag) {*/
                    var cover = "";
                    if (subliminal['cover_path'] != "") {
                      cover = subliminal['cover_path'];
                    }
                    _showBottomDialog(context, subliminal['title'],
                        subliminal['audio_path'], cover, subliminal['id']);
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
                              child: subliminal['cover_path'] != ""
                                  ? Image.network(
                                      subliminal['cover_path'],
                                      fit: BoxFit.contain,
                                      loadingBuilder: (BuildContext context,
                                          Widget child,
                                          ImageChunkEvent? loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child;
                                        }
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
                                subliminal['title'],
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontFamily: 'DPClear',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(top: 5),
                                child: Text(
                                  subliminal['description'],
                                  maxLines: 2,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
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
                        child: Container(
                            alignment: Alignment.center,
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
                                          'assets/images/ic_play_button_white.png',
                                          color: Colors.white,
                                          scale: 15,
                                        )
                                      : Image.asset(
                                          'assets/images/ic_pause_white.png',
                                          color: Colors.white,
                                          scale: 14,
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

  Future<void> createDirectoryInDownloads(int version) async {
    if (Platform.isIOS) {
      Directory? directory =
          Directory((await getApplicationDocumentsDirectory()).path);
      String newPath = '${directory.path}/u-${SharedPrefs().getUserId()}';
      Directory(newPath).createSync();
    } else {
      if (version == 13) {
        Directory? directory =
            Directory((await getExternalStorageDirectory())!.path);
        String newPath = '${directory.path}/u-${SharedPrefs().getUserId()}';
        Directory(newPath).createSync();
      } else {
        Directory? directory = Directory('/storage/emulated/0/Download');
        String newPath =
            '${directory.path}/SuccessSubliminal/u-${SharedPrefs().getUserId()}';
        Directory(newPath).createSync();
      }
    }
  }

  Future<String?> getDownloadPath(int version) async {
    Directory? directory;
    try {
      if (Platform.isIOS) {
        directory = Directory(
            "${(await getApplicationDocumentsDirectory()).path}/u-${SharedPrefs().getUserId()}");
        if (!await directory.exists()) {
          createDirectoryInDownloads(version);
        }
      } else {
        if (version == 13) {
          directory = Directory(
              "${(await getExternalStorageDirectory())!.path}/u-${SharedPrefs().getUserId()}");
          if (!await directory.exists()) {
            createDirectoryInDownloads(version);
          }
        } else {
          directory = Directory(
              '/storage/emulated/0/Download/SuccessSubliminal/u-${SharedPrefs().getUserId()}');
          if (!await directory.exists()) {
            createDirectoryInDownloads(version);
          }
        }
      }
      if (kDebugMode) {
        print(directory.path);
      }
    } catch (err, stack) {
      if (kDebugMode) {
        print("Cannot get download folder path--$err");
      }
    }
    return directory!.path;
  }

  Future<String> downloadFile(String url, String fileName, String dir) async {
    HttpClient httpClient = HttpClient();
    File file;
    String filePath = '';

    try {
      var request = await httpClient.getUrl(Uri.parse(url));
      var response = await request.close();

      if (response.statusCode == 200) {
        var bytes = await consolidateHttpClientResponseBytes(response);

        filePath = '$dir/$fileName';
        file = File(filePath);
        toast("File Downloaded in Download Directory", false);
        await file.writeAsBytes(bytes);
      } else {
        filePath = 'Error code: ${response.statusCode}';
        toast("File Not Downloaded", true);
      }
    } catch (ex) {
      filePath = 'Can not fetch url';
    }
    setState(() {
      Navigator.of(context, rootNavigator: true).pop();
      Navigator.of(context, rootNavigator: true).pop();
    });

    return filePath;
  }

  Future<String> downloadFile1(String url, String fileName, String dir) async {
    HttpClient httpClient = HttpClient();
    File file;
    String filePath = '';

    var request = await httpClient.getUrl(Uri.parse(url));
    var response = await request.close();

    if (response.statusCode == 200) {
      var contentLength = response.contentLength;
      var bytesReceived = 0;
      var progress = 0.0;
      var startTime = DateTime.now();

      var bytes = <int>[];

      response.listen((List<int> newBytes) {
        bytes.addAll(newBytes);
        bytesReceived += newBytes.length;
        progress = bytesReceived / contentLength;
        if (kDebugMode) {
          print('Download progress: ${(progress * 100).toStringAsFixed(2)}%');
        }

        // Calculate the time left
        var currentTime = DateTime.now();
        var elapsedTime = currentTime.difference(startTime).inSeconds;
        var timeLeft = ((elapsedTime / progress) - elapsedTime).toInt();
        _setState(() {
          _downloadMessage =
              ('Download progress: ${(progress * 100).toStringAsFixed(2)}%\nTime left: ${formatTimeLeft(timeLeft)}');
        });
        if (kDebugMode) {
          print('Time left: ${formatTimeLeft(timeLeft)}');
          print('_downloadMessage: $_downloadMessage');
        }
      }, onDone: () async {
        httpClient.close();

        filePath = '$dir/$fileName';
        file = File(filePath);
        await file.writeAsBytes(bytes);
        toast("File Downloaded in Download Directory", false);
        setState(() {
          Navigator.of(context, rootNavigator: true).pop();
          Navigator.of(context, rootNavigator: true).pop();
        });
      });
    } else {
      filePath = 'Error code: ${response.statusCode}';
      toast("File Not Downloaded", true);
      setState(() {
        Navigator.of(context, rootNavigator: true).pop();
        Navigator.of(context, rootNavigator: true).pop();
      });
    }

    return filePath;
  }

  String formatTimeLeft(int seconds) {
    var duration = Duration(seconds: seconds);
    var hours = duration.inHours;
    var minutes = duration.inMinutes.remainder(60);
    var formattedTime = '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}';
    return formattedTime;
  }

  void _navigateToDownloadedController() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (c, a1, a2) => const DownloadedSubPage(),
        transitionsBuilder: (c, anim, a2, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
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
              isLocal: false),
        ]);
      },
    );
  }

  Future<void> clearApplicationDirectory() async {
    Directory appDir = await getApplicationSupportDirectory();
    List<FileSystemEntity> files = appDir.listSync();
    for (FileSystemEntity file in files) {
      file.deleteSync(recursive: true);
      print("deleted");
    }
  }
}
