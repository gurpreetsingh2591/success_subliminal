import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app/router.dart';
import '../data/api/ApiService.dart';
import '../dialogs/custom_alert_dialog.dart';
import '../utils/constant.dart';
import '../utils/shared_prefs.dart';
import '../widget/BottomBarStateFullWidget.dart';

class CreateSubliminalPage extends StatefulWidget {
  const CreateSubliminalPage({Key? key}) : super(key: key);

  @override
  _CreateSubliminalPage createState() => _CreateSubliminalPage();
}

class _CreateSubliminalPage extends State<CreateSubliminalPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late dynamic usedFreeTrial;
  bool isFreeTrialUsed = false;
  bool isTrial = false;
  bool isLogin = false;
  bool isSubscriptionActive = false;

  double descriptionSize = 16;
  double createButtonSize = 400;
  double createButtonMargin = 400;
  int count = 0;
  bool freeTrialCreated = false;
  bool isCount = false;
  int difference = 0;

  dynamic subliminal;
  late List<dynamic> subliminalList = [];
  List<dynamic> subscriptionList = [];
  List<dynamic> subscriptionPriceList = [];
  late dynamic subscription;
  late dynamic subscriptionDetail;
  int selectIndex = 0;
  String amount = "";
  String plan = "";
  String subId = "";

  @override
  void initState() {
    super.initState();
    changeScreenName("create");

    initializePreference().whenComplete(() {
      setState(() {
        _getSubscriptionListData();
        _getSubliminalCountData();
      });
    });

    setState(() {
      isLogin = SharedPrefs().isLogin();

      isTrial = SharedPrefs().isFreeTrail();
      isFreeTrialUsed = SharedPrefs().isFreeTrailUsed();
      isSubscriptionActive = SharedPrefs().isSubscription();
    });

    if (kDebugMode) {
      print(isLogin);
      print(isTrial);
      print(isFreeTrialUsed);
      print(isSubscriptionActive);
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

  void _getSubliminalCountData() async {
    subliminal = await ApiService().getCreateSubliminalCount(context);

    Future.delayed(const Duration(seconds: 2)).then((value) =>
        setState(() {
          setState(() {
            if (subliminal['http_code'] != 200) {} else {
              count = subliminal['data']['subliminal_create_count']
              ['current_month_count'];
              freeTrialCreated = subliminal['data']['subliminal_create_count']
              ['free_trial_created'];
            }

            Future.delayed(const Duration(seconds: 2))
                .then((value) =>
                setState(() {
                  setState(() {
                    isCount = true;
                  });
                }));

            if (kDebugMode) {
              print(subliminalList);
            }
          });
        }));
  }

  _handleActiveSubscription() {
    if (SharedPrefs().getUserPlanId().toString() != "") {
      context.pushNamed('add-payment', queryParameters: {
        'amount': amount,
        "subscriptionId": subId,
        "planType": plan,
        "screen": 'create',
      });
    } else {
      context.pushNamed('subscription', queryParameters: {
        "screen": 'create',
      });
    }
  }

  void _getSubscriptionListData() async {
    subscription = await ApiService().getStripeProduct(context);

    Future.delayed(const Duration(seconds: 1)).then((value) =>
        setState(() async {
          setState(() {
            if (subscription['http_code'] != 200) {} else {
              subscriptionList
                  .addAll(subscription['data']['product_list']['data']);
              subscriptionPriceList
                  .addAll(subscription['data']['product_price']['data']);
            }
            if (kDebugMode) {
              print(subscription);
            }
            for (int i = 0; i < subscriptionList.length; i++) {
              if (isTrial || isSubscriptionActive) {
                if (SharedPrefs().getUserPlanId() != null) {
                  if (subscriptionList[i]['id'].toString() ==
                      SharedPrefs().getUserPlanId().toString()) {
                    setState(() {
                      amount = (subscriptionPriceList[i]['unit_amount'] / 100)
                          .toString();
                      plan = subscriptionList[i]['name'];
                      subId = subscriptionList[i]['id'].toString();

                      SharedPrefs().setUserPlanName(plan);
                      SharedPrefs().setUserPlanAmount(amount);
                    });
                    if (kDebugMode) {
                      print("id ----${subscriptionList[i]['id'].toString()}");
                      print(subscription);
                      print(
                          "subscriptionId ----${SharedPrefs()
                              .getUserPlanId()
                              .toString()}");
                    }
                    break;
                  }
                }
              }
            }
          });
        }));
  }

  changeScreenName(String name) {
    setState(() {
      screenName = name;
    });
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
              const BottomBarStateFull(screen: "create", isUserLogin: true),
              Container(
                margin: const EdgeInsets.only(bottom: 70),
                child: ListView(
                  shrinkWrap: false,
                  primary: true,
                  children: [
                    buildTopBarContainer(context, mq),
                    buildCreateButton(context),
                    buildConvertIntoVoiceContainer(
                        context,
                        'assets/images/ic_write_sub.png',
                        kSubliminalTitle,
                        kWriteSubliminalDes,
                        90),
                    buildConvertIntoVoiceContainer(
                        context,
                        'assets/images/ic_convert.png',
                        kConvertIntoAudioTitle,
                        kConvertDes,
                        110),
                    buildConvertIntoVoiceContainer(context,
                        'assets/images/ic_save.png', kSaveTitle, kSaveDes, 130),
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

  Future<void> initializePreference() async {
    SharedPrefs.init(await SharedPreferences.getInstance());
  }

  Widget buildCreateButton(BuildContext context) {
    return ConstrainedBox(
        constraints: const BoxConstraints(minWidth: double.infinity),
        child: Container(
          decoration: kButtonBox10Decoration,
          margin: const EdgeInsets.only(top: 40, left: 15, right: 15),
          height: 50,
          child: ElevatedButton(
              onPressed: () {
                isCount
                    ? isTrial && !freeTrialCreated && difference < 8
                    ? context.push(Routes.createSubliminal)
                    : isSubscriptionActive && count < planCount(plan)
                    ? context.push(Routes.createSubliminal)
                    : const CustomAlertDialog()
                    .buildUpgradeMobileSubscriptionDialogContainer(
                    context,
                    difference,
                    isSubscriptionActive,
                    isTrial,
                    amount,
                    plan,
                    subId)
                    : count;

                // context.push(Routes.createSubliminal);
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.transparent,
                shadowColor: Colors.transparent,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  isCount
                      ? const Text('+  ',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontFamily: 'DPClear',
                        fontWeight: FontWeight.w400,
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
                  ),
                ],
              )),
        ));
  }

  Widget buildConvertIntoVoiceContainer(BuildContext context, String image,
      String title, String description, double hei) {
    return Container(
      margin: const EdgeInsets.only(left: 15, right: 15, top: 15),
      decoration: kAllMobileCornerBoxDecoration2,
      child: Container(
        padding:
        const EdgeInsets.only(top: 20, left: 15, right: 15, bottom: 20),
        margin: const EdgeInsets.only(left: 15, right: 15),
        child: Align(
          alignment: Alignment.topLeft,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                margin: const EdgeInsets.only(top: 3),
                height: 100,
                width: 60,
                alignment: Alignment.topLeft,
                child: Image.asset(image, scale: 2.5),
              ),
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.only(
                          left: 15,
                          bottom: 12,
                        ),
                        alignment: Alignment.topLeft,
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 22,
                            color: Colors.white,
                            fontFamily: 'DPClear',
                            fontWeight: FontWeight.w600,
                          ),
                          softWrap: true,
                        ),
                      ),
                    ),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.only(
                          left: 15,
                          bottom: 5,
                        ),
                        alignment: Alignment.topLeft,
                        child: Text(
                          description,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white54,
                            fontFamily: 'DPClear',
                            fontWeight: FontWeight.w400,
                          ),
                          softWrap: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTopBarContainer(BuildContext context, Size mq) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.only(left: 15, top: 10),
          child: const Align(
            alignment: Alignment.topLeft,
            child: Text(
              'Create',
              style: TextStyle(
                  fontSize: 32,
                  color: Colors.white,
                  fontFamily: 'DPClear',
                  fontWeight: FontWeight.w500),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.only(left: 15, top: 10, right: 15),
          child: const Align(
            alignment: Alignment.topLeft,
            child: Text(
              'You can create your own Subliminal here in three steps',
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontFamily: 'DPClear',
                  fontWeight: FontWeight.w400),
            ),
          ),
        )
      ],
    );
  }
}
