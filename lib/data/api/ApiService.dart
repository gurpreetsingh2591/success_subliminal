import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:success_subliminal/utils/toast.dart';

import '../../utils/constant.dart';
import '../../utils/shared_prefs.dart';
import 'ApiConstants.dart';

class ApiService {
  String stripeSecretKey = "";

  /// Sign up*/
  Future<dynamic> getUsersRegister(String name, String email, String password,
      String subliminalId, BuildContext context) async {
    try {
      var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.usersSignUp);

      var headers = {'Content-Type': 'application/json'};
      var request = http.Request('POST', url);
      if (kDebugMode) {
        print(email + password);
      }
      request.body = jsonEncode({
        ApiConstants.name: name,
        ApiConstants.email: email,
        ApiConstants.password: password,
        ApiConstants.subliminalId: subliminalId
      });

      if (kDebugMode) {
        print(request.body);
      }
      request.headers.addAll(headers);

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      if (kDebugMode) {
        print(response.statusCode);
        print(response.body);
      }
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        return result;
      } else {
        var result = jsonDecode(response.body);
        return result;
      }
    } catch (e) {
      log(e.toString());
    }
    return null;
  }

  /// Login*/
  Future<dynamic> getUserLogin(
      String email, String password, BuildContext context) async {
    try {
      var url =
          Uri.parse(ApiConstants.baseUrl + ApiConstants.signInWithPassword);

      var headers = {'Content-Type': 'application/json'};
      var request = http.Request('POST', url);
      if (kDebugMode) {
        print(email + password);
      }
      request.body = jsonEncode(
          {ApiConstants.email: email, ApiConstants.password: password});

      if (kDebugMode) {
        print(request.body);
      }
      request.headers.addAll(headers);

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      if (kDebugMode) {
        print(response.statusCode);
        print(response.body);
      }
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        return result;
      } else {
        var result = jsonDecode(response.body);
        return result;
      }
    } catch (e) {
      log(e.toString());
    }
  }

  /// Forgot Password*/
  Future<dynamic> getUserForgotPassword(
      String email, BuildContext context) async {
    try {
      var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.forgotPassword);

      var headers = {'Content-Type': 'application/json'};
      var request = http.Request('POST', url);
      if (kDebugMode) {
        print(email);
      }
      request.body = jsonEncode({ApiConstants.email: email});

      if (kDebugMode) {
        print(request.body);
      }
      request.headers.addAll(headers);

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      if (kDebugMode) {
        print(response.statusCode);
        print(response.body);
      }
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        return result;
      } else {
        var result = jsonDecode(response.body);
        return result;
      }
    } catch (e) {
      log(e.toString());
    }
  }

  /// Verify OTP*/
  Future<dynamic> getUserVerifyOTP(
      String otp, String email, BuildContext context) async {
    try {
      var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.verifyOTP);

      var headers = {'Content-Type': 'application/json'};
      var request = http.Request('POST', url);
      if (kDebugMode) {
        print(email);
      }
      request.body =
          jsonEncode({ApiConstants.otp: otp, ApiConstants.email: email});

      if (kDebugMode) {
        print(request.body);
      }
      request.headers.addAll(headers);

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      if (kDebugMode) {
        print(response.statusCode);
        print(response.body);
      }
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        return result;
      } else {
        var result = jsonDecode(response.body);
        return result;
      }
    } catch (e) {
      log(e.toString());
    }
  }

  /// reset password*/
  Future<dynamic> getUserResetPassword(
      String password, String email, BuildContext context) async {
    try {
      var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.resetPassword);

      var headers = {'Content-Type': 'application/json'};
      var request = http.Request('POST', url);
      if (kDebugMode) {
        print(email);
      }
      request.body = jsonEncode(
          {ApiConstants.password: password, ApiConstants.email: email});

      if (kDebugMode) {
        print(request.body);
      }
      request.headers.addAll(headers);

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      if (kDebugMode) {
        print(response.statusCode);
        print(response.body);
      }
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        return result;
      } else {
        var result = jsonDecode(response.body);
        return result;
      }
    } catch (e) {
      log(e.toString());
    }
  }

  /// Create Subliminal*/
  Future<dynamic> getCreateSubliminal(
      String title,
      String description,
      String audioText,
      File coverFile,
      String cover_code,
      BuildContext context) async {
    try {
      var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.createSubliminal);

      var headers = {
        'Authorization': 'Bearer ${SharedPrefs().getTokenKey()}',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      var request = http.MultipartRequest('POST', url);
      request.fields.addAll({
        ApiConstants.title: title,
        ApiConstants.description: description,
        ApiConstants.audioText: audioText,
        ApiConstants.cover_code: cover_code,
      });

      if (coverFile.path != "") {
        request.files.add(await http.MultipartFile.fromPath(
            ApiConstants.cover, coverFile.path));
      }

      /*  if (bytes != null || bytes != "") {
        // Convert bytes to a File object
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/image.png');
        await file.writeAsBytes(bytes);

        request.files.add(
            await http.MultipartFile.fromPath(ApiConstants.cover, file.path));
      }
*/
      /* print(audioFile.path);
      if (audioFile.path != "") {
        request.files.add(await http.MultipartFile.fromPath(
            ApiConstants.audio, audioFile.path));
      }*/

      request.headers.addAll(headers);

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      if (kDebugMode) {
        print(response.body);
        print(response.statusCode);
      }
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        return result;
      } else {
        var result = jsonDecode(response.body);
        return result;
      }
    } catch (e) {
      log(e.toString());
    }
  }

  /// Create Subliminal*/
  Future<dynamic> getCreateSubliminalForWeb(String title, String description,
      String audioText, Uint8List coverFile, BuildContext context) async {
    try {
      var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.createSubliminal);

      var headers = {
        'Authorization': 'Bearer ${SharedPrefs().getTokenKey()}',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      var request = http.Request('POST', url);
      /*  request.body = jsonEncode(
          { ApiConstants.title: title,
            ApiConstants.description: description,
            ApiConstants.audioText: audioText,});*/
      request.bodyFields.addAll({
        ApiConstants.title: title,
        ApiConstants.description: description,
        ApiConstants.audioText: audioText,
      });

      /* request.bodyFields.addAll({
        ApiConstants.title: title,
        ApiConstants.description: description,
        ApiConstants.audioText: audioText,
      });*/

      request.bodyBytes = coverFile;

      /* print(audioFile.path);
      if (audioFile.path != "") {
        request.files.add(await http.MultipartFile.fromPath(
            ApiConstants.audio, audioFile.path));
      }*/

      request.headers.addAll(headers);

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      if (kDebugMode) {
        print(response.body);
        print(response.statusCode);
      }
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        return result;
      } else {
        var result = jsonDecode(response.body);
        return result;
      }
    } catch (e) {
      log(e.toString());
    }
  }

  /// Categories List*/
  Future<dynamic> getCategories(BuildContext context) async {
    try {
      var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.categories);
      var headers = {
        'Access-Control-Allow-Origin': '*',
        'Authorization': 'Bearer ${SharedPrefs().getTokenKey()}'
      };
      var request = http.Request('GET', url);

      request.headers.addAll(headers);
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      if (kDebugMode) {
        print(response.statusCode);
        print(response.body);
      }
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        return result;
      } else {
        var result = jsonDecode(response.body);
        return result;
      }
    } catch (e) {
      log(e.toString());
    }
  }

  /// Delete Account*/
  Future<dynamic> getDeleteAccount(BuildContext context) async {
    try {
      var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.deleteAccount);
      var headers = {'Authorization': 'Bearer ${SharedPrefs().getTokenKey()}'};
      var request = http.Request('DELETE', url);

      request.headers.addAll(headers);
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      if (kDebugMode) {
        print(response.statusCode);
        print(response.body);
      }
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        return result;
      } else {
        var result = jsonDecode(response.body);
        return result;
      }
    } catch (e) {
      log(e.toString());
    }
  }

  /// delete collection*/
  Future<dynamic> getDeleteCollection(
      BuildContext context, String collectionId) async {
    try {
      var url = Uri.parse(
          ApiConstants.baseUrl + ApiConstants.deleteCollection + collectionId);
      var headers = {
        'Access-Control-Allow-Origin': '*',
        'Authorization': 'Bearer ${SharedPrefs().getTokenKey()}'
      };
      var request = http.Request('GET', url);

      request.headers.addAll(headers);
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      if (kDebugMode) {
        print(response.statusCode);
        print(response.body);
      }
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        return result;
      } else {
        var result = jsonDecode(response.body);
        return result;
      }
    } catch (e) {
      log(e.toString());
    }
  }

  /// Discover Subliminal List*/
  Future<dynamic> getDiscoverSubliminalList(
      BuildContext context, String catId) async {
    try {
      var url = Uri.parse(
          "${ApiConstants.baseUrl}${ApiConstants.subliminalList}${ApiConstants.categoryId}=$catId");
      var headers = {
        'Access-Control-Allow-Origin': '*',
        'Authorization': 'Bearer ${SharedPrefs().getTokenKey()}'
      };
      var request = http.Request('GET', url);

      request.headers.addAll(headers);
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      if (kDebugMode) {
        print(response.statusCode);
        print(response.body);
      }
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        return result;
      } else {
        var result = jsonDecode(response.body);
        return result;
      }
    } catch (e) {
      log(e.toString());
    }
  }

  /// create Subliminal count*/
  Future<dynamic> getCreateSubliminalCount(
    BuildContext context,
  ) async {
    try {
      var url =
          Uri.parse("${ApiConstants.baseUrl}${ApiConstants.subliminalCount}");
      var headers = {
        'Access-Control-Allow-Origin': '*',
        'Authorization': 'Bearer ${SharedPrefs().getTokenKey()}'
      };
      var request = http.Request('GET', url);

      request.headers.addAll(headers);
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      if (kDebugMode) {
        print(response.statusCode);
        print(response.body);
      }
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        return result;
      } else {
        var result = jsonDecode(response.body);
        return result;
      }
    } catch (e) {
      log(e.toString());
    }
  }

  /// Login Discover Subliminal List*/
  Future<dynamic> getLoginDiscoverSubliminalList(
      BuildContext context, String catId) async {
    try {
      var url = Uri.parse(
          "${ApiConstants.baseUrl}${ApiConstants.loginSubliminalList}${ApiConstants.categoryId}=$catId");
      var headers = {
        'Access-Control-Allow-Origin': '*',
        'Authorization': 'Bearer ${SharedPrefs().getTokenKey()}'
      };
      var request = http.Request('GET', url);

      request.headers.addAll(headers);
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      if (kDebugMode) {
        print(response.statusCode);
        print(response.body);
      }
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        return result;
      } else {
        var result = jsonDecode(response.body);
        return result;
      }
    } catch (e) {
      log(e.toString());
    }
  }

  /// Testimonial List*/
  Future<dynamic> getTestimonialList(BuildContext context) async {
    try {
      var url =
          Uri.parse("${ApiConstants.baseUrl}${ApiConstants.testimonialList}");
      var headers = {'Authorization': 'Bearer ${SharedPrefs().getTokenKey()}'};
      var request = http.Request('GET', url);

      request.headers.addAll(headers);
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      if (kDebugMode) {
        print(response.statusCode);
        print(response.body);
      }
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        return result;
      } else {
        var result = jsonDecode(response.body);
        return result;
      }
    } catch (e) {
      log(e.toString());
    }
  }

  /// Discover Subliminal Detail*/
  Future<dynamic> getSubliminalDetail(
      BuildContext context, String subId) async {
    try {
      print(subId);
      var url = Uri.parse(
          "${ApiConstants.baseUrl}${ApiConstants.subliminalDetailAfterLogin}/$subId");
      print(url);
      var headers = {
        'Access-Control-Allow-Origin': '*',
        'Authorization': 'Bearer ${SharedPrefs().getTokenKey()}'
      };
      var request = http.Request('GET', url);

      request.headers.addAll(headers);
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      if (kDebugMode) {
        print(response.body);
        print(response.statusCode);
      }

      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        return result;
      } else {
        var result = jsonDecode(response.body);
        return result;
      }
    } catch (e) {
      log(e.toString());
    }
  }

  /// Discover Subliminal Detail*/
  Future<dynamic> getSubliminalDetailWithoutLogin(
      BuildContext context, String subId) async {
    try {
      if (kDebugMode) {
        print(subId);
      }
      var url = Uri.parse(
          "${ApiConstants.baseUrl}${ApiConstants.subliminalDetail}/$subId");
      if (kDebugMode) {
        print(url);
      }
      var headers = {
        'Access-Control-Allow-Origin': '*',
        'Authorization': 'Bearer ',
        'Accept': 'application/json'
      };
      var request = http.Request('GET', url);

      request.headers.addAll(headers);
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      if (kDebugMode) {
        print(response.body);
        print(response.statusCode);
      }

      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        return result;
      } else {
        var result = jsonDecode(response.body);
        return result;
      }
    } catch (e) {
      log(e.toString());
    }
  }

  /// My Subliminal List*/
  Future<dynamic> getMySubliminalList(BuildContext context) async {
    try {
      var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.mySubliminalList);
      var headers = {
        'Access-Control-Allow-Origin': '*',
        'Authorization': 'Bearer ${SharedPrefs().getTokenKey()}'
      };
      var request = http.Request('GET', url);

      request.headers.addAll(headers);
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      if (kDebugMode) {
        print(response.statusCode);
        print(response.body);
      }
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        return result;
      } else {
        var result = jsonDecode(response.body);
        return result;
      }
    } catch (e) {
      log(e.toString());
    }
  }

  /// Library Subliminal List*/
  Future<dynamic> getLibrarySubliminalList(
      BuildContext context, String filter) async {
    try {
      var url = Uri.parse(
          "${ApiConstants.baseUrl}${ApiConstants.librarySubliminalList}$filter");
      var headers = {
        'Access-Control-Allow-Origin': '*',
        'Authorization': 'Bearer ${SharedPrefs().getTokenKey()}'
      };
      var request = http.Request('GET', url);

      request.headers.addAll(headers);
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      if (kDebugMode) {
        print(response.statusCode);
        print(response.body);
      }
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        return result;
      } else {
        var result = jsonDecode(response.body);
        return result;
      }
    } catch (e) {
      log(e.toString());
    }
  }

  ///Add Wishlist*/
  Future<dynamic> getAddWishlist(
      String subliminalId, BuildContext context) async {
    try {
      var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.addWishlists);

      var headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${SharedPrefs().getTokenKey()}'
      };
      var request = http.Request('POST', url);
      if (kDebugMode) {
        print(subliminalId);
      }
      request.body = jsonEncode({ApiConstants.subliminalId: subliminalId});

      if (kDebugMode) {
        print(request.body);
      }
      request.headers.addAll(headers);

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      if (kDebugMode) {
        print(response.statusCode);
        print(response.body);
      }
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        return result;
      } else {
        var result = jsonDecode(response.body);
        return result;
      }
    } catch (e) {
      log(e.toString());
    }
  }

  /// Remove Wishlist*/
  Future<dynamic> getRemoveWishlist(
      String subliminalId, BuildContext context) async {
    try {
      var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.removeWishlists);

      var headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${SharedPrefs().getTokenKey()}'
      };
      var request = http.Request('POST', url);
      if (kDebugMode) {
        print(subliminalId);
      }
      request.body = jsonEncode({ApiConstants.subliminalId: subliminalId});

      if (kDebugMode) {
        print(request.body);
      }
      request.headers.addAll(headers);

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      if (kDebugMode) {
        print(response.statusCode);
        print(response.body);
      }
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        return result;
      } else {
        var result = jsonDecode(response.body);
        return result;
      }
    } catch (e) {
      log(e.toString());
    }
  }

  /// My Account Data*/
  Future<dynamic> getMyAccountData(BuildContext context) async {
    try {
      var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.myAccountData);
      var headers = {'Authorization': 'Bearer ${SharedPrefs().getTokenKey()}'};
      var request = http.Request('GET', url);

      request.headers.addAll(headers);
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      if (kDebugMode) {
        print(response.statusCode);
        print(response.body);
      }
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        return result;
      } else {
        var result = jsonDecode(response.body);
        return result;
      }
    } catch (e) {
      log(e.toString());
    }
  }

  /// My Account Data*/
  Future<dynamic> getCreatePaymentData(BuildContext context) async {
    try {
      var headers = {
        'Authorization':
            'Bearer sk_test_51Mb1VCSFyg9e3VDbrlTeZLy9ZLRzzgLhTyAGZZ8y5ApXsuqMCckLPS1CbGZCwtkhMYGXxIFtSMHQIVBAliMYrgek0057F8wOn5'
      };
      var request = http.Request(
          'GET', Uri.parse('https://dashboard.stripe.com/v1/payment_intents'));

      request.headers.addAll(headers);
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      if (kDebugMode) {
        print(response.statusCode);
        print(response.body);
      }
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        return result;
      } else {
        var result = jsonDecode(response.body);
        return result;
      }
    } catch (e) {
      log(e.toString());
    }
  }

  /// Edit Account*/
  Future<dynamic> getEditAccount(
      String name, String password, BuildContext context) async {
    try {
      var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.editAccount);

      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${SharedPrefs().getTokenKey()}'
      };
      var request = http.Request('POST', url);

      request.body = jsonEncode(
          {ApiConstants.name: name, ApiConstants.password: password});

      if (kDebugMode) {
        print(request.body);
      }
      request.headers.addAll(headers);

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      if (kDebugMode) {
        print(response.statusCode);
        print(response.body);
      }

      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        return result;
      } else {
        var result = jsonDecode(response.body);
        return result;
      }
    } catch (e) {
      log(e.toString());
    }
  }

  ///Send Email*/
  Future<dynamic> getSendEmail(String email, BuildContext context) async {
    try {
      var url =
          Uri.parse("${ApiConstants.baseUrl}${ApiConstants.sendEmail}$email");

      var headers = {'Authorization': 'Bearer ${SharedPrefs().getTokenKey()}'};
      var request = http.Request('GET', url);
      if (kDebugMode) {
        print(email);
      }
      /*request.body = jsonEncode({ApiConstants.emailId: email});

      if (kDebugMode) {
        print(request.body);
      }*/
      request.headers.addAll(headers);
      if (kDebugMode) {
        print(request);
      }
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (kDebugMode) {
        print(response.body);
        print(response.statusCode);
      }
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        return result;
      } else {
        var result = jsonDecode(response.body);
        return result;
      }
    } catch (e) {
      log(e.toString());
    }
  }

  /// Collection List*/
  Future<dynamic> getCollections(BuildContext context) async {
    try {
      var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.getCollections);
      var headers = {
        'Accept': 'application/json',
        'Authorization': 'Bearer ${SharedPrefs().getTokenKey()}'
      };
      var request = http.Request('GET', url);

      request.headers.addAll(headers);
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      if (kDebugMode) {
        print(response.statusCode);
        print(response.body);
      }
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        return result;
      } else {
        var result = jsonDecode(response.body);
        return result;
      }
    } catch (e) {
      log(e.toString());
    }
  }

  ///Create Collection*/
  Future<dynamic> getCreateCollection(
      String collectionName, BuildContext context) async {
    try {
      var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.createCollection);

      var headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${SharedPrefs().getTokenKey()}'
      };
      var request = http.Request('POST', url);
      if (kDebugMode) {
        print(collectionName);
      }
      request.body = jsonEncode({ApiConstants.name: collectionName});

      if (kDebugMode) {
        print(request.body);
      }
      request.headers.addAll(headers);

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      if (kDebugMode) {
        print(response.statusCode);
        print(response.body);
      }
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        return result;
      } else {
        var result = jsonDecode(response.body);
        return result;
      }
    } catch (e) {
      log(e.toString());
    }
  }

  ///Add to Collection*/
  Future<dynamic> getAddToCollection(String subliminalId, String collectionId,
      String type, BuildContext context) async {
    try {
      var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.addToCollection);

      var headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${SharedPrefs().getTokenKey()}'
      };
      var request = http.Request('POST', url);
      request.body = jsonEncode({
        ApiConstants.subliminalId: subliminalId,
        ApiConstants.collectionId: collectionId,
        ApiConstants.type: type
      });

      if (kDebugMode) {
        print(request.body);
      }
      request.headers.addAll(headers);

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      if (kDebugMode) {
        print(response.statusCode);
        print(response.body);
      }
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);

        return result;
      } else {
        var result = jsonDecode(response.body);

        return result;
      }
    } catch (e) {
      log(e.toString());
    }
  }

  /// Collection List*/
  Future<dynamic> getCollectionsSubliminalList(
      BuildContext context, String collectionId) async {
    try {
      var url = Uri.parse(ApiConstants.baseUrl +
          ApiConstants.collectionSubliminal +
          collectionId);
      var headers = {
        'Accept': 'application/json',
        'Authorization': 'Bearer ${SharedPrefs().getTokenKey()}'
      };
      var request = http.Request('GET', url);

      request.headers.addAll(headers);
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      if (kDebugMode) {
        print(response.statusCode);
        print(response.body);
      }
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        return result;
      } else {
        var result = jsonDecode(response.body);
        return result;
      }
    } catch (e) {
      log(e.toString());
    }
  }

  /// Subliminal delete */
  Future<dynamic> getDeleteSubliminal(
      BuildContext context, String subliminalId) async {
    try {
      var url = Uri.parse(
          "${ApiConstants.baseUrl}${ApiConstants.createSubliminal}/$subliminalId");
      var headers = {
        'Accept': 'application/json',
        'Authorization': 'Bearer ${SharedPrefs().getTokenKey()}'
      };
      var request = http.Request('DELETE', url);

      request.headers.addAll(headers);
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      if (kDebugMode) {
        print(response.statusCode);
        print(response.body);
      }
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        return result;
      } else {
        var result = jsonDecode(response.body);
        return result;
      }
    } catch (e) {
      log(e.toString());
    }
  }

  /// Stripe Product List*/
  Future<dynamic> getStripeProduct(BuildContext context) async {
    try {
      var url =
          Uri.parse(ApiConstants.baseUrl + ApiConstants.stripeProductList);
      var headers = {'Authorization': 'Bearer ${SharedPrefs().getTokenKey()}'};
      var request = http.Request('GET', url);

      request.headers.addAll(headers);
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      if (kDebugMode) {
        print(response.statusCode);
        print(response.body);
      }
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        return result;
      } else {
        var result = jsonDecode(response.body);
        return result;
      }
    } catch (e) {
      log(e.toString());
    }
  }

  ///stripe payment*/
  Future<dynamic> getStripePayment(String product_id, String email,
      String token, BuildContext context) async {
    try {
      var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.stripePayment);

      var headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${SharedPrefs().getTokenKey()}'
      };
      var request = http.Request('POST', url);
      request.body = jsonEncode({
        ApiConstants.Token: token,
        ApiConstants.Email: email,
        ApiConstants.productId: product_id
      });

      if (kDebugMode) {
        print(request.body);
      }
      request.headers.addAll(headers);

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      if (kDebugMode) {
        print(response.body);
      }
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);

        return result;
      } else {
        var result = jsonDecode(response.body);
        Navigator.of(context, rootNavigator: true).pop();
        toast("Something went wrong, Please try again later", true);

        return result;
      }
    } catch (e) {
      log(e.toString());
    }
  }

  ///trial with card*/
  Future<dynamic> getTrialWithCard(String product_id, String email,
      String token, String name, BuildContext context) async {
    try {
      var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.trialWithCard);

      var headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${SharedPrefs().getTokenKey()}'
      };
      var request = http.Request('POST', url);
      request.body = jsonEncode({
        ApiConstants.Token: token,
        ApiConstants.Email: email,
        ApiConstants.productId: product_id,
        ApiConstants.name: name
      });

      if (kDebugMode) {
        print(request.body);
      }
      request.headers.addAll(headers);

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      if (kDebugMode) {
        print(response.body);
      }
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);

        return result;
      } else {
        var result = jsonDecode(response.body);
        Navigator.of(context, rootNavigator: true).pop();
        toast("Something went wrong, Please try again later", true);

        return result;
      }
    } catch (e) {
      log(e.toString());
    }
  }

  ///stripe plan activate*/
  Future<dynamic> getStripeActivatePlan(String productId, String customerId,
      String pMId, String token, BuildContext context) async {
    try {
      var url =
          Uri.parse(ApiConstants.baseUrl + ApiConstants.activatePlanFromTrial);

      var headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${SharedPrefs().getTokenKey()}'
      };
      var request = http.Request('POST', url);
      request.body = jsonEncode({
        ApiConstants.customerId: customerId,
        ApiConstants.pMId: pMId,
        ApiConstants.productId: productId,
        ApiConstants.stripToken: token
      });

      if (kDebugMode) {
        print(request.body);
      }
      request.headers.addAll(headers);

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      if (kDebugMode) {
        print(response.body);
      }
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);

        return result;
      } else {
        var result = jsonDecode(response.body);
        Navigator.of(context, rootNavigator: true).pop();
        toast("Something went wrong, Please try again later", true);

        return result;
      }
    } catch (e) {
      log(e.toString());
    }
  }

  ///stripe plan activate*/
  Future<dynamic> getStripeActivatePlanTest(String productId, String customerId,
      String pMId, String token, BuildContext context) async {
    try {
      var url = Uri.parse(
          '${ApiConstants.baseUrl}api/v1/subscribe' /*ApiConstants.activatePlanFromTrial*/);

      var headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${SharedPrefs().getTokenKey()}'
      };
      var request = http.Request('POST', url);
      request.body = jsonEncode({
        'name': SharedPrefs().getUserFullName(),
        'email': SharedPrefs().getUserEmail(),
        'product_id': productId,
        'token': token
      });

      if (kDebugMode) {
        print(request.body);
      }
      request.headers.addAll(headers);

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      if (kDebugMode) {
        print(response.body);
      }
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);

        return result;
      } else {
        var result = jsonDecode(response.body);
        Navigator.of(context, rootNavigator: true).pop();
        toast("Something went wrong, Please try again later", true);

        return result;
      }
    } catch (e) {
      log(e.toString());
    }
  }

  ///stripe payment with saved card*/
  Future<dynamic> getStripePaymentWithSavedCards(String productId,
      String customerId, String pMId, BuildContext context) async {
    try {
      var url = Uri.parse(
          ApiConstants.baseUrl + ApiConstants.stripePaymentWithSavedCard);

      var headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${SharedPrefs().getTokenKey()}'
      };
      var request = http.Request('POST', url);
      request.body = jsonEncode({
        ApiConstants.customerId: customerId,
        ApiConstants.pMId: pMId,
        ApiConstants.productId: productId
      });

      if (kDebugMode) {
        print(request.body);
      }
      request.headers.addAll(headers);

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      if (kDebugMode) {
        print(response.body);
      }
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        return result;
      } else {
        var result = jsonDecode(response.body);
        Navigator.of(context, rootNavigator: true).pop();
        toast("Something went wrong, Please try again later", true);

        return result;
      }
    } catch (e) {
      log(e.toString());
    }
  }

  ///stripe payment with saved card*/
  Future<dynamic> getStripeBuyWithSavedCards(String subliminalId, String price,
      String customerId, String pMId, BuildContext context) async {
    try {
      var url =
          Uri.parse(ApiConstants.baseUrl + ApiConstants.stripeBuyWithSavedCard);

      var headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${SharedPrefs().getTokenKey()}'
      };
      var request = http.Request('POST', url);
      request.body = jsonEncode({
        ApiConstants.stripeCustomerId: customerId,
        ApiConstants.pMId: pMId,
        ApiConstants.subliminalId: subliminalId,
        ApiConstants.price: price
      });

      if (kDebugMode) {
        print(request.body);
      }
      request.headers.addAll(headers);

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      if (kDebugMode) {
        print(response.body);
      }
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        return result;
      } else {
        var result = jsonDecode(response.body);
        Navigator.of(context, rootNavigator: true).pop();
        toast("Something went wrong, Please try again later", true);
        return result;
      }
    } catch (e) {
      log(e.toString());
    }
  }

  ///Create Stripe Token*/
  Future<dynamic> getCreateToken(String cardNum, String expMonth,
      String expYear, String cvv, BuildContext context) async {
    try {
      var url =
          Uri.parse(ApiConstants.baseUrlStripe + ApiConstants.stripeToken);

      /* if (kReleaseMode) {
        stripeSecretKey = kSecretLiveKey;
      } else {
        stripeSecretKey = kSecretTestKey;
      }*/

      var headers = {
        'Authorization': 'Bearer $kSecretLiveKey',
        'Content-Type': 'application/x-www-form-urlencoded'
      };
      var request = http.Request('POST', url);
      request.bodyFields = {
        'card[number]': cardNum,
        'card[exp_month]': expMonth,
        'card[exp_year]': expYear,
        'card[cvc]': cvv
      };
      request.headers.addAll(headers);
      if (kDebugMode) {
        print(request.bodyFields);
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      if (kDebugMode) {
        print(response.statusCode);
      }
      if (response.statusCode == 200) {
        if (kDebugMode) {
          print(response.body);
        }
        var result = jsonDecode(response.body);
        return result;
      } else {
        var result = jsonDecode(response.body);
        return result;
      }
    } catch (e) {
      log(e.toString());
    }
  }

  ///Create Stripe payment method*/
  Future<dynamic> getCreateStripePaymentMethod(
      String cardNum,
      String name,
      String expMonth,
      String expYear,
      String cvv,
      String type,
      BuildContext context) async {
    try {
      var url =
          Uri.parse(ApiConstants.baseUrlStripe + ApiConstants.paymentMethod);
      /*if (kReleaseMode) {
        stripeSecretKey = kSecretLiveKey;
      } else {
        stripeSecretKey = kSecretTestKey;
      }*/
      var headers = {
        'Authorization': 'Bearer $kSecretLiveKey',
        'Content-Type': 'application/x-www-form-urlencoded'
      };
      var request = http.Request('POST', url);
      request.bodyFields = {
        'card[number]': cardNum,
        'card[exp_month]': expMonth,
        'card[exp_year]': expYear,
        'card[cvc]': cvv,
        'type': type,
        'billing_details[name]': name,
        'billing_details[email]': SharedPrefs().getUserEmail().toString()
      };
      request.headers.addAll(headers);
      if (kDebugMode) {
        print(request.bodyFields);
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      if (kDebugMode) {
        print(response.statusCode);
      }
      if (response.statusCode == 200) {
        if (kDebugMode) {
          print(response.body);
        }
        var result = jsonDecode(response.body);
        return result;
      } else {
        var result = jsonDecode(response.body);
        return result;
      }
    } catch (e) {
      log(e.toString());
    }
  }

  ///Add Stripe payment method*/
  Future<dynamic> getAddStripePaymentMethod(
      String customerId, String paymentMethodId, BuildContext context) async {
    try {
      var url = Uri.parse(
          "${ApiConstants.baseUrlStripe}${ApiConstants.paymentMethod}/$paymentMethodId/${ApiConstants.stripeAttach}");
      /* if (kReleaseMode) {
        stripeSecretKey = kSecretLiveKey;
      } else {
        stripeSecretKey = kSecretTestKey;
      }*/

      var headers = {
        'Authorization': 'Bearer $kSecretLiveKey',
        'Content-Type': 'application/x-www-form-urlencoded'
      };
      var request = http.Request('POST', url);
      request.bodyFields = {'customer': customerId};
      request.headers.addAll(headers);
      if (kDebugMode) {
        print(request.bodyFields);
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      if (kDebugMode) {
        print(response.statusCode);
      }
      if (response.statusCode == 200) {
        if (kDebugMode) {
          print(response.body);
        }
        var result = jsonDecode(response.body);
        return result;
      } else {
        var result = jsonDecode(response.body);
        return result;
      }
    } catch (e) {
      log(e.toString());
    }
  }

  ///Get List of Stripe payment method*/
  Future<dynamic> getStripePaymentMethodList(
      String customerId, BuildContext context) async {
    try {
      var url = Uri.parse(
          "${ApiConstants.baseUrlStripe}${ApiConstants.paymentMethod}?customer=$customerId&type=card");

      /*if (kReleaseMode) {
        stripeSecretKey = kSecretLiveKey;
      } else {
        stripeSecretKey = kSecretTestKey;
      }*/

      var headers = {
        'Authorization': 'Bearer $kSecretLiveKey',
        'Content-Type': 'application/x-www-form-urlencoded'
      };
      var request = http.Request('GET', url);

      request.headers.addAll(headers);

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      if (kDebugMode) {
        print(response.body);
      }

      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        return result;
      } else {
        var result = jsonDecode(response.body);

        return result;
      }
    } catch (e) {
      log(e.toString());
    }
  }

  ///Delete of Stripe payment method*/
  Future<dynamic> getDeleteStripePaymentMethod(
      String paymentMethodId, BuildContext context) async {
    try {
      var url = Uri.parse(
          "${ApiConstants.baseUrlStripe}${ApiConstants.paymentMethod}/$paymentMethodId/${ApiConstants.stripeDetach}");

      /*if (kReleaseMode) {
        stripeSecretKey = kSecretLiveKey;
      } else {
        stripeSecretKey = kSecretTestKey;
      }

*/
      var headers = {
        'Authorization': 'Bearer $kSecretLiveKey',
        'Content-Type': 'application/x-www-form-urlencoded'
      };
      var request = http.Request('POST', url);
      request.headers.addAll(headers);
      if (kDebugMode) {
        print(request.bodyFields);
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      if (kDebugMode) {
        print(response.body);
      }
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        return result;
      } else {
        var result = jsonDecode(response.body);
        return result;
      }
    } catch (e) {
      log(e.toString());
    }
  }

  ///Delete of Stripe payment method*/
  Future<dynamic> getUpdateStripePaymentMethod(
      String paymentMethodId, BuildContext context) async {
    try {
      var url = Uri.parse(
          "${ApiConstants.baseUrlStripe}${ApiConstants.paymentMethod}/$paymentMethodId/${ApiConstants.stripeDetach}");

      /* if (kReleaseMode) {
        stripeSecretKey = kSecretLiveKey;
      } else {
        stripeSecretKey = kSecretTestKey;
      }
*/

      var headers = {
        'Authorization': 'Bearer $kSecretLiveKey',
        'Content-Type': 'application/x-www-form-urlencoded'
      };
      var request = http.Request('POST', url);
      request.headers.addAll(headers);
      if (kDebugMode) {
        print(request.bodyFields);
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      if (kDebugMode) {
        print(response);
      }
      if (response.statusCode == 200) {
        if (kDebugMode) {
          print(response.body);
        }
        var result = jsonDecode(response.body);
        return result;
      } else {
        var result = jsonDecode(response.body);
        return result;
      }
    } catch (e) {
      log(e.toString());
    }
  }

  /// Stripe Subscription Detail*/
  Future<dynamic> getSubscriptionDetail(
    BuildContext context,
  ) async {
    try {
      var url =
          Uri.parse(ApiConstants.baseUrl + ApiConstants.subscriptionStatus);
      var headers = {'Authorization': 'Bearer ${SharedPrefs().getTokenKey()}'};
      var request = http.Request('GET', url);

      request.headers.addAll(headers);
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      if (kDebugMode) {
        print(response);
      }
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        return result;
      } else {
        var result = jsonDecode(response.body);
        return result;
      }
    } catch (e) {
      log(e.toString());
    }
  }

  /// Stripe cancel Subscription */
  Future<dynamic> getCancelSubscription(
      BuildContext context, String customerId) async {
    try {
      var url = Uri.parse(
          "${ApiConstants.baseUrl}${ApiConstants.cancelSubscriptionStatus}");
      var headers = {'Authorization': 'Bearer ${SharedPrefs().getTokenKey()}'};
      var request = http.Request('DELETE', url);

      request.headers.addAll(headers);
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      if (kDebugMode) {
        print(response.body);
      }
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        return result;
      } else {
        var result = jsonDecode(response.body);
        return result;
      }
    } catch (e) {
      log(e.toString());
    }
  }

  /// Stripe buy subliminal */
  Future<dynamic> getOneTimeBuySub(
    BuildContext context,
    String name,
    String email,
    String price,
    String token,
    String subId,
  ) async {
    try {
      var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.buySubliminal);

      var headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${SharedPrefs().getTokenKey()}'
      };
      var request = http.Request('POST', url);

      request.body = jsonEncode({
        ApiConstants.stripToken: token,
        ApiConstants.email: email,
        ApiConstants.price: price,
        ApiConstants.name: name,
        ApiConstants.subliminalId: subId,
      });

      if (kDebugMode) {
        print(request.body);
      }
      request.headers.addAll(headers);
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      if (kDebugMode) {
        print(response);
      }
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        return result;
      } else {
        var result = jsonDecode(response.body);
        return result;
      }
    } catch (e) {
      log(e.toString());
    }
  }

  /// Free Trial Used */
  Future<dynamic> getFreeTrialUsed(
    BuildContext context,
    String status,
    String subliminalId,
  ) async {
    try {
      var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.usedFreeTrial);

      var headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${SharedPrefs().getTokenKey()}'
      };
      var request = http.Request('POST', url);

      request.body = jsonEncode({
        ApiConstants.status: status,
        ApiConstants.subliminalId: subliminalId,
      });

      if (kDebugMode) {
        print(request.body);
      }
      request.headers.addAll(headers);
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      if (kDebugMode) {
        print(response);
      }
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        return result;
      } else {
        var result = jsonDecode(response.body);
        return result;
      }
    } catch (e) {
      log(e.toString());
    }
  }

  /// Customer Support */
  Future<dynamic> getCustomerSupport(
    BuildContext context,
    String message,
  ) async {
    try {
      var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.customerSupport);

      var headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${SharedPrefs().getTokenKey()}'
      };
      var request = http.Request('POST', url);

      request.body = jsonEncode({
        ApiConstants.message: message,
      });

      if (kDebugMode) {
        print(request.body);
      }
      request.headers.addAll(headers);
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      if (kDebugMode) {
        print(response);
      }
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        return result;
      } else {
        var result = jsonDecode(response.body);
        return result;
      }
    } catch (e) {
      log(e.toString());
    }
  }

  /// conversion subscribe  */
  Future<dynamic> getConversionSubscribeApi(
    String amount,
  ) async {
    try {
      var url = Uri.parse(ApiConstants.baseUrlConversionFB +
          ApiConstants.pixelId +
          ApiConstants.event);

      var headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };
      final payload = {
        'data': [
          {
            'event_name': 'Subscribe',
            'action_source': 'mobile', // Replace with your event name
            'event_time': DateTime.now().millisecondsSinceEpoch,

            'user_data': {
              'em': SharedPrefs().getUserEmail().toString(),
              // Example email address
            },
            'custom_data': {
              'currency': 'USD',
              'value': amount,
              'predicted_ltv': amount,
            },
          },
        ],
        'access_token': ApiConstants.accessToken,
      };

      var request = http.Request('POST', url);

      request.body = jsonEncode(
        payload,
      );

      if (kDebugMode) {
        print(request.body);
      }
      request.headers.addAll(headers);
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      if (kDebugMode) {
        print(response);
      }
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        return result;
      } else {
        var result = jsonDecode(response.body);
        return result;
      }
    } catch (e) {
      log(e.toString());
    }
  }

  /// conversion purchase  */
  Future<dynamic> getConversionPurchaseApi(
    String amount,
  ) async {
    try {
      var url = Uri.parse(ApiConstants.baseUrlConversionFB +
          ApiConstants.pixelId +
          ApiConstants.event);

      var headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };
      final payload = {
        'data': [
          {
            'event_name': 'Purchase', // Replace with your event name
            'action_source': 'mobile',
            'event_time': DateTime.now().millisecondsSinceEpoch,
            'user_data': {
              'em': SharedPrefs().getUserEmail().toString(),
              // Example email address
            },
            'custom_data': {
              'currency': 'USD',
              'value': amount,
            },
          },
        ],
        'access_token': ApiConstants.accessToken,
      };

      var request = http.Request('POST', url);

      request.body = jsonEncode(
        payload,
      );

      if (kDebugMode) {
        print(request.body);
      }
      request.headers.addAll(headers);
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      if (kDebugMode) {
        print(response);
      }
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        return result;
      } else {
        var result = jsonDecode(response.body);
        return result;
      }
    } catch (e) {
      log(e.toString());
    }
  }

  /// conversion start trial  */
  Future<dynamic> getConversionStartTrialApi() async {
    try {
      var url = Uri.parse(ApiConstants.baseUrlConversionFB +
          ApiConstants.pixelId +
          ApiConstants.event);

      var headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };
      final payload = {
        'data': [
          {
            'event_name': 'StartTrial', // Replace with your event name
            'action_source': 'mobile',
            'event_time': DateTime.now().millisecondsSinceEpoch,
            'user_data': {
              'em': SharedPrefs().getUserEmail().toString(),
              // Example email address
            },
            'custom_data': {
              'currency': 'USD',
              'value': '0.0',
              'predicted_ltv': '0.0',
            },
          },
        ],
        'access_token': ApiConstants.accessToken,
      };

      var request = http.Request('POST', url);

      request.body = jsonEncode(
        payload,
      );

      if (kDebugMode) {
        print(request.body);
      }
      request.headers.addAll(headers);
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      if (kDebugMode) {
        print(response);
      }
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        return result;
      } else {
        var result = jsonDecode(response.body);
        return result;
      }
    } catch (e) {
      log(e.toString());
    }
  }

  /// conversion Add payment  */
  Future<dynamic> getConversionAddPaymentApi() async {
    try {
      var url = Uri.parse(ApiConstants.baseUrlConversionFB +
          ApiConstants.pixelId +
          ApiConstants.event);

      var headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };
      final payload = {
        'data': [
          {
            'event_name': 'StartTrial', // Replace with your event name
            'action_source': 'mobile',
            'event_time': DateTime.now().millisecondsSinceEpoch,
            'user_data': {
              'em': SharedPrefs().getUserEmail().toString(),
              // Example email address
            },
          },
        ],
        'access_token': ApiConstants.accessToken,
      };

      var request = http.Request('POST', url);

      request.body = jsonEncode(
        payload,
      );

      if (kDebugMode) {
        print(request.body);
      }
      request.headers.addAll(headers);
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      if (kDebugMode) {
        print(response);
      }
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        return result;
      } else {
        var result = jsonDecode(response.body);
        return result;
      }
    } catch (e) {
      log(e.toString());
    }
  }

  /// conversion ViewContent  */
  Future<dynamic> getConversionViewContentApi(
    BuildContext context,
    String amount,
  ) async {
    try {
      var url = Uri.parse(ApiConstants.baseUrlConversionFB +
          ApiConstants.pixelId +
          ApiConstants.event);

      var headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };
      final payload = {
        'data': [
          {
            'event_name': 'ViewContent', // Replace with your event name
            'action_source': 'mobile',
            'event_time': DateTime.now().millisecondsSinceEpoch,
            'user_data': {
              'em': SharedPrefs().getUserEmail().toString(),
              // Example email address
            },
          },
        ],
        'access_token': ApiConstants.accessToken,
      };

      var request = http.Request('POST', url);

      request.body = jsonEncode(
        payload,
      );

      if (kDebugMode) {
        print(request.body);
      }
      request.headers.addAll(headers);
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      if (kDebugMode) {
        print(response);
      }
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        return result;
      } else {
        var result = jsonDecode(response.body);
        return result;
      }
    } catch (e) {
      log(e.toString());
    }
  }
}
