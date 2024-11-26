import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:success_subliminal/pages/web_pages/subscription_payment_web_page.dart';
import 'package:success_subliminal/utils/toast.dart';
import 'package:success_subliminal/widget/SettingCardInfoWidget.dart';

import '../app/router.dart';
import '../data/api/ApiService.dart';
import '../utils/center_loader.dart';
import '../utils/constant.dart';
import '../utils/shared_prefs.dart';
import '../widget/ButtonWidget400.dart';
import '../widget/TextFieldWidget400.dart';
import '../widget/TextFieldWidget500.dart';
import 'create_subliminal_page.dart';

class SubscriptionPaymentPage extends StatefulWidget {
  final String amount;
  final String subscriptionId;
  final String planType;
  final String screen;

  const SubscriptionPaymentPage({Key? key,
    required this.amount,
    required this.subscriptionId,
    required this.planType,
    required this.screen})
      : super(key: key);

  @override
  SubscriptionPaymentScreen createState() => SubscriptionPaymentScreen();
}

class SubscriptionPaymentScreen extends State<SubscriptionPaymentPage> {
/*  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();*/
  bool isLogin = false;
  late dynamic subscription;
  late dynamic conversionSubscription;
  late dynamic conversionAddPayment;
  late dynamic trialWithCard;
  late dynamic subscriptionDetail;
  late dynamic stripeTokenResponse;
  int selectIndex = 0;
  final _cardNoText = TextEditingController();
  final _expiryDateText = TextEditingController();
  final expiryYearText = TextEditingController();
  final _cvvText = TextEditingController();
  final _nameText = TextEditingController();
  bool isNameFocus = false;
  bool isCardNoFocus = false;
  bool isExpMonthFocus = false;
  bool isCVVFocus = false;
  bool isFreeTrialUsed = false;
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _cardFocus = FocusNode();
  final FocusNode _expiryFocus = FocusNode();
  final FocusNode _expiryYearFocus = FocusNode();
  final FocusNode _cvvFocus = FocusNode();
  String buttonName = "";
  String hostedInvoiceUrl = "";
  late dynamic paymentMethod;
  late dynamic addPaymentMethod;

  List<dynamic> cardsList = [];
  late dynamic listPaymentMethod;
  late dynamic usedFreeTrial;
  bool isCards = true;
  bool isAddAnotherCard = false;
  int isSelectCardIndex = -1;
  String pmID = "";
  String token = "";

  bool isTrial = false;
  bool isSubscriptionActive = false;

  @override
  void initState() {
    super.initState();

    initializePreference().whenComplete(() {
      setState(() {
        isLogin = SharedPrefs().isLogin();
        isFreeTrialUsed = SharedPrefs().isFreeTrailUsed();
        isTrial = SharedPrefs().isFreeTrail();
        isSubscriptionActive = SharedPrefs().isSubscription();
        /*   Stripe.publishableKey = kPublishableStripeLiveKey;
        Stripe.merchantIdentifier = 'Success Subliminals';
        Stripe.instance.applySettings();*/

      });
    });

    setState(() {
      if (widget.screen != 'trial') {
        buttonName = "Make Payment".toUpperCase();
      } else {
        buttonName = 'Start 7-day Free Trial'.toUpperCase();
      }
    });
    _getListPaymentMethodData(SharedPrefs().getStripeCustomerId().toString());
    _nameFocus.addListener(() {
      if (_nameFocus.hasFocus) {
        setState(() {
          isNameFocus = true;
          isCardNoFocus = false;
          isExpMonthFocus = false;
          isCVVFocus = false;
        });
      }
    });

    _cardFocus.addListener(() {
      if (_cardFocus.hasFocus) {
        setState(() {
          isNameFocus = false;
          isCardNoFocus = true;
          isExpMonthFocus = false;
          isCVVFocus = false;
        });
      }
    });

    _expiryFocus.addListener(() {
      if (_expiryFocus.hasFocus) {
        setState(() {
          isNameFocus = false;
          isCardNoFocus = false;
          isExpMonthFocus = true;
          isCVVFocus = false;
        });
      }
    });

    _cvvFocus.addListener(() {
      if (_cvvFocus.hasFocus) {
        setState(() {
          isNameFocus = false;
          isCardNoFocus = false;
          isExpMonthFocus = false;
          isCVVFocus = true;
        });
      }
    });
  }

  _handleOnPayWithStripeSavedCardButton(Size mq, BuildContext context,
      String pmId) {
    setState(() {
      if (pmID == "") {
        toast(kValidSelectCardError, true);
      } else {
        showCenterLoader(context);
        if (isTrial && !isSubscriptionActive) {
          _getActivatePlanFromTrialData(pmId, token, context, mq);
        } else {
          _getStripeSavedCardPaymentData(context, mq, pmId);
        }
      }
    });
  }

  void _getActivatePlanFromTrialData(String pmId, String token,
      BuildContext context, Size mq) async {
    subscription = await ApiService().getStripeActivatePlan(
        widget.subscriptionId,
        SharedPrefs().getStripeCustomerId().toString(),
        pmId,
        token,
        context);
    /* subscription = await ApiService().getStripeActivatePlanTest(
        widget.subscriptionId,
        SharedPrefs().getStripeCustomerId().toString(),
        pmId,
        token,
        context);*/

    Future.delayed(const Duration(seconds: 2)).then((value) =>
        setState(() {
          setState(() {
            if (subscription['http_code'] != 200) {} else {
              subscription = subscription['data']['subscription'];
              if (subscription != null) {
                /* Navigator.of(context, rootNavigator: true).pop();
                initPaymentSheet(
                    subscription['latest_invoice']['payment_intent']);

                hostedInvoiceUrl =
                    subscription['latest_invoice']['hosted_invoice_url'];
                if (kDebugMode) {
                  print(subscription['latest_invoice']);
                }
                if (kDebugMode) {
                  print(hostedInvoiceUrl);
                }*/
                _getStripeSubscriptionDetail(context, mq);

                trackSubscription(double.parse(widget.amount));

                // buildCollectionDialogContainer(context);
              }
            }
          });
        }));
  }

  void _getStripeSavedCardPaymentData(BuildContext context, Size mq,
      String pmId) async {
    subscription = await ApiService().getStripePaymentWithSavedCards(
        widget.subscriptionId,
        SharedPrefs().getStripeCustomerId().toString(),
        pmId,
        context);

    Future.delayed(const Duration(seconds: 1)).then((value) =>
        setState(() {
          setState(() {
            if (subscription['http_code'] != 200) {} else {
              subscription = subscription['data']['subscription'];
              if (subscription != null) {
                _getStripeSubscriptionDetail(context, mq);

                trackSubscription(double.parse(widget.amount));

                // buildCollectionDialogContainer(context);
              }
            }
          });
        }));
  }

  _handleOnPayWithStripeButton(Size mq, BuildContext context) {
    setState(() {
      if (isValidCardDetailInSetting(
        _nameText.text.toString(),
        _cardNoText.text.toString(),
        _expiryDateText.text.toString(),
        expiryYearText.text.toString(),
        _cvvText.text.toString(),
      )) {
        showCenterLoader(context);

        _getStripeTokenData(
            _cardNoText.text,
            _expiryDateText.text,
            expiryYearText.text,
            _cvvText.text,
            _nameText.text,
            context,
            mq);
      } else {}
    });
  }

  Future<dynamic> initPaymentSheet(dynamic data) async {
    try {
      if (kDebugMode) {
        print(data['client_secret']);
        print(data['customer']);
      }
      // 2. initialize the payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          // Enable custom flow
          customFlow: false,
          // Main params
          merchantDisplayName: 'Success Subliminals',
          paymentIntentClientSecret: data['client_secret'],
          customerId: data['customer'],
          allowsDelayedPaymentMethods: true,
          // Extra options
          style: ThemeMode.light,
        ),
      );

      await Stripe.instance.presentPaymentSheet();
      //await Stripe.instance.confirmPaymentSheetPayment();
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      rethrow;
    }
  }

  void expDateTextListener() {
    _expiryDateText.addListener(() {
      if (kDebugMode) {
        print("value: ${_expiryDateText.text}");
      }

      String text = _expiryDateText.text;
      if (text.length == 5) {
        FocusScope.of(context).nextFocus();
      }
    });
  }

  void _getStripePaymentData(String token, BuildContext context,
      Size mq) async {
    subscription = await ApiService().getStripePayment(widget.subscriptionId,
        SharedPrefs().getUserEmail().toString(), token, context);

    Future.delayed(const Duration(seconds: 1))
        .then((value) =>
        setState(() async {
          setState(() {
            if (subscription['http_code'] != 200) {} else {
              subscription = subscription['data']['subscription'];
              if (subscription != null) {
                trackSubscription(double.parse(widget.amount));

                _getStripeSubscriptionDetail(context, mq);
              }
            }
          });
        }));
  }

  void _getListPaymentMethodData(String customerId) async {
    listPaymentMethod =
    await ApiService().getStripePaymentMethodList(customerId, context);

    Future.delayed(const Duration(seconds: 2)).then((value) =>
        setState(() {
          setState(() {
            isCards = false;
            if (listPaymentMethod == null) {
              toast(listPaymentMethod['error']['message'], true);
            } else {
              setState(() {
                cardsList = listPaymentMethod['data'];
              });
            }

            setState(() {
              isCards = false;
              cardsList.isEmpty ? isAddAnotherCard = true : isAddAnotherCard;
            });

            if (kDebugMode) {
              print(cardsList);
            }
          });
        }));
  }

  void _getTrialStripeData(String token, BuildContext context) async {
    trialWithCard = await ApiService().getTrialWithCard(
        widget.subscriptionId,
        SharedPrefs().getUserEmail().toString(),
        token,
        _nameText.text,
        context);

    Future.delayed(const Duration(seconds: 1)).then((value) =>
        setState(() {
          setState(() {
            if (trialWithCard['http_code'] != 200) {} else {
              subscriptionDetail = trialWithCard['data']['subscription'];
              if (kDebugMode) {
                print(subscriptionDetail);
              }

              if (subscriptionDetail != null) {
                _getIsUserSubscription(context);
              }
            }
          });
        }));
  }

  void _getStripeTokenData(String cardNo, String expMonth, String expYear,
      String cvv, String name, BuildContext context, Size mq) async {
    stripeTokenResponse = await ApiService()
        .getCreateToken(cardNo, expMonth, expYear, cvv, context);

    Future.delayed(const Duration(seconds: 1)).then((value) =>
        setState(() {
          setState(() {
            if (stripeTokenResponse.containsKey('error')) {
              Navigator.of(context, rootNavigator: true).pop();
              if (stripeTokenResponse['error']['code'] ==
                  'invalid_expiry_month') {
                toast("Please enter correct expiry date", true);
              } else if (stripeTokenResponse['error']['code'] ==
                  'invalid_expiry_year') {
                toast("Please enter correct expiry date", true);
              } else if (stripeTokenResponse['error']['code'] ==
                  'invalid_cvc') {
                toast("Please enter correct card cvv", true);
              } else if (stripeTokenResponse['error']['code'] ==
                  'incorrect_number') {
                toast("Please enter correct card number", true);
              } else if (stripeTokenResponse['error']['code'] ==
                  'card_declined') {
                toast("Your Card is  invalid, Please enter valid card detail",
                    true);
              } else {
                toast("Please enter valid card detail", true);
              }
            } else {
              setState(() {
                stripeTokenResponse = stripeTokenResponse;
                if (stripeTokenResponse != null) {
                  if (widget.screen == 'trial') {
                    _getTrialStripeData(
                        stripeTokenResponse['id'].toString(), context);
                  } else {
                    if (isTrial && !isSubscriptionActive) {
                      _getActivatePlanFromTrialData("",
                          stripeTokenResponse['id'].toString(), context, mq);
                    } else {
                      /* _getActivatePlanFromTrialData("",
                          stripeTokenResponse['id'].toString(), context, mq);*/
                      _getStripePaymentData(
                          stripeTokenResponse['id'].toString(), context, mq);
                    }
                  }
                }
              });
            }
          });
        }));
  }

  void _getStripeSubscriptionDetail(BuildContext context, Size mq) async {
    subscriptionDetail = await ApiService().getSubscriptionDetail(context);

    Future.delayed(const Duration(seconds: 2)).then((value) =>
        setState(() {
          setState(() {
            if (subscriptionDetail['http_code'] != 200) {} else {
              subscriptionDetail = subscriptionDetail['data']
              ['current_user_subscription_status'];

              _getIsUserSubscription(context);
            }
          });
        }));
  }

  void _getIsUserSubscription(BuildContext context) {
    setState(() {
      if (subscriptionDetail['subscription_status'] == "trialing") {
        SharedPrefs().setIsFreeTrail(true);
        SharedPrefs().setIsSubscription(false);
        SharedPrefs().setIsFreeTrailUsed(false);
      } else if (subscriptionDetail['subscription_status'] == "active") {
        SharedPrefs().setIsSubscription(true);
        SharedPrefs().setIsFreeTrail(false);
        SharedPrefs().setIsFreeTrailUsed(true);
      }
      if (widget.screen != 'trial') {
        SharedPrefs().setUserSubscriptionId(
            subscriptionDetail['subscription_id'].toString());
        SharedPrefs()
            .setUserPlanId(subscriptionDetail['product_id'].toString());
        SharedPrefs().setIsSubscriptionStatus(subscriptionDetail['status']);
      } else {
        SharedPrefs().setIsSubscriptionStatus('trailing');
        SharedPrefs()
            .setUserPlanId(subscriptionDetail['plan']['product'].toString());
      }

      Future.delayed(const Duration(seconds: 4))
          .then((value) =>
          setState(() async {
            setState(() {
              Navigator.of(context, rootNavigator: true).pop();
              context.pushReplacement(Routes.create);
            });
          }));

      if (widget.screen != 'trial') {
        toast("Subscription upgrade successfully!", true);
      } else {
        toast("Your 7 day trial start successfully!", true);
      }
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
              return SubscriptionPaymentWebPage(
                amount: widget.amount,
                subscriptionId: widget.subscriptionId,
                planType: widget.planType,
                screen: widget.screen,
              );
            }
          },
        )
      //),
    );
  }

  Widget buildHomeContainer(BuildContext context, Size mq) {
    return SafeArea(
      // child: SingleChildScrollView(
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
        child: ListView(
          shrinkWrap: false,
          primary: false,
          children: [
            buildTopBarContainer(context, mq),
            buildSubscriptionListContainer(context, mq)

            /* Container(
                margin: const EdgeInsets.all(15),
                child: CardInfoWidget(
                  isNameFocus: isNameFocus,
                  isCardNoFocus: isCardNoFocus,
                  isExpMonthFocus: isExpMonthFocus,
                  isCVVFocus: isCVVFocus,
                  cardNoText: _cardNoText,
                  expiryDateText: _expiryDateText,
                  cvvText: _cvvText,
                  nameText: _nameText,
                  nameFocus: _nameFocus,
                  cardFocus: _cardFocus,
                  expiryFocus: _expiryFocus,
                  cvvFocus: _cvvFocus,
                ) */ /*buildCardDetailContainer(context),*/ /*
            ),
            buildButton(context)*/
          ],
        ),
      ),
    );
  }

  Widget buildSubscriptionListContainer(BuildContext context, Size mq) {
    return Container(
      padding: const EdgeInsets.only(right: 20, top: 10, bottom: 70),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
              margin: const EdgeInsets.only(top: 20, left: 20, right: 20),
              alignment: Alignment.topLeft,
              child: const Align(
                alignment: Alignment.topLeft,
                child: Text(
                  "Payment",
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontFamily: 'DPClear',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )),
          Container(
            margin: const EdgeInsets.only(top: 10, left: 20, right: 20),
            alignment: Alignment.topLeft,
            child: const Align(
              alignment: Alignment.topLeft,
              child: Text(
                "You will get charged after the 7-day free trial ends, not before.You can cancel anytime.",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white54,
                  fontFamily: 'DPClear',
                  fontWeight: FontWeight.w400,
                ),
                softWrap: true,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 10, left: 20, right: 20),
            alignment: Alignment.topLeft,
            child: Align(
                alignment: Alignment.topLeft,
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: "Total Price: ",
                    style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontFamily: 'DPClear',
                        fontWeight: FontWeight.w500),
                    /*defining default style is optional */
                    children: <TextSpan>[
                      TextSpan(
                          text:
                          "\$${planAmountFeatures(
                              widget.planType, widget.amount).toString()}",
                          style: const TextStyle(
                              fontSize: 22,
                              color: Colors.white,
                              fontFamily: 'DPClear',
                              fontWeight: FontWeight.w600)),
                      TextSpan(
                          text: "/${widget.planType}",
                          style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white54,
                              fontFamily: 'DPClear',
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                )),
          ),
          cardsList.isNotEmpty
              ? Container(
              margin: const EdgeInsets.only(left: 20),
              child: selectSavedCardContainer(context, mq))
              : const SizedBox(),
          !isCards
              ? Visibility(
            visible: isAddAnotherCard,
            child: Container(
              margin: const EdgeInsets.all(15),
              child: SettingCardInfoWidget(
                cardNoText: _cardNoText,
                cvvText: _cvvText,
                nameText: _nameText,
                expiryMonthText: _expiryDateText,
                expiryYearText: expiryYearText,
                onTap: () => _handleOnPayWithStripeButton(mq, context),
                buttonName: buttonName.toUpperCase(),
                screen: 'subscription',
                type: 'add',
                nameFocus: _nameFocus,
                cvvFocus: _cvvFocus,
                expiryMonthFocus: _expiryFocus,
                expiryYearFocus: _expiryYearFocus,
                cardFocus: _cardFocus,
              ),
            ),
          )
              : Container(
              margin: const EdgeInsets.only(top: 50),
              padding: const EdgeInsets.all(10),
              child: const CircularProgressIndicator()),
        ],
      ),
    );
  }

  Widget selectSavedCardContainer(BuildContext contexts, Size mq) {
    return Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
              margin: const EdgeInsets.only(top: 30, bottom: 10),
              alignment: Alignment.topLeft,
              child: const Align(
                alignment: Alignment.topLeft,
                child: TextFieldWidget500(
                    text: "Pay Using:",
                    size: 22,
                    color: Colors.white,
                    textAlign: TextAlign.center),
              )),
          Visibility(
            visible: !isAddAnotherCard,
            child: !isCards
                ? cardsList.isNotEmpty
                ? ListView.builder(
                shrinkWrap: true,
                itemCount: cardsList.length,
                itemBuilder: (BuildContext context, int index) {
                  return buildCardContainer(
                      context, cardsList[index], mq, index);
                })
                : const TextFieldWidget(
              text: 'No Cards',
              size: 14,
              color: Colors.white,
              weight: FontWeight.w400,
            )
                : Container(
                padding: const EdgeInsets.all(10),
                child: const CircularProgressIndicator()),
          ),
          Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Visibility(
                  visible: !isAddAnotherCard,
                  child: Container(
                    margin: const EdgeInsets.only(top: 20, right: 20),
                    decoration: kEditTextDecoration,
                    child: ButtonWidget400(
                        buttonSize: 50,
                        name: buttonName.toUpperCase(),
                        icon: '',
                        visibility: false,
                        padding: 30,
                        onTap: () =>
                        {
                          _handleOnPayWithStripeSavedCardButton(
                              mq, contexts, pmID)
                        },
                        size: 14,
                        deco: kButtonBox10Decoration),
                  ),
                ),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () =>
                    {
                      setState(() {
                        !isAddAnotherCard
                            ? isAddAnotherCard = true
                            : isAddAnotherCard = false;
                      })
                    },
                    child: Container(
                      height: 50,
                      padding: !isAddAnotherCard
                          ? const EdgeInsets.only(left: 20, right: 20)
                          : const EdgeInsets.only(left: 50, right: 50),
                      decoration: kButtonBox10Decoration,
                      alignment: Alignment.center,
                      margin: const EdgeInsets.only(
                        top: 20,
                      ),
                      child: TextFieldWidget(
                          text: !isAddAnotherCard
                              ? "Add card".toUpperCase()
                              : "Show cards".toUpperCase(),
                          size: 14,
                          weight: FontWeight.w400,
                          color: Colors.white),
                    ),
                  ),
                )
              ])
        ]);
  }

  Widget buildCardContainer(BuildContext context, dynamic cardItem, Size mq,
      int index) {
    return Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                  onTap: () =>
                  {
                    setState(() {
                      isSelectCardIndex = index;
                      pmID = cardItem['id'];
                      if (kDebugMode) {
                        print('pmID--$pmID');
                      }
                    })
                  },
                  child: Container(
                      decoration: isSelectCardIndex != index
                          ? kWhiteUnSelectBorderDecoration
                          : kWhiteSelectBorderDecoration,
                      padding: const EdgeInsets.only(
                          left: 20, right: 20, top: 20, bottom: 20),
                      margin: const EdgeInsets.only(top: 10),
                      child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  TextFieldWidget(
                                    text: cardItem['card']['brand'] != null
                                        ? cardItem['card']['brand'].toString()
                                        : "•••• ",
                                    size: 16,
                                    weight: FontWeight.w400,
                                    color: isSelectCardIndex != index
                                        ? Colors.white54
                                        : accent,
                                  ),
                                  TextFieldWidget(
                                    text: "--${cardItem['card']['last4']}  |  ",
                                    size: 16,
                                    weight: FontWeight.w400,
                                    color: isSelectCardIndex != index
                                        ? Colors.white54
                                        : accent,
                                  ),
                                  TextFieldWidget(
                                    text: cardItem['card']['exp_month']
                                        .toString()
                                        .length ==
                                        1
                                        ? "0${cardItem['card']['exp_month']}/${cardItem['card']['exp_year']}"
                                        : "${cardItem['card']['exp_month']}/${cardItem['card']['exp_year']}",
                                    size: 16,
                                    weight: FontWeight.w400,
                                    color: isSelectCardIndex != index
                                        ? Colors.white54
                                        : accent,
                                  ),
                                ]),
                            Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceAround,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(left: 10),
                                    child: TextFieldWidget(
                                      text: cardItem['billing_details']
                                      ['name'] !=
                                          null
                                          ? cardItem['billing_details']['name']
                                          .toString()
                                          : "User Name",
                                      size: 14,
                                      weight: FontWeight.w400,
                                      color: isSelectCardIndex != index
                                          ? Colors.white54
                                          : accent,
                                    ),
                                  ),
                                ])
                          ]))))
        ]);
  }

  Widget buildTopBarContainer(BuildContext context, Size mq) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        InkWell(
          onTap: () =>
          {
            setState(() {
              //context.pushReplacement(Routes.subscription);
              Navigator.pop(context);
              // toast("click", false);
            })
          },
          child: Container(
            padding: const EdgeInsets.only(left: 10, top: 10),
            child: Align(
              alignment: Alignment.topLeft,
              child: Image.asset('assets/images/ic_arrow_left.png', scale: 1.5),
            ),
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.only(top: 10, right: 40),
            child: const Align(
              alignment: Alignment.center,
              child: Text(
                "Subscription",
                maxLines: 2,
                style: TextStyle(
                    fontSize: 26,
                    color: Colors.white,
                    fontFamily: 'DPClear',
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildGoToButton(BuildContext context, BuildContext cont) {
    return ConstrainedBox(
        constraints: const BoxConstraints(minWidth: double.infinity),
        child: Container(
          decoration: kButtonBox10Decoration,
          margin: const EdgeInsets.only(top: 30, right: 25, left: 25),
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                Navigator.of(cont, rootNavigator: true).pop();
                _navigateToDiscoverScreen(cont);
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10), // <-- Radius
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Go To Dashboard'.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.white,
                      fontFamily: 'DPClear',
                      fontWeight: FontWeight.w600,
                    ))
              ],
            ),
          ),
        ));
  }

  Widget buildButton(BuildContext context, Size mq) {
    return ConstrainedBox(
        constraints: const BoxConstraints(minWidth: double.infinity),
        child: Container(
          decoration: kButtonBox10Decoration,
          margin: const EdgeInsets.only(top: 30, right: 25, left: 25),
          height: 50,
          child: ElevatedButton(
            onPressed: () async {
              setState(() {
                if (_nameText.text.isEmpty) {
                  toast(kValidNameOnCardError, true);
                } else if (_cardNoText.text.isEmpty) {
                  toast(kValidCardNoError, true);
                } else if (_cardNoText.text.length < 12) {
                  toast(kValidCardNoError, true);
                } else if (_expiryDateText.text.isEmpty) {
                  toast(kValidExpiryDateError, true);
                } else if (_expiryDateText.text.length < 5) {
                  toast(kValidExpiryDateError, true);
                } else if (_cvvText.text.isEmpty) {
                  toast(kValidCardCVVError, true);
                } else if (_cvvText.text.length < 3) {
                  toast(kValidCardCVVError, true);
                } else {
                  showCenterLoader(context);
                  String s = _expiryDateText.text;
                  int idx = s.indexOf("/");
                  List parts = [
                    s.substring(0, idx).trim(),
                    s.substring(idx + 1).trim()
                  ];
                  String expMonth = parts[0];
                  String expYear = parts[1];

                  _getStripeTokenData(
                      _cardNoText.text,
                      expMonth,
                      expYear,
                      _cvvText.text,
                      _nameText.text,
                      context,
                      mq);
                }
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10), // <-- Radius
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(buttonName,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.white,
                      fontFamily: 'DPClear',
                      fontWeight: FontWeight.w600,
                    ))
              ],
            ),
          ),
        ));
  }

  buildCollectionDialogContainer(BuildContext contexts) {
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
                padding: const EdgeInsets.all(20.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child:
                        Image.asset('assets/images/congrats.png', scale: 4),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 10, left: 25),
                        alignment: Alignment.topLeft,
                        child: Align(
                            alignment: Alignment.topLeft,
                            child: RichText(
                              textAlign: TextAlign.left,
                              text: TextSpan(
                                text: "Your Subscription ID :  ",
                                style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white54,
                                    fontFamily: 'DPClear',
                                    fontWeight: FontWeight.w500),
                                /*defining default style is optional */
                                children: <TextSpan>[
                                  TextSpan(
                                      text: subscription['id'],
                                      style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                          fontFamily: 'DPClear',
                                          fontWeight: FontWeight.w600)),
                                ],
                              ),
                            )),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 10, left: 25),
                        alignment: Alignment.topLeft,
                        child: Align(
                            alignment: Alignment.topLeft,
                            child: RichText(
                              textAlign: TextAlign.left,
                              text: TextSpan(
                                text: "Your Plan: ",
                                style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white54,
                                    fontFamily: 'DPClear',
                                    fontWeight: FontWeight.w500),
                                /*defining default style is optional */
                                children: <TextSpan>[
                                  TextSpan(
                                      text: " ${widget.planType}",
                                      style: const TextStyle(
                                          fontSize: 22,
                                          color: Colors.white,
                                          fontFamily: 'DPClear',
                                          fontWeight: FontWeight.w600)),
                                ],
                              ),
                            )),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 10, left: 25),
                        alignment: Alignment.topLeft,
                        child: Align(
                            alignment: Alignment.topLeft,
                            child: RichText(
                              textAlign: TextAlign.left,
                              text: TextSpan(
                                text: "You have total spent including tax: ",
                                style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white54,
                                    fontFamily: 'DPClear',
                                    fontWeight: FontWeight.w500),
                                /*defining default style is optional */
                                children: <TextSpan>[
                                  TextSpan(
                                      text:
                                      "\$${planAmountFeatures(
                                          widget.planType, widget.amount)
                                          .toString()}",
                                      style: const TextStyle(
                                          fontSize: 22,
                                          color: Colors.white,
                                          fontFamily: 'DPClear',
                                          fontWeight: FontWeight.w600)),
                                ],
                              ),
                            )),
                      ),
                      buildGoToButton(context, contexts)
                    ],
                  ),
                ),
              ));
        });
  }

  void _navigateToDiscoverScreen(BuildContext context) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (c, a1, a2) => const CreateSubliminalPage(),
        transitionsBuilder: (c, anim, a2, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }
}
