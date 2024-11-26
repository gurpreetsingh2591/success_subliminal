import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:success_subliminal/pages/create_subliminal_page.dart';

import '../../app/router.dart';
import '../../data/api/ApiService.dart';
import '../../utils/constant.dart';
import '../../utils/shared_prefs.dart';
import '../../widget/ButtonWidget400.dart';
import '../../widget/WebFooterWithoutLinkWidget.dart';
import '../../widget/WebTopBarContainer.dart';

class CreateSubliminalWebPage extends StatefulWidget {
  const CreateSubliminalWebPage({Key? key}) : super(key: key);

  @override
  CreateSubliminalWeb createState() => CreateSubliminalWeb();
}

class CreateSubliminalWeb extends State<CreateSubliminalWebPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  String tapBar = "create";
  bool isLogin = false;
  bool isCount = false;
  double titleSize = 28;
  double titleSizeBox = 28;
  dynamic subliminal;
  late List<dynamic> subliminalList = [];

  late dynamic usedFreeTrial;
  bool isFreeTrialUsed = false;
  bool freeTrialCreated = false;
  bool isTrial = false;
  bool isSubscriptionActive = false;
  String subscriptionId = "";

  double descriptionSize = 16;
  double descriptionSizeBox = 16;
  double createButtonSize = 400;
  int count = 0;
  int difference = 0;

  List<dynamic> subscriptionList = [];
  List<dynamic> subscriptionPriceList = [];
  late dynamic subscription;
  late dynamic subscriptionDetail;
  int selectIndex = 0;
  String amount = "";
  String plan = "";
  String subId = "";

  double leftPadding = 200;
  double rightPadding = 200;
  double descriptionRightPadding = 100;
  double buttonRightPadding = 40;
  double buttonInternalPadding = 10;

  @override
  void initState() {
    super.initState();
    initializePreference().whenComplete(() {
      setState(() {
        isLogin = SharedPrefs().isLogin();
        isTrial = SharedPrefs().isFreeTrail();
        isFreeTrialUsed = SharedPrefs().isFreeTrailUsed();
        isSubscriptionActive = SharedPrefs().isSubscription();
        isSubscriptionActive = SharedPrefs().isSubscription();
        subscriptionId = SharedPrefs().getUserSubscriptionId().toString();

        setState(() {
          if (!isLogin) {
            context.pushReplacement(Routes.home);
          }
        });
      });
    });

    _getSubscriptionListData();
    _getSubliminalCountData();
    if (kDebugMode) {
      print(isLogin);
      print(isTrial);
      print(isFreeTrialUsed);
      print(isSubscriptionActive);
      print("subscriptionId--$subscriptionId");
    }

    DateTime dateTime = DateTime.now();
    DateTime pickedDate = DateTime.parse(SharedPrefs().getTrialStartDate()!);

    difference = dateTime
        .difference(pickedDate)
        .inDays;
    _getStripeSubscriptionDetail();
  }


  void _getStripeSubscriptionDetail() async {
    subscriptionDetail = await ApiService().getSubscriptionDetail(context);

    Future.delayed(const Duration(seconds: 2)).then((value) =>
        setState(() {
          setState(() {
            if (subscriptionDetail['http_code'] != 200) {} else {
              subscriptionDetail = subscriptionDetail['data']
              ['current_user_subscription_status'];

              if (subscriptionDetail != null || subscriptionDetail != "") {
                _getIsUserSubscription(context);
              }
            }
          });
        }));
  }

  void _getIsUserSubscription(BuildContext context) {
    setState(() {
      if (subscriptionDetail['subscription_status'] == "trialing") {
        SharedPrefs().setIsFreeTrail(true);
        SharedPrefs().setIsSubscription(false);
      } else if (subscriptionDetail['subscription_status'] == "active") {
        SharedPrefs().setIsSubscription(true);
        SharedPrefs().setIsFreeTrail(false);
      } else if (subscriptionDetail['subscription_status'] == "canceled") {
        SharedPrefs().setIsSubscription(false);
        SharedPrefs().setIsFreeTrail(false);
      }

      SharedPrefs().setUserSubscriptionId(
          subscriptionDetail['subscription_id'].toString());
      SharedPrefs().setUserPlanId(subscriptionDetail['product_id'].toString());
      SharedPrefs().setIsSubscriptionStatus(subscriptionDetail['status']);
    });
  }

  _handleActiveSubscription() {
    if (SharedPrefs().getUserPlanId() != null && plan != "") {
      if (!isTrial && !isSubscriptionActive) {
        context
            .pushNamed('subscription', queryParameters: {"screen": 'create'});
      } else {
        if (!isTrial && isSubscriptionActive) {
          context
              .pushNamed('subscription', queryParameters: {"screen": 'create'});
        } else {
          context.pushNamed('add-payment', queryParameters: {
            'amount': amount,
            "subscriptionId": subId,
            "planType": plan,
            "screen": 'create',
          });
        }
      }
    } else {
      context.pushNamed('subscription', queryParameters: {
        "screen": 'create',
      });
    }
  }

  void _getSubscriptionListData() async {
    subscription = await ApiService().getStripeProduct(context);

    Future.delayed(const Duration(seconds: 2)).then((value) =>
        setState(() {
          setState(() {
            if (subscription['http_code'] != 200) {} else {
              subscriptionList
                  .addAll(subscription['data']['product_list']['data']);
              subscriptionPriceList
                  .addAll(subscription['data']['product_price']['data']);
            }

            for (int i = 0; i < subscriptionList.length; i++) {
              if (isTrial || isSubscriptionActive) {
                if (kDebugMode) {
                  print("id ----${subscriptionList[i]['id'].toString()}");
                  print(
                      "subscriptionId ----${SharedPrefs()
                          .getUserPlanId()
                          .toString()}");
                }

                if (subscriptionList[i]['id'].toString() ==
                    SharedPrefs().getUserPlanId().toString()) {
                  setState(() {
                    amount = (subscriptionPriceList[i]['unit_amount'] / 100)
                        .toString();
                    plan = subscriptionList[i]['name'];
                    SharedPrefs().setUserPlanName(plan);
                    SharedPrefs().setUserPlanAmount(amount);
                    subId = subscriptionList[i]['id'].toString();
                  });
                }
              }
            }

            if (kDebugMode) {
              print("size ----${subscriptionList.length}");
              print("name ----${subscriptionList[0]['name']}");
              print(
                  "size ----${subscription['data']['product_list']['data'][0]['name']}");
            }
          });
        }));
  }

  void _getSubliminalCountData() async {
    subliminal = await ApiService().getCreateSubliminalCount(context);

    Future.delayed(const Duration(seconds: 2)).then((value) =>
        setState(() {
          setState(() {
            if (subliminal['http_code'] != 200) {} else {
              setState(() {
                count = subliminal['data']['subliminal_create_count']
                ['current_month_count'];
                freeTrialCreated = subliminal['data']['subliminal_create_count']
                ['free_trial_created'];
              });
            }

            Future.delayed(const Duration(seconds: 2))
                .then((value) =>
                setState(() {
                  setState(() {
                    isCount = true;
                  });
                }));

            if (kDebugMode) {
              print(count);
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
            if (constraints.maxWidth > 757) {
              if (constraints.maxWidth < 900) {
                titleSize = 24;
                descriptionSize = 14;
                titleSizeBox = 16;
                descriptionSizeBox = 11;

                titleTextSize = 50;
                loginTopPadding = 100;

                leftPadding = 50;
                rightPadding = 50;
                descriptionRightPadding = 30;
                buttonRightPadding = 15;
                buttonInternalPadding = 5;
              } else if (constraints.maxWidth < 1100) {
                titleSize = 35;
                descriptionSize = 16;
                titleSizeBox = 16;
                descriptionSizeBox = 11;

                titleTextSize = 55;
                loginTopPadding = 105;

                leftPadding = 50;
                rightPadding = 50;

                descriptionRightPadding = 30;
                buttonRightPadding = 15;
                buttonInternalPadding = 5;
              } else if (constraints.maxWidth < 1300) {
                titleSize = 40;
                descriptionSize = 16;
                titleSizeBox = 18;
                descriptionSizeBox = 12;

                titleTextSize = 60;
                loginTopPadding = 110;
                leftPadding = 100;
                rightPadding = 100;
                descriptionRightPadding = 40;
                buttonRightPadding = 20;
                buttonInternalPadding = 5;
              } else if (constraints.maxWidth < 1600) {
                titleSize = 50;
                descriptionSize = 20;
                titleSizeBox = 20;
                descriptionSizeBox = 13;

                titleTextSize = 65;
                loginTopPadding = 115;

                leftPadding = 150;
                rightPadding = 150;
                descriptionRightPadding = 60;
                buttonRightPadding = 30;
                buttonInternalPadding = 15;
              } else if (constraints.maxWidth < 2000) {
                titleSize = 50;
                descriptionSize = 24;
                titleSizeBox = 25;
                descriptionSizeBox = 14;

                titleTextSize = 70;
                loginTopPadding = 120;

                leftPadding = 200;
                rightPadding = 200;
                descriptionRightPadding = 100;
                buttonRightPadding = 40;
                buttonInternalPadding = 10;
              }

              return buildHomeContainer(context, mq);
            } else {
              return const CreateSubliminalPage();
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
          children: [
            const WebTopBarContainer(screen: 'create'),
            Positioned(
                bottom: 0,
                child: SizedBox(
                    height: 80,
                    width: mq.width * 1,
                    child: const WebFooterWithoutLinkWidget())),
            Container(
                margin: EdgeInsets.only(
                    left: leftPadding,
                    right: rightPadding,
                    top: loginTopPadding,
                    bottom: 100),
                child: ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context)
                      .copyWith(scrollbars: false),
                  child: ListView(
                    primary: false,
                    shrinkWrap: true,
                    children: [
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            buildCreateTextContainer(context, mq),
                            buildCreateButton(context, mq),
                          ]),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            flex: 1,
                            child: buildConvertIntoVoiceContainer(
                                context,
                                'assets/images/ic_write_sub.png',
                                kSubliminalTitle,
                                kWriteSubliminalDes,
                                80,
                                "01"),
                          ),
                          Expanded(
                            flex: 1,
                            child: buildConvertIntoVoiceContainer(
                                context,
                                'assets/images/ic_convert.png',
                                kConvertIntoAudioTitle,
                                kConvertDes,
                                80,
                                "02"),
                          ),
                          Expanded(
                            flex: 1,
                            child: buildConvertIntoVoiceContainer(
                              context,
                              'assets/images/ic_save.png',
                              kSaveTitle,
                              kSaveDes,
                              80,
                              "03",
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Future<void> initializePreference() async {
    SharedPrefs.init(await SharedPreferences.getInstance());
  }

  Widget buildCreateButton(BuildContext context, Size mq) {
    return Container(
      width: createButtonSize - 40,
      padding: const EdgeInsets.only(top: 7, bottom: 7),
      margin: const EdgeInsets.only(right: 20, top: 40),
      decoration: kButtonBoxDecoration,
      alignment: Alignment.center,
      child: ElevatedButton(
        onPressed: () {
          isCount
              ? isTrial && !freeTrialCreated && difference < 8
              ? context.push(Routes.createSubliminal)
              : isSubscriptionActive && count < planCount(plan)
              ? context.push(Routes.createSubliminal)
              : buildCancelSubscriptionDialogContainer(context, mq)
              : count;
        },
        style: ElevatedButton.styleFrom(
            primary: Colors.transparent, shadowColor: Colors.transparent),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isCount
                ? const Text('+  ',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'DPClear',
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ))
                : const SizedBox(),
            isCount
                ? const Text(kCreateSubliminal,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontFamily: 'DPClear',
                  fontWeight: FontWeight.w400,
                ))
                : const CircularProgressIndicator(
              color: Colors.white,
            )
          ],
        ),
      ),
    );
  }

  Future<Object?> buildSideBar() {
    return showGeneralDialog(
      context: context,
      pageBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        return Container(
          height: double.infinity,
          width: 200.0,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10.0),
              bottomLeft: Radius.circular(10.0),
            ),
          ),
          child: const Center(
            child: Text('This is the right side bottom sheet'),
          ),
        );
      },
      barrierLabel: "",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: Duration(milliseconds: 400),
      transitionBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation, Widget child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      },
    );
  }

  buildCancelSubscriptionDialogContainer(BuildContext contexts, Size mq) {
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
                    width: mq.width * 0.2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(
                            top: 10,
                          ),
                          alignment: Alignment.center,
                          child: Align(
                              alignment: Alignment.center,
                              child: RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  text: difference < 8 && !isSubscriptionActive
                                      ? "You’ve reached your Create Subliminal limit for your Free Trial. You can wait until the card on file gets charged with the subscription plan or you can upgrade now."
                                      : 'You’ve reached your Create Subliminal limit for your current Plan',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontFamily: 'DPClear',
                                    fontWeight: FontWeight.w400,
                                  ),
                                  /*defining default style is optional */
                                ),
                              )),
                        ),
                        /* const TextFieldWidget400(
                            text:
                                "\n1. You can wait until your paid subscription starts to create more subliminals",
                            size: 15,
                            color: Colors.white),
                        const TextFieldWidget400(
                            text:
                                "2. You can upgrade your plan and start creating more subliminals now",
                            size: 15,
                            color: Colors.white),*/
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              decoration: kButtonBox10Decoration,
                              margin: const EdgeInsets.only(
                                  top: 20, right: 5, left: 5),
                              child: ButtonWidget400(
                                buttonSize: 40,
                                deco: kButtonBox10Decoration,
                                name: 'Not Now'.toUpperCase(),
                                icon: '',
                                visibility: false,
                                padding: 10,
                                onTap: () => {Navigator.pop(context)},
                                size: 12,
                              ),
                            ),
                            Container(
                              decoration: kButtonBox10Decoration,
                              margin: const EdgeInsets.only(
                                  top: 20, right: 5, left: 5),
                              child: ButtonWidget400(
                                buttonSize: 40,
                                deco: kButtonBox10Decoration,
                                name: 'Upgrade'.toUpperCase(),
                                icon: '',
                                visibility: false,
                                padding: 10,
                                onTap: () =>
                                {
                                  Navigator.pop(context),
                                  _handleActiveSubscription()
                                },
                                size: 12,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  )));
        });
  }

  Widget buildConvertIntoVoiceContainer(BuildContext context, String image,
      String title, String description, double hei, String step) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        double containerWidth = constraints.maxWidth;
        createButtonSize = constraints.maxWidth;
        return Container(
          width: containerWidth,
          padding:
          const EdgeInsets.only(top: 10, bottom: 20, left: 20, right: 20),
          margin: const EdgeInsets.only(
            left: 15,
            right: 15,
            top: 20,
          ),
          height: 280,
          decoration: kAllCornerBoxDecoration2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                alignment: Alignment.topRight,
                child: Text(
                  step,
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.yellow,
                    fontFamily: 'DPClear',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 10),
                height: 100,
                width: 60,
                alignment: Alignment.topCenter,
                child: Image.asset(image, scale: 2.5),
              ),
              Container(
                margin: const EdgeInsets.only(top: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Flexible(
                        child: Container(
                          // padding: EdgeInsets.only(bottom:5),
                          // margin: EdgeInsets.only(top:10),
                          alignment: Alignment.topLeft,
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: titleSizeBox,
                              color: Colors.white,
                              fontFamily: 'DPClear',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.only(top: 10),
                        alignment: Alignment.topLeft,
                        child: Text(
                          description,
                          maxLines: 4,
                          style: TextStyle(
                            fontSize: descriptionSizeBox,
                            color: Colors.white54,
                            fontFamily: 'DPClear',
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildCreateTextContainer(BuildContext context, Size mq) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.only(left: 15, right: 10),
          child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                'Create',
                style: TextStyle(
                    fontSize: titleSize,
                    color: Colors.white,
                    fontFamily: 'DPClear',
                    fontWeight: FontWeight.w400),
              )),
        ),
        Container(
          padding:
          const EdgeInsets.only(left: 15, top: 10, right: 15, bottom: 30),
          child: Align(
            alignment: Alignment.topLeft,
            child: Text(
              'You can create your own Subliminal here in three steps',
              style: TextStyle(
                  fontSize: descriptionSize,
                  color: kTextGrey,
                  fontFamily: 'DPClear',
                  fontWeight: FontWeight.w400),
            ),
          ),
        )
      ],
    );
  }
}
