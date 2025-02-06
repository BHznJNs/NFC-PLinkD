import 'package:flutter/material.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:nfc_plinkd/components/custom_button.dart';
import 'package:nfc_plinkd/utils/permission.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

class Recorder extends StatefulWidget {
  const Recorder({super.key, required this.onRecordEnd});

  final Function(String?) onRecordEnd;

  @override
  State<StatefulWidget> createState() => _RecorderState();
}

class _RecorderState extends State<Recorder> {
  late RecorderController recorderController;
  final timer = StopWatchTimer(mode: StopWatchMode.countUp);

  @override
  void initState() {
    super.initState();
    recorderController = RecorderController();
  }
  @override
  Future<void> dispose() async {
    recorderController.dispose();
    super.dispose();
    await timer.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final countupTimer = StreamBuilder(
      stream: timer.rawTime,
      initialData: timer.rawTime.value,
      builder: (context, snap) {
        final value = snap.data!;
        final displayTime =
          StopWatchTimer.getDisplayTime(value, hours: false);
        return Text(
          displayTime,
          style: const TextStyle(
            fontSize: 56,
            fontFamily: 'Helvetica',
            fontWeight: FontWeight.w500,
          ),
        );
      }
    );
    final waveform = AudioWaveforms(
      recorderController: recorderController,
      size: Size.fromHeight(64), 
    );
    return Scaffold(
      appBar: AppBar(title: Text('Record a Audio')),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 64),
        child: Column(
          children: [
            countupTimer,
            SizedBox(height: 64),
            waveform,
            Expanded(child: Container()),
            _TimerButton(
              onStart: () {
                requestRecordingPermission(
                  onGranted: () async {
                    timer.onStartTimer();
                    recorderController.record(
                      sampleRate: 44100,
                      bitRate: 128 * 1000,
                      path: '${(await getDownloadsDirectory())!.path}/test.m4a'
                    );
                  },
                  onDenied: () =>
                    Navigator.of(context).pop(),
                );
              },
              onPause: () {
                recorderController.pause();
                timer.onStopTimer();
              },
              onResume: () {
                recorderController.record();
                timer.onStartTimer();
              },
              onComplete: () {
                if (recorderController.isRecording) {
                  recorderController.stop().then((path) =>
                    widget.onRecordEnd(path));
                }
                timer.onResetTimer();
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _TimerButton extends StatefulWidget {
  const _TimerButton({
    required this.onStart,
    required this.onPause,
    required this.onResume,
    required this.onComplete,
  });

  final Function onStart;
  final Function onPause;
  final Function onResume;
  final Function onComplete;

  @override
  State<_TimerButton> createState() => _TimerButtonState();
}

class _TimerButtonState extends State<_TimerButton>
    with SingleTickerProviderStateMixin {
  bool isPlaying = false;
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<Offset> _slideLeft;
  late Animation<Offset> _slideRight;
  late Animation<double> _opacity;
  late Animation<double> _opacityRev;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _slideLeft = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-0.75, 0.0),
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _slideRight = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.75, 0.0),
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _opacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _opacityRev = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final startButton = CircularElevatedIconButton(
      icon: Icons.mic,
      onPressed: () {
        _controller.forward();
        widget.onStart();
        setState(() => isPlaying = true);
      },
      foregroundColor: Theme.of(context).colorScheme.primary,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
    );
    final pauseResumeButton = CircularElevatedIconButton(
      icon: isPlaying ? Icons.pause : Icons.play_arrow,
      onPressed: () {
        if (isPlaying) {
          widget.onPause();
        } else {
          widget.onResume();
        }
        setState(() => isPlaying = !isPlaying);
      },
      foregroundColor: Theme.of(context).colorScheme.secondary,
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
    );
    final stopButton = CircularElevatedIconButton(
      icon: Icons.check,
      onPressed: () {
        _controller.reverse();
        widget.onComplete();
        setState(() => isPlaying = false);
      },
      foregroundColor: Theme.of(context).colorScheme.error,
      backgroundColor: Theme.of(context).colorScheme.errorContainer,
    );
    return Stack(
      alignment: Alignment.center,
      children: [
        FadeTransition(
          opacity: _opacityRev,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SlideTransition(
                position: _slideLeft,
                child: pauseResumeButton,
              ),
              SlideTransition(
                position: _slideRight,
                child: stopButton,
              ),
            ],
          ),
        ),
        FadeTransition(
          opacity: _opacity,
          child: ScaleTransition(
            scale: _scale,
            child: startButton,
          ),
        ),
      ],
    );
  }
}
