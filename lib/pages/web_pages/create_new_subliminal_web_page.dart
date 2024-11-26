import 'dart:async';
import 'dart:convert';
import 'dart:developer';
/*import 'dart:html' as html;*/
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
import 'package:success_subliminal/pages/create_new_subliminal_page.dart';
import 'package:success_subliminal/widget/WebTopBarContainer.dart';

import '../../app/router.dart';
import '../../data/api/ApiService.dart';
import '../../dialogs/custom_alert_dialog.dart';
import '../../utils/center_loader.dart';
import '../../utils/constant.dart';
import '../../utils/shared_prefs.dart';
import '../../utils/toast.dart';
import '../../widget/ButtonWidget400.dart';
import '../../widget/CommonTextField.dart';
import '../../widget/NoteField.dart';

class CreateNewSubliminalWebPage extends StatefulWidget {
  const CreateNewSubliminalWebPage({Key? key}) : super(key: key);

  @override
  _CreateNewWebSubliminal createState() => _CreateNewWebSubliminal();
}

class _CreateNewWebSubliminal extends State<CreateNewSubliminalWebPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late dynamic createSubliminal;

  Future<void> initializePreference() async {
    SharedPrefs.init(await SharedPreferences.getInstance());
  }

  final _titleText = TextEditingController();
  final _descriptionText = TextEditingController();
  final FocusNode _titleFocus = FocusNode();
  final FocusNode _descriptionFocus = FocusNode();

  File imageFile = File("");
  PickedFile? pickedFile;
  bool isImageFile = false;
  FlutterTts flutterTts = FlutterTts();
  String initialValue = 'en-GB-News-I';
  String categoryInitialValue = 'Select Category';
  String categoryId = "";
  double volumeInitialValue = 1.0;
  double pitchInitialValue = 1.0;
  double rateInitialValue = 1.0;
  double sizeScreen = 0.4;
  double leftPadding = 200;
  double rightPadding = 200;
  List<Uint8List> images = [];
  Uint8List? image;
  int difference = 0;
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

  bool isLogin = false;
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
    initializePreference().whenComplete(() {
      setState(() {
        _getSubscriptionListData();
      });
    });

    setState(() {
      isLogin = SharedPrefs().isLogin();
      isTrial = SharedPrefs().isFreeTrail();
      isFreeTrialUsed = SharedPrefs().isFreeTrailUsed();
      isSubscriptionActive = SharedPrefs().isSubscription();

      setState(() {
        if (!isLogin) {
          context.pushReplacement(Routes.home);
        }
      });
    });
    Future.delayed(const Duration(seconds: 2)).then((value) => setState(() {
          DateTime dateTime = DateTime.now();
          DateTime pickedDate =
              DateTime.parse(SharedPrefs().getTrialStartDate()!);

          difference = dateTime.difference(pickedDate).inDays;
        }));
    if (kDebugMode) {
      print(isLogin);
      print(isTrial);
      print(isFreeTrialUsed);
      print(isSubscriptionActive);
    }

    _getStripeSubscriptionDetail();
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

  void _getCreateSubliminalData(Size mq) async {
    if (image != null) {
      cover_code = base64Encode(image!);
    }
    createSubliminal = await ApiService().getCreateSubliminal(
        _titleText.text.toString(),
        _descriptionText.text.toString(),
        finalStr,
        imageFile,
        cover_code,
        context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        if (createSubliminal != null) {
          if (createSubliminal['http_code'] == 200) {
            Navigator.of(context, rootNavigator: true).pop();
            if (createSubliminal['data'] == null) {
              buildUpgradeSubscriptionDialogContainer(context, mq);
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

  buildUpgradeSubscriptionDialogContainer(BuildContext contexts, Size mq) {
    return showDialog(
        context: contexts,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0)),
              backgroundColor: kDialogBgColor,
              insetPadding: const EdgeInsets.all(15),
              child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SizedBox(
                    width: mq.width * 0.2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(
                            top: 10,
                          ),
                          alignment: Alignment.center,
                          child: Align(
                              alignment: Alignment.center,
                              child: RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  text: difference < 8 && !isSubscriptionActive
                                      ? "You’ve reached your Create Subliminal limit for your Free Trial. You can wait until the card on file gets charged with the subscription plan or you can upgrade now."
                                      : 'You’ve reached your Create Subliminal limit for your current Plan',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontFamily: 'DPClear',
                                    fontWeight: FontWeight.w400,
                                  ),
                                  /*defining default style is optional */
                                ),
                              )),
                        ),
                        /* const TextFieldWidget400(
                            text:
                                "\n1. You can wait until your paid subscription starts to create more subliminals",
                            size: 15,
                            color: Colors.white),
                        const TextFieldWidget400(
                            text:
                                "2. You can upgrade your plan and start creating more subliminals now",
                            size: 15,
                            color: Colors.white),*/
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              decoration: kButtonBox10Decoration,
                              margin: const EdgeInsets.only(
                                  top: 20, right: 5, left: 5),
                              child: ButtonWidget400(
                                  buttonSize: 40,
                                  name: 'Not Now'.toUpperCase(),
                                  icon: '',
                                  visibility: false,
                                  padding: 10,
                                  onTap: () => {Navigator.pop(context)},
                                  size: 12,
                                  deco: kButtonBox10Decoration),
                            ),
                            Container(
                              decoration: kButtonBox10Decoration,
                              margin: const EdgeInsets.only(
                                  top: 20, right: 5, left: 5),
                              child: ButtonWidget400(
                                  buttonSize: 40,
                                  name: 'Upgrade'.toUpperCase(),
                                  icon: '',
                                  visibility: false,
                                  padding: 10,
                                  onTap: () => {_handleActiveSubscription()},
                                  size: 12,
                                  deco: kButtonBox10Decoration),
                            ),
                          ],
                        )
                      ],
                    ),
                  )));
        });
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
            if (constraints.maxWidth > 757) {
              if (constraints.maxWidth < 900) {
                leftPadding = 50;
                rightPadding = 50;
                sizeScreen = 0.8;
              } else if (constraints.maxWidth < 1100) {
                leftPadding = 50;
                rightPadding = 50;
                sizeScreen = 0.7;
              } else if (constraints.maxWidth < 1300) {
                leftPadding = 100;
                rightPadding = 100;
                sizeScreen = 0.6;
              } else if (constraints.maxWidth < 1600) {
                leftPadding = 150;
                rightPadding = 150;
                sizeScreen = 0.5;
              } else if (constraints.maxWidth < 2000) {
                leftPadding = 200;
                rightPadding = 200;
                sizeScreen = 0.4;
              }
              return buildHomeContainer(context, mq);
            } else {
              return const CreateNewSubliminalPage();
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
            child: Stack(children: <Widget>[
              const WebTopBarContainer(screen: "create"),
              Container(
                margin: EdgeInsets.only(
                    bottom: 100,
                    top: loginTopPadding,
                    left: leftPadding,
                    right: rightPadding),
                child: ListView(
                  shrinkWrap: false,
                  primary: true,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                            width: mq.width * sizeScreen,
                            child: buildCreateSubliminalContainer(context, mq)),
                        SizedBox(
                          width: mq.width * sizeScreen,
                          child: buildCreateButton(context, mq),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ])));
  }

  Widget buildCreateButton(BuildContext context, Size mq) {
    return ConstrainedBox(
        constraints: const BoxConstraints(minWidth: double.infinity),
        child: Container(
          decoration: kButtonBox10Decoration,
          margin: const EdgeInsets.only(top: 40, left: 15, right: 15),
          height: 50,
          child: ElevatedButton(
              onPressed: () {
                if (_titleText.text.isEmpty) {
                  const CustomAlertDialog()
                      .errorDialog("Please Enter the Title", context);
                } else if (_descriptionText.text.isEmpty) {
                  const CustomAlertDialog()
                      .errorDialog("Please Enter the Description", context);
                } else if (!SharedPrefs().isFreeTrail() &&
                    !SharedPrefs().isSubscription()) {
                  const CustomAlertDialog().showAlertDialog(context,
                      "Sorry!, Please take the subscription, you can't  create the subliminal without subscription");
                } else {
                  /* await flutterTts.setLanguage(initialValue);
                  await flutterTts.setSpeechRate(rateInitialValue);
                  await flutterTts.setVolume(volumeInitialValue);
                  await flutterTts.setPitch(pitchInitialValue);*/
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
                  finalStr =
                      description * mul + description.substring(0, diffLength);

                  if (kDebugMode) {
                    print('finalStrLen--- ${finalStr.length}');
                    print('finalStr--- $finalStr');
                  }
                  setState(() {
                    _getCreateSubliminalData(mq);
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.only(left: 25, right: 25),
                primary: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(kCreateSubliminal.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: 'DPClear',
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      )),
                ],
              )),
        ));
  }

  Widget buildCreateSubliminalContainer(BuildContext context, Size mq) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          alignment: Alignment.topLeft,
          margin: const EdgeInsets.only(left: 30, right: 15, top: 30),
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
          margin: const EdgeInsets.only(left: 15, right: 15, top: 15),
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
          margin:
              const EdgeInsets.only(left: 25, right: 15, top: 25, bottom: 10),
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
            margin: const EdgeInsets.only(left: 15, right: 15, top: 5),
            child: NoteField(
              controller: _descriptionText,
              hintText: kDescription,
              focus: _descriptionFocus,
            )),
        Container(
          alignment: Alignment.topLeft,
          margin: const EdgeInsets.only(
            left: 24,
            right: 15,
            top: 20,
          ),
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
                //pickFile()
                pickImages()
                //_openGallery(context)
              },
              child: Container(
                width: mq.width * .3,
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
                      child: Image.memory(image!,
                          fit: BoxFit
                              .fill)) /*Image.network(imageFile.path, scale: 5)),*/
                  )
              : Expanded(
                  flex: 1,
                  child: Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(left: 15, right: 15),
                    child: Text(
                      'JPG, PNG FILES 5 MB MAX'.toUpperCase(),
                      style: const TextStyle(
                          color: Colors.white54,
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

  Future<void> pickFile() async {
    if (kIsWeb) {
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null) {
        Uint8List? fileBytes = result.files.first.bytes;
        String fileName = result.files.first.name;

        print("object" + fileBytes!.length.toString());
        print("fileName" + fileName);
        // Upload file
      }

      //  FilePickerResult? result = await FilePicker.platform.pickFiles();

      //   if (result != null) {

      /*  String fileName = result.files.first.name;

        double fileSize = getFileSize(result.files.first.path!);
        if (fileSize > 2) {
          isImageFile = false;
          toast("your image size should be less than 5MB", false);
        } else {
          setState(() {
            imageFile = File(result.files.first.path!);

            isImageFile = true;
          });
        }*/
      //  } // Upload file
    }
  }

  Widget speechFields(BuildContext context, Size mq) {
    return ExpansionTile(
      title: const Text(
        'Speech Parameters',
        style: TextStyle(fontSize: 24),
      ),
      children: [
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
    pickedFile = await ImagePicker()
        .getImage(source: ImageSource.gallery, imageQuality: 50);

    // print("pickedFile" + pickedFile!.path);
    setState(() {
      double fileSize = getFileSize(pickedFile!.path);
      if (fileSize > 2) {
        isImageFile = false;
        toast("your image size should be less than 5MB", false);
      } else {
        imageFile = File(pickedFile!.path);
        //print("pickedFile" + imageFile.path);
        isImageFile = true;
      }
    });
  }

  Future<List<Uint8List>> pickImages() async {
    try {
      /*html.File? imageFiles = (await ImagePickerWeb.getImageAsFile());

      setState(() {
        isImageFile = true;
        imageFile = File(imageFiles!.relativePath!);
      });*/
      List<int> bytes = [];
      var files = await FilePicker.platform
          .pickFiles(type: FileType.image, allowMultiple: false);
      if (files != null && files.files.isNotEmpty) {
        for (int i = 0; i < files.files.length; i++) {
          setState(() {
            isImageFile = true;
            images.add(files.files[i].bytes!);

            image = files.files[i].bytes!;
            // bytes.add(files.files[i].bytes!);

            // print("image--${image.length}");
          });
          // imageFile = await bytesToFile(image, "Subliminal_image");
          /* setState(() {
            isImageFile = true;
            images.add(files.files[i].bytes!);
            imageFile = File(files.files[i].path!);
            print("image--${image.length}");
          });*/
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return images;
  }

/*
  void saveFile(Uint8List bytes, String fileName) {
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.document.createElement('a') as html.AnchorElement
      ..href = url
      ..download = fileName;
    html.document.body!.append(anchor);
    anchor.click();
    html.Url.revokeObjectUrl(url);
  }
*/

  Future<File> bytesToFile(Uint8List bytes, String fileName) async {
    String dir = (await getApplicationDocumentsDirectory()).path;
    File file = File('$dir/$fileName');
    await file.writeAsBytes(bytes);
    return file;
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
  }
}
