class ApiConstants {
  //Server url
  //static String baseUrl = 'http://64.226.75.207/admin/';
  //static String baseUrl = 'https://app.successsubliminals.app/';

  static String baseUrl = 'https://app.successsubliminals.net/';
  static String baseUrlAssets = 'https://app.successsubliminals.net/images/';

  //static String baseUrlAssets = 'https://app.successsubliminals.app/images/';
  static String baseUrlStripe = 'https://api.stripe.com/v1/';
  static String baseUrlConversionFB = 'https://graph.facebook.com/v17.0/';

  //static String baseUrlAssets = 'http://64.226.75.207/admin/images/';

  /*** Stripe End point */
  static String stripeToken = 'tokens';
  static String paymentMethod = 'payment_methods';
  static String stripeAttach = 'attach';
  static String stripeDetach = 'detach';

  // url end point
  static String usersSignUp = 'api/v1/register';
  static String usersChangePassword = 'update';
  static String signInWithPassword = 'api/v1/login';
  static String forgotPassword = 'api/v1/forget_password';
  static String verifyOTP = 'api/v1/verify_otp';
  static String resetPassword = 'api/v1/password/reset';
  static String categories = 'api/v1/categories';
  static String deleteAccount = 'api/v1/account-delete';
  static String deleteCollection = '/api/v1/collections/delete/';
  static String authKey = '?key=AIzaSyCdXvpJmyOkYMxBAgpidsS85KLPEWh4hcQ';
  static String createSubliminal = 'api/v1/subliminals';
  static String subliminalList = 'api/v1/discover-subliminals?';
  static String subliminalCount = 'api/v1/count-creator-subliminal';
  static String loginSubliminalList = 'api/v1/discover-subliminals-buy?';
  static String testimonialList = 'api/v1/testimonial';
  static String mySubliminalList = 'api/v1/my-subliminals';
  static String librarySubliminalList = 'api/v1/subliminals-library?';
  static String subliminalDetail = 'api/v1/subliminals';
  static String subliminalDetailAfterLogin = 'api/v1/subliminals-buy';
  static String addWishlists = 'api/v1/wishlists';
  static String removeWishlists = 'api/v1/remove-wishlists';
  static String editAccount = 'api/v1/edit-account';
  static String myAccountData = 'api/v1/my-account';
  static String sendEmail = 'api/v1/send-free-subliminal/';
  static String getCollections = 'api/v1/collections';
  static String createCollection = 'api/v1/create-collections';
  static String addToCollection = 'api/v1/dump-collection-subliminals';
  static String collectionSubliminal = 'api/v1/collection-subliminals?';
  static String stripeProductList = 'api/v1/products-list';
  static String stripePayment = 'api/v1/payment-subscription';
  static String trialWithCard = 'api/v1/subscription-with-free-trial';
  static String stripePaymentWithSavedCard = 'api/v1/payment-save-cart';
  static String stripeBuyWithSavedCard = 'api/v1/one-time-save-cart';
  static String subscriptionStatus = 'api/v1/subscription-status';
  static String cancelSubscriptionStatus = 'api/v1/cancel-subscription';
  static String buySubliminal = 'api/v1/one-time-payment';
  static String usedFreeTrial = 'api/v1/free-trial';
  static String activatePlanFromTrial = 'api/v1/active-plan';
  static String customerSupport = 'api/v1/customer-support';
  static String event = '/events';

  //constant parameters
  static String name = 'name';
  static String email = 'email';
  static String otp = 'otp';
  static String password = 'password';
  static String subliminalId = 'subliminal_id';
  static String returnSecureToken = 'returnSecureToken';
  static String idToken = 'idToken';
  static String bearer = 'Bearer ';
  static String authorization = 'Authorization ';
  static String title = 'title';
  static String description = 'description';
  static String audioText = 'audio_text';
  static String categoryId = 'category_id';
  static String cover = 'cover';
  static String cover_code = 'cover_code';
  static String audio = 'audio';
  static String emailId = 'email_address';
  static String collectionId = 'collection_id';
  static String productId = 'product_id';
  static String Email = 'Email';
  static String Token = 'Token';
  static String price = 'price';
  static String stripToken = 'token';
  static String status = 'status';
  static String message = 'message';
  static String customerId = 'customer_Id';
  static String stripeCustomerId = 'stripe_customer_id';
  static String pMId = 'payment_method_id';

  static String type = 'type';
  static String device = 'device';
  static String method = 'method';
  static String code = 'code';
  static String notes = 'notes';
  static String amount = 'amount';
  static String reason = 'reason';

  static String publishable_key =
      'pk_live_51MZIP6Ei5E21pY9Ih6m2q6mQ9fv5kXHd0Dh1mwbZN2eu6vhyM8xkWPmFWnee9JyfKzUy7SNoIlzaYXDNcPJgGuE400aAUUMmwa';
  static String secret_key =
      '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';

  static String accessToken =
      'EAArixLhLZCywBAASk5MzhphuCFiu1D7h2v1AirdPXRd4s4ZC1KDoP093Fcx8mJZCQv6sWk89GKPoUIJi4z08gZAUqzerVoBQtQSulp8vsghSua5J4LF1TyHvoPsvfgsNlBdunDPukVkZCyWt9c0tYURPrefJfnSoWnz1xcIIZA5JcMOJoVxLbd';

  static String pixelId = '217472651012986';
}
