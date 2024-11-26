import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_share_me/flutter_share_me.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app/router.dart';
import '../data/api/ApiService.dart';
import '../utils/center_loader.dart';
import '../utils/constant.dart';
import '../utils/shared_prefs.dart';
import '../utils/toast.dart';
import '../widget/BottomBarContainer.dart';

class MySubliminalPage extends StatefulWidget {
  const MySubliminalPage({Key? key}) : super(key: key);

  @override
  _MySubliminalPage createState() => _MySubliminalPage();
}

class _MySubliminalPage extends State<MySubliminalPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late List<dynamic> subliminalList = [];

  late dynamic subliminal;
  late dynamic _signUpModel;
  bool isLoading = false;
  bool isSubliminal = false;
  final player = AudioPlayer();
  String filter = "all";

  @override
  void initState() {
    super.initState();
    _getMySubliminalListData(filter);
    initializePreference().whenComplete(() {
      setState(() {});
    });
  }

  Future<void> initializePreference() async {
    SharedPrefs.init(await SharedPreferences.getInstance());
  }

  void _getMySubliminalListData(String filter) async {
    subliminal = await ApiService().getMySubliminalList(context);

    Future.delayed(const Duration(seconds: 2))
        .then((value) => setState(() async {
              setState(() {
                if (subliminal['http_code'] != 200) {
                } else {
                  isSubliminal = true;
                  subliminalList.addAll(subliminal['data']['subliminals']);
                }
                if (kDebugMode) {
                  print("size ----${subliminalList.length}");
                }
              });
            }));
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
          /*   decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [backgroundDark, backgroundDark],
              stops: [0.5, 1.5],
            ),
          ),*/
          child: Stack(
            children: <Widget>[
              Image.asset(
                'assets/images/bg_image.png',
                fit: BoxFit.cover,
                height: double.infinity,
                width: double.infinity,
                alignment: Alignment.center,
              ),
              buildTopBarContainer(context, mq),
              BottomBarContainer(screen: "create", isUserLogin: true),
              Container(
                margin: const EdgeInsets.only(bottom: 80, top: 70),
                child: ListView(
                  shrinkWrap: false,
                  primary: true,
                  children: [
                    buildSubliminalListContainer(context, mq),
                    buildAddNewSubliminalButton(context),
                    buildCreateBarContainer(context, mq),
                    buildCreateButton(context),
                    buildConvertIntoVoiceContainer(
                        context,
                        'assets/images/ic_write_sub.png',
                        kSubliminalTitle,
                        kWriteSubliminalDes),
                    buildConvertIntoVoiceContainer(
                        context,
                        'assets/images/ic_convert.png',
                        kConvertIntoAudioTitle,
                        kConvertDes),
                    buildConvertIntoVoiceContainer(context,
                        'assets/images/ic_save.png', kSaveTitle, kSaveDes),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      //),
    );
  }

  Widget buildSubliminalListContainer(BuildContext context, Size mq) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              (subliminalList.isNotEmpty)
                  ? ListView.builder(
                      reverse: true,
                      shrinkWrap: true,
                      primary: false,
                      itemCount: 1,
                      itemBuilder: (BuildContext context, int index) {
                        return buildSubliminalContainer(
                          context,
                          kAddToCollectionText,
                          true,
                          subliminalList[index],
                        );
                      })
                  : const SizedBox(
                      child: Center(child: CircularProgressIndicator()))
            ],
          ),
        ),
      ],
    );
  }

  Widget buildSubliminalContainer(BuildContext context, String buttonName,
      bool isWish, dynamic subliminalList) {
    String? path;

    return Container(
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.only(left: 15, right: 15, top: 10),
      decoration: kAllCornerBoxDecoration,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 100,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: subliminalList['cover_path'] != ""
                        ? Image.network(
                            subliminalList['cover_path'],
                            fit: BoxFit.fill,
                          )
                        : Image.asset(
                            'assets/images/bg_logo_image.png',
                          ),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.only(
                            left: 15,
                            bottom: 10,
                          ),
                          alignment: Alignment.topLeft,
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              subliminalList['title'],
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontFamily: 'DPClear',
                                fontWeight: FontWeight.w600,
                              ),
                              softWrap: true,
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.only(
                            left: 15,
                            bottom: 10,
                          ),
                          alignment: Alignment.topLeft,
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              subliminalList['description'],
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontFamily: 'DPClear',
                                fontWeight: FontWeight.w400,
                              ),
                              softWrap: true,
                            ),
                          ),
                        ),
                      )
                    ]),
              ),
            ],
          ),
          Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  flex: 9,
                  child: buildListenButton(context, subliminalList),
                ),
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                      onTap: () async => {
                            showCenterLoader(context),
                            path = await getDownloadPath(),
                            downloadFile(
                              subliminalList['audio_path'],
                              subliminalList['title'] +
                                  DateTime.now()
                                      .millisecondsSinceEpoch
                                      .toString() +
                                  '.wav',
                              path!,
                            ),
                          },
                      child: Container(
                        height: 50,
                        decoration: kTransButtonBoxDecoration,
                        alignment: Alignment.topRight,
                        margin:
                            const EdgeInsets.only(left: 7, right: 2, top: 10),
                        child: Align(
                          alignment: Alignment.center,
                          child: Image.asset('assets/images/ic_download.png',
                              scale: 1.5),
                        ),
                      )),
                ),
              ]),
          Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 50,
                    decoration: kTransButtonBoxDecoration,
                    alignment: Alignment.topRight,
                    margin: const EdgeInsets.only(top: 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Align(
                          alignment: Alignment.center,
                          child: Image.asset('assets/images/ic_edit.png',
                              scale: 1.5),
                        ),
                        Container(
                          margin: const EdgeInsets.only(left: 10),
                          child: Text(
                            'Edit'.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontFamily: 'DPClear',
                              fontWeight: FontWeight.w600,
                            ),
                            softWrap: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    margin: const EdgeInsets.only(left: 5, top: 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Expanded(
                          flex: 1,
                          child: GestureDetector(
                            onTap: () => {
                              toast("Copied", false),
                              Clipboard.setData(ClipboardData(
                                  text: subliminalList['title'] +
                                      "\n" +
                                      subliminalList['description'] +
                                      "\n\n" +
                                      subliminalList['audio_path']))
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 3),
                              height: 50,
                              decoration: kTransButtonBoxDecoration,
                              alignment: Alignment.topRight,
                              child: Align(
                                alignment: Alignment.center,
                                child: Image.asset(
                                    'assets/images/ic_attachment.png',
                                    scale: 1.5),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: GestureDetector(
                            onTap: () => {
                              FlutterShareMe().shareToFacebook(
                                  url: subliminalList['audio_path'],
                                  msg: subliminalList['description'])
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 3),
                              height: 50,
                              decoration: kTransButtonBoxDecoration,
                              alignment: Alignment.topRight,
                              child: Align(
                                alignment: Alignment.center,
                                child: Image.asset('assets/images/ic_fb.png',
                                    scale: 1.5),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                            flex: 1,
                            child: GestureDetector(
                              onTap: () => {
                                FlutterShareMe().shareToTwitter(
                                    url: subliminalList['audio_path'],
                                    msg: subliminalList['description'])
                              },
                              child: Container(
                                margin: const EdgeInsets.only(right: 3),
                                height: 50,
                                decoration: kTransButtonBoxDecoration,
                                alignment: Alignment.topRight,
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Image.asset(
                                      'assets/images/ic_twitter.png',
                                      scale: 1.5),
                                ),
                              ),
                            ))
                      ],
                    ),
                  ),
                ),
              ])
        ],
      ),
    );
  }

  Widget buildListenButton(BuildContext context, dynamic subliminalList) {
    return ConstrainedBox(
        constraints: const BoxConstraints(minWidth: double.infinity),
        child: Container(
          margin: const EdgeInsets.only(top: 10),
          height: 50,
          child: ElevatedButton(
              onPressed: () async {
                print(subliminalList['audio_path']);
                await player.setUrl(subliminalList['audio_path']);
                await player.play();
              },
              style: ElevatedButton.styleFrom(
                primary: kButtonColor1,
                onPrimary: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15), // <-- Radius
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.only(right: 10),
                    child: Align(
                      alignment: Alignment.center,
                      child:
                          Image.asset('assets/images/ic_play.png', scale: 1.5),
                    ),
                  ),
                  Text('listen now'.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 15,
                        fontFamily: 'DPClear',
                        fontWeight: FontWeight.w600,
                      )),
                ],
              )),
        ));
  }

  Widget buildAddNewSubliminalButton(BuildContext context) {
    return ConstrainedBox(
        constraints: const BoxConstraints(minWidth: double.infinity),
        child: Container(
          margin: const EdgeInsets.only(top: 20, left: 15, right: 15),
          height: 50,
          child: ElevatedButton(
              onPressed: () {
                context.go(Routes.createSubliminal);
              },
              style: ElevatedButton.styleFrom(
                primary: kButtonColor1,
                onPrimary: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15), // <-- Radius
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('+  ',
                      style: TextStyle(
                        fontSize: 24,
                        fontFamily: 'DPClear',
                        fontWeight: FontWeight.w700,
                      )),
                  Text(kAddNewSubliminal.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: 'DPClear',
                        fontWeight: FontWeight.w600,
                      )),
                ],
              )),
        ));
  }

  Widget buildCreateButton(BuildContext context) {
    return ConstrainedBox(
        constraints: const BoxConstraints(minWidth: double.infinity),
        child: Container(
          margin: const EdgeInsets.only(top: 20, left: 15, right: 15),
          height: 50,
          child: ElevatedButton(
              onPressed: () {
                context.go(Routes.createSubliminal);
              },
              style: ElevatedButton.styleFrom(
                primary: kButtonColor1,
                onPrimary: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15), // <-- Radius
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text('+  ',
                      style: TextStyle(
                        fontSize: 24,
                        fontFamily: 'DPClear',
                        fontWeight: FontWeight.w700,
                      )),
                  Text(kCreateSubliminal,
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'DPClear',
                        fontWeight: FontWeight.w600,
                      )),
                ],
              )),
        ));
  }

  Widget buildConvertIntoVoiceContainer(
      BuildContext context, String image, String title, String description) {
    return Container(
      margin: const EdgeInsets.only(left: 15, right: 15, top: 20),
      decoration: kAllCornerBoxDecoration,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          GestureDetector(
            onTap: () => {
              Fluttertoast.showToast(
                  msg: "clicked",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.red,
                  textColor: Colors.blue,
                  fontSize: 16.0)
            },
            child: Container(
              padding: const EdgeInsets.only(
                  top: 15, left: 15, right: 15, bottom: 15),
              margin: const EdgeInsets.only(left: 15, right: 15),
              child: Align(
                alignment: Alignment.topLeft,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      alignment: Alignment.topLeft,
                      child: Image.asset(image, scale: 2.5),
                    ),
                    Flexible(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.only(
                                left: 15,
                                bottom: 10,
                              ),
                              alignment: Alignment.topLeft,
                              child: Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 22,
                                  color: Colors.white,
                                  fontFamily: 'DPClear',
                                  fontWeight: FontWeight.w600,
                                ),
                                softWrap: true,
                              ),
                            ),
                          ),
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.only(
                                left: 15,
                                bottom: 10,
                              ),
                              alignment: Alignment.topLeft,
                              child: Text(
                                description,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontFamily: 'DPClear',
                                  fontWeight: FontWeight.w400,
                                ),
                                softWrap: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
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
              'My Subliminal',
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

  Widget buildCreateBarContainer(BuildContext context, Size mq) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.only(left: 15, top: 10),
          child: const Align(
            alignment: Alignment.topLeft,
            child: Text(
              'Create',
              style: TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                  fontFamily: 'DPClear',
                  fontWeight: FontWeight.w600),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.only(left: 15, top: 10, right: 15),
          child: const Align(
            alignment: Alignment.topLeft,
            child: Text(
              'You can create your own Subliminal here in three steps',
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontFamily: 'DPClear',
                  fontWeight: FontWeight.w400),
            ),
          ),
        )
      ],
    );
  }

  Future<String> downloadFile(String url, String fileName, String dir) async {
    HttpClient httpClient = HttpClient();
    File file;
    String filePath = '';

    try {
      var request = await httpClient.getUrl(Uri.parse(url));
      var response = await request.close();
      if (response.statusCode == 200) {
        var bytes = await consolidateHttpClientResponseBytes(response);
        filePath = '$dir/$fileName';
        file = File(filePath);
        toast("File Downloaded in Download Directory", false);
        await file.writeAsBytes(bytes);
      } else {
        filePath = 'Error code: ${response.statusCode}';
        toast("File Not Downloaded", true);
      }
      Navigator.of(context, rootNavigator: true).pop();
    } catch (ex) {
      filePath = 'Can not fetch url';
    }

    return filePath;
  }

  Future<String?> getDownloadPath() async {
    Directory? directory;
    try {
      if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = Directory('/storage/emulated/0/Download');
        // Put file in global download folder, if for an unknown reason it didn't exist, we fallback
        // ignore: avoid_slow_async_io
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      }
      print(directory?.path);
    } catch (err, stack) {
      print("Cannot get download folder path");
    }
    return directory?.path;
  }
}
