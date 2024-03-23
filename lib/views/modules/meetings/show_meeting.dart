import 'dart:async';
import 'dart:io';

import 'package:diligov/core/domains/app_uri.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';

import '../../../models/meeting_model.dart';
import '../../../utility/laboratory_file_processing.dart';
import '../../../utility/pdf_api.dart';
import '../../../widgets/appBar.dart';
import '../../../widgets/container_lable_with_box_shadow.dart';
import '../../../widgets/custome_text.dart';
class ShowMeeting extends StatefulWidget {
  final Meeting meeting;
   ShowMeeting({ super.key, required this.meeting});

  @override
  State<ShowMeeting> createState() => _ShowMeetingState();
}

class _ShowMeetingState extends State<ShowMeeting> {
  String pathPDF = "";
  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    // Allow all orientations when the widget is disposed
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, //,Colors.grey[400],
      appBar: Header(context),
      body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 15.0),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 400,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          margin: EdgeInsets.all(10.0),
                          width: double.infinity,
                          padding: EdgeInsets.all(15.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                  color: Colors.black54,
                                  blurRadius: 5.0,
                                  offset: Offset(0.0, 0.75)
                              )
                            ],
                            border: Border.all(
                                color: Colors.black12),
                            borderRadius:
                            const BorderRadius.all(Radius.circular(20)),
                          ),
                          child: Center(
                            child: CustomText(text:'Meetings',color: Theme.of(context).iconTheme.color,fontWeight: FontWeight.bold,fontSize: 18.0),
                          ),
                        ),
                        ContainerLabelWithBoxShadow(text: '${widget.meeting.meetingTitle}',),
                        ContainerLabelWithBoxShadow(text: '${widget.meeting?.meetingDescription}' ?? 'No Meeting Description',),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              margin: EdgeInsets.all(5.0),
                              padding: EdgeInsets.all(10.0),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                boxShadow: <BoxShadow>[
                                  BoxShadow(
                                      color: Colors.black54,
                                      blurRadius: 5.0,
                                      offset: Offset(0.0, 0.75)
                                  )
                                ],
                              ),
                            child: CustomText(text:'${widget.meeting?.meetingStartDate.toString()}',color: Theme.of(context).iconTheme.color,fontSize: 14.0),
                            ),
                            SizedBox(width: 5.0,),
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.all(5.0),
                                padding: EdgeInsets.all(10.0),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                  boxShadow: <BoxShadow>[
                                    BoxShadow(
                                        color: Colors.black54,
                                        blurRadius: 5.0,
                                        offset: Offset(0.0, 0.75)
                                    )
                                  ],
                                ),
                                child: CustomText(text:'${widget.meeting?.meetingEndDate}',color: Theme.of(context).iconTheme.color,fontSize: 14.0),
                              ),
                            ),
                          ],
                        ),
                        ContainerLabelWithBoxShadow(text: 'More Information',),
                        ContainerLabelWithBoxShadow(text: '${widget.meeting?.meetingMediaName}' ?? 'No Meeting MediaName',),
                      ],
                    ),
                  ),
                  SizedBox(width: 15.0,),
                  Flexible(
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          margin: EdgeInsets.all(10.0),
                          padding: EdgeInsets.all(15.0),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: <BoxShadow>[
                              BoxShadow(
                                  color: Colors.black54,
                                  blurRadius: 5.0,
                                  offset: Offset(0.0, 0.75)
                              )
                            ],
                              border: Border.all(
                                  color: Colors.black12),
                              borderRadius:
                              const BorderRadius.all(Radius.circular(20)),
                          ),
                          child: Center(child: CustomText(text:'Agendas',color: Theme.of(context).iconTheme.color ,fontWeight: FontWeight.bold,fontSize: 18.0),),
                        ),
                        listOfAgenda(context ,widget.meeting)
                      ],
                    ),
                  ),
                  // listOfAgenda(context ,meeting)
                ],
              ),
          ),

      ),
    );
  }

  Widget listOfAgenda(BuildContext context , Meeting meeting){
    final meetingsAgendas = meeting?.agendas?.map((agenda) {
      return  ListView(
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        children:[
          Container(
            margin: EdgeInsets.all(5.0),
            padding: EdgeInsets.all(15.0),
            decoration: BoxDecoration(
                color: Colors.white,
              boxShadow: <BoxShadow>[
                BoxShadow(
                    color: Colors.black54,
                    blurRadius: 5.0,
                    offset: Offset(0.0, 0.75)
                )
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: CustomText(text: '${agenda!.agendaTitle}',color: Theme.of(context).iconTheme.color,fontSize: 14.0)),
                Expanded(child: CustomText(text: '${agenda!.agendaDescription}',color: Theme.of(context).iconTheme.color,fontSize: 14.0)),
                Expanded(child: CustomText(text: '${agenda.agendaTime}',color: Theme.of(context).iconTheme.color,fontSize: 14.0)),
                Expanded(child: CustomText(text: '${agenda.presenter}',color: Theme.of(context).iconTheme.color,fontSize: 14.0)),
                if(agenda!.agendaFileFullPath != null)    Expanded(child: ElevatedButton.icon(
                    onPressed: () async {
                      final String filePath = '${AppUri.baseUri}/${agenda.agendaFileFullPath}';
                      setState(() {
                        pathPDF = filePath;
                      });
                      try {
                        if(await PDFApi.requestPermission()){
                          final String filePath = '${AppUri.baseUri}/${agenda.agendaFileFullPath}';
                          // print(filePath); 'https://diligov.com/public/charters/1/full_stack_developer_mohamed_fadol.pdf'
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          LaboratoryFileProcessing(path: 'https://diligov.com/public/charters/1/full_stack_developer_mohamed_fadol.pdf',agendaId: agenda.agendaId!)));
                      } else {
                        print("Lacking permissions to access the file in preparePdfFileFromNetwork function");
                      return;
                      }
                      } catch (e) { print("Error preparePdfFileFromNetwork function PDF: $e"); }
                    },
                    icon: Icon(Icons.picture_as_pdf),
                      label: Text('view')
                    )
                ),
              ],
            ),
          )
        ]
        );
    }).toList();
    return Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [...?meetingsAgendas ]
    );

  }
}
