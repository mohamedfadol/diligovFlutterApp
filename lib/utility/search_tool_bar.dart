// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:syncfusion_flutter_pdf/pdf.dart';
// import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
// import 'package:logger/logger.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../NetworkHandler.dart';
// import '../../models/user.dart';
// import 'dart:convert';
// import 'dart:io';
// import 'dart:async';
//
// import '../models/searchable.dart';
// import '../widgets/appBar.dart';
// class FindText extends StatefulWidget {
//   final String file;
//   const FindText({Key? key,required this.file}) : super(key: key);
//   static const routeName = '/FindText';
//
//   @override
//   State<FindText> createState() => _FindTextState();
// }
//
// class _FindTextState extends State<FindText> {
//
//   final PdfViewerController _pdfViewerController = PdfViewerController();
//
//   final GlobalKey<SearchToolbarState> _textSearchKey = GlobalKey();
//   late bool _showToolbar;
//   late bool _showScrollHead;
//
//   var log = Logger();
//   NetworkHandler networkHandler = NetworkHandler();
//   User user = User();
//
//   /// Ensure the entry history of Text search.
//   LocalHistoryEntry? _historyEntry;
//
//   late List searchables = [];
//   Future<List<Searchable>?> getAllFiles() async{
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     user =  User.fromJson(json.decode(prefs.getString("user")!)) ;
//     var response = await networkHandler.get('/get-list-searchables/${user.businessId.toString()}');
//     if (response.statusCode == 200 || response.statusCode == 201) {
//       log.d("get-list-searchables response statusCode == 200");
//       var responseData = json.decode(response.body) ;
//       var boardsData = responseData['data'] ;
//       setState((){
//         searchables = boardsData['searchables'];
//         log.d(searchables);
//       });
//
//     } else {
//       print(json.decode(response.body)['message']);
//     }
//   }
//
//   @override
//   void initState() {
//     _showToolbar = false;
//     _showScrollHead = true;
//     getAllFiles();
//     super.initState();
//   }
//
//   /// Ensure the entry history of text search.
//   void _ensureHistoryEntry() {
//     if (_historyEntry == null) {
//       final ModalRoute<dynamic>? route = ModalRoute.of(context);
//       if (route != null) {
//         _historyEntry = LocalHistoryEntry(onRemove: _handleHistoryEntryRemoved);
//         route.addLocalHistoryEntry(_historyEntry!);
//       }
//     }
//   }
//
//   /// Remove history entry for text search.
//   void _handleHistoryEntryRemoved() {
//     _textSearchKey.currentState?.clearSearch();
//     setState(() {
//       _showToolbar = false;
//     });
//     _historyEntry = null;
//   }
//
//   final String url ='https://diligov.com/public/charters/1/1675405923.A-Z-Alphabet-Book-and-1-10.pdf';
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: _showToolbar
//           ? AppBar(
//         flexibleSpace: SafeArea(
//           child: SearchToolbar(
//             key: _textSearchKey,
//             showTooltip: true,
//             controller: _pdfViewerController,
//             onTap: (Object toolbarItem) async {
//               if (toolbarItem.toString() == 'Cancel Search') {
//                 setState(() {
//                   _showToolbar = false;
//                   _showScrollHead = true;
//                   if (Navigator.canPop(context)) {
//                     Navigator.maybePop(context);
//                   }
//                 });
//               }
//               if (toolbarItem.toString() == 'noResultFound') {
//                 setState(() {
//                   _textSearchKey.currentState?._showToast = true;
//                 });
//                 await Future.delayed(const Duration(seconds: 1));
//                 setState(() {
//                   _textSearchKey.currentState?._showToast = false;
//                 });
//               }
//
//             },
//           ),
//         ),
//         automaticallyImplyLeading: false,
//         backgroundColor: const Color(0xFFFAFAFA),
//       )
//           : AppBar(
//         title: const Text('you could search some text !!', style: TextStyle(color: Colors.black87),),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.search,color: Colors.black87,),
//             onPressed: () {
//               setState(() {
//                 _showScrollHead = false;
//                 _showToolbar = true;
//                 _ensureHistoryEntry();
//               });
//             },
//           ),
//         ],
//         automaticallyImplyLeading: false,
//         backgroundColor: const Color(0xFFFAFAFA),
//       ),
//       body:  Stack(
//         children: [
//           Opacity(
//               opacity:0,
//               child: SfPdfViewer.network(
//                 url ?? widget.file,
//                 controller: _pdfViewerController,
//                 canShowScrollHead: _showScrollHead,
//               )
//           ),
//           Visibility(
//             visible: _textSearchKey.currentState?._showToast ?? false,
//             child: Align(
//               alignment: Alignment.center,
//               child: Flex(
//                 direction: Axis.horizontal,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: <Widget>[
//                   Container(
//                     padding:
//                     const EdgeInsets.only(left: 15, top: 7, right: 15, bottom: 7),
//                     decoration: BoxDecoration(
//                       color: Colors.grey[600],
//                       borderRadius: const BorderRadius.all(
//                         Radius.circular(16.0),
//                       ),
//                     ),
//                     child: const Text(
//                       'No result',
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                           fontFamily: 'Roboto',
//                           fontSize: 16,
//                           color: Colors.white),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           )
//         ],
//       ),
//
//     );
//   }
//
//   String buildsearchableText(String url){
//
//     for(int index =0; index < searchables.length; index++){
//
//       SfPdfViewer.network(
//         url,
//         controller: _pdfViewerController,
//         canShowScrollHead: _showScrollHead,
//       );
//     }
//     return url;
//   }
// }
//
// /// Signature for the [SearchToolbar.onTap] callback.
// typedef SearchTapCallback = void Function(Object item);
//
// /// SearchToolbar widget
// class SearchToolbar extends StatefulWidget {
//   ///it describe the search toolbar constructor
//   const SearchToolbar({
//     this.controller,
//     this.onTap,
//     this.showTooltip = true,
//     Key? key,
//   }) : super(key: key);
//
//   /// Indicates whether the tooltip for the search toolbar items need to be shown or not.
//   final bool showTooltip;
//
//   /// An object that is used to control the [SfPdfViewer].
//   final PdfViewerController? controller;
//
//   /// Called when the search toolbar item is selected.
//   final SearchTapCallback? onTap;
//
//   @override
//   SearchToolbarState createState() => SearchToolbarState();
// }
//
// /// State for the SearchToolbar widget
// class SearchToolbarState extends State<SearchToolbar> {
//   /// Indicates whether search is initiated or not.
//   bool _isSearchInitiated = false;
//
//   /// Indicates whether search toast need to be shown or not.
//   bool _showToast = false;
//
//   ///An object that is used to retrieve the current value of the TextField.
//   final TextEditingController _editingController = TextEditingController();
//
//   /// An object that is used to retrieve the text search result.
//   PdfTextSearchResult _pdfTextSearchResult = PdfTextSearchResult();
//
//   ///An object that is used to obtain keyboard focus and to handle keyboard events.
//   FocusNode? focusNode;
//
//   @override
//   void initState() {
//     super.initState();
//     focusNode = FocusNode();
//     focusNode?.requestFocus();
//   }
//
//   @override
//   void dispose() {
//     // Clean up the focus node when the Form is disposed.
//     focusNode?.dispose();
//     _pdfTextSearchResult.removeListener(() {});
//     super.dispose();
//   }
//
//   ///Clear the text search result
//   void clearSearch() {
//     _isSearchInitiated = false;
//     _pdfTextSearchResult.clear();
//   }
//
//   ///Display the Alert dialog to search from the beginning
//   void _showSearchAlertDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           insetPadding: const EdgeInsets.all(0),
//           title: const Text('Search Result'),
//           content: const SizedBox(
//               width: 328.0,
//               child: Text(
//                   'No more occurrences found. Would you like to continue to search from the beginning?')),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 setState(() {
//                   _pdfTextSearchResult.nextInstance();
//                 });
//                 Navigator.of(context).pop();
//               },
//               child: Text(
//                 'YES',
//                 style: TextStyle(
//                     color: const Color(0x00000000).withOpacity(0.87),
//                     fontFamily: 'Roboto',
//                     fontStyle: FontStyle.normal,
//                     fontWeight: FontWeight.w500,
//                     decoration: TextDecoration.none),
//               ),
//             ),
//             TextButton(
//               onPressed: () {
//                 setState(() {
//                   _pdfTextSearchResult.clear();
//                   _editingController.clear();
//                   _isSearchInitiated = false;
//                   focusNode?.requestFocus();
//                 });
//                 Navigator.of(context).pop();
//               },
//               child: Text(
//                 'NO',
//                 style: TextStyle(
//                     color: Color(0x00000000).withOpacity(0.87),
//                     fontFamily: 'Roboto',
//                     fontStyle: FontStyle.normal,
//                     fontWeight: FontWeight.w500,
//                     decoration: TextDecoration.none),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   ///Display the Alert dialog to display result
//   void _showSearchAlertDialogResult(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           insetPadding: const EdgeInsets.all(0),
//           title: Container(
//             width: 50.0,
//             padding: EdgeInsets.all(10.0),
//             color: Colors.red,
//             child: const Text('Results',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 18),),
//           ),
//           content: SizedBox(
//               width: 800.0,
//               height: 250.0,
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Text('Document name of document contains the word ( search ) in page ${_pdfTextSearchResult.currentInstanceIndex} of ${_pdfTextSearchResult.totalInstanceCount}',
//                         style: TextStyle(
//                             color: const Color.fromRGBO(0, 0, 0, 0.54).withOpacity(0.87),
//                             fontSize: 16),
//                       ),
//                       const Divider(color: Colors.black,),
//                     ],
//                   ),
//                   Text('No more occurrences found. Would you like to continue to search from the beginning?'),
//                 ],
//               )),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 setState(() {
//                   _pdfTextSearchResult.clear();
//                   _editingController.clear();
//                   _isSearchInitiated = false;
//                   Navigator.pop(context);
//                 });
//                 Navigator.pop(context);
//               },
//               child: Text(
//                 'YES',
//                 style: TextStyle(
//                     color: const Color(0x00000000).withOpacity(0.87),
//                     fontFamily: 'Roboto',
//                     fontStyle: FontStyle.normal,
//                     fontWeight: FontWeight.w500,
//                     decoration: TextDecoration.none),
//               ),
//             ),
//             TextButton(
//               onPressed: () {
//                 setState(() {
//                   _pdfTextSearchResult.clear();
//                   _editingController.clear();
//                   _isSearchInitiated = false;
//                   Navigator.pop(context);
//                 });
//                 Navigator.pop(context);
//               },
//               child: Text(
//                 'NO',
//                 style: TextStyle(
//                     color: Color(0x00000000).withOpacity(0.87),
//                     fontFamily: 'Roboto',
//                     fontStyle: FontStyle.normal,
//                     fontWeight: FontWeight.w500,
//                     decoration: TextDecoration.none),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: <Widget>[
//         SizedBox(
//           width: 450,
//           height: 50,
//           child: TextFormField(
//             style: TextStyle(color: const Color(0x00000000).withOpacity(0.87), fontSize: 16),
//             enableInteractiveSelection: false,
//             focusNode: focusNode,
//             keyboardType: TextInputType.text,
//             textInputAction: TextInputAction.search,
//             controller: _editingController,
//             decoration: InputDecoration(
//               prefixIcon: buildArrowIcon(),
//               suffixIcon: buildCloseIcon(),
//               hintText: "Looking For Some Words!!",
//               border: const OutlineInputBorder(
//                   borderRadius: BorderRadius.all(Radius.circular(50))
//               ),
//               hintStyle: TextStyle(color: const Color(0x00000000).withOpacity(0.34)),
//             ),
//             onChanged: (text) {
//               if (_editingController.text.isNotEmpty) {
//                 setState(() {});
//               }
//             },
//             onFieldSubmitted: (String value) {
//               if (kIsWeb) {
//                 _pdfTextSearchResult = widget.controller!.searchText(_editingController.text);
//                 print(
//                     'kIsWeb Total instance count: ${_pdfTextSearchResult.totalInstanceCount}');
//
//                 if (_pdfTextSearchResult.totalInstanceCount == 0) { widget.onTap?.call('noResultFound'); }
//                 setState(() {});
//               } else {
//                 _isSearchInitiated = true;
//                 _pdfTextSearchResult = widget.controller!.searchText(_editingController.text);
//                 _pdfTextSearchResult.addListener(() {
//                   print(
//                       'Total instance count: ${_pdfTextSearchResult.totalInstanceCount}');
//
//                   if (super.mounted) {
//                     setState(() {
//                       print(
//                           'mounted Total instance count: ${_pdfTextSearchResult.totalInstanceCount}');
//                     });
//                   }
//                   if (!_pdfTextSearchResult.hasResult && _pdfTextSearchResult.isSearchCompleted) {
//                     widget.onTap?.call('noResultFound');
//                   }
//                 });
//               }
//             },
//           ),
//         ),
//         const SizedBox(width: 10.0),
//         buildCircularForWaitingResultSearching(),
//         buildVisibilityIfSearchHasResult()
//
//       ],
//     );
//   }
//
//
//   Widget buildArrowIcon() => IconButton(
//     icon: Icon(
//       Icons.arrow_back,
//       color: const Color(0x00000000).withOpacity(0.54),
//       size: 24,
//     ),
//     onPressed: () {
//       widget.onTap?.call('Cancel Search');
//       _isSearchInitiated = false;
//       _editingController.clear();
//       _pdfTextSearchResult.clear();
//     },
//   );
//
//   Widget buildCloseIcon() => Visibility(
//     visible: _editingController.text.isNotEmpty,
//     child: Material(
//       color: Colors.transparent,
//       child: IconButton(
//         icon: const Icon(
//           Icons.clear,
//           color: Color.fromRGBO(0, 0, 0, 0.54),
//           size: 24,
//         ),
//         onPressed: () {
//           setState(() {
//             _editingController.clear();
//             _pdfTextSearchResult.clear();
//             widget.controller!.clearSelection();
//             _isSearchInitiated = false;
//             focusNode!.requestFocus();
//           });
//           widget.onTap!.call('Clear Text');
//         },
//         tooltip: widget.showTooltip ? 'Clear Text' : null,
//       ),
//     ),
//   );
//
//   Widget buildCircularForWaitingResultSearching() => Visibility(
//     visible:
//     !_pdfTextSearchResult.isSearchCompleted && _isSearchInitiated,
//     child: Padding(
//       padding: const EdgeInsets.only(right: 10),
//       child: SizedBox(
//         width: 24,
//         height: 24,
//         child: CircularProgressIndicator(
//           color: Theme.of(context).primaryColor,
//         ),
//       ),
//     ),
//   );
//
//   Widget buildVisibilityIfSearchHasResult() => Visibility(
//     visible: _pdfTextSearchResult.hasResult,
//     child: Row(
//       children: [
//         Text('${_pdfTextSearchResult.currentInstanceIndex}',
//           style: TextStyle(
//               color: const Color.fromRGBO(0, 0, 0, 0.54).withOpacity(0.87),
//               fontSize: 16),
//         ),
//         Text(' of ',
//           style: TextStyle(
//               color: const Color.fromRGBO(0, 0, 0, 0.54).withOpacity(0.87),
//               fontSize: 16),
//         ),
//         Text('${_pdfTextSearchResult.totalInstanceCount}',
//           style: TextStyle(
//               color: const Color.fromRGBO(0, 0, 0, 0.54).withOpacity(0.87),
//               fontSize: 16),
//         ),
//         Material(
//           color: Colors.transparent,
//           child: IconButton(
//             icon: const Icon(
//               Icons.navigate_before,
//               color: Color.fromRGBO(0, 0, 0, 0.54),
//               size: 24,
//             ),
//             onPressed: () {
//               setState(() {
//                 _pdfTextSearchResult.previousInstance();
//               });
//               widget.onTap!.call('Previous Instance');
//             },
//             tooltip: widget.showTooltip ? 'Previous' : null,
//           ),
//         ),
//         Material(
//           color: Colors.transparent,
//           child: IconButton(
//             icon: const Icon(
//               Icons.navigate_next,
//               color: Color.fromRGBO(0, 0, 0, 0.54),
//               size: 24,
//             ),
//             onPressed: () {
//               setState(() {
//                 if (_pdfTextSearchResult.currentInstanceIndex == _pdfTextSearchResult.totalInstanceCount &&
//                     _pdfTextSearchResult.currentInstanceIndex != 0 && _pdfTextSearchResult.totalInstanceCount != 0 && _pdfTextSearchResult.isSearchCompleted) {
//                   _showSearchAlertDialog(context);
//                 } else {
//                   widget.controller!.clearSelection();
//                   _pdfTextSearchResult.nextInstance();
//                 }
//               });
//               widget.onTap!.call('Next Instance');
//             },
//             tooltip: widget.showTooltip ? 'Next' : null,
//           ),
//         ),
//         Material(
//           color: Colors.transparent,
//           child: TextButton(
//             child: const Text('Show Result', style: TextStyle(color: Colors.red),),
//             onPressed: () {
//               setState(() {
//                 if (_pdfTextSearchResult.hasResult) {
//                   _showSearchAlertDialogResult(context);
//                 }
//               });
//             },
//           ),
//         ),
//       ],
//     ),
//   );
// }