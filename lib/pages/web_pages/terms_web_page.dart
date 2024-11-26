import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
/*import 'package:html_unescape/html_unescape.dart';*/
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/constant.dart';
import '../../utils/shared_prefs.dart';
import '../../widget/TextFieldWidget400.dart';
import '../../widget/TextFieldWidget500.dart';
import '../../widget/TopBarWebWithoutLogin.dart';
import '../../widget/WebTopBarContainer.dart';

class TermsWebPage extends StatefulWidget {
  const TermsWebPage({
    Key? key,
  }) : super(key: key);

  @override
  TermsWebPageState createState() => TermsWebPageState();
}

class TermsWebPageState extends State<TermsWebPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late dynamic subliminalDetail;
  late dynamic subliminalDataDetail;
  bool isLoading = false;
  bool isSubliminal = false;
  bool isTrial = false;
  bool isLogin = false;
  late dynamic subliminal;
  double screenWidth = 900;

  @override
  void initState() {
    super.initState();

    initializePreference().whenComplete(() {
      setState(() {});
    });
    isLogin = SharedPrefs().isLogin();
    if (kDebugMode) {
      print("loginStatus--$isLogin");
    }
  }

/*  String unescapedString = HtmlUnescape().convert(htmlContent);*/

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
              if (kDebugMode) {
                print(screenWidth);
              }
              return buildHomeContainer(context, mq);
            } else {
              screenWidth = 800;
              if (kDebugMode) {
                print(screenWidth);
              }
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
        child: Stack(
          children: <Widget>[
            screenWidth < 850
                ? buildTopBarContainer(context, mq)
                : screenWidth > 850 && isLogin
                    ? const WebTopBarContainer(screen: 'home')
                    : TopBarWithoutLoginContainer(screen: "home", mq: mq),
            Container(
              margin: EdgeInsets.only(
                  left: screenWidth < 850 ? 25 : loginLeftPadding,
                  right: screenWidth < 850 ? 25 : loginRightPadding,
                  top: screenWidth < 850 ? 70 : loginTopPadding,
                  bottom: screenWidth < 850 ? 15 : 30),
              child: ListView(
                shrinkWrap: false,
                primary: true,
                children: [
                  Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 15),
                          child: const TextFieldWidget500(
                              text: "Terms and Conditions",
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
                                text: "Welcome to Success Subliminals!",
                                size: 15,
                                weight: FontWeight.w400,
                                color: Colors.white)),
                        Container(
                            margin: const EdgeInsets.only(top: 15),
                            child: const TextFieldWidget(
                                text:
                                    "These terms and conditions outline the rules and regulations for the use of Success Subliminals LLC Website, located at successsubliminals.net.",
                                size: 15,
                                weight: FontWeight.w400,
                                color: Colors.white)),
                        Container(
                            margin: const EdgeInsets.only(top: 15),
                            child: const TextFieldWidget(
                                text:
                                    "By accessing this website we assume you accept these terms and conditions. Do not continue to use Success Subliminals LLC if you do not agree to take all of the terms and conditions stated on this page.",
                                size: 15,
                                weight: FontWeight.w400,
                                color: Colors.white)),
                        Container(
                            margin: const EdgeInsets.only(top: 15),
                            child: TextFieldWidget(
                                text: followingTerms,
                                size: 15,
                                weight: FontWeight.w400,
                                color: Colors.white)),
                        Container(
                          margin: const EdgeInsets.only(top: 20),
                          child: const TextFieldWidget500(
                              text: "Cookies",
                              size: 24,
                              color: Colors.white,
                              textAlign: TextAlign.center),
                        ),
                        Container(
                            margin: const EdgeInsets.only(top: 15),
                            child: const TextFieldWidget(
                                text:
                                    "We employ the use of cookies. By accessing Success Subliminals LLC, you agreed to use cookies in agreement with the Success Subliminals LLC Privacy Policy.",
                                size: 15,
                                weight: FontWeight.w400,
                                color: Colors.white)),
                        Container(
                            margin: const EdgeInsets.only(top: 15),
                            child: const TextFieldWidget(
                                text:
                                    "Most interactive websites use cookies to let us retrieve the user's details for each visit. Cookies are used by our website to enable the functionality of certain areas to make it easier for people visiting our website. Some of our affiliate/advertising partners may also use cookies.",
                                size: 15,
                                weight: FontWeight.w400,
                                color: Colors.white)),
                        Container(
                          margin: const EdgeInsets.only(top: 20),
                          child: const TextFieldWidget500(
                              text: "License",
                              size: 24,
                              color: Colors.white,
                              textAlign: TextAlign.center),
                        ),
                        Container(
                            margin: const EdgeInsets.only(top: 15),
                            child: const TextFieldWidget(
                                text:
                                    "Unless otherwise stated, Success Subliminals LLC and/or its licensors own the intellectual property rights for all material on Success Subliminals LLC. All intellectual property rights are reserved. You may access this from Success Subliminals LLC for your own personal use subjected to restrictions set in these terms and conditions.",
                                size: 15,
                                weight: FontWeight.w400,
                                color: Colors.white)),
                        Container(
                            margin: const EdgeInsets.only(top: 15),
                            child: const TextFieldWidget(
                                text: "You must not:",
                                size: 15,
                                weight: FontWeight.w400,
                                color: Colors.white)),
                        Container(
                            margin: const EdgeInsets.only(top: 15, left: 20),
                            child: const TextFieldWidget(
                                text: kLicence,
                                size: 15,
                                weight: FontWeight.w400,
                                color: Colors.white)),
                        Container(
                            margin: const EdgeInsets.only(top: 15),
                            child: const TextFieldWidget(
                                text:
                                    'This Agreement shall begin on the date here of. Our Terms and Conditions were created with the help of the Terms and Conditions Generator.',
                                size: 15,
                                weight: FontWeight.w400,
                                color: Colors.white)),
                        Container(
                            margin: const EdgeInsets.only(top: 15),
                            child: TextFieldWidget(
                                text: partOfWebsite,
                                size: 15,
                                weight: FontWeight.w400,
                                color: Colors.white)),
                        Container(
                            margin: const EdgeInsets.only(top: 15),
                            child: const TextFieldWidget(
                                text:
                                    'Success Subliminals LLC reserves the right to monitor all Comments and to remove any Comments which can be considered inappropriate, offensive or causes breach of these Terms and Conditions.',
                                size: 15,
                                weight: FontWeight.w400,
                                color: Colors.white)),
                        Container(
                            margin: const EdgeInsets.only(top: 15),
                            child: const TextFieldWidget(
                                text: 'You warrant and represent that:',
                                size: 15,
                                weight: FontWeight.w400,
                                color: Colors.white)),
                        Container(
                            margin: const EdgeInsets.only(top: 15, left: 15),
                            child: const TextFieldWidget(
                                text:
                                    '• You are entitled to post the Comments on our website and have all necessary licenses and consents to do so;\n• The Comments do not invade any intellectual property right, including without limitation copyright, patent or trademark of any third party;\n• The Comments do not contain any defamatory, libelous, offensive, indecent or otherwise unlawful material which is an invasion of privacy\n• The Comments will not be used to solicit or promote business or custom or present commercial activities or unlawful activity.',
                                size: 15,
                                weight: FontWeight.w400,
                                color: Colors.white)),
                        Container(
                            margin: const EdgeInsets.only(top: 15),
                            child: const TextFieldWidget(
                                text:
                                    'These organizations may link to our home page, to publications or to other Website information so long as the link: (a) is not in any way deceptive; (b) does not falsely imply sponsorship, endorsement or approval of the linking party and its products and/or services; and (c) fits within the context of the linking party site.',
                                size: 15,
                                weight: FontWeight.w400,
                                color: Colors.white)),
                        Container(
                            margin: const EdgeInsets.only(top: 15),
                            child: const TextFieldWidget(
                                text:
                                    'We may consider and approve other link requests from the following types of organizations:',
                                size: 15,
                                weight: FontWeight.w400,
                                color: Colors.white)),
                        Container(
                            margin: const EdgeInsets.only(top: 15, left: 15),
                            child: const TextFieldWidget(
                                text:
                                    '• commonly-known consumer and/or business information sources;\n• com community sites;\n• associations or other groups representing charities;\n• online directory distributors;\n• internet portals;\n• accounting, law and consulting firms; and\n• educational institutions and trade associations.',
                                size: 15,
                                weight: FontWeight.w400,
                                color: Colors.white)),
                        Container(
                            margin: const EdgeInsets.only(
                              top: 15,
                            ),
                            child: const TextFieldWidget(
                                text:
                                    'We will approve link requests from these organizations if we decide that: (a) the link would not make us look unfavorably to ourselves or to our accredited businesses; (b) the organization does not have any negative records with us; (c) the benefit to us from the visibility of the hyperlink compensates the absence of Success Subliminals LLC; and (d) the link is in the context of general resource information.',
                                size: 15,
                                weight: FontWeight.w400,
                                color: Colors.white)),
                        Container(
                            margin: const EdgeInsets.only(
                              top: 15,
                            ),
                            child: const TextFieldWidget(
                                text:
                                    'These organizations may link to our home page so long as the link: (a) is not in any way deceptive; (b) does not falsely imply sponsorship, endorsement or approval of the linking party and its products or services; and (c) fits within the context of the linking party site.',
                                size: 15,
                                weight: FontWeight.w400,
                                color: Colors.white)),
                        Container(
                            margin: const EdgeInsets.only(
                              top: 15,
                            ),
                            child: const TextFieldWidget(
                                text:
                                    'If you are one of the organizations listed in paragraph 2 above and are interested in linking to our website, you must inform us by sending an e-mail to Success Subliminals LLC. Please include your name, your organization name, contact information as well as the URL of your site, a list of any URLs from which you intend to link to our Website, and a list of the URLs on our site to which you would like to link. Wait 2-3 weeks for a response.',
                                size: 15,
                                weight: FontWeight.w400,
                                color: Colors.white)),
                        Container(
                            margin: const EdgeInsets.only(
                              top: 15,
                            ),
                            child: const TextFieldWidget(
                                text:
                                    'Approved organizations may hyperlink to our Website as follows:',
                                size: 15,
                                weight: FontWeight.w400,
                                color: Colors.white)),
                        Container(
                            margin: const EdgeInsets.only(
                              top: 15,
                            ),
                            child: const TextFieldWidget(
                                text:
                                    'Approved organizations may hyperlink to our Website as follows:',
                                size: 15,
                                weight: FontWeight.w400,
                                color: Colors.white)),
                        Container(
                            margin: const EdgeInsets.only(top: 15, left: 15),
                            child: const TextFieldWidget(
                                text:
                                    '• By use of our corporate name; or\n• By use of the uniform resource locator being linked to; or\n• By use of any other description of our Website being linked to that makes sense within the context and format of content on the linking party site.',
                                size: 15,
                                weight: FontWeight.w400,
                                color: Colors.white)),
                        Container(
                            margin: const EdgeInsets.only(
                              top: 15,
                            ),
                            child: const TextFieldWidget(
                                text:
                                    'No use of Success Subliminals LLC logo or other artwork will be allowed for linking absent a trademark license agreement.',
                                size: 15,
                                weight: FontWeight.w400,
                                color: Colors.white)),
                        Container(
                          margin: const EdgeInsets.only(top: 20),
                          child: const TextFieldWidget500(
                              text: "iFrames",
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
                                    'Without prior approval and written permission, you may not create frames around our Webpages that alter in any way the visual presentation or appearance of our Website.',
                                size: 15,
                                weight: FontWeight.w400,
                                color: Colors.white)),
                        Container(
                          margin: const EdgeInsets.only(top: 20),
                          child: const TextFieldWidget500(
                              text: "Content Liability",
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
                                    'We shall not be hold responsible for any content that appears on your Website. You agree to protect and defend us against all claims that is rising on your Website. No link(s) should appear on any Website that may be interpreted as libelous, obscene or criminal, or which infringes, otherwise violates, or advocates the infringement or other violation of, any third party rights.',
                                size: 15,
                                weight: FontWeight.w400,
                                color: Colors.white)),
                        Container(
                          margin: const EdgeInsets.only(top: 20),
                          child: const TextFieldWidget500(
                              text: "Reservation of Rights",
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
                                    'We reserve the right to request that you remove all links or any particular link to our Website. You approve to immediately remove all links to our Website upon request. We also reserve the right to amen these terms and conditions and it is linking policy at any time. By continuously linking to our Website, you agree to be bound to and follow these linking terms and conditions.',
                                size: 15,
                                weight: FontWeight.w400,
                                color: Colors.white)),
                        Container(
                          margin: const EdgeInsets.only(top: 20),
                          child: const TextFieldWidget500(
                              text: "Removal of links from our website",
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
                                    'If you find any link on our Website that is offensive for any reason, you are free to contact and inform us any moment. We will consider requests to remove links but we are not obligated to or so or to respond to you directly.',
                                size: 15,
                                weight: FontWeight.w400,
                                color: Colors.white)),
                        Container(
                            margin: const EdgeInsets.only(
                              top: 15,
                            ),
                            child: const TextFieldWidget(
                                text:
                                    'We do not ensure that the information on this website is correct, we do not warrant its completeness or accuracy; nor do we promise to ensure that the website remains available or that the material on the website is kept up to date.',
                                size: 15,
                                weight: FontWeight.w400,
                                color: Colors.white)),
                        Container(
                          margin: const EdgeInsets.only(top: 20),
                          child: const TextFieldWidget500(
                              text: "Disclaimer",
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
                                    'To the maximum extent permitted by applicable law, we exclude all representations, warranties and conditions relating to our website and the use of this website. Nothing in this disclaimer will:',
                                size: 15,
                                weight: FontWeight.w400,
                                color: Colors.white)),
                        Container(
                            margin: const EdgeInsets.only(top: 15, left: 15),
                            child: const TextFieldWidget(
                                text:
                                    '• limit or exclude our or your liability for death or personal injury;\n• limit or exclude our or your liability for fraud or fraudulent misrepresentation;\n• limit any of our or your liabilities in any way that is not permitted under applicable law; or\n• exclude any of our or your liabilities that may not be excluded under applicable law.',
                                size: 15,
                                weight: FontWeight.w400,
                                color: Colors.white)),
                        Container(
                            margin: const EdgeInsets.only(
                              top: 15,
                            ),
                            child: const TextFieldWidget(
                                text:
                                    'The limitations and prohibitions of liability set in this Section and elsewhere in this disclaimer: (a) are subject to the preceding paragraph; and (b) govern all liabilities arising under the disclaimer, including liabilities arising in contract, in tort and for breach of statutory duty.',
                                size: 15,
                                weight: FontWeight.w400,
                                color: Colors.white)),
                        Container(
                            margin: const EdgeInsets.only(
                              top: 15,
                            ),
                            child: const TextFieldWidget(
                                text:
                                    'As long as the website and the information and services on the website are provided free',
                                size: 15,
                                weight: FontWeight.w400,
                                color: Colors.white)),
                        Container(
                          margin: const EdgeInsets.only(top: 20),
                          child: const TextFieldWidget500(
                              text: "Returns & Refunds",
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
                                    'Success Subliminals LLC is committed to your satisfaction. If you have purchased digital subscription from Success Subliminals LLC and are unhappy with the product received, you may be eligible for a refund/partial refund if requested within 30 days of the original purchase date.',
                                size: 15,
                                weight: FontWeight.w400,
                                color: Colors.white)),
                        Container(
                            margin: const EdgeInsets.only(
                              top: 15,
                            ),
                            child: const TextFieldWidget(
                                text: 'Non-returnable Items:',
                                size: 15,
                                weight: FontWeight.w400,
                                color: Colors.white)),
                        Container(
                            margin: const EdgeInsets.only(
                              top: 15,
                            ),
                            child: const TextFieldWidget(
                                text:
                                    'The following items are non-returnable as stated at the time of purchase on successsubliminals.net',
                                size: 15,
                                weight: FontWeight.w400,
                                color: Colors.white)),
                        Container(
                            margin: const EdgeInsets.only(top: 15, left: 15),
                            child: const TextFieldWidget(
                                text: '• Individual Subliminals',
                                size: 15,
                                weight: FontWeight.w400,
                                color: Colors.white)),
                        Container(
                            margin: const EdgeInsets.only(top: 15),
                            child: const TextFieldWidget(
                                text:
                                    'Refunds of Digital/Subscription Based Goods:',
                                size: 15,
                                weight: FontWeight.w400,
                                color: Colors.white)),
                        Container(
                            margin: const EdgeInsets.only(top: 15),
                            child: const TextFieldWidget(
                                text:
                                    'To be eligible for a refund on any digital/subscription based goods, the following steps must be taken:    ',
                                size: 15,
                                weight: FontWeight.w400,
                                color: Colors.white)),
                        Container(
                            margin: const EdgeInsets.only(top: 15, left: 15),
                            child: const TextFieldWidget(
                                text:
                                    '• Refund must be requested in writing by contacting support@successsubliminals.net\n• Request of refund must be made within 30 days of the original purchase date    ',
                                size: 15,
                                weight: FontWeight.w400,
                                color: Colors.white)),
                        Container(
                            margin: const EdgeInsets.only(top: 15),
                            child: const TextFieldWidget(
                                text:
                                    'Success Subliminals LLC is committed to its consumers, and while we stand by our policy as written above, we also want to understand how we can resolve the dissatisfaction and better understand how we can serve you. Please contact Success Subliminals at support@successsubliminals.net for any questions related to our policy, or simply to let us know how we can help.',
                                size: 15,
                                weight: FontWeight.w400,
                                color: Colors.white)),
                        Container(
                            margin: const EdgeInsets.only(top: 15),
                            child: const TextFieldWidget(
                                text: 'Success Subliminals',
                                size: 15,
                                weight: FontWeight.w400,
                                color: Colors.white)),
                        Container(
                            margin: const EdgeInsets.only(top: 15),
                            child: const TextFieldWidget(
                                text: 'support@successsubliminals.net',
                                size: 15,
                                weight: FontWeight.w400,
                                color: Colors.white)),
                      ]),
                ],
              ),
            )
          ],
        ),
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
              'Terms and Conditions',
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
