
import 'package:flutter/material.dart';
import 'package:flutter_pcm_sound/flutter_pcm_sound.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const PcmSoundApp();
  }
}

class PcmSoundApp extends StatefulWidget {
  const PcmSoundApp({Key? key}) : super(key: key);

  @override
  _PcmSoundAppState createState() => _PcmSoundAppState();
}

class _PcmSoundAppState extends State<PcmSoundApp> {

  static const int sampleRate = 48000;

  int _remainingFrames = 0;
  MajorScale scale = MajorScale(sampleRate: sampleRate, noteDuration: 0.20);

  @override
  void initState() {
    super.initState();
    FlutterPcmSound.setLogLevel(LogLevel.verbose);
    FlutterPcmSound.setup(sampleRate: sampleRate, channelCount: 1);
    FlutterPcmSound.setFeedThreshold(sampleRate ~/ 10);
    FlutterPcmSound.setFeedCallback(_onFeed);
  }

  @override
  void dispose() {
    super.dispose();
    FlutterPcmSound.release();
  }

  void _onFeed(int remainingFrames) async {
    setState(() {
      _remainingFrames = remainingFrames;
    });
    List<int> frames = scale.generate(periods: 20);
    await FlutterPcmSound.feed(PcmArrayInt16.fromList(frames));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Flutter PCM Sound'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  FlutterPcmSound.setFeedCallback(_onFeed);
                  _onFeed(0); // start feeding
                },
                child: const Text('Play'),
              ),
              ElevatedButton(
                onPressed: () {
                  FlutterPcmSound.setFeedCallback(null); // stop
                  setState(() {
                    _remainingFrames = 0;
                  });
                },
                child: const Text('Stop'),
              ),
              Text('$_remainingFrames Remaining Frames')
            ],
          ),
        ),
      ),
    );
  }
}
