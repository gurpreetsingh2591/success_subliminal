import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:success_subliminal/pages/discover_page.dart';
import 'package:success_subliminal/pages/web_pages/discover_subliminal_list_web_page.dart';

import '../../app/router.dart';
import '../../data/api/ApiConstants.dart';
import '../../data/api/ApiService.dart';
import '../../utils/constant.dart';
import '../../utils/shared_prefs.dart';
import '../../widget/WebFooterWithoutLinkWidget.dart';
import '../../widget/WebTopBarContainer.dart';

class DiscoverWebPage extends StatefulWidget {
  const DiscoverWebPage({Key? key}) : super(key: key);

  @override
  _DiscoverwebScreen createState() => _DiscoverwebScreen();
}

class _DiscoverwebScreen extends State<DiscoverWebPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  String loginText = "";
  String loginText1 = "";
  bool isLoading = false;
  bool isLogin = false;
  List<dynamic> categoriesList = [];
  late dynamic categories;
  String tapBar = "discover";

  double leftPadding = 200;
  double rightPadding = 200;
  double topPadding = 100;
  double titleSize = 20;

  @override
  void initState() {
    super.initState();

    initializePreference().whenComplete(() {
      setState(() {
        isLogin = SharedPrefs().isLogin();

        setState(() {
          if (!isLogin) {
            context.pushReplacement(Routes.home);
          }
        });
      });
    });
    _getCategoriesData();
  }

  void _getCategoriesData() async {
    categories = await ApiService().getCategories(context);

    Future.delayed(const Duration(seconds: 1))
        .then((value) => setState(() async {
              setState(() {
                if (categories['http_code'] != 200) {
                } else {
                  categoriesList.addAll(categories['data']['categories']);
                }
                print("size ----${categoriesList.length}");
              });
            }));
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
            if (constraints.maxWidth > 757) {
              if (constraints.maxWidth < 900) {
                titleTextSize = 50;
                loginTopPadding = 100;
                leftPadding = 50;
                rightPadding = 50;
              } else if (constraints.maxWidth < 1100) {
                titleTextSize = 55;
                loginTopPadding = 105;
                leftPadding = 50;
                rightPadding = 50;
              } else if (constraints.maxWidth < 1300) {
                titleTextSize = 60;
                loginTopPadding = 110;
                leftPadding = 100;
                rightPadding = 100;
              } else if (constraints.maxWidth < 1600) {
                titleTextSize = 65;
                loginTopPadding = 115;
                leftPadding = 150;
                rightPadding = 150;
              } else if (constraints.maxWidth < 2000) {
                titleTextSize = 70;
                loginTopPadding = 120;
                leftPadding = 200;
                rightPadding = 200;
              }
              return buildHomeContainer(context, mq);
            } else {
              return const DiscoverPage();
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
            const WebTopBarContainer(screen: 'discover'),
            Positioned(
                bottom: 0,
                child: SizedBox(
                    height: 80,
                    width: mq.width * 1,
                    child: const WebFooterWithoutLinkWidget())),
            Container(
                alignment: Alignment.topCenter,
                margin: EdgeInsets.only(
                    left: leftPadding,
                    right: rightPadding,
                    top: loginTopPadding,
                    bottom: 100),
                child: ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context)
                      .copyWith(scrollbars: false),
                  child: ListView(
                    shrinkWrap: false,
                    primary: false,
                    children: <Widget>[
                      buildDiscoverTextContainer(context, mq),
                      categoriesList.isNotEmpty
                          ? buildCateGoryListContainer(context, mq)
                          : const SizedBox(
                              height: 500,
                              child:
                                  Center(child: CircularProgressIndicator())),
                    ],
                  ),
                ))
          ])),
    );
  }

  Widget buildCateGoryListContainer(BuildContext context, Size mq) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            if (constraints.maxWidth < 900) {
              titleSize = 18;
              return buildCategoriesListTabContainer(context, mq);
            } else if (constraints.maxWidth < 1500) {
              titleSize = 20;
              return buildCategoriesListWebContainer(context, mq);
            } else {
              titleSize = 24;
              return buildCategoriesListWeb2000Container(context, mq);
            }
          },
        )
      ],
    );
  }

  Widget buildCategoriesListWeb2000Container(BuildContext context, Size mq) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        (categoriesList.isNotEmpty)
            ? GridView.builder(
                reverse: false,
                shrinkWrap: true,
                primary: false,
                itemCount: categoriesList.length,
                itemBuilder: (BuildContext context, int index) {
                  return buildCategoryListItem(
                      context, categoriesList[index], index);
                },
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 2 / 1.4,
                ),
              )
            : const Align(
                alignment: Alignment.center,
                child: Text(
                  "No Categories",
                  style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontFamily: 'DPClear',
                      fontWeight: FontWeight.w600),
                ),
              ),
      ],
    );
  }

  Widget buildCategoriesListWebContainer(BuildContext context, Size mq) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        (categoriesList.isNotEmpty)
            ? GridView.builder(
                reverse: false,
                shrinkWrap: true,
                primary: false,
                itemCount: categoriesList.length,
                itemBuilder: (BuildContext context, int index) {
                  return buildCategoryListItem(
                      context, categoriesList[index], index);
                },
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 2 / 1.40,
                ),
              )
            : const Align(
                alignment: Alignment.center,
                child: Text(
                  "No Categories",
                  style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontFamily: 'DPClear',
                      fontWeight: FontWeight.w600),
                ),
              ),
      ],
    );
  }

  Widget buildCategoriesListTabContainer(BuildContext context, Size mq) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        (categoriesList.isNotEmpty)
            ? GridView.builder(
                reverse: false,
                shrinkWrap: true,
                primary: false,
                itemCount: categoriesList.length,
                itemBuilder: (BuildContext context, int index) {
                  return buildCategoryListItem(
                      context, categoriesList[index], index);
                },
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 2 / 1.45,
                ),
              )
            : const Align(
                alignment: Alignment.center,
                child: Text(
                  "No Categories",
                  style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontFamily: 'DPClear',
                      fontWeight: FontWeight.w600),
                ),
              ),
      ],
    );
  }

  Widget buildCategoryListItem(
      BuildContext context, dynamic category, int index) {
    return GestureDetector(
      onTap: () => {
        context.pushNamed('discover-subliminals', queryParameters: {
          'categoryName': category['name'],
          'categoryId': category['id'].toString(),
          'subname': "",
        })

        /* _navigateToDiscoverListScreen(
            context, category['name'], category['id'].toString())*/
      },
      child: Container(
        margin: const EdgeInsets.only(left: 10, right: 10, top: 20),
        padding: const EdgeInsets.all(10),
        decoration: kEditTextDecoration,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Align(
                    alignment: Alignment.topCenter,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: category['cover'] != ""
                          ? FadeInImage.assetNetwork(
                              placeholder: 'assets/images/dummy_image.png',
                              image: ApiConstants.baseUrlAssets +
                                  category['cover'],
                            )
                          : Image.asset(
                              'assets/images/bg_logo_image.png',
                              fit: BoxFit.fill,
                            ),
                    )),
              ),
            ),
            Container(
              padding: const EdgeInsets.only(left: 5, top: 10),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  category['name'],
                  style: TextStyle(
                      fontSize: titleSize,
                      color: Colors.white,
                      fontFamily: 'DPClear',
                      fontWeight: FontWeight.w500),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildDiscoverTextContainer(BuildContext context, Size mq) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
            margin: EdgeInsets.only(left: 20),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                'Discover',
                style: TextStyle(
                    fontSize: titleTextSize,
                    color: Colors.white,
                    fontFamily: 'DPClear',
                    fontWeight: FontWeight.w500),
              ),
            ))
      ],
    );
  }

  void _navigateToDiscoverListScreen(
      BuildContext context, String name, String id) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (c, a1, a2) => DiscoverCategoryWebListPage(
          categoryName: name,
          categoryId: id,
          subname: '',
        ),
        transitionsBuilder: (c, anim, a2, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }
}
