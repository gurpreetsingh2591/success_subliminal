import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:go_router/go_router.dart';
import 'package:success_subliminal/pages/downloaded_sub_page.dart';
import 'package:success_subliminal/pages/home_page.dart';
import 'package:success_subliminal/pages/sign_up_page.dart';
import 'package:success_subliminal/pages/signin_page.dart';
import 'package:success_subliminal/pages/subscription_list_page.dart';
import 'package:success_subliminal/pages/web_pages/account_setting_web_page.dart';
import 'package:success_subliminal/pages/web_pages/buy_subliminal_web_page.dart';
import 'package:success_subliminal/pages/web_pages/create_new_subliminal_web_page.dart';
import 'package:success_subliminal/pages/web_pages/create_subliminal_web_page.dart';
import 'package:success_subliminal/pages/web_pages/dashboard_web_page.dart';
import 'package:success_subliminal/pages/web_pages/discover_web_page.dart';
import 'package:success_subliminal/pages/web_pages/forgot_password_web_page.dart';
import 'package:success_subliminal/pages/web_pages/home_webpage.dart';
import 'package:success_subliminal/pages/web_pages/library_new_page_web.dart';
import 'package:success_subliminal/pages/web_pages/privacy_policy_web.dart';
import 'package:success_subliminal/pages/web_pages/sign_in_web_page.dart';
import 'package:success_subliminal/pages/web_pages/sign_up_web_page.dart';

import '../pages/account_setting_page.dart';
import '../pages/buy_payment_page.dart';
import '../pages/create_new_subliminal_page.dart';
import '../pages/create_subliminal_page.dart';
import '../pages/dashboard_page.dart';
import '../pages/discover_page.dart';
import '../pages/discover_subliminal_detail_page.dart';
import '../pages/discover_subliminal_list_page.dart';
import '../pages/forgot_password_page.dart';
import '../pages/library_new_page.dart';
import '../pages/my_subliminal_page.dart';
import '../pages/subscription_payment_page.dart';
import '../pages/web_pages/discover_subliminal_list_web_page.dart';
import '../pages/web_pages/discover_subliminal_web_detail_page.dart';
import '../pages/web_pages/subscription_list_web_page.dart';
import '../pages/web_pages/subscription_payment_web_page.dart';
import '../pages/web_pages/terms_web_page.dart';

class Routes {
  static const home = '/';
  static const mainHome = '/home';
  static const signUp = '/start-trial';
  static const account = '/account';
  static const signIn = '/sign-in';
  static const forgotPassword = '/forgot_password';
  static const verifyOTP = '/verify-otp';
  static const create = '/create';
  static const createSubliminal = '/create-subliminal';
  static const libraryNew = '/library';
  static const discover = '/discover';
  static const discoverCategory = '/discover-subliminals';
  static const discoverSubliminalDetail = '/discover-subliminals-detail';
  static const mySubliminal = '/my-subliminal';
  static const dashboard = '/dashboard';
  static const downloaded = '/downloaded';
  static const subscription = '/subscription';
  static const subscribed = '/add-payment';
  static const buySubliminal = '/buy-subliminals';
  static const term = '/terms-conditions';
  static const privacy = '/privacy-policy';
  static const audioPage = '/audio';
  static const downloadPage = '/download';
}

GoRouter buildRouter() {
  return GoRouter(
    routes: [
      /*GoRoute(
        path: Routes.home,
        builder: (_, __) =>
        kIsWeb
            ? const SplashScreen()
            : const SplashScreen(),
      ),*/
      GoRoute(
        path: Routes.home,
        builder: (_, __) => kIsWeb ? const HomeWebPage() : const HomePage(),
      ),
      GoRoute(
        path: Routes.forgotPassword,
        builder: (_, __) =>
            kIsWeb ? const ForgotPasswordWebPage() : const ForgotPasswordPage(),
      ),
      GoRoute(
        path: Routes.signUp,
        builder: (_, __) => kIsWeb ? const SignUpWebPage() : const SignUpPage(),
      ),
      GoRoute(
        path: Routes.signIn,
        builder: (_, __) => kIsWeb ? const SignInWebPage() : const SignInPage(),
      ),
      GoRoute(
        path: Routes.createSubliminal,
        builder: (_, __) => kIsWeb
            ? const CreateNewSubliminalWebPage()
            : const CreateNewSubliminalPage(),
      ),
      GoRoute(
        path: Routes.create,
        builder: (_, __) => kIsWeb
            ? const CreateSubliminalWebPage()
            : const CreateSubliminalPage(),
      ),
      GoRoute(
        path: Routes.discover,
        builder: (_, __) =>
            kIsWeb ? const DiscoverWebPage() : const DiscoverPage(),
      ),
      GoRoute(
        path: Routes.libraryNew,
        builder: (_, __) =>
            kIsWeb ? const LibraryNewWebPage() : const LibraryNewPage(),
      ),
      GoRoute(
        path: Routes.dashboard,
        builder: (_, __) => kIsWeb ? const DashBoardWebPage() : DashBoardPage(),
      ),
      GoRoute(
        path: Routes.account,
        builder: (_, __) =>
            kIsWeb ? const AccountSettingWebPage() : const AccountSettingPage(),
      ),
      GoRoute(
        path: Routes.downloadPage,
        builder: (_, __) =>
            kIsWeb ? const DownloadedSubPage() : const DownloadedSubPage(),
      ),
      GoRoute(
        path: Routes.mySubliminal,
        builder: (_, __) => const MySubliminalPage(),
      ),
      /*  GoRoute(
        path: Routes.subscription,
        builder: (_, __) =>
        kIsWeb
            ? const SubscriptionListWebPage()
            : const SubscriptionListPage(),
      ),*/
      GoRoute(
        path: Routes.subscription,
        name: "subscription",
        builder: (context, state) => kIsWeb
            ? SubscriptionListWebPage(
                screen: state.queryParameters['screen']!,
              )
            : SubscriptionListPage(
                screen: state.queryParameters['screen']!,
              ),
      ),
      /*   GoRoute(
        path: Routes.subscribed,
        name: "add-payment",
        builder: (context, state) => SubscriptionPaymentWebPage(
          amount: state.queryParameters['amount']!,
          subscriptionId: state.queryParameters['subscriptionId']!,
          planType: state.queryParameters['planType']!,
          screen: state.queryParameters['screen']!,
        ),
      ), */
      GoRoute(
        path: Routes.subscribed,
        name: "add-payment",
        builder: (context, state) => kIsWeb
            ? SubscriptionPaymentWebPage(
                amount: state.queryParameters['amount']!,
                subscriptionId: state.queryParameters['subscriptionId']!,
                planType: state.queryParameters['planType']!,
                screen: state.queryParameters['screen']!,
              )
            : SubscriptionPaymentPage(
                amount: state.queryParameters['amount']!,
                subscriptionId: state.queryParameters['subscriptionId']!,
                planType: state.queryParameters['planType']!,
                screen: state.queryParameters['screen']!,
              ),
      ),
      GoRoute(
        path: Routes.buySubliminal,
        name: "buy-subliminals",
        builder: (context, state) => kIsWeb
            ? BuySubliminalWebPage(
                subId: state.queryParameters['subId']!,
                subName: state.queryParameters['subName']!,
                catId: state.queryParameters['catId']!,
                catName: state.queryParameters['catName']!,
                amount: state.queryParameters['amount']!,
                screen: state.queryParameters['screen']!,
              )
            : BuySubliminalPage(
                subId: state.queryParameters['subId']!,
                subName: state.queryParameters['subName']!,
                catId: state.queryParameters['catId']!,
                catName: state.queryParameters['catName']!,
                amount: state.queryParameters['amount']!,
                screen: state.queryParameters['screen']!,
              ),
      ),
      GoRoute(
        path: Routes.discoverCategory,
        name: "discover-subliminals",
        builder: (context, state) => kIsWeb
            ? DiscoverCategoryWebListPage(
                categoryName: state.queryParameters['categoryName']!,
                categoryId: state.queryParameters['categoryId']!,
                subname: state.queryParameters['subname']!,
              )
            : DiscoverCategoryListPage(
                categoryName: state.queryParameters['categoryName']!,
                categoryId: state.queryParameters['categoryId']!,
              ),
      ),
      GoRoute(
        path: Routes.discoverSubliminalDetail,
        name: "discover-subliminals-detail",
        builder: (context, state) => kIsWeb
            ? DiscoverSubliminalDetailWebPage(
                subName: state.queryParameters['subName']!,
                subId: state.queryParameters['subId']!,
                categoryName: state.queryParameters['categoryName']!,
                catId: state.queryParameters['catId']!,
              )
            : DiscoverSubliminalDetailPage(
                subName: state.queryParameters['subName']!,
                subId: state.queryParameters['subId']!,
              ),
      ),
      GoRoute(
        path: Routes.term,
        builder: (_, __) =>
            kIsWeb ? const TermsWebPage() : const TermsWebPage(),
      ),
      GoRoute(
        path: Routes.privacy,
        builder: (_, __) => kIsWeb
            ? const PrivacyPolicyWebPage()
            : const PrivacyPolicyWebPage(),
      ),
    ],
  );
}
