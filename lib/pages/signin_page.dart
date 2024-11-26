import 'package:email_validator/email_validator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:success_subliminal/pages/web_pages/sign_in_web_page.dart';

import '../app/router.dart';
import '../data/api/ApiService.dart';
import '../dialogs/custom_alert_dialog.dart';
import '../utils/center_loader.dart';
import '../utils/constant.dart';
import '../utils/shared_prefs.dart';
import '../utils/toast.dart';
import '../widget/BottomBarStateFullWidget.dart';
import '../widget/ButtonWidget400.dart';
import '../widget/CommonPasswordTextField.dart';
import '../widget/CommonTextField.dart';
import '../widget/SignUpTextWidget.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  SignInScreen createState() => SignInScreen();
}

class SignInScreen extends State<SignInPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final _emailText = TextEditingController();
  final _passwordText = TextEditingController();

  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  late dynamic register;
  late dynamic _signUpModel;
  bool isLoading = false;
  bool isLogin = false;
  List<dynamic> categoriesList = [];
  late dynamic categories;

  @override
  void initState() {
    super.initState();
    changeScreenName("discover");
    initializePreference().whenComplete(() {
      isLogin = SharedPrefs().isLogin();
      setState(() {});
    });
  }

  changeScreenName(String name) {
    setState(() {
      screenName = name;
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
        .getUserLogin(_emailText.text.trim(), _passwordText.text, context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      //valueNotifier.value = _pcm; //provider
      setState(() {
        isLoading = true;
        // register = _signUpModel;

        if (_signUpModel['http_code'] != 200) {
          toast("Email/password incorrect", false);
          Navigator.of(context, rootNavigator: true).pop();
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
        //Navigator.of(context, rootNavigator: true).pop();
      });
    });
  }

  Future<void> initializePreference() async {
    SharedPrefs.init(await SharedPreferences.getInstance());
  }

  void _getIsUserRegister() {
    setState(() {
      SharedPrefs().setIsSignUp(true);
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
      //_navigateToNextScreen(context);
      context.go(Routes.create);
    });
  }

  void _getIsUserSubscription() {
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
        SharedPrefs().setIsFreeTrailUsed(true);
        SharedPrefs().setIsFreeTrail(false);
      } else if (_signUpModel['data']!['user_subscription_status']![
              'subscription_status'] ==
          "canceled") {
        SharedPrefs().setIsFreeTrail(false);
        SharedPrefs().setIsSubscription(false);
        SharedPrefs().setIsFreeTrailUsed(true);
      }

      SharedPrefs().setIsSubscriptionStatus(
          _signUpModel['data']!['user_subscription_status']!['status']);
      SharedPrefs().setUserSubscriptionId(
          _signUpModel['data']!['user_subscription_status']!['subscription_id']
              .toString());
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
            if (constraints.maxWidth < 757) {
              return buildHomeContainer(context, mq);
            } else {
              return const SignInWebPage();
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
        /*  decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [backgroundDark, backgroundDark],
            stops: [0.5, 1.5],
          ),
        ),*/
        child: Stack(
          children: [
            Image.asset(
              'assets/images/ic_bg_dark_blue.png',
              fit: BoxFit.cover,
              height: double.infinity,
              width: double.infinity,
              alignment: Alignment.center,
            ),
            buildTopBarContainer(context, mq),
            BottomBarStateFull(
              screen: "discover",
              isUserLogin: isLogin,
            ),
            Container(
              margin: const EdgeInsets.only(
                  bottom: 80, top: 80, left: 20, right: 20),
              child: ListView(
                shrinkWrap: true,
                primary: false,
                children: [
                  buildLoginTxtContainer(context),
                  buildLoginContainer(context, mq),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildLoginTxtContainer(BuildContext context) {
    return const Text(kSignInWith,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 18,
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
            margin: const EdgeInsets.only(top: 20, left: 10),
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
            margin: const EdgeInsets.only(top: 10, left: 10),
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
                  context.push(Routes.forgotPassword);
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
              top: 30,
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

  Widget buildTopBarContainer(BuildContext context, Size mq) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => {Navigator.pop(context)},
          child: Container(
            padding: const EdgeInsets.only(left: 10),
            height: mq.height * 0.09,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Image.asset('assets/images/ic_arrow_left.png', scale: 1.5),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.only(left: 15, top: 20),
          child: const Align(
            alignment: Alignment.topLeft,
            child: Text(
              ' Sign In',
              style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontFamily: 'DPClear',
                  fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ],
    );
  }
}
