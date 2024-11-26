import 'package:email_validator/email_validator.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:success_subliminal/pages/forgot_password_page.dart';
import 'package:success_subliminal/pages/web_pages/verify_otp_web_page.dart';

import '../../app/router.dart';
import '../../data/api/ApiService.dart';
import '../../dialogs/custom_alert_dialog.dart';
import '../../utils/center_loader.dart';
import '../../utils/constant.dart';
import '../../utils/shared_prefs.dart';
import '../../utils/toast.dart';
import '../../widget/CommonTextField.dart';
import '../../widget/SignUpTextWidget.dart';
import '../create_subliminal_page.dart';

class ForgotPasswordWebPage extends StatefulWidget {
  const ForgotPasswordWebPage({Key? key}) : super(key: key);

  @override
  ForgotPasswordWebScreen createState() => ForgotPasswordWebScreen();
}

class ForgotPasswordWebScreen extends State<ForgotPasswordWebPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final _emailText = TextEditingController();

  final FocusNode _emailFocus = FocusNode();

  late dynamic _forgotPasswordModel;
  bool isLogin = false;
  double screenWidth = 0.3;

  @override
  void initState() {
    super.initState();

    initializePreference().whenComplete(() {
      isLogin = SharedPrefs().isLogin();
      setState(() {});
    });
  }

  void _getForgotPasswordData(BuildContext context) async {
    _forgotPasswordModel =
        await ApiService().getUserForgotPassword(_emailText.text, context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        Navigator.of(context, rootNavigator: true).pop();
        if (_forgotPasswordModel['http_code'] != 200) {
          toast(_forgotPasswordModel["message"], false);
        } else {
          if (_forgotPasswordModel['message'] == 'failed') {
            toast(
                "Your email address is not exists, Please enter register email address",
                false);
          } else {
            toast("OTP Sent on your email address: ${_emailText.text}", false);
            setState(() {
              _navigateToOTPVerifyScreen(context, _emailText.text.toString());
            });
          }
        }
      });
    });
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
            if (constraints.maxWidth > 757) {
              if (constraints.maxWidth < 900) {
                loginTopPadding = 60;
                screenWidth = 0.70;
              } else if (constraints.maxWidth < 1150) {
                loginTopPadding = 70;
                screenWidth = 0.70;
              } else if (constraints.maxWidth < 1350) {
                loginTopPadding = 80;
                screenWidth = 0.50;
              } else if (constraints.maxWidth < 1650) {
                loginTopPadding = 90;
                screenWidth = 0.45;
              } else if (constraints.maxWidth < 2000) {
                loginTopPadding = 100;
                screenWidth = 0.30;
              }
              return buildHomeContainer(context, mq);
            } else {
              return const ForgotPasswordPage();
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
    return const Text(kForgotMsg,
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
            margin: const EdgeInsets.only(top: 50, left: 10),
            child: const Text(kEnterEmail,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
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
          ConstrainedBox(
              constraints: const BoxConstraints(minWidth: double.infinity),
              child: Container(
                decoration: kButtonBox10Decoration,
                margin: const EdgeInsets.only(
                  top: 50,
                ),
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    if (_emailText.text.toString() == "") {
                      const CustomAlertDialog()
                          .errorDialog(kEmailNullError, context);
                    } else if (!EmailValidator.validate(
                        _emailText.text.toString())) {
                      const CustomAlertDialog()
                          .errorDialog(kInvalidEmailError, context);
                    } else {
                      setState(() {
                        // context.pushReplacement(Routes.verifyOTP);
                        //_navigateToOTPVerifyScreen(context, _emailText.text.toString());
                        showCenterLoader(context);
                        _getForgotPasswordData(context);
                      });
                      // }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20), // <-- Radius
                    ),
                  ),
                  child: const Text('Next',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      )),
                ),
              )),
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

  void _navigateToOTPVerifyScreen(BuildContext context, String email) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (c, a1, a2) => VerifyOTPWebPage(
          email: email,
        ),
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
