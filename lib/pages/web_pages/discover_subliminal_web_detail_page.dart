import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:success_subliminal/pages/discover_subliminal_detail_page.dart';

import '../../app/router.dart';
import '../../data/api/ApiService.dart';
import '../../utils/AudioPlayerHandler.dart';
import '../../utils/center_loader.dart';
import '../../utils/constant.dart';
import '../../utils/service_locator.dart';
import '../../utils/shared_prefs.dart';
import '../../widget/ButtonWidget.dart';
import '../../widget/WebFooterWithoutLinkWidget.dart';
import '../../widget/WebTopBarContainer.dart';
import '../../widget/bottom_audio_player.dart';

class DiscoverSubliminalDetailWebPage extends StatefulWidget {
  final String subName;
  final String subId;
  final String categoryName;
  final String catId;

  const DiscoverSubliminalDetailWebPage(
      {Key? key,
      required this.subName,
      required this.subId,
      required this.categoryName,
      required this.catId})
      : super(key: key);

  @override
  SubliminalDetailPage createState() => SubliminalDetailPage();
}

class SubliminalDetailPage extends State<DiscoverSubliminalDetailWebPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late dynamic subliminalDetail;
  late dynamic subliminalDataDetail;
  bool isLoading = false;
  bool isSubliminal = false;
  bool isTrial = false;
  late dynamic subliminal;
  bool isTrialUsed = false;
  bool isSubscriptionActive = false;
  late dynamic usedFreeTrial;
  int difference = 0;
  double leftPadding = 50;
  double rightPadding = 50;
  bool isListen = false;
  double bottomMargin = 80;
  double leftMarginDescription = 100;
  dynamic selectedSubliminal;
  final AudioPlayerHandler _audioHandler = AudioPlayerHandler("");

  @override
  void initState() {
    super.initState();
    _startPlaybackStateListener();
    initializePreference().whenComplete(() {
      setState(() {});
    });

    DateTime dateTime = DateTime.now();
    DateTime pickedDate = DateTime.parse(SharedPrefs().getTrialStartDate()!);

    difference = dateTime.difference(pickedDate).inDays;

    _getSubliminalDetailData(widget.subId);
    setState(() {
      isTrial = SharedPrefs().isFreeTrail();
      isTrialUsed = SharedPrefs().isFreeTrailUsed();
    });

    if (!player.playing) {
      if (SharedPrefs().isFreeTrail()) {
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

  void changeName(String name, bool isPlay) {
    setState(() {
      buttonPlaying = name;
      SharedPrefs().setIsSubPlaying(isPlay);
    });
  }

  void _getUsedFreeTrialData(
      BuildContext context, String status, String id) async {
    usedFreeTrial = await ApiService().getFreeTrialUsed(context, status, id);

    Future.delayed(const Duration(seconds: 2)).then((value) => setState(() {
          setState(() {
            if (usedFreeTrial['http_code'] != 200) {
            } else {
              if (usedFreeTrial['data']['free_trial_status'] == 'true') {}
              setState(() {
                SharedPrefs().setIsFreeTrail(true);
                SharedPrefs().setIsFreeTrailUsed(true);

                isTrial = SharedPrefs().isFreeTrail();
                isTrialUsed = SharedPrefs().isFreeTrailUsed();
                isSubscriptionActive = SharedPrefs().isSubscription();
              });
            }
            if (kDebugMode) {
              print("size ----$usedFreeTrial");
            }
          });
        }));
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
                          ? bottomMargin = 200
                          : bottomMargin = 100
                      : bottomMargin = 100;
                } else {
                  if (SharedPrefs().getSubPlayingId() ==
                      subliminalDataDetail['subliminal']['id']) {
                    selectedSubliminal = subliminalDataDetail['subliminal'];
                    isFlag = true;
                  }
                  isFlag ? isListen = true : isListen = false;
                  isListen
                      ? SharedPrefs().isSubPlaying()
                          ? bottomMargin = 200
                          : bottomMargin = 100
                      : bottomMargin = 100;
                }
              }

              if (kDebugMode) {
                print(subliminalDetail);
              }
            }));
  }

  _handleOnBuyNowButton(BuildContext context, dynamic subliminalDetail) {
    setState(() {
      context.pushNamed('buy-subliminals', queryParameters: {
        'subId': subliminalDetail['id'].toString(),
        "subName": subliminalDetail['title'],
        "catId": widget.catId,
        "catName": widget.categoryName,
        "amount": subliminalDetail['price'].toString(),
        "screen": 'detail'
      });
    });
  }

  _handleOnListenButton(BuildContext context, Size mq, dynamic subliminalList) {
    setState(() {
      isListen = true;
      bottomMargin = 200;
      selectedSubliminal = subliminalList;
      setupServiceLocator(subliminalList['audio_path']);
    });

    setState(() {
      if (kDebugMode) {
        print(subliminalList['audio_path']);
        print(SharedPrefs().isSubPlaying());
      }

      if (!SharedPrefs().isSubPlaying()) {
        changeName(kStopNow, true);
        SharedPrefs().setPlayingSubId(subliminalList['id']);
        SharedPrefs().setPlayingSubImage(subliminalList['cover_path']);
        SharedPrefs().setPlayingSubUrl(subliminalList['audio_path']);
        SharedPrefs().setPlayingSubName(subliminalList['title']);
        player.setUrl(subliminalList['audio_path']);
        player.play();
        isLoading = true;
        Future.delayed(const Duration(seconds: 3)).then((value) => setState(() {
              isLoading = false;
            }));

        if (isTrial && !isTrialUsed) {
          _getUsedFreeTrialData(
              context, "true", subliminalList['id'].toString());
        }
      } else {
        SharedPrefs().setPlayingSubId(subliminalList['id']);
        SharedPrefs().setPlayingSubImage(subliminalList['cover_path']);
        SharedPrefs().setPlayingSubUrl(subliminalList['audio_path']);

        isLoading = false;
        changeName(kListenNow, false);
        player.stop();

        setState(() {
          SharedPrefs().setIsFreeTrailUsed(true);
          isTrialUsed = true;
        });
        /*if (SharedPrefs().getSubPlayingId() == subliminalList['id']) {
          SharedPrefs().setPlayingSubId(subliminalList['id']);
          SharedPrefs().setPlayingSubImage(subliminalList['cover_path']);
          SharedPrefs().setPlayingSubUrl(subliminalList['audio_path']);
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
          SharedPrefs().setPlayingSubImage(subliminalList['cover_path']);
          SharedPrefs().setPlayingSubUrl(subliminalList['audio_path']);
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
                    */ /*advancedPlayer.play(
                                    UrlSource(subliminalList['audio_path']));*/ /*
                    isLoading = false;
                  }));

          // await advancedPlayer.setUrl(subliminalList['audio_path']);
          // await advancedPlayer.play();
          // await advancedPlayer.setLoopMode(LoopMode.all);
        }*/
      }
    });

    /*  setState(() {
      setState(() {
        if (!player.playing) {
          changeName(kStopNow, true);
        } else {
          if (subPlaying == subliminalList['id']) {
            changeName(kListenNow, false);
          } else {
            changeName(kStopNow, true);
          }
        }
      });
      setState(() {
        if (kDebugMode) {
          print(subliminalList['audio_path']);
          print(subPlaying);
          print(subliminalList['id']);
        }

        if (!player.playing) {
          subPlaying = subliminalList['id'];
          player.setUrl(subliminalList['audio_path']);
          player.play();
          player.setLoopMode(LoopMode.all);
          if (isTrial && !isTrialUsed) {
            _getUsedFreeTrialData(
                context, "true", subliminalList['id'].toString());
          }
        } else {
          if (subPlaying == subliminalList['id']) {
            subPlaying = subliminalList['id'];
            player.stop();
            setState(() {
              SharedPrefs().setIsFreeTrailUsed(true);
              isTrialUsed = true;
            });
          } else {
            subPlaying = subliminalList['id'];
            player.stop();

            player.setUrl(subliminalList['audio_path']);
            !isTrialUsed
                ? setState(() {
                    SharedPrefs().setIsFreeTrailUsed(true);
                    isTrialUsed = true;
                  })
                : player.play();
            player.setLoopMode(LoopMode.all);
          }
        }
      });
    });*/
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
        body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            if (constraints.maxWidth > 757) {
              if (constraints.maxWidth < 900) {
                leftPadding = 50;
                rightPadding = 50;
                leftMarginDescription = 50;
              } else if (constraints.maxWidth < 1100) {
                leftPadding = 50;
                rightPadding = 50;
                leftMarginDescription = 50;
              } else if (constraints.maxWidth < 1300) {
                leftPadding = 100;
                rightPadding = 100;
                leftMarginDescription = 70;
              } else if (constraints.maxWidth < 1600) {
                leftPadding = 150;
                rightPadding = 150;
                leftMarginDescription = 100;
              } else if (constraints.maxWidth < 2000) {
                leftPadding = 200;
                rightPadding = 200;
                leftMarginDescription = 100;
              }
              return buildHomeContainer(context, mq);
            } else {
              return DiscoverSubliminalDetailPage(
                  subName: widget.subName, subId: widget.subId);
            }
          },
        ));
  }

  Widget buildHomeContainer(BuildContext context, Size mq) {
    return SafeArea(
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
            const WebTopBarContainer(screen: 'discover'),
            Positioned(
                bottom: 0,
                child: SizedBox(
                    height: 80,
                    width: mq.width * 1,
                    child: const WebFooterWithoutLinkWidget())),
            selectedSubliminal != null
                ? Visibility(
                    visible: isListen,
                    child: BottomAudioPlayerScreen(
                      subliminal: selectedSubliminal,
                      isLoading: isLoading,
                      padding: leftPadding,
                      onAddTap: () {
                        setState(() {
                          if (!SharedPrefs().isSubPlaying()) {
                            player.play();
                            changeName(kStopNow, true);
                          } else {
                            player.pause();
                            changeName(kListenNow, false);
                          }
                        });
                      },
                    ))
                : const Text(""),
            Container(
              margin: EdgeInsets.only(
                  top: loginTopPadding,
                  right: rightPadding,
                  left: leftPadding,
                  bottom: bottomMargin),
              child: ListView(
                shrinkWrap: true,
                primary: false,
                children: [
                  buildTopBarContainer(context, mq),
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
    );
  }

  Widget buildSubliminalDetailContainer(BuildContext context, Size mq) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
              flex: 3,
              child: Container(
                decoration: kEditTextDecoration,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: Align(
                    alignment: Alignment.center,
                    child: subliminalDataDetail['subliminal']['cover_path'] !=
                            ""
                        ? Image.network(
                            subliminalDataDetail['subliminal']['cover_path'],
                            fit: BoxFit.fitWidth,
                          )
                        : Image.asset('assets/images/bg_logo_image.png',
                            scale: 1.5),
                  ),
                ),
              )),
          Expanded(
              flex: 7,
              child: Container(
                  padding: EdgeInsets.only(
                    left: leftMarginDescription,
                  ),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            subliminalDataDetail['subliminal']['title'],
                            style: const TextStyle(
                                fontSize: 50,
                                color: Colors.white,
                                fontFamily: 'DPClear',
                                fontWeight: FontWeight.w600),
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
                                  letterSpacing: .5,
                                  fontFamily: 'DPClear',
                                  fontWeight: FontWeight.w400),
                            ),
                          ),
                        ),
                        Container(
                          height: 40,
                          decoration: kTransButtonBoxDecoration,
                          margin: const EdgeInsets.only(top: 50),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                margin: const EdgeInsets.only(left: 20),
                                child: Align(
                                  alignment: Alignment.center,
                                  child: !subliminalDataDetail['subliminal']
                                          ['wishlist']
                                      ? Image.asset('assets/images/ic_edit.png',
                                          scale: 1.5)
                                      : Image.asset(
                                          'assets/images/ic_edit.png',
                                          scale: 1.5,
                                          color: accent,
                                        ),
                                ),
                              ),
                              MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: GestureDetector(
                                      onTap: () => {
                                            setState(() {
                                              showCenterLoader(context);
                                              if (subliminalDataDetail[
                                                  'subliminal']['wishlist']) {
                                                _getRemoveWishListData(
                                                    subliminalDataDetail[
                                                            'subliminal']['id']
                                                        .toString());
                                              } else {
                                                _getAddWishListData(
                                                    subliminalDataDetail[
                                                            'subliminal']['id']
                                                        .toString());
                                              }
                                            })
                                          },
                                      child: Container(
                                          alignment: Alignment.center,
                                          margin: const EdgeInsets.only(
                                              left: 5, right: 20),
                                          child: !subliminalDataDetail[
                                                  'subliminal']['wishlist']
                                              ? Text(
                                                  "Add to wishlist"
                                                      .toUpperCase(),
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.white,
                                                    fontFamily: 'DPClear',
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                  softWrap: true,
                                                )
                                              : Text(
                                                  "Remove from wishlist"
                                                      .toUpperCase(),
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.white,
                                                    fontFamily: 'DPClear',
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                  softWrap: true,
                                                )))),
                            ],
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 30),
                          child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(right: 20),
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
                                isTrial && !isTrialUsed && difference < 8 ||
                                        subliminalDataDetail['subliminal']
                                            ['buyed'] ||
                                        subliminalDataDetail['subliminal']
                                                ['Is_free_trial'] ==
                                            1 ||
                                        SharedPrefs().getSubPlayingId() ==
                                            subliminalDataDetail['subliminal']
                                                ['id']
                                    ? listenButton(context, mq,
                                        subliminalDataDetail['subliminal'])
                                    : buyNowButton(context,
                                        subliminalDataDetail['subliminal'])
                              ]),
                        ),
                      ]))),
        ],
      ),
    );
  }

  Widget listenButton(BuildContext context, Size mq, dynamic subliminalList) {
    return Container(
        margin: const EdgeInsets.only(
          left: 30,
        ),
        child: ButtonWidget(
          name: SharedPrefs().getSubPlayingId() == subliminalList['id']
              ? buttonPlaying.toUpperCase()
              : isTrial && !isTrialUsed
                  ? kListenWithTrial.toUpperCase()
                  : kListenNow.toUpperCase(),
          icon: SharedPrefs().getSubPlayingId() == subliminalList['id']
              ? !SharedPrefs().isSubPlaying()
                  ? 'assets/images/ic_play.png'
                  : 'assets/images/ic_stop.png'
              : 'assets/images/ic_play.png',
          visibility: true,
          padding: 20,
          onTap: () => _handleOnListenButton(context, mq, subliminalList),
          size: 14,
          scale: 1.5,
          height: 50,
        ));
  }

  Widget buyNowButton(BuildContext context, dynamic subliminalList) {
    return Container(
        margin: const EdgeInsets.only(
          left: 30,
        ),
        child: ButtonWidget(
          name: 'buy now'.toUpperCase(),
          icon: 'assets/images/ic_bag_tick.png',
          visibility: true,
          padding: 20,
          onTap: () => _handleOnBuyNowButton(context, subliminalList),
          size: 14,
          scale: 1.5,
          height: 50,
        ));
  }

  Widget buildBuyNowButton(BuildContext context, dynamic subliminalList) {
    return Container(
      decoration: kButtonBox10Decoration,
      padding: const EdgeInsets.only(left: 20, right: 20),
      margin: const EdgeInsets.only(
        left: 30,
      ),
      height: 40,
      child: ElevatedButton(
        onPressed: () {
          context.pushNamed('buy-subliminals', queryParameters: {
            'subId': subliminalList['id'].toString(),
            "subName": subliminalList['title'],
            "catId": widget.catId,
            "catName": widget.categoryName,
            "amount": subliminalList['price'].toString(),
            "screen": 'list'
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
                child: Image.asset('assets/images/ic_bag_tick.png', scale: 1.5),
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
    );
  }

  Widget buildTopBarContainer(BuildContext context, Size mq) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
            onTap: () => {
                  setState(() {
                    context.pushReplacement(Routes.discover);
                  })
                },
            child: Container(
                padding: const EdgeInsets.all(10),
                decoration: kTransButtonBoxDecoration,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Image.asset('assets/images/ic_arrow_left.png',
                          scale: 3),
                    ),
                    Container(
                      padding: const EdgeInsets.only(left: 5, top: 2),
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          "all categories".toUpperCase(),
                          style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              fontFamily: 'DPClear',
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                    ),
                  ],
                ))),
        InkWell(
            onTap: () => {
                  setState(() {
                    context.pushNamed('discover-subliminals', queryParameters: {
                      'categoryName': widget.categoryName,
                      'categoryId': widget.catId,
                      'subname': widget.subName,
                    });

                    /* _navigateToSubliminalScreen(context, widget.catId,
                        widget.subName, widget.categoryName);*/
                  })
                },
            child: Container(
                margin: const EdgeInsets.only(left: 20),
                padding: const EdgeInsets.all(10),
                decoration: kTransButtonBoxDecoration,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Image.asset('assets/images/ic_arrow_left.png',
                          scale: 3),
                    ),
                    Container(
                      padding: const EdgeInsets.only(left: 5, top: 2),
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          widget.subName.toUpperCase(),
                          style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              fontFamily: 'DPClear',
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                    ),
                  ],
                )))
      ],
    );
  }
}
