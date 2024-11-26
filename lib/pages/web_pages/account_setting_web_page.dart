import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:success_subliminal/pages/account_setting_page.dart';
import 'package:success_subliminal/pages/web_pages/subscription_payment_web_page.dart';
import 'package:success_subliminal/widget/CommonTextField.dart';
import 'package:success_subliminal/widget/WebTopBarContainer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/router.dart';
import '../../data/api/ApiService.dart';
import '../../dialogs/custom_alert_dialog.dart';
import '../../utils/center_loader.dart';
import '../../utils/constant.dart';
import '../../utils/shared_prefs.dart';
import '../../utils/toast.dart';
import '../../widget/ButtonWidget.dart';
import '../../widget/ButtonWidget400.dart';
import '../../widget/CommonPasswordTextField.dart';
import '../../widget/PaymentCardsWidget.dart';
import '../../widget/SubscriptionSettingWidget.dart';
import '../../widget/SupportWidget.dart';
import '../../widget/TextFieldWidget400.dart';
import '../../widget/TextFieldWidget500.dart';
import '../../widget/WebFooterWithoutLinkWidget.dart';

class AccountSettingWebPage extends StatefulWidget {
  const AccountSettingWebPage({Key? key}) : super(key: key);

  @override
  AccountSettingWebState createState() => AccountSettingWebState();
}

class AccountSettingWebState extends State<AccountSettingWebPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _nameText = TextEditingController();
  final _supportDescriptionText = TextEditingController();
  final _emailText = TextEditingController();
  final _passwordText = TextEditingController();
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();

  final FocusNode _nameCFocus = FocusNode();
  final FocusNode _cardFocus = FocusNode();
  final FocusNode _expiryFocus = FocusNode();
  final FocusNode _expiryYearFocus = FocusNode();
  final FocusNode _cvvFocus = FocusNode();

  bool isNameFocused = false;
  bool isEmailFocused = false;
  bool isPasswordFocused = false;
  bool isChanges = false;
  dynamic myAccountData;
  dynamic myAccountUserDetail;
  double supportMessage = 0.5;
  double sizeScreen = 0.3;
  double cardSize = 0.3;
  double size = 0.25;
  double dialogScreenSize = 0.2;
  double creditsSize = 0.2;
  double cancelDialogSize = 0.2;
  double cardTextSize = 16;
  late int planIndex = -1;

  final _cardNoText = TextEditingController();
  final _expiryDateText = TextEditingController();
  final expiryYearText = TextEditingController();
  final _cvvText = TextEditingController();
  final _nameOnCardText = TextEditingController();

  dynamic editMyAccountData;
  dynamic editMyAccountUserDetail;
  String name = "";
  String editPaymentMethod = "";
  bool editMethod = false;
  bool editAddMethod = false;

  String screenName = "setting";
  List<dynamic> subscriptionList = [];
  List<dynamic> tempSubscriptionList = [];
  List<dynamic> tempSubscriptionPriceList = [];
  List<dynamic> subscriptionPriceList = [];
  List<dynamic> cardsList = [];
  late dynamic subscription;
  late dynamic paymentMethod;
  late dynamic addPaymentMethod;
  late dynamic listPaymentMethod;
  late dynamic deletePaymentMethod;
  late dynamic customerSupport;
  late dynamic conversionAddPayment;
  late dynamic deleteAccountData;

  String amount = "";
  String plan = "";
  String subId = "";

  bool isFreeTrialUsed = false;
  bool isTrial = false;
  bool isLogin = false;
  bool isSubscriptionActive = false;
  String isSubscriptionStatusActive = "";
  late dynamic cancelSubscription;
  late dynamic usedFreeTrial;
  late dynamic subscriptionDetail;
  double leftPadding = 200;
  double rightPadding = 200;
  double boxPadding = 40;
  Color textColor = Colors.white54;

  @override
  void initState() {
    super.initState();

    initializePreference().whenComplete(() {
      setState(() {
        isLogin = SharedPrefs().isLogin();
        isTrial = SharedPrefs().isFreeTrail();
        isFreeTrialUsed = SharedPrefs().isFreeTrailUsed();
        isSubscriptionActive = SharedPrefs().isSubscription();
        isSubscriptionStatusActive =
            SharedPrefs().getSubscriptionStatus().toString();
        setState(() {
          if (!isLogin) {
            context.pushReplacement(Routes.home);
          }
        });
      });
    });
    _getSubscriptionListData();
    _getListPaymentMethodData(SharedPrefs().getStripeCustomerId().toString());
    _getStripeSubscriptionDetail(context);
    setState(() {
      _nameText.text = SharedPrefs().getUserFullName()!;
      _emailText.text = SharedPrefs().getUserEmail()!;
      name = SharedPrefs().getUserFullName().toString().capitalize();
    });
  }

  Future<void> initializePreference() async {
    SharedPrefs.init(await SharedPreferences.getInstance());
  }

  void _getStripeSubscriptionDetail(BuildContext context) async {
    subscriptionDetail = await ApiService().getSubscriptionDetail(context);

    Future.delayed(const Duration(seconds: 2)).then((value) => setState(() {
          setState(() {
            if (subscriptionDetail['http_code'] != 200) {
            } else {
              subscriptionDetail = subscriptionDetail['data']
                  ['current_user_subscription_status'];
              if (subscriptionDetail != null) {
                _getIsUserSubscription();
              }
            }
          });
        }));
  }

  _handleOnTapOnSubscription(
      dynamic subscriptionList, dynamic subscriptionPriceList) {
    amount = (subscriptionPriceList['unit_amount'] / 100).toString();
    subId = subscriptionList['id'];
    plan = subscriptionList['name'];

    subscription != null
        ? context.pushNamed('add-payment', queryParameters: {
            'amount': amount,
            "subscriptionId": subId,
            "planType": plan,
            'screen': 'account',
          })
        : toast("Please Select Plan", false);

    // _navigateToSubscriptionScreen(context, amount, subId, plan);
  }

  _handleOnSendMessage(String message, BuildContext context, Size mq) {
    setState(() {
      if (kDebugMode) {
        print("message--$message");
      }
      showCenterLoader(context);
      _getCustomerSupport(message, context, mq);
    });
  }

  _handleOnYesSubscription() {
    Navigator.of(context, rootNavigator: true).pop();
    showCenterLoader(context);
    _getCancelSubscriptionData();
  }

  _handleOnDelete() {
    setState(() {
      dialog(context);
    });
  }

  Future dialog(BuildContext buildContext) {
    return showDialog(
      context: context,
      builder: (buildContext) => AlertDialog(
        content:
            const Text("Are you sure to delete permanently to your account?"),
        backgroundColor: kTransBaseNewWeb,
        actions: [
          TextButton(
            child: const Text(
              kCancel,
              style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'DPClear',
                  fontWeight: FontWeight.w700,
                  color: kTextColor),
            ),
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
            },
          ),
          TextButton(
            child: const Text(
              kOK,
              style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'DPClear',
                  fontWeight: FontWeight.w700,
                  color: kTextColor),
            ),
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
              showCenterLoader(context);
              _getDeleteAccountData();
            },
          ),
        ],
      ),
    );
  }

  void _getDeleteAccountData() async {
    deleteAccountData = await ApiService().getDeleteAccount(context);

    Future.delayed(const Duration(seconds: 2)).then((value) => setState(() {
          setState(() {
            if (deleteAccountData['http_code'] != 200) {
            } else {
              setState(() {
                if (player.playing) {
                  player.stop();
                }
                SharedPrefs().reset();

                SharedPrefs().removeTokenKey();
                SharedPrefs().setIsLogin(false);
                SharedPrefs().setIsSignUp(false);
                SharedPrefs().removeUserEmail();
                SharedPrefs().removeUserFullName();
                SharedPrefs().setIsSubPlaying(false);
                SharedPrefs().setFreeSubId("");
                SharedPrefs().setIsFreeTrail(false);
                SharedPrefs().setIsFreeTrailUsed(false);
                SharedPrefs().setPlayingSubId(0);
                SharedPrefs().setIsSubscription(false);
                SharedPrefs().setUserSubscriptionId("");
                SharedPrefs().setSubscriptionStartDate("");
                SharedPrefs().setSubscriptionEndDate("");
                SharedPrefs().setStripeCustomerId("");

                Navigator.of(context, rootNavigator: true).pop();
                context.go(Routes.home);
              });
            }
          });
        }));
  }

  _handleOnSaveAllChanges() {
    setState(() {
      if (_nameText.text.toString() == "") {
        const CustomAlertDialog().errorDialog(kNameNullError, context);
      } else if (_passwordText.text.toString() != "") {
        if (_passwordText.text.length < 6) {
          const CustomAlertDialog().errorDialog(kShortPassError, context);
        } else {
          showCenterLoader(context);
          _getEditMyAccount();
        }
      } else {
        showCenterLoader(context);
        _getEditMyAccount();
      }
    });
  }

  _handleOnCancelButton() {
    Navigator.of(context, rootNavigator: true).pop();
  }

  _handleOnEditCard(String pmId) {
    setState(() {
      editPaymentMethod = pmId;
      editMethod = true;

      if (kDebugMode) {
        print("editPaymentMethod--$editPaymentMethod");
        print("editMethod--$editMethod");
      }
    });
  }

  _handleOnDeleteCard(String pmId) {
    setState(() {
      showCenterLoader(context);
      _getDeletePaymentMethod(pmId);
    });
  }

  _handleOnAddCardInStripeButton() {
    setState(() {
      if (kDebugMode) {
        print("_cardNo--${_cardNoText.text}");
        print("_expiryDateText--${_expiryDateText.text}");
        print("expiryYearText--${expiryYearText.text}");
        print("_cvvText--${_cvvText.text}");
      }

      if (isValidCardDetailInSetting(
        _nameOnCardText.text.toString(),
        _cardNoText.text.toString(),
        _expiryDateText.text.toString(),
        expiryYearText.text.toString(),
        _cvvText.text.toString(),
      )) {
        showCenterLoader(context);
        _getCreatePaymentMethodData(
            context,
            _cardNoText.text,
            _nameOnCardText.text,
            _expiryDateText.text,
            expiryYearText.text,
            _cvvText.text);
      } else {}
    });
  }

  void _getSubscriptionListData() async {
    subscription = await ApiService().getStripeProduct(context);

    Future.delayed(const Duration(seconds: 1)).then((value) => setState(() {
          setState(() {
            if (subscription['http_code'] != 200) {
            } else {
              tempSubscriptionList
                  .addAll(subscription['data']['product_list']['data']);
              tempSubscriptionPriceList
                  .addAll(subscription['data']['product_price']['data']);

              if (tempSubscriptionList.isNotEmpty) {
                for (int i = 0; i < tempSubscriptionList.length; i++) {
                  if (tempSubscriptionList[i]['active'] == true) {
                    subscriptionList.add(tempSubscriptionList[i]);
                    subscriptionPriceList.add(tempSubscriptionPriceList[i]);
                  }
                }
              }
            }

            if (subscriptionList.isNotEmpty) {
              for (int i = 0; i < subscriptionList.length; i++) {
                if (isTrial ||
                    isSubscriptionActive ||
                    isSubscriptionStatusActive != "canceled") {
                  if (kDebugMode) {
                    print("id ----${subscriptionList[i]['id'].toString()}");
                    print(
                        "planId ----${SharedPrefs().getUserPlanId().toString()}");
                  }

                  if (subscriptionList[i]['id'].toString() ==
                      SharedPrefs().getUserPlanId().toString()) {
                    setState(() {
                      amount = (subscriptionPriceList[i]['unit_amount'] / 100)
                          .toString();
                      plan = subscriptionList[i]['name'];

                      SharedPrefs().setUserPlanName(plan);
                      SharedPrefs().setUserPlanAmount(amount);
                      setState(() {
                        if (isSubscriptionActive ||
                            isSubscriptionStatusActive != "canceled") {
                          planIndex = i;
                        }
                      });
                    });
                  }
                }
              }
            }
          });
        }));
  }

  void _getUsedFreeTrialData(
      BuildContext context, String status, String id) async {
    usedFreeTrial = await ApiService().getFreeTrialUsed(context, status, id);

    Future.delayed(const Duration(seconds: 2)).then((value) => setState(() {
          setState(() {
            if (usedFreeTrial['http_code'] != 200) {
            } else {
              if (usedFreeTrial['data']['free_trial_status'] == 'true') {
                setState(() {
                  SharedPrefs().setIsFreeTrailUsed(true);
                  isTrial = SharedPrefs().isFreeTrail();
                  isFreeTrialUsed = SharedPrefs().isFreeTrailUsed();
                  isSubscriptionActive = SharedPrefs().isSubscription();
                });
              }
            }
          });
        }));
  }

  void _getCancelSubscriptionData() async {
    cancelSubscription = await ApiService().getCancelSubscription(
        context, SharedPrefs().getUserSubscriptionId().toString());

    Future.delayed(const Duration(seconds: 2))
        .then((value) => setState(() async {
              setState(() {
                Navigator.of(context, rootNavigator: true).pop();
                if (cancelSubscription['http_code'] != 200) {
                } else {
                  subscriptionDetail = cancelSubscription['message'];

                  if (subscriptionDetail == null || isTrial) {
                    SharedPrefs().setIsSubscriptionStatus('canceled');
                    setState(() {
                      isSubscriptionStatusActive =
                          SharedPrefs().getSubscriptionStatus().toString();
                      planIndex = -1;
                    });
                  } else {
                    setState(() {
                      planIndex = -1;
                      _getIsUserSubscription();
                      // _getUsedFreeTrialData(context, "true", "0");
                    });
                  }
                  const CustomAlertDialog().errorDialog(
                      'Your subscription has been canceled', context);
                }
              });
            }));
  }

  void _getIsUserSubscription() {
    setState(() {
      if (subscriptionDetail['subscription_status'] == "trialing") {
        setState(() {
          SharedPrefs().setIsFreeTrail(true);
          isTrial = SharedPrefs().isFreeTrail();
        });
      } else if (subscriptionDetail['subscription_status'] == "active") {
        setState(() {
          SharedPrefs().setIsSubscription(true);

          isSubscriptionActive = SharedPrefs().isSubscription();
        });
      } else if (subscriptionDetail['subscription_status'] == "canceled") {
        setState(() {
          SharedPrefs().setIsFreeTrail(false);
          SharedPrefs().setIsSubscription(false);
          SharedPrefs().setIsFreeTrailUsed(true);
          SharedPrefs().setUserPlanId('');
          SharedPrefs().setUserSubscriptionId('');
          SharedPrefs().setSubscriptionEndDate('');
          SharedPrefs().setSubscriptionStartDate('');

          isTrial = SharedPrefs().isFreeTrail();
          isSubscriptionActive = SharedPrefs().isSubscription();

          planIndex = -1;
        });
      }
      SharedPrefs().setIsSubscriptionStatus(subscriptionDetail['status']);

      setState(() {
        isSubscriptionStatusActive =
            SharedPrefs().getSubscriptionStatus().toString();
      });
    });
  }

  void _getCreatePaymentMethodData(BuildContext context, String cardNo,
      String cardName, String expMonth, String expYear, String cvv) async {
    paymentMethod = await ApiService().getCreateStripePaymentMethod(
        cardNo, cardName, expMonth, expYear, cvv, "card", context);

    Future.delayed(const Duration(seconds: 2)).then((value) => setState(() {
          setState(() {
            if (paymentMethod.containsKey('error')) {
              toast(paymentMethod['error']['message'], true);

              Navigator.of(context, rootNavigator: true).pop();
            } else {
              setState(() {
                paymentMethod = paymentMethod;
                editAddMethod = true;
                _getAddPaymentMethodData(
                    context, paymentMethod['id'].toString());

                /*  isTrial || isSubscriptionActive
                      ? _getUsedFreeTrialData(context, "true")
                      : isTrial;*/
              });
            }
          });
        }));
  }

  void _getAddPaymentMethodData(BuildContext context, String pmId) async {
    addPaymentMethod = await ApiService().getAddStripePaymentMethod(
        SharedPrefs().getStripeCustomerId().toString(), pmId, context);

    Future.delayed(const Duration(seconds: 2)).then((value) => setState(() {
          setState(() {
            Navigator.of(context, rootNavigator: true).pop();
            Navigator.of(context, rootNavigator: true).pop();
            if (addPaymentMethod == null) {
              toast(addPaymentMethod['error']['message'], true);
              Navigator.of(context, rootNavigator: true).pop();
            } else {
              setState(() {
                addPaymentMethod = addPaymentMethod;
                editMethod
                    ? _handleOnDeleteCard(editPaymentMethod)
                    : _getListPaymentMethodData(
                        SharedPrefs().getStripeCustomerId().toString());

                _nameOnCardText.text = "";
                _cvvText.text = "";
                _cardNoText.text = "";
                expiryYearText.text = "";
                _expiryDateText.text = "";
              });
            }

            trackAddPaymentInfo();
          });
        }));
  }

  void _getListPaymentMethodData(String customerId) async {
    listPaymentMethod =
        await ApiService().getStripePaymentMethodList(customerId, context);

    Future.delayed(const Duration(seconds: 2)).then((value) => setState(() {
          if (listPaymentMethod.containsKey('error')) {
            if (listPaymentMethod['error']['code'] == 'resource_missing') {
              toast(listPaymentMethod['error']['message'], true);
            } else {
              toast(listPaymentMethod['error']['message'], true);
            }
          } else {
            setState(() {
              cardsList = listPaymentMethod['data'];
            });
          }
        }));
  }

  void _getDeletePaymentMethod(String pmId) async {
    deletePaymentMethod =
        await ApiService().getDeleteStripePaymentMethod(pmId, context);

    Future.delayed(const Duration(seconds: 2)).then((value) => setState(() {
          if (deletePaymentMethod == null) {
            Navigator.of(context, rootNavigator: true).pop();
          } else {
            Navigator.of(context, rootNavigator: true).pop();
            setState(() {
              !editMethod
                  ? const CustomAlertDialog().errorDialog(
                      "Your **** ${deletePaymentMethod['card']['last4'].toString()}  card is successfully removed",
                      context)
                  : const CustomAlertDialog().errorDialog(
                      "Your card details has been updated successfully",
                      context);
              // toast(deletePaymentMethod['card']['last4'].toString(), true);
              _getListPaymentMethodData(
                  SharedPrefs().getStripeCustomerId().toString());

              editMethod = false;
              editPaymentMethod = "";
            });
          }
        }));
  }

  void _getCustomerSupport(
      String message, BuildContext context, Size mq) async {
    customerSupport = await ApiService().getCustomerSupport(context, message);

    Future.delayed(const Duration(seconds: 2)).then((value) => setState(() {
          if (customerSupport['http_code'] != 200) {
            Navigator.of(context, rootNavigator: true).pop();
          } else {
            Navigator.of(context, rootNavigator: true).pop();
            setState(() {
              dialogSentMessageContainer(context, mq);
              _supportDescriptionText.text = "";
            });
          }
        }));
  }

  void _getEditMyAccount() async {
    editMyAccountData = await ApiService().getEditAccount(
      _nameText.text.toString(),
      _passwordText.text.toString(),
      context,
    );

    Future.delayed(const Duration(seconds: 2)).then((value) => setState(() {
          setState(() {
            if (editMyAccountData['http_code'] != 200) {
            } else {
              setState(() {
                editMyAccountUserDetail = editMyAccountData['data']['user'];

                _nameText.text = editMyAccountUserDetail['name'];
                _emailText.text = editMyAccountUserDetail['email'];
                _passwordText.text = "";

                SharedPrefs().removeUserFullName();
                SharedPrefs().removeUserEmail();
              });
              setState(() {
                isChanges = true;
                SharedPrefs().setUserFullName(editMyAccountUserDetail['name']);
                SharedPrefs().setUserEmail(editMyAccountUserDetail['email']);
                name = SharedPrefs().getUserFullName().toString().capitalize();
                isNameFocused = false;
                isEmailFocused = false;
                isPasswordFocused = false;
              });
            }

            Navigator.of(context, rootNavigator: true).pop();
          });
        }));
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
              if (constraints.maxWidth < 800) {
                titleTextSize = 50;
                loginTopPadding = 100;
                supportMessage = 0.8;
                sizeScreen = 0.9;
                size = 0.75;
                dialogScreenSize = 0.4;
                cardSize = 0.7;
                creditsSize = 0.6;

                leftPadding = 50;
                rightPadding = 50;
                boxPadding = 20;
              } else if (constraints.maxWidth < 1100) {
                titleTextSize = 55;
                loginTopPadding = 105;
                supportMessage = 0.7;
                sizeScreen = 0.8;
                size = 0.65;
                dialogScreenSize = 0.35;
                cardSize = 0.6;
                creditsSize = 0.5;
                leftPadding = 50;
                rightPadding = 50;
                boxPadding = 25;
              } else if (constraints.maxWidth < 1300) {
                titleTextSize = 60;
                loginTopPadding = 110;
                supportMessage = 0.6;
                sizeScreen = 0.7;
                size = 0.55;
                dialogScreenSize = 0.3;
                cardSize = 0.5;
                creditsSize = 0.4;
                leftPadding = 100;
                rightPadding = 100;
                boxPadding = 30;
              } else if (constraints.maxWidth < 1600) {
                titleTextSize = 65;
                loginTopPadding = 115;
                supportMessage = 0.55;
                sizeScreen = 0.6;
                size = 0.45;
                dialogScreenSize = 0.25;
                cardSize = 0.4;
                creditsSize = 0.3;
                leftPadding = 150;
                rightPadding = 150;
                boxPadding = 35;
              } else if (constraints.maxWidth < 2000) {
                titleTextSize = 70;
                loginTopPadding = 120;
                supportMessage = 0.50;
                leftPadding = 200;
                rightPadding = 200;
                sizeScreen = 0.5;
                size = 0.3;
                dialogScreenSize = 0.2;
                cardSize = 0.3;
                boxPadding = 40;
                creditsSize = 0.2;
              }

              return buildHomeContainer(context, mq);
            } else {
              return const AccountSettingPage();
            }
          },
        )
        //),
        );
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
          children: <Widget>[
            const WebTopBarContainer(screen: "account"),
            Positioned(
                bottom: 0,
                child: SizedBox(
                    height: 80,
                    width: mq.width * 1,
                    child: const WebFooterWithoutLinkWidget())),
            Container(
              margin: EdgeInsets.only(
                  left: leftPadding,
                  right: rightPadding,
                  bottom: 100,
                  top: loginTopPadding),
              child: ListView(
                shrinkWrap: true,
                primary: false,
                children: [
                  buildTopBarContainer(context, mq),
                  screenName == "setting"
                      ? buildAccountDetailContainer(context, mq)
                      : const SizedBox(),
                  screenName == "credits"
                      ? Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                              Container(
                                margin:
                                    const EdgeInsets.only(top: 80, left: 15),
                                width: mq.width * creditsSize,
                                child: const TextFieldWidget(
                                  text: 'Coming Soon',
                                  size: 26,
                                  color: Colors.white,
                                  weight: FontWeight.w400,
                                ),
                              )

                              /*  Container(
                                  margin: const EdgeInsets.only(top: 50),
                                  decoration: kAllCornerBoxDecoration2,
                                  width: mq.width * creditsSize,
                                  child: CreditsWidget(
                                    noOfCards: cardsList.length.toString(),
                                    onTap: () {},
                                  ))*/
                            ])
                      : const SizedBox(),
                  screenName == "gifts"
                      ? Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                              Container(
                                margin:
                                    const EdgeInsets.only(top: 80, left: 15),
                                width: mq.width * creditsSize,
                                child: const TextFieldWidget(
                                  text: 'Coming Soon',
                                  size: 26,
                                  weight: FontWeight.w400,
                                  color: Colors.white,
                                ),
                              )

                              /* Container(
                                  margin: const EdgeInsets.only(top: 50),
                                  decoration: kAllCornerBoxDecoration2,
                                  width: mq.width * creditsSize,
                                  child: CreditsWidget(
                                    noOfCards: cardsList.length.toString(),
                                    onTap: () {},
                                  ))*/
                            ])
                      : const SizedBox(),
                  screenName == "payment_card"
                      ? Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                              Container(
                                  margin:
                                      const EdgeInsets.only(top: 80, left: 15),
                                  decoration: kAllCornerBoxDecoration2,
                                  width: mq.width * .8,
                                  child: PaymentCardsWidget(
                                    mq: mq,
                                    cardList: cardsList,
                                    cardNoText: _cardNoText,
                                    expiryDateText: _expiryDateText,
                                    cvvText: _cvvText,
                                    nameText: _nameOnCardText,
                                    expiryYearText: expiryYearText,
                                    size: size,
                                    sizeScreen: sizeScreen,
                                    onAddTap: () {
                                      _handleOnAddCardInStripeButton();
                                    },
                                    onEditTap: _handleOnEditCard,
                                    onDelete: deleteCardAlert,
                                    cardSize: cardSize,
                                    nameFocus: _nameCFocus,
                                    cvvFocus: _cvvFocus,
                                    expiryMonthFocus: _expiryFocus,
                                    expiryYearFocus: _expiryYearFocus,
                                    cardFocus: _cardFocus,
                                    padding: 40,
                                    margin: 20,
                                    detailPadding: 60,
                                    titleSize: 34,
                                    cardTextSize: 16,
                                  ))
                            ])
                      : const SizedBox(),
                  screenName == "notification"
                      ? Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                              Container(
                                margin:
                                    const EdgeInsets.only(top: 80, left: 15),
                                width: mq.width * creditsSize,
                                child: const TextFieldWidget(
                                  text: 'Coming Soon',
                                  size: 26,
                                  weight: FontWeight.w400,
                                  color: Colors.white,
                                ),
                              )

                              /*   Container(
                                  margin: const EdgeInsets.only(top: 30),
                                  decoration: kAllCornerBoxDecoration2,
                                  width: mq.width * supportMessage,
                                  child: const NotificationWidget())*/
                            ])
                      : const SizedBox(),
                  screenName == "subscription"
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                              /* Row(
                                children: [*/
                              //buildCurrentSubscriptionContainer(context, mq),
                              buildOptionsSubscriptionContainer(context, mq),
                              /* ],
                              ),*/
                              /*  Row(
                                children: [*/
                              //buildFreeSubscriptionContainer(context, mq),
                              buildSubscriptionContainer(context, mq),
                              isSubscriptionStatusActive != "canceled"
                                  ? Container(
                                      margin: const EdgeInsets.only(
                                          top: 30, left: 15),
                                      width: 300,
                                      alignment: Alignment.topLeft,
                                      child: ButtonWidget400(
                                          name: 'Cancel Subscription',
                                          icon: '',
                                          visibility: false,
                                          padding: 20,
                                          onTap: () => {
                                                buildCancelSubscriptionDialogContainer(
                                                    context, mq)
                                              },
                                          size: 14,
                                          buttonSize: 50,
                                          deco: kButtonBox10Decoration))
                                  : const Text(""),

                              /* ],
                              )*/
                            ])
                      : const SizedBox(),
                  screenName == "support"
                      ? Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildYouMessageContainer(context, mq),
                            Container(
                                margin: const EdgeInsets.only(left: 15),
                                width: mq.width * supportMessage,
                                child: SupportWidget(
                                  supportDescriptionText:
                                      _supportDescriptionText,
                                )),
                            Container(
                                margin: const EdgeInsets.only(
                                    top: 20, left: 20, right: 30),
                                width: mq.width * supportMessage,
                                alignment: Alignment.topRight,
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Container(
                                          width: mq.width *
                                              (supportMessage -
                                                  (supportMessage - 0.15)),
                                          margin:
                                              const EdgeInsets.only(right: 5),
                                          child: ButtonWidget400(
                                              name: 'Send',
                                              icon: '',
                                              visibility: false,
                                              padding: 20,
                                              onTap: () => {
                                                    if (_supportDescriptionText
                                                            .text !=
                                                        "")
                                                      {
                                                        _handleOnSendMessage(
                                                            _supportDescriptionText
                                                                .text
                                                                .toString(),
                                                            context,
                                                            mq)
                                                      }
                                                    else
                                                      {
                                                        toast(
                                                            "Please enter you query",
                                                            false)
                                                      }
                                                  },
                                              size: 14,
                                              buttonSize: 50,
                                              deco: kButtonBox10Decoration))
                                    ]))
                          ],
                        )
                      : const SizedBox()
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildYouMessageContainer(BuildContext context, Size mq) {
    return Container(
        alignment: Alignment.topLeft,
        margin: const EdgeInsets.only(top: 80, bottom: 10, left: 15),
        child: const TextFieldWidget(
          text: 'Your message',
          size: 30,
          weight: FontWeight.w400,
          color: Colors.white,
        ));
  }

  Widget buildCurrentSubscriptionContainer(BuildContext context, Size mq) {
    return Container(
        width: 300,
        alignment: Alignment.topLeft,
        child: const TextFieldWidget(
          text: 'Current Subscription Plan',
          size: 22,
          weight: FontWeight.w400,
          color: Colors.white54,
        ));
  }

  Widget buildOptionsSubscriptionContainer(BuildContext context, Size mq) {
    return Container(
        margin: const EdgeInsets.only(left: 15, top: 80),
        alignment: Alignment.topLeft,
        child: const TextFieldWidget(
          text: 'Options to Upgrade',
          size: 22,
          weight: FontWeight.w400,
          color: Colors.white,
        ));
  }

  Widget buildFreeSubscriptionContainer(BuildContext context, Size mq) {
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.only(
        right: 20,
        top: 20,
      ),
      height: 230,
      width: 300,
      decoration: kAllCornerBoxDecoration2,
      child: Text(
        isTrial || isSubscriptionActive
            ? SharedPrefs().getUserPlanName().toString()
            : "Free",
        style: const TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontFamily: 'DPClear',
            fontWeight: FontWeight.w400),
      ),
    );
  }

  Widget buildSubscriptionContainer(BuildContext context, Size mq) {
    return (subscriptionList.isNotEmpty)
        ? Align(
            alignment: Alignment.topLeft,
            child: Container(
                margin: const EdgeInsets.only(
                  left: 15,
                  right: 10,
                ),
                height: 250,
                child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    reverse: false,
                    primary: false,
                    itemCount: subscriptionList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return SubscriptionWidget(
                        subscription: subscriptionList[index],
                        subscriptionPriceList: subscriptionPriceList[index],
                        index: index,
                        onTap: () => planIndex == index
                            ? toast(
                                "You have already this plan , Please choose another one$planIndex",
                                false)
                            : _handleOnTapOnSubscription(
                                subscriptionList[index],
                                subscriptionPriceList[index]),
                        currentPlan: planIndex == index,
                        width: 300,
                        radius: 10,
                      );
                    })))
        : Container(
            alignment: Alignment.topCenter,
            margin: const EdgeInsets.only(top: 20, left: 10),
            child: const Align(
              alignment: Alignment.center,
              child: Text(
                kComingSoon,
                style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontFamily: 'DPClear',
                    fontWeight: FontWeight.w600),
              ),
            ),
          );
  }

  Widget buildTopBarContainer(BuildContext context, Size mq) {
    return Column(
      children: [
        Container(
            alignment: Alignment.topLeft,
            margin: const EdgeInsets.only(left: 15),
            child: TextFieldWidget500(
                text: name,
                size: 32,
                color: Colors.white,
                textAlign: TextAlign.center)),
        Container(
          height: 30,
          margin: const EdgeInsets.only(top: 24, left: 15),
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                      onTap: () => {
                            setState(() {
                              screenName = "setting";
                            })
                          },
                      child: Container(
                          margin: const EdgeInsets.only(right: 30),
                          child: TextFieldWidget(
                            text: 'Settings',
                            size: 22,
                            weight: FontWeight.w400,
                            color:
                                screenName == "setting" ? accent : Colors.white,
                          )))),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => {
                    setState(() {
                      screenName = "subscription";
                    })
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 30),
                    child: Text(
                      "Subscription",
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w400,
                          color: screenName == "subscription"
                              ? accent
                              : Colors.white),
                    ),
                  ),
                ),
              ),
              MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => {
                      setState(() {
                        screenName = "payment_card";
                      })
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 30),
                      child: Text(
                        "Payment Card",
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w400,
                            color: screenName == "payment_card"
                                ? accent
                                : Colors.white),
                      ),
                    ),
                  )),
              MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => {
                      setState(() {
                        screenName = "credits";
                      })
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 30),
                      child: Text(
                        "Credits",
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w400,
                            color: screenName == "credits"
                                ? accent
                                : Colors.white),
                      ),
                    ),
                  )),
              MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                      onTap: () => {
                            setState(() {
                              screenName = "gifts";
                            })
                          },
                      child: Container(
                        margin: const EdgeInsets.only(right: 30),
                        child: Text(
                          "Gift",
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w400,
                              color: screenName == "gifts"
                                  ? accent
                                  : Colors.white),
                        ),
                      ))),
              MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                      onTap: () => {
                            setState(() {
                              screenName = "notification";
                            })
                          },
                      child: Container(
                        margin: const EdgeInsets.only(right: 30),
                        child: Text(
                          "Notifications",
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w400,
                              color: screenName == "notification"
                                  ? accent
                                  : Colors.white),
                        ),
                      ))),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                    onTap: () => {
                          setState(() {
                            screenName = "support";
                          })
                        },
                    child: Container(
                      margin: const EdgeInsets.only(right: 30),
                      child: Text(
                        "Support",
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w400,
                            color: screenName == "support"
                                ? accent
                                : Colors.white),
                      ),
                    )),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget buildAccountDetailContainer(BuildContext context, Size mq) {
    return Container(
      margin: const EdgeInsets.only(top: 80, left: 15),
      padding: const EdgeInsets.all(15),
      decoration: kAllCornerBoxDecoration2,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
              margin: EdgeInsets.only(bottom: 12, left: boxPadding, top: 30),
              child: const Text(
                'Your account settings',
                style: TextStyle(color: Colors.white, fontSize: 30),
              )),
          Container(
              margin: EdgeInsets.only(bottom: 20, left: boxPadding),
              child: const Text(
                  'Update your success subliminials account info.',
                  style: TextStyle(color: Colors.grey, fontSize: 14))),
          Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Expanded(
                    flex: 1,
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            alignment: Alignment.topLeft,
                            margin:
                                EdgeInsets.only(left: boxPadding, bottom: 15),
                            child: const Text(
                              'Full Name',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'DPClear',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 18),
                            ),
                          ),
                          Container(
                            height: 60,
                            margin: EdgeInsets.only(
                              left: boxPadding,
                              right: 15,
                            ),
                            decoration: !isNameFocused
                                ? kEditTextDecoration
                                : kEditTextWithBorderDecoration,
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 6,
                                  child: CommonTextField(
                                    controller: _nameText,
                                    hintText: kEnterName,
                                    text: '',
                                    isFocused: true,
                                    isDeco: false,
                                    textColor: textColor,
                                    focus: _nameFocus,
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: GestureDetector(
                                    onTap: () => {
                                      setState(() {
                                        if (isNameFocused) {
                                          isNameFocused = false;
                                          textColor = Colors.white54;
                                        } else {
                                          isNameFocused = true;
                                          textColor = Colors.white;
                                        }
                                      })
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(right: 5),
                                      height: 50,
                                      decoration: !isNameFocused
                                          ? kTransButtonBoxDecoration
                                          : kAccentButtonBoxDecoration,
                                      alignment: Alignment.topRight,
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: Image.asset(
                                            'assets/images/ic_edit_pencil.png',
                                            scale: 2),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ])),
                Expanded(
                    flex: 1,
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            alignment: Alignment.topLeft,
                            margin: const EdgeInsets.only(
                                left: 30, right: 15, bottom: 15),
                            child: const Text(
                              'Email',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'DPClear',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 18),
                            ),
                          ),
                          Container(
                            height: 60,
                            margin: EdgeInsets.only(
                              left: boxPadding,
                              right: 15,
                            ),
                            decoration: !isEmailFocused
                                ? kEditTextDecoration
                                : kEditTextWithBorderDecoration,
                            child: Row(
                              children: [
                                Expanded(
                                    flex: 6,
                                    child: CommonTextField(
                                      controller: _emailText,
                                      hintText: kEnterEmail,
                                      text: '',
                                      isFocused: true,
                                      isDeco: false,
                                      textColor: Colors.white54,
                                      focus: _emailFocus,
                                    )),
                                Expanded(
                                  flex: 1,
                                  child: GestureDetector(
                                    onTap: () => {
                                      setState(() {
                                        if (isEmailFocused) {
                                          isEmailFocused = false;
                                          toast("You can't change the email",
                                              true);
                                        } else {
                                          isEmailFocused = false;
                                          toast("You can't change the email",
                                              true);
                                        }
                                      })
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(right: 5),
                                      height: 50,
                                      decoration: !isEmailFocused
                                          ? kTransButtonBoxDecoration
                                          : kAccentButtonBoxDecoration,
                                      alignment: Alignment.topRight,
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: Image.asset(
                                            'assets/images/ic_edit_pencil.png',
                                            scale: 2),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ])),
                Expanded(
                    flex: 1,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            alignment: Alignment.topLeft,
                            margin: EdgeInsets.only(
                                left: boxPadding,
                                right: boxPadding,
                                bottom: 15,
                                top: 25),
                            child: const Text(
                              'Password',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'DPClear',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 18),
                            ),
                          ),
                          Container(
                            height: 60,
                            margin: EdgeInsets.only(
                              left: 15,
                              right: boxPadding,
                            ),
                            decoration: isPasswordFocused
                                ? kEditTextWithBorderDecoration
                                : kEditTextDecoration,
                            child: Row(
                              children: [
                                Expanded(
                                    flex: 6,
                                    child: CommonPasswordTextField(
                                      controller: _passwordText,
                                      hintText: kEnterPassword,
                                      text: '',
                                      isFocused: true,
                                      isDeco: false,
                                      focus: _passwordFocus,
                                    )),
                                Expanded(
                                  flex: 1,
                                  child: GestureDetector(
                                    onTap: () => {
                                      setState(() {
                                        if (isPasswordFocused) {
                                          isPasswordFocused = false;
                                        } else {
                                          isPasswordFocused = true;
                                        }
                                      })
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(right: 5),
                                      height: 50,
                                      decoration: isPasswordFocused
                                          ? kAccentButtonBoxDecoration
                                          : kTransButtonBoxDecoration,
                                      alignment: Alignment.topRight,
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: Image.asset(
                                            'assets/images/ic_edit_pencil.png',
                                            scale: 2),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(
                                left: 25, right: 15, top: 10),
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
                        ])),
              ]),
          Visibility(
            visible: isChanges,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(top: 10, left: boxPadding),
                  child: Align(
                    alignment: Alignment.center,
                    child: Image.asset(
                      'assets/images/ic_tick_circle.png',
                      scale: 2.5,
                      color: green,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 10, left: 5),
                  child: const Text('Changes saved',
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'DPClear',
                        color: green,
                        fontWeight: FontWeight.w400,
                      )),
                ),
              ],
            ),
          ),
          Container(
            width: 250,
            margin: EdgeInsets.only(top: 30, bottom: 30, left: boxPadding),
            child: ButtonWidget400(
              buttonSize: 50,
              name: 'save all changes'.toUpperCase(),
              icon: 'assets/images/ic_tick_circle.png',
              visibility: true,
              padding: 10,
              onTap: _handleOnSaveAllChanges,
              size: 14,
              deco: kButtonBox10Decoration,
            ),
          ),
          Container(
              width: 250,
              margin: EdgeInsets.only(bottom: 30, left: boxPadding),
              child: ButtonWidget(
                name: "Delete Account ",
                icon: 'assets/images/ic_delete_white.png',
                visibility: true,
                padding: 10,
                onTap: () => {_handleOnDelete()},
                size: 14,
                scale: 6,
                height: 50,
              ))
        ],
      ),
    );
  }

  deleteCardAlert(String pmId) {
    return showDialog(
      context: context,
      builder: (buildContext) => AlertDialog(
        content: const Text(kRemoveCard,
            style: TextStyle(
                fontSize: 18,
                fontFamily: 'DPClear',
                fontWeight: FontWeight.w500,
                color: Colors.white)),
        actions: [
          TextButton(
            child: const Text(
              kCancel,
              style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'DPClear',
                  fontWeight: FontWeight.w500,
                  color: kTextColor),
            ),
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
              // Navigator.pop(context);
            },
          ),
          TextButton(
            child: const Text(
              kOK,
              style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'DPClear',
                  fontWeight: FontWeight.w500,
                  color: kTextColor),
            ),
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
              _handleOnDeleteCard(pmId);
            },
          ),
        ],
      ),
    );
  }

  dialogSentMessageContainer(BuildContext contexts, Size mq) {
    return showDialog(
        context: contexts,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0)),
              backgroundColor: primary,
              insetPadding: const EdgeInsets.all(15),
              child: Padding(
                padding: const EdgeInsets.all(50),
                child: SizedBox(
                  width: mq.width * dialogScreenSize,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        alignment: Alignment.center,
                        child: const TextFieldWidget500(
                            text: kMessageSent,
                            size: 30,
                            color: accent,
                            textAlign: TextAlign.center),
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        child: const TextFieldWidget(
                            text: kReplyShortly,
                            size: 14,
                            weight: FontWeight.w400,
                            color: Colors.black),
                      ),
                      GestureDetector(
                        onTap: () =>
                            {Navigator.of(context, rootNavigator: true).pop()},
                        child: Container(
                            margin: const EdgeInsets.only(top: 30),
                            width: 200,
                            height: 50,
                            alignment: Alignment.center,
                            decoration: kBlackButtonBox10Decoration,
                            child: TextFieldWidget(
                                text: "Close".toUpperCase(),
                                size: 14,
                                weight: FontWeight.w400,
                                color: Colors.white)),
                      )
                    ],
                  ),
                ),
              ));
        });
  }

  void _navigateToSubscriptionScreen(
      BuildContext context, String amount, String subId, String plan) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (c, a1, a2) => SubscriptionPaymentWebPage(
          amount: amount,
          subscriptionId: subId,
          planType: plan,
          screen: 'setting',
        ),
        transitionsBuilder: (c, anim, a2, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  launchURL() async {
    const url =
        'https://www.freeprivacypolicy.com/live/27ba60ac-2400-455c-ba64-a0d06a2c5872';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  buildCancelSubscriptionDialogContainer(BuildContext contexts, Size mq) {
    return showDialog(
        context: contexts,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0)),
              backgroundColor: kDialogBgColor,
              insetPadding: const EdgeInsets.all(15),
              child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: SizedBox(
                    width: mq.width * 0.2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Image.asset('assets/images/ic_alert.png',
                              scale: 2),
                        ),
                        Container(
                          margin: const EdgeInsets.only(
                            top: 10,
                          ),
                          alignment: Alignment.center,
                          child: Align(
                              alignment: Alignment.center,
                              child: RichText(
                                textAlign: TextAlign.center,
                                text: const TextSpan(
                                  text: kCancelSubscriptionAlert,
                                  style: TextStyle(
                                      fontSize: 22,
                                      color: Colors.white,
                                      fontFamily: 'DPClear',
                                      fontWeight: FontWeight.w500),
                                  /*defining default style is optional */
                                ),
                              )),
                        ),
                        Container(
                          decoration: kButtonBox10Decoration,
                          margin: const EdgeInsets.only(
                              top: 30, right: 25, left: 25),
                          child: ButtonWidget400(
                              name: 'Yes'.toUpperCase(),
                              buttonSize: 50,
                              icon: '',
                              visibility: false,
                              padding: 20,
                              onTap: () => _handleOnYesSubscription(),
                              size: 12,
                              deco: kButtonBox10Decoration),
                        ),
                        Container(
                          decoration: kButtonBox10Decoration,
                          margin: const EdgeInsets.only(
                              top: 10, right: 25, left: 25),
                          child: ButtonWidget400(
                              name: 'Cancel'.toUpperCase(),
                              buttonSize: 50,
                              icon: '',
                              visibility: false,
                              padding: 20,
                              onTap: () => _handleOnCancelButton(),
                              size: 12,
                              deco: kButtonBox10Decoration),
                        ),
                      ],
                    ),
                  )));
        });
  }
}
