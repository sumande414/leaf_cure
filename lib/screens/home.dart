import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:tflite/tflite.dart';
import 'package:image_picker/image_picker.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  XFile? _image;
  List<dynamic>? _results = List.empty(growable: true);

  Future loadModel() async {
    String? res;
    res = await Tflite.loadModel(
      model: "assets/model.tflite",
      labels: "assets/labels.txt",
    );
    print(res);
  }

  Future imageClassification(XFile image) async {
    final List? results = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 6,
      threshold: 0.05,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    setState(() {
      results![0]['photo'] = File(image.path);
      (_results != null) ? _results!.add(results[0]) : _results = results;
    });
  }

  @override
  void initState() {
    loadModel();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Center(
              child: Image.asset('assets/icons/logo_text.png', height: 60)),
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
                onPressed: () async {
                  XFile? image = await ImagePicker()
                      .pickImage(source: ImageSource.gallery);
                  if (image != null) {
                    _image = image;
                    imageClassification(_image!);
                  }
                },
                child: const Icon(Icons.insert_photo_outlined)),
            SizedBox(
              width: 10,
            ),
            FloatingActionButton(
                onPressed: () async {
                  XFile? image =
                      await ImagePicker().pickImage(source: ImageSource.camera);
                  if (image != null) {
                    _image = image;
                    imageClassification(_image!);
                  }
                },
                child: const Icon(Icons.camera_alt_rounded)),
          ],
        ),
        body: (_results != null && _results!.isNotEmpty)
            ? ListView.builder(
                itemCount: _results!.length,
                itemBuilder: (context, index) => ListTile(
                      leading: Text((index + 1).toString()),
                      title: Text(
                        _results![index]['label'],
                      ),
                      trailing: Image.file(_results![index]['photo']),
                      titleTextStyle: TextStyle(color: Colors.white),
                    ))
            : null);
  }
}
