import 'package:circle_progress_bar/circle_progress_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hasan_project/controller/video_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:provider/provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
class UploadVideoPage extends StatefulWidget {
  const UploadVideoPage({Key? key}) : super(key: key);

  @override
  State<UploadVideoPage> createState() => _UploadVideoPageState();
}

class _UploadVideoPageState extends State<UploadVideoPage> {
  late  VideoPlayerController _videoPlayerController;
  List<Map<String, dynamic>> _tabs = [
    //{"text": "all", "icon": null},
    {"text": "Music", "icon": Icons.music_note},
    {"text": "Games", "icon": Icons.sports_esports_rounded},
    {"text": "Food", "icon": Icons.fastfood},
    {"text": "Sport", "icon": Icons.sports_handball},
    {"text": "Learning", "icon": Icons.school},
  ];
  @override
  void initState() {
    _videoPlayerController = VideoPlayerController.asset('assets/video/1.mp4');
    super.initState();
  }

  loadVideoPlayer(String path) {
    _videoPlayerController = VideoPlayerController.asset(path);
    // _videoPlayerController.addListener(() {
    //   setState(() {});
    // });
    // _videoPlayerController.initialize().then((value) {
    //   setState(() {});
    // });
    return _videoPlayerController;
  }
  String? _thumbnailFile;
  String? category;
  XFile? cameraPicker;
  XFile? galleryPicker;
  XFile? picker;

  _pickVideoFromCamera() async {
    cameraPicker = await ImagePicker().pickVideo(source: ImageSource.camera);
    picker=cameraPicker;
    _videoPlayerController = loadVideoPlayer(cameraPicker!.path);

    setState(() {});
  }

  _pickVideoFromGallery() async {
    galleryPicker = await ImagePicker().pickVideo(source: ImageSource.gallery);
    picker=galleryPicker;
    _videoPlayerController = loadVideoPlayer(galleryPicker!.path);
    setState(() {});
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    VideoProvider  videoProvider=Provider.of<VideoProvider>(context );
    videoProvider.checkSend=false;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Video'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                  child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: ElevatedButton(
                        onPressed: _pickVideoFromGallery,
                        child: const ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text('From Gallery'),
                          trailing: Icon(Icons.videocam_rounded),
                        ),
                      )),
                      const SizedBox(
                        width: 10.0,
                      ),
                      Expanded(
                          child: ElevatedButton(
                        onPressed: _pickVideoFromCamera,
                        child: const ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text('From Camera'),
                          trailing: Icon(Icons.camera_alt),
                        ),
                      )),
                    ],
                  ),
                  Expanded(
                          child: AspectRatio(
                          aspectRatio: 10.0,
                          child: VideoPlayer(_videoPlayerController),
                        ))
                ],
              )),
              DropdownButtonFormField(

                  items: [
                    for (int i = 0; i < _tabs.length; i++)
                      DropdownMenuItem(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${_tabs[i]['text']}'),
                            Icon(_tabs[i]['icon'])
                          ],
                        ),
                        value: i,
                      )
                  ],
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Select Category'),
                  validator: (val) {
                    if (val == null) {
                     return 'This Filed Is Required';
                    }
                  },
                  onChanged: (val) {
                    category=_tabs[val!]['text'];
                    //print('${category}');
                  }),
              const SizedBox(
                height: 10.0,
              ),
    ChangeNotifierProvider<VideoProvider>.value(
    value: Provider.of<VideoProvider>(context),
    child: Consumer<VideoProvider>(
    builder: (context, value, child)=>
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 60.0)),
                  onPressed: () async {
                    if(!videoProvider.checkSend){
                      if (_formKey.currentState!.validate()&&picker!=null) {
                        videoProvider.checkSend=true;
                        videoProvider.notifyListeners();
                        await videoProvider.addVideo(context, file: picker!, category: category!);
                        videoProvider.checkSend=false;
                        videoProvider.notifyListeners();
                        Navigator.pop(context);
                      }else{
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  child: videoProvider.checkSend?const Text("Upload ..."):const Text("Done"))))
            ],
          ),
        ),
      ),
    );
  }
}
