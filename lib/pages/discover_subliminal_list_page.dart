import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:go_router/go_router.dart';
import 'package:readmore/readmore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:success_subliminal/pages/web_pages/discover_subliminal_list_web_page.dart';

import '../data/api/ApiService.dart';
import '../utils/AudioPlayerHandler.dart';
import '../utils/constant.dart';
import '../utils/service_locator.dart';
import '../utils/shared_prefs.dart';
import '../widget/BottomBarStateFullWidget.dart';
import 'audio_player_page.dart';
import 'discover_subliminal_detail_page.dart';

class DiscoverCategoryListPage extends StatefulWidget {
  final String categoryName;
  final String categoryId;

  const DiscoverCategoryListPage(
      {Key? key, required this.categoryName, required this.categoryId})
      : super(key: key);

  @override
  _DiscoverCategoryListPage createState() => _DiscoverCategoryListPage();
}

class _DiscoverCategoryListPage extends State<DiscoverCategoryListPage>
    with WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late List<dynamic> subliminalList = [];
  var refreshKey = GlobalKey<RefreshIndicatorState>();
  late dynamic subliminal;
  bool isLoading = false;
  bool isSubliminal = false;
  bool isPlaying = false;
  bool isTrial = false;
  bool isListen = false;
  double bottomMargin = 80;
  double imageWidthSize = 150;
  double titleSize = 22;
  double descriptionSize = 18;
  int imageFlex = 1;
  int descriptionFlex = 3;
  dynamic selectedSubliminal;
  var playerStatus = "stop";
  bool isPrepare = false;
  final AudioPlayerHandler _audioHandler = AudioPlayerHandler("");
  bool isTrialUsed = false;
  late dynamic usedFreeTrial;
  int difference = 0;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      if (subliminalList.isNotEmpty) {
        for (int i = 0; i < subliminalList.length; i++) {
          if (SharedPrefs().getSubPlayingId() == subliminalList[i]['id']) {
            selectedSubliminal = subliminalList[i];
          }
        }
      }
      if (kDebugMode) {
        print('App resumed');
      }
    }
  }

  @override
  initState() {
    super.initState();
    initializePreference().whenComplete(() {
      setState(() {
        _startPlaybackStateListener();
        _getSubliminalListData(widget.categoryId);

        setState(() {
          isTrial = SharedPrefs().isFreeTrail();
          isTrialUsed = SharedPrefs().isFreeTrailUsed();
        });
        if (kDebugMode) {
          print("isTrial---$isTrial");
          print("isTrialUsed---$isTrialUsed");
        }

        SharedPrefs().isSubPlaying() ? isListen = true : isListen = false;
        SharedPrefs().isSubPlaying() ? bottomMargin = 170 : bottomMargin = 80;

        if (!SharedPrefs().isSubPlaying()) {
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

    difference = dateTime
        .difference(pickedDate)
        .inDays;
  }

  void _getUsedFreeTrialData(BuildContext context, String status,
      String id) async {
    usedFreeTrial = await ApiService().getFreeTrialUsed(context, status, id);

    Future.delayed(const Duration(seconds: 1)).then((value) =>
        setState(() {
          setState(() {
            if (usedFreeTrial['http_code'] != 200) {} else {
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

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    // player.dispose();
  }

  void _startPlaybackStateListener() {
    _audioHandler.playbackState.listen((state) {
      bool isPlaying = state.playing;
      if (kDebugMode) {
        print(isPlaying.toString());
      }
      setState(() {
        if (isPlaying) {
          changeName(kStopNow, true);
        } else {
          changeName(kListenNow, false);
        }
      });
    });
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

  void _getSubliminalListData(String categoryId) async {
    subliminal =
    await ApiService().getLoginDiscoverSubliminalList(context, categoryId);

    Future.delayed(const Duration(seconds: 2))
        .then((value) =>
        setState(() async {
          setState(() {
            setState(() {
              isSubliminal = true;
            });

            if (subliminal['http_code'] != 200) {} else {
              setState(() {
                subliminalList.clear();
                subliminalList.addAll(subliminal['data']['subliminals']);
              });

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
                    setState(() {
                      selectedSubliminal = subliminalList[i];
                    });

                    isFlag = true;
                    break;
                  }
                }
                isFlag ? isListen = true : isListen = false;
                isListen
                    ? SharedPrefs().isSubPlaying()
                    ? bottomMargin = 170
                    : bottomMargin = 80
                    : bottomMargin = 80;
              }
            }
            if (kDebugMode) {
              print("size ----${subliminalList.length}");
            }
          });
        }));
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery
        .of(context)
        .size;
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(0),
          child: AppBar(
            flexibleSpace: Container(
              decoration: const BoxDecoration(gradient: statusBarGradient),
            ),
          ),
        ),
        body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            if (constraints.maxWidth < 757) {
              if (constraints.maxWidth < 300) {
                imageFlex = 1;
                descriptionFlex = 3;
                imageWidthSize = 100;
                titleSize = 16;
                descriptionSize = 12;
              } else if (constraints.maxWidth < 400) {
                imageFlex = 1;
                descriptionFlex = 3;
                imageWidthSize = 100;
                titleSize = 16;
                descriptionSize = 12;
              } else if (constraints.maxWidth < 500) {
                imageFlex = 1;
                descriptionFlex = 3;
                imageWidthSize = 100;
                titleSize = 16;
                descriptionSize = 14;
              } else if (constraints.maxWidth < 600) {
                imageFlex = 2;
                descriptionFlex = 5;
                imageWidthSize = 100;
                titleSize = 18;
                descriptionSize = 16;
              } else if (constraints.maxWidth < 700) {
                imageFlex = 3;
                descriptionFlex = 5;
                imageWidthSize = 110;
                titleSize = 20;
                descriptionSize = 18;
              } else if (constraints.maxWidth < 760) {
                imageFlex = 3;
                descriptionFlex = 5;
                imageWidthSize = 130;
                titleSize = 22;
                descriptionSize = 20;
              }

              return buildHomeContainer(context, mq);
            } else {
              return DiscoverCategoryWebListPage(
                categoryName: widget.categoryName,
                categoryId: widget.categoryId,
                subname: '',
              );
            }
          },
        ));
  }

  Widget buildHomeContainer(BuildContext context, Size mq) {
    return RefreshIndicator(
      key: refreshKey,
      color: Colors.white,
      onRefresh: () async {
        setState(() {
          _startPlaybackStateListener();
          _getSubliminalListData(widget.categoryId);
          setState(() {
            isTrial = SharedPrefs().isFreeTrail();
            isTrialUsed = SharedPrefs().isFreeTrailUsed();
          });
          SharedPrefs().isSubPlaying() ? isListen = true : isListen = false;
          SharedPrefs().isSubPlaying() ? bottomMargin = 170 : bottomMargin = 80;

          if (!SharedPrefs().isSubPlaying()) {
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
      },
      child: SafeArea(
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
            children: [
              /* Image.asset(
                'assets/images/ic_bg_dark_blue.png',
                fit: BoxFit.cover,
                height: double.infinity,
                width: double.infinity,
                alignment: Alignment.center,
              ),*/
              buildTopBarContainer(context, mq),
              const BottomBarStateFull(screen: "discover", isUserLogin: true),
              selectedSubliminal != null
                  ? Visibility(
                  visible: isListen,
                  child: buildPlayerBottomContainer(
                      context, selectedSubliminal))
                  : const Text(""),
              Container(
                padding: EdgeInsets.only(bottom: bottomMargin),
                margin: const EdgeInsets.only(top: 100),
                child: ListView(
                  shrinkWrap: false,
                  primary: true,
                  children: [
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
    );
  }

  Widget buildSubliminalListContainer(BuildContext context, Size mq) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          margin: const EdgeInsets.only(left: 5, right: 5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              (subliminalList.isNotEmpty)
                  ? ListView.builder(
                  reverse: false,
                  shrinkWrap: true,
                  primary: false,
                  itemCount: subliminalList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return buildListItemContainer(
                      context,
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
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        InkWell(
          onTap: () =>
          {
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
            padding: const EdgeInsets.only(left: 15, top: 10),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                widget.categoryName,
                maxLines: 2,
                style: const TextStyle(
                    fontSize: 32,
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

  Widget buildListItemContainer(BuildContext context, String buttonName,
      bool isWish, dynamic subliminalList) {
    return GestureDetector(
        onTap: () =>
        {
          setState(() {
            _navigateToSubDetailScreen(context, subliminalList['title'],
                subliminalList['id'].toString());
          }),
        },
        child: Container(
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
                  Expanded(
                    flex: imageFlex,
                    child: SizedBox(
                        width: imageWidthSize,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15.0),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: subliminalList['cover_path'] != ""
                                ? Image.network(
                              subliminalList['cover_path'],
                              fit: BoxFit.fill,
                              loadingBuilder: (BuildContext context,
                                  Widget child,
                                  ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) return child;
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
                            ),
                          ),
                        )),
                  ),
                  Expanded(
                    flex: descriptionFlex,
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
                                  style: TextStyle(
                                    fontSize: titleSize,
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
                                  child: ReadMoreText(
                                      subliminalList['description'],
                                      trimLines: 4,
                                      colorClickableText: Colors.red,
                                      trimMode: TrimMode.Line,
                                      trimCollapsedText: 'Show more',
                                      trimExpandedText: '  Show less',
                                      moreStyle: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.white,
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w600),
                                      style: TextStyle(
                                        fontSize: descriptionSize,
                                        color: Colors.white54,
                                        fontFamily: 'DPClear',
                                        fontWeight: FontWeight.w400,
                                      ))),
                            ),
                          )
                        ]),
                  ),
                ],
              ),
              Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: imageFlex,
                      child: Container(
                        height: 50,
                        alignment: Alignment.center,
                        margin: const EdgeInsets.only(top: 10),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text('\$${subliminalList['price']}',
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                                fontFamily: 'DPClear',
                                fontWeight: FontWeight.w600,
                              )),
                        ),
                      ),
                    ),
                    Expanded(
                        flex: descriptionFlex,
                        child: isTrial && !isTrialUsed && difference < 8 ||
                            subliminalList['buyed'] ||
                            subliminalList['Is_free_trial'] == 1 ||
                            SharedPrefs().getSubPlayingId() ==
                                subliminalList['id']
                            ? buildListenButton(context, subliminalList)
                            : buildBuyNowButton(context, subliminalList)),
                  ]),
            ],
          ),
        ));
  }

  Widget buildListenButton(BuildContext context, dynamic subliminalList) {
    return ConstrainedBox(
        constraints: const BoxConstraints(minWidth: double.infinity),
        child: Container(
          decoration: kButtonBox10Decoration,
          margin: const EdgeInsets.only(top: 10, left: 15),
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                isListen = true;
                bottomMargin = 170;
                selectedSubliminal = subliminalList;
                // setupServiceLocator(subliminalList['audio_path']);

                if (!SharedPrefs().isSubPlaying() &&
                    SharedPrefs().getSubPlayingId() != subliminalList['id']) {
                  setupServiceLocator(subliminalList['audio_path']);
                  /*
                  AudioService.init(
                    builder: () =>
                        AudioPlayerHandler(subliminalList['audio_path']),
                    config: const AudioServiceConfig(
                      androidNotificationChannelId:
                          'com.success.subliminal.audio',
                      androidNotificationChannelName: 'Audio Service Demo',
                    ),
                  );*/
                }
              });

              setState(() {
                if (kDebugMode) {
                  print(subliminalList['audio_path']);
                }
                if (!SharedPrefs().isSubPlaying()) {
                  changeName(kStopNow, true);
                  SharedPrefs().setPlayingSubId(subliminalList['id']);
                  SharedPrefs()
                      .setPlayingSubImage(subliminalList['cover_path']);
                  SharedPrefs().setPlayingSubUrl(subliminalList['audio_path']);
                  SharedPrefs().setPlayingSubName(subliminalList['title']);
                  player.setUrl(subliminalList['audio_path']);
                  player.play();
                  //isLoading = true;

                  if (isTrial && !isTrialUsed) {
                    _getUsedFreeTrialData(
                        context, "true", subliminalList['id'].toString());
                  }

                  Future.delayed(const Duration(seconds: 5))
                      .then((value) =>
                      setState(() {
                        isLoading = false;
                      }));
                } else {
                  if (SharedPrefs().getSubPlayingId() == subliminalList['id']) {
                    SharedPrefs().setPlayingSubId(subliminalList['id']);
                    SharedPrefs()
                        .setPlayingSubImage(subliminalList['cover_path']);
                    SharedPrefs()
                        .setPlayingSubUrl(subliminalList['audio_path']);

                    isLoading = false;
                    changeName(kListenNow, false);
                    player.stop();

                    setState(() {
                      SharedPrefs().setIsFreeTrailUsed(true);
                      isTrialUsed = true;
                    });
                  } else {
                    //player.stop();
                    changeName(kStopNow, true);
                    SharedPrefs().setPlayingSubId(subliminalList['id']);
                    SharedPrefs()
                        .setPlayingSubImage(subliminalList['cover_path']);
                    SharedPrefs()
                        .setPlayingSubUrl(subliminalList['audio_path']);
                    SharedPrefs().setPlayingSubName(subliminalList['title']);

                    player.setUrl(subliminalList['audio_path']);
                    player.play();
                    isLoading = true;
                    Future.delayed(const Duration(seconds: 5))
                        .then((value) =>
                        setState(() {
                          isLoading = false;
                        }));
                  }
                }
              });
            },
            style: ElevatedButton.styleFrom(
              primary: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 3),
                  child: Align(
                    alignment: Alignment.center,
                    child: SharedPrefs().getSubPlayingId() ==
                        subliminalList['id']
                        ? !SharedPrefs().isSubPlaying()
                        ? Image.asset('assets/images/ic_play.png',
                        scale: 1.5)
                        : Image.asset('assets/images/ic_stop.png',
                        scale: 1.5)
                        : Image.asset('assets/images/ic_play.png', scale: 1.5),
                  ),
                ),
                Text(
                    SharedPrefs().getSubPlayingId() == subliminalList['id']
                        ? buttonPlaying.toUpperCase()
                        : isTrial && !isTrialUsed
                        ? kListenWithTrial.toUpperCase()
                        : kListenNow.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'DPClear',
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    )),
              ],
            ),
          ),
        ));
  }

  Widget buildDownloadButton(dynamic subliminalList) {
    return GestureDetector(
      onTap: () =>
      {
        setState(() async {
          final taskId = await FlutterDownloader.enqueue(
            url: subliminalList['audio_path'],
            savedDir:
            'the path of directory where you want to save downloaded files',
            showNotification: true,
            openFileFromNotification: true,
          );
        })
      },
      child: Container(
        height: 50,
        decoration: kTransButtonBoxDecoration,
        alignment: Alignment.topRight,
        margin: const EdgeInsets.only(left: 10, right: 2, top: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(left: 10),
              child: Align(
                alignment: Alignment.center,
                child: Image.asset('assets/images/ic_download.png', scale: 1.5),
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

  Widget buildBuyNowButton(BuildContext context, dynamic subliminalList) {
    return ConstrainedBox(
        constraints: const BoxConstraints(minWidth: double.infinity),
        child: Container(
          decoration: kButtonBox10Decoration,
          margin: const EdgeInsets.only(top: 10, left: 15),
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              context.pushNamed('buy-subliminals', queryParameters: {
                'subId': subliminalList['id'].toString(),
                "subName": subliminalList['title'],
                "catId": widget.categoryId,
                "catName": widget.categoryName,
                "amount": subliminalList['price'].toString(),
                "screen": 'list'
              });

              /* _navigateToBuySubliminalScreen(
                  context,
                  subliminalList['price'].toString(),
                  subliminalList['id'].toString(),
                  subliminalList['title'],
                  widget.categoryId,
                  widget.categoryName);*/
            },
            style: ElevatedButton.styleFrom(
              primary: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15), // <-- Radius
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 3),
                  child: Align(
                    alignment: Alignment.center,
                    child: Image.asset('assets/images/ic_bag_tick.png',
                        scale: 1.5),
                  ),
                ),
                Text('buy now'.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.white,
                      fontFamily: 'DPClear',
                      fontWeight: FontWeight.w600,
                    )),
              ],
            ),
          ),
        ));
  }

  void _navigateToSubDetailScreen(BuildContext context, String name,
      String id) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (c, a1, a2) =>
            DiscoverSubliminalDetailPage(subName: name, subId: id),
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

  void playerStateListener() {
    player.durationStream.listen((s) => setState(() {}));
  }

  void playerStatePositionListener() {
    player.positionStream.listen((s) => setState(() {}));
  }

  Widget buildPlayerBottomContainer(BuildContext context, dynamic subliminal) {
    return Positioned(
        bottom: 0,
        width: MediaQuery
            .of(context)
            .size
            .width,
        child: GestureDetector(
            onTap: () =>
            {
              setState(() {
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
                              onTap: () =>
                              {
                                setState(() {
                                  if (!SharedPrefs().isSubPlaying()) {
                                    player.play();
                                    changeName(kStopNow, true);
                                  } else {
                                    player.pause();
                                    changeName(kListenNow, false);
                                  }
                                }),
                              },
                              child: !isLoading
                                  ? !SharedPrefs().isSubPlaying()
                                  ? Image.asset(
                                'assets/images/ic_play_button_white.png',
                                scale: 15,
                              )
                                  : Image.asset(
                                'assets/images/ic_pause_white.png',
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


}
