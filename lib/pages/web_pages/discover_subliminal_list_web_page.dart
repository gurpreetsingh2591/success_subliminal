/*import 'dart:html' as html;*/

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:success_subliminal/pages/discover_subliminal_list_page.dart';

import '../../data/api/ApiService.dart';
import '../../utils/AudioPlayerHandler.dart';
import '../../utils/constant.dart';
import '../../utils/service_locator.dart';
import '../../utils/shared_prefs.dart';
import '../../widget/WebFooterWithoutLinkWidget.dart';
import '../../widget/WebTopBarContainer.dart';
import '../../widget/bottom_audio_player.dart';

class DiscoverCategoryWebListPage extends StatefulWidget {
  final String categoryName;
  final String categoryId;
  final String subname;

  const DiscoverCategoryWebListPage(
      {Key? key,
      required this.categoryName,
      required this.categoryId,
      required this.subname})
      : super(key: key);

  @override
  _DiscoverCategoryWebListPage createState() => _DiscoverCategoryWebListPage();
}

class _DiscoverCategoryWebListPage extends State<DiscoverCategoryWebListPage>
    with WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late List<dynamic> subliminalList = [];
  late dynamic subliminal;
  late dynamic usedFreeTrial;
  late dynamic signUpModel;
  bool isLoading = false;
  bool isSubliminal = false;
  bool isPlaying = false;
  bool isGrid = false;
  double categoryNameSize = 30;
  bool isTrial = false;
  bool isTrialUsed = false;
  bool isSubscriptionActive = false;
  int difference = 0;
  double leftPadding = 200;
  double rightPadding = 200;
  double descriptionRightPadding = 100;
  double buttonRightPadding = 40;
  double buttonInternalPadding = 20;

  bool isListen = false;
  double bottomMargin = 100;
  dynamic selectedSubliminal;
  int flexButton = 2;
  int flexDescription = 7;
  int flexImage = 1;
  final AudioPlayerHandler _audioHandler = AudioPlayerHandler("");

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

    _startPlaybackStateListener();
    initializePreference().whenComplete(() {
      setState(() {});

      _getSubliminalListData(widget.categoryId);

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
    setState(() {
      isTrial = SharedPrefs().isFreeTrail();
      isTrialUsed = SharedPrefs().isFreeTrailUsed();
      isSubscriptionActive = SharedPrefs().isSubscription();
    });

    DateTime dateTime = DateTime.now();
    DateTime pickedDate = DateTime.parse(SharedPrefs().getTrialStartDate()!);

    difference = dateTime.difference(pickedDate).inDays;

    if (kDebugMode) {
      print("is trial----$isTrial");
      print("isTrialUsed----$isTrialUsed");
      print("isSubscriptionActive----$isSubscriptionActive");
      print("difference----$difference");
      print("subPlaying----$subPlaying");
    }
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

  Future<void> initializePreference() async {
    SharedPrefs.init(await SharedPreferences.getInstance());
  }

  void _getSubliminalListData(String categoryId) async {
    subliminal =
        await ApiService().getLoginDiscoverSubliminalList(context, categoryId);

    Future.delayed(const Duration(seconds: 2)).then((value) => setState(() {
          setState(() {
            if (subliminal['http_code'] != 200) {
            } else {
              setState(() {
                subliminalList.clear();
                isSubliminal = true;
                subliminalList.addAll(subliminal['data']['subliminals']);

                bool isFlag = false;
                if (!SharedPrefs().isSubPlaying()) {
                  selectedSubliminal = subliminalList[0];
                  isListen = false;
                  isListen
                      ? SharedPrefs().isSubPlaying()
                          ? bottomMargin = 200
                          : bottomMargin = 100
                      : bottomMargin = 100;
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
                          ? bottomMargin = 200
                          : bottomMargin = 100
                      : bottomMargin = 100;
                }
              });
            }
            if (kDebugMode) {
              print("subliminal ----$subliminal");
            }
          });
        }));
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
                titleSize = 20;
                descriptionSize = 12;
                titleGridSize = 14;
                descriptionGridSize = 11;

                categoryNameSize = 30;

                leftPadding = 50;
                rightPadding = 50;
                descriptionRightPadding = 20;
                buttonRightPadding = 15;
                buttonInternalPadding = 10;
                flexButton = 3;
                flexDescription = 6;
                flexImage = 2;
              } else if (constraints.maxWidth < 1100) {
                titleSize = 22;
                descriptionSize = 13;
                titleGridSize = 16;
                descriptionGridSize = 12;
                categoryNameSize = 35;
                leftPadding = 50;
                rightPadding = 50;
                descriptionRightPadding = 30;
                buttonRightPadding = 20;
                buttonInternalPadding = 10;

                flexButton = 3;
                flexDescription = 6;
                flexImage = 2;
              } else if (constraints.maxWidth < 1300) {
                titleSize = 24;
                descriptionSize = 14;
                titleGridSize = 18;
                descriptionGridSize = 13;
                categoryNameSize = 60;
                leftPadding = 100;
                rightPadding = 100;
                descriptionRightPadding = 40;
                buttonRightPadding = 25;
                buttonInternalPadding = 12;

                flexButton = 2;
                flexDescription = 7;
                flexImage = 1;
              } else if (constraints.maxWidth < 1600) {
                titleSize = 26;
                descriptionSize = 15;
                titleGridSize = 20;
                descriptionGridSize = 14;
                categoryNameSize = 65;
                leftPadding = 150;
                rightPadding = 150;
                descriptionRightPadding = 60;
                buttonRightPadding = 30;
                buttonInternalPadding = 15;
                flexButton = 2;
                flexDescription = 7;
                flexImage = 1;
              } else if (constraints.maxWidth < 2000) {
                titleSize = 28;
                descriptionSize = 16;
                titleGridSize = 22;
                descriptionGridSize = 15;
                categoryNameSize = 70;
                leftPadding = 200;
                rightPadding = 200;
                descriptionRightPadding = 100;
                buttonRightPadding = 40;
                buttonInternalPadding = 20;

                flexButton = 2;
                flexDescription = 7;
                flexImage = 1;
              }

              return buildHomeContainer(context, mq);
            } else {
              return DiscoverCategoryListPage(
                  categoryName: widget.categoryName,
                  categoryId: widget.categoryId);
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
            const WebTopBarContainer(screen: "discover"),
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
            Positioned(
                bottom: 0,
                child: SizedBox(
                    height: 80,
                    width: mq.width * 1,
                    child: const WebFooterWithoutLinkWidget())),
            Container(
              margin: EdgeInsets.only(
                  top: loginTopPadding,
                  left: leftPadding,
                  right: rightPadding,
                  bottom: bottomMargin),
              child: ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context)
                      .copyWith(scrollbars: false),
                  child: ListView(
                    shrinkWrap: false,
                    primary: false,
                    children: [
                      buildTopBarContainer(context, mq),
                      isSubliminal
                          ? !isGrid
                              ? buildSubliminalListContainer(context, mq)
                              : buildSubliminalGridListContainer(context, mq)
                          : const SizedBox(
                              height: 500,
                              child:
                                  Center(child: CircularProgressIndicator())),
                    ],
                  )),
            )
          ],
        ),
      ),
    );
  }

  Widget buildSubliminalGridListContainer(BuildContext context, Size mq) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            if (constraints.maxWidth < 1100) {
              return buildTab(context);
            } else if (constraints.maxWidth < 1500) {
              return buildWeb1100_1400Grid(context);
            } else if (constraints.maxWidth < 1700) {
              return buildWebGrid(context);
            } else {
              return buildWeb2000Grid(context);
            }
          },
        )
      ],
    );
  }

  Widget buildWeb1100_1400Grid(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          (subliminalList.isNotEmpty)
              ? GridView.builder(
                  reverse: false,
                  shrinkWrap: true,
                  primary: false,
                  itemCount: subliminalList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return buildGridListItemContainer(
                      context,
                      kAddToCollectionText,
                      true,
                      subliminalList[index],
                    );
                  },
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 2 / 2.87,
                  ))
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
    );
  }

  Widget buildWebGrid(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          (subliminalList.isNotEmpty)
              ? GridView.builder(
                  reverse: false,
                  shrinkWrap: true,
                  primary: false,
                  itemCount: subliminalList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return buildGridListItemContainer(
                      context,
                      kAddToCollectionText,
                      true,
                      subliminalList[index],
                    );
                  },
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 2 / 2.7,
                  ))
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
    );
  }

  Widget buildWeb2000Grid(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          (subliminalList.isNotEmpty)
              ? GridView.builder(
                  reverse: false,
                  shrinkWrap: true,
                  primary: false,
                  itemCount: subliminalList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return buildGridListItemContainer(
                      context,
                      kAddToCollectionText,
                      true,
                      subliminalList[index],
                    );
                  },
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: 2 / 2.7,
                  ))
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
    );
  }

  Widget buildTab(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          (subliminalList.isNotEmpty)
              ? GridView.builder(
                  reverse: false,
                  shrinkWrap: true,
                  primary: false,
                  itemCount: subliminalList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return buildGridListItemContainer(
                      context,
                      kAddToCollectionText,
                      true,
                      subliminalList[index],
                    );
                  },
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 2 / 2.65,
                  ))
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
    );
  }

  Widget buildSubliminalListContainer(BuildContext context, Size mq) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 20),
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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
            onTap: () => {
                  setState(() {
                    Navigator.pop(context);
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
        Row(
          children: [
            Container(
              padding: const EdgeInsets.only(
                left: 15,
              ),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  widget.categoryName,
                  maxLines: 2,
                  style: TextStyle(
                      fontSize: categoryNameSize,
                      color: Colors.white,
                      fontFamily: 'DPClear',
                      fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ],
        ),
        Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  onTap: () => {
                    setState(() {
                      isGrid = true;
                    })
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    padding: const EdgeInsets.all(10),
                    decoration: isGrid
                        ? kAccentButtonBoxDecoration
                        : kTransButtonBoxDecoration,
                    child: Image.asset(
                      "assets/images/ic_list_view.png",
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => {
                    setState(() {
                      isGrid = false;
                    })
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    margin: const EdgeInsets.only(right: 50, left: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: isGrid
                        ? kTransButtonBoxDecoration
                        : kAccentButtonBoxDecoration,
                    child: Image.asset(
                      "assets/images/ic_grid_view.png",
                      scale: 1.5,
                    ),
                  ),
                ),
              ],
            ))
      ],
    );
  }

  Widget buildGridListItemContainer(BuildContext context, String buttonName,
      bool isWish, dynamic subliminalList) {
    return GestureDetector(
      onTap: () => {
        context.pushNamed('discover-subliminals-detail', queryParameters: {
          'categoryName': subliminalList['title'],
          'subName': widget.categoryName,
          'subId': subliminalList['id'].toString(),
          'catId': widget.categoryId,
        })

        /*  _navigateToSubDetailScreen(
            context,
            subliminalList['title'],
            subliminalList['id'].toString(),
            widget.categoryName,
            widget.categoryId)*/
      },
      child: Container(
        padding: const EdgeInsets.all(15),
        margin: const EdgeInsets.only(left: 10, right: 10, top: 20),
        decoration: kAllCornerBoxDecoration2,
        child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15.0),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: subliminalList['cover_path'] != ""
                            ? FadeInImage.assetNetwork(
                                placeholder: 'assets/images/bg_logo_image.png',
                                image: subliminalList['cover_path'],
                              )
                            : Image.asset(
                                'assets/images/bg_logo_image.png',
                              ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(top: 15),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          subliminalList['title'],
                          maxLines: 2,
                          style: TextStyle(
                            fontSize: titleGridSize,
                            color: Colors.white,
                            fontFamily: 'DPClear',
                            fontWeight: FontWeight.w500,
                          ),
                          softWrap: true,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(top: 10),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          subliminalList['description'],
                          maxLines: 4,
                          style: TextStyle(
                            fontSize: descriptionGridSize,
                            letterSpacing: .5,
                            color: Colors.white54,
                            fontFamily: 'DPClear',
                            fontWeight: FontWeight.w400,
                          ),
                          softWrap: true,
                        ),
                      ),
                    ),
                  ]),
              Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                      alignment: Alignment.bottomCenter,
                      padding: const EdgeInsets.only(top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(
                              bottom: 10,
                            ),
                            child: Text("\$${subliminalList['price']}",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 30,
                                  fontFamily: 'DPClear',
                                  fontWeight: FontWeight.w500,
                                )),
                          ),
                          isTrial && !isTrialUsed && difference < 8 ||
                                  subliminalList['buyed'] ||
                                  subliminalList['Is_free_trial'] == 1 ||
                                  SharedPrefs().getSubPlayingId() ==
                                      subliminalList['id']
                              ? buildListenButton(context, subliminalList)
                              : buildBuyNowButton(context, subliminalList),
                        ],
                      )))
            ]),
      ),
    );
  }

  void playerStateListener() {
    player.durationStream.listen((s) => setState(() {}));
  }

  void playerStatePositionListener() {
    player.positionStream.listen((s) => setState(() {}));
  }

  Widget buildListItemContainer(BuildContext context, String buttonName,
      bool isWish, dynamic subliminalList) {
    return GestureDetector(
      onTap: () => {
        context.pushNamed('discover-subliminals-detail', queryParameters: {
          'subName': subliminalList['title'],
          'subId': subliminalList['id'].toString(),
          'categoryName': widget.categoryName,
          'catId': widget.categoryId,
        })
      },
      child: Container(
        padding: const EdgeInsets.all(15),
        margin: const EdgeInsets.only(left: 10, right: 10, top: 10),
        decoration: kAllCornerBoxDecoration2,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                        flex: flexImage,
                        child: SizedBox(
                            width: 100,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15.0),
                              child: Align(
                                  alignment: Alignment.topLeft,
                                  child: subliminalList['cover_path'] != ""
                                      ? FadeInImage.assetNetwork(
                                          placeholder:
                                              'assets/images/bg_logo_image.png',
                                          image: subliminalList['cover_path'],
                                        )
                                      : Image.asset(
                                          'assets/images/bg_logo_image.png',
                                        )),
                            ))),
                    Expanded(
                      flex: flexDescription,
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.only(
                                left: 50,
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
                            Container(
                              padding: EdgeInsets.only(
                                right: descriptionRightPadding,
                                left: 50,
                                bottom: 10,
                              ),
                              alignment: Alignment.topLeft,
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  subliminalList['description'],
                                  style: TextStyle(
                                    fontSize: descriptionSize,
                                    color: Colors.white54,
                                    letterSpacing: .2,
                                    fontFamily: 'DPClear',
                                    fontWeight: FontWeight.w400,
                                  ),
                                  softWrap: true,
                                ),
                              ),
                            ),
                          ]),
                    ),
                    Expanded(
                      flex: flexButton,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          margin: EdgeInsets.only(right: buttonRightPadding),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(
                                    bottom: 15, right: 20),
                                child: Text("\$${subliminalList['price']}",
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontFamily: 'DPClear',
                                      fontWeight: FontWeight.w600,
                                    )),
                              ),
                              isTrial && !isTrialUsed && difference < 8 ||
                                      subliminalList['buyed'] ||
                                      subliminalList['Is_free_trial'] == 1 ||
                                      SharedPrefs().getSubPlayingId() ==
                                          subliminalList['id']
                                  ? buildListenButton2(context, subliminalList)
                                  : buildBuyNowButton(context, subliminalList),
                            ],
                          ),
                        ),
                      ),
                    )
                  ]),
            ]),
      ),
    );
  }

  Widget buildListenButton2(BuildContext context, dynamic subliminalList) {
    return Container(
        padding: EdgeInsets.only(
            right: buttonInternalPadding, left: buttonInternalPadding),
        decoration: kButtonBox10Decoration,
        height: 40,
        child: ElevatedButton(
          onPressed: () {
            if (isTrial && !isTrialUsed && buttonPlaying == kStopNow) {
            } else {
              setState(() {
                isListen = true;
                bottomMargin = 200;
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
                      .then((value) => setState(() {
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
                    !isTrialUsed
                        ? setState(() {
                            SharedPrefs().setIsFreeTrailUsed(true);
                            isTrialUsed = true;
                          })
                        : player.play();
                    isLoading = true;
                    Future.delayed(const Duration(seconds: 5))
                        .then((value) => setState(() {
                              isLoading = false;
                            }));
                  }
                }
              });

              /*  setState(() {
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

              setState(() async {
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

                    if (kDebugMode) {
                      print("isFreeTrial");
                    }
                  }

                  setState(() {
                    isListen = true;
                    bottomMargin = 200;
                  });
                } else {
                  if (subPlaying == subliminalList['id']) {
                    subPlaying = subliminalList['id'];
                    await player.stop();

                    SharedPrefs().setIsFreeTrailUsed(true);
                    isTrialUsed = true;
                  } else {
                    subPlaying = subliminalList['id'];
                    await player.stop();
                    await player.setUrl(subliminalList['audio_path']);
                    !isTrialUsed
                        ? SharedPrefs().setIsFreeTrailUsed(true)
                        : await player.play();

                    !isTrialUsed ? isTrialUsed = true : isTrialUsed;
                    await player.setLoopMode(LoopMode.all);
                  }
                }

                setState(() {
                  if (!player.playing) {
                    isListen = false;
                    bottomMargin = 100;
                  } else {
                    isListen = true;
                    bottomMargin = 200;
                  }

                });
              });*/
            }
          },
          style: ElevatedButton.styleFrom(
            primary: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(right: 10),
                child: Align(
                  alignment: Alignment.center,
                  child: SharedPrefs().getSubPlayingId() == subliminalList['id']
                      ? !SharedPrefs().isSubPlaying()
                          ? Image.asset('assets/images/ic_play.png', scale: 1.5)
                          : Image.asset('assets/images/ic_stop.png', scale: 1.5)
                      : Image.asset('assets/images/ic_play.png', scale: 1.5),
                ),
              ),
              Flexible(
                  child: Text(
                      SharedPrefs().getSubPlayingId() == subliminalList['id']
                          ? buttonPlaying.toUpperCase()
                          : isTrial && !isTrialUsed
                              ? kListenWithTrial.toUpperCase()
                              : kListenNow.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontFamily: 'DPClear',
                        fontWeight: FontWeight.w500,
                      ))),
            ],
          ),
        ));
  }

  Widget buildListenButton(BuildContext context, dynamic subliminalList) {
    return Container(
        padding: const EdgeInsets.only(left: 10, right: 10),
        decoration: kButtonBox10Decoration,
        height: 40,
        child: ElevatedButton(
          onPressed: () {
            if (isTrial && !isTrialUsed && buttonPlaying == kStopNow) {
            } else {
              setState(() {
                isListen = true;
                bottomMargin = 200;
                selectedSubliminal = subliminalList;
                setupServiceLocator(subliminalList['audio_path']);
              });

              setState(() {
                if (kDebugMode) {
                  print(subliminalList['audio_path']);
                  print("isPlaying--${SharedPrefs().isSubPlaying()}");
                }
                if (!SharedPrefs().isSubPlaying() ||
                    SharedPrefs().isSubPlaying() != null) {
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
                      .then((value) => setState(() {
                            isLoading = false;
                          }));
                  changeName(kStopNow, true);
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
                    // player.stop();

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
                        .then((value) => setState(() {
                              isLoading = false;
                            }));

                    changeName(kStopNow, true);
                  }
                }
              });

              /* setState(() {
              isListen = true;
              bottomMargin = 200;
              selectedSubliminal = subliminalList;
              setupServiceLocator(subliminalList['audio_path']);
            });

            setState(() {
              _getSubliminalListData(widget.categoryId);
            });
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
            });*/
            }
          },
          style: ElevatedButton.styleFrom(
            primary: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(right: 10),
                child: Align(
                  alignment: Alignment.center,
                  child: SharedPrefs().getSubPlayingId() == subliminalList['id']
                      ? !SharedPrefs().isSubPlaying()
                          ? Image.asset('assets/images/ic_play.png', scale: 1.5)
                          : Image.asset('assets/images/ic_stop.png', scale: 1.5)
                      : Image.asset('assets/images/ic_play.png', scale: 1.5),
                ),
              ),
              Flexible(
                  child: Text(
                      SharedPrefs().getSubPlayingId() == subliminalList['id']
                          ? buttonPlaying.toUpperCase()
                          : isTrial && !isTrialUsed
                              ? kListenWithTrial.toUpperCase()
                              : kListenNow.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontFamily: 'DPClear',
                        fontWeight: FontWeight.w500,
                      ))),
            ],
          ),
        ));
  }

  Widget buildDownloadButton(dynamic subliminalList) {
    return GestureDetector(
      onTap: () => {
        setState(() async {
          downloadFile(subliminalList['audio_path']);
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

  void downloadFile(String url) {}

  Widget buildBuyNowButton(BuildContext context, dynamic subliminalList) {
    return Container(
      padding: EdgeInsets.only(
          left: buttonInternalPadding, right: buttonInternalPadding),
      decoration: kButtonBox10Decoration,
      height: 40,
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
        },
        style: ElevatedButton.styleFrom(
          primary: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(right: 10),
              child: Align(
                alignment: Alignment.center,
                child: Image.asset('assets/images/ic_bag_tick.png', scale: 2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                right: 20,
              ),
              child: Text('buy now'.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'DPClear',
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
