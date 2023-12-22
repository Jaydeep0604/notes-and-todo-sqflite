import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:notes_sqflite/language/localisation.dart';
import 'package:notes_sqflite/widget/theme_container.dart';

class ImageViewScreen extends StatefulWidget {
  ImageViewScreen({
    Key? key,
    required this.path,
  });

  final String path;

  @override
  _ImageViewScreenState createState() => _ImageViewScreenState();
}

class _ImageViewScreenState extends State<ImageViewScreen> {
  void saveImageToGallery() async {
    final result = await ImageGallerySaver.saveFile(widget.path);
    if (result['isSuccess']) {
      print('Image added to Photos library.');
    } else {
      print('Failed to add image to Photos library.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ThemedContainer(
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back, color: Colors.white),
          ),
          actions: [
            PopupMenuButton(
              color: Colors.white,
              icon: Icon(
                Icons.more_vert,
                color: Colors.white,
              ),
              itemBuilder: (context) {
                return [
                  PopupMenuItem(
                    height: 40,
                    onTap: () {
                      saveImageToGallery();
                    },
                    child: Text(
                      "${AppLocalization.of(context)?.getTranslatedValue('save_image')}",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ];
              },
            )
          ],
        ),
        body: InteractiveViewer(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Image.file(
                File(widget.path),filterQuality: FilterQuality.high,
              ),
            ),
          ),
        ),
      ),
    );
  }
}