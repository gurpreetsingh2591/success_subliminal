import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/api/ApiService.dart';
import '../../utils/center_loader.dart';
import '../../utils/constant.dart';
import '../../utils/shared_prefs.dart';
import '../utils/AudioPlayerHandler.dart';
import '../utils/service_locator.dart';
import '../widget/BottomBarStateFullWidget.dart';
import '../widget/TextFieldWidget400.dart';
import '../widget/TextFieldWidget500.dart';
import 'audio_player_page.dart';

class DiscoverSubliminalDetailPage extends StatefulWidget {
  final String subName;
  final String subId;

  const DiscoverSubliminalDetailPage(
      {Key? key, required this.subName, required this.subId})
      : super(key: key);

  @override
  DiscoverSubliminalDetailScreen createState() =>
      DiscoverSubliminalDetailScreen();
}

class DiscoverSubliminalDetailScreen
    extends State<DiscoverSubliminalDetailPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late dynamic subliminalDetail;
  late dynamic subliminalDataDetail;
  bool isLoading = false;
  bool isSubliminal = false;
  late dynamic subliminal;
  bool isTrial = false;
  bool isActive = false;

  bool isListen = false;
  double bottomMargin = 80;
  dynamic selectedSubliminal;
  var playerStatus = "stop";
  bool isPrepare = false;
  final AudioPlayerHandler _audioHandler = AudioPlayerHandler("");
  bool isTrialUsed = false;
  late dynamic usedFreeTrial;
  int difference = 0;

  @override
  void initState() {
    super.initState();
    _getSubliminalDetailData(widget.subId);
    _startPlaybackStateListener();

    initializePreference().whenComplete(() {
      SharedPrefs().isSubPlaying() ? isListen = true : isListen = false;
      SharedPrefs().isSubPlaying() ? bottomMargin = 170 : bottomMargin = 80;
      isTrial = SharedPrefs().isFreeTrail();
      isActive = SharedPrefs().isSubscription();
      isTrialUsed = SharedPrefs().isFreeTrailUsed();
      setState(() {
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
    int difference = 0;
    DateTime dateTime = DateTime.now();
    DateTime pickedDate = DateTime.parse(SharedPrefs().getTrialStartDate()!);

    difference = dateTime.difference(pickedDate).inDays;
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

  void changeName(String name, bool isPlay) {
    setState(() {
      buttonPlaying = name;
      SharedPrefs().setIsSubPlaying(isPlay);
    });
  }

  void _startPlaybackStateListener() {
    _audioHandler.playbackState.listen((state) {
      bool isPlaying = state.playing;

      print(isPlaying.toString());
      setState(() {
        if (isPlaying) {
          changeName(kStopNow, true);
        } else {
          changeName(kListenNow, false);
        }
      });
    });
  }

  void _getAddWishListData(String subId) async {
    subliminal = await ApiService().getAddWishlist(subId, context);

    Future.delayed(const Duration(seconds: 2))
        .then((value) => setState(() async {
              setState(() {
                if (subliminal['http_code'] != 200) {
                } else {
                  _getSubliminalDetailData(widget.subId);
                }
                Future.delayed(const Duration(seconds: 3))
                    .then((value) => setState(() async {
                          setState(() {
                            Navigator.of(context, rootNavigator: true).pop();
                          });
                        }));
              });
            }));
  }

  void _getRemoveWishListData(String subId) async {
    subliminal = await ApiService().getRemoveWishlist(subId, context);

    Future.delayed(const Duration(seconds: 2))
        .then((value) => setState(() async {
              setState(() {
                if (subliminal['http_code'] != 200) {
                } else {
                  _getSubliminalDetailData(widget.subId);
                }
                Future.delayed(const Duration(seconds: 3))
                    .then((value) => setState(() async {
                          setState(() {
                            Navigator.of(context, rootNavigator: true).pop();
                          });
                        }));
              });
            }));
  }

  Future<void> initializePreference() async {
    SharedPrefs.init(await SharedPreferences.getInstance());
  }

  void _getSubliminalDetailData(String id) async {
    subliminalDetail = await ApiService().getSubliminalDetail(context, id);

    Future.delayed(const Duration(seconds: 2))
        .then((value) => setState(() async {
              setState(() {
                if (subliminalDetail['http_code'] != 200) {
                } else {
                  isSubliminal = true;
                  subliminalDataDetail = subliminalDetail['data'];
                  bool isFlag = false;
                  if (!SharedPrefs().isSubPlaying()) {
                    selectedSubliminal = subliminalDataDetail['subliminal'];
                    isListen = false;
                    isListen
                        ? SharedPrefs().isSubPlaying()
                            ? bottomMargin = 170
                            : bottomMargin = 80
                        : bottomMargin = 80;
                  } else {
                    if (SharedPrefs().getSubPlayingId() ==
                        subliminalDataDetail['subliminal']['id']) {
                      selectedSubliminal = subliminalDataDetail['subliminal'];
                      isFlag = true;
                    }
                    isFlag ? isListen = true : isListen = false;
                    isListen
                        ? SharedPrefs().isSubPlaying()
                            ? bottomMargin = 170
                            : bottomMargin = 80
                        : bottomMargin = 80;
                  }
                }
                print("size ----${subliminalDataDetail.toString()}");
                print(
                    "wishlist ----${subliminalDataDetail['subliminal']['wishlist']}");
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
              const BottomBarStateFull(screen: "discover", isUserLogin: true),
              selectedSubliminal != null
                  ? Visibility(
                      visible: isListen,
                      child: buildPlayerBottomContainer(
                          context, selectedSubliminal))
                  : const Text(""),
              Container(
                margin: EdgeInsets.only(bottom: bottomMargin, top: 80),
                child: ListView(
                  shrinkWrap: false,
                  primary: false,
                  children: [
                    isSubliminal
                        ? buildSubliminalDetailContainer(context, mq)
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

  Widget buildSubliminalDetailContainer(BuildContext context, Size mq) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            decoration: kEditTextDecoration,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: Align(
                alignment: Alignment.center,
                child: subliminalDataDetail['subliminal']['cover_path'] != ""
                    ? Image.network(
                        subliminalDataDetail['subliminal']['cover_path'],
                        fit: BoxFit.fitWidth,
                      )
                    : Image.asset('assets/images/img_dummy_2.png', scale: 1.5),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(left: 5, top: 25),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                subliminalDataDetail['subliminal']['title'],
                style: const TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontFamily: 'DPClear',
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(left: 5, top: 10),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                subliminalDataDetail['subliminal']['description'],
                style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white54,
                    fontFamily: 'DPClear',
                    fontWeight: FontWeight.w400),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(left: 5, top: 25),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                '\$${subliminalDataDetail['subliminal']['price']}',
                style: const TextStyle(
                    fontSize: 32,
                    color: Colors.white,
                    fontFamily: 'DPClear',
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
          Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: GestureDetector(
                    onTap: () => {
                      setState(() {
                        if (subliminalDataDetail['subliminal']['wishlist']) {
                          showCenterLoader(context);
                          _getRemoveWishListData(
                              subliminalDataDetail['subliminal']['id']
                                  .toString());
                        } else {
                          _callAddWishListApi(
                              context,
                              subliminalDataDetail['subliminal']['id']
                                  .toString());
                        }
                      })
                    },
                    child: Container(
                      height: 50,
                      decoration: kTransButtonBoxDecoration,
                      margin: const EdgeInsets.only(top: 15),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            margin: const EdgeInsets.only(left: 10),
                            child: Align(
                              alignment: Alignment.center,
                              child: !subliminalDataDetail['subliminal']
                                      ['wishlist']
                                  ? Image.asset('assets/images/ic_edit.png',
                                      scale: 1.5)
                                  : const Text(""),
                            ),
                          ),
                          Container(
                              alignment: Alignment.center,
                              margin: const EdgeInsets.only(left: 5, right: 5),
                              child: !subliminalDataDetail['subliminal']
                                      ['wishlist']
                                  ? Text(
                                      "Add to wishlist".toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                        fontFamily: 'DPClear',
                                        fontWeight: FontWeight.w600,
                                      ),
                                      softWrap: true,
                                    )
                                  : Text(
                                      "Remove from wishlist".toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                        fontFamily: 'DPClear',
                                        fontWeight: FontWeight.w600,
                                      ),
                                      softWrap: true,
                                    )),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: isTrial && !isTrialUsed && difference < 8 ||
                          subliminalDataDetail['subliminal']['buyed'] ||
                          subliminalDataDetail['subliminal']['Is_free_trial'] ==
                              1 ||
                          SharedPrefs().getSubPlayingId() ==
                              subliminalDataDetail['subliminal']['id']
                      ? buildListenButton(
                          context, subliminalDataDetail['subliminal'])
                      : buildBuyNowButton(
                          context, subliminalDataDetail['subliminal']),
                )
              ])
        ],
      ),
    );
  }

  _callAddWishListApi(BuildContext context, String id) {
    showCenterLoader(context);
    _getAddWishListData(id);
  }

  Widget buildListenButton(BuildContext context, dynamic subliminalList) {
    return ConstrainedBox(
        constraints: const BoxConstraints(minWidth: double.infinity),
        child: Container(
            decoration: kButtonBox10Decoration,
            margin: const EdgeInsets.only(top: 15, left: 10),
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  isListen = true;
                  bottomMargin = 170;
                  selectedSubliminal = subliminalList;
                  setupServiceLocator(subliminalList['audio_path']);
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
                    SharedPrefs()
                        .setPlayingSubUrl(subliminalList['audio_path']);
                    SharedPrefs().setPlayingSubName(subliminalList['title']);
                    //advancedPlayer.setSourceUrl(subliminalList['audio_path']);
                    player.setUrl(subliminalList['audio_path']);
                    player.play();
                    isLoading = true;
                    Future.delayed(const Duration(seconds: 3))
                        .then((value) => setState(() {
                              isLoading = false;
                            }));

                    if (isTrial && !isTrialUsed) {
                      _getUsedFreeTrialData(
                          context, "true", subliminalList['id'].toString());
                    }
                  } else {
                    if (SharedPrefs().getSubPlayingId() ==
                        subliminalList['id']) {
                      SharedPrefs().setPlayingSubId(subliminalList['id']);
                      SharedPrefs()
                          .setPlayingSubImage(subliminalList['cover_path']);
                      SharedPrefs()
                          .setPlayingSubUrl(subliminalList['audio_path']);
                      // advancedPlayer.setSourceUrl(subliminalList['audio_path']);
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

                      // advancedPlayer.setSourceUrl(subliminalList['audio_path']);
                      player.setUrl(subliminalList['audio_path']);
                      !isTrialUsed
                          ? setState(() {
                              SharedPrefs().setIsFreeTrailUsed(true);
                              isTrialUsed = true;
                            })
                          : player.play();
                      isLoading = true;
                      Future.delayed(const Duration(seconds: 3))
                          .then((value) => setState(() {
                                /*advancedPlayer.play(
                                    UrlSource(subliminalList['audio_path']));*/
                                isLoading = false;
                              }));

                      // await advancedPlayer.setUrl(subliminalList['audio_path']);
                      // await advancedPlayer.play();
                      // await advancedPlayer.setLoopMode(LoopMode.all);
                    }
                  }
                });

                //context.go(Routes.createSubliminal);
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // <-- Radius
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
                          : Image.asset('assets/images/ic_play.png',
                              scale: 1.5),
                    ),
                  ),
                  Flexible(
                      child: Text(
                          SharedPrefs().getSubPlayingId() ==
                                  subliminalList['id']
                              ? buttonPlaying.toUpperCase()
                              : isTrial && !isTrialUsed
                                  ? kListenWithTrial.toUpperCase()
                                  : kListenNow.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontFamily: 'DPClear',
                            fontWeight: FontWeight.w500,
                          ))),
                ],
              ),
            )));
  }

  Widget buildTopBarContainer(BuildContext context, Size mq) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => {
            setState(() {
              //context.pop(Routes.discover);
              Navigator.pop(context, true);
              // toast("click", false);
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
                widget.subName,
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

  Widget buildBuyNowButton(BuildContext context, dynamic subliminal) {
    return ConstrainedBox(
        constraints: const BoxConstraints(minWidth: double.infinity),
        child: Container(
          margin: const EdgeInsets.only(top: 15, left: 10),
          height: 50,
          decoration: kButtonBox10Decoration,
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                context.pushNamed('buy-subliminals', queryParameters: {
                  'subId': subliminal['id'].toString(),
                  "subName": subliminal['title'],
                  "catId": widget.subId,
                  "catName": widget.subName,
                  "amount": subliminal['price'].toString(),
                  "screen": 'detail'
                });
                /*   _navigateToBuySubliminalScreen(
                    context,
                    subliminal['price'].toString(),
                    subliminal['id'].toString(),
                    subliminal['title'],
                    widget.subName,
                    widget.subId);*/
              });
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
                  margin: const EdgeInsets.only(right: 10),
                  child: Align(
                    alignment: Alignment.center,
                    child: Image.asset('assets/images/ic_bag_tick.png',
                        scale: 1.5),
                  ),
                ),
                TextFieldWidget500(
                    text: 'buy now'.toUpperCase(),
                    size: 14,
                    color: Colors.white,
                    textAlign: TextAlign.center),
              ],
            ),
          ),
        ));
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

  Widget buildPlayerBottomContainer(BuildContext context, dynamic subliminal) {
    return Positioned(
        bottom: 0,
        width: MediaQuery.of(context).size.width,
        child: GestureDetector(
            onTap: () => {
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
                              TextFieldWidget500(
                                  text: subliminal['title'],
                                  size: 14,
                                  color: Colors.white,
                                  textAlign: TextAlign.center),
                              Container(
                                  margin: const EdgeInsets.only(top: 5),
                                  child: TextFieldWidget(
                                    text: subliminal['description'],
                                    size: 10,
                                    color: Colors.white,
                                    weight: FontWeight.w400,
                                  )),
                            ],
                          ),
                        )),
                    Expanded(
                        flex: 2,
                        child: Container(
                            child: GestureDetector(
                          onTap: () => {
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
}
