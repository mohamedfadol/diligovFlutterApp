// import 'package:diligov/files_functions/files_page.dart';
// import 'package:diligov/profile/user_profile.dart';
// import 'package:diligov/providers/icons_provider.dart';
// import 'package:diligov/providers/light_dark_mode_provider.dart';
// import 'package:diligov/providers/menus_provider.dart';
// import 'package:diligov/widgets/circularFabWidget.dart';
// import 'package:flutter/material.dart';
//
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
//
// import 'colors.dart';
//
// class Homepage extends StatefulWidget {
//   const Homepage({Key? key}) : super(key: key);
//
//   @override
//   State<Homepage> createState() => _HomepageState();
// }
//
// class _HomepageState extends State<Homepage> {
//   String? cityName = "Loading...";
//   bool menuPressed = false;
//
//   Future<String?> getUserLocation() async {
//     Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.medium);
//
//     List<Placemark> placemarks = await placemarkFromCoordinates(
//       position.latitude,
//       position.longitude,
//     );
//
//     return placemarks.first.locality;
//   }
//
//   void updateUserCity() async {
//     cityName = await getUserLocation();
//     setState(() {
//       cityName;
//     });
//   }
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     updateUserCity();
//     super.initState();
//   }
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     double width = MediaQuery.of(context).size.width;
//     double height = MediaQuery.of(context).size.height;
//
//     String iconPath = context.watch<IconsProvider>().getIconPath;
//     String iconName = context.watch<MenusProvider>().getIconName;
//
//
//     bool darkModeEnabled = context.watch<LightDarkMode>().darkModeIsEnabled;
//
//     return Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
//         child: Scaffold(
//             backgroundColor: darkModeEnabled ? Colour().darkBackgroundColor : Colour().lightbackgroundColor,
//             body: OrientationBuilder(builder: (context, orientation) {
//               return GestureDetector(
//                 child: Stack(
//
//                   children: [
//                     Padding(
//                       padding: EdgeInsets.only(
//                           left: width / 3, top: height / 14, right: width / 3),
//                       child: Container(
//                         height: 400,
//                         width: 400,
//                         decoration: BoxDecoration(
//                             color: Colors.white.withOpacity(0.001),
//                             borderRadius: BorderRadius.circular(360),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.white.withOpacity(0.01),
//                                 blurRadius: 100.0,
//                                 spreadRadius: 100.0,
//                                 offset: Offset(0, 1),
//                                 // shadow direction: bottom right
//                               ),
//                             ]),
//                       ),
//                     ),
//
//                     Container(
//                       child: Padding(
//                         padding:
//                             EdgeInsets.symmetric(horizontal: 8, vertical: 18),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Row(children: [
//                               Container(
//                                 width: 30,
//                                 height: 30,
//                                 child: InkWell(
//                                   onTap: (){
//                                     Navigator.pushNamed(context, '/dashboardHome');
//                                   },
//                                   child: SvgPicture.asset(
//                                     "icons/world-wide-web-svgrepo.svg",
//                                     color: Colour().iconsColor,
//                                   ),
//                                 ),
//                               ),
//                               Padding(
//                                 padding: EdgeInsets.symmetric(horizontal: 18),
//                                 child: Container(
//                                   height: 36,
//                                   width: 300,
//                                   decoration: BoxDecoration(
//                                       // color: darkModeEnabled? Colors.grey.shade700:Colors.white,
//                                       borderRadius:
//                                           BorderRadius.all(Radius.circular(8))),
//                                   child: TextField(
//                                     onChanged: (searchText) {},
//                                     decoration: InputDecoration(
//                                         hintText: "Search",
//                                         hintStyle: TextStyle(
//                                           // color: darkModeEnabled? Colors.white : Colors.grey.shade700,
//                                         ),
//                                         contentPadding: EdgeInsets.only(bottom: 10,left: 10),
//                                         border: InputBorder.none),
//                                   ),
//                                 ),
//                               ),
//                               TopHomepageIcon(
//                                   Icons.arrow_forward_outlined, () {}),
//                               Expanded(child: SizedBox()),
//                               TopHomepageIcon(
//                                   Icons.calendar_month_outlined, () {}),
//                               IconButton(
//                                 onPressed: () {
//                                   context.read<LightDarkMode>().toggleDarkMode();
//                                   if(!darkModeEnabled){
//                                   context.read<IconsProvider>().changePath("images/diligov_darkmode_icon.png");
//                                   }
//                                   else{
//                                     context.read<IconsProvider>().changePath("images/diligov_icon.png");
//                                   }
//                                 },
//                                 icon: SvgPicture.asset(
//                                   "icons/dark_mode.svg",
//                                   color: Colors.grey.shade600,
//                                   width: 30,
//                                   height: 30,
//                                 ),
//                               ),
//                               TopHomepageIcon(Icons.settings, () {}),
//                               TopHomepageIcon(Icons.person, () {
//                                 Navigator.push(context, MaterialPageRoute(builder: (context) => UserProfile()));
//                               }),
//                               TopHomepageIcon(Icons.notifications, () {}),
//                               TopHomepageIcon(Icons.file_copy_sharp, () {
//                                 Navigator.push(context, MaterialPageRoute(builder: (context)=> FilesPage()));
//                               })
//                             ]),
//                             Expanded(child: SizedBox()),
//                             Stack(
//                               children: [
//                                 GestureDetector(
//                                   onTap: (){
//                                     setState(() {
//                                       if( iconPath == "images/diligov_icon.png" || iconPath == "images/diligov_darkmode_icon.png"){
//                                       menuPressed = !menuPressed;
//                                       }
//                                       else{
//                                         if(darkModeEnabled){
//                                           context.read<IconsProvider>().changePath("images/diligov_darkmode_icon.png");
//                                         }
//                                         else{
//                                         context.read<IconsProvider>().changePath("images/diligov_icon.png");
//                                         }
//                                         context.read<MenusProvider>().changeIconName("Home");
//                                         context.read<MenusProvider>().backToHomeMenu();
//                                       }
//                                     });
//                                   },
//                                   child: Center(
//                                     child: Column(
//                                       children: [
//                                         Image.asset(
//                                           context.watch<IconsProvider>().getIconPath,
//                                           scale: 0.8,
//                                         ),
//                                         if(iconName != "Home")
//                                           Padding(
//                                             padding: EdgeInsets.only(top: 8.0),
//                                             child: Text(iconName,
//                                               style: TextStyle(
//                                                 fontSize: 20,
//                                               fontWeight: FontWeight.bold,
//                                                 color: Colors.grey.shade600
//                                             ),),
//                                           ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             Expanded(child: SizedBox()),
//                             Text("Welcome: User name"),
//                             Row(
//                               children: [
//                                 Text("Connection Security Status :"),
//                                 Text(
//                                   " Strong Encrypted",
//                                   style: TextStyle(color: Colors.green.shade600),
//                                 ),
//                                 Expanded(child: SizedBox()),
//                                 Row(
//                                   children: [
//                                     Text(
//                                       DateFormat.jm().format(DateTime.now()) +
//                                           " - " +
//                                           "$cityName - " +
//                                           DateFormat("dd/MM/yyyy")
//                                               .format(DateTime.now()),
//                                       style: TextStyle(
//                                           color: Colors.grey.shade800,
//                                           fontWeight: FontWeight.bold),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//
//                     Padding(
//                       padding:
//                           EdgeInsets.only(top: height / 1.5, left: width / 4.8),
//                       child: Container(
//                         height: 170,
//                         width: 700,
//                         decoration: BoxDecoration(
//                             color: Colors.white.withOpacity(0.001),
//                             borderRadius: BorderRadius.circular(360),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.white.withOpacity(0.02),
//                                 blurRadius: 100.0,
//                                 spreadRadius: 5.0,
//                                 offset: Offset(0, 1),
//                                 // shadow direction: bottom right
//                               ),
//                             ]),
//                       ),
//                     ),
//                     Visibility(
//                       visible: menuPressed,
//                         child: CircularFabWidget()
//                     ),
//                   ],
//                 ),
//               );
//             })));
//   }
// }
//
//
// class TopHomepageIcon extends StatelessWidget {
//   final IconData iconName;
//   final VoidCallback onPressed;
//   TopHomepageIcon(this.iconName, this.onPressed);
//
//   @override
//   Widget build(BuildContext context) {
//     return IconButton(
//         onPressed: onPressed,
//         icon: Icon(
//           iconName,
//           size: 30,
//           color: Colour().iconsColor,
//         ));
//   }
// }
