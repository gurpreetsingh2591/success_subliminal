import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/api/ApiService.dart';
import '../../utils/constant.dart';
import '../../utils/shared_prefs.dart';

class SubscriptionSettingWebPage extends StatefulWidget {
  const SubscriptionSettingWebPage({Key? key}) : super(key: key);

  @override
  SubscriptionSettingWebState createState() => SubscriptionSettingWebState();
}

class SubscriptionSettingWebState extends State<SubscriptionSettingWebPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String screenName = "";
  List<dynamic> subscriptionList = [];
  List<dynamic> subscriptionPriceList = [];
  late dynamic subscription;

  @override
  void initState() {
    super.initState();

    _getSubscriptionListData();
    initializePreference().whenComplete(() {
      setState(() {});
    });
  }

  void _getSubscriptionListData() async {
    subscription = await ApiService().getStripeProduct(context);

    Future.delayed(const Duration(seconds: 1))
        .then((value) => setState(() async {
              setState(() {
                if (subscription['http_code'] != 200) {
                } else {
                  subscriptionList
                      .addAll(subscription['data']['product_list']['data']);
                  subscriptionPriceList
                      .addAll(subscription['data']['product_price']['data']);
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
    return buildHomeContainer(context, mq);
  }

  Widget buildHomeContainer(BuildContext context, Size mq) {
    return Container(
      margin: const EdgeInsets.only(top: 50),
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          primary: false,
          itemCount: subscriptionList.length,
          itemBuilder: (BuildContext context, int index) {
            return buildSubscriptionListItem(
                context, subscriptionList[index], index);
          }),
    );
  }

  Widget buildSubscriptionListItem(
      BuildContext context, dynamic subscription, int index) {
    return GestureDetector(
      onTap: () => {setState(() {})},
      child: Container(
        margin: const EdgeInsets.only(top: 20),
        padding: const EdgeInsets.all(15),
        decoration: kUnSelectedCollectionBoxDecoration,
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
}
