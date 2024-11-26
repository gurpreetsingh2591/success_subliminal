import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/api/ApiService.dart';
import '../../utils/constant.dart';
import '../../utils/shared_prefs.dart';
import '../app/router.dart';
import '../widget/BottomBarStateFullWidget.dart';
import '../widget/OfferContainer.dart';

class SubliminalDetailPage extends StatefulWidget {
  final String subId;

  const SubliminalDetailPage({Key? key, required this.subId}) : super(key: key);

  @override
  SubliminalDetailPageState createState() => SubliminalDetailPageState();
}

class SubliminalDetailPageState extends State<SubliminalDetailPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late dynamic subliminalDetail;
  late dynamic subliminalDataDetail;
  bool isLoading = false;
  bool isSubliminal = false;
  late dynamic subliminal;
  bool isTrial = false;
  bool isActive = false;

  double bottomMargin = 80;
  String title = "";

  @override
  void initState() {
    super.initState();
    _getSubliminalDetailData(widget.subId);

    initializePreference().whenComplete(() {
      isTrial = SharedPrefs().isFreeTrail();
      isActive = SharedPrefs().isSubscription();
      setState(() {});
    });
  }

  Future<void> initializePreference() async {
    SharedPrefs.init(await SharedPreferences.getInstance());
  }

  void _getSubliminalDetailData(String id) async {
    subliminalDetail =
        await ApiService().getSubliminalDetailWithoutLogin(context, id);

    Future.delayed(const Duration(seconds: 2)).then((value) => setState(() {
          setState(() {
            if (subliminalDetail['http_code'] != 200) {
            } else {
              isSubliminal = true;
              subliminalDataDetail = subliminalDetail['data'];

              setState(() {
                title = subliminalDataDetail['subliminal']['title'];
              });
            }
            /*if (kDebugMode) {
                  print("size ----${subliminalDataDetail.toString()}");
                }*/
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
      body: SafeArea(
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
          child: Stack(
            children: <Widget>[
              Image.asset(
                'assets/images/ic_bg_dark_blue.png',
                fit: BoxFit.cover,
                height: double.infinity,
                width: double.infinity,
                alignment: Alignment.center,
              ),
              buildTopBarContainer(context, mq),
              const BottomBarStateFull(screen: "home", isUserLogin: false),
              Container(
                margin: EdgeInsets.only(bottom: bottomMargin, top: 70),
                child: ListView(
                  shrinkWrap: false,
                  primary: true,
                  children: [
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
      ),
    );
  }

  Widget buildSubliminalDetailContainer(BuildContext context, Size mq) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            decoration: kEditTextDecoration,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: Align(
                alignment: Alignment.center,
                child: subliminalDataDetail['subliminal']['cover_path'] != ""
                    ? Image.network(
                        subliminalDataDetail['subliminal']['cover_path'],
                        fit: BoxFit.fitWidth,
                      )
                    : Image.asset('assets/images/img_dummy_2.png', scale: 1.5),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(left: 5, top: 25),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                subliminalDataDetail['subliminal']['title'],
                style: const TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontFamily: 'DPClear',
                    fontWeight: FontWeight.w600),
              ),
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
            padding: const EdgeInsets.only(left: 5, top: 25),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                '\$${subliminalDataDetail['subliminal']['price'].toString()}',
                style: const TextStyle(
                    fontSize: 32,
                    color: Colors.white,
                    fontFamily: 'DPClear',
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
          Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Container(
                    height: 50,
                    decoration: kTransButtonBoxDecoration,
                    margin: const EdgeInsets.only(top: 15),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          margin: const EdgeInsets.only(left: 10),
                          child: Align(
                              alignment: Alignment.center,
                              child: Image.asset('assets/images/ic_edit.png',
                                  scale: 1.5)),
                        ),
                        GestureDetector(
                            onTap: () => {},
                            child: Container(
                                alignment: Alignment.center,
                                margin:
                                    const EdgeInsets.only(left: 5, right: 5),
                                child: Text(
                                  "Add to wishlist".toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontFamily: 'DPClear',
                                    fontWeight: FontWeight.w600,
                                  ),
                                  softWrap: true,
                                ))),
                      ],
                    ),
                  ),
                ),
                Expanded(
                    flex: 1,
                    child: buildListenButton(
                        context, subliminalDataDetail['subliminal']))
              ])
        ],
      ),
    );
  }

  Widget buildListenButton(BuildContext context, dynamic subliminalList) {
    return ConstrainedBox(
        constraints: const BoxConstraints(minWidth: double.infinity),
        child: Container(
            decoration: kButtonBox10Decoration,
            margin: const EdgeInsets.only(top: 15, left: 10),
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                SharedPrefs().setFreeSubId(subliminalList['id'].toString());
                context.push(Routes.signUp);
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // <-- Radius
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                      child: Text(kListenWithTrial.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontFamily: 'DPClear',
                            fontWeight: FontWeight.w400,
                          ))),
                ],
              ),
            )));
  }

  Widget buildTopBarContainer(BuildContext context, Size mq) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => {
            setState(() {
              //context.pop(Routes.discover);
              Navigator.pop(context, true);
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
            padding: const EdgeInsets.only(left: 15, top: 10),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                title,
                maxLines: 2,
                style: const TextStyle(
                    fontSize: 32,
                    color: Colors.white,
                    fontFamily: 'DPClear',
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
