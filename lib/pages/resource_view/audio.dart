import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:nfc_plinkd/config.dart';
import 'package:share_plus/share_plus.dart';
import 'package:nfc_plinkd/components/custom_button.dart';
import 'package:open_file/open_file.dart';

Future<void> openAudioWithDefaultPlayer(BuildContext context, String path) async {
  final result = await OpenFile.open(path);
  final useBuiltinAudioPlayer = await Configuration.useBuiltinAudioPlayer.read();
  if ((useBuiltinAudioPlayer ?? false) && context.mounted) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => AudioPlayerPage(path)));
    return;
  }

  switch (result.type) {
    case ResultType.done: return;
    case ResultType.fileNotFound:
      if (kDebugMode) print('Target file not found: $path');
    case ResultType.noAppToOpen:
    case ResultType.permissionDenied:
    case ResultType.error:
      // fallback to build-in player
      if (context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => AudioPlayerPage(path)));
      }
  }
}

String _formatDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
  String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
  String twoDigitHours = twoDigits(duration.inHours);
  return "${duration.inHours > 0 ? "$twoDigitHours:" : ""}$twoDigitMinutes:$twoDigitSeconds";
}

class AudioPlayerPage extends StatefulWidget {
  const AudioPlayerPage(this.path, {super.key});

  final String path;

  @override
  State<AudioPlayerPage> createState() => _AudioPlayerPageState();
}

class _AudioPlayerPageState extends State<AudioPlayerPage> {
  final AudioPlayer player = AudioPlayer();
  bool isPlaying = false;

  void share() {
    Share.shareXFiles([XFile(widget.path)]);
  }

  Future<void> _initAudioPlayer() async {
    try {
      // Load audio from file path
      await player.setFilePath(widget.path);

      player.playerStateStream.listen((playerState) {
        if (!mounted) return;
        setState(() => isPlaying = playerState.playing);
      });

      player.playbackEventStream.listen((_) {},
        onError: (Object e, StackTrace stackTrace) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading audio')),
          );
        }
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading audio')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playerCard = Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 32, horizontal: 72),
      child: Card.filled(
        elevation: 4,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 64),
          child: Icon(
            Icons.mic,
            size: 108,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
      ),
    );
    final playerDuration = StreamBuilder<Duration>(
      stream: player.positionStream,
      builder: (context, snapshot) {
        final position = snapshot.data ?? Duration.zero;
        final totalDuration = player.duration ?? Duration.zero;
        const textStyle = TextStyle(fontSize: 12);
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: Row(
            children: [
              Text(_formatDuration(position), style: textStyle),
              Expanded(child: Container()),
              Text(_formatDuration(totalDuration), style: textStyle),
            ],
          ),
        );
      },
    );
    final playerSlider = StreamBuilder<Duration>(
      stream: player.positionStream,
      builder: (context, snapshot) {
        final position = snapshot.data ?? Duration.zero;
        final slider = Slider.adaptive(
          value: position.inSeconds.toDouble(),
          min: 0,
          max: player.duration?.inSeconds.toDouble()?? 100, // Provide a max value, or a default
          onChanged: (value) async {
            await player.seek(Duration(seconds: value.toInt()));
          },
        );
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight: 2.0,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
            ),
            child: slider,
          )
        );
      },
    );
    return Scaffold(
      appBar: AppBar(actions: [
        IconButton(
          onPressed: share,
          icon: Icon(Icons.share),
        ),
      ]),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          playerCard,
          Expanded(child: Container()),
          Stack(children: [
            playerSlider,
            playerDuration,
          ]),
          Padding(
            padding: EdgeInsets.only(top: 16, bottom: 64),
            child: CircularElevatedIconButton(
              onPressed: () async {
                if (isPlaying) {
                  await player.pause();
                } else {
                  await player.play();
                }
              },
              icon: isPlaying ? Icons.pause : Icons.play_arrow,
              foregroundColor: Theme.of(context).colorScheme.primary,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}
