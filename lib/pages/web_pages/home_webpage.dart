import 'package:email_validator/email_validator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:success_subliminal/pages/web_pages/subliminal_detail_web_page.dart';
import 'package:success_subliminal/widget/WebFooterWidget.dart';
import 'package:video_player/video_player.dart';

import '../../app/router.dart';
import '../../data/api/ApiConstants.dart';
import '../../data/api/ApiService.dart';
import '../../dialogs/custom_alert_dialog.dart';
import '../../utils/MyCustomScrollBehavior.dart';
import '../../utils/center_loader.dart';
import '../../utils/constant.dart';
import '../../utils/shared_prefs.dart';
import '../../utils/toast.dart';
import '../../widget/CommonTextFieldWithoutBG.dart';
import '../../widget/TopBarWebWithoutLogin.dart';
import '../home_page.dart';

class HomeWebPage extends StatefulWidget {
  final String? redirect;

  const HomeWebPage({Key? key, this.redirect}) : super(key: key);

  @override
  HomeWebScreen createState() => HomeWebScreen();
}

class HomeWebScreen extends State<HomeWebPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();

  bool isLogin = false;
  bool isTrial = false;
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
  Size wsize = Size.zero;
  double turnOnSize = 40;
  double firstPageHeight = 0.85;
  double subButtonMargin = 50;
  double subButtonMargins = 50;
  double imageScale = 1;
  double shadowImageScale = 1;
  double marginTopEmail = 200;
  double marginTopSigning = 150;
  double marginRightSigning = 150;
  double scrollPos = 1;
  bool isSubliminal = false;

  List<int> verticalData = [];
  List<int> horizontalData = [];

  final int increment = 10;

  bool isLoadingVertical = false;
  bool isLoadingHorizontal = false;

  @override
  void initState() {
    super.initState();

    videoPlayerController = VideoPlayerController.network(videoUrl)
      ..initialize().then((_) {
        setState(() {
          videoPlayerController!.seekTo(const Duration(seconds: 1));
          videoPlayerController!.setLooping(false);
          videoPlayerController!.addListener(() {
            if (videoPlayerController!.value.position >=
                videoPlayerController!.value.duration) {
              // Video has reached its end
              setState(() {
                videoPlayerController!.pause();
              });
            }
          });
        });
      });

    initializePreference().whenComplete(() {
      isLogin = SharedPrefs().isLogin();
      isTrial = SharedPrefs().isFreeTrail();

      if (isLogin) {
        videoPlayerController!.pause();
        context.go(Routes.create);
      }
    });

    _getCategoriesData();
    _getTestimonialListData();
  }

  _handleOnReceiveEmailButton() {
    if (_emailText.text.toString() == "") {
      const CustomAlertDialog().errorDialog(kEmailNullError, context);
    } else if (!EmailValidator.validate(_emailText.text.toString())) {
      const CustomAlertDialog().errorDialog(kInvalidEmailError, context);
    } else {
      setState(() {
        FocusScope.of(context).unfocus();

        showCenterLoader(context);
        _getSendEmailData(_emailText.text.toString());
      });
    }
  }

  void _getSubliminalListData(String categoryId) async {
    subliminal =
        await ApiService().getDiscoverSubliminalList(context, categoryId);

    Future.delayed(const Duration(seconds: 3)).then((value) => setState(() {
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
        }));
  }

  void _getTestimonialListData() async {
    testimonials = await ApiService().getTestimonialList(context);

    Future.delayed(const Duration(seconds: 3)).then((value) => setState(() {
          testimonialsList.clear();
          if (testimonials['http_code'] != 200) {
          } else {
            setState(() {
              testimonialsList.addAll(testimonials['data']['testimonial']);
            });
          }
          if (kDebugMode) {
            print(testimonialsList);
          }
        }));
  }

  void _getSendEmailData(String emailId) async {
    sendEmail = await ApiService().getSendEmail(emailId, context);

    Future.delayed(const Duration(seconds: 2)).then((value) => setState(() {
          if (sendEmail['http_code'] != 200) {
          } else {
            toast("Download link has been sent on your email", false);
          }
          if (kDebugMode) {
            print("size ----${sendEmail['http_code']}");
          }
          _emailText.text = "";
          Navigator.of(context, rootNavigator: true).pop();
        }));
  }

  void _getCategoriesData() async {
    categories = await ApiService().getCategories(context);

    Future.delayed(const Duration(seconds: 3)).then((value) => setState(() {
          if (categories['http_code'] != 200) {
          } else {
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
    final mq = MediaQuery.of(context).size;
    return WillPopScope(
        onWillPop: () async => false,
        child: MaterialApp(
            scrollBehavior: MyCustomScrollBehavior(),
            debugShowCheckedModeBanner: false,
            home: Scaffold(
                appBar: PreferredSize(
                  preferredSize: const Size.fromHeight(0),
                  child: AppBar(
                    flexibleSpace: Container(
                      decoration:
                          const BoxDecoration(gradient: statusBarGradient),
                    ),
                  ),
                ),
                body: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    if (constraints.maxWidth > 757) {
                      if (constraints.maxWidth < 900) {
                        turnOnSize = 35;
                        imageScale = 3;
                        subButtonMargin = 30;
                        firstPageHeight = 0.55;
                        marginTopEmail = 100;
                        marginTopSigning = 70;
                        marginRightSigning = 70;
                        shadowImageScale = 2;
                      } else if (constraints.maxWidth < 1100) {
                        turnOnSize = 40;
                        imageScale = 2.5;
                        subButtonMargin = 30;
                        firstPageHeight = 0.60;
                        marginTopEmail = 100;
                        marginTopSigning = 70;
                        marginRightSigning = 70;
                        shadowImageScale = 1.5;
                      } else if (constraints.maxWidth < 1300) {
                        turnOnSize = 40;
                        imageScale = 2;
                        subButtonMargin = 30;
                        firstPageHeight = .75;
                        marginTopEmail = 130;
                        marginTopSigning = 100;
                        marginRightSigning = 100;
                        shadowImageScale = 2;
                      } else if (constraints.maxWidth < 1600) {
                        turnOnSize = 50;
                        imageScale = 1.5;
                        subButtonMargin = 30;
                        firstPageHeight = .85;
                        marginTopEmail = 160;
                        marginTopSigning = 120;
                        marginRightSigning = 120;
                        shadowImageScale = 2;
                      } else if (constraints.maxWidth < 2000) {
                        turnOnSize = 60;
                        imageScale = 1;
                        subButtonMargin = 30;
                        firstPageHeight = 0.85;
                        marginTopEmail = 200;
                        marginTopSigning = 150;
                        marginRightSigning = 150;
                        shadowImageScale = 2;
                      }
                      return buildHomeContainer(context, mq);
                    } else {
                      return const HomePage();
                    }
                  },
                ))));
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
              TopBarWithoutLoginContainer(screen: "home", mq: mq),
              Container(
                  margin: const EdgeInsets.only(top: 100),
                  child: ListView(
                    shrinkWrap: false,
                    primary: false,
                    children: [
                      Stack(children: [
                        Column(
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Container(
                                  width: mq.width * .5,
                                  margin: const EdgeInsets.only(left: 100),
                                  height: mq.height * firstPageHeight,
                                  alignment: Alignment.bottomRight,
                                  child: ClipRRect(
                                    child: Image.asset(
                                      'assets/images/ic_dummy_home_web.png',
                                      scale: imageScale,
                                    ),
                                  ),
                                ),
                              ),
                            ]),
                        Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                margin:
                                    const EdgeInsets.only(top: 80, left: 100),
                                width: mq.width * .6,
                                child: RichText(
                                  text: TextSpan(
                                    text: kTurn,
                                    style: TextStyle(
                                        fontSize: turnOnSize,
                                        color: kYellow,
                                        letterSpacing: -1.5,
                                        fontFamily: 'DPClear',
                                        fontWeight: FontWeight.w600),
                                    children: [
                                      TextSpan(
                                          text: kWith,
                                          style: TextStyle(
                                              fontSize: turnOnSize,
                                              color: Colors.white,
                                              fontFamily: 'DPClear',
                                              letterSpacing: -1.5,
                                              fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ),
                              ),
                              MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                  onTap: () => {
                                    setState(() {
                                      videoPlayerController!.pause();
                                      context.go(Routes.signUp);
                                    })
                                  },
                                  child: Align(
                                    alignment: Alignment.topLeft,
                                    child: Container(
                                      margin: const EdgeInsets.only(
                                          top: 20, left: 90),
                                      height: 70,
                                      alignment: Alignment.topLeft,
                                      child: ClipRRect(
                                        child: Image.asset(
                                          'assets/images/ic_text_button.png',
                                          scale: 1,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                alignment: Alignment.topLeft,
                                margin: const EdgeInsets.only(
                                    left: 100, top: 15, right: 50),
                                child: const Text(
                                  kOffer1,
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                      fontFamily: 'DPClear',
                                      fontWeight: FontWeight.w400),
                                ),
                              ),
                            ]),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Image.asset(
                            'assets/images/ic_shadow.png',
                            color: kBaseColorDark,
                            scale: shadowImageScale,
                          ),
                        ),
                      ]),
                      buildWatchVideoContainer(context, mq),
                      buildDiscoverBarContainer(context),
                      buildSentEmailContainer(context, mq),
                      const WebFooterWidget()
                    ],
                  ))
            ])));
  }

  Widget buildDiscoverBarContainer(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20, top: 100, left: 10, right: 10),
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
                          Positioned(
                            top: 170,
                            right: 2,
                            child: InkWell(
                              onTap: () {
                                scrollToRight();
                              },
                              child: Container(
                                margin: EdgeInsets.only(left: subButtonMargins),
                                decoration: const BoxDecoration(
                                    color: Colors.black,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                height: 40,
                                width: 40,
                                child: const Icon(
                                  Icons.arrow_forward,
                                  color: Colors.white,
                                  size: 15,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 170,
                            height: 40,
                            width: 40,
                            child: Container(
                              decoration: const BoxDecoration(
                                  color: Colors.black,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              height: 40,
                              width: 40,
                              child: InkWell(
                                onTap: () {
                                  _scrollToLeft();
                                },
                                child: const Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                  size: 15,
                                ),
                              ),
                            ),
                          ),
                        ])),
                  ])
                : const SizedBox(
                    height: 500,
                    child: Center(child: CircularProgressIndicator())),
            discoverButton(),
            buildTestimonialContainer(context),
          ],
        ),
      ),
    );
  }

  Widget buildTestimonialContainer(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 100, bottom: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Testimonials",
            style: TextStyle(
                fontSize: turnOnSize,
                color: Colors.white,
                letterSpacing: -1.0,
                fontFamily: 'DPClear',
                fontWeight: FontWeight.w600),
          ),
          testimonialsList.isNotEmpty
              ? buildTestimonialListContainer(context)
              : SizedBox(
                  child: Center(
                      child: Container(
                          margin: const EdgeInsets.only(top: 10),
                          child: const Align(
                            alignment: Alignment.center,
                            child: Text(
                              "No Testimonials",
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontFamily: 'DPClear',
                                  fontWeight: FontWeight.w600),
                            ),
                          )))),
        ],
      ),
    );
  }

  Widget buildTestimonialListContainer(BuildContext context) {
    return (testimonialsList.isNotEmpty)
        ? Align(
            alignment: Alignment.topLeft,
            child: Container(
                padding: const EdgeInsets.only(left: 10, right: 10),
                height: 260,
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    primary: false,
                    itemCount: testimonialsList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return buildTestimonialListItem(
                          context, testimonialsList[index]);
                    })))
        : Container(
            margin: const EdgeInsets.only(top: 10),
            child: const Align(
              alignment: Alignment.center,
              child: Text(
                "No Testimonials",
                style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontFamily: 'DPClear',
                    fontWeight: FontWeight.w600),
              ),
            ));
  }

  Widget buildTestimonialListItem(
      BuildContext context, dynamic testimonialList) {
    return Container(
      width: 400,
      margin: const EdgeInsets.only(left: 5, right: 5, top: 50),
      padding: const EdgeInsets.all(10),
      decoration: kEditTextDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                  width: 70,
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: Align(
                        alignment: Alignment.center,
                        child: testimonialList['photo'] != ""
                            ? Image.network(
                                ApiConstants.baseUrlAssets +
                                    testimonialList['photo'],
                                fit: BoxFit.fill,
                                loadingBuilder: (BuildContext context,
                                    Widget child,
                                    ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                    ),
                                  );
                                },
                              )
                            : Image.asset(
                                'assets/images/ic_dummy_banner.png',
                                fit: BoxFit.fill,
                              ),
                      ))),
              Container(
                  margin: const EdgeInsets.only(left: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          padding: const EdgeInsets.only(right: 5),
                          height: 15,
                          child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                              primary: false,
                              itemCount: testimonialList['rating'],
                              itemBuilder: (BuildContext context, int index) {
                                return Container(
                                    padding: const EdgeInsets.only(right: 3),
                                    child: Image.asset(
                                      'assets/images/ic_heart_icon.png',
                                      fit: BoxFit.fill,
                                    ));
                              })),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 10),
                            child: Text(
                              testimonialList['name'].toString().toUpperCase(),
                              style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.white,
                                  fontFamily: 'DPClear',
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      )
                    ],
                  ))
            ],
          ),
          Container(
            width: 380,
            padding: const EdgeInsets.only(top: 10),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                testimonialList['description'],
                maxLines: 5,
                style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontFamily: 'DPClear',
                    fontWeight: FontWeight.w400),
              ),
            ),
          )
        ],
      ),
    );
  }

  void scrollToRight() {
    //scrollPos+=1;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 500),
      curve: Curves.ease,
    );
  }

  void _scrollToLeft() {
    // scrollPos -= 1;
    _scrollController.animateTo(
      _scrollController.position.minScrollExtent,
      duration: const Duration(milliseconds: 500),
      curve: Curves.ease,
    );
  }

  Widget buildSubliminalListWithCatContainer(BuildContext context) {
    return (subliminalList.isNotEmpty)
        ? Align(
            alignment: Alignment.topLeft,
            child: Container(
                margin: const EdgeInsets.only(left: 10, right: 10, top: 20),
                height: 350,
                child: /*ScrollSnapList(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  controller: _scrollController,
                  onItemFocus: _onItemFocus,
                  itemSize: 35,
                  itemBuilder: _buildListItem,
                  itemCount: data.length,
                  reverse: true,
                ),*/
                    ListView.builder(
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        primary: false,
                        controller: _scrollController,
                        itemCount: subliminalList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return buildSubliminalListItem(
                              context, subliminalList[index]);
                        })))
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
        margin: const EdgeInsets.only(top: 40),
        child: InkWell(
            onTap: () {
              videoPlayerController!.pause();
              context.push(Routes.signUp);
            },
            child: Image.asset('assets/images/ic_discover_btn.png', scale: 2)));
  }

  Widget buildSubliminalListItem(BuildContext context, dynamic subliminalList) {
    return GestureDetector(
      onTap: () => {
        _navigateToSubDetailScreen(context, subliminalList['id'].toString())
      },
      child: Container(
        margin: const EdgeInsets.only(
          left: 5,
          right: 5,
        ),
        padding: const EdgeInsets.all(10),
        decoration: kEditTextDecoration10Radius,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(
                width: 330,
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: Align(
                      alignment: Alignment.center,
                      child: subliminalList['cover_path'] != ""
                          ? Image.network(
                              subliminalList['cover_path'],
                              fit: BoxFit.cover,
                              height: 300,
                              width: 330,
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
                              fit: BoxFit.cover,
                              height: 300,
                              width: 330,
                            ),
                    ))),
            Container(
              padding: const EdgeInsets.only(top: 5),
              child: Align(
                alignment: Alignment.topLeft,
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
                padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
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

  Widget buildCategoryListItem(
      BuildContext context, String name, String id, int index) {
    return GestureDetector(
        onTap: () => {
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

  Widget buildWatchVideoContainer(BuildContext context, Size mq) {
    return Stack(
      children: [
        videoPlayerController!.value.isInitialized
            ? AspectRatio(
                aspectRatio: videoPlayerController!.value.aspectRatio,
                child: VideoPlayer(videoPlayerController!),
              )
            : Container(),
        AspectRatio(
          aspectRatio: videoPlayerController!.value.aspectRatio,
          child: Container(
            alignment: Alignment.bottomLeft,
            child: VideoProgressIndicator(videoPlayerController!,
                allowScrubbing: true),
          ),
        ),
        AspectRatio(
            aspectRatio: videoPlayerController!.value.aspectRatio,
            child: Container(
              alignment: Alignment.center,
              child: FloatingActionButton(
                onPressed: () {
                  setState(() {
                    videoPlayerController!.value.isPlaying
                        ? videoPlayerController!.pause()
                        : videoPlayerController!.play();
                  });
                },
                backgroundColor: Colors.white,
                foregroundColor: kButtonColor2,
                child: Icon(
                  videoPlayerController!.value.isPlaying
                      ? Icons.pause
                      : Icons.play_arrow,
                ),
              ),
            ))
      ],
    );
  }

  Widget buildTopBarContainer(BuildContext context, Size mq) {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, top: 25),
      height: mq.height * 0.1,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Image.asset(
              'assets/images/app_logo.png',
              scale: 2,
            ),
          ),
          Row(children: [
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => {
                  loginContainerVisible = true,
                  signUpContainerVisible = false,
                  context.pushReplacement(Routes.signIn),
                  videoPlayerController!.pause()
                },
                child: Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.only(left: 30, right: 30),
                    margin: const EdgeInsets.only(right: 10, top: 2),
                    decoration: kBlackButtonBox10Decoration,
                    height: 52,
                    child: Text("Sign In".toUpperCase(),
                        style: const TextStyle(
                            fontSize: 12,
                            letterSpacing: 1,
                            fontFamily: 'DPClear',
                            color: Colors.white,
                            fontWeight: FontWeight.w400),
                        textAlign: TextAlign.center),
                  ),
                ),
              ),
            ),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => {
                  setState(() {
                    context.go(Routes.signUp);
                    videoPlayerController!.pause();
                  })
                },
                child: Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    height: 60,
                    alignment: Alignment.center,
                    child: ClipRRect(
                      child: Image.asset(
                        'assets/images/ic_text_button.png',
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ]),
        ],
      ),
    );
  }

  Widget buildSentEmailContainer(BuildContext context, Size mq) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10, top: 40, left: 10, right: 10),
      decoration: kBlackButtonBox30Decoration,
      child: Container(
        padding: const EdgeInsets.only(left: 10, right: 10, bottom: 20),
        decoration: kSendEmailBoxImageDecoration,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded(
                flex: 2,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        padding:
                            const EdgeInsets.only(left: 30, right: 20, top: 30),
                        child: RichText(
                          textAlign: TextAlign.left,
                          text: TextSpan(
                            text: 'Download',
                            style: TextStyle(
                                fontSize: turnOnSize,
                                color: kYellow,
                                fontFamily: 'DPClear',
                                fontWeight: FontWeight.w500),
                            children: <TextSpan>[
                              TextSpan(
                                  text: ' Your Free Subliminal Today',
                                  style: TextStyle(
                                      fontSize: turnOnSize,
                                      color: Colors.white,
                                      fontFamily: 'DPClear',
                                      fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      ),
                    ])),
            Expanded(
                flex: 3,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(
                            left: 30, right: 30, top: marginTopEmail),
                        child: const Text(
                          'Enter your email below to receive the subliminal download link',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontFamily: 'DPClear',
                              fontWeight: FontWeight.w300),
                        ),
                      ),
                      Container(
                          height: 80,
                          margin: const EdgeInsets.only(
                              left: 30, right: 30, top: 15),
                          decoration: kEditTextEmailDecoration,
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: CommonTextFieldWithoutBG(
                                  controller: _emailText,
                                  hintText: kEnterEmail,
                                  text: "",
                                  isFocused: true,
                                  onEnterKey: () =>
                                      _handleOnReceiveEmailButton(),
                                ),
                              ),
                              Expanded(
                                  flex: 2,
                                  child: MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: GestureDetector(
                                      onTap: () => {
                                        setState(() {
                                          _handleOnReceiveEmailButton();
                                        })
                                      },
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Container(
                                          margin: const EdgeInsets.only(top: 3),
                                          height: 80,
                                          alignment: Alignment.centerRight,
                                          child: ClipRRect(
                                            child: Image.asset(
                                              'assets/images/ic_export_button.png',
                                              scale: 1,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ))
                            ],
                          )),
                      Container(
                        padding: EdgeInsets.only(
                            left: 30,
                            bottom: 20,
                            right: marginRightSigning,
                            top: marginTopSigning),
                        child: RichText(
                          textAlign: TextAlign.left,
                          text: TextSpan(
                            text: 'By signing up, you agree to the',
                            style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white54,
                                letterSpacing: .5,
                                fontFamily: 'DPClear',
                                height: 1.5,
                                fontWeight: FontWeight.w200),
                            children: [
                              TextSpan(
                                text: ' Terms & Conditions',
                                style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                    letterSpacing: .5,
                                    height: 1.5,
                                    fontFamily: 'DPClear',
                                    fontWeight: FontWeight.w200),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    context.push(Routes.term);
                                    videoPlayerController!.pause();
                                    // launchURL();
                                  },
                              ),
                              const TextSpan(
                                  text:
                                      ' and that Success Subliminals may send you marketing emails '
                                      'and understand that we may use your information in accordance with our',
                                  style: TextStyle(
                                      fontSize: 14,
                                      height: 1.5,
                                      letterSpacing: .5,
                                      color: Colors.white54,
                                      fontFamily: 'DPClear',
                                      fontWeight: FontWeight.w200)),
                              TextSpan(
                                text: '  Privacy Policy.',
                                style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                    letterSpacing: .5,
                                    height: 1.5,
                                    fontFamily: 'DPClear',
                                    fontWeight: FontWeight.w200),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    videoPlayerController!.pause();
                                    context
                                        .push(Routes.privacy); //  launchURL();
                                  },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ])),
          ],
        ),
      ),
    );
  }

  buildVideoDialogContainer(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0)),
            backgroundColor: kTrans,
            insetPadding: const EdgeInsets.all(15),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () =>
                        {Navigator.of(context, rootNavigator: true).pop()},
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Image.asset('assets/images/ic_close_bg.png',
                          scale: 5),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  void _navigateToSubDetailScreen(BuildContext context, String id) {
    videoPlayerController!.pause();

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (c, a1, a2) => SubliminalDetailWebPage(subId: id),
        transitionsBuilder: (c, anim, a2, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }
}
