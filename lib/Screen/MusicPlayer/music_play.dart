import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';

class MusicPlay extends StatefulWidget {
  const MusicPlay(
      {super.key,required this.index, required this.audioPlayer,required this.songModelList});

  
  final AudioPlayer audioPlayer;
  final List<SongModel> songModelList;
  final int index;

  @override
  State<MusicPlay> createState() => _MusicPlayState();
}

class _MusicPlayState extends State<MusicPlay> {
  Duration duration = const Duration();
  Duration position = const Duration();
  bool isPlay = false;
   List<AudioSource> songList = [];

  int currentIndex = 0;

  @override
  void initState() {
    currentIndex=widget.index;
      parseSong();
    super.initState();
  }

  

  changeToSecond(int second){
    Duration duration=Duration(seconds: second);
    widget.audioPlayer.seek(duration);

  }


  // update code

    void parseSong() async{
    try {
      for (var element in widget.songModelList) {
        songList.add(
          AudioSource.uri(
            Uri.parse(element.uri!),
          
          ),
        );
      }

      // widget.audioPlayer.setAudioSource(
      //   ConcatenatingAudioSource(children: songList),
      // );
      // Define the playlist


final playlist = ConcatenatingAudioSource(
  
  useLazyPreparation: true,
  // Customise the shuffle algorithm
  shuffleOrder: DefaultShuffleOrder(),
  // Specify the playlist items
  children:songList,
);
      await widget.audioPlayer.setAudioSource(playlist, initialIndex:currentIndex, initialPosition: Duration.zero);
      widget.audioPlayer.play();
      isPlay = true;

      widget.audioPlayer.durationStream.listen((d) {
        if (d != null) {
          setState(() {
            duration = d;
          });
        }
      });
      widget.audioPlayer.positionStream.listen((p) {
        setState(() {
          position = p;
        });
      });
      listenToEvent();
      listenToSongIndex();
    } on Exception catch (_) {
      // popBack();
    }
  }

  void listenToEvent() {
    widget.audioPlayer.playerStateStream.listen((state) {
      if (state.playing) {
        setState(() {
          isPlay = true;
        });
      } else {
        setState(() {
          isPlay = false;
        });
      }
      if (state.processingState == ProcessingState.completed) {
        setState(() {
          isPlay = false;
        });
      }
    });
  }

  void listenToSongIndex() {
    widget.audioPlayer.currentIndexStream.listen(
      (event) {
        setState(
          () {
            if (event != null) {
              currentIndex = event;
            }
            
          },
        );
      },
    );
  }

  // @override
  // void dispose() {
  //   widget.audioPlayer.dispose();
  //   super.dispose();
  // } 

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    double width = size.width;
    double height = size.height;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.03),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                    widget.audioPlayer.stop();
                  },
                  icon: const Icon(Icons.arrow_back_ios)),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                       QueryArtworkWidget(
      id: widget.songModelList[currentIndex].id,
      type: ArtworkType.AUDIO,
      artworkHeight: 200,
      artworkWidth: 200,
      artworkFit: BoxFit.cover,
      nullArtworkWidget: CircleAvatar(
                        radius: width * 0.25,
                        child: const Icon(Icons.music_note),
                      ),
    ),
                      
                      SizedBox(
                        height: height * 0.03,
                      ),
                      Text(
                        widget.songModelList[currentIndex].displayNameWOExt,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: width * 0.06),
                        maxLines: 1,
                        overflow: TextOverflow.fade,
                      ),
                      SizedBox(
                        height: height * 0.02,
                      ),
                      Text(
                       widget.songModelList[currentIndex].artist.toString() == "<unknown>"
                            ? "< Unknown Artist >"
                            :  widget.songModelList[currentIndex].artist.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.fade,
                      ),
                      SizedBox(
                        height: height * 0.03,
                      ),
                      Row(
                        children: [
                           Text(position.toString().split(".")[0]),
                          Expanded(
                              child: Slider(
                                value:position.inSeconds.toDouble(),
                              max: duration.inSeconds.toDouble(),
                              min: const Duration(microseconds: 0).inSeconds.toDouble(),
                              
                               onChanged: (value) {
                               setState(() {
                                  changeToSecond(value.toInt());
                                  value=value;

                               });

                              })),
                           Text(duration.toString().split(".")[0]),
                        ],
                      ),
                      SizedBox(
                        height: height * 0.02,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          IconButton(
                              onPressed: () {
                                     widget.audioPlayer.seekToPrevious();
                              },
                              icon: Icon(
                                Icons.skip_previous,
                                size: width * 0.08,
                              )),
                          CircleAvatar(
                            radius: width * 0.07,
                            backgroundColor: Colors.white,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  if (isPlay) {
                                    widget.audioPlayer.pause();
                                  } else {
                                    widget.audioPlayer.play();
                                  }
                                  isPlay = !isPlay;
                                });
                              },
                              child: Icon(
                                isPlay ? Icons.pause : Icons.play_arrow,
                                size: width * 0.08,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          IconButton(
                              onPressed: () {
                                 if (widget.audioPlayer.hasNext) {
                              widget.audioPlayer.seekToNext();
                            }
                              },
                              icon: Icon(
                                Icons.skip_next,
                                size: width * 0.08,
                              )),
                        ],
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}


