import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:success_subliminal/pages/discover_subliminal_detail_page.dart';
import 'package:success_subliminal/pages/discover_subliminal_list_page.dart';
import 'package:success_subliminal/pages/web_pages/buy_subliminal_web_page.dart';
import 'package:success_subliminal/utils/toast.dart';

import '../app/router.dart';
import '../data/api/ApiService.dart';
import '../utils/center_loader.dart';
import '../utils/constant.dart';
import '../utils/shared_prefs.dart';
import '../widget/ButtonWidget400.dart';
import '../widget/SettingCardInfoWidget.dart';
import '../widget/TextFieldWidget400.dart';
import '../widget/TextFieldWidget500.dart';

class BuySubliminalPage extends StatefulWidget {
  final String amount;
  final String subId;
  final String subName;
  final String catId;
  final String catName;
  final String screen;

  const BuySubliminalPage(
      {Key? key,
      required this.amount,
      required this.subId,
      required this.subName,
      required this.catId,
      required this.catName,
      required this.screen})
      : super(key: key);

  @override
  BuySubliminalScreen createState() => BuySubliminalScreen();
}

class BuySubliminalScreen extends State<BuySubliminalPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isLogin = false;
  late dynamic buySubliminal;
  late dynamic buySubliminalDetail;
  late dynamic stripeTokenResponse;
  int selectIndex = 0;
  final _cardNoText = TextEditingController();
  final _expiryDateText = TextEditingController();
  final _expiryYearText = TextEditingController();
  final _cvvText = TextEditingController();
  bool isNameFocus = false;
  bool isCardNoFocus = false;
  bool isExpMonthFocus = false;
  bool isCVVFocus = false;
  final _nameText = TextEditingController();
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _cardFocus = FocusNode();
  final FocusNode _expiryFocus = FocusNode();
  final FocusNode _expiryYearFocus = FocusNode();
  final FocusNode _cvvFocus = FocusNode();

  List<dynamic> cardsList = [];
  late dynamic listPaymentMethod;
  late dynamic paymentMethod;
  late dynamic addPaymentMethod;
  late dynamic usedFreeTrial;
  bool isFreeTrialUsed = false;
  String pmID = "";
  bool isAddAnotherCard = false;
  int isSelectCardIndex = -1;
  bool isCards = true;
  late dynamic subscription;
  late dynamic conversionPurchase;
  late dynamic conversionAddPayment;

  @override
  void initState() {
    super.initState();
    // cvvDateTextListener();
    _getListPaymentMethodData(SharedPrefs().getStripeCustomerId().toString());
    // expDateTextListener();
    initializePreference().whenComplete(() {
      isLogin = SharedPrefs().isLogin();
    });

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

  _handleOnPayWithStripeSavedCardButton(
      Size mq, BuildContext context, String subId, String price, String pmId) {
    setState(() {
      if (pmID == "") {
        toast(kValidSelectCardError, true);
      } else {
        showCenterLoader(context);
        _getStripeSavedCardPaymentData(context, mq, subId, price, pmId);
      }
    });
  }

  void _getListPaymentMethodData(String customerId) async {
    listPaymentMethod =
        await ApiService().getStripePaymentMethodList(customerId, context);

    Future.delayed(const Duration(seconds: 1))
        .then((value) => setState(() async {
              setState(() {
                isCards = false;
                if (listPaymentMethod == null) {
                  toast(listPaymentMethod['error']['message'], true);
                } else {
                  cardsList = listPaymentMethod['data'];
                }

                setState(() {
                  cardsList.isEmpty
                      ? isAddAnotherCard = true
                      : isAddAnotherCard;
                });

                if (kDebugMode) {
                  print("cardsList ----$cardsList");
                }
              });
            }));
  }

  void _getStripeSavedCardPaymentData(BuildContext context, Size mq,
      String subId, String price, String pmId) async {
    subscription = await ApiService().getStripeBuyWithSavedCards(subId, price,
        SharedPrefs().getStripeCustomerId().toString(), pmId, context);

    Future.delayed(const Duration(seconds: 1))
        .then((value) => setState(() async {
              setState(() {
                if (subscription['http_code'] != 200) {
                } else {
                  subscription = subscription['data'];
                  if (widget.screen == 'list') {
                    context.pushNamed('discover-subliminals', queryParameters: {
                      'categoryName': widget.catName,
                      'categoryId': widget.catId,
                      'subname': widget.subName,
                    });
                    // _navigateToDiscoverListScreen(context);
                  } else if (widget.screen == 'library') {
                    context.pushReplacement(Routes.libraryNew);
                  } else {
                    context.pushNamed('discover-subliminals-detail',
                        queryParameters: {
                          'categoryName': widget.catName,
                          'subName': widget.subName,
                          'subId': widget.subId,
                          'catId': widget.catId,
                        });

                    // _navigateToDiscoverDetailScreen(context);
                  }
                  trackPurchase(double.parse(widget.amount));
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
        _expiryYearText.text.toString(),
        _cvvText.text.toString(),
      )) {
        showCenterLoader(context);
        _getStripeTokenData(context, _cardNoText.text, _expiryDateText.text,
            _expiryYearText.text, _cvvText.text, _nameText.text);
      } else {}
    });
  }

  void cvvDateTextListener() {
    _cvvText.addListener(() {
      if (kDebugMode) {
        print("value: ${_cvvText.text}");
      }

      String text = _cvvText.text;
      if (text.length == 3) {
        FocusScope.of(context).nextFocus();
      }
    });
  }

  void _getStripePaymentData(String token, BuildContext context) async {
    buySubliminal = await ApiService().getOneTimeBuySub(
      context,
      SharedPrefs().getUserFullName().toString(),
      SharedPrefs().getUserEmail().toString(),
      widget.amount,
      token,
      widget.subId,
    );

    Future.delayed(const Duration(seconds: 2)).then((value) => setState(() {
          setState(() {
            if (buySubliminal['http_code'] != 200) {
            } else {
              buySubliminalDetail = buySubliminal['data'];
              if (buySubliminalDetail != null) {
                Navigator.of(context, rootNavigator: true).pop();
                //  Navigator.pop(context);
                if (widget.screen == 'list') {
                  context.pushNamed('discover-subliminals', queryParameters: {
                    'categoryName': widget.catName,
                    'categoryId': widget.catId,
                    'subname': widget.subName,
                  });
                  // _navigateToDiscoverListScreen(context);
                } else if (widget.screen == "library") {
                  context.pushReplacement(Routes.libraryNew);
                } else {
                  kIsWeb
                      ? context.pushNamed('discover-subliminals-detail',
                          queryParameters: {
                              'subName': widget.subName,
                              'subId': widget.subId,
                              'catId': widget.catId,
                              'categoryName': widget.catName,
                            })
                      : context.pushNamed('discover-subliminals-detail',
                          queryParameters: {
                              'subName': widget.subName,
                              'subId': widget.subId,
                            });
                  // _navigateToDiscoverDetailScreen(context);
                }
                // buildBuyDialogContainer(context);
              }
            }
          });
        }));
  }

  void _getStripeTokenData(BuildContext context, String cardNo, String expMonth,
      String expYear, String cvv, String name) async {
    stripeTokenResponse = await ApiService()
        .getCreateToken(cardNo, expMonth, expYear, cvv, context);

    Future.delayed(const Duration(seconds: 1)).then((value) => setState(() {
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
              stripeTokenResponse = stripeTokenResponse;
              if (stripeTokenResponse != null) {
                _getStripePaymentData(
                    stripeTokenResponse['id'].toString(), context);
              }
            }
          });
        }));
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
              return BuySubliminalWebPage(
                amount: widget.amount,
                subId: widget.subId,
                subName: widget.subName,
                catId: widget.catId,
                catName: widget.catName,
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
                  "Please Enter your detail below to Buy the subliminals.",
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
                            text: "\$${widget.amount}",
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
              margin: const EdgeInsets.only(top: 10, left: 20, right: 20),
              alignment: Alignment.topLeft,
              child: Align(
                  alignment: Alignment.topLeft,
                  child: RichText(
                    textAlign: TextAlign.left,
                    text: TextSpan(
                      text: "Your Subliminals: ",
                      style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontFamily: 'DPClear',
                          fontWeight: FontWeight.w500),
                      /*defining default style is optional */
                      children: <TextSpan>[
                        TextSpan(
                            text: widget.subName,
                            style: const TextStyle(
                                fontSize: 22,
                                color: Colors.white,
                                fontFamily: 'DPClear',
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  )),
            ),
            cardsList.isNotEmpty
                ? selectSavedCardContainer(context, mq)
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
                          expiryYearText: _expiryYearText,
                          onTap: () =>
                              {_handleOnPayWithStripeButton(mq, context)},
                          buttonName: 'Make Payment'.toUpperCase(),
                          screen: 'subscription',
                          type: 'add',
                          nameFocus: _nameFocus,
                          cvvFocus: _cvvFocus,
                          expiryMonthFocus: _expiryFocus,
                          expiryYearFocus: _expiryYearFocus,
                          cardFocus: _cardFocus,
                        )),
                  )
                : Container(
                    width: 100,
                    height: 100,
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(top: 50),
                    padding: const EdgeInsets.all(10),
                    child: const CircularProgressIndicator())
          ],
        ),
      ),
    );
  }

  Widget selectSavedCardContainer(BuildContext contexts, Size mq) {
    return Container(
      margin: const EdgeInsets.only(left: 15, right: 15),
      child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
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
                          name: "Make Payment".toUpperCase(),
                          icon: '',
                          visibility: false,
                          padding: 30,
                          onTap: () => {
                                _handleOnPayWithStripeSavedCardButton(mq,
                                    context, widget.subId, widget.amount, pmID)
                              },
                          size: 14,
                          buttonSize: 50,
                          deco: kButtonBox10Decoration),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => {
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
                ])
          ]),
    );
  }

  Widget buildCardContainer(
      BuildContext context, dynamic cardItem, Size mq, int index) {
    return Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
              onTap: () => {
                    setState(() {
                      isSelectCardIndex = index;
                      pmID = cardItem['id'];
                      print('pmID--$pmID');
                    })
                  },
              child: Container(
                  width: mq.width,
                  decoration: isSelectCardIndex != index
                      ? kWhiteUnSelectBorderDecoration
                      : kWhiteSelectBorderDecoration,
                  padding: const EdgeInsets.only(
                      left: 20, right: 20, top: 20, bottom: 20),
                  margin: const EdgeInsets.only(top: 10),
                  child: Row(
                      mainAxisSize: MainAxisSize.min,
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
                                color: isSelectCardIndex != index
                                    ? Colors.white54
                                    : accent,
                                weight: FontWeight.w400,
                              ),
                              TextFieldWidget(
                                text: "--${cardItem['card']['last4']}  |  ",
                                size: 16,
                                color: isSelectCardIndex != index
                                    ? Colors.white54
                                    : accent,
                                weight: FontWeight.w400,
                              ),
                              TextFieldWidget(
                                text: cardItem['card']['exp_month']
                                            .toString()
                                            .length ==
                                        1
                                    ? "0${cardItem['card']['exp_month']}/${cardItem['card']['exp_year']}"
                                    : "${cardItem['card']['exp_month']}/${cardItem['card']['exp_year']}",
                                size: 16,
                                color: isSelectCardIndex != index
                                    ? Colors.white54
                                    : accent,
                                weight: FontWeight.w400,
                              ),
                            ]),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(left: 10),
                                child: TextFieldWidget(
                                  text: cardItem['billing_details']['name'] !=
                                          null
                                      ? cardItem['billing_details']['name']
                                          .toString()
                                      : "User Name",
                                  weight: FontWeight.w400,
                                  size: 14,
                                  color: isSelectCardIndex != index
                                      ? Colors.white54
                                      : accent,
                                ),
                              ),
                            ])
                      ])))
        ]);
  }

  Widget buildTopBarContainer(BuildContext context, Size mq) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => {
            setState(() {
              if (widget.screen == 'list') {
                context.pushNamed('discover-subliminals', queryParameters: {
                  'categoryName': widget.catName,
                  'categoryId': widget.catId,
                  'subname': widget.subName,
                });
                // _navigateToDiscoverListScreen(context);
              } else if (widget.screen == "library") {
                context.pushReplacement(Routes.libraryNew);
              } else {
                kIsWeb
                    ? context.pushNamed('discover-subliminals-detail',
                        queryParameters: {
                            'subName': widget.subName,
                            'subId': widget.subId,
                            'catId': widget.catId,
                            'categoryName': widget.catName,
                          })
                    : context.pushNamed('discover-subliminals-detail',
                        queryParameters: {
                            'subName': widget.subName,
                            'subId': widget.subId,
                          });
                // _navigateToDiscoverDetailScreen(context);
              }
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
            padding: const EdgeInsets.only(top: 10),
            child: const Align(
              alignment: Alignment.center,
              child: Text(
                "Buy Subliminals",
                maxLines: 2,
                style: TextStyle(
                    fontSize: 22,
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
                Navigator.pop(context);
                if (widget.screen == 'list') {
                  context.pushNamed('discover-subliminals', queryParameters: {
                    'categoryName': widget.catName,
                    'categoryId': widget.catId,
                    'subname': widget.subName,
                  });
                  //  _navigateToDiscoverListScreen(cont);
                } else if (widget.screen == "library") {
                  context.pushReplacement(Routes.libraryNew);
                } else {
                  kIsWeb
                      ? context.pushNamed('discover-subliminals-detail',
                          queryParameters: {
                              'subName': widget.subName,
                              'subId': widget.subId,
                              'catId': widget.catId,
                              'categoryName': widget.catName,
                            })
                      : context.pushNamed('discover-subliminals-detail',
                          queryParameters: {
                              'subName': widget.subName,
                              'subId': widget.subId,
                            });
                  // _navigateToDiscoverDetailScreen(cont);
                }
              });
            },
            style: ElevatedButton.styleFrom(
              primary: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10), // <-- Radius
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Go To Discover'.toUpperCase(),
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

  Widget buildButton(BuildContext context) {
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

                  _getStripeTokenData(context, _cardNoText.text, expMonth,
                      expYear, _cvvText.text, _nameText.text);
                }
              });
            },
            style: ElevatedButton.styleFrom(
              primary: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10), // <-- Radius
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Make Payment'.toUpperCase(),
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

  buildBuyDialogContainer(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext contexts) {
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
                                text: "Your Buy ID :  ",
                                style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white54,
                                    fontFamily: 'DPClear',
                                    fontWeight: FontWeight.w500),
                                /*defining default style is optional */
                                children: <TextSpan>[
                                  TextSpan(
                                      text:
                                          buySubliminalDetail['id'].toString(),
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
                                text: "Your Subliminal: ",
                                style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white54,
                                    fontFamily: 'DPClear',
                                    fontWeight: FontWeight.w500),
                                /*defining default style is optional */
                                children: <TextSpan>[
                                  TextSpan(
                                      text: widget.subName,
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
                                      text: "\$${widget.amount}",
                                      style: const TextStyle(
                                          fontSize: 22,
                                          color: Colors.white,
                                          fontFamily: 'DPClear',
                                          fontWeight: FontWeight.w600)),
                                ],
                              ),
                            )),
                      ),
                      buildGoToButton(contexts, context)
                    ],
                  ),
                ),
              ));
        });
  }

  void _navigateToDiscoverListScreen(BuildContext context) {
    Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (c, a1, a2) => DiscoverCategoryListPage(
              categoryName: widget.catName, categoryId: widget.catId),
          transitionsBuilder: (c, anim, a2, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 500),
        ));
  }

  void _navigateToDiscoverDetailScreen(BuildContext context) {
    Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (c, a1, a2) => DiscoverSubliminalDetailPage(
              subName: widget.subName, subId: widget.subId),
          transitionsBuilder: (c, anim, a2, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 500),
        ));
  }

  void _navigateToNextScreen(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (context) => DiscoverCategoryListPage(
                categoryName: widget.catName, categoryId: widget.catId)),
        (Route<dynamic> route) => false);
  }
}
