import 'package:chewie/chewie.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:success_subliminal/pages/subliminal_detail_page.dart';
import 'package:success_subliminal/pages/web_pages/sign_up_web_page.dart';
import 'package:video_player/video_player.dart';

import '../app/router.dart';
import '../data/api/ApiConstants.dart';
import '../data/api/ApiService.dart';
import '../dialogs/custom_alert_dialog.dart';
import '../utils/center_loader.dart';
import '../utils/constant.dart';
import '../utils/shared_prefs.dart';
import '../utils/toast.dart';
import '../widget/BottomBarStateFullWidget.dart';
import '../widget/ButtonWidget.dart';
import '../widget/CommonTextFieldWithoutBG.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  HomeScreen createState() => HomeScreen();
}

class HomeScreen extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  var refreshKey = GlobalKey<RefreshIndicatorState>();
  bool isLogin = false;
  bool isTrial = false;
  final _emailText = TextEditingController();
  List<dynamic> categoriesList = [];
  late dynamic categories;
  String categoryId = "";
  late List<dynamic> subliminalList = [];
  late dynamic subliminal;
  late dynamic sendEmail;
  int selectIndex = 0;
  bool isSubliminal = false;
  double dummyImageScale = 1.5;

  List<dynamic> testimonialsList = [];
  late dynamic testimonials;
  late ChewieController chewieController;

/*
  final YoutubePlayerController _controller = YoutubePlayerController(
    initialVideoId: '38r53qxw26s',
    flags: const YoutubePlayerFlags(
      autoPlay: true,
      mute: false,
      showLiveFullscreenButton: false,
    ),
  );*/
  Duration _currentPosition = Duration.zero;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initControllers();
    _getCategoriesData();
    _getTestimonialListData();
    changeScreenName("home");
    initializePreference().whenComplete(() {
      isLogin = SharedPrefs().isLogin();
      isTrial = SharedPrefs().isFreeTrail();

      if (isLogin) {
        context.push(Routes.create);
      }
    });
    // Import package
    trackPermission();
  }

  Future<void> trackPermission() async {
    // Show tracking authorization dialog and ask for permission
    final status = await AppTrackingTransparency.requestTrackingAuthorization();
  }

  void _initControllers() {
    controllers = VideoPlayerController.network(videoUrl)
      ..initialize().then((value) {
        controllers!.seekTo(_currentPosition);

        setState(() {});
      });
    chewieController = ChewieController(
      videoPlayerController: controllers!,
      allowedScreenSleep: true,
      allowFullScreen: true,
      deviceOrientationsAfterFullScreen: [
        DeviceOrientation.portraitDown,
        DeviceOrientation.portraitUp,
      ],
      autoInitialize: false,
      showControls: true,
      autoPlay: false,
      looping: false,
    )..addListener(_reInitListener);
    if (_isPlaying) {
      chewieController.play();
    }
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

  void _reInitControllers() {
    videoPlayerController!.pause();
    chewieController.removeListener(_reInitListener);
    _currentPosition = controllers!.value.position;
    _isPlaying = chewieController.isPlaying;
    _initControllers();
  }

  void _reInitListener() {
    if (!chewieController.isFullScreen) {
      _reInitControllers();
    }
  }

  /*@override
  void dispose() {
    controllers!.dispose();
    chewieController.dispose();
    super.dispose();
  }
*/
  changeScreenName(String name) {
    setState(() {
      screenName = name;
    });
  }

  void _getTestimonialListData() async {
    testimonialsList.clear();

    testimonials = await ApiService().getTestimonialList(context);

    Future.delayed(const Duration(seconds: 2))
        .then((value) => setState(() async {
              setState(() {
                testimonialsList.clear();
                if (testimonials['http_code'] != 200) {
                } else {
                  testimonialsList.addAll(testimonials['data']['testimonial']);
                }
                if (kDebugMode) {
                  print("size ----${testimonialsList.length}");
                }
              });
            }));
  }

  void _getSubliminalListData(String categoryId) async {
    subliminalList.clear();

    subliminal =
        await ApiService().getDiscoverSubliminalList(context, categoryId);

    Future.delayed(const Duration(seconds: 2))
        .then((value) => setState(() async {
              setState(() {
                isSubliminal = true;
                subliminalList.clear();
                if (subliminal['http_code'] != 200) {
                } else {
                  subliminalList.addAll(subliminal['data']['subliminals']);
                }
                if (kDebugMode) {
                  print("size ----${subliminalList.length}");
                }
              });
            }));
  }

  void _getSendEmailData(String emailId) async {
    sendEmail = await ApiService().getSendEmail(emailId, context);

    Future.delayed(const Duration(seconds: 2))
        .then((value) => setState(() async {
              setState(() {
                if (sendEmail['http_code'] != 200) {
                } else {
                  toast("Download link has been sent on your email", false);
                }
                if (kDebugMode) {
                  print("size ----${sendEmail['http_code']}");
                }
                _emailText.text = "";
                Navigator.of(context, rootNavigator: true).pop();
              });
            }));
  }

  void _getCategoriesData() async {
    categories = await ApiService().getCategories(context);

    Future.delayed(const Duration(seconds: 1))
        .then((value) => setState(() async {
              setState(() {
                if (categories['http_code'] != 200) {
                } else {
                  categoriesList.addAll(categories['data']['categories']);
                  categoryId =
                      categories['data']['categories'][0]['id'].toString();
                  _getSubliminalListData(categoryId);
                }
                print("size ----${categoriesList.length}");
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
            if (constraints.maxWidth < 757) {
              if (constraints.maxWidth > 500) {
                dummyImageScale = 1;
              } else {
                dummyImageScale = 1.5;
              }
              return buildHomeContainer(context, mq);
            } else {
              return const SignUpWebPage();
            }
          },
        ));
  }

  Widget buildHomeContainer(BuildContext context, Size mq) {
    return RefreshIndicator(
      key: refreshKey,
      color: Colors.black,
      onRefresh: () async {
        _getCategoriesData();
        _getTestimonialListData();
        initializePreference().whenComplete(() {
          isLogin = SharedPrefs().isLogin();
          isTrial = SharedPrefs().isFreeTrail();
          if (isLogin) {
            context.push(Routes.create);
          }
        });
      },
      child: SafeArea(
        child: Container(
            constraints: BoxConstraints(
              maxHeight: mq.height,
            ),
            child: Stack(children: [
              Image.asset(
                'assets/images/bg_image.png',
                fit: BoxFit.cover,
                height: double.infinity,
                width: double.infinity,
                alignment: Alignment.center,
              ),

              const BottomBarStateFull(
                screen: "home",
                isUserLogin: false,
              ),
              // buildBottomBarContainer(context),
              Container(
                padding: const EdgeInsets.only(bottom: 70),
                child: ListView(
                  shrinkWrap: false,
                  primary: false,
                  children: [
                    buildTopBarContainer(context, mq),
                    Container(
                      padding:
                          const EdgeInsets.only(left: 20, right: 20, top: 10),
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: const TextSpan(
                          text: kTurn,
                          style: TextStyle(
                              fontSize: 26,
                              color: kYellow,
                              fontFamily: 'DPClear',
                              fontWeight: FontWeight.w500),
                          /*defining default style is optional */
                          children: <TextSpan>[
                            TextSpan(
                                text: kWith,
                                style: TextStyle(
                                    fontSize: 26,
                                    color: Colors.white,
                                    fontFamily: 'DPClear',
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      decoration: kAllCornerBackgroundBoxDecoration,
                      margin:
                          const EdgeInsets.only(left: 15, right: 15, top: 20),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20.0),
                        child: Align(
                          alignment: Alignment.center,
                          child: Image.asset(
                            'assets/images/dummy_image.png',
                            scale: dummyImageScale,
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                        onTap: () =>
                            {controllers!.pause(), context.push(Routes.signUp)},
                        child: Container(
                          margin: const EdgeInsets.only(
                              left: 15, right: 15, top: 20),
                          padding: const EdgeInsets.only(
                              left: 20, top: 15, bottom: 15, right: 20),
                          decoration: kButtonBox10Decoration2,
                          alignment: Alignment.center,
                          child: Text(
                            !isTrial
                                ? kStartFreeTrial.toUpperCase()
                                : kYouHaveTrial.toUpperCase(),
                            style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontFamily: 'DPClear',
                                fontWeight: FontWeight.w500),
                          ),
                        )),
                    Container(
                      padding: const EdgeInsets.only(
                          left: 20, top: 15, bottom: 15, right: 20),
                      alignment: Alignment.center,
                      child: const Text(
                        kOffer1,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontFamily: 'DPClear',
                            fontWeight: FontWeight.w400),
                      ),
                    ),
                    buildVideoBlock(context, mq),
                    // : buildWatchVideoContainer(context),
                    buildDiscoverBarContainer(context),
                    buildTestimonialContainer(context),
                    buildSentEmailContainer(context),
                    buildTermsContainer(context)
                  ],
                ),
              )
            ])),
      ),
    );
  }

  Widget buildBottomBarContainer(BuildContext context) {
    return Positioned(
      bottom: 0,
      width: MediaQuery.of(context).size.width,
      child: Container(
        decoration: kBottomBarBgDecoration,
        height: 70,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(right: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    'assets/images/ic_home.png',
                    scale: 1.5,
                  ),
                  const Text(
                    'Home',
                    style: TextStyle(
                        fontSize: 12,
                        color: kYellow,
                        fontFamily: 'DPClear',
                        fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => {
                controllers!.pause(),
                context.push(Routes.signUp)

                // _navigateToDiscoverScreen(context)
              },
              child: Container(
                margin: const EdgeInsets.only(left: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.asset('assets/images/ic_discover.png', scale: 1.5),
                    const Text(
                      'Discover',
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontFamily: 'DPClear',
                          fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDiscoverBarContainer(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20, top: 20),
      decoration: kAllCornerBackgroundBoxDecoration,
      child: Container(
        padding: const EdgeInsets.only(
          top: 15,
          bottom: 15,
        ),
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
                children: <TextSpan>[
                  TextSpan(
                      text: " Subliminals",
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
                padding: const EdgeInsets.only(left: 15, right: 15),
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
                margin: const EdgeInsets.only(left: 15, right: 15),
                height: 180,
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    primary: false,
                    itemCount: subliminalList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return buildSubliminalListItem(
                          context, subliminalList[index]);
                    })))
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

  Widget buildTestimonialContainer(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Container(
        padding: const EdgeInsets.only(top: 10, bottom: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Testimonials",
              style: TextStyle(
                  fontSize: 26,
                  color: Colors.white,
                  letterSpacing: -1.0,
                  fontFamily: 'DPClear',
                  fontWeight: FontWeight.w600),
            ),
            testimonialsList.isNotEmpty
                ? buildTestimonialListContainer(context)
                : const SizedBox(
                    child: Center(child: CircularProgressIndicator())),
          ],
        ),
      ),
    );
  }

  Widget buildTestimonialListContainer(BuildContext context) {
    return (testimonialsList.isNotEmpty)
        ? SingleChildScrollView(
            child: Align(
                alignment: Alignment.topLeft,
                child: Container(
                    margin: const EdgeInsets.only(top: 10),
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    height: 230,
                    child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        primary: false,
                        itemCount: testimonialsList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return buildTestimonialListItem(
                              context, testimonialsList[index]);
                        }))))
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
      width: 275,
      margin: const EdgeInsets.only(left: 5, right: 5, top: 0),
      padding: const EdgeInsets.all(10),
      decoration: kAllCornerBackgroundBox20Decoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: SizedBox(
                    width: 60,
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Align(
                          alignment: Alignment.center,
                          child: testimonialList['photo'] != ""
                              ? Image.network(
                                  ApiConstants.baseUrlAssets +
                                      testimonialList['photo'],
                                  fit: BoxFit.contain,
                                  loadingBuilder: (BuildContext context,
                                      Widget child,
                                      ImageChunkEvent? loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
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
                                    );
                                  },
                                )
                              : Image.asset(
                                  'assets/images/bg_logo_image.png',
                                  fit: BoxFit.contain,
                                ),
                        ))),
              ),
              Expanded(
                  flex: 3,
                  child: Container(
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
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return Container(
                                        padding:
                                            const EdgeInsets.only(right: 3),
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
                                  testimonialList['name']
                                      .toString()
                                      .toUpperCase(),
                                  style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.white,
                                      fontFamily: 'DPClear',
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          )
                        ],
                      )))
            ],
          ),
          Container(
            padding: const EdgeInsets.only(top: 10),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                testimonialList['description'],
                maxLines: 5,
                style: const TextStyle(
                    fontSize: 12,
                    height: 1.5,
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
      onTap: () => {
        _navigateToSubDetailScreen(
            context, subliminalList['title'], subliminalList['id'].toString())
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
                              image: subliminalList['cover_path'],
                              fit: BoxFit.cover,
                            )
                          : Image.asset(
                              'assets/images/bg_logo_image.png',
                              height: 120,
                              width: 140,
                              fit: BoxFit.cover,
                            ), /* subliminalList['cover_path'] != ""
                          ? Image.network(
                              subliminalList['cover_path'],
                              fit: BoxFit.fill,
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
                            ),*/
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

  Widget buildVideoBlock(BuildContext context, Size mq) {
    return Container(
        margin: const EdgeInsets.only(left: 15, right: 15),
        alignment: Alignment.center,
        decoration: kBlackButtonBox10Decoration,
        height: 300,
        width: mq.width,
        child: buildVideoContainer(context));
  }

  Widget buildWatchVideoContainer(BuildContext context) {
    return GestureDetector(
        onTap: () => {buildVideoDialogContainer(context)},
        child: Container(
          margin:
              const EdgeInsets.only(left: 15, right: 15, top: 30, bottom: 30),
          padding:
              const EdgeInsets.only(left: 20, top: 15, bottom: 15, right: 20),
          decoration: kBlackButtonBox10Decoration2,
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                margin: const EdgeInsets.only(right: 15),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Image.asset('assets/images/ic_video.png', scale: 1.5),
                ),
              ),
              const Text('WATCH VIDEO',
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontFamily: 'DPClear',
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ));
  }

  Widget buildSentEmailContainer(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10, top: 10),
      decoration: kBlackButtonBox30Decoration,
      child: Container(
          padding:
              const EdgeInsets.only(top: 30, left: 10, right: 10, bottom: 50),
          decoration: kSendEmailBoxImageDecorationMobile,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    text: 'Download',
                    style: TextStyle(
                        fontSize: 26,
                        color: kYellow,
                        fontFamily: 'DPClear',
                        fontWeight: FontWeight.w600),
                    /*defining default style is optional */
                    children: <TextSpan>[
                      TextSpan(
                          text: ' Your Free Subliminal Today',
                          style: TextStyle(
                              fontSize: 26,
                              color: Colors.white,
                              fontFamily: 'DPClear',
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 10, right: 10, top: 15),
                child: Column(
                  children: [
                    Text(
                      'Enter your email below to receive the subliminal ',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontFamily: 'DPClear',
                          fontWeight: FontWeight.w500),
                    ),
                    Text(
                      'download link ',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontFamily: 'DPClear',
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 15, right: 15, top: 10),
                decoration: kEditTextEmailDecoration,
                child: CommonTextFieldWithoutBG(
                    controller: _emailText,
                    hintText: kEnterEmail,
                    text: "",
                    isFocused: true,
                    onEnterKey: () => _handleOnReceiveEmailButton()),
              ),
              Container(
                decoration: kButtonBox10Decoration,
                margin: const EdgeInsets.only(top: 20, right: 15, left: 15),
                child: ButtonWidget(
                  name: 'receive download link'.toUpperCase(),
                  icon: '',
                  visibility: false,
                  padding: 20,
                  onTap: () => _handleOnReceiveEmailButton(),
                  size: 12,
                  scale: 2,
                  height: 50,
                ),
              ),
              Container(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: 'By signing up, you agree to the',
                    style: const TextStyle(
                        fontSize: 12,
                        height: 1.5,
                        color: Colors.white54,
                        fontFamily: 'DPClear',
                        fontWeight: FontWeight.w400),
                    children: <TextSpan>[
                      TextSpan(
                        text: ' Terms & Conditions',
                        style: const TextStyle(
                            fontSize: 12,
                            height: 1.5,
                            color: Colors.white,
                            fontFamily: 'DPClear',
                            fontWeight: FontWeight.w400),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            if (kIsWeb) {
                              controllers!.pause();
                              context.push(Routes.term);

                              //navigateToWebScreen(context, 'term');
                              //  launchTermURL();
                            } else {
                              controllers!.pause();
                              context.push(Routes.term);
                              //_navigateToWebScreen(context, 'term');
                            }
                          },
                      ),
                      const TextSpan(
                          text:
                              ' and that Success Subliminals may send you marketing emails and understand that we may use your information in accordance with our',
                          style: TextStyle(
                              fontSize: 12,
                              height: 1.5,
                              color: Colors.white54,
                              fontFamily: 'DPClear',
                              fontWeight: FontWeight.w400)),
                      TextSpan(
                        text: '  Privacy Policy.',
                        style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            height: 1.5,
                            fontFamily: 'DPClear',
                            fontWeight: FontWeight.w400),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            if (kIsWeb) {
                              // launchURL();
                              context.push(Routes.privacy);
                              controllers!.pause();
                              // _navigateToWebScreen(context, 'policy');
                            } else {
                              controllers!.pause();
                              context.push(Routes.privacy);
                              // _navigateToWebScreen(context, 'policy');
                            }
                          },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )),
    );
  }

  Widget buildTermsContainer(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 30, bottom: 30, left: 15, right: 15),
      decoration: kTopCornerBlackBackgroundBoxDecoration,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () => {
                setState(() {
                  if (kIsWeb) {
                    context.push(Routes.term);
                    controllers!.pause();
                    // _navigateToWebScreen(context, 'term');
                    //launchTermURL();
                  } else {
                    controllers!.pause();
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
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 10),
            child: GestureDetector(
              onTap: () => {
                setState(() {
                  if (kIsWeb) {
                    //launchURL();
                    context.push(Routes.privacy);
                    controllers!.pause();
                    // _navigateToWebScreen(context, 'policy');
                  } else {
                    controllers!.pause();
                    context.push(Routes.privacy);
                    // _navigateToWebScreen(context, 'policy');
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
    );
  }

  Widget buildTopBarContainer(BuildContext context, Size mq) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          margin: const EdgeInsets.only(left: 10, right: 10, top: 10),
          padding: const EdgeInsets.only(left: 10),
          height: 80,
          decoration: kInnerDecoration,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Align(
                alignment: Alignment.centerLeft,
                child: Image.asset('assets/images/app_logo_mobile.png',
                    scale: 2.5),
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () =>
                          {controllers!.pause(), context.push(Routes.signIn)},
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.only(
                            left: 20, right: 20, top: 12, bottom: 12),
                        decoration: kBlackButtonBox10Decoration,
                        child: Text(
                          kSignIn.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontFamily: 'DPClear',
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () =>
                          {controllers!.pause(), context.push(Routes.signUp)},
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.all(10),
                        decoration: kButtonBox10Decoration,
                        child: Text(
                          kStartTrial.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontFamily: 'DPClear',
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                    )
                  ]),
            ],
          ),
        ),
      ],
    );
  }

  buildVideoDialogContainer(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return WillPopScope(
              onWillPop: () async {
                // Handle the back button press here
                // Dismiss the dialog and return false to allow the back navigation
                videoPlayerController!.pause();
                Navigator.of(context).pop();
                return false;
              },
              child: Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0)),
                backgroundColor: kTrans,
                insetPadding: const EdgeInsets.only(
                    left: 15, right: 15, top: 100, bottom: 100),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () => {
                          setState(() {
                            controllers!.pause();
                            Navigator.of(context, rootNavigator: true).pop();
                          }),
                        },
                        child: Align(
                          alignment: Alignment.topRight,
                          child: Image.asset('assets/images/ic_close_bg.png',
                              scale: 5),
                        ),
                      ),
                      Expanded(
                          child: Container(
                              alignment: Alignment.center,
                              child: buildVideoContainer(context))),
                    ],
                  ),
                ),
              ));
        });
  }

  Widget buildVideoContainer(BuildContext context) {
    return Stack(
      children: [
        controllers!.value.isInitialized
            ? AspectRatio(
                aspectRatio: controllers!.value.aspectRatio,
                child: controllers!.value.isInitialized
                    ? Chewie(
                        controller: chewieController,
                      )
                    : null,
                /*: VideoPlayer(controllers),*/
              )
            : Container(),
      ],
    );
  }

  void _navigateToSubDetailScreen(
      BuildContext context, String name, String id) {
    controllers!.pause();
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (c, a1, a2) => SubliminalDetailPage(subId: id),
        transitionsBuilder: (c, anim, a2, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }
}
