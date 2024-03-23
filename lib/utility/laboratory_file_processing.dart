import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:audioplayers/audioplayers.dart';
import 'package:diligov/models/agenda_model.dart';
import 'package:diligov/providers/note_page_provider.dart';
import 'package:diligov/utility/pdf_api.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../src/drawing_painter.dart';
import '../src/pdf_file_processing_class.dart';
import '../src/stroke.dart';
import '../src/text_annotation.dart';
import '../widgets/custome_text.dart';
import 'package:record/record.dart';

class LaboratoryFileProcessing extends StatefulWidget {
  final String path;
  final int agendaId;
  const LaboratoryFileProcessing({super.key, required this.path, required this.agendaId});

  @override
  State<LaboratoryFileProcessing> createState() => _LaboratoryFileProcessingState();
}

class _LaboratoryFileProcessingState extends State<LaboratoryFileProcessing> {

  final GlobalKey<ScaffoldState> _parentScaffoldKey = GlobalKey<ScaffoldState>();
  late AudioRecorder audioRecord;
  late AudioPlayer audioPlayer;
  bool isRecording = false;
  String audioPath = '';
  User user = User();
  var log = Logger();
  String localPath = "";
  List<Offset> points = [];
  List<Stroke> strokes = [];
  List<Stroke> undoStack = [];
  List<Stroke> redoStack = [];
  double currentPenWidth = 5.0;
  bool eraseMode = false;
  bool showTextInput = false;
  Offset textPosition = Offset.zero;
  int indexing = 0;
  int? totalPagesOfFile;
  String tempInputText = "";
  Offset? tempTextPosition;
  List<TextAnnotation> textAnnotations = [];
  double currentFontSize = 18.0; // Default font size
  Color selectedColor = Colors.black; // Default color
  Color iconColor = Colors.grey;
  bool _isDrawingEnabled = false;
  bool strokesStatus = false;
  bool isPrivate = true;
  List<Map<String, dynamic>> textList = [];
  final TextEditingController textEditingController = TextEditingController();
  late TextEditingController? _controller = TextEditingController();

  @override
  void initState() {
    audioPlayer = AudioPlayer();
    audioRecord = AudioRecorder();
    // Enforce portraitUp and portraitDown orientations
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    preparePdfFileFromNetwork();
    textEditingController.addListener(_handleTextChange);
    _controller!.addListener(_handleTextChange);
    super.initState();
  }

  @override
  void dispose() {
    audioRecord.dispose();
    audioPlayer.dispose();
    // Allow all orientations when the widget is disposed
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      // DeviceOrientation.landscapeLeft,
      // DeviceOrientation.landscapeRight,
    ]);
    textEditingController.removeListener(_handleTextChange);
    textEditingController.dispose();
    _controller!.removeListener(_handleEditTextChange);
    _controller!.dispose();
    super.dispose();
  }

  void _handleEditTextChange() {
    String text = _controller!.text;
    if (text.length > 25 && !text.contains('\n')) {
      // Find the last space before the 25th character
      int breakPoint = text.substring(0, 25).lastIndexOf(' ');
      if (breakPoint == -1) {
        breakPoint = 25; // If no space found, break at exactly 25 characters
      }
      String newText = '${text.substring(0, breakPoint)}\n${text.substring(breakPoint)}';
      _controller!.value = TextEditingValue(
        text: newText,
        selection: TextSelection.fromPosition(TextPosition(offset: breakPoint + 1)),
      );
    }
  }

  void _handleTextChange() {
    String text = textEditingController.text;
    if (text.length > 25 && !text.contains('\n')) {
      // Find the last space before the 25th character
      int breakPoint = text.substring(0, 25).lastIndexOf(' ');
      if (breakPoint == -1) {
        breakPoint = 25; // If no space found, break at exactly 25 characters
      }
      String newText = '${text.substring(0, breakPoint)}\n${text.substring(breakPoint)}';
      textEditingController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.fromPosition(TextPosition(offset: breakPoint + 1)),
      );
    }
  }

  void showPenSettingsDialog() {
    // Temporary variables to hold the slider value and selected color locally
    double tempPenWidth = currentPenWidth;
    Color tempSelectedColor = selectedColor;
    double tempFontSize = currentFontSize;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Adjust Pen Settings'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                // Pen Width Slider
                StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                    return Slider(
                      min: 10.0,
                      max: 36.0,
                      divisions: 26,
                      value: tempFontSize,
                      label: tempFontSize.round().toString(),
                      onChanged: (double value) {
                        setState(() {
                          tempPenWidth = value;
                          tempFontSize = value;
                        });
                      },
                    );
                  },
                ),
                // Color Picker
                StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                    // Build color picker as a row of color choices
                    List<Color> colors = [Colors.black, Colors.red, Colors.green, Colors.blue, Colors.yellow]; // Add more colors as needed
                    return Wrap(
                      spacing: 8.0, // Spacing between each color circle
                      children: colors.map((color) => GestureDetector(
                        onTap: () {
                          setState(() {
                            tempSelectedColor = color;
                          });
                        },
                        child: CircleAvatar(
                          backgroundColor: color,
                          child: tempSelectedColor == color ? const Icon(Icons.check, color: Colors.white) : null,
                        ),
                      )).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog without saving changes
              },
            ),
            TextButton(
              child: const Text('Done'),
              onPressed: () {
                // Update the main state with the new pen width and color
                setState(() {
                  currentFontSize = tempFontSize;
                  currentPenWidth = tempPenWidth;
                  selectedColor = tempSelectedColor;
                });
                Navigator.of(context).pop(); // Close the dialog and save changes
              },
            ),
          ],
        );
      },
    );
  }

  void _toggleDrawing() {
    setState(() {
      _isDrawingEnabled = !_isDrawingEnabled;
    });
  }

  // Optionally adjust the _erase method similarly if you're using it
  @override
  Offset _adjustOffset(Offset localPosition) {
    // Adjust the offset for the AppBar height and the status bar height
    double appBarHeight = AppBar().preferredSize.height;
    double statusBarHeight = MediaQuery.of(context).padding.top;

    return Offset(
        localPosition.dx,
        localPosition.dy - appBarHeight - statusBarHeight
    );
  }

  @override
  void _onPanStart(DragStartDetails details) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset localPosition = box.globalToLocal(details.globalPosition);
    final Offset adjustedPosition = _adjustOffset(localPosition);

    setState(() {
      strokes.add(Stroke(points: [adjustedPosition], paint: Paint()
        ..color = selectedColor
        ..strokeWidth = currentPenWidth
        ..style = PaintingStyle.stroke));
    });
  }

  @override
  void _onPanUpdate(DragUpdateDetails details) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset localPosition = box.globalToLocal(details.globalPosition);
    final Offset adjustedPosition = _adjustOffset(localPosition);
    setState(() {
      strokes.last.points.add(adjustedPosition);
    });
  }

  @override
  void _onPanEnd(DragEndDetails details) {
    // Optionally, add logic here if you need to finalize a stroke or handle it in a specific way
  }

  @override
  void _erase(DragUpdateDetails details) {
    if (eraseMode) {
      final RenderBox box = context.findRenderObject() as RenderBox;
      final Offset localPosition = box.globalToLocal(details.globalPosition);
      final Offset adjustedPosition = _adjustOffset(localPosition);

      setState(() {
        // Define an erase threshold (radius within which points will be erased)
        double eraseThreshold = 30.0; // Adjust based on your needs

        // Check each stroke to see if it contains points within the erase threshold of the adjustedPosition
        for (var stroke in strokes) {
          stroke.points.removeWhere((point) =>
          (point - adjustedPosition).distance <= eraseThreshold);
        }

        // Optionally, remove strokes that are completely erased (no points left)
        strokes.removeWhere((stroke) => stroke.points.isEmpty);
      });
    }
  }

  Widget buildColorPicker() {
    List<Color> colors = [Colors.black, Colors.red, Colors.green, Colors.blue, Colors.yellow]; // Add more colors as needed
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: colors.map((color) =>
          GestureDetector(
            onTap: () {
              setState(() {
                selectedColor = color;
                Navigator.of(context).pop();
              });
            },
            child: Column(
              children: [
                CircleAvatar(backgroundColor: color),
              ],
            ),
          )
      ).toList(),
    );
  }

  // Assuming textAnnotations is a List<TextAnnotation>
  int getNextAnnotationId() {
    if (textAnnotations.isNotEmpty) {
      return textAnnotations.map((a) => a.id).reduce(max) + 1;
    }
    return 1; // Start IDs from 1 if the list is empty
  }

  Widget buildTextInputField() {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                color: Colors.grey[300],
                child: IconButton(
                  icon: const Icon(Icons.check, color: Colors.green,), // Icon for saving the text
                  onPressed: () {
                    final newId = getNextAnnotationId();
                    setState(() {
                      // Create a new annotation with a unique ID
                      textAnnotations.add(
                          TextAnnotation(
                            position: tempTextPosition!,
                            text: textEditingController.text,
                            id: newId,
                            color: selectedColor,
                          )
                      );

                      textList.add({
                        "id": newId,
                        "text": textEditingController!.text,
                        "positionDx": tempTextPosition!.dx,
                        "positionDy": tempTextPosition!.dy,
                        "isPrivate": isPrivate,
                        "pageIndex": indexing
                      });
                      showTextInput = false; // Hide TextField after saving
                      textEditingController.clear(); // Clear text field for next input
                      tempTextPosition = null; // Reset position
                    });
                  },

                ),
              ),
              const SizedBox(width: 5.0,),
              Container(
                color: Colors.grey[300],
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.red,), // Icon for closing the text field
                  onPressed: () {
                    setState(() {
                      showTextInput = false;
                      tempTextPosition = null; // Reset to indicate no selected position
                    });
                  },
                ),
              ),
              const SizedBox(width: 5.0,),
              Container(
                color: Colors.grey[300],
                child: IconButton(
                  icon: const Icon(Icons.share, color: Colors.green,), // Icon for closing the text field
                  onPressed: () {
                    setState(() {
                      showTextInput = false;
                      tempTextPosition = null; // Reset to indicate no selected position
                    });
                  },
                ),
              ),
              const SizedBox(width: 5.0,),
              Container(
                color: Colors.grey[300],
                child: Tooltip(
                  message: isPrivate ? 'make public' : 'make private' ,
                  height: 40.0,
                  padding: EdgeInsets.all(10.0),
                  verticalOffset: 48,
                  preferBelow: false,
                  child: IconButton(
                      onPressed: () {
                        setState(() {
                          isPrivate = !isPrivate; // Toggle erase mode
                        });
                      },
                      icon: Icon( isPrivate ? Icons.visibility_off_outlined : Icons.remove_red_eye_outlined, color: iconColor,),
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 5.0,),
          Container(
            color: Colors.white,
            width: 200, // Adjust as needed
            child: TextField(
              style: TextStyle(color: selectedColor!),
              controller: textEditingController,
              maxLines: null,
              autofocus: true,
              onChanged: (value) => tempInputText = value,
              decoration: const InputDecoration(
                hintText: "Enter text",
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) {
                final newId = getNextAnnotationId();
                setState(() {
                  textAnnotations.add(
                      TextAnnotation(
                        position: tempTextPosition!,
                        text: value,
                        id: newId,
                        color: selectedColor,
                      )
                  );
                  textList.add({
                    "id": newId,
                    "text": value,
                    "positionDx": tempTextPosition!.dx,
                    "positionDy": tempTextPosition!.dy,
                    "isPrivate": isPrivate,
                    "pageIndex": indexing
                  });
                  showTextInput = false; // Hide TextField after submission
                  tempTextPosition = null; // Reset position for the next input
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  void updateTextListObjectById(List<Map<String, dynamic>> list, int id, Map<String, dynamic> newData) {
    // Find the object with the specified ID and update its properties
    list.forEach((element) {
      if (element["id"] == id) {
        newData.forEach((key, value) {
          if (element.containsKey(key)) {
            element[key] = value;
          }
        });
      }
    });
  }

  void showEditOptions(TextAnnotation annotation, {bool isNew = false}) {
    _controller = TextEditingController(text: annotation.text);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isNew ? 'Add Annotation' : 'Edit Annotation'),
          content: TextField(
            controller: _controller,
            maxLines: null,
            autofocus: true,
          ),
          actions: <Widget>[
            if (!isNew)
              TextButton(
                onPressed: () {
                  setState(() {
                    textAnnotations.removeWhere((a) => a.id == annotation.id); // Delete annotation
                    int indexToRemove = textList.indexWhere((item) => item['id'] == annotation.id);
                    if (indexToRemove != -1) {
                      textList.removeAt(indexToRemove);
                    }
                  });
                  Navigator.of(context).pop();
                },
                child: const Text('Delete'),
              ),
            TextButton(
              onPressed: () {
                setState(() {
                  if (isNew) {
                    // Add the new annotation
                    textAnnotations.add(TextAnnotation(
                      position: annotation.position,
                      text: _controller!.text,
                      id: annotation.id,
                      color: selectedColor,
                    ));
                    updateTextListObjectById(textList, annotation.id, {"text": _controller!.text, "pageIndex": indexing});
                  } else {
                    // Update existing annotation
                    annotation.text = _controller!.text;
                    updateTextListObjectById(textList, annotation.id, {"text": _controller!.text, "pageIndex": indexing});
                  }
                });
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> preparePdfFileFromNetwork() async {
    try {
      if(await PDFApi.requestPermission()){
          //'https://diligov.com/public/charters/1/logtah.pdf'; // Replace with your PDF URL
          final filePath = await PDFApi.loadNetwork(widget.path!);
          setState(() { localPath = filePath.path!;});
        } else {
              print("Lacking permissions to access the file in preparePdfFileFromNetwork function");
              return;
        }
    } catch (e) { print("Error preparePdfFileFromNetwork function PDF: $e"); }
  }

  Future<void> takeScreenshot() async {
    try {
          if(await PDFApi.requestPermission()){
              RenderRepaintBoundary boundary = _parentScaffoldKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
              ui.Image image = await boundary.toImage(pixelRatio: 3.0);
              ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
              Uint8List pngBytes = byteData!.buffer.asUint8List();
              // Save pngBytes to a file
              final directory = await getTemporaryDirectory();
              final fileCreateTime =  DateTime.now().millisecondsSinceEpoch;
              final imagePath = await File('${directory.path}/$fileCreateTime.png').create();
              await imagePath.writeAsBytes(pngBytes);
              final pdfFile = await PdfFileProcessingClass.ReplaceImageByIndexOfPageFromNetWorkPath(imagePath.path!, indexing, totalPagesOfFile!, widget.path!);

              await PDFApi.downloadFileToStorage(pdfFile!);
              // await PDFApi.openFile(pdfFile);

              final SharedPreferences prefs = await SharedPreferences.getInstance();
              user =  User.fromJson(json.decode(prefs.getString("user")!));
              Map<String, dynamic> data = {
                "ListDataOfNotes": textList,
                "fileEdited": widget.path,
                "businessId": user.businessId,
                "addby": user.userId,
                "agenda_id": widget.agendaId
              };
              final provider = Provider.of<NotePageProvider>(context,listen: false);
              Future.delayed(Duration.zero, () {
                provider.insertNewNote(data);
                provider.setIsBack(true);
              });

              if(provider.isBack == true) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: CustomText(text: AppLocalizations.of(context)!.agenda_add_successfully ),
                    backgroundColor: Colors.greenAccent,
                  ),
                );
                Future.delayed(const Duration(seconds: 10), () {
                  // Navigator.pushReplacementNamed(context, MinutesMeetingList.routeName);
                });
              }else{
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: CustomText(text: AppLocalizations.of(context)!.agenda_add_failed ),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              }
              print('done to open download file');
          } else {
            print("Lacking permissions to access the file.");
            return;
          }
    } catch (e) {
      print("Error catch taking screenshot function: $e");
    }
  }

  Future<void > startRecording() async{
    try{
        if(await audioRecord.hasPermission()){
          final status = await Permission.microphone.request();
          if(status != PermissionStatus.granted){
            print('Microphone permission');
          }else{
            final documentsDir = await getApplicationDocumentsDirectory();
            final fileCreateTime  =  DateTime.now().millisecondsSinceEpoch;
            final savedFilePath ='${documentsDir.path}/$fileCreateTime.mp3';
            await audioRecord.start(const RecordConfig(), path: savedFilePath);
            PDFApi.saveFileToDirectoryPath('$fileCreateTime.mp3', 'recordingNotes', 'This is a test file.');
            setState(() {isRecording = true;});
          }
      }
    }catch(e){
      print('Error Starting recording $e');
    }
  }

  Future<void > stopRecording() async{
      try{
        if(await audioRecord.hasPermission()){
           String ? path =  await audioRecord.stop();
           print(path!);
            setState(() {
              isRecording = false;
              audioPath = path!;
            });
          }
      }catch(e){ print('Error Starting recording $e'); }
  }

  Future<void > playRecording() async{
    try{
        Source urlSource = UrlSource(audioPath!);
        print('url Source $urlSource');
        await audioPlayer.play(urlSource);
    }catch(e){
      print('error playing problem $e');
    }
  }

  Widget BuildRecordControlling () {
   final icon = isRecording ? Icons.mic : Icons.stop;
   final text = isRecording ? 'Stop' : 'Start';
    return Row(
      children: [
        if(isRecording)
          const Text('recording ...' , style: TextStyle(fontSize: 15.0),),
        ElevatedButton.icon(
            onPressed: isRecording ? stopRecording : startRecording,
            icon: Icon(icon),
            label : isRecording ? Text(text) : Text(text)
        ),
        if(!isRecording && audioPath != null)
        IconButton(
            onPressed: playRecording,
            icon: Icon(Icons.play_arrow_sharp),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title:  Container(
          decoration: const BoxDecoration(
              border: Border.symmetric(
                  horizontal: BorderSide(width: 1.0, color: Colors.grey,),
                  vertical: BorderSide(width: 1.0, color: Colors.grey,)
              )
          ),
          padding: const EdgeInsets.only(right: 10.0),
          // color: Colors.grey,
          child: Row(
            children: [
              TextButton.icon(
                onPressed: _toggleDrawing,
                icon: Icon(
                  Icons.edit,
                  size: 24.0,
                  color: iconColor,
                ),
                label: const Text('Draw',style: TextStyle(fontSize: 20.0),),
              ),

              TextButton.icon(
                onPressed: showPenSettingsDialog,
                icon: Icon(
                  Icons.color_lens,
                  size: 24.0,
                  color: iconColor,
                ),
                label: const Text('Colors'),
              ),

              TextButton.icon(
                onPressed: () {
                  setState(() {
                    showTextInput = !showTextInput;
                  });
                },
                icon: Icon(
                  Icons.text_fields,
                  size: 24.0,
                  color: iconColor,
                ),
                label: const Text('Add Text'),
              ),

              TextButton.icon(
                onPressed: () {
                  setState(() {
                    eraseMode = !eraseMode; // Toggle erase mode
                  });
                },
                icon: Icon(
                  eraseMode ? Icons.brush : Icons.delete,
                  size: 24.0,
                  color: iconColor,
                ),
                label: const Text('Delete'),
              ),

              Spacer(),
              Tooltip(
                message: isPrivate ? 'make all public' : 'make all private' ,
                height: 40.0,
                padding: EdgeInsets.all(10.0),
                verticalOffset: 48,
                preferBelow: false,
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      isPrivate = !isPrivate; // Toggle erase mode
                    });
                  },
                  icon: Icon( isPrivate ? Icons.visibility_off_outlined : Icons.remove_red_eye_outlined, color: iconColor,),


                ),
              )
            ],
          ),
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: BuildRecordControlling (),
          )
        ],
      ),
      body: Form(
        child: RepaintBoundary(
          key: _parentScaffoldKey,
          child: localPath.isNotEmpty
              ? GestureDetector(
                    onTapDown: (TapDownDetails details) {
                        if (showTextInput) {
                          // Convert local position to global
                          final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
                          final globalPosition = overlay.globalToLocal(details.globalPosition);

                          // Adjust for AppBar height and SafeArea padding if necessary
                          final appBarHeight = Scaffold.of(context).appBarMaxHeight ?? 0;
                          final safePaddingTop = MediaQuery.of(context).padding.top;

                          setState(() {
                            tempTextPosition = globalPosition.translate(0, -(appBarHeight + safePaddingTop));
                            showTextInput = true; // Make sure this is true to show the TextField
                          });

                          // Create a temporary annotation for editing
                          final tempAnnotation = TextAnnotation(
                            position: tempTextPosition!,
                            text: "",
                            id: DateTime.now().millisecondsSinceEpoch, // Example for unique ID
                            color: selectedColor,
                          );

                          // Show edit options, allowing the user to input text
                          showEditOptions(tempAnnotation, isNew: true);

                        }
                    },
            child: SafeArea(
              child: Stack(
                children: [
                    //CustomPdfView(path: localPath),
                    PDFView(
                    fitEachPage: true,
                    filePath: localPath,
                    autoSpacing: true,
                    enableSwipe: true,
                    pageSnap: true,
                    swipeHorizontal: false,
                    nightMode: false,
                    onPageChanged: (int? currentPage, int? totalPages) {

                      print("Current page: $currentPage!, Total pages: $totalPages!");
                      // You can use this callback to keep track of the current page.
                      setState(() {
                        indexing = currentPage!;
                        totalPagesOfFile = totalPages!;
                      });
                      print(indexing);
                    },
                  ),

                    if (_isDrawingEnabled)
                        Builder(
                            builder: (context) {
                              return GestureDetector(
                                onPanStart: eraseMode ? null : _onPanStart,
                                onPanUpdate: eraseMode ? _erase : _onPanUpdate,
                                onPanEnd: eraseMode ? null : _onPanEnd,
                                onTapDown: (TapDownDetails details) {
                                  // Check if we're in text input mode
                                  if (showTextInput) {
                                    final RenderBox box = context.findRenderObject() as RenderBox;
                                    final Offset localPosition = box.globalToLocal(details.globalPosition);

                                    print("Global position: ${details.globalPosition}");
                                    print("Local position: $localPosition");
                                    setState(() {
                                      showTextInput = true;
                                      tempTextPosition = localPosition;

                                    });
                                  }
                                },
                                child: Builder(
                                    builder: (context) {
                                      return Container(
                                        color: Colors.transparent,
                                        width: MediaQuery.of(context).size.width,
                                        height: MediaQuery.of(context).size.height,
                                        child: CustomPaint(
                                          painter: DrawingPainter(strokes: strokes!),
                                          size: Size.infinite,
                                          child: const Icon(Icons.edit_note), // show icon in center widget file
                                        ),
                                      );
                                    }
                                ),
                              );
                            }
                        ),

                        // Inside your build method, where you're setting up the Stack for annotations
                        ...textAnnotations.map(
                              (annotation) => Positioned(
                                                left: annotation.position.dx,
                                                top: annotation.position.dy,
                                                child: Builder(
                                                    builder: (context) {
                                                      return GestureDetector(
                                                        onTap: () =>  showEditOptions(annotation),
                                                        child: Container(
                                                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2), // Small padding for easier tapping
                                                          color: Colors.yellow.withAlpha(100), // Semi-transparent background to visualize tapping area
                                                          child: Text(annotation.text, style: TextStyle(color: annotation.color, fontSize: 18)),
                                                        ),
                                                      );
                                                    }
                                                ),
                                              )
                        ),

                    // TextField for inputting text
                    if (showTextInput && tempTextPosition != null)
                        Positioned(
                          left: tempTextPosition!.dx,
                          top: tempTextPosition!.dy,
                          child: Builder(
                              builder: (context) {
                                return buildTextInputField();
                              }
                          ),
                        ),
                ],
              ),
            ),
          )
              : const Center(child: CircularProgressIndicator()),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async{
          // Adding a delay can sometimes help if the widget is not rendered yet
          Future.delayed(const Duration(milliseconds: 500), () async {
            takeScreenshot();
            print('PDF Path: $localPath');
            print("list text is  $textList");
          });
        },
        tooltip: 'Save File',
        child: const Icon(Icons.save),
      ),
    );
  }







}
