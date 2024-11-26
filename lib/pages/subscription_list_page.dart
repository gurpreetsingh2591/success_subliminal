import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:success_subliminal/pages/subscription_payment_page.dart';
import 'package:success_subliminal/pages/web_pages/subscription_list_web_page.dart';

import '../app/router.dart';
import '../data/api/ApiService.dart';
import '../utils/constant.dart';
import '../utils/shared_prefs.dart';
import '../utils/toast.dart';

class SubscriptionListPage extends StatefulWidget {
  final String? screen;

  const SubscriptionListPage({Key? key, required this.screen})
      : super(key: key);

  @override
  SubscriptionScreen createState() => SubscriptionScreen();
}

class SubscriptionScreen extends State<SubscriptionListPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  bool isLogin = false;
  List<dynamic> subscriptionList = [];
  List<dynamic> subscriptionPriceList = [];
  List<dynamic> tempSubscriptionPriceList = [];
  List<dynamic> tempSubscriptionList = [];
  late dynamic subscription;
  int selectIndex = 0;
  String amount = "";
  String plan = "";
  String subId = "";
  bool isSub = false;
  bool isFreeTrialUsed = false;
  String buttonName = "";

  @override
  void initState() {
    super.initState();
    initializePreference().whenComplete(() {
      setState(() {
        isLogin = SharedPrefs().isLogin();
        isFreeTrialUsed = SharedPrefs().isFreeTrailUsed();
        _getSubscriptionListData();
      });
    });
    if (widget.screen != 'trial') {
      buttonName = "Subscribe Now".toUpperCase();
    } else {
      buttonName = 'Start 7-day Free Trial'.toUpperCase();
    }
  }

  void _getSubscriptionListData() async {
    subscription = await ApiService().getStripeProduct(context);

    Future.delayed(const Duration(seconds: 2)).then((value) =>
        setState(() {
          setState(() {
            if (subscription['http_code'] != 200) {} else {
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
                setState(() {
                  amount = (subscriptionPriceList[0]['unit_amount'] / 100)
                      .toString();
                  subId = subscriptionList[0]['id'];
                  plan = subscriptionList[0]['name'];

                  isSub = true;
                });
              }
            }
            setState(() {
              isSub = true;
            });
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
              return buildHomeContainer(context, mq);
            } else {
              return SubscriptionListWebPage(
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
      //  child: SingleChildScrollView(
      child: Container(
          height: mq.height,
          constraints: BoxConstraints(
            maxHeight: mq.height,
          ),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [backgroundDark, backgroundDark],
              stops: [0.5, 1.5],
            ),
          ),
          child: Stack(children: [
            /* Image.asset(
          'assets/images/bg_image.png',
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
            alignment: Alignment.center,
          ),*/
            // buildBottomBar(context, 'dashboard'),
            SizedBox(
              height: 50,
              child: buildTopBarContainer(context, mq),
            ),
            Container(
                margin: const EdgeInsets.only(bottom: 30, top: 50),
                child: ListView(
                  shrinkWrap: true,
                  primary: false,
                  children: [
                    buildSubscriptionListContainer(context, mq),
                    buildButton(context)
                  ],
                ))
          ])),
      //)
    );
  }

  Widget buildSubscriptionListContainer(BuildContext context, Size mq) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10, top: 20, left: 20, right: 20),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          const Align(
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
          Container(
            margin: const EdgeInsets.only(top: 10),
            alignment: Alignment.topLeft,
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
              alignment: Alignment.topLeft,
              child: Align(
                  alignment: Alignment.topLeft,
                  child: buildSubscriptionContainer(context)))
              : const SizedBox(
              height: 500,
              child: Center(child: CircularProgressIndicator())),
        ],
      ),
    );
  }

  Widget buildSubscriptionContainer(BuildContext contexts) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
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

  Widget buildSubscriptionListItem(BuildContext context, dynamic subscription,
      int index) {
    return GestureDetector(
      onTap: () =>
      {
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
                      fontSize: 22,
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
      children: [
        InkWell(
          onTap: () =>
          {
            setState(() {
              if (widget.screen == "create") {
                Navigator.pop(context);
              } else {
                context.pushReplacement(Routes.dashboard);
              }
              // Navigator.of(context, rootNavigator: true).pop();
              // Navigator.pop(context);
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
            padding: const EdgeInsets.only(top: 10, right: 40),
            child: const Align(
              alignment: Alignment.center,
              child: Text(
                "Subscription",
                maxLines: 2,
                style: TextStyle(
                    fontSize: 26,
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

  Widget buildButton(BuildContext context) {
    return ConstrainedBox(
        constraints: const BoxConstraints(minWidth: double.infinity),
        child: Container(
          decoration: kButtonBox10Decoration,
          margin:
          const EdgeInsets.only(top: 10, right: 25, left: 25, bottom: 20),
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                /*   subscription != null
                    ? _navigateToSubscriptionScreen(context)
                    : toast("Please Select Plan", false);*/

                subscription != null
                    ? context.pushNamed('add-payment', queryParameters: {
                  'amount': amount,
                  "subscriptionId": subId,
                  "planType": plan,
                  "screen": widget.screen,
                })
                    : toast("Please Select Plan", false);
              });

              //context.go(Routes.createSubliminal);
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
                Text(buttonName.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontFamily: 'DPClear',
                      fontWeight: FontWeight.w400,
                    ))
              ],
            ),
          ),
        ));
  }

  void _navigateToSubscriptionScreen(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (c, a1, a2) =>
            SubscriptionPaymentPage(
              amount: amount,
              subscriptionId: subId,
              planType: plan,
              screen: '',
            ),
        transitionsBuilder: (c, anim, a2, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }
}
