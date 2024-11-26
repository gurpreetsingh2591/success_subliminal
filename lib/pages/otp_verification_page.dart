import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/otp_field_style.dart';
import 'package:otp_text_field/style.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:success_subliminal/pages/reset_password_page.dart';
import 'package:success_subliminal/pages/web_pages/verify_otp_web_page.dart';

/*import 'dart:html' as html;*/

import '../data/api/ApiService.dart';
import '../dialogs/custom_alert_dialog.dart';
import '../utils/center_loader.dart';
import '../utils/constant.dart';
import '../utils/shared_prefs.dart';
import '../utils/toast.dart';
import '../widget/BottomBarStateFullWidget.dart';
import '../widget/OtpTimer.dart';
import 'create_subliminal_page.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;

  const OtpVerificationScreen({Key? key, required this.email})
      : super(key: key);

  @override
  OtpVerificationScreenState createState() => OtpVerificationScreenState();
}

class OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<OtpTimerState> _otpTimerStateKey = GlobalKey<OtpTimerState>();
  String loginText = "If you haven't received OTP yet? ";
  String loginText1 = "Resend";

  bool isLoading = false;
  bool isLogin = false;

  String otp = "";
  late dynamic _verifyModel;
  late dynamic _forgotPasswordModel;
  bool isTimeUp = false;
  bool isTimeStart = true;

  @override
  void initState() {
    super.initState();
    changeScreenName("discover");
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

  changeScreenName(String name) {
    setState(() {
      screenName = name;
    });
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
          builder: (BuildContext context, BoxConstraints constraints) {
            if (constraints.maxWidth < 757) {
              return buildHomeContainer(context, mq);
            } else {
              return VerifyOTPWebPage(email: widget.email);
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
                  buildOTPContainer(context, mq),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildLoginTxtContainer(BuildContext context) {
    return const Text(kOTPMsg,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 18,
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
              margin: const EdgeInsets.only(top: 40),
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
              'OTP Verification',
              style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontFamily: 'DPClear',
                  fontWeight: FontWeight.w500),
            ),
          ),
        )
      ],
    );
  }

  void _navigateToResetOTPScreen(BuildContext context, String email) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (c, a1, a2) => ResetPasswordPage(
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
