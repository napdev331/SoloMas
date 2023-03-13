import 'dart:io';

import 'package:flutter/material.dart';
import 'package:helpers/helpers.dart' show OpacityTransition;
import 'package:image_picker/image_picker.dart';
import 'package:solomas/activities/home/add_video/add_video_screen.dart';
import 'package:solomas/resources_helper/colors.dart';
import 'package:solomas/resources_helper/dimens.dart';
import 'package:video_editor/video_editor.dart';
import 'package:video_player/video_player.dart';

import '../../../resources_helper/screen_area/scaffold.dart';
import '../../../resources_helper/strings.dart';

class VideoEditor extends StatefulWidget {
  const VideoEditor({
    Key? key,
    this.type,
  }) : super(key: key);
  final type;

  @override
  State<VideoEditor> createState() => _VideoEditorState();
}

class _VideoEditorState extends State<VideoEditor> {
  final _exportingProgress = ValueNotifier<double>(0.0);
  final _isExporting = ValueNotifier<bool>(false);
  final double height = 60;
  final ImagePicker _picker = ImagePicker();
  VideoEditorController? _controller;
  bool _exported = false;
  String _exportText = "";

  String formatter(Duration duration) => [
        duration.inMinutes.remainder(60).toString().padLeft(2, '0'),
        duration.inSeconds.remainder(60).toString().padLeft(2, '0')
      ].join(":");

  void _galleryVideo() async {
    var source = widget.type == ImageSourceType.gallery
        ? ImageSource.gallery
        : ImageSource.camera;
    final XFile? galleryFile = await _picker.pickVideo(source: source);
    var file = File(galleryFile?.path ?? '');
    _controller = VideoEditorController.file((file),
        maxDuration: const Duration(seconds: 15))
      ..initialize().then((_) => setState(() {}));
  }

  @override
  void initState() {
    super.initState();
    _galleryVideo();
  }

  @override
  void dispose() {
    _exportingProgress.dispose();
    _isExporting.dispose();
    _controller?.dispose();
    super.dispose();
  }

  void _exportVideo() async {
    _exportingProgress.value = 0;
    _isExporting.value = true;
    await _controller?.exportVideo(
      onProgress: (stats, value) => _exportingProgress.value = value,
      onError: (e, s) => _exportText = StringHelper.expoVideoErrorMsg,
      onCompleted: (file) {
        _isExporting.value = false;
        if (mounted) return;

        final VideoPlayerController videoController =
            VideoPlayerController.file(file);
        videoController.initialize().then((value) async {
          setState(() {});
          videoController.play();
          videoController.setLooping(true);
          await showDialog(
            context: context,
            builder: (_) => Padding(
              padding: const EdgeInsets.all(30),
              child: Center(
                child: AspectRatio(
                  aspectRatio: videoController.value.aspectRatio,
                  child: VideoPlayer(videoController),
                ),
              ),
            ),
          );
          await videoController.pause();
          videoController.dispose();
        });

        _exportText = StringHelper.expoVideoSucMsg;
        setState(() => _exported = true);
        Future.delayed(const Duration(seconds: 2),
            () => setState(() => _exported = false));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SoloScaffold(
      backGroundColor: Colors.black,
      appBar: AppBar(
        leading: Container(
          alignment: Alignment.topLeft,
          child: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                padding: EdgeInsets.all(DimensHelper.sidesMargin),
                child: Image.asset('images/blackarrow_black.png',
                    color: SoloColor.white),
              )),
        ),
        centerTitle: true,
        title: Text(StringHelper.video,
            style: TextStyle(
                fontFamily: 'Poppins-Regular',
                color: SoloColor.white,
                fontWeight: FontWeight.w400)),
        backgroundColor: SoloColor.chargeBlue,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(StringHelper.add,
                style: TextStyle(
                    fontFamily: 'Poppins-Regular',
                    color: SoloColor.white,
                    fontSize: 16)),
          )
        ],
      ),
      body: _controller?.initialized == true
          ? SafeArea(
              child: Column(children: [
              // IconButton(
              //   onPressed: _exportVideo,
              //   icon: const Icon(Icons.save, color: Colors.white),
              // ),
              Expanded(
                child: Stack(alignment: Alignment.center, children: [
                  CropGridViewer(
                    controller: _controller as VideoEditorController,
                    showGrid: false,
                  ),
                  AnimatedBuilder(
                    animation: _controller!.video,
                    builder: (_, __) => OpacityTransition(
                      visible: _controller?.isPlaying == false,
                      child: GestureDetector(
                        onTap: _controller?.video.play,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child:
                              const Icon(Icons.play_arrow, color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                ]),
              ),
              Container(
                  margin: const EdgeInsets.only(top: 10),
                  child: Column(children: [
                    AnimatedBuilder(
                      animation: _controller!.video,
                      builder: (_, __) {
                        final duration =
                            _controller?.video.value.duration.inSeconds;
                        final pos = _controller!.trimPosition * duration!;
                        final start = _controller!.minTrim * duration;
                        final end = _controller!.maxTrim * duration;

                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: height / 4),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(formatter(Duration(seconds: pos.toInt())),
                                    style: TextStyle(color: SoloColor.white)),
                                OpacityTransition(
                                  visible: _controller?.isTrimming == false,
                                  child: Row(children: [
                                    Text(
                                        formatter(
                                            Duration(seconds: start.toInt())),
                                        style:
                                            TextStyle(color: SoloColor.white)),
                                    const SizedBox(width: 10),
                                    Text(
                                        formatter(
                                            Duration(seconds: end.toInt())),
                                        style:
                                            TextStyle(color: SoloColor.white)),
                                  ]),
                                )
                              ]),
                        );
                      },
                    ),
                    Container(
                        width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.symmetric(vertical: height / 4),
                        child: TrimSlider(
                          controller: _controller as VideoEditorController,
                          height: height,
                          horizontalMargin: height / 4,
                          // child: TrimTimeline(
                          //     controller: _controller as VideoEditorController,
                          //     margin: const EdgeInsets.only(top: 10))),
                        ))
                  ])),
              // _customSnackBar(),
              ValueListenableBuilder(
                valueListenable: _isExporting,
                builder: (_, bool export, __) => OpacityTransition(
                  visible: export,
                  child: AlertDialog(
                    backgroundColor: Colors.white,
                    title: ValueListenableBuilder(
                      valueListenable: _exportingProgress,
                      builder: (_, double value, __) => Text(
                        "Exporting video ${(value * 100).ceil()}%",
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ]))
          : const Center(child: CircularProgressIndicator()),
    );
  }

// Widget _customSnackBar() {
//   return Align(
//     alignment: Alignment.bottomCenter,
//     child: SwipeTransition(
//       visible: _exported,
//       axisAlignment: 1.0,
//       child: Container(
//         height: height,
//         width: double.infinity,
//         color: Colors.black.withOpacity(0.8),
//         child: Center(
//           child: Text(_exportText,
//               style: const TextStyle(fontWeight: FontWeight.bold)),
//         ),
//       ),
//     ),
//   );
// }
}
