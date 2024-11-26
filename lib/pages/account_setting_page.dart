import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app/router.dart';
import '../data/api/ApiService.dart';
import '../dialogs/custom_alert_dialog.dart';
import '../utils/center_loader.dart';
import '../utils/constant.dart';
import '../utils/shared_prefs.dart';
import '../utils/toast.dart';
import '../widget/BottomBarStateFullWidget.dart';
import '../widget/ButtonWidget.dart';
import '../widget/ButtonWidget400.dart';
import '../widget/PaymentCardsWidget.dart';
import '../widget/SubscriptionSettingWidget.dart';
import '../widget/SupportWidget.dart';
import '../widget/TextFieldWidget400.dart';
import '../widget/TextFieldWidget500.dart';

class AccountSettingPage extends StatefulWidget {
  const AccountSettingPage({Key? key}) : super(key: key);

  @override
  _AccountSettingPage createState() => _AccountSettingPage();
}

class _AccountSettingPage extends State<AccountSettingPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final _nameText = TextEditingController();
  final _emailText = TextEditingController();
  final _passwordText = TextEditingController();
  final _supportDescriptionText = TextEditingController();
  bool isNameFocused = false;
  bool isEmailFocused = false;
  bool isPasswordFocused = false;
  dynamic myAccountData;
  dynamic myAccountUserDetail;
  bool isChanges = false;
  dynamic editMyAccountData;
  dynamic editMyAccountUserDetail;
  String name = "";
  String screenCName = "setting";

  String editPaymentMethod = "";
  bool editMethod = false;
  bool editAddMethod = false;

  List<dynamic> subscriptionList = [];
  List<dynamic> tempSubscriptionList = [];
  List<dynamic> tempSubscriptionPriceList = [];
  List<dynamic> subscriptionPriceList = [];
  List<dynamic> cardsList = [];
  late dynamic subscription;
  late dynamic paymentMethod;
  late dynamic addPaymentMethod;
  late dynamic listPaymentMethod;
  late dynamic deleteAccountData;
  late dynamic deletePaymentMethod;
  late dynamic customerSupport;
  late int planIndex = -1;

  String amount = "";
  String plan = "";
  String subId = "";

  bool isFreeTrialUsed = false;
  bool isTrial = false;
  bool isSubscriptionActive = false;
  late dynamic cancelSubscription;
  late dynamic subscriptionDetail;
  late dynamic usedFreeTrial;
  late dynamic conversionAddPayment;
  String isSubscriptionStatusActive = "";

  final _cardNoText = TextEditingController();
  final _expiryDateText = TextEditingController();
  final expiryYearText = TextEditingController();
  final _cvvText = TextEditingController();
  final _nameOnCardText = TextEditingController();

  final FocusNode _nameCFocus = FocusNode();
  final FocusNode _cardFocus = FocusNode();
  final FocusNode _expiryFocus = FocusNode();
  final FocusNode _expiryYearFocus = FocusNode();
  final FocusNode _cvvFocus = FocusNode();

  double cardTextSize = 16;

  @override
  void initState() {
    super.initState();

    initializePreference().whenComplete(() {
      setState(() {});
    });
    _getListPaymentMethodData(SharedPrefs().getStripeCustomerId().toString());
    changeScreenName("account");
    _getSubscriptionListData();
    _getStripeSubscriptionDetail(context, 'load');
    setState(() {
      _nameText.text = SharedPrefs().getUserFullName()!;
      _emailText.text = SharedPrefs().getUserEmail()!;
      name = SharedPrefs().getUserFullName().toString().capitalize();

      isLogin = SharedPrefs().isLogin();
      isTrial = SharedPrefs().isFreeTrail();
      isFreeTrialUsed = SharedPrefs().isFreeTrailUsed();
      isSubscriptionActive = SharedPrefs().isSubscription();
      isSubscriptionStatusActive =
          SharedPrefs().getSubscriptionStatus().toString();
    });
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

  _handleOnDelete() {
    setState(() {
      dialog(context);
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

            if (kDebugMode) {
              print("paymentMethod ----$paymentMethod");
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
          setState(() {
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
          });
        }));
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

  void _getDeletePaymentMethod(String pmId) async {
    deletePaymentMethod =
        await ApiService().getDeleteStripePaymentMethod(pmId, context);

    Future.delayed(const Duration(seconds: 2)).then((value) => setState(() {
          setState(() {
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
          });
        }));
  }

  void _getCustomerSupport(
      String message, BuildContext context, Size mq) async {
    customerSupport = await ApiService().getCustomerSupport(context, message);

    Future.delayed(const Duration(seconds: 2)).then((value) => setState(() {
          setState(() {
            if (customerSupport['http_code'] != 200) {
              Navigator.of(context, rootNavigator: true).pop();
            } else {
              Navigator.of(context, rootNavigator: true).pop();
              setState(() {
                dialogSentMessageContainer(context, mq);
                _supportDescriptionText.text = "";
              });
            }
          });
        }));
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
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        child: const TextFieldWidget(
                          text: kReplyShortly,
                          size: 14,
                          color: Colors.black,
                          weight: FontWeight.w400,
                        ),
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
                              color: Colors.white,
                              weight: FontWeight.w400,
                            )),
                      )
                    ],
                  ),
                ),
              ));
        });
  }

  changeScreenName(String name) {
    setState(() {
      screenName = name;
    });
  }

  Future<void> initializePreference() async {
    SharedPrefs.init(await SharedPreferences.getInstance());
  }

  void _getSubscriptionListData() async {
    subscription = await ApiService().getStripeProduct(context);

    Future.delayed(const Duration(seconds: 2)).then((value) => setState(() {
          setState(() {
            if (subscription['http_code'] != 200) {
            } else {
              tempSubscriptionList
                  .addAll(subscription['data']['product_list']['data']);
              tempSubscriptionPriceList
                  .addAll(subscription['data']['product_price']['data']);
              for (int i = 0; i < tempSubscriptionList.length; i++) {
                if (tempSubscriptionList[i]['active'] == true) {
                  subscriptionList.add(tempSubscriptionList[i]);
                  subscriptionPriceList.add(tempSubscriptionPriceList[i]);
                }
              }
            }
            if (subscriptionList.isNotEmpty) {
              for (int i = 0; i < subscriptionList.length; i++) {
                if (isTrial ||
                    isSubscriptionActive ||
                    isSubscriptionStatusActive != "canceled") {
                  if (kDebugMode) {
                    print("id ----${subscriptionList[i]['id']}");
                    print("planId ----${SharedPrefs().getUserPlanId()}");
                  }

                  if (SharedPrefs().getUserPlanId() != null) {
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
              if (kDebugMode) {
                print("size ----${subscriptionList.length}");
                print("planIndex ----$planIndex");
                print("name ----${subscriptionList[0]['name']}");
                print(subscriptionList);
              }
            }
          });
        }));
  }

  void _getStripeSubscriptionDetail(BuildContext context, String type) async {
    subscriptionDetail = await ApiService().getSubscriptionDetail(context);

    Future.delayed(const Duration(seconds: 2)).then((value) => setState(() {
          setState(() {
            if (subscriptionDetail['http_code'] != 200) {
            } else {
              subscriptionDetail = subscriptionDetail['data']
                  ['current_user_subscription_status'];
              if (subscriptionDetail != null) {
                if (type == 'load') {
                  _getIsUserSubscriptionLoad(context);
                } else {
                  _getIsUserSubscription();
                }
              }
            }
          });
        }));
  }

  void _getCancelSubscriptionData() async {
    cancelSubscription = await ApiService().getCancelSubscription(
        context, SharedPrefs().getUserSubscriptionId().toString());

    Future.delayed(const Duration(seconds: 2)).then((value) => setState(() {
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
              const CustomAlertDialog()
                  .errorDialog('Your subscription has been canceled', context);
            }
          });
        }));
  }

  void _getIsUserSubscriptionLoad(BuildContext context) {
    setState(() {
      if (subscriptionDetail['subscription_status'] == "trialing") {
        SharedPrefs().setIsFreeTrail(true);
        SharedPrefs().setIsSubscription(false);
      } else if (subscriptionDetail['subscription_status'] == "active") {
        SharedPrefs().setIsSubscription(true);
        SharedPrefs().setIsFreeTrail(false);
      } else if (subscriptionDetail['subscription_status'] == "canceled") {
        SharedPrefs().setIsSubscription(false);
        SharedPrefs().setIsFreeTrail(false);
      }

      SharedPrefs().setUserSubscriptionId(
          subscriptionDetail['subscription_id'].toString());
      SharedPrefs().setUserPlanId(subscriptionDetail['product_id'].toString());
      SharedPrefs().setIsSubscriptionStatus(subscriptionDetail['status']);
    });
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
          SharedPrefs().setIsFreeTrail(false);
          isSubscriptionActive = SharedPrefs().isSubscription();
        });
      } else if (subscriptionDetail['subscription_status'] == "canceled") {
        setState(() {
          SharedPrefs().setIsFreeTrail(false);
          SharedPrefs().setIsSubscription(false);
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

  void _getEditMyAccount() async {
    editMyAccountData = await ApiService().getEditAccount(
      _nameText.text.toString(),
      _passwordText.text.toString(),
      context,
    );

    Future.delayed(const Duration(seconds: 2)).then((value) =>
        setState(() async {
          setState(() {
            if (editMyAccountData['http_code'] != 200) {
            } else {
              editMyAccountUserDetail = editMyAccountData['data']['user'];

              _nameText.text = editMyAccountUserDetail['name'];
              _emailText.text = editMyAccountUserDetail['email'];
              _passwordText.text = "";

              SharedPrefs().removeUserFullName();
              SharedPrefs().removeUserEmail();
              if (kDebugMode) {
                print("size ----${editMyAccountUserDetail['name']}");
              }
              if (kDebugMode) {
                print("size ----${editMyAccountUserDetail['email']}");
              }
              setState(() {
                isChanges = true;
                name = SharedPrefs().getUserFullName().toString().capitalize();
                SharedPrefs().setUserFullName(editMyAccountUserDetail['name']);
                SharedPrefs().setUserEmail(editMyAccountUserDetail['email']);
              });
            }
            if (kDebugMode) {
              print("size ----${editMyAccountUserDetail.length}");
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
            if (constraints.maxWidth < 757) {
              if (constraints.maxWidth < 300) {
                titleTextSize = 14;
              } else if (constraints.maxWidth < 400) {
                titleTextSize = 14;
              } else if (constraints.maxWidth < 500) {
                titleTextSize = 15;
              } else if (constraints.maxWidth < 600) {
                titleTextSize = 16;
              } else if (constraints.maxWidth < 700) {
                titleTextSize = 16;
              }
            }
            return buildHomeContainer(context, mq);
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
          children: <Widget>[
            /* Image.asset(
                'assets/images/ic_bg_dark_blue.png',
                fit: BoxFit.cover,
                height: double.infinity,
                width: double.infinity,
                alignment: Alignment.center,
              ),*/
            const BottomBarStateFull(screen: "account", isUserLogin: true),
            Container(
              margin: const EdgeInsets.only(bottom: 70, top: 10),
              child: ListView(
                shrinkWrap: false,
                primary: true,
                children: [
                  buildTopBarContainer(context, mq),
                  screenCName == "setting"
                      ? buildAccountDetailContainer(context)
                      : const SizedBox(),
                  screenCName == "credits"
                      ? Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                              Container(
                                margin:
                                    const EdgeInsets.only(top: 80, left: 15),
                                alignment: Alignment.center,
                                child: const TextFieldWidget(
                                  text: 'Coming Soon',
                                  size: 16,
                                  color: Colors.white,
                                  weight: FontWeight.w400,
                                ),
                              )
                            ])
                      : const SizedBox(),
                  screenCName == "subscription"
                      ? Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                              buildOptionsSubscriptionContainer(context, mq),
                              /* ],
                              ),*/
                              /*  Row(
                                children: [*/
                              //buildFreeSubscriptionContainer(context, mq),
                              Container(
                                alignment: Alignment.topCenter,
                                margin:
                                    const EdgeInsets.only(right: 5, left: 25),
                                child: buildSubscriptionContainer(context, mq),
                              ),
                              isSubscriptionStatusActive != "canceled" ||
                                      isSubscriptionActive
                                  ? Container(
                                      margin: const EdgeInsets.only(
                                          top: 30,
                                          left: 25,
                                          right: 25,
                                          bottom: 20),
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
                            ])
                      : const SizedBox(),
                  screenCName == "notifications"
                      ? Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                              Container(
                                margin:
                                    const EdgeInsets.only(top: 80, left: 15),
                                alignment: Alignment.center,
                                child: const TextFieldWidget(
                                  text: 'Coming Soon',
                                  size: 16,
                                  color: Colors.white,
                                  weight: FontWeight.w400,
                                ),
                              )
                            ])
                      : const SizedBox(),
                  screenCName == "gifts"
                      ? Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                              Container(
                                margin:
                                    const EdgeInsets.only(top: 80, left: 15),
                                alignment: Alignment.center,
                                child: const TextFieldWidget(
                                  text: 'Coming Soon',
                                  size: 16,
                                  color: Colors.white,
                                  weight: FontWeight.w400,
                                ),
                              )
                            ])
                      : const SizedBox(),
                  screenCName == "supports"
                      ? Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                              buildYouMessageContainer(context, mq),
                              Container(
                                  margin: const EdgeInsets.only(
                                      left: 15, right: 15),
                                  child: SupportWidget(
                                    supportDescriptionText:
                                        _supportDescriptionText,
                                  )),
                              Container(
                                  margin: const EdgeInsets.only(
                                      top: 25, left: 20, right: 20),
                                  alignment: Alignment.topRight,
                                  child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Container(
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
                            ])
                      : const SizedBox(),
                  screenCName == "payment"
                      ? Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                              PaymentCardsWidget(
                                mq: mq,
                                cardList: cardsList,
                                cardNoText: _cardNoText,
                                expiryDateText: _expiryDateText,
                                cvvText: _cvvText,
                                nameText: _nameOnCardText,
                                expiryYearText: expiryYearText,
                                size: 0.9,
                                sizeScreen: 0.98,
                                onAddTap: () {
                                  _handleOnAddCardInStripeButton();
                                },
                                onEditTap: _handleOnEditCard,
                                onDelete: deleteCardAlert,
                                cardSize: 0.9,
                                nameFocus: _nameCFocus,
                                cvvFocus: _cvvFocus,
                                expiryMonthFocus: _expiryFocus,
                                expiryYearFocus: _expiryYearFocus,
                                cardFocus: _cardFocus,
                                padding: 20,
                                margin: 0,
                                detailPadding: 30,
                                titleSize: 20,
                                cardTextSize: titleTextSize,
                              )
                            ])
                      : const SizedBox(),
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
        margin: const EdgeInsets.only(top: 20, bottom: 10, left: 15),
        child: const TextFieldWidget500(
          text: 'Your message',
          size: 20,
          color: Colors.white,
          textAlign: TextAlign.left,
        ));
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

  Widget buildOptionsSubscriptionContainer(BuildContext context, Size mq) {
    return Container(
        margin: const EdgeInsets.only(left: 25, top: 25),
        alignment: Alignment.topLeft,
        child: const TextFieldWidget500(
          text: 'Options to Upgrade',
          size: 20,
          color: Colors.white,
          textAlign: TextAlign.left,
        ));
  }

  Widget buildSubscriptionContainer(BuildContext context, Size mq) {
    return (subscriptionList.isNotEmpty)
        ? ListView.builder(
            shrinkWrap: true,
            reverse: true,
            primary: false,
            itemCount: subscriptionList.length,
            itemBuilder: (BuildContext context, int index) {
              return SubscriptionWidget(
                subscription: subscriptionList[index],
                subscriptionPriceList: subscriptionPriceList[index],
                index: index,
                onTap: () => planIndex == index
                    ? toast(
                        "You have already this plan , Please choose another one",
                        false)
                    : _handleOnTapOnSubscription(
                        subscriptionList[index], subscriptionPriceList[index]),
                currentPlan: planIndex == index,
                width: mq.width,
                radius: 30,
              );
            })
        : Container(
            alignment: Alignment.topCenter,
            margin: const EdgeInsets.only(top: 20),
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
                              screenCName = "setting";
                            })
                          },
                      child: Container(
                          margin: const EdgeInsets.only(right: 30),
                          child: TextFieldWidget500(
                              text: 'Settings',
                              size: 16,
                              color: screenCName == "setting"
                                  ? accent
                                  : Colors.white,
                              textAlign: TextAlign.center)))),
              MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                      onTap: () => {
                            setState(() {
                              screenCName = "subscription";
                            })
                          },
                      child: Container(
                          margin: const EdgeInsets.only(right: 30),
                          child: TextFieldWidget500(
                              text: 'Subscription',
                              size: 16,
                              color: screenCName == "subscription"
                                  ? accent
                                  : Colors.white,
                              textAlign: TextAlign.center)))),
              MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                      onTap: () => {
                            setState(() {
                              screenCName = "payment";
                            })
                          },
                      child: Container(
                          margin: const EdgeInsets.only(right: 30),
                          child: TextFieldWidget500(
                              text: 'Payment card',
                              size: 16,
                              color: screenCName == "payment"
                                  ? accent
                                  : Colors.white,
                              textAlign: TextAlign.center)))),
              MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                      onTap: () => {
                            setState(() {
                              screenCName = "credits";
                            })
                          },
                      child: Container(
                          margin: const EdgeInsets.only(right: 30),
                          child: TextFieldWidget500(
                              text: 'Credits',
                              size: 16,
                              color: screenCName == "credits"
                                  ? accent
                                  : Colors.white,
                              textAlign: TextAlign.center)))),
              MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                      onTap: () => {
                            setState(() {
                              screenCName = "gifts";
                            })
                          },
                      child: Container(
                          margin: const EdgeInsets.only(right: 30),
                          child: TextFieldWidget500(
                              text: 'Gift',
                              size: 16,
                              color: screenCName == "gifts"
                                  ? accent
                                  : Colors.white,
                              textAlign: TextAlign.center)))),
              MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                      onTap: () => {
                            setState(() {
                              screenCName = "notifications";
                            })
                          },
                      child: Container(
                          margin: const EdgeInsets.only(right: 30),
                          child: TextFieldWidget500(
                              text: 'Notifications',
                              size: 16,
                              color: screenCName == "notifications"
                                  ? accent
                                  : Colors.white,
                              textAlign: TextAlign.center)))),
              MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                      onTap: () => {
                            setState(() {
                              screenCName = "supports";
                            })
                          },
                      child: Container(
                          margin: const EdgeInsets.only(right: 30),
                          child: TextFieldWidget500(
                              text: 'Support',
                              size: 16,
                              color: screenCName == "supports"
                                  ? accent
                                  : Colors.white,
                              textAlign: TextAlign.center)))),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildAccountDetailContainer(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.only(
            left: 15,
            top: 24,
          ),
          child: const Align(
            alignment: Alignment.topLeft,
            child: Text(
              'Your account settings',
              style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontFamily: 'DPClear',
                  fontWeight: FontWeight.w500),
            ),
          ),
        ),
        Column(
          children: [
            Container(
              padding: const EdgeInsets.only(left: 15, top: 10, right: 15),
              child: const Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'Update your Success Subliminal account info',
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.white54,
                      fontFamily: 'DPClear',
                      fontWeight: FontWeight.w400),
                ),
              ),
            ),
          ],
        ),
        Container(
          alignment: Alignment.topLeft,
          margin: const EdgeInsets.only(left: 20, right: 15, top: 24),
          child: const Text(
            'Name',
            style: TextStyle(
                color: Colors.white,
                fontFamily: 'DPClear',
                fontWeight: FontWeight.w500,
                fontSize: 16),
          ),
        ),
        Container(
          height: 50,
          margin: const EdgeInsets.only(left: 15, right: 15, top: 5),
          decoration: !isNameFocused
              ? kEditTextDecoration
              : kEditTextWithBorderDecoration,
          child: Row(
            children: [
              Expanded(
                flex: 7,
                child: TextFormField(
                  enabled: isNameFocused,
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'DPClear',
                    fontWeight: FontWeight.w600,
                    color: !isNameFocused ? Colors.white54 : Colors.white,
                  ),
                  controller: _nameText,
                  keyboardType: TextInputType.text,
                  enableSuggestions: false,
                  textAlign: TextAlign.left,
                  onEditingComplete: () => FocusScope.of(context).nextFocus(),
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    counterText: '',
                    hintStyle: TextStyle(
                        fontSize: 14.0,
                        color: Colors.white54,
                        fontFamily: 'DPClear'),
                    hintText: kEnterName,
                    contentPadding: EdgeInsets.only(left: 20, right: 20),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: GestureDetector(
                  onTap: () => {
                    setState(() {
                      if (isNameFocused) {
                        isNameFocused = false;
                      } else {
                        isNameFocused = true;
                      }
                    })
                  },
                  child: Container(
                      margin:
                          const EdgeInsets.only(right: 5, top: 5, bottom: 5),
                      height: 45,
                      decoration: !isNameFocused
                          ? kTransButtonBoxDecoration
                          : kAccentButtonBoxDecoration,
                      alignment: Alignment.topRight,
                      child: buildEditIcon(context)),
                ),
              ),
            ],
          ),
        ),
        Container(
          alignment: Alignment.topLeft,
          margin: const EdgeInsets.only(left: 20, right: 15, top: 15),
          child: const Text(
            'Email',
            style: TextStyle(
                color: Colors.white,
                fontFamily: 'DPClear',
                fontWeight: FontWeight.w500,
                fontSize: 16),
          ),
        ),
        Container(
          height: 50,
          margin: const EdgeInsets.only(left: 15, right: 15, top: 5),
          decoration: !isEmailFocused
              ? kEditTextDecoration
              : kEditTextWithBorderDecoration,
          child: Row(
            children: [
              Expanded(
                flex: 7,
                child: TextFormField(
                  enabled: isEmailFocused,
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'DPClear',
                    fontWeight: FontWeight.w600,
                    color: !isEmailFocused ? Colors.white54 : Colors.white,
                  ),
                  controller: _emailText,
                  keyboardType: TextInputType.emailAddress,
                  enableSuggestions: false,
                  textAlign: TextAlign.left,
                  onEditingComplete: () => FocusScope.of(context).nextFocus(),
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    counterText: '',
                    hintStyle: TextStyle(
                        fontSize: 14.0,
                        color: Colors.white54,
                        fontFamily: 'DPClear'),
                    hintText: kEnterEmail,
                    contentPadding: EdgeInsets.only(left: 20, right: 20),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: GestureDetector(
                  onTap: () => {
                    setState(() {
                      if (isEmailFocused) {
                        isEmailFocused = false;
                        toast("You can't change the email", true);
                      } else {
                        isEmailFocused = false;
                        toast("You can't change the email", true);
                      }
                    })
                  },
                  child: Container(
                      margin:
                          const EdgeInsets.only(right: 5, top: 5, bottom: 5),
                      height: 45,
                      decoration: !isEmailFocused
                          ? kTransButtonBoxDecoration
                          : kAccentButtonBoxDecoration,
                      alignment: Alignment.topRight,
                      child: buildEditIcon(context)),
                ),
              ),
            ],
          ),
        ),
        Container(
          alignment: Alignment.topLeft,
          margin: const EdgeInsets.only(left: 20, right: 15, top: 15),
          child: const Text(
            'Password',
            style: TextStyle(
                color: Colors.white,
                fontFamily: 'DPClear',
                fontWeight: FontWeight.w500,
                fontSize: 16),
          ),
        ),
        Container(
          height: 50,
          margin: const EdgeInsets.only(left: 15, right: 15, top: 5),
          decoration: isPasswordFocused
              ? kEditTextWithBorderDecoration
              : kEditTextDecoration,
          child: Row(
            children: [
              Expanded(
                flex: 7,
                child: TextFormField(
                  enabled: isPasswordFocused,
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'DPClear',
                    fontWeight: FontWeight.w600,
                    color: !isPasswordFocused ? Colors.white54 : Colors.white,
                  ),
                  controller: _passwordText,
                  keyboardType: TextInputType.visiblePassword,
                  enableSuggestions: false,
                  textAlign: TextAlign.left,
                  onEditingComplete: () => FocusScope.of(context).nextFocus(),
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    counterText: '',
                    hintStyle: TextStyle(
                        fontSize: 14.0,
                        color: Colors.white54,
                        fontFamily: 'DPClear'),
                    hintText: kEnterPassword,
                    contentPadding: EdgeInsets.only(left: 20, right: 20),
                  ),
                ),
              ),
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
                      margin:
                          const EdgeInsets.only(right: 5, top: 5, bottom: 5),
                      height: 45,
                      decoration: isPasswordFocused
                          ? kAccentButtonBoxDecoration
                          : kTransButtonBoxDecoration,
                      alignment: Alignment.topRight,
                      child: buildEditIcon(context)),
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.only(left: 25, top: 5),
          child: const Align(
            alignment: Alignment.topLeft,
            child: Text(
              'Passwords must be at least 6 characters',
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.white54,
                  fontFamily: 'DPClear',
                  fontWeight: FontWeight.w400),
            ),
          ),
        ),
        Visibility(
          visible: isChanges,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 20, left: 20),
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
                margin: const EdgeInsets.only(top: 20, left: 5),
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
          margin: const EdgeInsets.only(top: 50, left: 15, right: 15),
          child: ButtonWidget400(
              buttonSize: 50,
              name: 'save all changes'.toUpperCase(),
              icon: 'assets/images/ic_tick_circle.png',
              visibility: true,
              padding: 10,
              onTap: _handleOnSaveAllChanges,
              size: 14,
              deco: kButtonBox10Decoration),
        ),
        /*   Container(
          margin: const EdgeInsets.only(top: 50, left: 15, right: 15),
          child: ButtonWidget400(
              buttonSize: 50,
              name: 'Logout'.toUpperCase(),
              icon: 'assets/images/ic_download.png',
              visibility: true,
              padding: 10,
              onTap: _handleOnLogout,
              size: 14,
              deco: kLogoutButtonBox10Decoration),
        ),*/
        ConstrainedBox(
            constraints: const BoxConstraints(minWidth: double.infinity),
            child: Container(
              margin: const EdgeInsets.only(
                  top: 30, bottom: 30, left: 15, right: 15),
              height: 50,
              child: ElevatedButton(
                onPressed: () {
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
                  SharedPrefs().setUserPlanName("");
                  SharedPrefs().removeUserPlanId();
                  SharedPrefs().reset();
                  if (player.playing) {
                    player.stop();
                  }
                  // Navigator.of(context, rootNavigator: true).pop();
                  context.go(Routes.home);

                  //dialog(context);
                },
                style: ElevatedButton.styleFrom(
                  primary: kBaseColor3,
                  onPrimary: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15), // <-- Radius
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 10),
                      child: Align(
                        alignment: Alignment.center,
                        child: Image.asset('assets/images/ic_download.png',
                            scale: 2.5),
                      ),
                    ),
                    Text('Logout'.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 15,
                          fontFamily: 'DPClear',
                          fontWeight: FontWeight.w600,
                        )),
                  ],
                ),
              ),
            )),
        Container(
            margin: const EdgeInsets.only(bottom: 30, left: 15, right: 15),
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
    );
  }

  Widget buildEditIcon(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Image.asset('assets/images/ic_edit_pencil.png', scale: 2),
    );
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
}
