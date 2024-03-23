import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
class SignatureView extends StatefulWidget {
  const SignatureView({Key? key}) : super(key: key);
  static const routeName = '/SignatureView';
  @override
  State<SignatureView> createState() => _SignatureViewState();
}

class _SignatureViewState extends State<SignatureView> {
  late SignatureController signController;
  @override
  void initState(){
    super.initState();
    signController = SignatureController(
      penColor: Colors.black,
      penStrokeWidth: 1,
    );
  }

  @override
  void dispose(){
    signController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Column(
      children: [
        Signature(
            controller: signController,
            backgroundColor: Colors.red,
          height: 200,
          width: 200,
        ),
        buildButton(context),
      ],
    ),
  );

  Widget buildButton(BuildContext context) => Container(
    color: Colors.black,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        buildSave(context),
        buildClear()
      ],
    ),
  );

  buildSave(BuildContext context) => IconButton(
      onPressed: () async{
        if(signController.isNotEmpty){
          final signature = await exportSignature();
        }
      },
      icon: const Icon(Icons.add, color: Colors.green,)
  );

  buildClear() => IconButton(
      onPressed: (){ signController.clear();},
      icon: const Icon(Icons.clear, color: Colors.green,)
  );

  Future<Uint8List?> exportSignature() async{
    final exportController = SignatureController(
      penStrokeWidth: 2,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
      points: signController.points,
    );
    final signature = await exportController.toPngBytes();
    exportController.dispose();
    return signature;

  }
}
