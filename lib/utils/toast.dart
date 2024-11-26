import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'constant.dart';

Future<bool?> toast(String message, bool isError) {
  return Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 1,
    backgroundColor: isError ? kBaseRed : kBaseLightColor,
    textColor: Colors.white,
    fontSize: 15.0,
  );
}
/*
              final cardDetails = CardDetails(
                number: '4000056655665556',
                expirationMonth: 12,
                expirationYear: 24,
                cvc: '213',
              );
              final cardDetail = CardDetails(
                number: _cardText.details.number.toString(),
                expirationMonth: _cardText.details.expiryMonth?.toInt(),
                expirationYear: _cardText.details.expiryYear?.toInt(),
                cvc: _cardText.details.cvc.toString(),
              );

              if (kDebugMode) {
                print(cardDetail.toJson());
              }
              Stripe.instance.dangerouslyUpdateCardDetails(cardDetails);*/
/*var id = "";

              Map<String, dynamic> card = <String, dynamic>{};

              card['number'] = '4242424242424242';
              card['exp_month'] = "3";
              card['exp_year'] = "2024";
              card['cvc'] = '123';
              card['name'] = 'garry';

              var param = CardTokenParams.fromJson(card);
              var paramss =
                  const CardTokenParams(type: TokenType.Card, name: "garry");

              if (kDebugMode) {
                print("paramss---$paramss");
              }
              if (kDebugMode) {
                print("products---$card");
              }
              if (kDebugMode) {
                print("details----${card.entries}");
              }
              if (kDebugMode) {
                print("param---${param.toJson()}");
              }*/

/*  Map<String, dynamic> card = <String, dynamic>{};

              card['type'] = TokenType.Card;
              card['name'] = "garry";

              final cardDetails = CardDetails(
                number: '4242424242424242',
                expirationMonth: 12.toInt(),
                expirationYear: 24.toInt(),
                cvc: '123',
              );
              Stripe.instance.dangerouslyUpdateCardDetails(cardDetails);

              var params = CardTokenParams.fromJson(card);
              */ /* type: TokenType.Card,
              name: 'garry',
              address: Address(
              city: 'city',
              country: 'country',
              line1: 'line1',
              line2: 'line2',
              postalCode: '123456',
              state: 'state'),
              currency: 'usd')*/ /*
              if (kDebugMode) {
                print("paramss---$params");
              }

              dynamic token = (await Stripe.instance
                  .createToken(CreateTokenParams.card(params: params)));

              if (kDebugMode) {
                print("token---" + token.toJson()['id']);
              }*/

/*              final paymentMethod = _cardText.details.complete
                  ? await Stripe.instance
                      .createPaymentMethod(
                          params: PaymentMethodParams.card(
                        paymentMethodData: PaymentMethodData(
                            billingDetails: BillingDetails.fromJson({
                          'name': SharedPrefs().getUserFullName(),
                          'email': SharedPrefs().getUserEmail(),
                        })),
                      ))
                      .then((value) => {
                            value.toJson(),
                            id = value.id,
                            _getStripePaymentData(
                                "tok_1Mo27pEi5E21pY9It4Da06h2"),
                          })
                  : const SnackBar(
                      content: Text("Please Enter All Detail"),
                      backgroundColor: kBaseColor)*/

/* await Stripe.instance
                  .confirmPayment(
                data: PaymentMethodParams.card(
                  paymentMethodData: PaymentMethodData(
                    billingDetails: BillingDetails.fromJson({
                      'name': SharedPrefs().getUserFullName(),
                      'email': SharedPrefs().getUserEmail(),
                    }),
                  ),
                ),
                paymentIntentClientSecret: '',
              )
                  .then((value) => id = value.id);*/

/*Future<TokenData?> _generateToken() async {
  try {
    Stripe.instance.dangerouslyUpdateCardDetails(CardDetails(
      number: '5555555555554444',
      expirationMonth: 12,
      expirationYear: 25,
      cvc: '123',
    ));

    var params = const CardTokenParams(
        type: TokenType.Card,
        name: 'garry',
        address: Address(
            city: 'city',
            country: 'country',
            line1: 'line1',
            line2: 'line2',
            postalCode: '123456',
            state: 'state'),
        currency: 'usd');

    if (kDebugMode) {
      print("paramss---$params");
    }

    */ /* TokenData? token = await Stripe.instance.createToken(
        const CreateTokenParams(
            type: TokenType.Card,
            name: 'garry',
            address: Address(
                city: 'city',
                country: 'country',
                line1: 'line1',
                line2: 'line2',
                postalCode: '123456',
                state: 'state')),
      );*/ /*
    TokenData token = await Stripe.instance.createToken(
      CreateTokenParams(type: TokenType.Card),
    );
    if (kDebugMode) {
      print("token---${token.id}");
    }
    return token;
  } catch (e) {
    String? message = e.toString();
    if (e is PlatformException) {
      if (kDebugMode) {
        print(e.code);
      }
    }
    return null;
  }
}*/
