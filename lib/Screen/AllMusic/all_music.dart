import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';

import '../MusicPlayer/music_play.dart';

class AllMusic extends StatefulWidget {
  const AllMusic({super.key});

  @override
  State<AllMusic> createState() => _AllMusicState();
}

class _AllMusicState extends State<AllMusic> {

      final _audioQuery = OnAudioQuery();
       final audioPlayer = AudioPlayer();


         bool _storagePermissionGranted = false;
         bool _isDinedpermission=false;

  @override
  void initState() {
    super.initState();
    _checkStoragePermission();
  }

  Future<void> _checkStoragePermission() async {
    final status = await Permission.storage.status;
    if(status.isGranted){
      setState(() {
      _storagePermissionGranted = status.isGranted;
    });

    }else if(status.isDenied) {
        setState(() {
      _isDinedpermission = status.isDenied;
    });
     
    }else{
       _requestStoragePermission();
    }
    
  }

  Future<void> _requestStoragePermission() async {
    final status = await Permission.storage.request();
    if (status.isGranted) {
      setState(() {
        _storagePermissionGranted = true;
      });
    }else if(status.isDenied){
        setState(() {
      _isDinedpermission = status.isDenied;
    });

    }
  }


 void _openAppSettings() {
   openAppSettings();
   setState(() {
     
   });
   

  }
      


  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Songs"),
        actions:  [
          IconButton(
            onPressed:(){},
            icon: const Icon(Icons.search))
        ],
      ),
   //   body: Center(child: const Text("Data"),),

      body: !_storagePermissionGranted? Center(child:Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.accessibility_new,size: 200,),
          const SizedBox(height: 10,),
          const Text("Allow Music Player access to storage and media?"),
          const SizedBox(height: 25,),
          Container(
            height: 45,
            margin: const EdgeInsets.symmetric(horizontal: 15),
            width:double.infinity,
            child: ElevatedButton(onPressed: (){
              if(_isDinedpermission){
                _openAppSettings();
              }else{
                _requestStoragePermission();

              }
              
            },
            style: ElevatedButton.styleFrom(
              shape: const StadiumBorder(),
              backgroundColor:Colors.purple,
              
            ),
             child:const Text("Allow Access",)),
          )



        ],
      ),) : FutureBuilder<List<SongModel>>(
        future: _audioQuery.querySongs(
          sortType: null,
          uriType: UriType.EXTERNAL,
          orderType: OrderType.ASC_OR_SMALLER,
          ignoreCase: true
        ),
        
        builder: (context,item){

          if(item.data==null){
            return const Center(
              child: CircularProgressIndicator(),
            );
          }else if(item.data!.isEmpty){
            return const Center(
              child: Text(
                "No Song Found",
              ),
            );
          }else{
            return ListView.builder(

              itemCount: item.data!.length,
              itemBuilder: (context,index)=>ListTile(
                leading: QueryArtworkWidget(id:item.data![index].id, type:ArtworkType.AUDIO,nullArtworkWidget:const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.music_note)),),
                title: Text(item.data![index].displayNameWOExt),
                subtitle: Text(item.data![index].artistId.toString()),
                trailing: const Icon(Icons.more_horiz),
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (_)=>MusicPlay(songModelList:item.data!,audioPlayer: audioPlayer,index:index,)));
                },


            ));
          }


      },
    )
    
    
    
    
    );
  }
}