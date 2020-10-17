import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:tflite/tflite.dart';

// import 'open_camera.dart';
import 'dart:math' as math;
import 'camera.dart';
import 'bndbox.dart';


class HomePage extends StatefulWidget {
  final List<CameraDescription> cameras;

  HomePage(this.cameras);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<dynamic> _recognitions;
  int _imageHeight = 0;
  int _imageWidth = 0;
  String _model = "";
  bool blur = false;

  File imageURI;
  String result;
  String path;
  final picker = ImagePicker();

  List _outputs;
  File _image;
  bool _loading = false;

  @override
  void initState() { 
    super.initState();
    _loading = true;

    loadModel().then((value) {
      setState(() {
        _loading = false;
      });
    });
  }

  loadModel() async {
    await Tflite.loadModel(
      model: "assets/model.tflite", 
      labels: "assets/labels.txt"
    );
  }

  setModel(String model) {
    setState(() {
      _model = model;
    });
  }

  setRecognitions(recognitions, imageHeight, imageWidth) {
    setState(() {
      _recognitions = recognitions;
      _imageHeight = imageHeight;
      _imageWidth = imageWidth;
    });
    print(_recognitions);
    if(_recognitions[0]['label'] == "Pornography"){
      setState(() {
        blur = true;
      });
    } else {
      setState(() {
        blur = false;
      });
    }
  }

  // Future getImageFromGallery() async {
  //   // final image = await ImagePicker.getImage(source: ImageSource.gallery);
  //   var pickedFile = await picker.getImage(source: ImageSource.gallery);
  //   setState(() {
  //     imageURI = File(pickedFile.path);
  //     path = pickedFile.path;
  //   });
  //   classifyImage();
  // }

  // Future classifyImage() async {
    
  //   var output = await Tflite.runModelOnImage(path: path);
  //   setState(() {
  //     result = output.toString();
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("Pornography Detection")),
      ),
      body: _model == ""
        ? _loading
          ? Container(
            alignment: Alignment.center,
            child: CircularProgressIndicator(),
          )
          : SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 70, horizontal: 20),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _image == null
                    ? Text("No Image Selected")
                    : _outputs[0]['label'] == 'Pornography'
                      ? Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: FileImage(_image),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(
                            sigmaX: 5,
                            sigmaY: 5
                          ),
                          child: Container(
                            color: Colors.black.withOpacity(0),
                          ),
                        ),
                      )
                      : Image.file(_image, width: 300, height: 300, fit: BoxFit.cover,),
                  SizedBox(height: 4,),
                  _outputs == null
                    ? Container()
                    : Text("${_outputs[0]['label']}", style: TextStyle(fontSize: 24),),
                  Image.asset("assets/images/logo_sea.png", width: 180, height: 180,),
                  SizedBox(height: 20,),
                  ButtonTheme(
                    minWidth: 160,
                    height: 50,
                    child: RaisedButton( 
                      onPressed: () => setModel("SSDMobileNet"),
                      color: Colors.red,
                      child: Text("Live Camera", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6)
                      ),
                    ),
                  ),
                  SizedBox(height: 20,),
                  ButtonTheme(
                    minWidth: 160,
                    height: 50,
                    child: RaisedButton( 
                      onPressed: () => takePicture(),
                      color: Colors.red,
                      child: Text("Take Picture", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6)
                      ),
                    ),
                  ),
                  SizedBox(height: 20,),
                  ButtonTheme(
                    minWidth: 160,
                    height: 50,
                    child: RaisedButton( 
                      onPressed: () => pickImage(),
                      color: Colors.red,
                      child: Text("Upload Image", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6)
                      ),
                    ),
                  ),
                  SizedBox(height: 100,),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Credit By", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
                        SizedBox(height: 4,),
                        Text("VIN - Elvin Nur F (Machine Learning Developer)", style: TextStyle(fontSize: 16)),
                        SizedBox(height: 4,),
                        Text("PAL - Muhamad Naufal S. B (Android Developer)", style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        )
      : Stack(
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
          blur == true
          ? Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 5,
                  sigmaY: 5
                ),
                child: Container(
                  color: Colors.black.withOpacity(0),
                ),
              ),
            )
          : Container(),
        ],
      ),
    );
  }

  takePicture() async {
    final image = await ImagePicker().getImage(source: ImageSource.camera);
    if(image == null) return null;
    setState(() {
      _loading = false;
      _image = File(image.path);
    });
    classifyImage(File(image.path));
  }

  pickImage() async {
    final image = await ImagePicker().getImage(source: ImageSource.gallery);
    if (image == null) return null;
    setState(() {
      _loading = true;
      _image = File(image.path);
    });
    classifyImage(File(image.path));
  }

  classifyImage(File image) async {
    var output = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 2,
      threshold: 0.5,
      imageMean: 127.5,
      imageStd: 127.5
    );
    print(output);
    setState(() {
      _loading = false;
      _outputs = output;
    });
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }
}