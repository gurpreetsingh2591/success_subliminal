import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  factory SharedPrefs() {
    if (_prefs == null) {
      throw Exception('Call SharedPrefs.init() before accessing it');
    }
    return _singleton;
  }

  SharedPrefs._internal();

  static void init(SharedPreferences sharedPreferences) =>
      _prefs ??= sharedPreferences;

  static final SharedPrefs _singleton = SharedPrefs._internal();

  static SharedPreferences? _prefs;

  static const String _tokenKey = '_tokenKey',
      _userEmail = '_userEmail',
      _onBoardingCompleted = '_onBoardingCompleted',
      _isLogin = '_isLogin',
      _isSubscription = '_isSubscription',
      _isSubscriptionStatus = '_isSubscriptionStatus',
      _isSignUp = '_isSignUp',
      _isUserRegister = '_isUserRegister',
      _isUserRegisterAnAccount = '_isUserRegisterAnAccount',
      _userId = '_userId',
      _userFullName = '_userFullName',
      _userDOB = '_userDOB',
      _userPhone = '_userPhone',
      _isFreeTrail = '_isFreeTrail',
      _isFreeTrailUsed = '_isFreeTrailUsed',
      _isTokenTime = '_isTokenTime',
      _deviceId = '_deviceId',
      _userSubscriptionId = '_userSubscriptionId',
      _userPlanId = '_userPlanId',
      _subscriptionStartDate = '_subscriptionStartDate',
      _subscriptionEndDate = '_subscriptionEndDate',
      _trialStartDate = '_trialStartDate',
      _trialEndDate = '_trialEndDate',
      _subPlayingName = '_subPlayingName',
      _subPlayingImage = '_subPlayingImage',
      _subPlayingUrl = '_subPlayingUrl',
      _subIsPlaying = '_subIsPlaying',
      _subPlayingId = '_subPlayingId',
      _freeSubId = '_freeSubId',
      _planName = '_planName',
      _planAmount = '_planAmount',
      _stripeCustomerId = 'stripeCustomerId';

  Future<bool> setIsOnBoardingCompleted([bool isCompleted = false]) =>
      _prefs!.setBool(_onBoardingCompleted, isCompleted);

  bool isOnBoardingCompleted() =>
      _prefs!.getBool(_onBoardingCompleted) ?? false;

  ///* User SignIn/SignUp Detail*/
  Future<bool> setIsLogin([bool isLogin = false]) =>
      _prefs!.setBool(_isLogin, isLogin);

  bool isLogin() => _prefs!.getBool(_isLogin) ?? false;

  Future<bool> setIsSignUp([bool isSignUp = false]) =>
      _prefs!.setBool(_isSignUp, isSignUp);

  bool isSignUp() => _prefs!.getBool(_isSignUp) ?? false;

  Future<bool> setTokenKey(String token) => _prefs!.setString(_tokenKey, token);

  Future<bool> removeTokenKey() => _prefs!.remove(_tokenKey);

  String? getTokenKey() => _prefs!.getString(_tokenKey);

  Future<bool> setUserEmail(String email) =>
      _prefs!.setString(_userEmail, email);

  Future<bool> removeUserEmail() => _prefs!.remove(_userEmail);

  String? getUserEmail() => _prefs!.getString(_userEmail);

  Future<bool> setUserFullName(String userFullName) =>
      _prefs!.setString(_userFullName, userFullName);

  Future<bool> removeUserFullName() => _prefs!.remove(_userFullName);

  String? getUserFullName() => _prefs!.getString(_userFullName);

  Future<bool> setUserId(String userId) => _prefs!.setString(_userId, userId);

  String? getUserId() => _prefs!.getString(_userId);

  Future<bool> setUserDob(String userDOB) =>
      _prefs!.setString(_userDOB, userDOB);

  Future<bool> removeUserDob() => _prefs!.remove(_userDOB);

  String? getUserDob() => _prefs!.getString(_userDOB);

  Future<bool> setUserPhone(String userPhone) =>
      _prefs!.setString(_userPhone, userPhone);

  Future<bool> removeUserPhone() => _prefs!.remove(_userPhone);

  String? getUserPhone() => _prefs!.getString(_userPhone);

  ///------

  ///* User subscription detail */
  Future<bool> setIsSubscription([bool isSubscription = false]) =>
      _prefs!.setBool(_isSubscription, isSubscription);

  bool isSubscription() => _prefs!.getBool(_isSubscription) ?? false;

  ///* User subscription status detail */
  Future<bool> setIsSubscriptionStatus([String isSubscriptionStatus = ""]) =>
      _prefs!.setString(_isSubscriptionStatus, isSubscriptionStatus);

  String? getSubscriptionStatus() => _prefs!.getString(_isSubscriptionStatus);

  Future<bool> setUserSubscriptionId(String subscriptionId) =>
      _prefs!.setString(_userSubscriptionId, subscriptionId);

  Future<bool> removeUserSubscriptionId() =>
      _prefs!.remove(_userSubscriptionId);

  String? getUserSubscriptionId() => _prefs!.getString(_userSubscriptionId);

  ///Subscription dates
  Future<bool> setSubscriptionStartDate(String subscriptionId) =>
      _prefs!.setString(_subscriptionStartDate, subscriptionId);

  String? getSubscriptionStartDate() =>
      _prefs!.getString(_subscriptionStartDate);

  Future<bool> setSubscriptionEndDate(String subscriptionId) =>
      _prefs!.setString(_subscriptionEndDate, subscriptionId);

  String? getSubscriptionEndDate() => _prefs!.getString(_subscriptionEndDate);

  ///Plan Detail
  Future<bool> setUserPlanId(String userPlanId) =>
      _prefs!.setString(_userPlanId, userPlanId);

  Future<bool> removeUserPlanId() => _prefs!.remove(_userPlanId);

  String? getUserPlanId() => _prefs!.getString(_userPlanId);

  Future<bool> setUserPlanName(String planName) =>
      _prefs!.setString(_planName, planName);

  String? getUserPlanName() => _prefs!.getString(_planName);

  Future<bool> setUserPlanAmount(String planAmount) =>
      _prefs!.setString(_planAmount, planAmount);

  String? getUserPlanAmount() => _prefs!.getString(_planAmount);

  ///* ----- */

  ///*User Trial Detail*/

  Future<bool> setIsFreeTrail([bool isFreeTrail = false]) =>
      _prefs!.setBool(_isFreeTrail, isFreeTrail);

  bool isFreeTrail() => _prefs!.getBool(_isFreeTrail) ?? false;

  Future<bool> setIsFreeTrailUsed([bool isFreeTrail = false]) =>
      _prefs!.setBool(_isFreeTrailUsed, isFreeTrail);

  bool isFreeTrailUsed() => _prefs!.getBool(_isFreeTrailUsed) ?? false;

  /// User Trial date
  Future<bool> setTrialStartDate(String subscriptionId) =>
      _prefs!.setString(_trialStartDate, subscriptionId);

  String? getTrialStartDate() => _prefs!.getString(_trialStartDate);

  Future<bool> setTrialEndDate(String subscriptionId) =>
      _prefs!.setString(_trialEndDate, subscriptionId);

  String? getTrialEndDate() => _prefs!.getString(_trialEndDate);

  ///* ---- */

  ///*Subliminal Detail*/
  Future<bool> setPlayingSubId(int subscriptionId) =>
      _prefs!.setInt(_subPlayingId, subscriptionId);

  int? getSubPlayingId() => _prefs!.getInt(_subPlayingId);

  Future<bool> setPlayingSubImage(String subImage) =>
      _prefs!.setString(_subPlayingImage, subImage);

  String? getSubPlayingImage() => _prefs!.getString(_subPlayingImage);

  Future<bool> setPlayingSubName(String subscriptionId) =>
      _prefs!.setString(_subPlayingName, subscriptionId);

  String? getSubPlayingName() => _prefs!.getString(_subPlayingName);

  Future<bool> setPlayingSubUrl(String subscriptionId) =>
      _prefs!.setString(_subPlayingUrl, subscriptionId);

  String? getSubPlayingUrl() => _prefs!.getString(_subPlayingUrl);

  Future<bool> setIsSubPlaying([bool isSubPlaying = false]) =>
      _prefs!.setBool(_subIsPlaying, isSubPlaying);

  bool isSubPlaying() => _prefs!.getBool(_subIsPlaying) ?? false;

  ///*------*/

  Future<bool> setDeviceId(String deviceId) =>
      _prefs!.setString(_deviceId, deviceId);

  String? getDeviceId() => _prefs!.getString(_deviceId);

  ///*Stripe Detail*/

  Future<bool> setStripeCustomerId(String stripeCustomerId) =>
      _prefs!.setString(_stripeCustomerId, stripeCustomerId);

  String? getStripeCustomerId() => _prefs!.getString(_stripeCustomerId);

  Future<bool> setFreeSubId(String freeSubId) =>
      _prefs!.setString(_freeSubId, freeSubId);

  String? getFreeSubId() => _prefs!.getString(_freeSubId);

  Future reset() async {
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    final SharedPreferences prefs = await _prefs;
    prefs.clear();
  }
}
