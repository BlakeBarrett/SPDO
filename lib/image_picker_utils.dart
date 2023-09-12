import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class ImagePickerUtils {
  static final ImagePicker _picker = ImagePicker();

  static Future<Directory> _getDirectory() async {
    return await getApplicationSupportDirectory();
  }

  static Future<File?> _getImageFile() async {
    var directory = await _getDirectory();
    if (!directory.existsSync()) {
      return null;
    }
    try {
      return File(directory.path);
      // var list = directory.listSync();
      // if (list.isEmpty) {
      //   return null;
      // } else {
      //   return File(list.first.path);
      // }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return null;
    }
  }

  static Future<Image?> getImage(context) async {
    var size = MediaQuery.of(context).size;
    var imageFile = await _getImageFile();
    var exists = await imageFile?.exists() ?? false;
    if (exists && imageFile != null) {
      return Image.file(
        imageFile,
        fit: BoxFit.cover,
        width: size.width,
        height: size.height,
      );
    } else {
      return null;
    }
  }

  static void clearImage() => _getDirectory().then((value) {
        value.listSync().forEach((element) {
          element.delete();
        });
      });

  static Future<bool> browseForImage() async {
    var image = await _picker.pickImage(source: ImageSource.gallery);
    // user cancelled
    if (image == null) {
      return false;
    }
    Directory directory = await _getDirectory();
    String path = '${directory.path}/${image.name}';
    image.saveTo(path);
    return true;
  }
}
