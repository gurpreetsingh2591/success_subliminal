import 'dart:js' as js;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:success_subliminal/utils/toast.dart';
import 'package:universal_html/html.dart' as html;
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import '../data/api/ApiService.dart';

const kBlackColor = Color.fromRGBO(9, 9, 9, 1.0);
const kBaseColor = Color.fromRGBO(39, 6, 159, 1.0);
const kBaseColorDark = Color.fromRGBO(20, 0, 78, 1.0);
const kBaseRed = Color.fromRGBO(193, 30, 30, 1.0);
const kDarkBlueColor = Color.fromRGBO(2, 9, 52, 0.3607843137254902);
const kYellow = Color.fromRGBO(251, 255, 46, 1.0);
const kBaseColor3 = Color.fromRGBO(96, 61, 220, 1.0);
const kTrans = Color.fromRGBO(255, 255, 255, 0.0);
const kTransBaseNew = Color.fromRGBO(26, 5, 65, 1.0);
const kTransBaseNewWeb = Color.fromRGBO(26, 5, 65, 1.0);
const kWhiteTrans = Color.fromRGBO(255, 255, 255, 0.050980392156862744);
const kWhiteTrans20 = Color.fromRGBO(255, 255, 255, 0.19607843137254902);
const kWhiteTrans20New = Color.fromRGBO(255, 255, 255, 0.10196078431372549);
const kGrayTrans = Color.fromRGBO(25, 25, 25, 1.0);
const kLightWhiteTrans = Color.fromRGBO(255, 255, 255, 0.011764705882352941);
const kBaseLightColor = Color.fromRGBO(173, 69, 154, 1);
const kButtonColor1 = Color.fromRGBO(192, 111, 255, 1.0);
const kButtonColor2 = Color.fromRGBO(159, 35, 255, 1.0);
const kLoginText = Color.fromRGBO(172, 66, 254, 1.0);
const kTextGrey = Color.fromRGBO(199, 199, 199, 1.0);
const kTextColor = Color.fromRGBO(172, 66, 254, 1.0);
const kDialogBgColor = Color.fromRGBO(34, 4, 84, 1.0);
const primary = Colors.white;
const backgroundDark = Color(0xff150334);
const backgroundDark2 = Color(0xff1a0541);
const bottomBarColor = Color(0x5907001f);
const accent = Color(0xffac42fe);
const green = Color(0xff5be845);
const accentLight = Color(0x67ac42fe);

/// * Static Strings
const String kEmailNullError = "Please enter your email";
const String kInvalidEmailError = "Please enter valid Email";
const String kPassNullError = "Please enter your password";
const String kShortPassError = "Password must be at least 6 characters";
const String kConfirmPasswordMatchError = "Your both password not matched";
const String kNameNullError = "Please enter your name";
const String kOTPError = "Please enter valid OTP";
const String kCollectionNameNullError = "Please enter collection name";
const String kStreetNullError = "Please enter your street";
const String kCityNullError = "Please enter your city";
const String kStateNullError = "Please enter your state";
const String kZipCodeNullError = "Please enter your zip code";
const String kCorrectCode = "Please enter 4-set code";
const String kEnterPassword = 'Password';
const String kConfirmPassword = 'Re-enter Password';
const String kEnterEmail = 'E-mail';
const String kOTP = 'OTP';
const String kDescription = 'Your Description Here';
const String kTitle = 'Your Title Here';
const String kNewPassword = 'New Password';
const String kConfirmNewPassword = 'Confirm New Password';
const String kEnterNewPassword = "Entre new password";
const String kEnterConfirmNewPassword = "Entre Confirm new password";
const String kEnterName = "Full name";
const String kEnterCollectionName = "Enter collection name";
const String kEnterDob = "Please enter date of birth";
const String kEnterFullName = "Full Name";
const String kEnterPhone = 'Phone Number';

/// Card Validation Strings */
const String kValidCardNoError = "Please Enter Valid Card Number";
const String kValidExpiryDateError = "Please Enter Valid Card Expiry Date";
const String kValidCardCVVError = "Please Enter Valid Card CVV";
const String kValidNameOnCardError = "Please Enter Name on Card";
const String kValidSelectCardError = "Please Select  Card";

const String kOffer1 = "\$7.97 a month after 7-day trial. Cancel anytime.";
const String kOffer2 = "1  credit to pick any subliminal of your choice.";
const String kOffer3 = "Create your own subliminals for you to keep.";
const String kCancelAnyTimeMsg = "Cancel Anytime. No Commitments.";
const String kSubscriptionSubTitle =
    "You can choose subscription plan, with 7 day trial. You can cancel Anytime.";

const String kSubPlansTitle = "Subscription Plans";
const String kSignUpFree = " Start 7-day Free Trial";
const String kCreateSubliminal = "CREATE SUBLIMINAL";
const String kAddNewSubliminal = "add new subliminal";
const String kCreateNewSubliminal = "CREATE NEW SUBLIMINAL";
const String kSignIn = "Sign In";
const String kHaveNotAcc = "If you haven't account? ";
const String kSignUp = "Sign Up";

const String kVerifyOTP = "Verify OTP";
const String kSignInWith = "Sign in with your success subliminals account";
const String kForgotMsg =
    "Enter your register email, you will get OTP on your email";
const String kNewPasswordMsg = "Enter your new password same in both fields";
const String kOTPMsg =
    "You have received OTP on your email, Please enter below";
const String kCancelSubscriptionAlert =
    "Are you sure to cancel the subscription?";
const String kSetCode = 'Set code';
const String kBioMetrics = "Use Biometrics";
const String kYes = 'Yes';
const String kNo = 'No';
const String kCancel = "Cancel";
const String kOK = 'OK';
const String kSend = "Send";
const String kSubmit = 'Submit';
const String kAgree = 'Agree';
const String kMinus = '-';
const String kPlus = "+";
const String kPound = "£";
const String kThisMonth = "This Month";
const String kLastMonth = "Last Month";
const String kThisYear = "This Year";
const String kLastYear = "Last Year";
const String kLast12Month = "Last 12 Month";
const String kShareStatement = "Share Statement file";
const String kDownloadStatement = 'Download Statement';
const String kShare = 'Share Statement';
const String kStatementExport = "Statement export options";
const String kNote = 'Note';
const String kRegisterAnAccount = "Register an account";
const String kStartFreeTrial = "Start Free Trial Now";
const String kStartTrial = "Free Trial";
const String kBuySubscription = "Buy Subscription";
const String kYouHaveTrial = "you have 7 day trial";
const String kListenWithTrial = "Listen with free trial";
const String kListenNow = "Listen Now";
const String kStopNow = "Stop Now";
const String kCancelSubscription = "Cancel Subscription";
const String kLogout = "Log out";
const String kDeleteAccountTitle = "Delete account";
const String kFAQ = "Frequently asked questions";
const String kNewsUpdate = "News & Updates";
const String kHome = "Home";
const String kPleaseWait = "Please wait...";
const String kAddToCollectionText = "add  to  collections";
const String kEditText = "Edit";
const String kRegister = 'Register';
const String kAppId = '2264410337079767';

const String kSecretTestKey =
    'sk_test_51MZIP6Ei5E21pY9IiVnhnObCGaTDCvniUzGJw7FKrep1cmezr6VP0ZdAwr6VrDzYvxVUbB4MlllVbC5CDUt8ZoWI00z7azpUR4';
const String kSecretLiveKey =
    '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';
const String kPublishableStripeTestKey =
    'pk_test_51MZIP6Ei5E21pY9IF3tiKZMLd9aUIgj8bvpvYyOxcOZKYykqfYlInC9HxV6jbYZTpsCjHmsW2L8h38RHdU0KAeSi00LloERoK1';
const String kPublishableStripeLiveKey =
    'pk_live_51MZIP6Ei5E21pY9Ih6m2q6mQ9fv5kXHd0Dh1mwbZN2eu6vhyM8xkWPmFWnee9JyfKzUy7SNoIlzaYXDNcPJgGuE400aAUUMmwa';
const String conversionApiToken =
    'EAArixLhLZCywBAGaHwLFmUHcfKGOySfcMIRdX2T9QoOR76FtSV4NL0dx1UgbWqqChEbCFwyZCQeNeErXulqRoGENeBtFNd97TuQ0du09LxZAVMZAjZA4OWXhdbuV1DvU6xsnhOVmeZCrL2Vgu1lTp1FVc8yPy0tuFpoB3zToW8I61subV0aRLJ3Ky5XxiuZCbMZD';
const String conversionApiToken2 =
    'EAADaeN4whZC8BALhMPJb9t0aRewcVQsIVNuQFJMWnZARSdMgUxXCcObZBk1q8178AawfQUEW2vBCJlDpYbld8k0EUAeANGiBZBeZAF2kKPUuApWXZA1ZAlUttEXOl9BKPAJBnUlZCunUpV0HKVxFUFaNJBIrScKwzsLcQwuqcdNxSEP9Op0ORgUHV2t1VqlMo7gZD';
const String conversionApiToken3Client =
    'EAArixLhLZCywBABYJuDrNSZADJyoOrX3dUgIgYerlwwU2UC9i8C6plYAn6uPqm4PeQ5RaZAPGkV5DsZBBLJTkeYva7pa3neW6HKHyh8DKj1qvQb5eNKTCkhicQ8nNTIXcggsDZAQEFsZC1P7rcemHri4sv0mWtYZBwwknTyMFNBLTNzWMWroEZBwy0TC180YgZBgZD';
const String conversionApiToken4Client =
    'EAADaeN4whZC8BAOpIobFbsMORFwOVUXZAZBWZAZA1xea1QqLzZCZASRiVcanRw0sVDKoHfHOYLc3ZAnryUZB771G7YhjXYIKHO8hEbnXZBG6CDXZBOyks504y0vMbx4yxn4pUYy2gT469ZAEbtU5J3KAM7ZAj28MWwS96dkR2KI0MjhxZA2uLsLXQ4CdeWpHBtJhybZC1IZD';
const String kTurn = "Turn on your mind's powerful subconscious abilities";
const String kDis = "   Discover";
const String kcri = "   Create";
const String kComingSoon = "Coming Soon";
const String kWith =
    "  with our specifically designed subliminal recordings and cutting-edge technology to create your own subliminals";
const String klib = "  Library";
const String kSubliminalTitle = "Write your Subliminal";
const String kConvertIntoAudioTitle = "Convert into Audio";
const String kSaveTitle = "Save and Enjoy";
const String kMessageSent = "Your message has been sent successfully";
const String kReplyShortly = "We will reply to you shortly.";
const String kRemoveCard = "Are you sure to remove this  card?";
const String kLicence =
    "• Republish material from Success Subliminals LLC \n• Sell, rent or sub-license material from Success Subliminals LLC\n• Reproduce, duplicate or copy material from Success Subliminals LLC\n• Redistribute content from Success Subliminals LLC";
const String kWriteSubliminalDes =
    "Write down the affirmations in the present tense and in the first person";
const String kConvertDes =
    'The affirmations are coded into audio below your hearing threshold to reach the subconscious mind easily';
const String kSaveDes =
    'It is recommended that you listen to a recording at least once a day. You can listen to them in all situations, except when using heavy machinery';

List<String> languageList = [
  'en-GB',
  'en-AU',
  'en-US',
  'de-DE'
      'de-LU'
];

const String sharingContent =
    "\n\nA. Click on the activation link provided Free trial subliminal link.\n\n"
    "B. Click on the 'Sign Up' button, located in the top-right corner of the homepage.\n\n"
    "C. Provide the required information, such as your name, email address, and a secure password.\n\n"
    "D. Once your account is activated, log in using your email address and password.\n\n"
    "E. Navigate to the 'Library' section on our website and find the “Manifest your Dream Life” subliminal.\n\nThank you for choosing Success Subliminals to help you in your personal development journey.\n\n"
    "Best regards,\nSuccess Subliminals Team";

const String sharingContent1 =
    "Dear Friend,\n\nTo access your complimentary subliminal, please follow the instructions outlined below:"
    "\n\nClick here to start free trial\n\n";

const String sharingContent2 = "\n\nBest regards,\nSuccess Subliminals Team";

final player = AudioPlayer();
int subPlaying = -1;
bool isPlaying = false;
String buttonPlaying = "Listen Now";
String screenName = "create";

bool loginContainerVisible = false;
bool signUpContainerVisible = true;

double titleTextSize = 50;
double loginTopPadding = 100;
double loginRightPadding = 100;
double loginLeftPadding = 100;

double titleSize = 24;
double descriptionSize = 16;
double titleGridSize = 20;
double descriptionGridSize = 14;

bool isLogin = false;
bool isTrialStatus = false;
bool isTrialUsed = false;
bool isSubscriptionActive = false;

bool isValidCardDetailInSetting(
    String name, String cardNo, String expMonth, String expYear, String cVV) {
  bool isValid = false;

  if (cardNo.isEmpty) {
    isValid = false;
    toast(kValidCardNoError, true);
  } else if (cardNo.length < 12) {
    isValid = false;
    toast(kValidCardNoError, true);
  } else if (expMonth.isEmpty) {
    isValid = false;
    toast(kValidExpiryDateError, true);
  } else if (expMonth.length < 2) {
    isValid = false;
    toast(kValidExpiryDateError, true);
  } else if (expYear.isEmpty) {
    isValid = false;
    toast(kValidExpiryDateError, true);
  } else if (expYear.length < 2) {
    isValid = false;
    toast(kValidExpiryDateError, true);
  } else if (cVV.isEmpty) {
    isValid = false;
    toast(kValidCardCVVError, true);
  } else if (cVV.length < 3) {
    isValid = false;
    toast(kValidCardCVVError, true);
  } else if (name.isEmpty) {
    isValid = false;
    toast(kValidNameOnCardError, true);
  } else {
    isValid = true;
  }

  return isValid;
}

bool isValidCardDetailSubscription(
    String name, String cardNo, String expDate, String cVV) {
  bool isValid = false;
  if (name.isEmpty) {
    isValid = false;
    toast(kValidNameOnCardError, true);
  } else if (cardNo.isEmpty) {
    isValid = false;
    toast(kValidCardNoError, true);
  } else if (cardNo.length < 12) {
    isValid = false;
    toast(kValidCardNoError, true);
  } else if (expDate.isEmpty) {
    isValid = false;
    toast(kValidExpiryDateError, true);
  } else if (expDate.length < 5) {
    isValid = false;
    toast(kValidExpiryDateError, true);
  } else if (cVV.isEmpty) {
    isValid = false;
    toast(kValidCardCVVError, true);
  } else if (cVV.length < 3) {
    isValid = false;
    toast(kValidCardCVVError, true);
  } else {
    isValid = true;
  }

  return isValid;
}

String followingTerms = '''
The following terminology applies to these Terms and Conditions, Privacy Statement and Disclaimer Notice and all Agreements: "Client", "You" and "Your" refers to you, the person log on this website and compliant to the Company's terms and conditions. "The Company", "Ourselves", "We", "Our" and "Us", refers to our Company. "Party", "Parties", or "Us", refers to both the Client and ourselves. All terms refer to the offer, acceptance and consideration of payment necessary to undertake the process of our assistance to the Client in the most appropriate manner for the express purpose of meeting the Client's needs in respect of provision of the Company's stated services, in accordance with and subject to, prevailing law of us. Any use of the above terminology or other words in the singular, plural, capitalization and/or he/she or they, are taken as interchangeable and therefore as referring to same.
''';
String partOfWebsite = '''
Parts of this website offer an opportunity for users to post and exchange opinions and information in certain areas of the website. Success Subliminals LLC does not filter, edit, publish or review Comments prior to their presence on the website. Comments do not reflect the views and opinions of Success Subliminals LLC,its agents and/or affiliates. Comments reflect the views and opinions of the person who post their views and opinions. To the extent permitted by applicable laws, Success Subliminals LLC shall not be liable for the Comments or for any liability, damages or expenses caused and/or suffered as a result of any use of and/or posting of and/or appearance of the Comments on this website.''';

String videoUrl = 'https://app.successsubliminals.net/images/videoplayback.mp4';

launchURL() async {
  const url = 'https://app.successsubliminals.net/privacy-policy';
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  } else {
    throw 'Could not launch $url';
  }
}

launchTermURL() async {
  const url = 'https://app.successsubliminals.net/terms-conditions';
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  } else {
    throw 'Could not launch $url';
  }
}

launchFacebookURL(String url, String title) async {
  final urls = 'https://www.facebook.com/sharer/sharer.php?u=$url&t=$title';
  final uri = Uri.parse(urls);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  } else {
    throw 'Could not launch $url';
  }
}

launchTwitterURL(String url, String title) async {
  final urls = 'https://twitter.com/intent/tweet?text=$title&url=$url';
  final uri = Uri.parse(urls);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  } else {
    throw 'Could not launch $url';
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

const statusBarGradient = LinearGradient(
  colors: <Color>[
    backgroundDark,
    kBaseColor,
  ],
  stops: [0.5, 1.5],
);

final kInnerDecoration = BoxDecoration(
  color: kDarkBlueColor,
  border: Border.all(color: kWhiteTrans, width: 2),
  borderRadius: BorderRadius.circular(30),
);

final kEditTextDecoration = BoxDecoration(
  color: kWhiteTrans,
  border: Border.all(color: kTrans),
  borderRadius: BorderRadius.circular(15),
);

final kEditTextDecoration10Radius = BoxDecoration(
  color: kWhiteTrans,
  border: Border.all(color: kWhiteTrans),
  borderRadius: BorderRadius.circular(10),
);

final kEditTextEmailDecoration = BoxDecoration(
  color: kGrayTrans,
  border: Border.all(color: kGrayTrans),
  borderRadius: BorderRadius.circular(15),
);

final kEditTextWithBorderDecoration = BoxDecoration(
  border: Border.all(color: accent, width: 2),
  color: kTrans,
  borderRadius: BorderRadius.circular(15),
);

final kWhiteUnSelectBorderDecoration = BoxDecoration(
  border: Border.all(color: Colors.black, width: 2),
  color: Colors.black,
  borderRadius: BorderRadius.circular(20),
);
final kWhiteSelectBorderDecoration = BoxDecoration(
  border: Border.all(color: accent, width: 2),
  color: Colors.black,
  borderRadius: BorderRadius.circular(20),
);

const kBottomBarBgDecoration = BoxDecoration(
    color: bottomBarColor,
    border: Border(
      top: BorderSide(color: kWhiteTrans, width: 0),
    ));

const kBottomBarBgWithoutLoginDecoration = BoxDecoration(
    color: kLightWhiteTrans,
    border: Border(
      top: BorderSide(color: kWhiteTrans, width: 0),
    ));
final kBlackButtonDecoration = BoxDecoration(
  color: Colors.black,
  borderRadius: BorderRadius.circular(15),
);

final kDummyImageDecoration = BoxDecoration(
  // color: kBaseColor,
  border: Border.all(color: kWhiteTrans, width: 2),
  borderRadius: BorderRadius.circular(20),
);

final kButtonBoxDecoration = BoxDecoration(
  gradient: const LinearGradient(
    colors: [kButtonColor1, kButtonColor2],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  ),
  borderRadius: BorderRadius.circular(5),
);

final kSendEmailBoxImageDecoration = BoxDecoration(
  image: const DecorationImage(
      image: AssetImage("assets/images/ic_send_email_bg.png"),
      fit: BoxFit.fill),
  borderRadius: BorderRadius.circular(10),
);
final kSendEmailBoxImageDecorationMobile = BoxDecoration(
  image: const DecorationImage(
      image: AssetImage("assets/images/ic_send_email_bg_mobile.png"),
      fit: BoxFit.fill),
  borderRadius: BorderRadius.circular(10),
);

final kButtonBox10Decoration = BoxDecoration(
  gradient: const LinearGradient(
    colors: [kButtonColor1, kButtonColor2],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  ),
  borderRadius: BorderRadius.circular(10),
);

final kButtonBox10Decoration2 = BoxDecoration(
  gradient: const LinearGradient(
    colors: [kButtonColor1, kButtonColor2],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  ),
  borderRadius: BorderRadius.circular(12),
);
final kTransButtonBoxDecoration = BoxDecoration(
  gradient: const LinearGradient(colors: [kWhiteTrans, kWhiteTrans]),
  borderRadius: BorderRadius.circular(10),
);
final kAccentButtonBoxDecoration = BoxDecoration(
  gradient: const LinearGradient(colors: [accent, accent]),
  borderRadius: BorderRadius.circular(10),
);

final kBlackButtonBoxDecoration = BoxDecoration(
  gradient: const LinearGradient(colors: [kBlackColor, kBlackColor]),
  borderRadius: BorderRadius.circular(5),
);
final kBlackButtonBox10Decoration = BoxDecoration(
  gradient: const LinearGradient(colors: [kBlackColor, kBlackColor]),
  borderRadius: BorderRadius.circular(10),
);
final kBlackButtonBox10Decoration2 = BoxDecoration(
  gradient: const LinearGradient(colors: [kBlackColor, kBlackColor]),
  borderRadius: BorderRadius.circular(14),
);
final kBlackButtonBox30Decoration = BoxDecoration(
  gradient: const LinearGradient(colors: [kBlackColor, kBlackColor]),
  borderRadius: BorderRadius.circular(30),
);
final kBlackButtonBox20Decoration = BoxDecoration(
  gradient: const LinearGradient(colors: [kBlackColor, kBlackColor]),
  borderRadius: BorderRadius.circular(20),
);
final kTopCornerBlackBackgroundBoxDecoration = BoxDecoration(
  color: kBaseColor,
  border: Border.all(color: kBlackColor),
  gradient: const LinearGradient(colors: [kBlackColor, kBlackColor]),
  borderRadius: const BorderRadius.only(
      topLeft: Radius.circular(10), topRight: Radius.circular(10)),
);

final kAllCornerBackgroundBoxDecoration = BoxDecoration(
  color: kBaseColor,
  border: Border.all(color: kWhiteTrans, width: 2),
  gradient: const LinearGradient(colors: [kWhiteTrans, kWhiteTrans]),
  borderRadius: BorderRadius.circular(30),
);
final kAllCornerBackgroundBox20Decoration = BoxDecoration(
  color: kBaseColor,
  border: Border.all(color: kWhiteTrans, width: 1),
  gradient: const LinearGradient(colors: [kWhiteTrans, kWhiteTrans]),
  borderRadius: BorderRadius.circular(15),
);

final kAllCornerBoxDecoration = BoxDecoration(
  color: kBaseColor,
  border: Border.all(color: kWhiteTrans20, width: 1),
  gradient: const LinearGradient(colors: [kWhiteTrans, kWhiteTrans]),
  borderRadius: BorderRadius.circular(20),
);

final kAllCornerBoxDecoration2 = BoxDecoration(
  color: kBaseColor,
  border: Border.all(color: kWhiteTrans, width: 1),
  gradient: const LinearGradient(colors: [backgroundDark2, backgroundDark2]),
  borderRadius: BorderRadius.circular(20),
);
final kAllCornerBoxDecoration2Dark = BoxDecoration(
  color: kBaseColor,
  border: Border.all(color: kWhiteTrans20New, width: 2),
  gradient: const LinearGradient(colors: [backgroundDark2, backgroundDark2]),
  borderRadius: BorderRadius.circular(20),
);
final kAllMobileCornerBoxDecoration2 = BoxDecoration(
  color: kBaseColor,
  border: Border.all(color: kWhiteTrans, width: 1),
  gradient: const LinearGradient(colors: [backgroundDark2, backgroundDark2]),
  borderRadius: BorderRadius.circular(30),
);

final kSelectedCollectionBoxDecoration = BoxDecoration(
  color: kBaseColor,
  border: Border.all(color: accent, width: 3),
  gradient: const LinearGradient(colors: [kWhiteTrans20New, kWhiteTrans20New]),
  borderRadius: BorderRadius.circular(10),
);
final kUnSelectedCollectionBoxDecoration = BoxDecoration(
  color: kBaseColor,
  gradient: const LinearGradient(colors: [kWhiteTrans20New, kWhiteTrans20New]),
  borderRadius: BorderRadius.circular(10),
);

TextStyle textStyle(double size, Color color, FontWeight weight) {
  return TextStyle(
      fontSize: size, color: color, fontFamily: 'DPClear', fontWeight: weight);
}

TextStyle hintStyle(double size, Color color, FontWeight weight) {
  return TextStyle(
      fontSize: size, color: color, fontFamily: 'DPClear', fontWeight: weight);
}

double planAmountFeatures(String plan, String amount) {
  double amounts = 0.0;

  if (plan == "Half Yearly Plan") {
    amounts = double.parse(amount) * 6;
  } else if (plan == "Annual Plan") {
    amounts = double.parse(amount) * 12;
  } else if (plan == "Monthly Plan") {
    amounts = double.parse(amount);
  }
  return amounts;
}

int planCount(String plan) {
  int count = 0;

  if (plan == "Half Yearly Plan") {
    count = 8;
  } else if (plan == "Annual Plan") {
    count = 12;
  } else if (plan == "Monthly Plan") {
    count = 4;
  }
  return count;
}

String planFeatures(String plan) {
  String features = "";

  if (plan == "Half Yearly Plan") {
    features =
        "Charged every 6 months\nCreate up to 8 subliminals a month\nCancel anytime";
  } else if (plan == "Annual Plan") {
    features =
        "Charged every 12 months\nCreate up to 12 subliminals a month\nCancel anytime";
  } else if (plan == "Monthly Plan") {
    features =
        "Charged every month\nCreate up to 4 subliminals a month\nCancel anytime";
  }
  return features;
}

String planChargeFeatures(String plan) {
  String features = "";

  if (plan == "Half Yearly Plan") {
    features = "Charged every 6 months";
  } else if (plan == "Annual Plan") {
    features = "Charged every 12 months";
  } else if (plan == "Monthly Plan") {
    features = "Charged every month";
  }
  return features;
}

String planCreateSubFeatures(String plan) {
  String features = "";

  if (plan == "Half Yearly Plan") {
    features = "Create up to 8 subliminals a month";
  } else if (plan == "Annual Plan") {
    features = "Create up to 12 subliminals a month";
  } else if (plan == "Monthly Plan") {
    features = "Create up to 4 subliminals a month";
  }
  return features;
}

VideoPlayerController? controllers;
VideoPlayerController? videoPlayerController;
bool isSubPlaying = false;

BoxDecoration planImageDeco(String plan, double radius) {
  late BoxDecoration kDecoration;
  if (plan == "Half Yearly Plan") {
    kDecoration = BoxDecoration(
      image: const DecorationImage(
          image: AssetImage("assets/images/ic_half_yearly_bg.png"),
          fit: BoxFit.fill),
      borderRadius: BorderRadius.circular(radius),
    );
  } else if (plan == "Annual Plan") {
    kDecoration = BoxDecoration(
      image: const DecorationImage(
          image: AssetImage("assets/images/ic_annual_bg.png"),
          fit: BoxFit.fill),
      borderRadius: BorderRadius.circular(radius),
    );
  } else if (plan == "Monthly Plan") {
    kDecoration = BoxDecoration(
      image: const DecorationImage(
          image: AssetImage("assets/images/ic_monthly_bg.png"),
          fit: BoxFit.fill),
      borderRadius: BorderRadius.circular(radius),
    );
  } else {
    kDecoration = BoxDecoration(
      image: const DecorationImage(
          image: AssetImage("assets/images/ic_monthly_bg.png"),
          fit: BoxFit.fill),
      borderRadius: BorderRadius.circular(radius),
    );
  }
  return kDecoration;
}

void trackSubscription(double price) {
  js.context.callMethod('subscription', [price]);

  //_getConversionSubscribeAPI(price.toString());
  /*fbAppEvents.logSubscribe(
      price: double.parse(widget.amount),
      // Replace with the actual purchase amount
      currency: 'USD',
      orderId: '', // Replace with the appropriate currency code
    );*/
}

void trackAddPaymentInfo() {
  js.context.callMethod('addPaymentInfo', [""]);
  // _getConversionAddPaymentAPI();
}

void trackPurchase(double price) {
  js.context.callMethod('purchase', [price]);
  // _getConversionPurchaseAPI(price.toString());
}

void trackTrialInfo() {
  js.context.callMethod('startTrial', [""]);
  // _getConversionStartTrialAPI();
}

void _getConversionAddPaymentAPI() async {
  await ApiService().getConversionAddPaymentApi();
}

void _getConversionPurchaseAPI(String amount) async {
  await ApiService().getConversionPurchaseApi(amount);
}

void _getConversionSubscribeAPI(String amount) async {
  ApiService().getConversionSubscribeApi(amount);
}

void _getConversionStartTrialAPI() async {
  await ApiService().getConversionStartTrialApi();
}

dynamic getSubliminalId() {
  String subliminalId = "";
  String currentUrl = html.window.location.href;

  Uri uri = Uri.parse(currentUrl);

  subliminalId = uri.queryParameters['subliminal_id'].toString();
  if (kDebugMode) {
    print("link---$currentUrl");
  }
  return subliminalId;
}
