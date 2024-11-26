import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/constant.dart';
import '../../utils/shared_prefs.dart';
import '../../widget/TextFieldWidget400.dart';
import '../../widget/TextFieldWidget500.dart';
import '../../widget/TopBarWebWithoutLogin.dart';
import '../../widget/WebTopBarContainer.dart';

class PrivacyPolicyWebPage extends StatefulWidget {
  const PrivacyPolicyWebPage({Key? key}) : super(key: key);

  @override
  PrivacyPolicyScreen createState() => PrivacyPolicyScreen();
}

class PrivacyPolicyScreen extends State<PrivacyPolicyWebPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  String loginText = "";
  String loginText1 = "";
  bool isLoading = false;
  bool isLogin = false;
  List<dynamic> categoriesList = [];
  late dynamic categories;
  String tapBar = "discover";

  double leftPeding = 200;
  double rightPeding = 200;
  double topPeding = 100;
  double titleSize = 20;
  double screenWidth = 900;

  @override
  void initState() {
    super.initState();
    initializePreference().whenComplete(() {
      isLogin = SharedPrefs().isLogin();
      setState(() {});
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
            if (constraints.maxWidth > 900) {
              screenWidth = 1000;
              if (constraints.maxWidth < 900) {
                titleTextSize = 50;
                loginTopPadding = 100;
              } else if (constraints.maxWidth < 1100) {
                titleTextSize = 55;
                loginTopPadding = 105;
              } else if (constraints.maxWidth < 1300) {
                titleTextSize = 60;
                loginTopPadding = 110;
              } else if (constraints.maxWidth < 1600) {
                titleTextSize = 65;
                loginTopPadding = 115;
              } else if (constraints.maxWidth < 2000) {
                titleTextSize = 70;
                loginTopPadding = 120;
              }
              return buildHomeContainer(context, mq);
            } else {
              screenWidth = 800;
              return buildHomeContainer(context, mq);
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
          child: Stack(children: [
            screenWidth < 850
                ? buildTopBarContainer(context, mq)
                : screenWidth > 850 && isLogin
                    ? const WebTopBarContainer(screen: 'home')
                    : TopBarWithoutLoginContainer(screen: "home", mq: mq),
            Container(
                alignment: Alignment.topCenter,
                margin: EdgeInsets.only(
                    left: screenWidth < 850 ? 25 : loginLeftPadding,
                    right: screenWidth < 850 ? 25 : loginRightPadding,
                    top: screenWidth < 850 ? 70 : loginTopPadding,
                    bottom: screenWidth < 850 ? 15 : 30),
                child: ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context)
                      .copyWith(scrollbars: false),
                  child: ListView(
                    shrinkWrap: false,
                    primary: false,
                    children: <Widget>[
                      Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 15),
                              child: const TextFieldWidget500(
                                  text:
                                      "Privacy Policy for Success Subliminals",
                                  size: 24,
                                  color: Colors.white,
                                  textAlign: TextAlign.center),
                            ),
                            Container(
                                margin: const EdgeInsets.only(top: 15),
                                child: const TextFieldWidget(
                                    text: "Last modified: 05/06/2023",
                                    size: 15,
                                    weight: FontWeight.w400,
                                    color: Colors.white)),
                            Container(
                                margin: const EdgeInsets.only(top: 30),
                                child: const TextFieldWidget(
                                    text:
                                        "At Success Subliminals LLC, accessible from successsubliminals.net, one of our main priorities is the privacy of our visitors. This Privacy Policy document contains types of information that is collected and recorded by Success Subliminals LLC and how we use it.",
                                    size: 15,
                                    weight: FontWeight.w400,
                                    color: Colors.white)),
                            Container(
                                margin: const EdgeInsets.only(top: 15),
                                child: const TextFieldWidget(
                                    text:
                                        "If you have additional questions or require more information about our Privacy Policy, do not hesitate to contact us.",
                                    size: 15,
                                    weight: FontWeight.w400,
                                    color: Colors.white)),
                            Container(
                                margin: const EdgeInsets.only(top: 15),
                                child: const TextFieldWidget(
                                    text:
                                        'This Privacy Policy applies only to our online activities and is valid for visitors to our website with regards to the information that they shared and/or collect in Success Subliminals LLC. This policy is not applicable to any information collected offline or via channels other than this website.',
                                    size: 15,
                                    weight: FontWeight.w400,
                                    color: Colors.white)),
                            Container(
                              margin: const EdgeInsets.only(top: 20),
                              child: const TextFieldWidget500(
                                  text: "Consent",
                                  size: 24,
                                  color: Colors.white,
                                  textAlign: TextAlign.center),
                            ),
                            Container(
                                margin: const EdgeInsets.only(top: 15),
                                child: const TextFieldWidget(
                                    text:
                                        "By using our website, you hereby consent to our Privacy Policy and agree to its terms.",
                                    size: 15,
                                    weight: FontWeight.w400,
                                    color: Colors.white)),
                            Container(
                              margin: const EdgeInsets.only(top: 20),
                              child: const TextFieldWidget500(
                                  text: "Information we collect",
                                  size: 24,
                                  color: Colors.white,
                                  textAlign: TextAlign.center),
                            ),
                            Container(
                                margin: const EdgeInsets.only(top: 15),
                                child: const TextFieldWidget(
                                    text:
                                        'The personal information that you are asked to provide, and the reasons why you are asked to provide it, will be made clear to you at the point we ask you to provide your personal information.',
                                    size: 15,
                                    weight: FontWeight.w400,
                                    color: Colors.white)),
                            Container(
                                margin: const EdgeInsets.only(top: 15),
                                child: const TextFieldWidget(
                                    text:
                                        "If you contact us directly, we may receive additional information about you such as your name, email address, phone number, the contents of the message and/or attachments you may send us, and any other information you may choose to provide.",
                                    size: 15,
                                    weight: FontWeight.w400,
                                    color: Colors.white)),
                            Container(
                                margin: const EdgeInsets.only(
                                  top: 15,
                                ),
                                child: const TextFieldWidget(
                                    text:
                                        'When you register for an Account, we may ask for your contact information, including items such as name, company name, address, email address, and telephone number.',
                                    size: 15,
                                    weight: FontWeight.w400,
                                    color: Colors.white)),
                            Container(
                                margin: const EdgeInsets.only(top: 15),
                                child: const TextFieldWidget(
                                    text:
                                        'This Agreement shall begin on the date here of. Our Terms and Conditions were created with the help of the <u>Terms and Conditions Generator</u>.',
                                    size: 15,
                                    weight: FontWeight.w400,
                                    color: Colors.white)),
                            Container(
                                margin: const EdgeInsets.only(top: 20),
                                child: const TextFieldWidget500(
                                    text: 'How we use your information',
                                    size: 24,
                                    color: Colors.white,
                                    textAlign: TextAlign.center)),
                            Container(
                                margin: const EdgeInsets.only(top: 15),
                                child: const TextFieldWidget(
                                    text:
                                        'We use the information we collect in various ways, including to:',
                                    size: 15,
                                    weight: FontWeight.w400,
                                    color: Colors.white)),
                            Container(
                                margin:
                                    const EdgeInsets.only(top: 15, left: 15),
                                child: const TextFieldWidget(
                                    text:
                                        '• Provide, operate, and maintain our website\n• Improve, personalize, and expand our website\n• Understand and analyze how you use our website\n• Develop new products, services, features, and functionality\n• Communicate with you, either directly or through one of our partners, including for customer service, to provide you with updates and other information relating to the website, and for marketing and promotional purposes\n• Send you emails\n• Find and prevent fraud',
                                    size: 15,
                                    weight: FontWeight.w400,
                                    color: Colors.white)),
                            Container(
                              margin: const EdgeInsets.only(top: 20),
                              child: const TextFieldWidget500(
                                  text: "Log Files",
                                  size: 24,
                                  color: Colors.white,
                                  textAlign: TextAlign.center),
                            ),
                            Container(
                                margin: const EdgeInsets.only(
                                  top: 15,
                                ),
                                child: const TextFieldWidget(
                                    text:
                                        'Success Subliminals LLC follows a standard procedure of using log files. These files log visitors when they visit websites. All hosting companies do this and a part of hosting services analytics. The information collected by log files include internet protocol (IP) addresses, browser type, Internet Service Provider (ISP), date and time stamp, referring/exit pages, and possibly the number of clicks. These are not linked to any information that is personally identifiable. The purpose of the information is for analyzing trends, administering the site, tracking users movement on the website, and gathering demographic information.',
                                    size: 15,
                                    weight: FontWeight.w400,
                                    color: Colors.white)),
                            Container(
                              margin: const EdgeInsets.only(top: 20),
                              child: const TextFieldWidget500(
                                  text: "Cookies and Web Beacons",
                                  size: 24,
                                  color: Colors.white,
                                  textAlign: TextAlign.center),
                            ),
                            Container(
                                margin: const EdgeInsets.only(
                                  top: 15,
                                ),
                                child: const TextFieldWidget(
                                    text:
                                        'Like any other website, Success Subliminals LLC uses "cookies". These cookies are used to store information including visitors preferences, and the pages on the website that the visitor accessed or visited. The information is used to optimize the users experience by customizing our web page content based on visitors browser type and/or other information.',
                                    size: 15,
                                    weight: FontWeight.w400,
                                    color: Colors.white)),
                            Container(
                              margin: const EdgeInsets.only(top: 20),
                              child: const TextFieldWidget500(
                                  text: "Advertising Partners Privacy Policies",
                                  size: 24,
                                  color: Colors.white,
                                  textAlign: TextAlign.center),
                            ),
                            Container(
                                margin: const EdgeInsets.only(
                                  top: 15,
                                ),
                                child: const TextFieldWidget(
                                    text:
                                        'You may consult this list to find the Privacy Policy for each of the advertising partners of Success Subliminals LLC.',
                                    size: 15,
                                    weight: FontWeight.w400,
                                    color: Colors.white)),
                            Container(
                                margin: const EdgeInsets.only(
                                  top: 15,
                                ),
                                child: const TextFieldWidget(
                                    text:
                                        'Third-party ad servers or ad networks uses technologies like cookies, JavaScript, or Web Beacons that are used in their respective advertisements and links that appear on Success Subliminals LLC, which are sent directly to users browser. They automatically receive your IP address when this occurs. These technologies are used to measure the effectiveness of their advertising campaigns and/or to personalize the advertising content that you see on websites that you visit.',
                                    size: 15,
                                    weight: FontWeight.w400,
                                    color: Colors.white)),
                            Container(
                                margin: const EdgeInsets.only(
                                  top: 15,
                                ),
                                child: const TextFieldWidget(
                                    text:
                                        'Note that Success Subliminals LLC has no access to or control over these cookies that are used by third-party advertisers.',
                                    size: 15,
                                    weight: FontWeight.w400,
                                    color: Colors.white)),
                            Container(
                              margin: const EdgeInsets.only(top: 20),
                              child: const TextFieldWidget500(
                                  text:
                                      "Personal Data processed for the following purposes and using the following services:",
                                  size: 24,
                                  color: Colors.white,
                                  textAlign: TextAlign.center),
                            ),
                            Container(
                                margin: const EdgeInsets.only(
                                  top: 15,
                                ),
                                child: const TextFieldWidget(
                                    text:
                                        '• Analytics\n    • Google Analytics\n    Personal Data: Trackers; Usage Data\n• Advertising\n• Meta\n• Google Ads\n• Remarketing and behavioral targeting\n    • Google Ads Remarketing, Remarketing with Google Analytics and Facebook Remarketing\n    Personal Data: Trackers; Usage Data\n    • Meta Custom Audience\n    Personal Data: email address; Trackers',
                                    size: 15,
                                    weight: FontWeight.w400,
                                    color: Colors.white)),
                            Container(
                              margin: const EdgeInsets.only(top: 20),
                              child: const TextFieldWidget500(
                                  text:
                                      "Information on opting out of interest-based advertising",
                                  size: 24,
                                  color: Colors.white,
                                  textAlign: TextAlign.center),
                            ),
                            Container(
                              margin: const EdgeInsets.only(
                                top: 15,
                              ),
                              child: RichText(
                                text: TextSpan(
                                  text:
                                      'In addition to any opt-out feature provided by any of the services listed in this document, Users may follow the instructions provided by',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                  ),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: "YourOnlineChoices",
                                      style: const TextStyle(
                                          fontSize: 15,
                                          decoration: TextDecoration.underline,
                                          color: Colors.blue,
                                          fontFamily: 'DPClear',
                                          fontWeight: FontWeight.w600),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          'https://www.youronlinechoices.com/';
                                        },
                                    ),
                                    const TextSpan(
                                      text: " (EU), the ",
                                      style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.white,
                                          fontFamily: 'DPClear',
                                          fontWeight: FontWeight.w600),
                                    ),
                                    TextSpan(
                                      text: "Network Advertising Initiative",
                                      style: const TextStyle(
                                          fontSize: 15,
                                          decoration: TextDecoration.underline,
                                          color: Colors.blue,
                                          fontFamily: 'DPClear',
                                          fontWeight: FontWeight.w600),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          'https://thenai.org/about-online-advertising/';
                                        },
                                    ),
                                    const TextSpan(
                                      text: " (US) and the ",
                                      style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.white,
                                          fontFamily: 'DPClear',
                                          fontWeight: FontWeight.w600),
                                    ),
                                    TextSpan(
                                      text: "Digital Advertising Alliance ",
                                      style: const TextStyle(
                                          fontSize: 15,
                                          decoration: TextDecoration.underline,
                                          color: Colors.blue,
                                          fontFamily: 'DPClear',
                                          fontWeight: FontWeight.w600),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          'https://youradchoices.com/control';
                                        },
                                    ),
                                    const TextSpan(
                                      text: " (US), ",
                                      style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.white,
                                          fontFamily: 'DPClear',
                                          fontWeight: FontWeight.w600),
                                    ),
                                    TextSpan(
                                      text: " DAAC ",
                                      style: const TextStyle(
                                          fontSize: 15,
                                          decoration: TextDecoration.underline,
                                          color: Colors.blue,
                                          fontFamily: 'DPClear',
                                          fontWeight: FontWeight.w600),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          'https://youradchoices.ca/en/learn';
                                        },
                                    ),
                                    const TextSpan(
                                      text: " (Canada), ",
                                      style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.white,
                                          fontFamily: 'DPClear',
                                          fontWeight: FontWeight.w600),
                                    ),
                                    TextSpan(
                                      text: " DDAI  ",
                                      style: const TextStyle(
                                          fontSize: 15,
                                          decoration: TextDecoration.underline,
                                          color: Colors.blue,
                                          fontFamily: 'DPClear',
                                          fontWeight: FontWeight.w600),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          'http://www.ddai.info/optout';
                                        },
                                    ),
                                    const TextSpan(
                                      text:
                                          " (Japan) or other similar initiatives. Such initiatives allow Users to select their tracking preferences for most of the advertising tools. The Owner thus recommends that Users make use of these resources in addition to the information provided in this document. ",
                                      style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.white,
                                          fontFamily: 'DPClear',
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                                margin: const EdgeInsets.only(
                                  top: 15,
                                ),
                                child: const TextFieldWidget(
                                    text:
                                        'The Digital Advertising Alliance offers an application called AppChoices that helps Users to control interest-based advertising on mobile apps.',
                                    size: 15,
                                    weight: FontWeight.w400,
                                    color: Colors.white)),
                            Container(
                                margin:
                                    const EdgeInsets.only(top: 15, left: 15),
                                child: const TextFieldWidget(
                                    text:
                                        'Users may also opt-out of certain advertising features through applicable device settings, such as the device advertising settings for mobile phones or ads settings in general',
                                    size: 15,
                                    weight: FontWeight.w400,
                                    color: Colors.white)),
                            Container(
                                margin: const EdgeInsets.only(
                                  top: 15,
                                ),
                                child: const TextFieldWidget(
                                    text:
                                        'Success Subliminals LLC Privacy Policy does not apply to other advertisers or websites. Thus, we are advising you to consult the respective Privacy Policies of these third-party ad servers for more detailed information. It may include their practices and instructions about how to opt-out of certain options.',
                                    size: 15,
                                    weight: FontWeight.w400,
                                    color: Colors.white)),
                            Container(
                                margin: const EdgeInsets.only(
                                  top: 15,
                                ),
                                child: const TextFieldWidget(
                                    text:
                                        'You can choose to disable cookies through your individual browser options. To know more detailed information about cookie management with specific web browsers, it can be found at the browsers respective websites.',
                                    size: 15,
                                    weight: FontWeight.w400,
                                    color: Colors.white)),
                            Container(
                              margin: const EdgeInsets.only(top: 20),
                              child: const TextFieldWidget500(
                                  text: "Mode and place of processing the Data",
                                  size: 24,
                                  color: Colors.white,
                                  textAlign: TextAlign.center),
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 20),
                              child: const TextFieldWidget500(
                                  text: "Methods of processing",
                                  size: 24,
                                  color: Colors.white,
                                  textAlign: TextAlign.center),
                            ),
                            Container(
                                margin: const EdgeInsets.only(
                                  top: 15,
                                ),
                                child: const TextFieldWidget(
                                    text:
                                        'The Owner takes appropriate security measures to prevent unauthorized access, disclosure, modification, or unauthorized destruction of the Data.The Data processing is carried out using computers and/or IT enabled tools, following organizational procedures and modes strictly related to the purposes indicated. In addition to the Owner, in some cases, the Data may be accessible to certain types of persons in charge, involved with the operation of this Application (administration, sales, marketing, legal, system administration) or external parties (such as third-party technical service providers, mail carriers, hosting providers, IT companies, communications agencies) appointed, if necessary, as Data Processors by the Owner. The updated list of these parties may be requested from the Owner at any time.',
                                    size: 15,
                                    weight: FontWeight.w400,
                                    color: Colors.white)),
                            Container(
                                margin: const EdgeInsets.only(
                                  top: 20,
                                ),
                                child: const TextFieldWidget500(
                                    text: 'Legal basis of processing',
                                    size: 24,
                                    color: Colors.white,
                                    textAlign: TextAlign.center)),
                            Container(
                                margin: const EdgeInsets.only(
                                  top: 15,
                                ),
                                child: const TextFieldWidget(
                                    text:
                                        'The Owner may process Personal Data relating to Users if one of the following applies:',
                                    size: 15,
                                    weight: FontWeight.w400,
                                    color: Colors.white)),
                            Container(
                                margin:
                                    const EdgeInsets.only(top: 15, left: 15),
                                child: const TextFieldWidget(
                                    text:
                                        '• Users have given their consent for one or more specific purposes. Note: Under some legislations the Owner may be allowed to process Personal Data until the User objects to such processing (“opt-out”), without having to rely on consent or any other of the following legal bases. This, however, does not apply, whenever the processing of Personal Data is subject to European data protection law;\n• provision of Data is necessary for the performance of an agreement with the User and/or for any pre-contractual obligations thereof;\n• processing is necessary for compliance with a legal obligation to which the Owner is subject;\n• processing is related to a task that is carried out in the public interest or in the exercise of official authority vested in the Owner;\n• processing is necessary for the purposes of the legitimate interests pursued by the Owner or by a third party.',
                                    size: 15,
                                    weight: FontWeight.w400,
                                    color: Colors.white)),
                            Container(
                                margin: const EdgeInsets.only(
                                  top: 20,
                                ),
                                child: const TextFieldWidget500(
                                    text: 'Place',
                                    size: 24,
                                    color: Colors.white,
                                    textAlign: TextAlign.center)),
                            Container(
                                margin: const EdgeInsets.only(top: 15),
                                child: const TextFieldWidget(
                                    text:
                                        'The Data is processed at the Owner operating offices and in any other places where the parties involved in the processing are located.',
                                    size: 15,
                                    weight: FontWeight.w400,
                                    color: Colors.white)),
                            Container(
                                margin: const EdgeInsets.only(top: 15),
                                child: const TextFieldWidget(
                                    text:
                                        'Depending on the User location, data transfers may involve transferring the User Data to a country other than their own. To find out more about the place of processing of such transferred Data, Users can check the section containing details about the processing of Personal Data.',
                                    size: 15,
                                    weight: FontWeight.w400,
                                    color: Colors.white)),
                            Container(
                                margin:
                                    const EdgeInsets.only(top: 15, left: 15),
                                child: const TextFieldWidget(
                                    text:
                                        'Users are also entitled to learn about the legal basis of Data transfers to a country outside the European Union or to any international organization governed by public international law or set up by two or more countries, such as the UN, and about the security measures taken by the Owner to safeguard their Data.',
                                    size: 15,
                                    weight: FontWeight.w400,
                                    color: Colors.white)),
                            Container(
                                margin: const EdgeInsets.only(top: 15),
                                child: const TextFieldWidget(
                                    text:
                                        'If any such transfer takes place, Users can find out more by checking the relevant sections of this document or inquire with the Owner using the information provided in the contact section.',
                                    size: 15,
                                    weight: FontWeight.w400,
                                    color: Colors.white)),
                            Container(
                                margin: const EdgeInsets.only(
                                  top: 20,
                                ),
                                child: const TextFieldWidget500(
                                    text: 'Retention time',
                                    size: 24,
                                    color: Colors.white,
                                    textAlign: TextAlign.center)),
                            Container(
                                margin: const EdgeInsets.only(top: 15),
                                child: const TextFieldWidget(
                                    text:
                                        'Personal Data shall be processed and stored for as long as required by the purpose they have been collected for.',
                                    size: 15,
                                    weight: FontWeight.w400,
                                    color: Colors.white)),
                            Container(
                                margin: const EdgeInsets.only(top: 15),
                                child: const TextFieldWidget(
                                    text: 'Therefore:',
                                    size: 15,
                                    weight: FontWeight.w400,
                                    color: Colors.white)),
                            Container(
                                margin:
                                    const EdgeInsets.only(top: 15, left: 15),
                                child: const TextFieldWidget(
                                    text:
                                        '• Personal Data collected for purposes related to the performance of a contract between the Owner and the User shall be retained until such contract has been fully performed.\n• Personal Data collected for the purposes of the Owner’s legitimate interests shall be retained as long as needed to fulfill such purposes. Users may find specific information regarding the legitimate interests pursued by the Owner within the relevant sections of this document or by contacting the Owner.',
                                    size: 15,
                                    weight: FontWeight.w400,
                                    color: Colors.white)),
                            Container(
                                margin: const EdgeInsets.only(top: 15),
                                child: const TextFieldWidget(
                                    text:
                                        'The Owner may be allowed to retain Personal Data for a longer period whenever the User has given consent to such processing, as long as such consent is not withdrawn. Furthermore, the Owner may be obliged to retain Personal Data for a longer period whenever required to do so for the performance of a legal obligation or upon order of an authority.',
                                    size: 15,
                                    weight: FontWeight.w400,
                                    color: Colors.white)),
                            Container(
                                margin: const EdgeInsets.only(top: 15),
                                child: const TextFieldWidget(
                                    text:
                                        'Once the retention period expires, Personal Data shall be deleted. Therefore, the right of access, the right to erasure, the right to rectification and the right to data portability cannot be enforced after expiration of the retention period.',
                                    size: 15,
                                    weight: FontWeight.w400,
                                    color: Colors.white)),
                            Container(
                                margin: const EdgeInsets.only(
                                  top: 20,
                                ),
                                child: const TextFieldWidget500(
                                    text: 'The purposes of processing',
                                    size: 24,
                                    color: Colors.white,
                                    textAlign: TextAlign.center)),
                            Container(
                                margin: const EdgeInsets.only(top: 15),
                                child: const TextFieldWidget(
                                    text:
                                        'The Data concerning the User is collected to allow the Owner to provide its Service, comply with its legal obligations, respond to enforcement requests, protect its rights and interests (or those of its Users or third parties), detect any malicious or fraudulent activity, as well as the following: Analytics and Remarketing and behavioral targeting.',
                                    size: 15,
                                    weight: FontWeight.w400,
                                    color: Colors.white)),
                            Container(
                                margin: const EdgeInsets.only(top: 15),
                                child: const TextFieldWidget(
                                    text:
                                        'For specific information about the Personal Data used for each purpose, the User may refer to the section “Detailed information on the processing of Personal Data”.',
                                    size: 15,
                                    weight: FontWeight.w400,
                                    color: Colors.white)),
                            Container(
                                margin: const EdgeInsets.only(
                                  top: 20,
                                ),
                                child: const TextFieldWidget500(
                                    text:
                                        'Detailed information on the processing of Personal Data',
                                    size: 24,
                                    color: Colors.white,
                                    textAlign: TextAlign.center)),
                            Container(
                                margin: const EdgeInsets.only(top: 15),
                                child: const TextFieldWidget(
                                    text:
                                        'Personal Data is collected for the following purposes and using the following services:',
                                    size: 15,
                                    weight: FontWeight.w400,
                                    color: Colors.white)),
                            Container(
                                margin: const EdgeInsets.only(top: 15),
                                child: const TextFieldWidget(
                                    text:
                                        '• Analytics\n• Remarketing and behavioral targeting',
                                    size: 15,
                                    weight: FontWeight.w400,
                                    color: Colors.white)),
                            Container(
                                margin: const EdgeInsets.only(
                                  top: 20,
                                ),
                                child: const TextFieldWidget500(
                                    text:
                                        'Additional information about Data collection and processing',
                                    size: 24,
                                    color: Colors.white,
                                    textAlign: TextAlign.center)),
                            Container(
                                margin: const EdgeInsets.only(
                                  top: 20,
                                ),
                                child: const TextFieldWidget500(
                                    text: 'Legal action',
                                    size: 20,
                                    color: Colors.white,
                                    textAlign: TextAlign.center)),
                            Container(
                                margin: const EdgeInsets.only(top: 15),
                                child: const TextFieldWidget(
                                    text:
                                        'The User Personal Data may be used for legal purposes by the Owner in Court or in the stages leading to possible legal action arising from improper use of this Application or the related Services.The User declares to be aware that the Owner may be required to reveal personal data upon request of public authorities.',
                                    size: 15,
                                    weight: FontWeight.w400,
                                    color: Colors.white)),
                            Container(
                                margin: const EdgeInsets.only(
                                  top: 20,
                                ),
                                child: const TextFieldWidget500(
                                    text:
                                        'Additional information about User Personal Data',
                                    size: 20,
                                    color: Colors.white,
                                    textAlign: TextAlign.center)),
                            Container(
                                margin: const EdgeInsets.only(top: 15),
                                child: const TextFieldWidget(
                                    text:
                                        'In addition to the information contained in this privacy policy, this Application may provide the User with additional and contextual information concerning particular Services or the collection and processing of Personal Data upon request.',
                                    size: 15,
                                    weight: FontWeight.w400,
                                    color: Colors.white)),
                            Container(
                                margin: const EdgeInsets.only(
                                  top: 20,
                                ),
                                child: const TextFieldWidget500(
                                    text: 'System logs and maintenance',
                                    size: 20,
                                    color: Colors.white,
                                    textAlign: TextAlign.center)),
                            Container(
                                margin: const EdgeInsets.only(top: 15),
                                child: const TextFieldWidget(
                                    text:
                                        'For operation and maintenance purposes, this Application and any third-party services may collect files that record interaction with this Application (System logs) or use other Personal Data (such as the IP Address) for this purpose.',
                                    size: 15,
                                    weight: FontWeight.w400,
                                    color: Colors.white)),
                            Container(
                                margin: const EdgeInsets.only(
                                  top: 20,
                                ),
                                child: const TextFieldWidget500(
                                    text:
                                        'Information not contained in this policy',
                                    size: 20,
                                    color: Colors.white,
                                    textAlign: TextAlign.center)),
                            Container(
                                margin: const EdgeInsets.only(top: 15),
                                child: const TextFieldWidget(
                                    text:
                                        'More details concerning the collection or processing of Personal Data may be requested from the Owner at any time. Please see the contact information at the beginning of this document.',
                                    size: 15,
                                    weight: FontWeight.w400,
                                    color: Colors.white)),
                            Container(
                                margin: const EdgeInsets.only(
                                  top: 20,
                                ),
                                child: const TextFieldWidget500(
                                    text:
                                        'How “Do Not Track” requests are handled',
                                    size: 20,
                                    color: Colors.white,
                                    textAlign: TextAlign.center)),
                            Container(
                                margin: const EdgeInsets.only(top: 15),
                                child: const TextFieldWidget(
                                    text:
                                        'This Application does not support “Do Not Track” requests.\nTo determine whether any of the third-party services it uses honor the “Do Not Track” requests, please read their privacy policies.',
                                    size: 15,
                                    weight: FontWeight.w400,
                                    color: Colors.white)),
                            Container(
                                margin: const EdgeInsets.only(
                                  top: 20,
                                ),
                                child: const TextFieldWidget500(
                                    text: 'Changes to this privacy policy',
                                    size: 20,
                                    color: Colors.white,
                                    textAlign: TextAlign.center)),
                            Container(
                                margin: const EdgeInsets.only(top: 15),
                                child: const TextFieldWidget(
                                    text:
                                        'The Owner reserves the right to make changes to this privacy policy at any time by notifying its Users on this page and possibly within this Application and/or - as far as technically and legally feasible - sending a notice to Users via any contact information available to the Owner. It is strongly recommended to check this page often, referring to the date of the last modification listed at the bottom.\nShould the changes affect processing activities performed on the basis of the User’s consent, the Owner shall collect new consent from the User, where required.',
                                    size: 15,
                                    weight: FontWeight.w400,
                                    color: Colors.white)),
                            Container(
                                margin: const EdgeInsets.only(
                                  top: 20,
                                ),
                                child: const TextFieldWidget500(
                                    text:
                                        'CCPA Privacy Rights (Do Not Sell My Personal Information)',
                                    size: 20,
                                    color: Colors.white,
                                    textAlign: TextAlign.center)),
                            Container(
                                margin: const EdgeInsets.only(top: 15),
                                child: const TextFieldWidget(
                                    text:
                                        'Under the CCPA, among other rights, California consumers have the right to:\n\nRequest that a business that collects a consumer personal data disclose the categories and specific pieces of personal data that a business has collected about consumers.\n\nRequest that a business delete any personal data about the consumer that a business has collected.\n\nRequest that a business that sells a consumer personal data, not sell the consumer personal data.\n\nIf you make a request, we have one month to respond to you. If you would like to exercise any of these rights, please contact us.',
                                    size: 15,
                                    weight: FontWeight.w400,
                                    color: Colors.white)),
                            Container(
                                margin: const EdgeInsets.only(
                                  top: 20,
                                ),
                                child: const TextFieldWidget500(
                                    text: 'GDPR Data Protection Rights',
                                    size: 20,
                                    color: Colors.white,
                                    textAlign: TextAlign.center)),
                            Container(
                                margin: const EdgeInsets.only(top: 15),
                                child: const TextFieldWidget(
                                    text:
                                        'We would like to make sure you are fully aware of all of your data protection rights. Every user is entitled to the following:\n\nThe right to access – You have the right to request copies of your personal data. We may charge you a small fee for this service.\n\nThe right to rectification – You have the right to request that we correct any information you believe is inaccurate. You also have the right to request that we complete the information you believe is incomplete.\n\nThe right to erasure – You have the right to request that we erase your personal data, under certain conditions.\n\nThe right to restrict processing – You have the right to request that we restrict the processing of your personal data, under certain conditions.\n\nThe right to object to processing – You have the right to object to our processing of your personal data, under certain conditions.\n\nThe right to data portability – You have the right to request that we transfer the data that we have collected to another organization, or directly to you, under certain conditions.\n\nIf you make a request, we have one month to respond to you. If you would like to exercise any of these rights, please contact us.',
                                    size: 15,
                                    weight: FontWeight.w400,
                                    color: Colors.white)),
                            Container(
                                margin: const EdgeInsets.only(
                                  top: 20,
                                ),
                                child: const TextFieldWidget500(
                                    text: 'Children\'s Information',
                                    size: 20,
                                    color: Colors.white,
                                    textAlign: TextAlign.center)),
                            Container(
                                margin: const EdgeInsets.only(top: 15),
                                child: const TextFieldWidget(
                                    text:
                                        'Another part of our priority is adding protection for children while using the internet. We encourage parents and guardians to observe, participate in, and/or monitor and guide their online activity.\n\nSuccess Subliminals LLC does not knowingly collect any Personal Identifiable Information from children under the age of 13. If you think that your child provided this kind of information on our website, we strongly encourage you to contact us immediately and we will do our best efforts to promptly remove such information from our records.',
                                    size: 15,
                                    weight: FontWeight.w400,
                                    color: Colors.white)),
                            Container(
                                margin: const EdgeInsets.only(
                                  top: 20,
                                ),
                                child: const TextFieldWidget500(
                                    text: 'Changes to This Privacy Policy',
                                    size: 20,
                                    color: Colors.white,
                                    textAlign: TextAlign.center)),
                            Container(
                                margin: const EdgeInsets.only(top: 15),
                                child: const TextFieldWidget(
                                    text:
                                        'We may update our Privacy Policy from time to time. Thus, we advise you to review this page periodically for any changes. We will notify you of any changes by posting the new Privacy Policy on this page. These changes are effective immediately, after they are posted on this page.\nOur Privacy Policy was created with the help of the Privacy Policy Generator.',
                                    size: 15,
                                    weight: FontWeight.w400,
                                    color: Colors.white)),
                            Container(
                                margin: const EdgeInsets.only(
                                  top: 20,
                                ),
                                child: const TextFieldWidget500(
                                    text: 'Contact Us',
                                    size: 20,
                                    color: Colors.white,
                                    textAlign: TextAlign.center)),
                            Container(
                                margin: const EdgeInsets.only(top: 15),
                                child: const TextFieldWidget(
                                    text:
                                        'If you have any questions or suggestions about our Privacy Policy, do not hesitate to contact us.\n\nsupport@successsubliminals.net',
                                    size: 15,
                                    weight: FontWeight.w400,
                                    color: Colors.white)),
                          ]),
                    ],
                  ),
                ))
          ])),
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
              'Privacy Policy',
              style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontFamily: 'DPClear',
                  fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ],
    );
  }
}
