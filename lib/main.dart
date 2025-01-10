import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class ImageClassifier extends StatefulWidget {
  @override
  _ImageClassifierState createState() => _ImageClassifierState();
}

class _ImageClassifierState extends State<ImageClassifier> {
  File? _image;
  List? _output;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    loadModel().then((value) {
      setState(() {
        _loading = false;
      });
    });
  }

  Future<void> loadModel() async {
    await Tflite.loadModel(
      model: "assets/model.tflite",
      labels: "assets/labels.txt",
    );
  }

  void classifyImage(File image) async {
    var output = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 5,
      threshold: 0.5,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    setState(() {
      _output = output;
    });
  }

  Future<void> pickImage() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage == null) return;

    setState(() {
      _image = File(pickedImage.path);
      _loading = true;
    });
    classifyImage(_image!);
    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fashion MNIST Classifier'),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _image == null
                    ? Text('No image selected.')
                    : Image.file(_image!),
                SizedBox(height: 20),
                _output != null
                    ? Text(
                        'Prediction: ${_output![0]["label"]}\nConfidence: ${(_output![0]["confidence"] * 100).toStringAsFixed(2)}%',
                        style: TextStyle(fontSize: 16),
                      )
                    : Container(),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: pickImage,
                  child: Text('Pick an Image'),
                ),
              ],
            ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: ImageClassifier()));
}