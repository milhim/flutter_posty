import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:posty/core/network/data_loader.dart';
import 'package:posty/models/shared_class.dart';
import 'package:posty/models/uploded_post_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:mime/mime.dart';
import 'package:posty/pages/home_page.dart';
import 'package:posty/widgets/error_page.dart';
import 'package:video_player/video_player.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class AddNewPostPage extends StatefulWidget {
  const AddNewPostPage({super.key});

  @override
  State<AddNewPostPage> createState() => _AddNewPostPageState();
}

class _AddNewPostPageState extends State<AddNewPostPage> {
  final TextEditingController _contentController = TextEditingController();
  List<String> selectedImages = [];
  List<String> selectedVideos = [];
  List<PlatformFile>? pickedImages = [];
  List<PlatformFile>? pickedVideos = [];
  UploadTask? _uploadTask;
  bool _isLoading = false;

  List<Map<String, dynamic>> _mediaToUpload = [];

  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: _isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Add New Post'),
          centerTitle: true,
        ),
        body: Container(
          padding: EdgeInsets.all(10),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _contentController,
                    decoration: const InputDecoration(
                      labelText: 'Text Content',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                    validator: (value) {
                      if (pickedImages!.isNotEmpty ||
                          pickedVideos!.isNotEmpty) {
                        log('1');

                        return null;
                      } else if (value!.isEmpty) {
                        log('2');

                        return 'Post content is required';
                      }
                      log('3');

                      return null;
                    },
                    minLines: 1,
                    maxLines: 6,
                  ),
                  ElevatedButton(
                    onPressed: _selectImage,
                    child: Text('Select Images'),
                  ),
                  SizedBox(height: 8.0),
                  ElevatedButton(
                    onPressed: _selectVideo,
                    child: Text('Select Videos'),
                  ),
                  SizedBox(height: 8.0),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        if (pickedImages != null) {
                          // pickedImages!.forEach((element) async {
                          //   await _uploadFiles(element);
                          // });
                          await Future.wait(pickedImages!
                              .map((element) => _uploadFiles(element)));

                          pickedImages!.clear();
                          selectedImages.clear();
                        }
                        if (pickedVideos != null) {
                          // pickedVideos!.forEach((element) async {
                          //   await _uploadFiles(element);
                          // });
                          await Future.wait(pickedVideos!
                              .map((element) => _uploadFiles(element)));

                          pickedVideos!.clear();
                          selectedVideos.clear();
                        }

                        await sendData();
                      }
                    },
                    child: Text('Submit Post'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future _selectImage() async {
    final result = await FilePicker.platform
        .pickFiles(allowMultiple: true, type: FileType.image);

    setState(() {
      pickedImages = result?.files;
    });
  }

  Future _selectVideo() async {
    final result = await FilePicker.platform
        .pickFiles(allowMultiple: true, type: FileType.video);

    setState(() {
      pickedVideos = result?.files;
    });
  }

  Future _uploadFiles(PlatformFile? pickedFile) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final path = 'files/${pickedFile!.name}';
      final file = File(pickedFile.path!);

      final ref = FirebaseStorage.instance.ref().child(path);
      _uploadTask = ref.putFile(file);

      final snapshot = await _uploadTask!.whenComplete(() {});

      final downloadURl = await snapshot.ref.getDownloadURL();
      final mimeType = lookupMimeType(pickedFile.name);

      String mediaType = _getMediaType(mimeType);

      if (mediaType == 'video') {
        final videoController =
            VideoPlayerController.file(File(pickedFile.path!));

        await videoController.initialize();
        final videoWidth = videoController.value.size.width.toInt();
        final videoHeight = videoController.value.size.height.toInt();

        videoController.dispose();

        final media = {
          "src_url": downloadURl,
          "src_thum": "",
          "src_icon": "",
          "media_type": mediaType,
          "mime_type": mimeType,
          "fullPath": snapshot.ref.fullPath,
          "width": videoWidth,
          "height": videoHeight,
          "size": pickedFile.size
        };
        _mediaToUpload.add(media);
        selectedVideos.add(downloadURl);
        log('From Videos : ${media.toString()}');
      } else if (mediaType == 'image') {
        final media = {
          "src_url": downloadURl,
          "src_thum": "",
          "src_icon": "",
          "media_type": mediaType,
          "mime_type": mimeType,
          "fullPath": snapshot.ref.fullPath,
          "width": 400,
          "height": 400,
          "size": pickedFile.size
        };
        _mediaToUpload.add(media);
        selectedImages.add(downloadURl);
        log('From Images : ${media.toString()}');
      }
    } catch (e) {
      log(e.toString());
    }

    setState(() {
      _isLoading = false;
    });
  }

  String _getMediaType(String? mimeType) {
    String mediaType; //store media type
    if (mimeType != null) {
      if (mimeType.startsWith('image')) {
        mediaType = 'image';
      } else if (mimeType.startsWith('video')) {
        mediaType = 'video';
      } else {
        mediaType = 'other';
      }
    } else {
      mediaType = 'unknown';
    }
    return mediaType;
  }

  Future<void> sendData() async {
    setState(() {
      _isLoading = true;
    });
    final Map<String, dynamic> jsonData = {
      "content": _contentController.text,
      "media": _mediaToUpload,
      "friends_ids": []
    };

    final response = await DataLoader.postRequest(
      url: DataLoader.addNewPostURL,
      body: jsonData,
    );

    if (response.code == '1') {
      _mediaToUpload.clear();
      setState(() {
        _isLoading = false;
      });
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(),
          ),
          (route) => false);
      print("Data sent successfully!");
    } else {
      setState(() {
        _isLoading = false;
      });
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Icon(Icons.error,
                size: MediaQuery.of(context).size.height / 4,
                color: Colors.red),
            content: Text(response.message),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      print("Failed to send data: ${response.code}");
    }
  }
}
