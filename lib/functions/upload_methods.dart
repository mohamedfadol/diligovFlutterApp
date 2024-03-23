import 'package:flutter/material.dart';

// Widget bottomSheet(){
//   return Container(
//       height: 100.0,
//       width: MediaQuery.of(context).size.width,
//       margin: EdgeInsets.symmetric(horizontal:20, vertical:20),
//       child: Column(
//           children:[
//             Text('Choose an Photo',style: TextStyle(fontSize: 20)),
//             SizedBox(height: 20),
//
//             Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   ElevatedButton.icon(
//                     onPressed: () {
//                       takePhoto(ImageSource.camera);
//                     },
//                     icon: Icon(Icons.camera,size: 24.0,),
//                     label: Text('Camera'), // <-- Text
//                   ),
//                   SizedBox(width:15),
//                   ElevatedButton.icon(
//                     onPressed: () {
//                       takePhoto(ImageSource.gallery);
//                     },
//                     icon: Icon(Icons.image,size: 24.0,),
//                     label: Text('Gallery'), // <-- Text
//                   ),
//
//                 ]
//             )
//           ]
//       )
//   );
// }
//
// Widget imageProfile() {
//   return Center(
//     child: Stack(
//       children: <Widget>[
//         CircleAvatar(
//           backgroundColor: Colors.brown.shade800,
//           radius: 70.0,
//           backgroundImage: _imageFile == null ?
//           AssetImage("assets/images/profile.jpg",) as ImageProvider : FileImage(File(_imageFile!.path)),
//         ),
//         Positioned(
//             child: InkWell(
//                 onTap: (){
//                   showModalBottomSheet(
//                     context: context,
//                     builder: ((builder) => bottomSheet()),
//                   );
//                 },
//                 child: Icon(Icons.camera_alt,size: 40, color: Colors.teal,)
//             )
//
//         )
//       ],
//     ),
//   );
// }
//
// Future<XFile?> takePhoto(ImageSource source) async{
//   final XFile? image = await _picker.pickImage(source: source);
//   setState(() { _imageFile = image ;   });
// }
//
