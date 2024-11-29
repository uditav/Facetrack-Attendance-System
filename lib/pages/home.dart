import 'dart:convert';
import 'package:flask_flutter_api/utils/httpFunction.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var response;
  var result = [];
  String url = 'http://10.0.2.2:5000/process_video';
  final btnStyle = ButtonStyle(
    backgroundColor: WidgetStateProperty.all<Color>(Colors.grey[300]!),
  );

  String videoNum = '1';

  String filePath = "";
  bool _selected = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          appBar: AppBar(
            title: const Text("Attendance using Face Recognition"),
            backgroundColor: Colors.deepPurple,
          ),
          body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _pickVideo,
                    style: btnStyle,
                    child: Text("SELECT VIDEO",
                      style: Theme
                          .of(context)
                          .textTheme
                          .labelLarge,
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  const Text(
                    'You have selected video:',
                  ),
                  Text(
                    '$_selected',
                     style: Theme
                        .of(context)
                        .textTheme
                        .headlineMedium,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                    onPressed: () async{
                      if(_selected){
                        response = await fetchData(videoNum, url);
                        var decodedVal = jsonDecode(response);
                        setState(()  {
                          result = decodedVal["present"];
                        });
                      }
                    },
                    style: btnStyle,
                    child: Text("FACE RECOGNITION",
                      style: Theme
                          .of(context)
                          .textTheme
                          .labelLarge,
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        result = [];
                      });
                    },
                    style: btnStyle,
                    child: Text("CLEAR",
                      style: Theme
                          .of(context)
                          .textTheme
                          .labelLarge,
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: result.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text('Roll Number: ${result[index]}'),
                        );
                      },
                    ),
                  ),
                ],
              )
          ),
        )
    );
  }

  void _pickVideo() async{
    final picker = ImagePicker();
    XFile? videoFile;
    try{
      videoFile = await picker.pickVideo(source: ImageSource.gallery);
      filePath = videoFile!.path;
    }
    catch(e){
      print("Error picking video: $e");
    }
    setState(() {
      if (filePath != null) {
        // Automatically upload the selected video
        _selected = true;
        print('video not null');
      } else {
        print('No file selected');
      }
    });
  }

}

