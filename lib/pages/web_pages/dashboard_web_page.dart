import 'package:email_validator/email_validator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:success_subliminal/pages/dashboard_page.dart';
import 'package:success_subliminal/pages/web_pages/discover_subliminal_web_detail_page.dart';
import 'package:video_player/video_player.dart';

import '../../app/router.dart';
import '../../data/api/ApiService.dart';
import '../../dialogs/custom_alert_dialog.dart';
import '../../utils/center_loader.dart';
import '../../utils/constant.dart';
import '../../utils/shared_prefs.dart';
import '../../utils/toast.dart';
import '../../widget/ButtonWidget400.dart';
import '../../widget/CommonTextFieldWithoutBG.dart';
import '../../widget/WebFooterWidget.dart';
import '../../widget/WebTopBarContainer.dart';

class DashBoardWebPage extends StatefulWidget {
  final String? redirect;

  const DashBoardWebPage({Key? key, this.redirect}) : super(key: key);

  @override
  DashBoardWebScreen createState() => DashBoardWebScreen();
}

class DashBoardWebScreen extends State<DashBoardWebPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController _scrollController = ScrollController();

  List<dynamic> categoriesList = [];
  List<dynamic> testimonialsList = [];
  late dynamic categories;
  late dynamic testimonials;
  int selectIndex = 0;
  late dynamic sendEmail;
  final _emailText = TextEditingController();
  late List<dynamic> subliminalList = [];
  late dynamic subliminal;
  String categoryId = "";
  String isSubscriptionStatusActive = "";
  double turnOnSize = 40;
  double gridSize = 2.2;
  double imageScale = 1;

  double firstPageHeight = 0.85;

  double marginTopEmail = 200;
  double marginTopSigning = 150;
  double marginRightSigning = 150;

  bool isSubliminal = false;
  late VideoPlayerController _controllers;
  late dynamic cancelSubscription;
  late dynamic usedFreeTrial;
  bool isFreeTrialUsed = false;
  bool isLogin = false;
  bool isTrial = false;
  bool isSubscriptionActive = false;
  bool isSubscriptionProcess = false;

  List<dynamic> subscriptionList = [];
  List<dynamic> subscriptionPriceList = [];
  late dynamic subscription;
  String amount = "";
  String plan = "";

  @override
  void initState() {
    super.initState();

    _controllers = VideoPlayerController.network(videoUrl)
      ..initialize().then((_) {
        setState(() {
          _controllers.seekTo(const Duration(seconds: 2));
        });
      });
    initializePreference().whenComplete(() {
      setState(() {
        isLogin = SharedPrefs().isLogin();
        isTrial = SharedPrefs().isFreeTrail();
        isFreeTrialUsed = SharedPrefs().isFreeTrailUsed();
        isSubscriptionActive = SharedPrefs().isSubscription();
        isSubscriptionStatusActive =
            SharedPrefs().getSubscriptionStatus().toString();
        setState(() {
          if (!isLogin) {
            context.pushReplacement(Routes.home);
          }
        });
      });

      _getCategoriesData();
    });
  }


  void _getSubliminalListData(String categoryId) async {
    subliminalList.clear();
    subliminal =
    await ApiService().getDiscoverSubliminalList(context, categoryId);

    Future.delayed(const Duration(seconds: 2)).then((value) =>
        setState(() {
          setState(() {
            subliminalList.clear();
            if (subliminal['http_code'] != 200) {
              setState(() {
                isSubliminal = true;
              });
            } else {
              setState(() {
                isSubliminal = true;
                subliminalList.addAll(subliminal['data']['subliminals']);
              });
            }
            if (kDebugMode) {
              print(subliminalList);
            }
          });
        }));
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
          setState(() {
            isSubscriptionProcess = false;
          });
        });
      }
      SharedPrefs().setIsSubscriptionStatus(cancelSubscription['status']);
    });
  }


  void _getCategoriesData() async {
    categories = await ApiService().getCategories(context);

    Future.delayed(const Duration(seconds: 2)).then((value) =>
        setState(() {
          if (categories['http_code'] != 200) {} else {
            setState(() {
              categoriesList.addAll(categories['data']['categories']);
              categoryId = categories['data']['categories'][0]['id'].toString();
              _getSubliminalListData(categoryId);
            });
          }
          if (kDebugMode) {
            print(categoriesList);
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
        body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            if (constraints.maxWidth > 767) {
              if (constraints.maxWidth < 900) {
                turnOnSize = 35;
                imageScale = 3;
                gridSize = 2.8;

                firstPageHeight = 0.55;
                marginTopEmail = 100;
                marginTopSigning = 70;
                marginRightSigning = 70;
              } else if (constraints.maxWidth < 1100) {
                turnOnSize = 40;
                imageScale = 2.5;
                gridSize = 2.6;

                firstPageHeight = 0.60;
                marginTopEmail = 100;
                marginTopSigning = 70;
                marginRightSigning = 70;
              } else if (constraints.maxWidth < 1300) {
                turnOnSize = 40;
                imageScale = 2;
                gridSize = 2.4;

                firstPageHeight = .75;
                marginTopEmail = 130;
                marginTopSigning = 100;
                marginRightSigning = 100;
              } else if (constraints.maxWidth < 1600) {
                turnOnSize = 50;
                imageScale = 1.5;
                gridSize = 2.2;

                firstPageHeight = .80;
                marginTopEmail = 160;
                marginTopSigning = 120;
                marginRightSigning = 120;
              } else if (constraints.maxWidth < 1800) {
                turnOnSize = 50;
                imageScale = 1.5;
                gridSize = 2.2;

                firstPageHeight = 0.85;
                marginTopEmail = 180;
                marginTopSigning = 140;
                marginRightSigning = 140;
              } else if (constraints.maxWidth < 2000) {
                turnOnSize = 60;
                imageScale = 1;
                gridSize = 2.2;

                firstPageHeight = 0.85;
                marginTopEmail = 200;
                marginTopSigning = 150;
                marginRightSigning = 150;
              }

              return buildHomeContainer(context, mq);
            } else {
              return DashBoardPage();
            }
          },
        ));
  }

  Widget buildHomeContainer(BuildContext context, Size mq) {
    return SingleChildScrollView(
        child: Container(
            constraints: BoxConstraints(
              maxHeight: mq.height,
            ),
            child: Stack(children: [
              Image.asset(
                'assets/images/bg_web.png',
                fit: BoxFit.cover,
                height: double.infinity,
                width: double.infinity,
                alignment: Alignment.center,
              ),
              const WebTopBarContainer(
                screen: 'home',
              ),
              Container(
                  margin: const EdgeInsets.only(top: 100),
                  child: ListView(
                    shrinkWrap: false,
                    primary: false,
                    children: [

                      buildDiscoverBarContainer(context),

                      const WebFooterWidget()
                    ],
                  ))
            ])));
  }

  Widget buildDiscoverBarContainer(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20, left: 15, right: 15),
      child: Container(
        padding: const EdgeInsets.only(top: 10, bottom: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            RichText(
              textAlign: TextAlign.start,
              text: TextSpan(
                text: "Discover",
                style: TextStyle(
                    fontSize: turnOnSize,
                    color: kYellow,
                    letterSpacing: -1.0,
                    fontFamily: 'DPClear',
                    fontWeight: FontWeight.w600),
                /*defining default style is optional */
                children: <TextSpan>[
                  TextSpan(
                      text: " Subliminals",
                      style: TextStyle(
                          fontSize: turnOnSize,
                          letterSpacing: -1.0,
                          color: Colors.white,
                          fontFamily: 'DPClear',
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            categoriesList.isNotEmpty
                ? buildCategoriesListContainer(context)
                : Container(
                height: 200,
                margin: const EdgeInsets.only(top: 20),
                child: const Center(child: CircularProgressIndicator())),
            isSubliminal
                ? Row(children: [
              Expanded(
                  flex: 8,
                  child: Stack(children: [
                    buildSubliminalListWithCatContainer(context),

                  ])),
            ])
                : const SizedBox(
                height: 500,
                child: Center(child: CircularProgressIndicator())),
            discoverButton(),

          ],
        ),
      ),
    );
  }


  Widget buildSubliminalListWithCatContainer(BuildContext context) {
    return (subliminalList.isNotEmpty)
        ? Align(
        alignment: Alignment.topLeft,
        child: Container(
            margin: const EdgeInsets.only(left: 10, right: 10, top: 20),
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
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 2 / gridSize,
                )) /* ListView.builder(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    primary: false,
                    controller: _scrollController,
                    itemCount: subliminalList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return buildSubliminalListItem(
                          context, subliminalList[index]);
                    })))*/
        ))
        : Container(
      alignment: Alignment.topCenter,
      margin: const EdgeInsets.only(top: 20),
      child: const Align(
        alignment: Alignment.center,
        child: Text(
          kComingSoon,
          style: TextStyle(
              fontSize: 24,
              color: Colors.white,
              fontFamily: 'DPClear',
              fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget discoverButton() {
    return Container(
        height: 80,
        margin: const EdgeInsets.only(top: 22),
        child: InkWell(
            onTap: () {
              context.pushReplacement(Routes.discover);
            },
            child: Image.asset(
              'assets/images/ic_discover_btn.png',
              scale: 2,
            )));
  }

  Widget buildSubliminalListItem(BuildContext context, dynamic subliminalList) {
    return GestureDetector(
      onTap: () =>
      {
        context.pushNamed('discover-subliminals-detail', queryParameters: {
          'categoryName': subliminalList['title'],
          'subName': subliminalList['category_name'].toString(),
          'subId': subliminalList['id'].toString(),
          'catId': categoryId,
        })

        /* _navigateToSubDetailScreen(
          context,
          subliminalList['title'],
          subliminalList['id'].toString(),
          subliminalList['category_name'].toString(),
          categoryId,
        )*/
      },
      child: Container(
        margin: const EdgeInsets.only(left: 5, right: 5, top: 10),
        padding: const EdgeInsets.all(10),
        decoration: kEditTextDecoration10Radius,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: Align(
                      alignment: Alignment.center,
                      child: subliminalList['cover_path'] != ""
                          ? Image.network(
                        subliminalList['cover_path'],
                        fit: BoxFit.contain,
                        loadingBuilder: (BuildContext context,
                            Widget child,
                            ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                              padding: const EdgeInsets.all(10),
                              child: Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress
                                      .expectedTotalBytes !=
                                      null
                                      ? loadingProgress
                                      .cumulativeBytesLoaded /
                                      loadingProgress
                                          .expectedTotalBytes!
                                      : null,
                                ),
                              ));
                        },
                      )
                          : Image.asset(
                        'assets/images/bg_logo_image.png',
                        fit: BoxFit.fill,
                      ),
                    ))),
            Container(
              padding: const EdgeInsets.only(top: 5),
              child: Align(
                alignment: Alignment.topCenter,
                child: Text(
                  subliminalList['title'],
                  style: const TextStyle(
                      fontSize: 20,
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

  Widget buildCategoriesListContainer(BuildContext context) {
    return (categoriesList.isNotEmpty)
        ? Align(
        alignment: Alignment.center,
        child: Container(
            margin: const EdgeInsets.only(top: 20),
            padding: const EdgeInsets.only(left: 10, right: 10),
            height: 100,
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
      margin: const EdgeInsets.only(top: 70),
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
                        alignment: Alignment.center,
                        height: 50,
                        margin:
                        const EdgeInsets.only(left: 5, right: 5, top: 25),
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        decoration: selectIndex == index
                            ? kButtonBox10Decoration
                            : kBlackButtonBox10Decoration,
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            name.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontFamily: 'DPClear',
                                fontWeight: FontWeight.w500),
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
}
