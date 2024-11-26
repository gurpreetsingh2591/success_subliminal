import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:success_subliminal/pages/subscription_list_page.dart';
import 'package:success_subliminal/pages/web_pages/subscription_payment_web_page.dart';

import '../../app/router.dart';
import '../../data/api/ApiService.dart';
import '../../utils/constant.dart';
import '../../utils/shared_prefs.dart';

class SubscriptionListWebPage extends StatefulWidget {
  final String? screen;

  const SubscriptionListWebPage({Key? key, required this.screen})
      : super(key: key);

  @override
  SubscriptionWebScreen createState() => SubscriptionWebScreen();
}

class SubscriptionWebScreen extends State<SubscriptionListWebPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isLogin = false;
  List<dynamic> subscriptionList = [];
  List<dynamic> tempSubscriptionList = [];
  List<dynamic> tempSubscriptionPriceList = [];
  List<dynamic> subscriptionPriceList = [];
  late dynamic subscription;
  int selectIndex = 0;
  String amount = "";
  String plan = "";
  String subId = "";
  bool isSub = false;
  double screenSize = 0.3;
  bool isFreeTrialUsed = false;
  String buttonName = "";

  @override
  void initState() {
    super.initState();
    initializePreference().whenComplete(() {
      isLogin = SharedPrefs().isLogin();
      isFreeTrialUsed = SharedPrefs().isFreeTrailUsed();

      if (widget.screen != 'trial') {
        buttonName = "Subscribe Now".toUpperCase();
      } else {
        buttonName = 'Start 7-day Free Trial'.toUpperCase();
      }
      if (!isLogin) {
        context.pushReplacement(Routes.home);
      }
      _getSubscriptionListData();
    });
  }

  void _getSubscriptionListData() async {
    subscription = await ApiService().getStripeProduct(context);

    Future.delayed(const Duration(seconds: 1))
        .then((value) => setState(() async {
              setState(() {
                if (subscription['http_code'] != 200) {
                } else {
                  tempSubscriptionList
                      .addAll(subscription['data']['product_list']['data']);
                  tempSubscriptionPriceList
                      .addAll(subscription['data']['product_price']['data']);
                  for (int i = 0; i < tempSubscriptionList.length; i++) {
                    if (tempSubscriptionList[i]['active'] == true) {
                      subscriptionList.add(tempSubscriptionList[i]);
                      subscriptionPriceList.add(tempSubscriptionPriceList[i]);
                    }
                  }

                  if (subscriptionList.isNotEmpty) {
                    amount = (subscriptionPriceList[0]['unit_amount'] / 100)
                        .toString();
                    subId = subscriptionList[0]['id'];
                    plan = subscriptionList[0]['name'];

                    isSub = true;
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

  Future<void> initializePreference() async {
    SharedPrefs.init(await SharedPreferences.getInstance());
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
                screenSize = 0.7;
              } else if (constraints.maxWidth < 1100) {
                screenSize = 0.6;
              } else if (constraints.maxWidth < 1300) {
                screenSize = 0.5;
              } else if (constraints.maxWidth < 1600) {
                screenSize = 0.4;
              } else if (constraints.maxWidth < 2000) {
                screenSize = 0.3;
              }

              return buildHomeContainer(context, mq);
            } else {
              return SubscriptionListPage(
                screen: widget.screen,
              );
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
          child: Stack(children: <Widget>[
            ListView(
              shrinkWrap: false,
              primary: false,
              children: [
                buildTopBarContainer(context, mq),
                buildSubscriptionListContainer(context, mq),
              ],
            )
          ])),
    );
  }

  Widget buildSubscriptionListContainer(BuildContext context, Size mq) {
    return Container(
      margin: const EdgeInsets.only(top: 100, bottom: 40),
      child: Container(
        padding: const EdgeInsets.only(right: 20, top: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: mq.width * screenSize,
              child: const Align(
                alignment: Alignment.topLeft,
                child: Text(
                  kSubPlansTitle,
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontFamily: 'DPClear',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            Container(
              width: mq.width * screenSize,
              margin: const EdgeInsets.only(top: 10),
              child: const Align(
                alignment: Alignment.topLeft,
                child: Text(
                  kSubscriptionSubTitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white54,
                    fontFamily: 'DPClear',
                    fontWeight: FontWeight.w400,
                  ),
                  softWrap: true,
                ),
              ),
            ),
            isSub
                ? Container(
                    margin: const EdgeInsets.only(top: 20),
                    width: mq.width * screenSize,
                    alignment: Alignment.center,
                    child: Align(
                        alignment: Alignment.center,
                        child: buildSubscriptionContainer(context)))
                : SizedBox(
                    height: 200,
                    width: mq.width * screenSize,
                    child: const Center(child: CircularProgressIndicator())),
            SizedBox(
                width: mq.width * screenSize, child: buildButton(context, mq))
          ],
        ),
      ),
    );
  }

  Widget buildSubscriptionContainer(BuildContext contexts) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        (subscriptionList.isNotEmpty)
            ? ListView.builder(
                shrinkWrap: true,
                primary: false,
                itemCount: subscriptionList.length,
                itemBuilder: (BuildContext context, int index) {
                  return buildSubscriptionListItem(
                      contexts, subscriptionList[index], index);
                })
            : const Align(
                alignment: Alignment.center,
                child: Text(
                  "No Subscription Plans",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontFamily: 'DPClear',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
      ],
    );
  }

  Widget buildSubscriptionListItem(
      BuildContext context, dynamic subscription, int index) {
    return GestureDetector(
      onTap: () => {
        setState(() {
          selectIndex = index;
          amount =
              (subscriptionPriceList[index]['unit_amount'] / 100).toString();
          subId = subscription['id'];
          plan = subscription['name'];
        })
      },
      child: Container(
        margin: const EdgeInsets.only(top: 20),
        padding: const EdgeInsets.all(15),
        decoration: selectIndex != index
            ? kUnSelectedCollectionBoxDecoration
            : kSelectedCollectionBoxDecoration,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              subscription['name'],
              style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontFamily: 'DPClear',
                  fontWeight: FontWeight.w600),
            ),
            Container(
              margin: const EdgeInsets.only(top: 10),
              child: RichText(
                textAlign: TextAlign.left,
                text: TextSpan(
                  text:
                      "\$${subscriptionPriceList[index]['unit_amount'] / 100}",
                  style: const TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontFamily: 'DPClear',
                      fontWeight: FontWeight.w600),
                  /*defining default style is optional */
                  children: <TextSpan>[
                    TextSpan(
                        text: "/ monthly for a " + subscription['name'],
                        style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white54,
                            fontFamily: 'DPClear',
                            fontWeight: FontWeight.w400)),
                  ],
                ),
              ),
            ),
            Container(
                margin: const EdgeInsets.only(top: 5),
                padding: const EdgeInsets.only(top: 5),
                child: Text(
                  planFeatures(subscription['name']),
                  style: const TextStyle(
                      fontSize: 14,
                      letterSpacing: .2,
                      height: 1.3,
                      color: Colors.white,
                      fontFamily: 'DPClear',
                      fontWeight: FontWeight.w400),
                )),
          ],
        ),
      ),
    );
  }

  Widget buildTopBarContainer(BuildContext context, Size mq) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => {
            setState(() {
              if (widget.screen == "create") {
                Navigator.pop(context);
              } else {
                context.pushReplacement(Routes.dashboard);
              }
            })
          },
          child: Container(
            padding: const EdgeInsets.only(left: 10, top: 20),
            child: Align(
              alignment: Alignment.topLeft,
              child: Image.asset('assets/images/ic_arrow_left.png', scale: 1.5),
            ),
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.only(top: 20, right: 70),
            child: const Align(
              alignment: Alignment.center,
              child: Text(
                "Subscription",
                maxLines: 2,
                style: TextStyle(
                    fontSize: 32,
                    color: Colors.white,
                    fontFamily: 'DPClear',
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildButton(BuildContext context, Size mq) {
    return Container(
      width: mq.width * 0.3,
      decoration: kButtonBox10Decoration,
      margin: const EdgeInsets.only(top: 40),
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            /* SubscribedScreenArguments args = SubscribedScreenArguments(
              amount: amount,
              subscriptionId: subId,
              planType: plan,
              screen: 'list',
            );
*/

            //Navigator.pushNamed(context, '/add-payment');

            context.pushNamed('add-payment', queryParameters: {
              'amount': amount,
              "subscriptionId": subId,
              "planType": plan,
              "screen": widget.screen
            });
            //_navigateToSubscriptionScreen(context);
          });
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
            Text(buttonName.toUpperCase(),
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontFamily: 'DPClear',
                  fontWeight: FontWeight.w500,
                ))
          ],
        ),
      ),
    );
  }

  void _navigateToSubscriptionScreen(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (c, a1, a2) => SubscriptionPaymentWebPage(
          amount: amount,
          subscriptionId: subId,
          planType: plan,
          screen: 'list',
        ),
        transitionsBuilder: (c, anim, a2, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }
}
