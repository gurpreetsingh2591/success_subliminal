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
import '../widget/CommonPasswordTextField.dart';
import 'create_subliminal_page.dart';
import 'discover_subliminal_list_page.dart';

class ResetPasswordPage extends StatefulWidget {
  final String email;

  const ResetPasswordPage({Key? key, required this.email}) : super(key: key);

  @override
  ResetPasswordPageState createState() => ResetPasswordPageState();
}

class ResetPasswordPageState extends State<ResetPasswordPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final _passwordText = TextEditingController();
  final _confirmPasswordText = TextEditingController();

  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();

  late dynamic _resetPasswordModel;
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

  void _getResetPasswordData(BuildContext context) async {
    _resetPasswordModel = await ApiService()
        .getUserResetPassword(_passwordText.text.trim(), widget.email, context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      //valueNotifier.value = _pcm; //provider
      setState(() {
        Navigator.of(context, rootNavigator: true).pop();
        if (_resetPasswordModel['http_code'] != 200) {
          Navigator.of(context, rootNavigator: true).pop();
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
    final mq = MediaQuery
        .of(context)
        .size;
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
                  buildResetPasswordTxtContainer(context),
                  buildResetPasswordContainer(context, mq),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildResetPasswordTxtContainer(BuildContext context) {
    return const Text(kNewPasswordMsg,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 18,
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
            margin: const EdgeInsets.only(top: 30, left: 10),
            child: const Text(kNewPassword,
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
            child: CommonPasswordTextField(
              controller: _passwordText,
              hintText: "Enter new password",
              text: "",
              isFocused: true,
              isDeco: true,
              focus: _passwordFocus,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 10, left: 10),
            child: const Text(kConfirmNewPassword,
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
              controller: _confirmPasswordText,
              hintText: "Enter confirm new password",
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
                  child: const Text('Reset Password',
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
              'Reset Password',
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

  void _navigateToDiscoverListScreen(BuildContext context, String name,
      String id) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (c, a1, a2) =>
            DiscoverCategoryListPage(categoryName: name, categoryId: id),
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
