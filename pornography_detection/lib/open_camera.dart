import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite/tflite.dart';
import 'dart:math' as math;
import 'camera.dart';
import 'bndbox.dart';

class OpenCamera extends StatefulWidget {

  final List<CameraDescription> cameras;

  OpenCamera(this.cameras);

  @override
  _OpenCameraState createState() => _OpenCameraState();
}

class _OpenCameraState extends State<OpenCamera> {

  List<dynamic> _recognitions;
  int _imageHeight = 0;
  int _imageWidth = 0;

  @override
  void initState() { 
    super.initState();
    loadModel();
  }

  loadModel() async {
    await Tflite.loadModel(
      model: "assets/model.tflite", 
      labels: "assets/labels.txt"
    );
  }

  setRecognitions(recognitions, imageHeight, imageWidth) {
    setState(() {
      _recognitions = recognitions;
      _imageHeight = imageHeight;
      _imageWidth = imageWidth;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          Camera(
            widget.cameras,
            setRecognitions,
          ),
          BndBox(
            _recognitions == null ? [] : _recognitions,
            math.max(_imageHeight, _imageWidth),
            math.min(_imageHeight, _imageWidth),
            screen.height,
            screen.width,
          ),
        ],
      ),
    );
  }
}