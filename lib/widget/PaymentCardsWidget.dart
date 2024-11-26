import 'package:flutter/material.dart';

import '../utils/constant.dart';
import 'RightSlideDialog.dart';
import 'SettingCardInfoWidget.dart';
import 'TextFieldWidget400.dart';
import 'TextFieldWidget500.dart';

class PaymentCardsWidget extends StatelessWidget {
  final Size mq;
  final List<dynamic> cardList;
  final TextEditingController cardNoText;
  final TextEditingController expiryDateText;
  final TextEditingController expiryYearText;
  final TextEditingController cvvText;
  final TextEditingController nameText;
  final double size;
  final double cardSize;
  final double sizeScreen;
  final double padding;
  final double detailPadding;
  final double titleSize;
  final double cardTextSize;
  final double margin;
  final VoidCallback onAddTap;
  final Function(String) onDelete;
  final Function(String) onEditTap;
  final FocusNode nameFocus;
  final FocusNode cvvFocus;
  final FocusNode expiryMonthFocus;
  final FocusNode expiryYearFocus;
  final FocusNode cardFocus;

  const PaymentCardsWidget({
    Key? key,
    required this.mq,
    required this.cardList,
    required this.cardNoText,
    required this.expiryDateText,
    required this.cvvText,
    required this.nameText,
    required this.expiryYearText,
    required this.size,
    required this.sizeScreen,
    required this.onAddTap,
    required this.onEditTap,
    required this.onDelete,
    required this.cardSize,
    required this.nameFocus,
    required this.cvvFocus,
    required this.expiryMonthFocus,
    required this.expiryYearFocus,
    required this.cardFocus,
    required this.padding,
    required this.margin,
    required this.detailPadding,
    required this.titleSize,
    required this.cardTextSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: margin),
      padding: EdgeInsets.all(padding),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 5),
            child: TextFieldWidget500(
                text: "Saved payment cards",
                size: titleSize,
                color: Colors.white,
                textAlign: TextAlign.left),
          ),
          Container(
              margin: const EdgeInsets.only(top: 5),
              child: const TextFieldWidget(
                text: "Manage your payment details for one-time purchases.",
                size: 16,
                color: Colors.white54,
                weight: FontWeight.w400,
              )),
          Container(
              margin: const EdgeInsets.only(top: 40, bottom: 10),
              child: const TextFieldWidget500(
                  text: "My cards",
                  size: 26,
                  color: Colors.white,
                  textAlign: TextAlign.center)),
          cardList.isNotEmpty
              ? ListView.builder(
                  shrinkWrap: true,
                  itemCount: cardList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return buildCardContainer(context, cardList[index], mq);
                  })
              : Container(
                  margin: const EdgeInsets.only(top: 20, bottom: 10),
                  child: const TextFieldWidget500(
                      text: "You have not any saved card.",
                      size: 16,
                      color: Colors.white54,
                      textAlign: TextAlign.center),
                ),
          buildAddCardContainer(context, mq)
        ],
      ),
    );
  }

  Widget buildCardContainer(BuildContext context, dynamic cardItem, Size mq) {
    return Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: mq.width * cardSize,
            decoration: kBlackButtonBox20Decoration,
            padding: const EdgeInsets.all(20),
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
                      Align(
                        alignment: Alignment.center,
                        child: Image.asset(
                          'assets/images/ic_cards.png',
                          scale: 2,
                          color: Colors.white,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 5, left: 10),
                        child: TextFieldWidget500(
                            text: "•••• ",
                            size: cardTextSize,
                            color: Colors.white54,
                            textAlign: TextAlign.center),
                      ),
                      Container(
                          margin: const EdgeInsets.only(top: 5),
                          child: TextFieldWidget(
                            text: "${cardItem['card']['last4']} | ",
                            size: cardTextSize,
                            color: Colors.white54,
                            weight: FontWeight.w400,
                          )),
                      Container(
                          margin: const EdgeInsets.only(top: 5),
                          child: TextFieldWidget(
                            text: cardItem['card']['exp_month']
                                        .toString()
                                        .length ==
                                    1
                                ? "0${cardItem['card']['exp_month']}/${cardItem['card']['exp_year']}"
                                : "${cardItem['card']['exp_month']}/${cardItem['card']['exp_year']}",
                            size: cardTextSize,
                            color: Colors.white54,
                            weight: FontWeight.w400,
                          )),
                    ]),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Image.asset(
                          'assets/images/ic_edit_pencil.png',
                          scale: 2.5,
                          color: Colors.white54,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => {
                          onEditTap(cardItem['id']),
                          openDialog(context, mq, cardItem, 'edit')
                        },
                        child: Container(
                          margin: const EdgeInsets.only(left: 5),
                          child: TextFieldWidget(
                            text: "Edit Card".toUpperCase(),
                            size: cardTextSize,
                            color: Colors.white54,
                            weight: FontWeight.w400,
                          ),
                        ),
                      ),
                      GestureDetector(
                          onTap: () => {onDelete(cardItem['id'])},
                          child: Container(
                            margin: const EdgeInsets.only(left: 20),
                            child: Align(
                              alignment: Alignment.center,
                              child: Image.asset('assets/images/ic_trash.png',
                                  scale: 2),
                            ),
                          )),
                    ]),
              ],
            ),
          )
        ]);
  }

  Widget buildAddCardContainer(BuildContext context, Size mq) {
    dynamic cardItem;
    return Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: mq.width * cardSize,
            decoration: kAllCornerBoxDecoration2Dark,
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.only(top: 30, bottom: 10),
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
                      Align(
                        alignment: Alignment.center,
                        child:
                            Image.asset('assets/images/ic_cards.png', scale: 2),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 5, left: 20),
                        child: TextFieldWidget500(
                            text: "••••",
                            size: cardTextSize,
                            color: Colors.white54,
                            textAlign: TextAlign.center),
                      ),
                      Container(
                          margin: const EdgeInsets.only(top: 5),
                          child: TextFieldWidget(
                            text: " 0000 | ",
                            size: cardTextSize,
                            color: Colors.white54,
                            weight: FontWeight.w400,
                          )),
                      Container(
                          margin: const EdgeInsets.only(top: 5),
                          child: TextFieldWidget(
                            text: "MM/YY",
                            size: cardTextSize,
                            color: Colors.white54,
                            weight: FontWeight.w400,
                          )),
                    ]),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      GestureDetector(
                          onTap: () => {
                                nameText.text = "",
                                cardNoText.text = "",
                                cvvText.text = "",
                                expiryYearText.text = "",
                                expiryDateText.text = "",
                                openDialog(context, mq, cardItem, 'add')
                              },
                          child: TextFieldWidget(
                            text: "+  Add card".toUpperCase(),
                            size: cardTextSize,
                            color: Colors.yellow,
                            weight: FontWeight.w400,
                          )),
                    ]),
              ],
            ),
          )
        ]);
  }

  void openDialog(
      BuildContext context, Size mq, dynamic cardDetail, String type) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (BuildContext context, Animation animation,
          Animation secondaryAnimation) {
        return RightSlideDialog(
          onClose: () {
            Navigator.of(context).pop();
          },
          screenSize: sizeScreen,
          child: Scaffold(
              body: Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    width: MediaQuery.of(context).size.width * sizeScreen,
                    height: MediaQuery.of(context).size.height,
                    color: backgroundDark2,
                    child: buildAddCardWidget(context, mq, cardDetail, type),
                  ))),
        );
      },
    );
  }

  Widget buildAddCardWidget(
      BuildContext context, Size mq, dynamic cardDetail, String type) {
    if (cardDetail != null) {
      if (cardDetail['card']['exp_month'].toString().length == 1) {
        expiryDateText.text = "0${cardDetail['card']['exp_month']}";
      } else {
        expiryDateText.text = cardDetail['card']['exp_month'].toString();
      }

      expiryYearText.text =
          cardDetail['card']['exp_year'].toString().substring(2, 4);
      nameText.text = cardDetail['billing_details']['name'].toString();
    }
    return ListView(shrinkWrap: true, children: [
      Container(
          padding: EdgeInsets.only(
              top: 20, bottom: 20, left: detailPadding, right: 20),
          child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => {Navigator.of(context).pop()},
                  child: Align(
                    alignment: Alignment.topRight,
                    child:
                        Image.asset('assets/images/ic_close_btn.png', scale: 2),
                  ),
                ),
                SizedBox(
                    width: MediaQuery.of(context).size.width * size,
                    child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              margin: const EdgeInsets.only(top: 3),
                              child: DefaultTextStyle(
                                style: const TextStyle(
                                    fontSize: 50,
                                    color: Colors.white,
                                    fontFamily: 'DPClear',
                                    fontWeight: FontWeight.w400),
                                child: Text(
                                    type == 'edit' ? 'Edit Card' : 'Add Card'),
                              )),
                          Container(
                              margin:
                                  const EdgeInsets.only(top: 15, bottom: 15),
                              child: SettingCardInfoWidget(
                                cardNoText: cardNoText,
                                cvvText: cvvText,
                                nameText: nameText,
                                expiryMonthText: expiryDateText,
                                expiryYearText: expiryYearText,
                                onTap: () => {onAddTap()},
                                buttonName: '+  Add Card',
                                screen: 'add_card',
                                type: type,
                                nameFocus: nameFocus,
                                cvvFocus: cvvFocus,
                                expiryMonthFocus: expiryMonthFocus,
                                expiryYearFocus: expiryYearFocus,
                                cardFocus: cardFocus,
                              ) /*buildCardDetailContainer(context),*/

                              ),
                        ]))
              ])),
    ]);
  }
}
