import 'dart:typed_data';
import 'dart:convert';
//import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'firebase_options.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.initializeFirebase();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage> {
  Uint8List? _pickedImage;
  String _ocrResult = "";
  bool isLoading = false;

  void startLoading() {
    setState(() {
      isLoading = true;
    });
  }

  void endLoading() {
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _pickImage() async {
    Uint8List? imageBytes = await ImagePickerWeb.getImageAsBytes();
    if (imageBytes != null) {
      setState(() {
        _pickedImage = imageBytes;
        _ocrResult = ""; // リセット
      });
    }
  }

  Future<void> _sendImage() async {
    if (_pickedImage != null) {
      String base64Image = base64Encode(_pickedImage!);
      Uri url = Uri.parse('http://127.0.0.1:5000/trimming');
      String body = json.encode({
        'post_img': base64Image,
      });

      startLoading();

      try {
        Response response = await http.post(url, body: body);

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          setState(() {
            _ocrResult = data['ocr_result'];
          });
        } else {
          print('エラー: ${response.statusCode}');
        }

        //final data = json.decode(response.body);
        //String imageBase64 = data['result'];
        //Uint8List bytes = base64Decode(imageBase64);

        // setState(() {
        //   _ocrResult = data['ocr_result'];
        // });

      } catch (e) {
        print('Error: $e');
      }

      endLoading();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OCR App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _pickedImage == null
                ? Container(
                    width: 400,
                    height: 300,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  )
                : Container(
                    width: 400,
                    height: 300,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Image.memory(
                      _pickedImage!,
                    ),
                  ),
            const SizedBox(height: 10),
            _ocrResult.isEmpty
                ? Container(
                    width: 400,
                    height: 300,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator()
                        : const Center(child: SizedBox()),
                  )
                : Container(
                    width: 400,
                    height: 300,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        'OCR Result: $_ocrResult',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('写真選択'),
            ),
            ElevatedButton(
              onPressed: _sendImage,
              child: const Text('OCR実行'),
            ),
          ],
        ),
      ),
    );
  }
}

// class _MyHomePageState extends State<MyHomePage> {
//   Uint8List? _pickedImage;
//   String _ocrResult = ""; //
//   bool isLoading = false;

//   void startLoading() {
//     setState(() {
//       isLoading = true;
//     });
//   }

//   void endLoading() {
//     setState(() {
//       isLoading = false;
//     });
//   }

//   Future<void> _pickImage() async {
//     // Use your custom method to get image bytes
//     Uint8List? imageBytes = await ImagePickerWeb.getImageAsBytes();
//     //Uint8List? imageBytes = await getImageAsBytes();
//     if (imageBytes != null) {
//       setState(() {
//         _pickedImage = imageBytes;
//         _ocrResult = ""; //
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('機械学習'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             _pickedImage == null
//                 ? Container(
//                     width: 400,
//                     height: 300,
//                     decoration: BoxDecoration(
//                       color: Colors.grey,
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   )
//                 : Container(
//                     width: 400,
//                     height: 300,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: Image.memory(
//                       _pickedImage!,
//                     ),
//                   ),
//             const SizedBox(height: 10),
//             _predictedImage == null
//                 ? Container(
//                     width: 400,
//                     height: 300,
//                     decoration: BoxDecoration(
//                       color: Colors.grey,
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: isLoading
//                         ? const CircularProgressIndicator()
//                         : const Center(child: SizedBox()),
//                   )
//                 : Container(
//                     width: 400,
//                     height: 300,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: Image(image: _predictedImage!.image),
//                   ),
//             ElevatedButton(
//               onPressed: _pickImage,
//               child: const Text('選ぶ'),
//             ),
//             ElevatedButton(
//               onPressed: () async {
//                 startLoading();
//                 if (_pickedImage != null) {
//                   String base64Image = base64Encode(_pickedImage!);
//                   Uri url = Uri.parse('http://127.0.0.1:5000/trimming');
//                   String body = json.encode({
//                     'post_img': base64Image,
//                   });

//                   Response response = await http.post(url, body: body);

//                   final data = json.decode(response.body);
//                   String imageBase64 = data['result'];
//                   Uint8List bytes = base64Decode(imageBase64);
//                   Image image = Image.memory(bytes);
//                   setState(() {
//                     _predictedImage = image;
//                   });
//                 }

//                 endLoading();
//               },
//               child: const Text('送る'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

