import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:success_subliminal/pages/web_pages/discover_web_page.dart';

import '../data/api/ApiConstants.dart';
import '../data/api/ApiService.dart';
import '../utils/constant.dart';
import '../utils/shared_prefs.dart';
import '../widget/BottomBarStateFullWidget.dart';
import 'discover_subliminal_list_page.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({Key? key}) : super(key: key);

  @override
  _DiscoverPage createState() => _DiscoverPage();
}

class _DiscoverPage extends State<DiscoverPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool isLoading = false;
  bool isLogin = false;
  List<dynamic> categoriesList = [];
  late dynamic categories;

  @override
  void initState() {
    super.initState();
    _getCategoriesData();
    changeScreenName('discover');
    initializePreference().whenComplete(() {
      isLogin = SharedPrefs().isLogin();
      setState(() {});
    });
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
                if (kDebugMode) {
                  print("size ----${categoriesList.length}");
                }
              });
            }));
  }

  changeScreenName(String name) {
    setState(() {
      screenName = name;
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
            if (constraints.maxWidth < 757) {
              return buildHomeContainer(context, mq);
            } else {
              return const DiscoverWebPage();
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
            /* Image.asset(
              'assets/images/ic_bg_dark_blue.png',
              fit: BoxFit.cover,
              height: double.infinity,
              width: double.infinity,
              alignment: Alignment.center,
            ),*/
            buildTopBarContainer(context, mq),
            BottomBarStateFull(
              screen: "discover",
              isUserLogin: isLogin,
            ),
            Container(
              padding: const EdgeInsets.only(bottom: 70),
              margin: const EdgeInsets.only(top: 50),
              child: ListView(
                shrinkWrap: false,
                primary: true,
                children: [
                  categoriesList.isNotEmpty
                      ? buildCategoriesListContainer(context, mq)
                      : const SizedBox(
                          height: 500,
                          child: Center(child: CircularProgressIndicator())),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildCategoriesListContainer(BuildContext context, Size mq) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          margin: const EdgeInsets.only(left: 5, right: 5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              (categoriesList.isNotEmpty)
                  ? ListView.builder(
                      reverse: false,
                      shrinkWrap: true,
                      primary: false,
                      itemCount: categoriesList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return buildCategoryListItem(
                            context, categoriesList[index], index);
                      })
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
          ),
        ),
      ],
    );
  }

  Widget buildCategoryListItem(
      BuildContext context, dynamic category, int index) {
    return GestureDetector(
      onTap: () => {
        _navigateToDiscoverListScreen(
            context, category['name'], category['id'].toString())
      },
      child: Container(
        margin: const EdgeInsets.only(left: 15, right: 15, top: 10),
        padding: const EdgeInsets.all(10),
        decoration: kAllCornerBoxDecoration2,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: category['cover'] != ""
                      ? FittedBox(
                          child: FadeInImage.assetNetwork(
                          placeholder: 'assets/images/dummy_image.png',
                          image: ApiConstants.baseUrlAssets + category['cover'],
                          fit: BoxFit.fill,
                        ))
                      : Image.asset(
                          'assets/images/bg_logo_image.png',
                          fit: BoxFit.fill,
                        ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.only(left: 5, top: 10),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  category['name'],
                  style: const TextStyle(
                      fontSize: 18,
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

  Widget buildTopBarContainer(BuildContext context, Size mq) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        isLogin
            ? Container(
                padding: const EdgeInsets.only(left: 15, top: 10),
                child: const Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Discover',
                    style: TextStyle(
                        fontSize: 32,
                        color: Colors.white,
                        fontFamily: 'DPClear',
                        fontWeight: FontWeight.w500),
                  ),
                ),
              )
            : GestureDetector(
                onTap: () => {Navigator.pop(context)},
                child: Container(
                  padding: const EdgeInsets.only(left: 10),
                  height: mq.height * 0.09,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Image.asset('assets/images/ic_arrow_left.png',
                        scale: 1.5),
                  ),
                ),
              )
      ],
    );
  }

  void _navigateToDiscoverListScreen(
      BuildContext context, String name, String id) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (c, a1, a2) =>
            DiscoverCategoryListPage(categoryName: name, categoryId: id),
        transitionsBuilder: (c, anim, a2, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }
}
