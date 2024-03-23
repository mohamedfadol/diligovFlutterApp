import 'package:diligov/models/committee_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

import '../../../colors.dart';
import '../../../models/agenda_model.dart';
import '../../../models/board_model.dart';
import '../../../models/data/years_data.dart';
import '../../../models/meeting_model.dart';
import '../../../models/note_model.dart';
import '../../../models/user.dart';
import '../../../providers/note_page_provider.dart';
import '../../../src/custom_rendering_file_pdf.dart';
import '../../../src/render_file_manager.dart';
import '../../../utility/laboratory_file_processing.dart';
import '../../../utility/meetings_expansion_panel.dart';
import '../../../utility/pdf_api.dart';
import '../../../widgets/appBar.dart';
import '../../../widgets/build_dynamic_data_cell.dart';
import '../../../widgets/custom_icon.dart';
import '../../../widgets/custome_text.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';

import '../../../widgets/dropdown_string_list.dart';


class NoteListViews extends StatefulWidget {
  const NoteListViews({super.key});
  static const routeName = '/NoteListViews';

  @override
  State<NoteListViews> createState() => _NoteListViewsState();
}

class _NoteListViewsState extends State<NoteListViews> with SingleTickerProviderStateMixin{
  var log = Logger();
  User user = User();
  // Initial Selected Value
  String yearSelected = '2024';
  String localPath ='';
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
    // TODO: implement initState
    defaultTabBarViewController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    defaultTabBarViewController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: Header(context),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.0),
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
                  margin: EdgeInsets.only(right: 30.0),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // buildUpperTitleLeftSideBox(),
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
                              Tab(child: CustomText(text:"Boards")),
                              Tab(child: CustomText(text:"Committees")),
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
                  child: Container(
                    height: 600,
                    color: Colors.white,
                    // child: CustomRenderingFilePdf(path: localPath!),
                  ),
                ),
              ],
            )

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


  Widget buildAllAnnotationsLeftSideBox() {
    return Padding(
      padding: EdgeInsets.only(left: 15.0, top: 10.0),
      child: Row(
        // crossAxisAlignment: CrossAxisAlignment.start,
        // mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(Icons.note_alt_outlined),
          SizedBox(width: 15.0,),
          CustomText(text:'See all my annotations',fontWeight: FontWeight.bold,fontSize: 16,color: Colors.grey),

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
              child: CustomText(text:'All groups',fontWeight: FontWeight.bold,fontSize: 16,color: Colors.grey),
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





