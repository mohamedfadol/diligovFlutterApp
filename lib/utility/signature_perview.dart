import 'dart:typed_data';
import 'dart:async';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
class SignaturePerview extends StatelessWidget {
  final Uint8List signature;
  const SignaturePerview({Key? key, required this.signature}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.black,
    appBar: AppBar(
      title: const Text('Save Signature'),
      actions: [
        IconButton(onPressed: ()=> storeSignature(context),
            icon: const Icon(Icons.done)
        ),
        const SizedBox(width: 10,),
      ],
    ),
    body: Center(
      child: Image.memory(signature),
    ),
  );

  Future storeSignature(BuildContext context)async{
    final status = await Permission.storage.status;
    if(!status.isGranted){
      await Permission.storage.request();
    }

    final time = DateTime.now().toIso8601String().replaceAll('.', ':');
    final name = 'signature_$time.png';
    final result = await ImageGallerySaver.saveImage(signature, name: name);
    final isSuccess = result['isSuccess'];
    if(isSuccess){
      Navigator.pop(context);
      Flushbar(
        title: "Signature Successfully",
        message: "Signature has been Successfully In Folder",
        duration: Duration(seconds: 6),
        backgroundColor: Colors.greenAccent,
        titleColor: Colors.white,
        messageColor: Colors.white,
      ).show(context);
    }else{
      Flushbar(
        title: "Signature Failed",
        message: "Signature has been Failed Store In Folder",
        duration: Duration(seconds: 6),
        backgroundColor: Colors.red,
        titleColor: Colors.white,
        messageColor: Colors.white,
      ).show(context);
    }

  }
}
