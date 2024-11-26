import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:success_subliminal/pages/reset_password_page.dart';

import '../../app/router.dart';
import '../../data/api/ApiService.dart';
import '../../dialogs/custom_alert_dialog.dart';
import '../../utils/center_loader.dart';
import '../../utils/constant.dart';
import '../../utils/shared_prefs.dart';
import '../../utils/toast.dart';
import '../../widget/CommonTextField.dart';

class ResetPasswordWebPage extends StatefulWidget {
  final String email;

  const ResetPasswordWebPage({Key? key, required this.email}) : super(key: key);

  @override
  ResetPasswordWebPageState createState() => ResetPasswordWebPageState();
}

class ResetPasswordWebPageState extends State<ResetPasswordWebPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final _passwordText = TextEditingController();
  final _confirmPasswordText = TextEditingController();

  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();

  late dynamic _resetPasswordModel;
  bool isLogin = false;

  String loginText = "If you haven't account?";
  String loginText1 = " Sign Up";
  double screenWidth = 0.3;

  @override
  void initState() {
    super.initState();

    initializePreference().whenComplete(() {
      isLogin = SharedPrefs().isLogin();
      setState(() {});
    });
  }

  void _getResetPasswordData(BuildContext context) async {
    _resetPasswordModel = await ApiService()
        .getUserResetPassword(_passwordText.text, widget.email, context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        Navigator.of(context, rootNavigator: true).pop();
        if (_resetPasswordModel['http_code'] != 200) {
          toast(_resetPasswordModel["message"], false);
        } else {
          if (_resetPasswordModel['message'] == 'failed') {
            toast("Password not reset, Please try again", false);
          } else {
            toast(
                "Password reset successfully, Please login with this password}",
                false);
            setState(() {
              context.pushReplacement(Routes.signIn);
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
              return ResetPasswordPage(email: widget.email);
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
                                child: buildResetPasswordTxtContainer(context)),
                            Container(
                                margin: const EdgeInsets.only(top: 20),
                                width: mq.width * screenWidth,
                                child:
                                    buildResetPasswordContainer(context, mq)),
                          ])),
                ])
          ],
        ));
  }

  Widget buildResetPasswordTxtContainer(BuildContext context) {
    return const Text(kNewPasswordMsg,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 22,
          color: Colors.white,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w500,
        ));
  }

  Widget buildResetPasswordContainer(BuildContext context, Size mq) {
    return Align(
      alignment: Alignment.topLeft,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(top: 50, left: 10),
            child: const Text(kNewPassword,
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
              controller: _passwordText,
              hintText: "Enter new password",
              text: "",
              isFocused: true,
              isDeco: true,
              textColor: Colors.white,
              focus: _passwordFocus,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 15, left: 10),
            child: const Text(kConfirmNewPassword,
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
              controller: _confirmPasswordText,
              hintText: "Enter confirm new password",
              text: "",
              isFocused: true,
              isDeco: true,
              textColor: Colors.white,
              focus: _confirmPasswordFocus,
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
                    if (_passwordText.text.toString() == "") {
                      const CustomAlertDialog()
                          .errorDialog(kEnterNewPassword, context);
                    } else if (_confirmPasswordText.text.toString() == "") {
                      const CustomAlertDialog()
                          .errorDialog(kEnterConfirmNewPassword, context);
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
                        _getResetPasswordData(context);
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
                  child: const Text("Reset Password",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      )),
                ),
              )),
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
                  context.push(Routes.home);
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
}
