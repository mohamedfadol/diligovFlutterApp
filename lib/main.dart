import 'package:diligov/core/firebase_messageing_service.dart';
import 'package:diligov/firebase_options.dart';
import 'package:diligov/l10n/l10n.dart';
import 'package:diligov/providers/annual_reports_provider_page.dart';
import 'package:diligov/providers/disclosure_page_provider.dart';
import 'package:diligov/providers/financial_page_provider.dart';
import 'package:diligov/providers/actions_tracker_page_provider.dart';
import 'package:diligov/providers/annual_audit_report_provider.dart';
import 'package:diligov/providers/authentications/auth_provider.dart';
import 'package:diligov/providers/authentications/user_provider.dart';
import 'package:diligov/providers/committee_provider.dart';
import 'package:diligov/providers/evaluation_page_provider.dart';
import 'package:diligov/providers/global_search_provider.dart';
import 'package:diligov/providers/icons_provider.dart';
import 'package:diligov/providers/light_dark_mode_provider.dart';
import 'package:diligov/providers/localizations_provider.dart';
import 'package:diligov/providers/meeting_page_provider.dart';
import 'package:diligov/providers/menus_provider.dart';
import 'package:diligov/providers/minutes_provider_page.dart';
import 'package:diligov/providers/navigation_model_provider.dart';
import 'package:diligov/providers/navigator_provider.dart';
import 'package:diligov/providers/member_page_provider.dart';
import 'package:diligov/providers/board_page_provider.dart';
import 'package:diligov/providers/note_page_provider.dart';
import 'package:diligov/providers/notification_page_provider.dart';
import 'package:diligov/providers/resolutions_page_provider.dart';
import 'package:diligov/providers/theme_provider.dart';
import 'package:diligov/utility/laboratory_file_processing.dart';
import 'package:diligov/utility/signature_view.dart';
import 'package:diligov/views/boards_views/quick_access_board_list_view.dart';
import 'package:diligov/views/calenders/calendar_page.dart';
import 'package:diligov/views/committee_views/calenders/committee_calendar_page.dart';
import 'package:diligov/views/committee_views/committee_resolutions_views/committee_resolutions_list_views.dart';
import 'package:diligov/views/committee_views/quick_access_committee_list_view.dart';
import 'package:diligov/views/dashboard/dashboard_home_screen.dart';
import 'package:diligov/views/auth/login_screen.dart';
import 'package:diligov/views/dashboard/setting.dart';
import 'package:diligov/views/modules/actions_tracker_view/actions_tracker_list.dart';
import 'package:diligov/views/modules/annual_audit_report/annual_audit_report_list.dart';
import 'package:diligov/views/modules/annual_report_views/annual_report_list_view.dart';
import 'package:diligov/views/modules/board_views/tab_bar_list_view.dart';
import 'package:diligov/views/modules/disclosures_views/disclosures_list_view.dart';
import 'package:diligov/views/modules/evaluation_views/board_effectiveness.dart';
import 'package:diligov/views/modules/evaluation_views/evaluation_list_views.dart';
import 'package:diligov/views/modules/evaluation_views/member_peer_assessment.dart';
import 'package:diligov/views/modules/financials_views/financial_list_views.dart';
import 'package:diligov/views/modules/minutes_meeting_views/minutes_meeting_list.dart';
import 'package:diligov/views/modules/note_views/note_list_views.dart';
import 'package:diligov/views/modules/reports_views/reports_list_views.dart';
import 'package:diligov/views/modules/evaluation_views/evaluation_home.dart';
import 'package:diligov/views/modules/resolutions_views/resolutions_list_views.dart';
import 'package:diligov/views/tab_bar_view/members_view/members_list.dart';
import 'package:diligov/views/tab_bar_view/members_view/insert_new_member.dart';
import 'package:diligov/views/tab_bar_view/members_view/quick_access_member_list_view.dart';
import 'package:diligov/views/user/edit_profile.dart';
import 'package:diligov/views/user/profile.dart';
import 'package:diligov/views/boards_views/boards_list_views.dart';
import 'package:diligov/views/committee_views/committee_list.dart';
import 'package:diligov/views/tab_bar_view/member_and_committees.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'models/user.dart';
import 'utility/shared_preference.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import 'package:syncfusion_flutter_core/core.dart';
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async{
  await Firebase.initializeApp();
  if (kDebugMode) {
    print('firebase Messaging Background Handler is ${message.messageId}');
  }
}

void main() async{
  SyncfusionLicense.registerLicense("YOUR LICENSE KEY");
  WidgetsFlutterBinding.ensureInitialized();
  await initLocalNotification();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);
    FirebaseMessagingService().initialize();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]).then((value) {
    runApp(
        MultiProvider
          (
          providers: [
          ChangeNotifierProvider<IconsProvider>(create:(_) => IconsProvider()),
          ChangeNotifierProvider<MenusProvider>(create:(_) => MenusProvider()),
          ChangeNotifierProvider<LightDarkMode>(create:(_) => LightDarkMode()),
          ChangeNotifierProvider<AuthProvider>(create:(_) => AuthProvider()),
          ChangeNotifierProvider<UserProfilePageProvider>(create:(_) => UserProfilePageProvider()),
          ChangeNotifierProvider<NavigatorProvider>(create:(_) => NavigatorProvider()),
          ChangeNotifierProvider<MemberPageProvider>(create:(_) => MemberPageProvider()),
          ChangeNotifierProvider<BoardPageProvider>(create:(_) => BoardPageProvider()),
          ChangeNotifierProvider<ThemeProvider>(create:(_) => ThemeProvider()),
          ChangeNotifierProvider<CommitteeProvider>(create:(_) => CommitteeProvider()),
          ChangeNotifierProvider<MeetingPageProvider>(create:(_) => MeetingPageProvider()),
          ChangeNotifierProvider<EvaluationPageProvider>(create:(_) => EvaluationPageProvider()),
          ChangeNotifierProvider<AnnualAuditReportProvider>(create: (_) => AnnualAuditReportProvider()),
          ChangeNotifierProvider<MinutesProviderPage>(create: (_) => MinutesProviderPage()),
          ChangeNotifierProvider<ResolutionsPageProvider>(create:(_) => ResolutionsPageProvider()),
          ChangeNotifierProvider<LocalizationsProvider>(create:(_) => LocalizationsProvider()),
          ChangeNotifierProvider<ActionsTrackerPageProvider>(create:(_) => ActionsTrackerPageProvider()),
          ChangeNotifierProvider<FinancialPageProvider>(create:(_) => FinancialPageProvider()),
          ChangeNotifierProvider<AnnualReportsProviderPage>(create:(_) => AnnualReportsProviderPage()),
          ChangeNotifierProvider<DisclosurePageProvider>(create:(_) => DisclosurePageProvider()),
            ChangeNotifierProvider<NotePageProvider>(create:(_) => NotePageProvider()),
            ChangeNotifierProvider<NavigationModelProvider>(create:(_) => NavigationModelProvider()),
            ChangeNotifierProvider<NotificationPageProvider>(create:(_) => NotificationPageProvider()),
            ChangeNotifierProvider<GlobalSearchProvider>(create:(_) => GlobalSearchProvider()),
        ],
          child: MyApp(),
        )
    );
  });
}

Future<void> initLocalNotification()async{
  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid,);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}


class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp>  with WidgetsBindingObserver{

  void requestPermissions() async{
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(alert: true,announcement: false,badge: true,carPlay: false,criticalAlert: false,provisional: false,sound: true,);
    if(settings.authorizationStatus == AuthorizationStatus.authorized){
      print('user granted permission');
    } else {
      print('User declined or has not yet granted permission');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    requestPermissions();
    WidgetsBinding.instance?.addObserver(this);

    // Set up method channel to receive termination events
    const platform = MethodChannel('app_lifecycle');
    platform.setMethodCallHandler((call) async {
      if (call.method == 'onTerminate') {
        // Handle termination event
        print('App is being terminated');
        // Perform actions, such as removing tokens, when the app is being terminated
      }
    });

  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }


  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
      // App is in the foreground
        print('App is in the foreground');
        break;
      case AppLifecycleState.inactive:
      // App is in an inactive state (possibly transitioning between foreground and background)
        break;
      case AppLifecycleState.paused:
      // App is in the background
        print('App is in the background');
        break;
      case AppLifecycleState.detached:
      // App is detached (not running)
        print('App is inactive remove token');
        UserPreferences().removeUser();
        print('App is detached');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (BuildContext context) {
      final themeProvider = Provider.of<ThemeProvider>(context);
      final localeLanguage = Provider.of<LocalizationsProvider>(context);
      // Ideally, fetch notifications when the app is initialized or at a suitable place
      context.read<NotificationPageProvider>().fetchNotifications();
      Future<UserModel> getUserData () => UserPreferences().getUser();
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          statusBarColor: Theme.of(context).scaffoldBackgroundColor,
        statusBarIconBrightness: Brightness.dark ,
      ));

      return MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: L10n.all,
        locale: localeLanguage.locale,
        debugShowCheckedModeBanner: false,
        themeMode: themeProvider.themeMode,
        theme: MyThemes.lightTheme,
        darkTheme: MyThemes.darkTheme,
        home: FutureBuilder(
            future: getUserData(),
            builder: (context,AsyncSnapshot<UserModel> snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                  return LoginScreen();
                case ConnectionState.waiting:
                  return const CircularProgressIndicator();
                default:
                  if (snapshot.hasError) {
                    print(snapshot.error);
                    return LoginScreen();
                  } else if (snapshot.data?.token == null) {
                    return LoginScreen();
                    //   return LaboratoryFileProcessing(path: 'https://diligov.com/public/charters/1/logtah.pdf',);
                  } else {
                    Provider.of<UserProfilePageProvider>(context).setUser(snapshot.data!.user);
                  }
                  return const DashboardHomeScreen();
                  // return LaboratoryFileProcessing(path: 'https://diligov.com/public/charters/1/logtah.pdf',); //DashboardHomeScreen();

              }
            }),
        routes: {
          LoginScreen.routeName : (context) => LoginScreen(),
          // '/homePage': (context) => const Homepage(),
          '/dashboardHome': (context) => const DashboardHomeScreen(),
          ProfileUser.routeName: (context) => const ProfileUser(),
          EditProfile.routeName: (context) => const EditProfile(),
          Setting.routeName: (context) => const Setting(),
          MembersList.routeName: (context) => const MembersList(),
          InsertNewMember.routeName: (context) => const InsertNewMember(),
          MemberAndCommittees.routeName: (context) => const MemberAndCommittees(),
          BoardsListViews.routeName: (context) => const BoardsListViews(),
          CommitteeList.routeName: (context) => const CommitteeList(),
          SignatureView.routeName: (context) => const SignatureView(),
          CalendarPage.routeName: (context) => const CalendarPage(),
          CommitteeCalendarPage.routeName: (context) => const CommitteeCalendarPage(),
          BoardListView.routeName: (context) => const BoardListView(),
          ReportsListViews.routeName: (context) => const ReportsListViews(),
          ResolutionsListViews.routeName: (context) => const ResolutionsListViews(),
          EvaluationHome.routeName: (context) => const EvaluationHome(),
          MemberPeerAssessment.routeName: (context) => const MemberPeerAssessment(),
          BoardEffectiveness.routeName: (context) => const BoardEffectiveness(),
          EvaluationListViews.routeName: (context) => const EvaluationListViews(),
          AnnualAuditReport.routeName: (context) => const AnnualAuditReport(),
          MinutesMeetingList.routeName: (context) => const MinutesMeetingList(),
          QuickAccessBoardListView.routeName: (context) => const QuickAccessBoardListView(),
          QuickAccessMemberListView.routeName: (context) => const QuickAccessMemberListView(),
          QuickAccessCommitteeListView.routeName: (context) => const QuickAccessCommitteeListView(),
          ActionsTrackerList.routeName: (context) =>  ActionsTrackerList(),
          FinancialListViews.routeName: (context) =>  FinancialListViews(),
          AnnualReportListView.routeName: (context) =>  AnnualReportListView(),
          DisclosureListViews.routeName: (context) =>  DisclosureListViews(),
          CommitteeResolutionsListViews.routeName: (context) =>  CommitteeResolutionsListViews(),
          NoteListViews.routeName: (context) =>  NoteListViews(),
          NoteListViews.routeName: (context) =>  NoteListViews(),

        },
      );
    });
  }
}

