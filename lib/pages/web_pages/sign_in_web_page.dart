import 'package:email_validator/email_validator.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:success_subliminal/pages/signin_page.dart';
import 'package:success_subliminal/pages/web_pages/forgot_password_web_page.dart';

import '../../app/router.dart';
import '../../data/api/ApiService.dart';
import '../../dialogs/custom_alert_dialog.dart';
import '../../utils/center_loader.dart';
import '../../utils/constant.dart';
import '../../utils/shared_prefs.dart';
import '../../utils/toast.dart';
import '../../widget/ButtonWidget400.dart';
import '../../widget/CommonPasswordTextField.dart';
import '../../widget/CommonTextField.dart';
import '../../widget/SignUpTextWidget.dart';
import '../create_subliminal_page.dart';

class SignInWebPage extends StatefulWidget {
  const SignInWebPage({Key? key}) : super(key: key);

  @override
  SignInWebScreen createState() => SignInWebScreen();
}

class SignInWebScreen extends State<SignInWebPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final _emailText = TextEditingController();
  final _passwordText = TextEditingController();

  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  late dynamic register;
  late dynamic _signUpModel;
  bool isLoading = false;
  bool isLogin = false;
  double screenWidth = 0.3;
  double leftPadding = 200;
  double rightPadding = 200;

  @override
  void initState() {
    super.initState();

    initializePreference().whenComplete(() {
      isLogin = SharedPrefs().isLogin();
      setState(() {});
    });
  }

  void handleSignInButton() {
    if (_emailText.text.toString() == "") {
      const CustomAlertDialog().errorDialog(kEmailNullError, context);
    } else if (!EmailValidator.validate(_emailText.text.toString().trim())) {
      const CustomAlertDialog().errorDialog(kInvalidEmailError, context);
    } else if (_passwordText.text.toString() == "") {
      const CustomAlertDialog().errorDialog(kPassNullError, context);
    } else if (_passwordText.text.length < 6) {
      const CustomAlertDialog().errorDialog(kShortPassError, context);
    } else {
      setState(() {
        showCenterLoader(context);
        _getSignInData();
      });
      // }
    }
  }

  void _getSignInData() async {
    _signUpModel = await ApiService()
        .getUserLogin(_emailText.text, _passwordText.text, context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        isLoading = true;
        //  register = _signUpModel;
        if (kDebugMode) {
          print(_signUpModel);
        }
        if (_signUpModel['http_code'] != 200) {
          Navigator.of(context, rootNavigator: true).pop();
          toast("Email/password incorrect", false);
        } else {
          _getIsUserRegister();

          if (_signUpModel['data']['user_subscription_status'] != null) {
            _getIsUserSubscription();
          } else {
            if (_signUpModel['data']!['user']!['subscription_status'] ==
                "trialing") {
              SharedPrefs().setIsFreeTrail(true);
              if (_signUpModel['data']['user']['free_trial_status'] ==
                  "false") {
                SharedPrefs().setIsFreeTrailUsed(false);
              } else {
                SharedPrefs().setIsFreeTrailUsed(true);
              }
              SharedPrefs().setIsSubscription(false);
              SharedPrefs().setIsSubscriptionStatus('trailing');
            } else if (_signUpModel['data']!['user']!['subscription_status'] ==
                "active") {
              SharedPrefs().setIsSubscription(true);
              SharedPrefs().setIsFreeTrail(false);
              SharedPrefs().setIsFreeTrailUsed(true);
              SharedPrefs().setIsSubscriptionStatus('active');
            } else if (_signUpModel['data']!['user']!['subscription_status'] ==
                "canceled") {
              SharedPrefs().setIsFreeTrail(false);
              SharedPrefs().setIsSubscription(false);
              SharedPrefs().setIsFreeTrailUsed(true);
              SharedPrefs().setIsSubscriptionStatus('canceled');
            }
          }
        }
      });
    });
  }

  Future<void> initializePreference() async {
    SharedPrefs.init(await SharedPreferences.getInstance());
  }

  void _getIsUserRegister() async {
    setState(() {
      SharedPrefs().setIsSignUp(false);
      SharedPrefs().setIsLogin(true);
      SharedPrefs().setUserFullName(_signUpModel['data']!['user']!['name']!);
      SharedPrefs().setUserEmail(_signUpModel['data']!['user']!['email']!);
      SharedPrefs().setTokenKey(_signUpModel['data']!['user']!['token']!);
      SharedPrefs().setUserId(_signUpModel['data']!['user']!['id']!.toString());
      SharedPrefs().setStripeCustomerId(
          _signUpModel['data']!['user']!['stripe_customer_id']!.toString());
      SharedPrefs()
          .setTrialStartDate(_signUpModel['data']!['user']!['created_at']!);
      if (kDebugMode) {
        print(SharedPrefs().getTokenKey());
        print(SharedPrefs().getUserFullName());
        print(SharedPrefs().getUserEmail());
      }

      Navigator.of(context, rootNavigator: true).pop();
      context.pushReplacement(Routes.create);
    });
  }

  void _getIsUserSubscription() async {
    setState(() {
      if (_signUpModel['data']!['user_subscription_status']![
              'subscription_status'] ==
          "trialing") {
        SharedPrefs().setIsFreeTrail(true);
        if (_signUpModel['data']['user']['free_trial_status'] == "false") {
          SharedPrefs().setIsFreeTrailUsed(false);
        } else {
          SharedPrefs().setIsFreeTrailUsed(true);
        }
        SharedPrefs().setIsSubscription(false);
      } else if (_signUpModel['data']!['user_subscription_status']![
              'subscription_status'] ==
          "active") {
        SharedPrefs().setIsSubscription(true);
        SharedPrefs().setIsFreeTrail(false);
        SharedPrefs().setIsFreeTrailUsed(true);
      } else if (_signUpModel['data']!['user_subscription_status']![
              'subscription_status'] ==
          "canceled") {
        SharedPrefs().setIsFreeTrail(false);
        SharedPrefs().setIsSubscription(false);
        SharedPrefs().setIsFreeTrailUsed(true);
      }
      SharedPrefs().setIsSubscriptionStatus(
          _signUpModel['data']!['user_subscription_status']!['status']);
      SharedPrefs().setUserSubscriptionId(_signUpModel['data']![
          'user_subscription_status']!['subscription_id']!);
      SharedPrefs().setSubscriptionStartDate(
          _signUpModel['data']!['user_subscription_status']!['start_date']!);
      SharedPrefs().setSubscriptionStartDate(
          _signUpModel['data']!['user_subscription_status']!['end_date']!);
      SharedPrefs().setUserPlanId(
          _signUpModel['data']!['user_subscription_status']!['product_id']!);
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
                loginTopPadding = 50;
                screenWidth = 0.70;
                leftPadding = 50;
                rightPadding = 50;
              } else if (constraints.maxWidth < 1150) {
                loginTopPadding = 60;
                screenWidth = 0.70;
                leftPadding = 70;
                rightPadding = 70;
              } else if (constraints.maxWidth < 1350) {
                loginTopPadding = 80;
                screenWidth = 0.50;
                leftPadding = 100;
                rightPadding = 100;
              } else if (constraints.maxWidth < 1650) {
                loginTopPadding = 90;
                screenWidth = 0.40;
                leftPadding = 150;
                rightPadding = 150;
              } else if (constraints.maxWidth < 2000) {
                loginTopPadding = 100;
                screenWidth = 0.30;
                leftPadding = 200;
                rightPadding = 200;
              }
              return buildHomeContainer(context, mq);
            } else {
              return const SignInPage();
            }
          },
        ));
  }

  Widget buildHomeContainer(BuildContext context, Size mq) {
    return Container(
        constraints: BoxConstraints(
          maxHeight: mq.height,
        ),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [backgroundDark, backgroundDark],
            stops: [0.5, 1.5],
          ),
        ),
        child: ListView(
          shrinkWrap: false,
          primary: false,
          children: [
            buildTopLogoContainer(context, mq),
            Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                      margin: EdgeInsets.only(top: loginTopPadding, bottom: 50),
                      width: mq.width * screenWidth,
                      padding: const EdgeInsets.all(60),
                      decoration: kAllCornerBackgroundBoxDecoration,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(
                                width: mq.width * screenWidth,
                                child: buildLoginTxtContainer(context)),
                            Container(
                                margin: const EdgeInsets.only(top: 20),
                                width: mq.width * screenWidth,
                                child: buildLoginContainer(context, mq)),
                          ])),
                ])
          ],
        ));
  }

  Widget buildLoginTxtContainer(BuildContext context) {
    return const Text(kSignInWith,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 22,
          color: Colors.white,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w500,
        ));
  }

  Widget buildLoginContainer(BuildContext context, Size mq) {
    return Align(
      alignment: Alignment.topLeft,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(top: 30, left: 10),
            child: const Text(kEnterEmail,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                )),
          ),
          Container(
            height: 60,
            margin: const EdgeInsets.only(
              top: 5,
            ),
            decoration: kEditTextDecoration,
            child: CommonTextField(
              controller: _emailText,
              hintText: "Enter your registered email",
              text: "",
              isFocused: true,
              isDeco: true,
              textColor: Colors.white,
              focus: _emailFocus,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 15, left: 10),
            child: const Text(kEnterPassword,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                )),
          ),
          Container(
            height: 60,
            margin: const EdgeInsets.only(top: 5),
            decoration: kEditTextDecoration,
            child: CommonPasswordTextField(
              controller: _passwordText,
              hintText: "Enter your password",
              text: "",
              isFocused: true,
              isDeco: true,
              focus: _passwordFocus,
            ),
          ),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => {
                setState(() {
                  _navigateToForgotPasswordScreen(context);
                  //context.push(Routes.forgotPassword);
                })
              },
              child: Container(
                margin: const EdgeInsets.only(top: 10),
                child: const Align(
                  alignment: Alignment.topRight,
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontFamily: 'DPClear',
                        fontWeight: FontWeight.w500),
                    /*defining default style is optional */
                  ),
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(
              top: 50,
            ),
            child: ButtonWidget400(
              name: kSignIn,
              icon: "",
              visibility: false,
              padding: 10,
              onTap: () => {handleSignInButton()},
              size: 16,
              buttonSize: 50,
              deco: kButtonBox10Decoration,
            ),
          ),
          const Align(alignment: Alignment.center, child: SignUpTextWidget())
        ],
      ),
    );
  }

  Widget buildTopLogoContainer(BuildContext context, Size mq) {
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

  void _navigateToForgotPasswordScreen(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (c, a1, a2) => const ForgotPasswordWebPage(),
        transitionsBuilder: (c, anim, a2, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _navigateToNextScreen(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const CreateSubliminalPage()),
        (Route<dynamic> route) => false);
  }
}
