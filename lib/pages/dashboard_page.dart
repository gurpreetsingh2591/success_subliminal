import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

import '../app/router.dart';
import '../data/api/ApiService.dart';
import '../dialogs/custom_alert_dialog.dart';
import '../utils/center_loader.dart';
import '../utils/constant.dart';
import '../utils/shared_prefs.dart';
import '../widget/BottomBarStateFullWidget.dart';
import '../widget/ButtonWidget.dart';

class DashBoardPage extends StatefulWidget {
  DashBoardPage({Key? key}) : super(key: key);

  @override
  _DashBoardPage createState() => _DashBoardPage();
}

class _DashBoardPage extends State<DashBoardPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  var refreshKey = GlobalKey<RefreshIndicatorState>();

  var controller;
  final _emailText = TextEditingController();
  List<dynamic> categoriesList = [];
  late dynamic categories;
  String categoryId = "";
  late List<dynamic> subliminalList = [];
  late dynamic subliminal;
  late dynamic sendEmail;
  int selectIndex = 0;
  bool isSubliminal = false;
  List<dynamic> testimonialsList = [];
  late dynamic testimonials;
  late dynamic cancelSubscription;
  late VideoPlayerController _controllers;
  late dynamic usedFreeTrial;

  List<dynamic> subscriptionList = [];
  List<dynamic> subscriptionPriceList = [];
  late dynamic subscription;
  String amount = "";
  String plan = "";
  String isSubscriptionStatusActive = "";
  bool isFreeTrialUsed = false;
  bool isLogin = false;
  bool isTrial = false;
  bool isSubscriptionActive = false;

  @override
  void initState() {
    super.initState();

    _controllers = VideoPlayerController.network('')
      ..initialize().then((_) {
        setState(() {
          _controllers.seekTo(const Duration(seconds: 1));
          _controllers.pause();
        });
      });

    initializePreference().whenComplete(() {
      setState(() {
        isLogin = SharedPrefs().isLogin();
        isTrial = SharedPrefs().isFreeTrail();
        isSubscriptionActive = SharedPrefs().isSubscription();
        isFreeTrialUsed = SharedPrefs().isFreeTrailUsed();
        isSubscriptionStatusActive =
            SharedPrefs().getSubscriptionStatus().toString();
      });
    });

    changeScreenName('dashboard');
    _getCategoriesData();
  }

  changeScreenName(String name) {
    setState(() {
      screenName = name;
    });
  }


  void _getCancelSubscriptionData() async {
    cancelSubscription = await ApiService().getCancelSubscription(
        context, SharedPrefs().getUserSubscriptionId().toString());

    Future.delayed(const Duration(seconds: 2))
        .then((value) =>
        setState(() {
          setState(() {
            Navigator.of(context, rootNavigator: true).pop();
            if (cancelSubscription['http_code'] != 200) {} else {
              cancelSubscription = cancelSubscription['message'];

              if (cancelSubscription == null || isTrial) {
                SharedPrefs().setIsSubscriptionStatus('canceled');
                setState(() {
                  isSubscriptionStatusActive =
                      SharedPrefs().getSubscriptionStatus().toString();
                });
              } else {
                setState(() {
                  _getIsUserSubscription();
                });
              }

              const CustomAlertDialog().errorDialog(
                  'Your subscription has been canceled', context);
            }
          });
        }));
  }

  _handleOnYesSubscription() {
    Navigator.of(context, rootNavigator: true).pop();
    showCenterLoader(context);
    _getCancelSubscriptionData();
  }

  _handleOnCancelButton() {
    Navigator.of(context, rootNavigator: true).pop();
  }

  void _getIsUserSubscription() {
    setState(() {
      if (cancelSubscription['subscription_status'] == "trialing") {
        setState(() {
          SharedPrefs().setIsFreeTrail(true);
          isTrial = SharedPrefs().isFreeTrail();
        });
      } else if (cancelSubscription['subscription_status'] == "active") {
        setState(() {
          SharedPrefs().setIsSubscription(true);

          isSubscriptionActive = SharedPrefs().isSubscription();
        });
      } else if (cancelSubscription['subscription_status'] == "canceled") {
        setState(() {
          SharedPrefs().setIsFreeTrail(false);
          SharedPrefs().setIsSubscription(false);
          SharedPrefs().setIsFreeTrailUsed(true);
          SharedPrefs().setUserPlanId('');
          SharedPrefs().setUserSubscriptionId('');
          SharedPrefs().setSubscriptionEndDate('');
          SharedPrefs().setSubscriptionStartDate('');

          isTrial = SharedPrefs().isFreeTrail();
          isSubscriptionActive = SharedPrefs().isSubscription();
        });
      }
      SharedPrefs().setIsSubscriptionStatus(cancelSubscription['status']);

      setState(() {
        isSubscriptionStatusActive =
            SharedPrefs().getSubscriptionStatus().toString();
      });
    });
  }

  void _getSubliminalListData(String categoryId) async {
    subliminal =
    await ApiService().getDiscoverSubliminalList(context, categoryId);

    Future.delayed(const Duration(seconds: 2)).then((value) =>
        setState(() {
          isSubliminal = true;
          subliminalList.clear();
          if (subliminal['http_code'] != 200) {} else {
            setState(() {
              subliminalList.addAll(subliminal['data']['subliminals']);
            });
          }
        }));
  }


  void _getCategoriesData() async {
    categories = await ApiService().getCategories(context);

    Future.delayed(const Duration(seconds: 1)).then((value) =>
        setState(() {
          if (categories['http_code'] != 200) {} else {
            setState(() {
              categoriesList.addAll(categories['data']['categories']);
              categoryId = categories['data']['categories'][0]['id'].toString();
              _getSubliminalListData(categoryId);
            });
          }
        }));
  }


  Future<void> initializePreference() async {
    SharedPrefs.init(await SharedPreferences.getInstance());
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
      body: RefreshIndicator(
        key: refreshKey,
        color: Colors.white,
        onRefresh: () async {
          _getCategoriesData();
          initializePreference().whenComplete(() {
            isLogin = SharedPrefs().isLogin();
            isTrial = SharedPrefs().isFreeTrail();
          });
        },
        child: SafeArea(
          // child: SingleChildScrollView(
          child: Container(
              constraints: BoxConstraints(
                maxHeight: mq.height,
              ),
              /* decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [backgroundDark, backgroundDark],
                  stops: [0.5, 1.5],
                ),
              ),*/
              child: Stack(children: [
                Image.asset(
                  'assets/images/bg_image.png',
                  fit: BoxFit.cover,
                  height: double.infinity,
                  width: double.infinity,
                  alignment: Alignment.center,
                ),
                // buildBottomBar(context, 'dashboard'),
                buildTopBarContainer(context, mq),
                const BottomBarStateFull(
                    screen: "dashboard", isUserLogin: true),
                buildTermsContainer(context),
                Container(
                  padding: const EdgeInsets.only(bottom: 150, top: 100),
                  child: ListView(
                    shrinkWrap: false,
                    primary: false,
                    children: [
                      buildDiscoverBarContainer(context),
                    ],
                  ),
                )
              ])),
        ),
      ),
    );
  }

  Widget buildDiscoverBarContainer(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20, top: 20),
      decoration: kAllCornerBackgroundBoxDecoration,
      child: Container(
        padding:
        const EdgeInsets.only(top: 20, bottom: 20, left: 10, right: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            RichText(
              textAlign: TextAlign.start,
              text: const TextSpan(
                text: "Discover",
                style: TextStyle(
                    fontSize: 26,
                    color: Colors.white,
                    fontFamily: 'DPClear',
                    fontWeight: FontWeight.w600),
                /*defining default style is optional */
                children: <TextSpan>[
                  TextSpan(
                      text: " Subliminal",
                      style: TextStyle(
                          fontSize: 26,
                          color: kYellow,
                          fontFamily: 'DPClear',
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            categoriesList.isNotEmpty
                ? buildCategoriesListContainer(context)
                : const Text(""),
            isSubliminal
                ? buildSubliminalListWithCatContainer(context)
                : const SizedBox(
                height: 100,
                child: Center(child: CircularProgressIndicator())),
          ],
        ),
      ),
    );
  }

  Widget buildCategoriesListContainer(BuildContext context) {
    return (categoriesList.isNotEmpty)
        ? Align(
        alignment: Alignment.topLeft,
        child: Container(
            padding: const EdgeInsets.only(left: 10, right: 10),
            height: 80,
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                primary: false,
                itemCount: categoriesList.length,
                itemBuilder: (BuildContext context, int index) {
                  return buildCategoryListItem(
                      context,
                      categoriesList[index]['name'],
                      categoriesList[index]['id'].toString(),
                      index);
                })))
        : Container(
        margin: const EdgeInsets.only(top: 10),
        child: const Align(
          alignment: Alignment.center,
          child: Text(
            "No Categories",
            style: TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontFamily: 'DPClear',
                fontWeight: FontWeight.w600),
          ),
        ));
  }

  Widget buildSubliminalListWithCatContainer(BuildContext context) {
    return (subliminalList.isNotEmpty)
        ? Align(
        alignment: Alignment.topLeft,
        child: Container(
            margin: const EdgeInsets.only(left: 10, right: 10),
            child: GridView.builder(
                reverse: false,
                shrinkWrap: true,
                primary: false,
                itemCount: subliminalList.length,
                itemBuilder: (BuildContext context, int index) {
                  return buildSubliminalListItem(
                    context,
                    subliminalList[index],
                  );
                },
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 2 / 2.2,
                ))))
        : const Align(
      alignment: Alignment.center,
      child: Text(
        kComingSoon,
        style: TextStyle(
            fontSize: 24,
            color: Colors.white,
            fontFamily: 'DPClear',
            fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget buildCategoryListItem(BuildContext context, String name, String id,
      int index) {
    return GestureDetector(
        onTap: () =>
        {
          setState(() {
            isSubliminal = false;
            selectIndex = index;
            categoryId = id;
            _getSubliminalListData(categoryId);
          })
        },
        child: Align(
            alignment: Alignment.topCenter,
            child: Container(
                alignment: Alignment.topCenter,
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        alignment: Alignment.topCenter,
                        height: 40,
                        margin:
                        const EdgeInsets.only(left: 5, right: 5, top: 25),
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        decoration: selectIndex == index
                            ? kButtonBoxDecoration
                            : kBlackButtonBoxDecoration,
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            name.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontFamily: 'DPClear',
                                fontWeight: FontWeight.w400),
                          ),
                        ),
                      ),
                      Visibility(
                          visible: selectIndex == index,
                          child: Container(
                            alignment: Alignment.topCenter,
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: Image.asset(
                                'assets/images/ic_bottom_arrow.png',
                                scale: 1.5,
                              ),
                            ),
                          ))
                    ]))));
  }

  Widget buildSubliminalListItem(BuildContext context, dynamic subliminalList) {
    return GestureDetector(
      onTap: () =>
      {
        context.pushNamed('discover-subliminals-detail', queryParameters: {
          'subName': subliminalList['title'],
          'subId': subliminalList['id'].toString(),
          "categoryName": "",
          "catId": "",
        })
      },
      child: Container(
        margin: const EdgeInsets.only(left: 5, right: 5, top: 10),
        padding: const EdgeInsets.all(10),
        decoration: kAllCornerBackgroundBox20Decoration,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
                width: 140,
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: Align(
                      alignment: Alignment.center,
                      child: subliminalList['cover_path'] != ''
                          ? FadeInImage.assetNetwork(
                        placeholder: 'assets/images/bg_logo_image.png',
                        placeholderCacheHeight: 120,
                        placeholderCacheWidth: 140,
                        fit: BoxFit.cover,
                        image: subliminalList['cover_path'],
                      )
                          : Image.asset(
                        'assets/images/bg_logo_image.png',
                        fit: BoxFit.cover,
                        height: 120,
                        width: 140,
                      ),
                    ))),
            Container(
              width: 140,
              padding: const EdgeInsets.only(top: 5),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  subliminalList['title'],
                  maxLines: 1,
                  style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontFamily: 'DPClear',
                      fontWeight: FontWeight.w400),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }


  Widget buildTermsContainer(BuildContext context) {
    return Positioned(
        bottom: 0,
        width: MediaQuery
            .of(context)
            .size
            .width,
        child: Container(
          margin: const EdgeInsets.only(bottom: 70, top: 10),
          padding:
          const EdgeInsets.only(top: 30, bottom: 30, left: 15, right: 15),
          decoration: kTopCornerBlackBackgroundBoxDecoration,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(right: 10),
                child: Column(children: [
                  GestureDetector(
                    onTap: () =>
                    {
                      setState(() {
                        if (kIsWeb) {
                          context.push(Routes.term);
                          //    launchTermURL();
                        } else {
                          context.push(Routes.term);
                          // _navigateToWebScreen(context, 'term');
                        }
                      }),
                    },
                    child: const Text(
                      'Terms & Conditions',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.white54,
                          fontFamily: 'DPClear',
                          fontWeight: FontWeight.w400),
                    ),
                  )
                ]),
              ),
              Container(
                margin: const EdgeInsets.only(left: 10),
                child: GestureDetector(
                  onTap: () =>
                  {
                    setState(() {
                      if (kIsWeb) {
                        context.push(Routes.privacy);
                        // launchURL();
                      } else {
                        context.push(Routes.privacy);
                        //_navigateToWebScreen(context, 'policy');
                      }
                    }),
                  },
                  child: const Text(
                    'Privacy Policy',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.white54,
                        fontFamily: 'DPClear',
                        fontWeight: FontWeight.w400),
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  Widget buildTopBarContainer(BuildContext context, Size mq) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          margin: const EdgeInsets.only(left: 10, right: 10, top: 10),
          padding: const EdgeInsets.only(left: 10),
          height: mq.height * 0.09,
          decoration: kInnerDecoration,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Align(
                alignment: Alignment.centerLeft,
                child: Image.asset('assets/images/app_logo_mobile.png',
                    scale: 2.5),
              ),
              GestureDetector(
                onTap: () =>
                {
                  isSubscriptionStatusActive != "canceled"
                      ? buildCancelSubscriptionDialogContainer(context)
                      : context.pushNamed('subscription', queryParameters: {
                    "screen": 'home',
                  })
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.only(
                      left: 10, top: 10, bottom: 10, right: 10),
                  constraints: const BoxConstraints(
                    maxWidth: 200,
                    maxHeight: 40,
                  ),
                  decoration: kButtonBox10Decoration,
                  child: Text(
                    isSubscriptionStatusActive != "canceled"
                        ? kCancelSubscription.toUpperCase()
                        : kBuySubscription.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontFamily: 'DPClear',
                        fontWeight: FontWeight.w500),
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }


  buildCancelSubscriptionDialogContainer(BuildContext contexts) {
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
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child:
                      Image.asset('assets/images/ic_alert.png', scale: 2),
                    ),
                    Container(
                      margin: const EdgeInsets.only(
                        top: 10,
                      ),
                      alignment: Alignment.center,
                      child: Align(
                          alignment: Alignment.center,
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: const TextSpan(
                              text: kCancelSubscriptionAlert,
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontFamily: 'DPClear',
                                  fontWeight: FontWeight.w500),
                              /*defining default style is optional */
                            ),
                          )),
                    ),
                    Container(
                      decoration: kButtonBox10Decoration,
                      margin:
                      const EdgeInsets.only(top: 30, right: 25, left: 25),
                      child: ButtonWidget(
                        name: 'Yes'.toUpperCase(),
                        icon: '',
                        visibility: false,
                        padding: 20,
                        onTap: () => _handleOnYesSubscription(),
                        size: 12,
                        scale: 2,
                        height: 50,
                      ),
                    ),
                    Container(
                      decoration: kButtonBox10Decoration,
                      margin:
                      const EdgeInsets.only(top: 10, right: 25, left: 25),
                      child: ButtonWidget(
                        name: 'Cancel'.toUpperCase(),
                        icon: '',
                        visibility: false,
                        padding: 20,
                        onTap: () => _handleOnCancelButton(),
                        size: 12,
                        scale: 2,
                        height: 50,
                      ),
                    ),
                  ],
                ),
              ));
        });
  }
}
