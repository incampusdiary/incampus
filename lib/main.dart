import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:incampusdiary/activity_feed/upload.dart';
import 'package:incampusdiary/screens/home_screen.dart';
import 'package:incampusdiary/screens/login.dart';
import 'package:incampusdiary/screens/signup.dart';
import 'package:incampusdiary/vetometer/add_poll_astra.dart';
import 'package:incampusdiary/vetometer/vetometer_screen_astra.dart';
import 'package:incampusdiary/vetometer/live_polls_astra.dart';
import 'package:incampusdiary/vetometer/view_poll_astra.dart';
import 'package:incampusdiary/models/vetometer/poll_options_data.dart';
import 'models/vetometer/add_poll_model.dart';
import 'models/vetometer/edit_poll_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'activity_feed/news_feed.dart';
import 'activity_feed/profile.dart';
import 'models/news_feed/news_feed_data_model.dart';
import 'vetometer/edit_poll_astra.dart';
import 'vetometer/poll_stats_astra.dart';

Future<void> main() async {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarBrightness: Brightness.light,
  ));

  await dotenv.load(fileName: ".env");

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

var brightness = SchedulerBinding.instance.window.platformBrightness;
bool darkModeOn = brightness == Brightness.dark;

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => PollOptionsData()),
        ChangeNotifierProvider(create: (context) => EditPollModel()),
        ChangeNotifierProvider(create: (context) => AddPollModel()),
        ChangeNotifierProvider(create: (context) => NewsFeedData()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          textTheme: GoogleFonts.nunitoTextTheme(
            Theme.of(context).textTheme,
          ),
          scrollbarTheme: ScrollbarThemeData().copyWith(
            thumbColor: MaterialStateProperty.all(Colors.grey[600].withOpacity(0.85)),
          ),
        ),
        initialRoute: HomeScreen.id,
        routes: {
          HomeScreen.id: (context) => HomeScreen(),
          LoginScreen.id: (context) => LoginScreen(),
          SignUp.id: (context) => SignUp(),

          NewsFeed.id: (context) => NewsFeed(),
          Upload.id: (context) => Upload(),
          Profile.id: (context) => Profile(),

          VetometerScreen.id: (context) => VetometerScreen(),
          VetometerViewPoll.id: (context) => VetometerViewPoll(),
          VetometerLivePolls.id: (context) => VetometerLivePolls(),
          VetometerAddPoll.id: (context) => VetometerAddPoll(),
          VetometerEditPoll.id: (context) => VetometerEditPoll(),
          VetometerPollStats.id: (context) => VetometerPollStats(),
        },
      ),
    );
  }
}
