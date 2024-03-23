import 'package:diligov/models/searchable.dart';
import 'package:diligov/providers/global_search_provider.dart';
import 'package:diligov/widgets/custom_icon.dart';
import 'package:diligov/widgets/custome_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:provider/provider.dart';
import '../utility/preview_pdf_file_for_searchable_text.dart';
class GlobalSearchBox extends StatelessWidget {
  const GlobalSearchBox({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final globalSearchProvider = Provider.of<GlobalSearchProvider>(context);

    return SizedBox(
      height: 50,
      child: CupertinoTypeAheadField<SearchableModel?>(
        debounceDuration: const Duration(microseconds: 500),
        builder: (context, controller, focusNode) {
          print("iam context:  ${controller.text}");
          return TextField(
            // controller: globalSearchProvider.controller,
            focusNode: focusNode,
            controller: controller,
              decoration: InputDecoration(
                  hintStyle: TextStyle(fontSize: 14,color: Colors.grey[600],fontWeight: FontWeight.bold),
                  hintText: "Looking For Some Words!!",
                  prefixIcon: Consumer<GlobalSearchProvider>(
                    builder: (context, provider, child) {
                      return IconButton(
                        icon: provider.icon,
                        onPressed: () {
                          if (provider.controller.text.isNotEmpty) {
                            provider.clearText();
                          }
                          // Add additional logic if necessary, e.g., for search functionality
                        },
                      );
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30))
                  )
              ),
          );
        },
          loadingBuilder: (context) =>  Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
            child: CustomText(text:'Looking for searching ...', color: Colors.green,fontSize: 20.0,),
          ),
          suggestionsCallback: GlobalSearchProvider.extractTextsWithinAllFilesDocuments,
          itemBuilder: (context, SearchableModel? suggestion){
            final committee = suggestion!;
            String segment = committee.findSegmentAfterPrefix(committee.fileDir!,"https://diligov.com/public/charters");
            var fileSearched =  segment.replaceAll('_', ' ');
            return Container(
              color: Colors.grey[300],
              child: ListTile(
                leading: CustomIcon(icon: Icons.file_open, color: Colors.grey,),
                title: CustomText(text:fileSearched, fontWeight: FontWeight.bold,fontSize: 15,),
                trailing: Container(
                    padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                        color: Colors.greenAccent[100],
                        borderRadius: BorderRadius.all(Radius.circular(50.0))
                    ),
                    child: CustomText(text:'${committee.textCount.toString()} ${committee.textString}',
                      fontWeight: FontWeight.bold,color: Colors.red,fontSize: 15.0,)),
              ),
            );
          },
          emptyBuilder: (context) =>  SizedBox(
            height: 60,
            child: Center(
              child: CustomText(text: 'No Things Found', fontSize: 18, color: Colors.red,),
            ),
          ),
        itemSeparatorBuilder: (BuildContext context, int i){
          return buildStaticDividerSizeBox(Colors.white10);
        },
        onSelected: (SearchableModel? suggestion){
          final committee = suggestion!;
          print(committee?.textString ?? 'not ttttttt');
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => PreviewPdfFileForSearchableText(file: committee.fileDir!, fileName: '12.pdf',searchText: committee!.textString!)),
          );

          // ScaffoldMessenger.of(context)
          //   ..removeCurrentSnackBar()
          //     ..showSnackBar(SnackBar(
          //       content: CustomText(text:committee.fileDir!),
          //     ),
          //   );
      },
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
