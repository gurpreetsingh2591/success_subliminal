import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/router.dart';
import '../../data/api/ApiService.dart';
import '../../utils/constant.dart';
import '../../utils/shared_prefs.dart';
import '../../widget/OfferContainer.dart';
import '../../widget/TopBarWebWithoutLogin.dart';
import '../../widget/WebFooterWithoutLinkWidget.dart';
import '../subliminal_detail_page.dart';

class SubliminalDetailWebPage extends StatefulWidget {
  final String subId;

  const SubliminalDetailWebPage({
    Key? key,
    required this.subId,
  }) : super(key: key);

  @override
  SubliminalDetailWebPageState createState() => SubliminalDetailWebPageState();
}

class SubliminalDetailWebPageState extends State<SubliminalDetailWebPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late dynamic subliminalDetail;
  late dynamic subliminalDataDetail;
  bool isLoading = false;
  bool isSubliminal = false;
  bool isTrial = false;
  late dynamic subliminal;
  double leftPadding = 50;
  double rightPadding = 50;

  @override
  void initState() {
    super.initState();
    _getSubliminalDetailData(widget.subId);
    isTrial = SharedPrefs().isFreeTrail();
    initializePreference().whenComplete(() {
      setState(() {});
    });
  }

  Future<void> initializePreference() async {
    SharedPrefs.init(await SharedPreferences.getInstance());
  }

  void _getSubliminalDetailData(String id) async {
    subliminalDetail =
        await ApiService().getSubliminalDetailWithoutLogin(context, id);

    Future.delayed(const Duration(seconds: 2))
        .then((value) => setState(() async {
              setState(() {
                if (subliminalDetail['http_code'] != 200) {
                } else {
                  isSubliminal = true;
                  subliminalDataDetail = subliminalDetail['data'];
                }
                if (kDebugMode) {
                  print("size ----${subliminalDataDetail.toString()}");
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
                leftPadding = 50;
                rightPadding = 50;
              } else if (constraints.maxWidth < 1100) {
                leftPadding = 50;
                rightPadding = 50;
              } else if (constraints.maxWidth < 1300) {
                leftPadding = 100;
                rightPadding = 100;
              } else if (constraints.maxWidth < 1600) {
                leftPadding = 150;
                rightPadding = 150;
              } else if (constraints.maxWidth < 2000) {
                leftPadding = 200;
                rightPadding = 200;
              }
              return buildHomeContainer(context, mq);
            } else {
              return SubliminalDetailPage(subId: widget.subId);
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
            TopBarWithoutLoginContainer(screen: "home", mq: mq),
            Positioned(
                bottom: 0,
                child: SizedBox(
                    height: 80,
                    width: mq.width * 1,
                    child: const WebFooterWithoutLinkWidget())),
            Container(
              margin: EdgeInsets.only(
                  top: loginTopPadding,
                  right: leftPadding,
                  left: rightPadding,
                  bottom: 100),
              child: ListView(
                shrinkWrap: false,
                primary: true,
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
        crossAxisAlignment: CrossAxisAlignment.start,
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
                        : Image.asset('assets/images/img_dummy_2.png',
                            scale: 1.5),
                  ),
                ),
              )),
          Expanded(
              flex: 7,
              child: Container(
                  padding: const EdgeInsets.only(
                    left: 100,
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
                          margin: const EdgeInsets.only(top: 50),
                          child: const OfferContainerWidget(),
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
                                    child: Image.asset(
                                        'assets/images/ic_edit.png',
                                        scale: 1.5)),
                              ),
                              GestureDetector(
                                  onTap: () =>
                                      {context.pushReplacement(Routes.signIn)},
                                  child: Container(
                                      alignment: Alignment.center,
                                      margin: const EdgeInsets.only(
                                          left: 5, right: 20),
                                      child: Text(
                                        "Add to wishlist".toUpperCase(),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.white,
                                          fontFamily: 'DPClear',
                                          fontWeight: FontWeight.w500,
                                        ),
                                        softWrap: true,
                                      ))),
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
                                buildListenButton(
                                    context, subliminalDataDetail['subliminal'])
                              ]),
                        ),
                      ]))),
        ],
      ),
    );
  }

  Widget buildListenButton(BuildContext context, dynamic subliminalList) {
    return Container(
        decoration: kButtonBox10Decoration,
        padding: const EdgeInsets.only(left: 20, right: 20),
        margin: const EdgeInsets.only(
          left: 30,
        ),
        height: 50,
        child: ElevatedButton(
          onPressed: () {
            setState(() {
              SharedPrefs().setFreeSubId(subliminalList['id'].toString());
              if (kDebugMode) {
                print("free sub id--${SharedPrefs().getFreeSubId()}");
              }
              context.pushReplacement(Routes.signUp);
            });
          },
          style: ElevatedButton.styleFrom(
            primary: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10), // <-- Radius
            ),
          ),
          child: Text(kListenWithTrial.toUpperCase(),
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontFamily: 'DPClear',
                fontWeight: FontWeight.w400,
              )),
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
        onPressed: () {},
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
                          "Home Page".toUpperCase(),
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
      ],
    );
  }
}
