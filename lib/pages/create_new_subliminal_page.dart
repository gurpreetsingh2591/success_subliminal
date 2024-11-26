import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app/router.dart';
import '../data/api/ApiService.dart';
import '../dialogs/custom_alert_dialog.dart';
import '../dialogs/custom_uprade_dialog.dart';
import '../utils/center_loader.dart';
import '../utils/constant.dart';
import '../utils/shared_prefs.dart';
import '../utils/toast.dart';
import '../widget/BottomBarStateFullWidget.dart';
import '../widget/CommonTextField.dart';
import '../widget/NoteField.dart';

class CreateNewSubliminalPage extends StatefulWidget {
  const CreateNewSubliminalPage({Key? key}) : super(key: key);

  @override
  CreateNewSubliminal createState() => CreateNewSubliminal();
}

class CreateNewSubliminal extends State<CreateNewSubliminalPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late dynamic createSubliminal;

  Future<void> initializePreference() async {
    SharedPrefs.init(await SharedPreferences.getInstance());
  }

  final _titleText = TextEditingController();
  final _descriptionText = TextEditingController();
  final FocusNode _titleFocus = FocusNode();
  final FocusNode _descriptionFocus = FocusNode();
  List<Uint8List> images = [];
  Uint8List? image;
  File imageFile = File("");
  bool isImageFile = false;
  FlutterTts flutterTts = FlutterTts();
  String initialValue = 'en-GB-News-I';
  String categoryInitialValue = 'Select Category';
  String categoryId = "";
  double volumeInitialValue = 1.0;
  double pitchInitialValue = 1.0;
  double rateInitialValue = 1.0;
  Map<String, String> voiceList = {};
  List<String> languageList = [
    'en-GB-News-J',
    'en-GB-News-I',
  ];
  String finalStr = "";
  final player = AudioPlayer();
  final _apikey = "AIzaSyAWYc1QmZiIamKdk8ETKO-58l9xvDFU9Vk";
  AudioPlayer audioPlayer = AudioPlayer();
  String femaleVoice = "cmn-CN-Standard-A";
  String maleVoice = "en-US-Standard-A";
  bool isCategory = false;

  final int _maxLength = 4500;
  int mul = 0;
  String description = "";
  String cover_code = "";
  int strLength = 0;
  int diffLength = 0;
  int difference = 0;
  bool isFreeTrialUsed = false;
  bool isTrial = false;
  bool isSubscriptionActive = false;

  List<dynamic> subscriptionList = [];
  List<dynamic> subscriptionPriceList = [];
  late dynamic subscription;
  int selectIndex = 0;
  String amount = "";
  String plan = "";
  String subId = "";
  dynamic subliminal;
  dynamic subscriptionDetail;
  late List<dynamic> subliminalList = [];

  @override
  initState() {
    super.initState();
    _titleText.text = "";
    _descriptionText.text = "";
    initializePreference().whenComplete(() {
      setState(() {
        _getSubscriptionListData();
      });
    });
    isLogin = SharedPrefs().isLogin();
    isTrial = SharedPrefs().isFreeTrail();
    isFreeTrialUsed = SharedPrefs().isFreeTrailUsed();
    isSubscriptionActive = SharedPrefs().isSubscription();
    isTrialStatus = SharedPrefs().isFreeTrail();
    if (kDebugMode) {
      print(isLogin);
      print(isTrial);
      print(isFreeTrialUsed);
      print(isSubscriptionActive);
    }
    DateTime dateTime = DateTime.now();
    DateTime pickedDate = DateTime.parse(SharedPrefs().getTrialStartDate()!);

    difference = dateTime.difference(pickedDate).inDays;
    _getStripeSubscriptionDetail();
  }

  void _getStripeSubscriptionDetail() async {
    subscriptionDetail = await ApiService().getSubscriptionDetail(context);

    Future.delayed(const Duration(seconds: 2)).then((value) => setState(() {
          setState(() {
            if (subscriptionDetail['http_code'] != 200) {
            } else {
              subscriptionDetail = subscriptionDetail['data']
                  ['current_user_subscription_status'];

              if (subscriptionDetail != null || subscriptionDetail != "") {
                _getIsUserSubscription(context);
              }
            }
          });
        }));
  }

  void _getIsUserSubscription(BuildContext context) {
    setState(() {
      if (subscriptionDetail['subscription_status'] == "trialing") {
        SharedPrefs().setIsFreeTrail(true);
        SharedPrefs().setIsSubscription(false);
      } else if (subscriptionDetail['subscription_status'] == "active") {
        SharedPrefs().setIsSubscription(true);
        SharedPrefs().setIsFreeTrail(false);
      } else if (subscriptionDetail['subscription_status'] == "canceled") {
        SharedPrefs().setIsSubscription(false);
        SharedPrefs().setIsFreeTrail(false);
      }

      SharedPrefs().setUserSubscriptionId(
          subscriptionDetail['subscription_id'].toString());
      SharedPrefs().setUserPlanId(subscriptionDetail['product_id'].toString());
      SharedPrefs().setIsSubscriptionStatus(subscriptionDetail['status']);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _titleText.text = "";
    _descriptionText.text = "";
  }

  void _getSubscriptionListData() async {
    subscription = await ApiService().getStripeProduct(context);

    Future.delayed(const Duration(seconds: 1)).then((value) => setState(() {
          setState(() {
            if (subscription['http_code'] != 200) {
            } else {
              subscriptionList
                  .addAll(subscription['data']['product_list']['data']);
              subscriptionPriceList
                  .addAll(subscription['data']['product_price']['data']);
            }

            for (int i = 0; i < subscriptionList.length; i++) {
              if (isTrial || isSubscriptionActive) {
                if (kDebugMode) {
                  print("id ----${subscriptionList[i]['id'].toString()}");
                  print(
                      "subscriptionId ----${SharedPrefs().getUserPlanId().toString()}");
                }

                if (subscriptionList[i]['id'].toString() ==
                    SharedPrefs().getUserPlanId().toString()) {
                  setState(() {
                    amount = (subscriptionPriceList[i]['unit_amount'] / 100)
                        .toString();
                    plan = subscriptionList[i]['name'];
                    SharedPrefs().setUserPlanName(plan);
                    SharedPrefs().setUserPlanAmount(amount);
                    subId = subscriptionList[i]['id'].toString();
                  });
                }
              }
            }

            if (kDebugMode) {
              print("size ----${subscriptionList.length}");
              print("name ----${subscriptionList[0]['name']}");
              print(
                  "size ----${subscription['data']['product_list']['data'][0]['name']}");
            }
          });
        }));
  }

  _handleActiveSubscription() {
    if (SharedPrefs().getUserPlanId() != null && plan != "") {
      if (!isTrial && !isSubscriptionActive) {
        context
            .pushNamed('subscription', queryParameters: {"screen": 'create'});
      } else {
        if (!isTrial && isSubscriptionActive) {
          context
              .pushNamed('subscription', queryParameters: {"screen": 'create'});
        } else {
          context.pushNamed('add-payment', queryParameters: {
            'amount': amount,
            "subscriptionId": subId,
            "planType": plan,
            "screen": 'create',
          });
        }
      }
    } else {
      context.pushNamed('subscription', queryParameters: {
        "screen": 'create',
      });
    }

    /* if (SharedPrefs().getUserPlanId() != null) {
      if (plan != "") {
        context.pushNamed('add-payment', queryParameters: {
          'amount': amount,
          "subscriptionId": subId,
          "planType": plan,
          "screen": 'create',
        });
      }
    } else {
      context.pushNamed('subscription', queryParameters: {
        "screen": 'create',
      });
    }*/
  }

  void _getCreateCategoryData() async {
    createSubliminal = await ApiService().getCreateSubliminal(
        _titleText.text.toString(),
        _descriptionText.text.toString(),
        finalStr,
        imageFile,
        cover_code,
        context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      //valueNotifier.value = _pcm; //provider
      setState(() {
        if (createSubliminal != null) {
          if (createSubliminal['http_code'] == 200) {
            if (createSubliminal['data'] == null) {
              toast(
                  "You’ve reached your Create Subliminal limit for your current Plan",
                  false);
              CustomUpgradeDialog(
                difference: difference,
                isSubscriptionActive: isSubscriptionActive,
                isTrial: isTrial,
                onTap: () {
                  _handleActiveSubscription();
                },
                context: context,
              );
            } else {
              try {
                context.push(Routes.libraryNew);
                _titleText.text = "";
                _descriptionText.text = "";
                categoryId = "";
              } catch (e) {
                log(e.toString());
                context.push(Routes.libraryNew);
                _titleText.text = "";
                _descriptionText.text = "";
                categoryId = "";
              }
            }
            Navigator.of(context, rootNavigator: true).pop();
          } else {
            try {
              Navigator.of(context, rootNavigator: true).pop();
              toast("Sorry! Subliminal Not Created Successfully", false);
            } catch (e) {
              Navigator.of(context, rootNavigator: true).pop();
              toast("Sorry! Subliminal Not Created Successfully", false);
            }
          }
        } else {
          Navigator.of(context, rootNavigator: true).pop();
          toast("Sorry! Subliminal Not Created Successfully", false);
        }
      });
    });
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
        body: SafeArea(
          // child: SingleChildScrollView(
          child: Container(
            constraints: BoxConstraints(
              maxHeight: mq.height,
            ),
            /* decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [backgroundDark, backgroundDark],
                stops: [0.5, 1.5],
              ),
            ),*/
            child: Stack(
              children: <Widget>[
                Image.asset(
                  'assets/images/ic_bg_dark_blue.png',
                  fit: BoxFit.cover,
                  height: double.infinity,
                  width: double.infinity,
                  alignment: Alignment.center,
                ),
                buildTopBarContainer(context, mq),
                const BottomBarStateFull(screen: "create", isUserLogin: true),
                Container(
                  margin: const EdgeInsets.only(bottom: 70, top: 70),
                  child: ListView(
                    shrinkWrap: false,
                    primary: true,
                    children: [
                      buildCreateSubliminalContainer(context),
                      /* isCategory
                            ? buildCategoriesDropDownField(mq)
                            : const Center(child: CircularProgressIndicator()),*/
                      //speechFields(context, mq),
                      buildCreateButton(context),
                    ],
                  ),
                )
              ],
            ),
          ),
        ));
  }

  Widget buildCreateButton(BuildContext context) {
    return ConstrainedBox(
        constraints: const BoxConstraints(minWidth: double.infinity),
        child: Container(
          decoration: kButtonBox10Decoration,
          margin: const EdgeInsets.only(top: 40, left: 15, right: 15),
          height: 50,
          child: ElevatedButton(
              onPressed: () {
                // await flutterTts.setVoice({"name": "Karen", "locale": "en-AU"});
                //
                if (_titleText.text.isEmpty) {
                  const CustomAlertDialog()
                      .errorDialog("Please Enter the Title", context);
                } else if (_descriptionText.text.isEmpty) {
                  const CustomAlertDialog()
                      .errorDialog("Please Enter the Description", context);
                } else if (!SharedPrefs().isSubscription() &&
                    !SharedPrefs().isFreeTrail()) {
                  const CustomAlertDialog().showAlertDialog(context,
                      "Sorry!, Please take the subscription, you can't  create the subliminal without subscription");
                } else {
                  /*  await flutterTts.setLanguage(initialValue);
                  await flutterTts.setSpeechRate(rateInitialValue);
                  await flutterTts.setVolume(volumeInitialValue);
                  await flutterTts.setPitch(pitchInitialValue);
                  flutterTts.synthesizeToFile(
                      _descriptionText.text,
                      Platform.isAndroid
                          ? "subliminal_tts.mp3"
                          : "subliminal_tts.caf");*/

                  /* String filePath = "";
                  Directory? appDir =
                      await getApplicationDocumentsDirectory(); // 1
                  String appDocumentsPath = appDir.path; // 2
                  Directory appDirec = Directory(appDir.path);
                  if (await appDirec.exists()) {
                    if (Platform.isAndroid) {
                      filePath =
                          '/storage/emulated/0/Android/data/com.successsubliminal.success_subliminal/files/subliminal_tts.mp3';
                    } else if (Platform.isIOS) {
                      filePath = '$appDocumentsPath/subliminal_tts.caf';
                    }
                  } else {
                    if (Platform.isAndroid) {
                      filePath =
                          '/storage/emulated/0/Android/data/com.successsubliminal.success_subliminal/files/subliminal_tts.mp3';
                    } else if (Platform.isIOS) {
                      filePath = '$appDocumentsPath/subliminal_tts.caf';
                    }
                    await Directory(filePath).create();
                  }*/

                  setState(() {
                    showCenterLoader(context);
                  });

                  mul = 0;
                  description = "";
                  strLength = 0;
                  diffLength = 0;

                  description = "${_descriptionText.text} ";

                  strLength = description.length;
                  mul = (_maxLength / strLength).floor();
                  diffLength = _maxLength - (mul * strLength);
                  /*  if (kDebugMode) {
                    print('mul $mul');
                    print('diffLength $diffLength');
                  }*/

                  finalStr =
                      description * mul + description.substring(0, diffLength);

                  if (kDebugMode) {
                    print('finalStrLen--- ${finalStr.length}');
                    print('finalStr--- $finalStr');
                  }
                  setState(() {
                    if (image != null) {
                      cover_code = base64Encode(image!);
                    } else {
                      cover_code = "";
                    }
                    _getCreateCategoryData();
                  });
                  // playmalevoice(finalStr, initialValue, "en-US", pitchInitialValue, rateInitialValue);
                }
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.transparent,
                shadowColor: Colors.transparent,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(kCreateSubliminal,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontFamily: 'DPClear',
                        fontWeight: FontWeight.w600,
                      )),
                ],
              )),
        ));
  }

  Widget buildTopBarContainer(BuildContext context, Size mq) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => {
            // Navigator.pop(context)
            context.go(Routes.create)
          },
          child: Container(
            padding: const EdgeInsets.only(left: 10, top: 5),
            child: Align(
              alignment: Alignment.topLeft,
              child: Image.asset('assets/images/ic_arrow_left.png', scale: 1.5),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.only(left: 15, top: 10),
          child: const Align(
            alignment: Alignment.topLeft,
            child: Text(
              'New Subliminal',
              style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontFamily: 'DPClear',
                  fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildCreateSubliminalContainer(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Container(
          alignment: Alignment.topLeft,
          margin: const EdgeInsets.only(left: 20, right: 15, top: 10),
          child: const Text(
            'Title',
            style: TextStyle(
                color: Colors.white,
                fontFamily: 'DPClear',
                fontWeight: FontWeight.w500,
                fontSize: 20),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(left: 15, right: 15, top: 10),
          decoration: kEditTextDecoration,
          child: CommonTextField(
            controller: _titleText,
            hintText: kTitle,
            text: "",
            isFocused: true,
            isDeco: true,
            textColor: Colors.white,
            focus: _titleFocus,
          ),
        ),
        Container(
          alignment: Alignment.topLeft,
          margin: const EdgeInsets.only(left: 20, right: 15, top: 20),
          child: const Text(
            'Description',
            style: TextStyle(
                color: Colors.white,
                fontFamily: 'DPClear',
                fontWeight: FontWeight.w500,
                fontSize: 20),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(left: 15, right: 15, top: 10),
          decoration: kEditTextDecoration,
          child: NoteField(
            controller: _descriptionText,
            hintText: kDescription,
            focus: _descriptionFocus,
          ),
        ),
        Container(
          alignment: Alignment.topLeft,
          margin: const EdgeInsets.only(left: 20, right: 15, top: 20),
          child: const Text(
            'Cover',
            style: TextStyle(
                color: Colors.white,
                fontFamily: 'DPClear',
                fontWeight: FontWeight.w500,
                fontSize: 20),
          ),
        ),
        Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: () => {
                //toast("your image size should be less than 5MB", false),
                kIsWeb ? pickImages() : _openGallery(context)
              },
              child: Container(
                padding: const EdgeInsets.only(left: 20, top: 15, bottom: 15),
                margin: const EdgeInsets.only(left: 15, top: 10),
                decoration: kBlackButtonDecoration,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Image.asset('assets/images/ic_gallery.png', scale: 1.5),
                    Container(
                      padding: const EdgeInsets.only(left: 10),
                      child: Text('add subliminal cover'.toUpperCase(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'DPClear',
                              fontWeight: FontWeight.w700,
                              fontSize: 12)),
                    ),
                  ],
                ),
              ),
            ),
          ),
          isImageFile
              ? Expanded(
                  flex: 1,
                  child: Container(
                      height: 100,
                      alignment: Alignment.center,
                      margin: const EdgeInsets.only(left: 15, right: 15),
                      child: kIsWeb
                          ? Image.memory(image!, fit: BoxFit.fill)
                          : Image.file(imageFile, scale: 5)),
                )
              : Expanded(
                  flex: 1,
                  child: Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(left: 15, right: 15),
                    child: Text(
                      'JPG, PNG FILES 5 MB MAX'.toUpperCase(),
                      style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'DPClear',
                          fontWeight: FontWeight.w700,
                          fontSize: 14),
                    ),
                  ),
                )
        ]),
      ],
    );
  }

  Widget speechFields(BuildContext context, Size mq) {
    return ExpansionTile(
      title: const Text(
        'Speech Parameters',
        style: TextStyle(fontSize: 24),
      ),
      children: [
        //buildLanguageDropDownField(mq),
        Container(
          margin: const EdgeInsets.only(left: 15, right: 15),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              const Text('Volume'),
              Expanded(
                child: Slider(
                  value: volumeInitialValue,
                  onChanged: (double value) {
                    setState(() {
                      volumeInitialValue = value;
                    });
                  },
                  min: 0.5,
                  max: 5.0,
                ),
              ),
              Text(volumeInitialValue.toStringAsFixed(1)),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.only(left: 15, right: 15),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              const Text('Pitch'),
              Expanded(
                child: Slider(
                  value: pitchInitialValue,
                  onChanged: (double value) {
                    setState(() {
                      pitchInitialValue = value;
                    });
                  },
                  min: 0.1,
                  max: 2.0,
                ),
              ),
              Text(pitchInitialValue.toStringAsFixed(1)),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.only(left: 15, right: 15),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              const Text('Rate'),
              Expanded(
                child: Slider(
                  value: rateInitialValue,
                  onChanged: (double value) {
                    setState(() {
                      rateInitialValue = value;
                    });
                  },
                  min: 0.1,
                  max: 2.0,
                ),
              ),
              Text(rateInitialValue.toStringAsFixed(1)),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildLanguageDropDownField(Size mq) {
    return Container(
      padding: const EdgeInsets.only(left: 10),
      child: DropdownButton<String>(
        value: initialValue,
        icon: const Icon(Icons.keyboard_arrow_down),
        iconSize: 24,
        elevation: 16,
        underline: Container(
          height: 0,
          color: Colors.transparent,
        ),
        style: const TextStyle(
          fontSize: 14,
          fontFamily: 'DPClear',
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        onChanged: (String? data) {
          setState(() {
            initialValue = data!;
          });
        },
        items: languageList.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
    );
  }

  Future _openGallery(BuildContext context) async {
    // final picker = ImagePicker();
    PickedFile? pickedFile = await ImagePicker()
        .getImage(source: ImageSource.gallery, imageQuality: 50);
    setState(() {
      double fileSize = getFileSize(pickedFile!.path);
      if (fileSize > 2) {
        isImageFile = false;
        toast("your image size should be less than 5MB", false);
      } else {
        imageFile = File(pickedFile.path);

        isImageFile = true;
      }
    });
    // Navigator.pop(context);
  }

  Future<List<Uint8List>> pickImages() async {
    try {
      var files = await FilePicker.platform
          .pickFiles(type: FileType.image, allowMultiple: false);
      if (files != null && files.files.isNotEmpty) {
        for (int i = 0; i < files.files.length; i++) {
          setState(() {
            isImageFile = true;
            images.add(files.files[i].bytes!);

            image = files.files[i].bytes!;
          });
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return images;
  }

  double getFileSize(String filepath) {
    var file = File(filepath);
    int sizeInBytes = file.lengthSync();
    double sizeInMb = sizeInBytes / (1024 * 1024);
    return sizeInMb;
  }

  Future<http.Response> texttospeech(String text, String voicetype,
      String langCode, double pitch, double rate) {
    var url = Uri.parse(
        "https://texttospeech.googleapis.com/v1beta1/text:synthesize?key=$_apikey");

    var body = json.encode({
      "audioConfig": {
        "audioEncoding": "LINEAR16",
        "pitch": pitch,
        "speakingRate": rate
      },
      "input": {"text": text},
      "voice": {"languageCode": langCode, "name": voicetype}
    });

    var response = http.post(url,
        headers: {"Content-type": "application/json"}, body: body);

    return response;
  }

//Play  voice
  playmalevoice(String text, String voice, String langCode, double pitch,
      double rate) async {
    var response = await texttospeech(text, voice, langCode, pitch, rate);
    var jsonData = jsonDecode(response.body);

    String audioBase64 = jsonData['audioContent'];
    Uint8List bytes = base64Decode(audioBase64);

    String filePath = "";
    Directory? appDir = await getApplicationDocumentsDirectory(); // 1
    String appDocumentsPath = appDir.path; // 2
    Directory appDirec = Directory(appDir.path);
    if (await appDirec.exists()) {
      if (Platform.isAndroid) {
        filePath =
            '/storage/emulated/0/Android/data/com.successsubliminal.success_subliminal/files/subliminal_tts.mp3';
      } else if (Platform.isIOS) {
        filePath = '$appDocumentsPath/subliminal_tts.caf';
      }
    } else {
      if (Platform.isAndroid) {
        filePath =
            '/storage/emulated/0/Android/data/com.successsubliminal.success_subliminal/files/subliminal_tts.mp3';
      } else if (Platform.isIOS) {
        filePath = '$appDocumentsPath/subliminal_tts.caf';
      }
      await Directory(filePath).create();
    }

    File file = File(filePath);

    await file.writeAsBytes(bytes);
    //audioPlayer.setVolume(1);
    //var result = audioPlayer.setFilePath(file.path);
    //audioPlayer.play();

    /* setState(() {
      _getCreateCategoryData(file);
    });*/
  }
}
