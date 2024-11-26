import 'dart:collection';

/*import 'dart:html' as html;*/

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_share_me/flutter_share_me.dart';
import 'package:go_router/go_router.dart';
import 'package:readmore/readmore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:success_subliminal/pages/library_new_page.dart';
import 'package:success_subliminal/pages/web_pages/buy_subliminal_web_page.dart';
import 'package:success_subliminal/widget/ButtonWidget.dart';

import '../../app/router.dart';
import '../../data/api/ApiService.dart';
import '../../dialogs/custom_alert_dialog.dart';
import '../../utils/AudioPlayerHandler.dart';
import '../../utils/center_loader.dart';
import '../../utils/constant.dart';
import '../../utils/service_locator.dart';
import '../../utils/shared_prefs.dart';
import '../../utils/toast.dart';
import '../../widget/CommonTextField.dart';
import '../../widget/WebFooterWithoutLinkWidget.dart';
import '../../widget/WebTopBarContainer.dart';
import '../../widget/bottom_audio_player.dart';

class LibraryNewWebPage extends StatefulWidget {
  const LibraryNewWebPage({Key? key}) : super(key: key);

  @override
  _LibraryNewWebPage createState() => _LibraryNewWebPage();
}

class _LibraryNewWebPage extends State<LibraryNewWebPage>
    with WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late List<dynamic> subliminalList = [];
  late dynamic selectSubliminal;
  late List<dynamic> collectionList = [];
  late dynamic subliminal;
  late dynamic deleteSubliminal;
  late dynamic addToCollection;
  late dynamic collection;
  late dynamic createCollection;
  late dynamic deleteCollection;

  bool isSubliminal = false;

  int isSelect = 0;
  int difference = 0;
  Map<bool, int> isSelectList = HashMap();
  final _nameText = TextEditingController();
  final FocusNode _nameFocus = FocusNode();

  String filter = "all";
  String tapBar = "library";
  String filterAll = "wishlist=false&buy=false&my=true";
  String collectionId = "";
  bool isTrial = false;
  bool isTrialUsed = false;
  bool isSubscriptionActive = false;
  bool isLogin = false;
  late dynamic usedFreeTrial;
  Size? mq;
  double leftPadding = 200;
  double rightPadding = 200;
  double descriptionRightPadding = 100;
  double buttonRightPadding = 40;
  double buttonInternalPadding = 10;
  int flexButton = 2;
  int flexDescription = 7;
  int flexImage = 1;

  bool isLoading = false;
  bool isListen = false;
  int subIndex = 0;
  double bottomMargin = 100;
  dynamic selectedSubliminal;
  final AudioPlayerHandler _audioHandler = AudioPlayerHandler("");

  @override
  @override
  void initState() {
    super.initState();
    _getSubliminalListData(filterAll);
    _startPlaybackStateListener();
    initializePreference().whenComplete(() {
      setState(() {
        isTrial = SharedPrefs().isFreeTrail();
        isTrialUsed = SharedPrefs().isFreeTrailUsed();
        isLogin = SharedPrefs().isLogin();

        setState(() {
          if (!isLogin) {
            context.pushReplacement(Routes.home);
          }
        });
      });
    });

    DateTime dateTime = DateTime.now();
    DateTime pickedDate = DateTime.parse(SharedPrefs().getTrialStartDate()!);

    difference = dateTime.difference(pickedDate).inDays;

    if (!player.playing) {
      if (SharedPrefs().isFreeTrail() == true) {
        if (isTrialUsed) {
          changeName(kListenNow, false);
        } else {
          // changeName(kListenWithTrial, false)

          int pos = 0;

          if (subliminalList.isNotEmpty) {
            if (subliminalList.length == 1) {
              pos = 0;
            } else {
              pos = (subliminalList.length - 1);
            }

            subliminalList[0]['creator_id'].toString() !=
                    SharedPrefs().getUserId().toString()
                ? changeName(kListenWithTrial, false)
                : changeName(kListenNow, false);
          }
        }
      } else {
        changeName(kListenNow, false);
      }
    } else {
      changeName(kStopNow, true);
    }
  }

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
      if (kDebugMode) {
        print('buttonPlaying--$buttonPlaying');
        print('isPlaying--$isPlaying');
      }
    });
  }

  void selectItem(bool isSelected, int index) {
    setState(() {
      isSelectList = {isSelected: index};
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
            if (subliminal['http_code'] != 200) {
            } else {
              subliminalList.clear();

              subliminalList.addAll(subliminal['data']['subliminals']);

              if (subliminalList.isNotEmpty) {
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

                // _getCollectionListData("show", mq, subliminalList[0]);
              }
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
            }
            if (kDebugMode) {
              print("size ----$usedFreeTrial");
            }
          });
        }));
  }

  void _getDeleteCollectionData(BuildContext context, String id) async {
    deleteCollection = await ApiService().getDeleteCollection(context, id);

    Future.delayed(const Duration(seconds: 2)).then((value) => setState(() {
          setState(() {
            if (deleteCollection['http_code'] != 200) {
            } else {
              if (deleteCollection['data']['free_trial_status'] == 'true') {}
            }
            Navigator.of(context, rootNavigator: true).pop();
            toast("Collection Deleted", false);
            if (kDebugMode) {
              print("size ----$deleteCollection");
            }
          });
        }));
  }

  void _getCollectionSubliminalListData(String categoryId) async {
    subliminal =
        await ApiService().getCollectionsSubliminalList(context, categoryId);

    Future.delayed(const Duration(seconds: 2))
        .then((value) => setState(() async {
              setState(() {
                if (subliminal['http_code'] != 200) {
                } else {
                  subliminalList.clear();

                  isSubliminal = true;
                  subliminalList.addAll(subliminal['data']['subliminals']);
                }
                print("size ----${subliminalList.length}");
                Navigator.of(context, rootNavigator: true).pop();
                Navigator.of(context, rootNavigator: true).pop();
              });
            }));
  }

  void _getDeleteSubliminalListData(String subId) async {
    deleteSubliminal = await ApiService().getDeleteSubliminal(context, subId);

    Future.delayed(const Duration(seconds: 2))
        .then((value) => setState(() async {
              setState(() {
                if (deleteSubliminal['http_code'] != 200) {
                } else {
                  if (deleteSubliminal['message'] == 'Item Deleted') {
                    _getSubliminalListData(filterAll);
                  } else {
                    toast(deleteSubliminal['message'], false);
                  }

                  Future.delayed(const Duration(seconds: 3))
                      .then((value) => setState(() async {
                            setState(() {
                              Navigator.of(context, rootNavigator: true).pop();
                            });
                          }));
                }
              });
            }));
  }

  void _getCollectionListData(
      String type, Size? mq, dynamic subliminalList) async {
    collection = await ApiService().getCollections(context);

    Future.delayed(const Duration(seconds: 2))
        .then((value) => setState(() async {
              setState(() {
                if (collection['http_code'] != 200) {
                } else {
                  collectionList.clear();

                  collectionList.addAll(collection['data']['collections']);
                  if (type == "create") {
                    Navigator.of(context, rootNavigator: true).pop();
                    Navigator.of(context, rootNavigator: true).pop();
                    Navigator.of(context, rootNavigator: true).pop();
                    buildCollectionDialogContainer(
                        context, subliminalList, mq!);
                  } else {}
                }
                print("size ----${collectionList.length}");
              });
            }));
  }

  void _getCreateCollectionListData(
      String collectionName, dynamic subliminalList, Size mq) async {
    createCollection =
        await ApiService().getCreateCollection(collectionName, context);

    Future.delayed(const Duration(seconds: 1)).then((value) =>
        setState(() async {
          setState(() {
            if (createCollection['http_code'] != 200) {
            } else {
              toast(
                  createCollection['data']['collection']['name'] +
                      ' successfully created',
                  false);
              _getCollectionListData('create', mq, subliminalList);
            }
            print("size ----${createCollection['data']['collection']['name']}");
          });
        }));
  }

  void _getAddToCollectionData(
      String subId, String collectionId, String type) async {
    addToCollection = await ApiService()
        .getAddToCollection(subId, collectionId, type, context);

    Future.delayed(const Duration(seconds: 2))
        .then((value) => setState(() async {
              setState(() {
                if (addToCollection['http_code'] != 200) {
                } else {
                  _getSubliminalListData(filterAll);
                }
                Future.delayed(const Duration(seconds: 2))
                    .then((value) => setState(() async {
                          setState(() {
                            if (filter != "collection") {
                              Navigator.of(context, rootNavigator: true).pop();
                            }
                            if (addToCollection['message'] == 'added') {
                              Navigator.of(context, rootNavigator: true).pop();
                            }
                          });
                        }));
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
                  _getSubliminalListData(filterAll);
                }
                Navigator.of(context, rootNavigator: true).pop();
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
                  _getSubliminalListData(filterAll);
                }
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
        body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            if (constraints.maxWidth > 757) {
              if (constraints.maxWidth < 900) {
                titleTextSize = 50;
                loginTopPadding = 100;
                titleSize = 20;
                descriptionSize = 12;
                leftPadding = 50;
                rightPadding = 50;
                descriptionRightPadding = 30;
                buttonRightPadding = 15;
                buttonInternalPadding = 5;
                flexButton = 3;
                flexDescription = 6;
                flexImage = 2;
              } else if (constraints.maxWidth < 1100) {
                titleTextSize = 55;
                loginTopPadding = 105;
                titleSize = 22;
                descriptionSize = 13;
                leftPadding = 50;
                rightPadding = 50;

                descriptionRightPadding = 30;
                buttonRightPadding = 15;
                buttonInternalPadding = 5;
                flexButton = 3;
                flexDescription = 6;
                flexImage = 2;
              } else if (constraints.maxWidth < 1300) {
                titleTextSize = 60;
                loginTopPadding = 110;
                titleSize = 24;
                descriptionSize = 14;
                leftPadding = 100;
                rightPadding = 100;
                descriptionRightPadding = 40;
                buttonRightPadding = 20;
                buttonInternalPadding = 5;
                flexButton = 2;
                flexDescription = 7;
                flexImage = 1;
              } else if (constraints.maxWidth < 1600) {
                titleTextSize = 65;
                loginTopPadding = 115;
                titleSize = 26;
                descriptionSize = 15;
                leftPadding = 150;
                rightPadding = 150;
                descriptionRightPadding = 60;
                buttonRightPadding = 30;
                buttonInternalPadding = 15;
                flexButton = 2;
                flexDescription = 7;
                flexImage = 1;
              } else if (constraints.maxWidth < 2000) {
                titleTextSize = 70;
                loginTopPadding = 120;
                titleSize = 28;
                descriptionSize = 16;
                leftPadding = 200;
                rightPadding = 200;
                descriptionRightPadding = 100;
                buttonRightPadding = 40;
                buttonInternalPadding = 10;
                flexButton = 2;
                flexDescription = 7;
                flexImage = 1;
              }
              return buildHomeContainer(context, mq);
            } else {
              return const LibraryNewPage();
            }
          },
        )
        //),
        );
  }

  Widget buildHomeContainer(BuildContext context, Size mq) {
    return SafeArea(
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
            const WebTopBarContainer(
              screen: 'library',
            ),
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
                  bottom: bottomMargin,
                  top: loginTopPadding,
                  left: leftPadding,
                  right: rightPadding),
              child: ListView(
                shrinkWrap: false,
                primary: true,
                children: [
                  buildTitleTexContainer(context, mq),
                  buildFilterContainer(context, mq),
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
    );
  }

  Widget buildFilterContainer(BuildContext context, Size mq) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
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
                              fontSize: 20,
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
                              fontSize: 20,
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
              margin: const EdgeInsets.only(left: 20),
              child: filter == "wishlist"
                  ? const Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        'Wishlist',
                        style: TextStyle(
                            fontSize: 20,
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
                            fontSize: 20,
                            color: Colors.white,
                            fontFamily: 'DPClear',
                            fontWeight: FontWeight.w600),
                      ),
                    ),
            ),
          ),
          /*  GestureDetector(
            onTap: () =>
            {
              setState(() {
                //isSubliminal = true;
                //subliminalList.clear();
                filterAll = "wishlist=false&buy=false&my=true";
                buildCollectionListFilterDialogContainer(context, mq);
              })
            },
            child: Container(
              margin: const EdgeInsets.only(left: 20),
              child: filter == "collection"
                  ? const Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'Collections',
                  style: TextStyle(
                      fontSize: 20,
                      color: kTextColor,
                      fontFamily: 'DPClear',
                      fontWeight: FontWeight.w600),
                ),
              )
                  : const Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'Collections',
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontFamily: 'DPClear',
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),*/
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
                margin: const EdgeInsets.only(left: 20),
                child: filter == "categories"
                    ? const Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          'Categories',
                          style: TextStyle(
                              fontSize: 20,
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
                              fontSize: 20,
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
          margin: const EdgeInsets.only(top: 15),
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
                        return buildSubliminalContainer(
                            contexts,
                            kAddToCollectionText,
                            true,
                            subliminalList[index],
                            mq);
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

  Widget buildTitleTexContainer(BuildContext context, Size mq) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: Text(
            'Library',
            style: TextStyle(
                fontSize: titleTextSize,
                color: Colors.white,
                fontFamily: 'DPClear',
                fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget buildBuyNowButton(BuildContext context, dynamic subliminalList) {
    return Container(
        decoration: kButtonBox10Decoration,
        height: 40,
        alignment: Alignment.centerRight,
        width: 250,
        child: ElevatedButton(
          onPressed: () {
            setState(() {
              Navigator.of(context, rootNavigator: true).pop();
              _navigateToBuySubliminalScreen(
                context,
                subliminalList['price'].toString(),
                subliminalList['id'].toString(),
                subliminalList['title'],
                subliminalList['creator_id'].toString(),
                subliminalList['category_name'],
              );
            });
          },
          style: ElevatedButton.styleFrom(
            primary: Colors.transparent,
            shadowColor: Colors.transparent,
            minimumSize: const Size.fromWidth(100),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
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
                      Image.asset('assets/images/ic_bag_tick.png', scale: 1.50),
                ),
              ),
              Text('Buy Now'.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontFamily: 'DPClear',
                    fontWeight: FontWeight.w600,
                  ))
            ],
          ),
        ));
  }

  Widget buildDeleteButton(
      BuildContext context, Size mq, dynamic subliminalList) {
    return Container(
      width: 250,
      margin: const EdgeInsets.only(top: 10),
      child: ButtonWidget(
        name: "Delete Subliminal",
        icon: "assets/images/ic_delete_white.png",
        visibility: true,
        padding: 0,
        onTap: () => {
          showCenterLoader(context),
          _getDeleteSubliminalListData(subliminalList['id'].toString())
        },
        size: 12,
        scale: 7,
        height: 40,
      ),
    );
  }

  Widget buildListenButton(BuildContext context, dynamic subliminalList) {
    return Container(
        decoration: kButtonBox10Decoration,
        height: 40,
        width: 250,
        alignment: Alignment.centerRight,
        child: ElevatedButton(
          onPressed: () {
            setState(() {
              isListen = true;
              bottomMargin = 200;
              selectedSubliminal = subliminalList;

              setupServiceLocator(subliminalList['audio_path']);
              //_audioHandler.audioUrl = subliminalList['audio_path'];
            });

            setState(() {
              if (kDebugMode) {
                print(subliminalList['audio_path']);
                print(SharedPrefs().isSubPlaying());
              }

              if (!SharedPrefs().isSubPlaying()) {
                changeName("Stop Now", true);
                SharedPrefs().setPlayingSubId(subliminalList['id']);
                SharedPrefs().setPlayingSubImage(subliminalList['cover_path']);
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
                // await advancedPlayer.setLoopMode(LoopMode.all);
              } else {
                if (SharedPrefs().getSubPlayingId() == subliminalList['id']) {
                  SharedPrefs().setPlayingSubId(subliminalList['id']);
                  SharedPrefs()
                      .setPlayingSubImage(subliminalList['cover_path']);
                  SharedPrefs().setPlayingSubUrl(subliminalList['audio_path']);
                  // advancedPlayer.setSourceUrl(subliminalList['audio_path']);

                  isLoading = false;

                  changeName("Listen Now", false);
                  // advancedPlayer.stop();
                  player.stop();

                  subliminalList['creator_id'].toString() !=
                          SharedPrefs().getUserId().toString()
                      ? setState(() {
                          SharedPrefs().setIsFreeTrailUsed(true);
                          isTrialUsed = true;
                        })
                      : isTrialUsed;
                } else {
                  //player.stop();
                  changeName("Stop Now", true);
                  SharedPrefs().setPlayingSubId(subliminalList['id']);
                  SharedPrefs()
                      .setPlayingSubImage(subliminalList['cover_path']);
                  SharedPrefs().setPlayingSubUrl(subliminalList['audio_path']);
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

            /* setState(() {
              if (!player.playing) {
                changeName("Stop Now", true);
              } else {
                if (subPlaying == subliminalList['id']) {
                  changeName("Listen Now", false);
                } else {
                  changeName("Stop Now", true);
                }
              }
            });
            setState(() {
              if (kDebugMode) {
                print(subliminalList['audio_path']);
              }

              if (!player.playing) {
                subPlaying = subliminalList['id'];
                player.setUrl(subliminalList['audio_path']);
                player.play();
                player.setLoopMode(LoopMode.off);

                if (kDebugMode) {
                  print('subPlaying--2$subPlaying');
                }
                if (isTrial &&
                    !isTrialUsed &&
                    subliminalList['creator_id'].toString() !=
                        SharedPrefs().getUserId().toString()) {
                  _getUsedFreeTrialData(
                      context, "true", subliminalList['id'].toString());
                }
              } else {
                if (subPlaying == subliminalList['id']) {
                  subPlaying = subliminalList['id'];
                  player.stop();
                  subliminalList['creator_id'].toString() !=
                          SharedPrefs().getUserId().toString()
                      ? setState(() {
                          SharedPrefs().setIsFreeTrailUsed(true);
                          isTrialUsed = true;
                        })
                      : isTrialUsed;
                } else {
                  subPlaying = subliminalList['id'];
                  player.stop();

                  player.setUrl(subliminalList['audio_path']);
                  subliminalList['creator_id'].toString() !=
                              SharedPrefs().getUserId().toString() &&
                          !isTrialUsed
                      ? setState(() {
                          SharedPrefs().setIsFreeTrailUsed(true);
                          isTrialUsed = true;
                        })
                      : player.play();
                  player.setLoopMode(LoopMode.off);
                }
              }
            });*/
          },
          style: ElevatedButton.styleFrom(
            primary: Colors.transparent,
            shadowColor: Colors.transparent,
            minimumSize: const Size.fromWidth(100),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.only(right: buttonInternalPadding),
                child: Align(
                    alignment: Alignment.center,
                    child: SharedPrefs().getSubPlayingId() ==
                            subliminalList['id']
                        ? !SharedPrefs().isSubPlaying()
                            ? Image.asset('assets/images/ic_play.png',
                                scale: 1.5)
                            : Image.asset('assets/images/ic_stop.png',
                                scale: 1.5)
                        : Image.asset('assets/images/ic_play.png', scale: 1.5)),
              ),
              Flexible(
                  child: Text(
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
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontFamily: 'DPClear',
                        fontWeight: FontWeight.w500,
                      )))
            ],
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
              player.stop();
              Navigator.pop(context);
              setState(() {
                changeName("Listen Now", false);
              });
            },
            style: ElevatedButton.styleFrom(
              primary: Colors.black,
              onPrimary: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
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

  buildCollectionDialogContainer(
      BuildContext contexts, dynamic subliminalList, Size mq) {
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
                child: SingleChildScrollView(
                    child: SizedBox(
                  width: mq.width * 0.3,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              alignment: Alignment.topLeft,
                              margin: const EdgeInsets.only(left: 10, top: 10),
                              child: const Text(
                                "Collection List",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontFamily: 'DPClear',
                                  fontWeight: FontWeight.w500,
                                ),
                                softWrap: true,
                              ),
                            ),
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () => {
                                  Navigator.of(context, rootNavigator: true)
                                      .pop()
                                },
                                child: Align(
                                  alignment: Alignment.topRight,
                                  child: Container(
                                      alignment: Alignment.topLeft,
                                      margin: const EdgeInsets.only(right: 10),
                                      child: Image.asset(
                                          'assets/images/ic_close_btn.png',
                                          scale: 3)),
                                ),
                              ),
                            ),
                          ]),
                      buildCollectionListContainer(
                          context, subliminalList, false, mq),
                      MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                              onTap: () => {
                                    setState(() {
                                      _nameText.text = "";
                                      buildCreateCollectionDialogContainer(
                                          context, subliminalList, mq);
                                    })
                                  },
                              child: Container(
                                alignment: Alignment.topLeft,
                                margin:
                                    const EdgeInsets.only(left: 10, top: 20),
                                child: const Text(
                                  "+Add new ",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.blue,
                                    fontFamily: 'DPClear',
                                    fontWeight: FontWeight.w500,
                                  ),
                                  softWrap: true,
                                ),
                              ))),
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () => {
                            setState(() {
                              showCenterLoader(context);
                              _getAddToCollectionData(
                                  subliminalList['id'].toString(),
                                  collectionId,
                                  "add");
                            })
                          },
                          child: Container(
                            height: 50,
                            decoration: kTransButtonBoxDecoration,
                            margin: const EdgeInsets.only(
                                top: 20, left: 10, right: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  margin: const EdgeInsets.only(left: 10),
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Image.asset(
                                        'assets/images/ic_edit.png',
                                        scale: 1.5),
                                  ),
                                ),
                                Container(
                                  alignment: Alignment.center,
                                  margin: const EdgeInsets.only(
                                      left: 10, right: 10),
                                  child: Text(
                                    "add to collection".toUpperCase(),
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
                        ),
                      )
                    ],
                  ),
                )),
              ));
        });
  }

  buildCollectionListFilterDialogContainer(BuildContext contexts, Size mq) {
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
              child: SizedBox(
                width: mq.width * 0.3,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            alignment: Alignment.topLeft,
                            margin: const EdgeInsets.only(left: 10, top: 10),
                            child: const Text(
                              "Select Collection",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontFamily: 'DPClear',
                                fontWeight: FontWeight.w500,
                              ),
                              softWrap: true,
                            ),
                          ),
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () => {
                                Navigator.of(context, rootNavigator: true).pop()
                              },
                              child: Align(
                                alignment: Alignment.topRight,
                                child: Container(
                                    alignment: Alignment.topLeft,
                                    margin: const EdgeInsets.only(right: 10),
                                    child: Image.asset(
                                        'assets/images/ic_close_btn.png',
                                        scale: 3)),
                              ),
                            ),
                          ),
                        ]),
                    buildCollectionListContainer(
                        context, subliminalList, true, mq),
                  ],
                ),
              ),
            ),
          );
        });
  }

  buildCreateCollectionDialogContainer(
      BuildContext contexts, dynamic subliminalList, Size mq) {
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
                child: SizedBox(
                  width: mq.width * 0.3,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        alignment: Alignment.center,
                        child: const Text(
                          "Create Collection",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontFamily: 'DPClear',
                            fontWeight: FontWeight.w500,
                          ),
                          softWrap: true,
                        ),
                      ),
                      Container(
                        alignment: Alignment.topLeft,
                        margin: const EdgeInsets.only(top: 10),
                        child: const Text(
                          "Name",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontFamily: 'DPClear',
                            fontWeight: FontWeight.w500,
                          ),
                          softWrap: true,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 10),
                        decoration: kEditTextDecoration,
                        child: CommonTextField(
                          controller: _nameText,
                          hintText: kEnterCollectionName,
                          text: "",
                          isFocused: true,
                          isDeco: true,
                          textColor: Colors.white,
                          focus: _nameFocus,
                        ),
                      ),
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () => {
                            setState(() {
                              if (_nameText.text.toString().isEmpty) {
                                const CustomAlertDialog().errorDialog(
                                    kCollectionNameNullError, context);
                              } else {
                                showCenterLoader(context);
                                _getCreateCollectionListData(
                                    _nameText.text.toString(),
                                    subliminalList,
                                    mq);
                              }
                            })
                          },
                          child: Container(
                            height: 50,
                            decoration: kTransButtonBoxDecoration,
                            margin: const EdgeInsets.only(top: 20),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  margin: const EdgeInsets.only(left: 10),
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Image.asset(
                                        'assets/images/ic_edit.png',
                                        scale: 1.5),
                                  ),
                                ),
                                Container(
                                  alignment: Alignment.center,
                                  margin: const EdgeInsets.only(
                                      left: 10, right: 10),
                                  child: Text(
                                    "Create new collection".toUpperCase(),
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
                        ),
                      ),
                      buildCloseButton(context)
                    ],
                  ),
                ),
              ));
        });
  }

  Widget buildCollectionListContainer(BuildContext contexts, dynamic subliminal,
      bool isFilterCollection, Size mq) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          (collectionList.isNotEmpty)
              ? ListView.builder(
                  shrinkWrap: true,
                  primary: false,
                  itemCount: collectionList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return buildCollectionItemContainer(
                        contexts,
                        collectionList[index],
                        index,
                        subliminal,
                        isFilterCollection,
                        mq);
                  })
              : const Align(
                  alignment: Alignment.center,
                  child: Text(
                    "No Collections!",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontFamily: 'DPClear',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget buildCollectionItemContainer(
      BuildContext context,
      dynamic collectionList,
      int index,
      dynamic subliminal,
      bool isFilterCollection,
      Size mq) {
    collectionId = collectionList['id'].toString();
    return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => {
            if (isFilterCollection)
              {
                setState(() {
                  filter = "collection";
                }),
                collectionId = collectionList['id'].toString(),
                isSelect = index,
                showCenterLoader(context),
                _getCollectionSubliminalListData("collection_id=$collectionId"),
              }
            else
              {
                collectionId = collectionList['id'].toString(),
                isSelect = index,
                //toast(collectionList['name'] + ' is select', false),
                Navigator.pop(context),
                buildCollectionDialogContainer(context, subliminal, mq)
              }
          },
          child: Container(
            padding: const EdgeInsets.all(15),
            margin: const EdgeInsets.only(left: 5, right: 5, top: 10),
            decoration: isSelect != index
                ? kUnSelectedCollectionBoxDecoration
                : kSelectedCollectionBoxDecoration,
            child: Container(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Align(
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        collectionList['name'],
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontFamily: 'DPClear',
                          fontWeight: FontWeight.w500,
                        ),
                        softWrap: true,
                      ),
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () => {
                            setState(() {
                              showCenterLoader(context);
                              _getDeleteCollectionData(
                                  context, collectionList['id'].toString());
                            })
                          },
                          child: Align(
                            alignment: Alignment.topRight,
                            child: Container(
                                alignment: Alignment.topLeft,
                                margin: const EdgeInsets.only(right: 10),
                                child: Image.asset(
                                  'assets/images/ic_delete.png',
                                  scale: 7,
                                  color: Colors.white,
                                )),
                          ),
                        ),
                      ),
                    ],
                  )),
            ),
          ),
        ));
  }

  Widget buildSubliminalContainer(BuildContext context, String buttonName,
      bool isWish, dynamic subliminalList, Size mq) {
    return Container(
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.only(top: 10),
      decoration: kAllCornerBoxDecoration2,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
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
                          ? Image.network(
                              subliminalList['cover_path'],
                              fit: BoxFit.cover,
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
                              fit: BoxFit.fill,
                            ),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: flexDescription,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
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
                          left: 50,
                          right: descriptionRightPadding,
                          bottom: 10,
                        ),
                        alignment: Alignment.topLeft,
                        child: Column(
                          children: [
                            Align(
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
                                  ),
                                ) /*Text(
                                subliminalList['description'],
                                style: TextStyle(
                                  fontSize: descriptionSize,
                                  color: Colors.white54,
                                  fontFamily: 'DPClear',
                                  fontWeight: FontWeight.w400,
                                ),
                                softWrap: true,
                              ),*/
                                ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(left: 50, right: 20),
                        child:
                            buildButtonsContainer(context, subliminalList, mq),
                      )
                    ]),
              ),
              Expanded(
                flex: flexButton,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    (subliminalList['creator_id'].toString() !=
                            SharedPrefs().getUserId())
                        ? (isTrial && !isTrialUsed && difference < 8) ||
                                subliminalList['buyed'] ||
                                subliminalList['Is_free_trial'] == 1 ||
                                filter == 'all' ||
                                filter == 'collection'
                            ? buildListenButton(context, subliminalList)
                            : buildBuyNowButton(context, subliminalList)
                        : buildListenButton(context, subliminalList),

                    (subliminalList['creator_id'].toString() ==
                                SharedPrefs().getUserId() &&
                            filter == 'all')
                        ? buildDeleteButton(context, mq, subliminalList)
                        : const SizedBox(),
                    //  buildDownloadButton(subliminalList)
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildCheckTab(dynamic subliminalList, Size mq) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth > 900) {
          return Container(
              margin: const EdgeInsets.only(
                left: 50,
              ),
              child: buildButtonsContainer(context, subliminalList, mq));
        } else {
          return Container(
              margin: const EdgeInsets.only(
                left: 50,
              ),
              child: buildTabButtonsContainer(context, subliminalList, mq));
        }
      },
    );
  }

  void downloadFile(String url) {}

  Widget buildDownloadButton(dynamic subliminalList) {
    return GestureDetector(
      onTap: () => {
        setState(() async {
          downloadFile(subliminalList['audio_path']);
        })
      },
      child: Container(
        height: 40,
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
                child: Image.asset('assets/images/ic_download.png', scale: 3),
              ),
            ),
            // Container(
            //   alignment: Alignment.center,
            //   margin: const EdgeInsets.only(left: 10, right: 10),
            //   child: Text(
            //     "download",
            //     style: const TextStyle(
            //       fontSize: 5,
            //       color: Colors.white,
            //       fontFamily: 'DPClear',
            //       fontWeight: FontWeight.w500,
            //     ),
            //     softWrap: true,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget buildButtonsContainer(
      BuildContext context, dynamic subliminalList, Size mq) {
    return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SharedPrefs().getUserId() !=
                      subliminalList['creator_id'].toString() &&
                  filter == 'wishlist'
              ? GestureDetector(
                  onTap: () => {
                    setState(() {
                      showCenterLoader(context);
                      if (subliminalList['wishlist'] == true) {
                        _getRemoveWishListData(subliminalList['id'].toString());
                      } else {
                        _getAddWishListData(subliminalList['id'].toString());
                      }
                    })
                  },
                  child: Container(
                    height: 40,
                    decoration: kTransButtonBoxDecoration,
                    margin: const EdgeInsets.only(top: 10, right: 10),
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Align(
                          child: subliminalList['wishlist']
                              ? Image.asset('assets/images/ic_heart_empty.png',
                                  color: kTextColor, scale: 1.5)
                              : Image.asset('assets/images/ic_heart_empty.png',
                                  scale: 1.5),
                        ),
                        Container(
                          alignment: Alignment.center,
                          margin: const EdgeInsets.only(left: 5),
                          child: Text(
                            !subliminalList['wishlist']
                                ? "Add to wishlist".toUpperCase()
                                : "Remove from wishlist".toUpperCase(),
                            style: const TextStyle(
                              fontSize: 10,
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
                )
              : const SizedBox(),
/*          GestureDetector(
            onTap: () => {
              setState(() {
                if (subliminalList['added_collection'] == true) {
                  showCenterLoader(context);
                  String type = "remove";
                  _getAddToCollectionData(subliminalList['id'].toString(),
                      subliminalList['collection_id'].toString(), type);
                } else {
                  buildCollectionDialogContainer(context, subliminalList, mq);
                }
              })
            },
            child: Container(
              height: 40,
              decoration: kTransButtonBoxDecoration,
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Align(
                    alignment: Alignment.center,
                    child: Image.asset('assets/images/ic_edit.png', scale: 1.5),
                  ),
                  Container(
                    height: 50,
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(left: 5),
                    child: Text(
                      subliminalList["added_collection"] == true
                          ? "Remove From collection".toUpperCase()
                          : "add to collection".toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10,
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
          )*/
          Container(
            margin: const EdgeInsets.only(left: 5, top: 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  height: 50,
                  alignment: Alignment.center,
                  margin: const EdgeInsets.only(right: 10, bottom: 10),
                  child: Text(
                    'Share'.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontFamily: 'DPClear',
                      fontWeight: FontWeight.w500,
                    ),
                    softWrap: true,
                  ),
                ),
                GestureDetector(
                  onTap: () => {
                    toast("Copied", false),
                    Clipboard.setData(ClipboardData(
                        text:
                            "${sharingContent1}https://successsubliminals.net/start-trial?subliminal_id=${subliminalList['id']}$sharingContent"

                        /*  subliminalList['title'] +
                            "\n" +
                            subliminalList['description'] +
                            "\n\n" +
                            subliminalList['audio_path'])*/
                        ))
                  },
                  child: Container(
                    margin: const EdgeInsets.only(left: 5, top: 5),
                    height: 40,
                    width: 40,
                    decoration: kTransButtonBoxDecoration,
                    alignment: Alignment.topRight,
                    child: Align(
                      alignment: Alignment.center,
                      child: Image.asset('assets/images/ic_attachment.png',
                          scale: 1.5),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => {
                    setState(() async {
                      //String url = subliminalList['audio_path'];
                      //String title = subliminalList['title'];

                      String url =
                          "https://successsubliminals.net/start-trial?subliminal_id=${subliminalList['id']}"; //subliminalList['audio_path'];
                      String title =
                          "${sharingContent1}https://successsubliminals.net/start-trial?subliminal_id=${subliminalList['id']}$sharingContent"; //subliminalList['title'];
                      launchFacebookURL(url, title);
                    }),
                  },
                  child: Container(
                    margin: const EdgeInsets.only(left: 5, top: 5),
                    height: 40,
                    width: 40,
                    decoration: kTransButtonBoxDecoration,
                    alignment: Alignment.topRight,
                    child: Align(
                      alignment: Alignment.center,
                      child: Image.asset('assets/images/ic_fb.png', scale: 1.5),
                    ),
                  ),
                ),
                GestureDetector(
                    onTap: () => {
                          setState(() async {
                            String url =
                                "https://successsubliminals.net/start-trial?subliminal_id=${subliminalList['id']}"; //subliminalList['audio_path'];
                            String title =
                                "${sharingContent1}https://successsubliminals.net/start-trial?subliminal_id=${subliminalList['id']}$sharingContent2"; //subliminalList['title'];

                            launchTwitterURL("", title);
                          })
                        },
                    child: Container(
                      margin: const EdgeInsets.only(left: 5, top: 5),
                      height: 40,
                      width: 40,
                      decoration: kTransButtonBoxDecoration,
                      alignment: Alignment.topRight,
                      child: Align(
                        alignment: Alignment.center,
                        child: Image.asset('assets/images/ic_twitter.png',
                            scale: 1.5),
                      ),
                    ))
              ],
            ),
          ),
        ]);
  }

  Widget buildTabButtonsContainer(
      BuildContext context, dynamic subliminalList, Size mq) {
    return Wrap(runSpacing: 5.0, spacing: 5.0, children: <Widget>[
      GestureDetector(
        onTap: () => {
          setState(() {
            showCenterLoader(context);
            if (subliminalList['wishlist'] == true) {
              _getRemoveWishListData(subliminalList['id'].toString());
            } else {
              _getAddWishListData(subliminalList['id'].toString());
            }
          })
        },
        child: Container(
          height: 40,
          decoration: kTransButtonBoxDecoration,
          margin: const EdgeInsets.only(
            top: 10,
          ),
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Align(
                child: subliminalList['wishlist']
                    ? Image.asset('assets/images/ic_heart_empty.png',
                        color: kTextColor, scale: 1.5)
                    : Image.asset('assets/images/ic_heart_empty.png',
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
                    fontSize: 10,
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
      ),
      GestureDetector(
        onTap: () => {
          setState(() {
            if (subliminalList['added_collection'] == true) {
              showCenterLoader(context);
              String type = "remove";
              _getAddToCollectionData(subliminalList['id'].toString(),
                  subliminalList['collection_id'].toString(), type);
            } else {
              buildCollectionDialogContainer(context, subliminalList, mq);
            }
          })
        },
        child: Container(
          height: 40,
          decoration: kTransButtonBoxDecoration,
          margin: const EdgeInsets.only(top: 10, left: 10),
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Align(
                alignment: Alignment.center,
                child: Image.asset('assets/images/ic_edit.png', scale: 1.5),
              ),
              Container(
                height: 50,
                alignment: Alignment.center,
                margin: const EdgeInsets.only(left: 10),
                child: Text(
                  subliminalList["added_collection"] == true
                      ? "Remove From collection".toUpperCase()
                      : "add to collection".toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
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
      ),
      Container(
        margin: const EdgeInsets.only(left: 5, top: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              height: 50,
              alignment: Alignment.center,
              margin: const EdgeInsets.only(left: 20, right: 10, bottom: 10),
              child: Text(
                'Share'.toUpperCase(),
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  fontFamily: 'DPClear',
                  fontWeight: FontWeight.w500,
                ),
                softWrap: true,
              ),
            ),
            GestureDetector(
              onTap: () => {
                toast("Copied", false),
                Clipboard.setData(ClipboardData(
                    text: subliminalList['title'] +
                        "\n" +
                        subliminalList['description'] +
                        "\n\n" +
                        subliminalList['audio_path']))
              },
              child: Container(
                margin: const EdgeInsets.only(left: 5, top: 5),
                height: 40,
                width: 40,
                decoration: kTransButtonBoxDecoration,
                alignment: Alignment.topRight,
                child: Align(
                  alignment: Alignment.center,
                  child: Image.asset('assets/images/ic_attachment.png',
                      scale: 1.5),
                ),
              ),
            ),
            GestureDetector(
              onTap: () => {
                FlutterShareMe().shareToFacebook(
                    url: subliminalList['audio_path'],
                    msg: subliminalList['description'])
              },
              child: Container(
                margin: const EdgeInsets.only(left: 5, top: 5),
                height: 40,
                width: 40,
                decoration: kTransButtonBoxDecoration,
                alignment: Alignment.topRight,
                child: Align(
                  alignment: Alignment.center,
                  child: Image.asset('assets/images/ic_fb.png', scale: 1.5),
                ),
              ),
            ),
            GestureDetector(
                onTap: () => {
                      FlutterShareMe().shareToTwitter(
                          url: subliminalList['audio_path'],
                          msg: subliminalList['description'])
                    },
                child: Container(
                  margin: const EdgeInsets.only(left: 5, top: 5),
                  height: 40,
                  width: 40,
                  decoration: kTransButtonBoxDecoration,
                  alignment: Alignment.topRight,
                  child: Align(
                    alignment: Alignment.center,
                    child:
                        Image.asset('assets/images/ic_twitter.png', scale: 1.5),
                  ),
                ))
          ],
        ),
      ),
    ]);
  }

  void _navigateToBuySubliminalScreen(
    BuildContext context,
    String price,
    String subId,
    String subName,
    String catId,
    String catName,
  ) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (c, a1, a2) => BuySubliminalWebPage(
          amount: price,
          subId: subId,
          subName: subName,
          catId: catId,
          catName: catName,
          screen: "library",
        ),
        transitionsBuilder: (c, anim, a2, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }
}
