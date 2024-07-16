import 'package:camera/camera.dart';
import 'package:cancer_app/widget/loader.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';



class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  late final CameraController _cameraController;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        alignment: Alignment.center,
        children: [
          //assetImage('background'),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 15.0),
                Expanded(
                  child: FutureBuilder(
                    future: startCamera(),
                    builder: (context, AsyncSnapshot<bool> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Loader();
                      }
                      if (snapshot.hasData && snapshot.data!) {
                        return DottedBorder(
                          strokeCap: StrokeCap.square,
                          strokeWidth: 5.0,
                          borderType: BorderType.RRect,
                          dashPattern: [8, 4],
                          color: Colors.black,
                          child: CameraPreview(_cameraController),
                        );
                      }
                       return const Text('Camera not available');
                    },
                  ),
                ),
                const SizedBox(height: 15.0),
              //   ElevatedButton(
              //     onPressed: () {
              //      _cameraController.takePicture().then((value) => null);
              //        },
              //    child: Text('Take picture'),
              // ) 
                        Padding(
                      padding: const EdgeInsets.all(10.0),
            child: ElevatedButton(
              onPressed: () async => detectImage(await ImagePicker().pickImage(source: ImageSource.gallery)),
              child: Text('Gallery'),
            ),
),
              
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> startCamera() async {
    final cameraStatus = await Permission.camera.request();
    if (cameraStatus == PermissionStatus.granted) {
      final cameras = await availableCameras();
      _cameraController = CameraController(
        cameras[0],
        ResolutionPreset.high,
      );
      await _cameraController.initialize();
      return true;
    }
    return false;
  }

   Future<File?> getImage(bool isCamera) async {
    try {
      final image = await ImagePicker().pickImage(
          source: isCamera ? ImageSource.camera : ImageSource.gallery);
      if (image != null) {
        return File(image.path);
      } else {
        return null;
      }
    } on Exception catch (_) {
      return null;
    }
  }

  detectImage(XFile? image) async {
    try {
      await Tflite.loadModel(
          model: 'assets/modals/model.tflite',);

      if (image != null) {
        Tflite.runModelOnImage(
          path: image.path,
          imageMean: 0.0,
          imageStd: 255.0,
          numResults: 2,
          threshold: 0.2,
          asynch: true,
        ).then((recognitions) {
          if (recognitions != null) {
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder: (context) => ResultScreen(
            //         recognitions.map((rec) => Disease.fromJson(rec)).toList()),
            //   ),
            // );
          }
        });
      }
    } on Exception catch (e) {
      print(e.toString());
    }
  }
}
