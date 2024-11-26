import 'package:email_validator/email_validator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:success_subliminal/pages/web_pages/sign_up_web_page.dart';

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
import '../widget/OfferWidget.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  SignUpPageState createState() => SignUpPageState();
}

class SignUpPageState extends State<SignUpPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _nameText = TextEditingController();
  final _emailText = TextEditingController();
  final _passwordText = TextEditingController();
  final _confirmPasswordText = TextEditingController();
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();

  String loginText = "Already have an account?";
  String loginText1 = " Sign In";
  late dynamic register;
  late dynamic _signUpModel;
  late dynamic conversionStartTrial;
  bool isLoading = false;
  bool isLogin = false;
  List<dynamic> categoriesList = [];
  late dynamic categories;
  String trialSub = "";
  String? subliminalId = "";

  @override
  void initState() {
    super.initState();
    changeScreenName("discover");
    initializePreference().whenComplete(() {
      isLogin = SharedPrefs().isLogin();
      setState(() {});
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

  changeScreenName(String name) {
    setState(() {
      screenName = name;
    });
  }

  void handleSignUpButton() {
    if (_nameText.text.toString().trim() == "") {
      const CustomAlertDialog().errorDialog(kNameNullError, context);
    } else if (_emailText.text.toString() == "") {
      const CustomAlertDialog().errorDialog(kEmailNullError, context);
    } else if (!EmailValidator.validate(_emailText.text.toString().trim())) {
      const CustomAlertDialog().errorDialog(kInvalidEmailError, context);
    } else if (_passwordText.text.toString() == "") {
      const CustomAlertDialog().errorDialog(kPassNullError, context);
    } else if (_passwordText.text.length < 6) {
      const CustomAlertDialog().errorDialog(kShortPassError, context);
    } else if (_passwordText.text.toString() !=
        _confirmPasswordText.text.toString()) {
      const CustomAlertDialog()
          .errorDialog(kConfirmPasswordMatchError, context);
    } else {
      setState(() {
        showCenterLoader(context);
        _getSignUpData(context);
      });
    }
  }

  void _getSignUpData(BuildContext context) async {
    if (SharedPrefs().getFreeSubId() != null) {
      trialSub = SharedPrefs().getFreeSubId().toString();
    }

    if (kDebugMode) {
      print("id--$trialSub");
    }

    _signUpModel = await ApiService().getUsersRegister(_nameText.text,
        _emailText.text.trim(), _passwordText.text, trialSub, context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      //valueNotifier.value = _pcm; //provider
      setState(() {
        isLoading = true;

        if (_signUpModel['http_code'] != 200) {
          Navigator.of(context, rootNavigator: true).pop();
          toast(_signUpModel["message"], false);
        } else {
          _signUpModel = _signUpModel;
          _getIsUserRegister(context);
          trackTrialInfo();
        }
      });
    });
  }

  Future<void> initializePreference() async {
    SharedPrefs.init(await SharedPreferences.getInstance());
  }

  void _getIsUserRegister(BuildContext context) async {
    setState(() {
      SharedPrefs().setIsSignUp(true);
      SharedPrefs().setIsLogin(true);
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
      context.goNamed('subscription', queryParameters: {
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
            if (constraints.maxWidth < 757) {
              return buildHomeContainer(context, mq);
            } else {
              return const SignUpWebPage();
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
          children: [
            buildTopBarContainer(context, mq),
            BottomBarStateFull(
              screen: "discover",
              isUserLogin: isLogin,
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 80, top: 50),
              child: ListView(
                shrinkWrap: false,
                primary: true,
                children: [
                  const OfferWidget(),
                  buildLoginTxtContainer(context),
                  buildSignUpContainer(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildLoginTxtContainer(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 30),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          text: loginText,
          style: const TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontFamily: 'DPClear',
              fontWeight: FontWeight.w500),
          /*defining default style is optional */
          children: [
            TextSpan(
              text: loginText1,
              style: const TextStyle(
                  fontSize: 18,
                  color: kLoginText,
                  fontFamily: 'DPClear',
                  fontWeight: FontWeight.w500),
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
          margin: const EdgeInsets.only(left: 15, right: 15, top: 20),
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
          margin: const EdgeInsets.only(left: 15, right: 15, top: 10),
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
          margin: const EdgeInsets.only(left: 15, right: 15, top: 10),
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
          margin: const EdgeInsets.only(left: 25, right: 15, top: 5),
          child: const Align(
            alignment: Alignment.topLeft,
            child: Text(
              'Passwords must be at least 6 characters',
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.white54,
                  fontFamily: 'DPClear',
                  fontWeight: FontWeight.w400),
              /*defining default style is optional */
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(left: 15, right: 15, top: 10),
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
        Container(
          margin:
              const EdgeInsets.only(top: 20, left: 15, right: 15, bottom: 10),
          child: ButtonWidget400(
            name: kSignUpFree.toUpperCase(),
            icon: "",
            visibility: false,
            padding: 10,
            onTap: () => {handleSignUpButton()},
            size: 16,
            buttonSize: 50,
            deco: kButtonBox10Decoration,
          ),
        ),
        Container(
          alignment: Alignment.topLeft,
          margin:
              const EdgeInsets.only(left: 15, top: 20, bottom: 20, right: 15),
          child: RichText(
            textAlign: TextAlign.start,
            text: TextSpan(
              text: "By creating an account, you agree to  ",
              style: const TextStyle(
                  color: Colors.white54,
                  fontFamily: 'DPClear',
                  height: 1.2,
                  fontWeight: FontWeight.w300),
              children: <TextSpan>[
                TextSpan(
                  text: "Conditions",
                  style: const TextStyle(
                      color: Colors.white,
                      height: 1.2,
                      fontFamily: 'DPClear',
                      fontWeight: FontWeight.w300),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      if (kIsWeb) {
                        context.push(Routes.term);
                        // launchTermURL();
                      } else {
                        context.push(Routes.term);
                        //_navigateToWebScreen(context, 'term');
                      }
                    },
                ),
                const TextSpan(
                    text: "  of  ",
                    style: TextStyle(
                        color: Colors.white54,
                        height: 1.2,
                        fontFamily: 'DPClear',
                        fontWeight: FontWeight.w300)),
                TextSpan(
                  text: "Use and Privacy Notice",
                  style: const TextStyle(
                      color: Colors.white,
                      height: 1.2,
                      fontFamily: 'DPClear',
                      fontWeight: FontWeight.w300),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      if (kIsWeb) {
                        context.push(Routes.privacy);
                        //launchURL();
                      } else {
                        context.push(Routes.privacy);
                        //_navigateToWebScreen(context, 'policy');
                      }
                    },
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget buildTopBarContainer(BuildContext context, Size mq) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
        )
      ],
    );
  }
}
