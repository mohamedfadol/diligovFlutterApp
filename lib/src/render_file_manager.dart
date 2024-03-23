import 'package:diligov/providers/note_page_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:logger/logger.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import 'package:provider/provider.dart';
import '../models/board_model.dart';
import '../models/committee_model.dart';
import '../models/data/years_data.dart';
import '../models/user.dart';
import '../utility/meetings_expansion_panel.dart';
import '../utility/pdf_api.dart';
import '../widgets/appBar.dart';
import '../widgets/custome_text.dart';
import '../widgets/dropdown_string_list.dart';

class RenderFileManager extends StatefulWidget {
  final String path;
  const RenderFileManager({super.key, required this.path});

  @override
  State<RenderFileManager> createState() => _RenderFileManagerState();
}

class _RenderFileManagerState extends State<RenderFileManager>  with SingleTickerProviderStateMixin{


  final GlobalKey<ScaffoldState> _parentScaffoldKey = GlobalKey<ScaffoldState>();

  User user = User();
  var log = Logger();
  // Initial Selected Value
  String yearSelected = '2024';
  String localPath = "";
  UniqueKey? keyTile;
  TabController? defaultTabBarViewController;
  int tabIndex = 0;
  void expandTile(){
    setState(() {
      keyTile = UniqueKey();
    });
  }

  @override
  void initState() {
    // print(widget.path);
    defaultTabBarViewController = TabController(length: 2, vsync: this);
    preparePdfFileFromNetwork();
    super.initState();
  }

  @override
  void dispose() {
    defaultTabBarViewController!.dispose();
    super.dispose();
  }

  Future<void> preparePdfFileFromNetwork() async {
    try {
      if(await PDFApi.requestPermission()){
        //'https://diligov.com/public/charters/1/logtah.pdf'; // Replace with your PDF URL
        final filePath = await PDFApi.loadNetwork(widget.path);
        setState(() { localPath = filePath.path!;});
        print('preparePdfFileFromNetwork function $localPath');
      } else {
        print("Lacking permissions to access the file in preparePdfFileFromNetwork function");
        return;
      }
    } catch (e) { print("Error preparePdfFileFromNetwork function PDF: $e"); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: Header(context),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildFullTopFilter(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 600,
                  margin: EdgeInsets.only(right: 25.0),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildUpperTitleLeftSideBox(),
                      buildSearchBoxLeftSide(),
                      buildAllAnnotationsLeftSideBox() ,
                      SizedBox(height: 15,),
                      buildStaticDividerSizeBox(Colors.grey[100]!),
                      SizedBox(
                        height: 50,
                        width: 400,
                        child: TabBar(
                          onTap: (index) {
                            setState(() {
                              tabIndex = index;
                            });
                            print(index);
                          },
                          enableFeedback: true,
                          controller: defaultTabBarViewController,
                          dividerColor: Colors.grey,
                          indicatorColor: Colors.red,
                          labelColor: Colors.red,
                          unselectedLabelColor: Colors.grey,
                          labelStyle: TextStyle(fontWeight: FontWeight.bold,fontSize: 16,color: Colors.red),
                          tabs: [
                            Tab(child: Text("Boards")),
                            Tab(child: Text("Committees")),
                          ],
                        ),
                      ),
                      Expanded(
                        child: SizedBox(
                          width: 400,
                          child: TabBarView(
                              controller: defaultTabBarViewController,
                              children: [
                                Consumer<NotePageProvider>(
                                    builder: (context, provider, child) {
                                      if (provider.boardsData?.boards == null) {
                                        provider.getListOfBoardNotes(context);
                                        return Center(
                                          child: SpinKitThreeBounce(
                                            itemBuilder: (BuildContext context, int index) {
                                              return DecoratedBox(
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(15),
                                                  color: index.isEven ? Colors.red : Colors.green,
                                                ),
                                              );
                                            },
                                          ),
                                        );
                                      }
                                      return provider.boardsData!.boards!.isEmpty
                                          ? buildEmptyContainerNotes()
                                          : buildResponseDataOfBoardNotes(provider);
                                    }),

                                Consumer<NotePageProvider>(
                                    builder: (context, provider, child) {
                                      if (provider.committeesData?.committees == null) {
                                        provider.getListOfCommitteeNotes(context);
                                        return Center(
                                          child: SpinKitThreeBounce(
                                            itemBuilder: (BuildContext context, int index) {
                                              return DecoratedBox(
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(15),
                                                  color: index.isEven ? Colors.red : Colors.green,
                                                ),
                                              );
                                            },
                                          ),
                                        );
                                      }
                                      return provider.committeesData!.committees!.isEmpty
                                          ? buildEmptyContainerNotes()
                                          : buildResponseDataOfCommitteesNotes(provider);
                                    }),
                              ]
                          ),
                        ),
                      ),

                    ],),
                ),
                Expanded(
                  child: localPath.isNotEmpty
                      ? SizedBox(
                        height: 550,
                        child: PDFView(
                          fitEachPage: true,
                          filePath: localPath!,
                          autoSpacing: true,
                          enableSwipe: true,
                          pageSnap: true,
                          swipeHorizontal: false,
                          nightMode: false,
                          onPageChanged: (int? currentPage, int? totalPages) {

                            print("Current page: $currentPage!, Total pages: $totalPages!");
                            // You can use this callback to keep track of the current page.
                          },
                        ),
                      )
                      : const Center(child: CircularProgressIndicator()),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildFullTopFilter() => Padding(
    padding: const EdgeInsets.only(top: 3.0, left: 0.0, right: 8.0, bottom: 8.0),
    child: Row(
      children: [
        Container(
          width: 200,
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15.0),
          color: Colors.red,
          child: Center(child: CustomText(text: 'My Notes',color: Colors.white,fontSize: 20,fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 5.0,),
        Container(
          width: 200,
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15.0),
          color: Colors.red,
          child: DropdownButtonHideUnderline(
            child: DropdownStringList(
              boxDecoration: Colors.white,
              hint: CustomText(text: AppLocalizations.of(context)!.select_year,color: Colors.white) ,
              selectedValue: yearSelected,
              dropdownItems: yearsData,
              onChanged: (String? newValue) async {
                yearSelected = newValue!.toString();
                setState(() {yearSelected = newValue!;});
                Map<String, dynamic> data = {
                  "dateYearRequest": yearSelected!,
                  // "member_id": "member_id"
                };
                NotePageProvider providerGetNotesByDateYear = Provider.of<NotePageProvider>(context,listen: false);
                if(tabIndex == 0){
                  Future.delayed(Duration.zero, () {
                    providerGetNotesByDateYear.getListOfBoardNotes(data);
                  });
                }else{
                  Future.delayed(Duration.zero, () {
                    providerGetNotesByDateYear.getListOfCommitteeNotes(data);
                  });
                }

              },
              color: Colors.grey,
            ),
          ),
        ),
      ],
    ),
  );

  Widget buildSearchBoxLeftSide() {
    return Padding(
      padding: const EdgeInsets.only(left: 15.0),
      child: Center(
        child: SizedBox(
          height: 40,
          width: 370,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey.withOpacity(0.5),
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(
                    Icons.search,
                    color: Colors.grey,
                    size: 25,
                  ),
                ),
                new Expanded(
                  child: TextField(
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Quick Search",
                      hintStyle: TextStyle(color: Colors.grey),
                      contentPadding:
                      EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                      isDense: true,
                    ),
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.black,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildAllAnnotationsLeftSideBox() {
    return Padding(
      padding: EdgeInsets.only(left: 15.0, top: 30.0),
      child: Row(
        // crossAxisAlignment: CrossAxisAlignment.start,
        // mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(Icons.note_alt_outlined),
          SizedBox(width: 10.0,),
          Text('See all my annotations'),

        ],
      ),
    );
  }

  Widget buildUpperTitleLeftSideBox() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 15.0),
      margin: EdgeInsets.only(bottom: 10.0),
      color: Colors.grey[100],
      width: 400,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              // height: 50,
              // color: Colors.red,
              child: Text('All groups'),
            ),
            SizedBox(width: 10.0,),
            Container(
              // height: 50,
              // color: Colors.red,
              child: Icon(Icons.arrow_drop_down),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildStaticDividerSizeBox(Color dividerColor) {
    return new SizedBox(
      height: 2.0,
      width: 400,
      child: new Container(
        margin: new EdgeInsetsDirectional.only(start: 50.0, end: 1.0),
        height: 2.0,
        color: dividerColor,
      ),
    );
  }

  Widget buildEmptyContainerNotes() {
    return Container(
        decoration: BoxDecoration(border: Border.all(color: Colors.white, width: 1.0)),
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: CustomText(
            text:
            AppLocalizations.of(context)!.no_data_to_show,
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        )
    );
  }


  Widget buildResponseDataOfBoardNotes(NotePageProvider provider) {
    return Container(
      // color: Colors.red,
      padding: EdgeInsets.only(top: 10.0),
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        scrollDirection: Axis.vertical,
        child: ExpansionPanelList(
          materialGapSize: 10.0,
          dividerColor: Colors.grey[100],
          elevation: 3.0,
          expandedHeaderPadding: EdgeInsets.all(0.0),
          expandIconColor: Colors.white,
          expansionCallback: (int index, bool isExpanded) {
            provider.toggleBoardParentMenu(index);
            print(index);
          },
          children: provider.boardsData!.boards!.map<ExpansionPanel>((Board board) {
            return ExpansionPanel(
              canTapOnHeader: true,
              backgroundColor: board.isExpanded! ? Colors.grey  : Colors.blueGrey[200],
              headerBuilder: (BuildContext context, bool isExpanded) {
                return ListTile(
                  title: CustomText(text:'${board?.boardName ?? ''}' , fontWeight: FontWeight.bold,),
                );
              },
              body: MeetingsExpansionPanel(meetings: board.meetings!,),
              isExpanded: board.isExpanded!,
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget buildResponseDataOfCommitteesNotes(NotePageProvider provider) {
    return Container(
      // color: Colors.red,
      padding: EdgeInsets.only(top: 10.0),
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        scrollDirection: Axis.vertical,
        child: ExpansionPanelList(
          materialGapSize: 10.0,
          dividerColor: Colors.grey[100],
          elevation: 3.0,
          expandedHeaderPadding: EdgeInsets.all(0.0),
          expandIconColor: Colors.white,
          expansionCallback: (int index, bool isExpanded) {
            provider.toggleCommitteeParentMenu(index);
            print(index);
          },
          children: provider.committeesData!.committees!.map<ExpansionPanel>((Committee committee) {
            return ExpansionPanel(
              canTapOnHeader: true,
              backgroundColor: committee.isExpanded! ? Colors.grey  : Colors.blueGrey[200],
              headerBuilder: (BuildContext context, bool isExpanded) {
                return ListTile(
                  title: CustomText(text:'${committee?.committeeName ?? ''}' , fontWeight: FontWeight.bold,),
                );
              },
              body: MeetingsExpansionPanel(meetings: committee.meetings!,),
              isExpanded: committee.isExpanded!,
            );
          }).toList(),
        ),
      ),
    );
  }
}
