import 'package:email_validator/email_validator.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:success_subliminal/pages/sign_up_page.dart';
import 'package:success_subliminal/utils/toast.dart';

import '../../app/router.dart';
import '../../data/api/ApiService.dart';
import '../../dialogs/custom_alert_dialog.dart';
import '../../utils/center_loader.dart';
import '../../utils/constant.dart';
import '../../utils/shared_prefs.dart';
import '../../widget/CommonPasswordTextField.dart';
import '../../widget/CommonTextField.dart';
import '../../widget/OfferWidgetWeb.dart';
import '../web_view.dart';

class SignUpWebPage extends StatefulWidget {
  const SignUpWebPage({Key? key}) : super(key: key);

  @override
  SignUpWebPageState createState() => SignUpWebPageState();
}

class SignUpWebPageState extends State<SignUpWebPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final _nameText = TextEditingController();
  final _emailText = TextEditingController();
  final _passwordText = TextEditingController();
  final _confirmPasswordText = TextEditingController();

  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();

  String loginText = "";
  String loginText1 = "";
  late dynamic register;
  late dynamic _signUpModel;
  late dynamic conversionStartTrial;
  bool isLoading = false;
  bool isLogin = false;

  TextAlign textAlignment = TextAlign.center;
  double leftPadding = 200;
  double rightPadding = 200;
  double topPadding = 100;
  double titleSize = 20;
  double lineHeight = .7;
  double limitedTextSize = 40;
  double leftMargin = 40;
  double topMargin = 120;
  String trialSub = "";
  String? subliminalId = "";

  @override
  void initState() {
    super.initState();
    initializePreference().whenComplete(() {
      isLogin = SharedPrefs().isLogin();
      setState(() {
        loginText = "Already have an account?";
        loginText1 = " Sign In";
      });
    });

    if (kIsWeb) {
      subliminalId = getSubliminalId();
      if (kDebugMode) {
        print("subliminalId--${subliminalId!}");
      }
      if (subliminalId != "null") {
        trialSub = subliminalId!;
      } else {
        if (SharedPrefs().getFreeSubId() != null) {
          trialSub = SharedPrefs().getFreeSubId().toString();
        } else {
          trialSub = "";
        }
      }
    } else {
      if (SharedPrefs().getFreeSubId() != null) {
        trialSub = SharedPrefs().getFreeSubId().toString();
      } else {
        trialSub = "";
      }
    }
    if (kDebugMode) {
      print("trialSub--$trialSub");
    }
  }

  void _getSignUpData() async {
    _signUpModel = await ApiService().getUsersRegister(
        _nameText.text, _emailText.text, _passwordText.text, trialSub, context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        isLoading = true;
        register = _signUpModel;

        if (register['http_code'] != 200) {
          Navigator.of(context, rootNavigator: true).pop();
          toast(register['message'], true);
        } else {
          _getIsUserRegister();
        }
      });
    });
  }

  Future<void> initializePreference() async {
    SharedPrefs.init(await SharedPreferences.getInstance());
  }

  void _getIsUserRegister() async {
    setState(() {
      if (_signUpModel['data']!['user']!['subscription_status'] == "trialing") {
        SharedPrefs().setIsFreeTrail(true);
        if (_signUpModel['data']['user']['free_trial_status'] == "false") {
          SharedPrefs().setIsFreeTrailUsed(false);
        } else {
          SharedPrefs().setIsFreeTrailUsed(true);
        }
        SharedPrefs().setIsSubscription(false);
      }
      SharedPrefs().setIsSubscriptionStatus('trailing');
      SharedPrefs().setIsSignUp(true);
      SharedPrefs().setIsLogin(true);
      SharedPrefs().setUserFullName(_signUpModel['data']!['user']!['name']!);
      SharedPrefs()
          .setTrialStartDate(_signUpModel['data']!['user']!['created_at']!);
      SharedPrefs().setUserEmail(_signUpModel['data']!['user']!['email']!);
      SharedPrefs().setTokenKey(_signUpModel['data']!['user']!['token']!);
      SharedPrefs().setUserId(_signUpModel['data']!['user']!['id']!.toString());
      SharedPrefs().setSubscriptionStartDate(
          _signUpModel['data']!['user']!['id']!.toString());
      SharedPrefs().setStripeCustomerId(
          _signUpModel['data']!['user']!['stripe_customer_id']!.toString());
      if (kDebugMode) {
        print(SharedPrefs().getTokenKey());
        print(SharedPrefs().getUserFullName());
        print(SharedPrefs().getUserEmail());
      }
      trackTrialInfo();
      Navigator.of(context, rootNavigator: true).pop();
      //context.push(Routes.subscription);
      context.pushReplacementNamed('subscription', queryParameters: {
        "screen": 'trial',
      });
    });
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
                titleTextSize = 50;
                loginTopPadding = 100;
                lineHeight = .5;
                limitedTextSize = 35;
                leftMargin = 20;
                topMargin = 150;
                textAlignment = TextAlign.left;
              } else if (constraints.maxWidth < 1100) {
                titleTextSize = 55;
                loginTopPadding = 105;
                leftPadding = 70;
                rightPadding = 70;
                lineHeight = .5;
                limitedTextSize = 35;
                leftMargin = 20;
                topMargin = 150;
                textAlignment = TextAlign.left;
              } else if (constraints.maxWidth < 1300) {
                leftPadding = 100;
                rightPadding = 100;
                titleTextSize = 60;
                loginTopPadding = 110;
                lineHeight = .7;
                limitedTextSize = 35;
                leftMargin = 30;
                topMargin = 120;
                textAlignment = TextAlign.center;
              } else if (constraints.maxWidth < 1600) {
                titleTextSize = 65;
                loginTopPadding = 115;
                leftPadding = 150;
                rightPadding = 150;
                lineHeight = .7;
                limitedTextSize = 35;
                topMargin = 120;
                leftMargin = 30;
                textAlignment = TextAlign.center;
              } else if (constraints.maxWidth < 2000) {
                titleTextSize = 70;
                loginTopPadding = 120;
                leftPadding = 200;
                rightPadding = 200;
                lineHeight = .7;
                limitedTextSize = 40;
                leftMargin = 40;
                topMargin = 120;
                textAlignment = TextAlign.center;
              }
              return buildHomeContainer(context, mq);
            } else {
              return const SignUpPage();
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
          child: Stack(children: [
            buildDiscoverLogoContainer(context, mq),
            Container(
                alignment: Alignment.topCenter,
                margin: EdgeInsets.only(
                    left: 0, right: 0, top: topMargin, bottom: 0),
                child: ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context)
                      .copyWith(scrollbars: false),
                  child: ListView(
                    shrinkWrap: true,
                    primary: false,
                    children: <Widget>[
                      Container(
                          alignment: Alignment.topLeft,
                          decoration: kAllCornerBackgroundBoxDecoration,
                          padding: const EdgeInsets.all(10),
                          margin: EdgeInsets.only(
                            bottom: 100,
                            left: leftPadding,
                            right: rightPadding,
                            top: 0,
                          ),
                          child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                    flex: 9,
                                    child: OfferWidgetWeb(
                                        limitedTextSize: limitedTextSize)),
                                Expanded(
                                    flex: 1,
                                    child: SizedBox(
                                        height: mq.height * lineHeight,
                                        child: const VerticalDivider(
                                          width: 2,
                                          color: kWhiteTrans,
                                        ))),
                                const Padding(
                                  padding: EdgeInsets.all(4),
                                ),
                                Expanded(
                                    flex: 9,
                                    child: Container(
                                        alignment: Alignment.topLeft,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            buildLoginTxtContainer(context),
                                            buildSignUpContainer(context),
                                          ],
                                        )))
                              ])),
                    ],
                  ),
                ))
          ])),
    );
  }

  Widget buildLoginTxtContainer(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(right: 20, top: 40, bottom: 30),
      child: RichText(
        textAlign: textAlignment,
        text: TextSpan(
          text: loginText,
          style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontFamily: 'DPClear',
              fontWeight: FontWeight.w500),
          children: <TextSpan>[
            TextSpan(
              text: loginText1,
              style: const TextStyle(
                  fontSize: 16,
                  color: kLoginText,
                  fontFamily: 'DPClear',
                  fontWeight: FontWeight.w600),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  setState(() {
                    context.pushReplacement(Routes.signIn);
                  });
                },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSignUpContainer(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            height: 60,
            margin: EdgeInsets.only(right: leftMargin, top: 10),
            decoration: kEditTextDecoration,
            child: CommonTextField(
              controller: _nameText,
              hintText: kEnterName,
              text: "",
              isFocused: true,
              isDeco: true,
              textColor: Colors.white,
              focus: _nameFocus,
            ),
          ),
          Container(
            height: 60,
            margin: EdgeInsets.only(right: leftMargin, top: 10),
            decoration: kEditTextDecoration,
            child: CommonTextField(
              controller: _emailText,
              hintText: kEnterEmail,
              text: "",
              isFocused: true,
              isDeco: true,
              textColor: Colors.white,
              focus: _emailFocus,
            ),
          ),
          Container(
            height: 60,
            margin: EdgeInsets.only(right: leftMargin, top: 10),
            decoration: kEditTextDecoration,
            child: CommonPasswordTextField(
              controller: _passwordText,
              hintText: kEnterPassword,
              text: "",
              isFocused: true,
              isDeco: true,
              focus: _passwordFocus,
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 10, right: leftMargin, top: 5),
            child: const Align(
              alignment: Alignment.topLeft,
              child: Text(
                'Passwords must be at least 6 characters',
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontFamily: 'DPClear',
                    fontWeight: FontWeight.w400),
                /*defining default style is optional */
              ),
            ),
          ),
          Container(
            height: 60,
            margin: EdgeInsets.only(right: leftMargin, top: 10),
            decoration: kEditTextDecoration,
            child: CommonPasswordTextField(
              controller: _confirmPasswordText,
              hintText: kConfirmPassword,
              text: "",
              isFocused: true,
              isDeco: true,
              focus: _confirmPasswordFocus,
            ),
          ),
          ConstrainedBox(
              constraints: const BoxConstraints(minWidth: double.infinity),
              child: Container(
                decoration: kButtonBox10Decoration,
                margin: EdgeInsets.only(top: 20, left: 5, right: leftMargin),
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    if (_nameText.text.toString() == "") {
                      const CustomAlertDialog()
                          .errorDialog(kNameNullError, context);
                    } else if (_emailText.text.toString() == "") {
                      const CustomAlertDialog()
                          .errorDialog(kEmailNullError, context);
                    } else if (!EmailValidator.validate(
                        _emailText.text.toString().trim())) {
                      const CustomAlertDialog()
                          .errorDialog(kInvalidEmailError, context);
                    } else if (_passwordText.text.toString() == "") {
                      const CustomAlertDialog()
                          .errorDialog(kPassNullError, context);
                    } else if (_passwordText.text.length < 6) {
                      const CustomAlertDialog()
                          .errorDialog(kShortPassError, context);
                    } else if (_passwordText.text.toString() !=
                        _confirmPasswordText.text.toString()) {
                      const CustomAlertDialog()
                          .errorDialog(kConfirmPasswordMatchError, context);
                    } else {
                      setState(() {
                        showCenterLoader(context);
                        _getSignUpData();
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.only(left: 15, right: 15),
                    primary: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(kSignUpFree.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: 'DPClear',
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                      )),
                ),
              )),
          Container(
            alignment: Alignment.topLeft,
            margin: EdgeInsets.only(
                left: 10, top: 20, bottom: 20, right: leftMargin),
            child: RichText(
              textAlign: TextAlign.start,
              text: TextSpan(
                text: "By creating an account, you agree to  ",
                style: const TextStyle(
                    color: Colors.white54,
                    fontFamily: 'DPClear',
                    fontWeight: FontWeight.w300),
                children: <TextSpan>[
                  TextSpan(
                    text: "Conditions",
                    style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'DPClear',
                        fontWeight: FontWeight.w300),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        if (kIsWeb) {
                          context.push(Routes.term);
                          //launchTermURL();
                        } else {
                          _navigateToWebScreen(context, 'term');
                        }
                      },
                  ),
                  const TextSpan(
                      text: "  of  ",
                      style: TextStyle(
                          color: Colors.white54,
                          fontFamily: 'DPClear',
                          fontWeight: FontWeight.w300)),
                  TextSpan(
                    text: "Use and Privacy Notice",
                    style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'DPClear',
                        fontWeight: FontWeight.w300),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        if (kIsWeb) {
                          context.push(Routes.privacy);
                          //launchURL();
                        } else {
                          _navigateToWebScreen(context, 'policy');
                        }
                      },
                  ),
                ],
              ),
            ),
          ),
        ]);
  }

  Widget buildDiscoverLogoContainer(BuildContext context, Size mq) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => {
                setState(() {
                  if (kIsWeb) {
                    context.push(Routes.home);
                  } else {
                    Navigator.pop(context);
                  }
                })
              },
              child: Container(
                padding: const EdgeInsets.only(left: 20, top: 25),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Image.asset('assets/images/app_logo.png', scale: 2.5),
                ),
              ),
            )),
      ],
    );
  }

  void _navigateToWebScreen(BuildContext context, String isTermPolicy) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (c, a1, a2) => WebViewScreen(
          isTermPolicy: isTermPolicy,
        ),
        transitionsBuilder: (c, anim, a2, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }
}
