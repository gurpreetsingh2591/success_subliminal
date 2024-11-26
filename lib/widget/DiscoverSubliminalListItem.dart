import 'package:flutter/material.dart';

import '../pages/discover_subliminal_detail_page.dart';
import '../utils/constant.dart';

class DiscoverSubliminalItemContainer extends StatelessWidget {
  final BuildContext context;
  final String buttonName;
  final bool isWish;
  final dynamic subliminalList;

  const DiscoverSubliminalItemContainer({
    Key? key,
    required this.context,
    required this.buttonName,
    required this.isWish,
    required this.subliminalList,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context = this.context;
    return GestureDetector(
      onTap: () => {
        //toast("click", false)
        _navigateToSubDetailScreen(
            context, subliminalList['title'], subliminalList['id'].toString())
      },
      child: Container(
        padding: const EdgeInsets.all(15),
        margin: const EdgeInsets.only(left: 10, right: 10, top: 10),
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
                subliminalList['cover_path'] != ""
                    ? SizedBox(
                        width: 100,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15.0),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Image.network(
                              subliminalList['cover_path'],
                              fit: BoxFit.fill,
                            ),
                          ),
                        ))
                    : SizedBox(
                        width: 100,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15.0),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Image.asset(
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
                    flex: 4,
                    child: Container(
                      height: 50,
                      alignment: Alignment.topRight,
                      margin: const EdgeInsets.only(right: 2, top: 10),
                      child: Align(
                        alignment: Alignment.center,
                        child: Text('\$40'.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 15,
                              fontFamily: 'DPClear',
                              fontWeight: FontWeight.w600,
                            )),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 7,
                    child: buildBuyNowButton(context),
                  ),
                ]),
          ],
        ),
      ),
    );
  }

  Widget buildBuyNowButton(BuildContext context) {
    return ConstrainedBox(
        constraints: const BoxConstraints(minWidth: double.infinity),
        child: Container(
          margin: const EdgeInsets.only(top: 10, left: 10),
          height: 50,
          child: ElevatedButton(
            onPressed: () async {},
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
                    child: Image.asset('assets/images/ic_bag_tick.png',
                        scale: 1.5),
                  ),
                ),
                Text('buy now'.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 15,
                      fontFamily: 'DPClear',
                      fontWeight: FontWeight.w600,
                    )),
              ],
            ),
          ),
        ));
  }

  void _navigateToSubDetailScreen(
      BuildContext context, String name, String id) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (c, a1, a2) =>
            DiscoverSubliminalDetailPage(subName: name, subId: id),
        transitionsBuilder: (c, anim, a2, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }
}
