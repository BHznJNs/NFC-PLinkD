import 'package:flutter/material.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:nfc_plinkd/components/custom_button.dart';
import 'package:nfc_plinkd/l10n/app_localizations.dart';
import 'package:nfc_plinkd/utils/permission.dart';

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
    final l10n = S.of(context)!;
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
      size: const Size.fromHeight(64), 
    );
    return Scaffold(
      appBar: AppBar(title: Text(l10n.recorderPage_title)),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 64),
        child: Column(
          children: [
            countupTimer,
            const SizedBox(height: 64),
            waveform,
            Expanded(child: Container()),
            _TimerButton(
              onStart: () async {
                final hasPermission = await requestRecordingPermission();
                if (!hasPermission) {
                  if (!context.mounted) return;
                  Navigator.of(context).pop();
                }

                final targetPath = path.join((await getTemporaryDirectory()).path, 'temp.m4a');
                timer.onStartTimer();
                recorderController.record(
                  sampleRate: 44100,
                  bitRate: 128 * 1000,
                  path: targetPath,
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
                recorderController.stop().then((path) =>
                  widget.onRecordEnd(path));
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
  late AnimationController controller;
  late Animation<double> scale;
  late Animation<Offset> slideLeft;
  late Animation<Offset> slideRight;
  late Animation<double> opacity;
  late Animation<double> opacityRev;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    scale = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeInOut),
    );
    slideLeft = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-0.75, 0.0),
    ).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeInOut),
    );
    slideRight = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.75, 0.0),
    ).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeInOut),
    );
    opacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeInOut),
    );
     opacityRev = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final startButton = CircularElevatedIconButton(
      icon: Icons.mic,
      onPressed: () {
        controller.forward();
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
          opacity: opacityRev,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SlideTransition(
                position: slideLeft,
                child: pauseResumeButton,
              ),
              SlideTransition(
                position: slideRight,
                child: stopButton,
              ),
            ],
          ),
        ),
        FadeTransition(
          opacity: opacity,
          child: ScaleTransition(
            scale: scale,
            child: startButton,
          ),
        ),
      ],
    );
  }
}
