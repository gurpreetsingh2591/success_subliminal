import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/otp_field_style.dart';
import 'package:otp_text_field/style.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:success_subliminal/pages/otp_verification_page.dart';
import 'package:success_subliminal/pages/web_pages/reset_password_web_page.dart';

import '../../app/router.dart';
import '../../data/api/ApiService.dart';
import '../../dialogs/custom_alert_dialog.dart';
import '../../utils/center_loader.dart';
import '../../utils/constant.dart';
import '../../utils/shared_prefs.dart';
import '../../utils/toast.dart';
import '../../widget/OtpTimer.dart';
import '../create_subliminal_page.dart';

class VerifyOTPWebPage extends StatefulWidget {
  final String email;

  const VerifyOTPWebPage({Key? key, required this.email}) : super(key: key);

  @override
  VerifyOTPWebPageState createState() => VerifyOTPWebPageState();
}

class VerifyOTPWebPageState extends State<VerifyOTPWebPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<OtpTimerState> _otpTimerStateKey = GlobalKey<OtpTimerState>();
  late dynamic _verifyModel;
  late dynamic _forgotPasswordModel;
  bool isLogin = false;
  bool isTimeUp = false;
  bool isTimeStart = true;

  String loginText = "If you haven't received OTP yet? ";
  String loginText1 = "Resend";
  double screenWidth = 0.3;
  String otp = "";

  @override
  void initState() {
    super.initState();

    initializePreference().whenComplete(() {
      isLogin = SharedPrefs().isLogin();
      setState(() {});
    });
  }

  void _resendOtp() {
    setState(() {
      // Code to resend OTP
    });
    _otpTimerStateKey.currentState?.restartTimer();
  }

  void _getVerifyOTPData(BuildContext context) async {
    _verifyModel =
        await ApiService().getUserVerifyOTP(otp, widget.email, context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        Navigator.of(context, rootNavigator: true).pop();
        if (_verifyModel['http_code'] != 200) {
          toast(_verifyModel["message"], false);
        } else {
          if (_verifyModel['message'] == 'failed') {
            toast("Your OTP is not valid, Please enter valid OTP", false);
          } else {
            toast("OTP Verified Successfully", false);
            setState(() {
              _navigateToResetOTPScreen(context, widget.email);
            });
          }
        }
      });
    });
  }

  void _getResendOTPData(BuildContext context) async {
    _forgotPasswordModel =
        await ApiService().getUserForgotPassword(widget.email, context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      //valueNotifier.value = _pcm; //provider
      setState(() {
        setState(() {
          isTimeUp = false;
        });
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
            toast("OTP Sent on your email address: ${widget.email}", false);
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
          builder: (BuildContext contexts, BoxConstraints constraints) {
            if (constraints.maxWidth > 757) {
              if (constraints.maxWidth < 900) {
                titleTextSize = 50;
                loginTopPadding = 100;
                screenWidth = 0.70;
              } else if (constraints.maxWidth < 1100) {
                titleTextSize = 55;
                loginTopPadding = 105;
                screenWidth = 0.60;
              } else if (constraints.maxWidth < 1300) {
                titleTextSize = 60;
                loginTopPadding = 110;
                screenWidth = 0.50;
              } else if (constraints.maxWidth < 1600) {
                titleTextSize = 65;
                loginTopPadding = 115;
                screenWidth = 0.40;
              } else if (constraints.maxWidth < 2000) {
                titleTextSize = 70;
                loginTopPadding = 120;
                screenWidth = 0.30;
              }
              return buildHomeContainer(context, mq);
            } else {
              return OtpVerificationScreen(email: widget.email);
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
                      margin: const EdgeInsets.only(top: 120),
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
                                child: buildOTPContainer(context, mq)),
                          ])),
                ])
          ],
        ));
  }

  Widget buildLoginTxtContainer(BuildContext context) {
    return const Text(kOTPMsg,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 22,
          color: Colors.white,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w500,
        ));
  }

  Widget buildOTPContainer(BuildContext context, Size mq) {
    return Align(
      alignment: Alignment.topLeft,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            height: 60,
            margin: const EdgeInsets.only(
              top: 50,
            ),
            child: OTPTextField(
              length: 6,
              width: MediaQuery.of(context).size.width,
              fieldWidth: 50,
              style: const TextStyle(fontSize: 17, color: Colors.white),
              textFieldAlignment: MainAxisAlignment.spaceAround,
              otpFieldStyle: OtpFieldStyle(
                  focusBorderColor: accent,
                  disabledBorderColor: accentLight,
                  enabledBorderColor: accent,
                  errorBorderColor: Colors.red //(here)
                  ),
              fieldStyle: FieldStyle.box,
              onCompleted: (pin) {
                if (pin.isNotEmpty) {
                  otp = pin;
                }

                if (kDebugMode) {
                  print("Completed: $pin");
                }
              },
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
                    if (otp == "") {
                      const CustomAlertDialog().errorDialog(kOTPError, context);
                    } else {
                      setState(() {
                        showCenterLoader(context);
                        _getVerifyOTPData(context);
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
                  child: const Text(kVerifyOTP,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      )),
                ),
              )),
          Container(
              margin: const EdgeInsets.only(top: 30),
              child: buildResendTxtContainer1(context))
        ],
      ),
    );
  }

  Widget buildResendTxtContainer1(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(loginText,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
          )),
      MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => {
              setState(() {
                isTimeUp = false;
                isTimeStart = true;
                showCenterLoader(context);
                _getResendOTPData(context);
                _resendOtp();
              })
            },
            child: Visibility(
              visible: isTimeUp,
              child: Text(loginText1,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: accent,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  )),
            ),
          )),
      Visibility(
          visible: isTimeStart,
          child: Align(
              alignment: Alignment.center,
              child: OtpTimer(
                key: _otpTimerStateKey,
                timeInSec: 45,
                onTimerEnd: () {
                  setState(() {
                    isTimeUp = true;
                    isTimeStart = false;
                  }); // handle the timer end event here
                },
              ))),
    ]);
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

  void _navigateToResetOTPScreen(BuildContext context, String email) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (c, a1, a2) => ResetPasswordWebPage(
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
