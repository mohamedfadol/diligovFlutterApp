import 'package:path/path.dart';

class SearchableData {
  List<SearchableModel>? files;
  SearchableData({this.files});
  SearchableData.fromJson(Map<String, dynamic> json) {
    if (json['files'] != null) {
      files = <SearchableModel>[];
      json['files'].forEach((v) {
        files!.add(new SearchableModel.fromJson(v));
      });
    }
  }
}

class SearchableModel {
  int? textCount;
  String? textString;
  String? fileDir;

  SearchableModel({
    this.textString,
    this.textCount,
    this.fileDir,});

  SearchableModel.fromJson(Map<String, dynamic> json) {
    textCount = json['count'];
    textString = json['search_text'];
    fileDir = json['url'];
  }

  // Function to find the segment following a specified path prefix
  String findSegmentAfterPrefix(String documentUri,String prefix) {
    // Normalize the prefix to ensure it does not end with a slash
    String normalizedPrefix = prefix.endsWith('/') ? prefix : '$prefix/';
    // Check if the URL contains the prefix
    if (documentUri!.contains(normalizedPrefix)) {
      // Extract the part of the URL after the prefix
      String afterPrefix = documentUri!.split(normalizedPrefix).last;
      // Find the first segment after the prefix
      List<String> segments = afterPrefix.split('/');
      // Return the first segment if available, otherwise an empty string
      return segments.isNotEmpty ? segments.first : '';
    }
    return ''; // Return an empty string if the prefix is not found
  }

}