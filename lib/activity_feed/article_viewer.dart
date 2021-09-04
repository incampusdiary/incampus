import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:incampusdiary/activity_feed/profile.dart';
import 'package:incampusdiary/constants.dart';
import 'package:incampusdiary/models/news_feed/post_model.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

import '../main.dart';
import 'article_editor.dart';
import 'comments.dart';
import 'news_feed.dart';

class ArticleViewer extends StatefulWidget {
  static final id = 'article-viewer';
  final PostModel postFile;

  const ArticleViewer({@required this.postFile});

  @override
  _ArticleViewerState createState() => _ArticleViewerState();
}

class _ArticleViewerState extends State<ArticleViewer> {

  ScrollController scrollController;
  bool isMoveUpIconVisible = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    scrollController = ScrollController();
    scrollController.addListener(_scrollListener);
  }

  bool isCommentsVisible = false;
  Future<void> _scrollListener() async {
    if (isCommentsVisible) return;
    var offset = scrollController.offset;
    var maxScrollExtent = scrollController.position.maxScrollExtent + 50;
    print('$maxScrollExtent   isCommentsVisible: $isCommentsVisible   $offset');
    if (offset >= maxScrollExtent) {
      showToast(message: 'Swipe Up for Comments!');
      if (offset >= maxScrollExtent + 50) {
        isCommentsVisible = true;
        await showModalBottomSheet(
            isScrollControlled: true,
            isDismissible: true,
            barrierColor: Colors.transparent,
            backgroundColor: Colors.transparent,
            enableDrag: true,
            elevation: 20,
            context: context,
            builder: (context) => Comments());
        isCommentsVisible = false;
      }
    } else if (scrollController.offset > 150) {
      setState(() {
        isMoveUpIconVisible = true;
      });
    } else
      setState(() {
        isMoveUpIconVisible = false;
      });
  }

  @override
  Widget build(BuildContext context) {
    print('Article Viewer Called');

    final Color white = Colors.white;
    final Color black = darkModeOn ? white : Colors.black;
    final Color blue = Color(0xFF096EFA);

    final currentUser = FirebaseAuth.instance.currentUser;
    final width = MediaQuery.of(context).size.width;

    /// Settings for the page transition when moveUp or moveDown icons are clicked.
    final animationDuration = Duration(seconds: 1);

    /// Settings for the page transition when moveUp or moveDown icons are clicked.
    final animationCurve = Curves.fastOutSlowIn;

    return Material(
      color: darkModeOn ? Color(0xFF141820) : Colors.green[50],
      child: Stack(
        children: [
          Column(
            children: [
              SizedBox(height: 40),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18.0, vertical: 18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Wrap(
                        direction: Axis.horizontal,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Container(
                            height: 35,
                            width: 90,
                            color: blue,
                            child: Center(
                              child: Text(
                                'Article',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: white,
                                  fontFamily: "Nunito",
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 20),
                          SvgPicture.asset('images/calendar.svg',
                              height: 25, width: 25),
                          SizedBox(width: 10),
                          Text(
                            postDateTime(),
                            style: TextStyle(
                              fontSize: 16,
                              color: black.withOpacity(0.7),
                              fontFamily: "Nunito",
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),

                    /// TODO: Add a Condition & move this to postDescription screen
                    (currentUser.uid == widget.postFile.userId)
                        ? InkWell(
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      ArticleEditor(
                                    isEditing: true,
                                  ),
                                ),
                              );
                              setState(() {});
                            },
                            child: Image.asset(
                              'images/edit_icon.png',
                              height: 45.0,
                              width: 45.0,
                            ),
                          )
                        : Container(),

                    /// Dark Mode
                    // IconButton(
                    //   tooltip: 'DarkMode',
                    //   icon: Icon(
                    //     darkMode ? darkModeIcon : lightModeIcon,
                    //     color: darkMode ? white : blue,
                    //     size: 30,
                    //   ),
                    //   onPressed: () {
                    //     setState(() {
                    //       darkMode = !darkMode;
                    //     });
                    //   },
                    // ),
                  ],
                ),
              ),

              /// Main Body (Article Viewer)
              Expanded(
                child: Scrollbar(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    physics: BouncingScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    child: Container(
                      child: Padding(
                        padding:
                            const EdgeInsets.fromLTRB(18.0, 16.0, 18.0, 48.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.postFile.title,
                                    style: TextStyle(
                                      fontSize: 40,
                                      color: black,
                                      fontFamily: "Nunito",
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  SizedBox(height: 25),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12),
                                    child: Row(
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (BuildContext context) =>
                                                        Profile(
                                                            userId:
                                                                post.userId),
                                              ),
                                            );
                                          },
                                          child: CircleAvatar(
                                            backgroundImage: NetworkImage(
                                                currentUser.photoURL),
                                            radius: 25,
                                          ),
                                        ),
                                        SizedBox(width: 15),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                currentUser.displayName,
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  color: black,
                                                  fontFamily: "Nunito",
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Text(
                                                'CSE, Heritage Institute of Technology',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: black.withOpacity(0.8),
                                                  fontFamily: "Nunito",
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 15),
                            Stack(
                              children: [
                                Center(
                                  child: Container(
                                    margin: EdgeInsets.symmetric(vertical: 2),
                                    color: black.withOpacity(0.85),
                                    width: width * 0.8,
                                    height: 1,
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.center,
                                  child: Center(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: blue,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      width: width * 0.3,
                                      height: 5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 25),
                            Markdown(
                              shrinkWrap: true,
                              selectable: true,
                              physics: NeverScrollableScrollPhysics(),
                              data: widget.postFile.description,
                              onTapLink: (text, url, title) {
                                print(url);
                                _launchURL(url);
                              },
                              styleSheet: MarkdownStyleSheet(
                                h1: TextStyle(
                                  fontFamily: "Nunito",
                                  fontSize: 30,
                                  fontWeight: FontWeight.w700,
                                  color: darkModeOn ? blue : Colors.indigo,
                                ),
                                h2: TextStyle(
                                  fontFamily: "Nunito",
                                  fontSize: 27,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green,
                                ),
                                h3: TextStyle(
                                  fontFamily: "Nunito",
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                  color: black,
                                ),
                                em: TextStyle(
                                  fontStyle: FontStyle.italic,
                                ),
                                p: TextStyle(
                                  fontFamily: "Nunito",
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400,
                                  color: black,
                                ),
                                strong: TextStyle(
                                  fontFamily: "Nunito",
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: black,
                                ),
                                code: TextStyle(
                                  fontSize: 15,
                                  backgroundColor: Colors.transparent,
                                ),
                                codeblockPadding: EdgeInsets.all(16),
                                blockquoteDecoration: BoxDecoration(
                                  color: Colors.transparent,
                                ),
                                blockquotePadding:
                                    EdgeInsets.symmetric(vertical: 20),
                                codeblockDecoration: BoxDecoration(
                                  color: Colors.grey[100],
                                ),
                                codeblockAlign: WrapAlignment.start,
                                listBullet: TextStyle(fontFamily: "Nunito"),
                                tableHead: TextStyle(fontFamily: "Nunito"),
                                tableBody: TextStyle(fontFamily: "Nunito"),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            right: 20,
            top: 125,
            bottom: 100,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Visibility(
                  visible: isMoveUpIconVisible,
                  child: InkWell(
                    onTap: () {
                      scrollController.animateTo(
                        scrollController.position.minScrollExtent - 50,
                        duration: animationDuration,
                        curve: animationCurve,
                      );
                    },
                    child: Container(
                      child: Icon(Icons.arrow_circle_up_sharp,
                          size: 25, color: Colors.green),
                      padding: EdgeInsets.all(5),
                      color: Colors.black54,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    scrollController.animateTo(
                      scrollController.position.maxScrollExtent + 50,
                      duration: animationDuration,
                      curve: animationCurve,
                    );
                  },
                  child: Container(
                    child: Icon(Icons.arrow_circle_down_sharp,
                        size: 25, color: Colors.green),
                    padding: EdgeInsets.all(5),
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  postDateTime() {
    var day = widget.postFile.timestamp.toDate().day;
    var month = widget.postFile.timestamp.toDate().month;
    var year = widget.postFile.timestamp.toDate().year;

    var monthName = monthList[month];
    String date = '$monthName $day, $year';

    return date;
  }

  void _launchURL(url) async =>
      await canLaunch(url) ? await launch(url) : throw 'Could not launch $url';
}

List monthList = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
