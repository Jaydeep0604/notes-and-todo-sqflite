import 'dart:io';
import 'package:flutter/material.dart';
import 'package:notes_sqflite/utils/app_colors.dart';
import 'package:notes_sqflite/utils/app_message.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_manager/photo_manager.dart';

class ImageViewScreen extends StatefulWidget {
  ImageViewScreen({
    super.key,
    required this.path,
  });
  String path;

  @override
  State<ImageViewScreen> createState() => _ImageViewScreenState();
}

class _ImageViewScreenState extends State<ImageViewScreen> {
  void saveImageToGallery() async {
    final result = await PhotoManager.editor
        .saveImageWithPath(widget.path, title: "demoimage");
    if (result != null) {
      print('Image added to Photos library.');
      AppMessage.showToast(context, "Image Saved Successfully");
    } else {
      print('Failed to add image to Photos library.');
      AppMessage.showToast(context, "Failed to Save Image");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
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
            color: AppColors.whiteColor,
            icon: Icon(
              Icons.more_vert,
              color: AppColors.whiteColor,
            ),
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  height: 30,
                  onTap: () {
                    saveImageToGallery();
                  },
                  child: Text(
                    "Save image",
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontSize: 14,
                          color: AppColors.blackColor,
                        ),
                  ),
                )
              ];
            },
          )
        ],
      ),
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: PhotoView(
          imageProvider: FileImage(
            File(widget.path),
          ),
        ),
      )),
    );
  }
}
