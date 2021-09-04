import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:incampusdiary/screens/home_screen.dart';
import 'package:incampusdiary/screens/login.dart';
import 'package:incampusdiary/screens/signup.dart';
import 'package:incampusdiary/vetometer/add_poll_astra.dart';
import 'package:incampusdiary/vetometer/vetometer_screen_astra.dart';
import 'package:incampusdiary/vetometer/live_polls_astra.dart';
import 'package:incampusdiary/vetometer/view_poll_astra.dart';
import 'package:incampusdiary/models/vetometer/poll_options_data.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'models/vetometer/add_poll_model.dart';
import 'models/vetometer/edit_poll_model.dart';
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

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => PollOptionsData()),
        ChangeNotifierProvider(create: (context) => EditPollModel()),
        ChangeNotifierProvider(create: (context) => AddPollModel()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          textTheme: GoogleFonts.nunitoTextTheme(
            Theme.of(context).textTheme,
          ),
        ),
        initialRoute: HomeScreen.id,
        routes: {
          HomeScreen.id: (context) => HomeScreen(),
          LoginScreen.id: (context) => LoginScreen(),
          SignUp.id: (context) => SignUp(),
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
