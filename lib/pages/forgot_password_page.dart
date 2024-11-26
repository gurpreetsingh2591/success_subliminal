import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:success_subliminal/pages/web_pages/forgot_password_web_page.dart';

import '../data/api/ApiService.dart';
import '../dialogs/custom_alert_dialog.dart';
import '../utils/center_loader.dart';
import '../utils/constant.dart';
import '../utils/shared_prefs.dart';
import '../utils/toast.dart';
import '../widget/BottomBarStateFullWidget.dart';
import '../widget/CommonTextField.dart';
import '../widget/SignUpTextWidget.dart';
import 'create_subliminal_page.dart';
import 'otp_verification_page.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  ForgotPasswordScreen createState() => ForgotPasswordScreen();
}

class ForgotPasswordScreen extends State<ForgotPasswordPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final _emailText = TextEditingController();
  final _passwordText = TextEditingController();

  final FocusNode _emailFocus = FocusNode();

  late dynamic register;
  late dynamic _forgotPasswordModel;
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

  void _getForgotPasswordData(BuildContext context) async {
    _forgotPasswordModel = await ApiService()
        .getUserForgotPassword(_emailText.text.trim(), context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      //valueNotifier.value = _pcm; //provider
      setState(() {
        Navigator.of(context, rootNavigator: true).pop();
        if (_forgotPasswordModel['http_code'] != 200) {
          Navigator.of(context, rootNavigator: true).pop();
          toast(_forgotPasswordModel["message"], false);
        } else {
          if (_forgotPasswordModel['message'] == 'failed') {
            toast(
                "Your email address is not exists, Please enter register email address",
                false);
          } else {
            toast("OTP Sent on your email address: ${_emailText.text}", false);
            // context.pushReplacement(Routes.verifyOTP);
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
            if (constraints.maxWidth < 757) {
              return buildHomeContainer(context, mq);
            } else {
              return const ForgotPasswordWebPage();
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
              margin: const EdgeInsets.only(
                  bottom: 80, top: 80, left: 20, right: 20),
              child: ListView(
                shrinkWrap: false,
                primary: true,
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
    return const Text(kForgotMsg,
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
                        _emailText.text.toString().trim())) {
                      const CustomAlertDialog()
                          .errorDialog(kInvalidEmailError, context);
                    } else {
                      setState(() {
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
              'Forgot Password',
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

  void _navigateToOTPVerifyScreen(BuildContext context, String email) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (c, a1, a2) => OtpVerificationScreen(
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
