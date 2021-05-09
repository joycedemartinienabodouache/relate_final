import 'dart:io';
import 'dart:math';
import 'package:image/image.dart' as Im;
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_platform_interface/src/types/image_source.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:relate/enum/user_state.dart';

class Utils{
  static String getUsername(String email){
    return "link:${email.split('@')[0]}";
  }
/*
* split the user name in order to get the first initials of each of their name
* */
  static String getInitials(String name){
    List<String> nameSplit = name.split(" ");// split upon spaces and
                                              // store them in a list
    String fNameInitial = nameSplit[0][0];// retrieve the first letter of  the first name stored
    String lNameInitial = nameSplit[1][0];// retrieve the first letter of the last name stored

    return fNameInitial + lNameInitial ;//initials to be returned (2 characters)
  }

  static Future<File> pickImage({@required ImageSource source}) async{

    // ignore: deprecated_member_use
    File selectedImage = await ImagePicker.pickImage(source: source);
    return await compressImage(selectedImage);
  }

  static Future<File> compressImage(File imageToCompress) async{
    final tempDir = await getTemporaryDirectory();

    final path = tempDir.path;

    int rand = Random().nextInt(1000);

    Im.Image image = Im.decodeImage(imageToCompress.readAsBytesSync());
    Im.copyResize(image, width: 500, height: 500);

    return new File('$path/img_$rand.jpg')
      ..writeAsBytesSync(Im.encodeJpg(image, quality: 85));
  }

  static int stateToNum(UserState userState){
    switch(userState){
      case UserState.Offline:
        return 0;

      case UserState.Online:
        return 1;

        default:
          return 2;
    }
  }

  static numToState(int num){
    switch(num){
      case 0:
        return UserState.Offline;

      case 1:
        return UserState.Online;

      default:
        return UserState.Waiting;
    }
  }

  static String formatDateString(String dateString){
    DateTime dateTime = DateTime.parse(dateString);
    var formatter = DateFormat('dd/MM/yy');
    return formatter.format(dateTime);
  }

}