import 'package:diligov/utility/pdf_api.dart';
import 'package:flutter/material.dart';

import '../core/domains/app_uri.dart';
import '../models/agenda_model.dart';
import '../models/meeting_model.dart';
import '../src/render_file_manager.dart';
import '../widgets/custome_text.dart';
class MeetingsExpansionPanel extends StatefulWidget {
  final List<Meeting>? meetings;

  MeetingsExpansionPanel({super.key, required this.meetings});

  @override
  State<MeetingsExpansionPanel> createState() => _MeetingsExpansionPanelState();
}

class _MeetingsExpansionPanelState extends State<MeetingsExpansionPanel> {

  String? localPath = '';
  String? baseUri;

  @override
  Widget build(BuildContext context) {

    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      scrollDirection: Axis.vertical,
      child: ExpansionPanelList.radio(
        materialGapSize: 10.0,
        dividerColor: Colors.grey[100],
        elevation: 3.0,
        expandedHeaderPadding : EdgeInsets.only(top: 5.0, bottom: 5.0),
        children: widget.meetings!.map<ExpansionPanelRadio>((Meeting meeting) {
          return ExpansionPanelRadio(
            canTapOnHeader: true,
            backgroundColor: meeting.isExpanded! ? Colors.grey  : Colors.blueGrey[200],
            value: meeting.meetingId.toString(),
            headerBuilder: (BuildContext context, bool isExpanded) {
              return Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: ListTile(
                  title: CustomText(
                    text: '- ${meeting.meetingTitle!} & ${meeting.meetingSerialNumber!}',
                    fontWeight: FontWeight.w500,
                    fontSize: 18.0,
                  ),
                ),
              );
            },
            body: SizedBox(
              height: 300,
              child: ListView.separated(
                  itemCount: meeting.agendas!.length,
                  itemBuilder: (BuildContext context, int index) {
                    final Agenda agenda = meeting.agendas![index];
                    return
                      Container(
                        color: agenda.isClicked! ? Colors.red[100] :  Colors.blueGrey[50],
                        child: ListTile(
                          key: UniqueKey(),
                          onTap: () async {
                            setState(() {
                              meeting.agendas!.forEach((item) {
                                item.isClicked = false;
                              });
                              agenda!.isClicked = !agenda.isClicked!;
                            final baseUri = '${AppUri.baseUri}';
                              localPath =  '${baseUri}/${agenda.agendaFileFullPath.toString()}' ?? '';
                            });
                            try {
                              if(await PDFApi.requestPermission()){
                                print('agenda full path == $localPath');
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => RenderFileManager(path: localPath!)),
                                );
                              } else {
                                print("Lacking permissions to access the file in preparePdfFileFromNetwork function");
                                return;
                              }
                            } catch (e) { print("Error preparePdfFileFromNetwork function PDF: $e"); }

                          },
                          contentPadding: EdgeInsets.only(left: 30.0),
                          leading: Icon(Icons.picture_as_pdf_outlined),
                          title: Text(agenda.agendaTitle ?? 'no file attached'),
                          subtitle: Text(agenda.agendaFileName ?? ''),
                        ),
                      );
                  },
                  separatorBuilder: (context, index) => buildStaticDividerSizeBox(Colors.red[200]!)
              ),
            ),
          );
        }).toList(),
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
}