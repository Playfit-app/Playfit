import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:playfit/i18n/strings.g.dart';
import 'package:playfit/components/level_cinematic/difficulty.dart';
import 'package:playfit/services/tts_service.dart';
import 'package:playfit/services/workout_timer_service.dart';
import 'package:playfit/styles/styles.dart';
import 'package:playfit/workout_analyzer.dart';
import 'package:playfit/image_converter.dart';
import 'package:playfit/components/camera/left_box_widget.dart';
import 'package:playfit/components/camera/bottom_box_widget.dart';
import 'package:playfit/components/camera/celebration_overlay.dart';
import 'package:playfit/workout_progression_page.dart';

enum BoxType { left, bottom }

class CameraView extends StatefulWidget {
  final Map<String, List<dynamic>> workoutSessionExercises;
  final String difficulty;
  final int currentExerciseIndex;
  final String landmarkImageUrl;
  final Map<String, String?> characterImages;
  final BoxType boxType;
  final String city;
  final int level;

  const CameraView({
    super.key,
    required this.workoutSessionExercises,
    required this.difficulty,
    required this.currentExerciseIndex,
    required this.landmarkImageUrl,
    required this.characterImages,
    required this.boxType,
    required this.city,
    required this.level,
  });

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  CameraController? _controller;
  bool _isDetecting = false;
  final WorkoutAnalyzer _workoutAnalyzer = WorkoutAnalyzer();
  WorkoutTimerService _workoutTimerService = WorkoutTimerService();
  late WorkoutType _workoutType;
  late String _exerciseName;
  late Duration _elapsedTime;

  int _count = 0;
  late int _targetCount;
  bool _showCelebration = false;
  bool _showStartButton = true;
  int _celebrationCountdown = 5;
  Timer? _celebrationTimer;
  bool _celebrationStarted = false;
  late FlutterTts _flutterTts;
  late final SpeechToText _speechToText;
  bool _speechAvailable = false;
  bool _isListeningForGo = false;
  bool _goTriggered = false;
  Timer? _speechRestartTimer;
  bool _speechPermissionDenied = false;
  String? _speechErrorMessage;
  String? _lastRecognizedPhrase;

  WorkoutType workoutTypeFromName(String name) {
    switch (name.toLowerCase().replaceAll('-', '')) {
      case 'squat':
        return WorkoutType.squat;
      case 'jumpingjack':
        return WorkoutType.jumpingJack;
      case 'pushup':
        return WorkoutType.pushUp;
      case 'pullup':
        return WorkoutType.pullUp;
      default:
        throw Exception('Workout type not recognized: $name');
    }
  }

  @override
  void initState() {
    super.initState();

    _elapsedTime = _workoutTimerService.elapsed;
    _workoutTimerService.onTick = (elapsed) {
      if (mounted) {
        setState(() {
          _elapsedTime = elapsed;
        });
      }
    };
    final exercise = widget.workoutSessionExercises[widget.difficulty]![
        widget.currentExerciseIndex];
    _workoutType = workoutTypeFromName(exercise['name']);
    _targetCount = exercise['repetitions'];
    _exerciseName = exercise['name'];
    _flutterTts = FlutterTts();
    configureTtsLanguage(_flutterTts);
    _speechToText = SpeechToText();

    initCamera();
    // Don't auto-start listening - only initialize permissions
    _initializeSpeechRecognition();
    _workoutAnalyzer.workoutCounts.addListener(() {
      final count = _workoutAnalyzer.workoutCounts.value[_workoutType];
      if (count != null && count > _count && count <= _targetCount) {
        setState(() {
          _count = count;
          _announceCount();
          if (_count == _targetCount && !_celebrationStarted) {
            _celebrationStarted = true;
            _showCelebration = true;
            _stopDetecting();
          }
        });
      }
    });
  }

  Future<void> _announceCount() async {
    await _flutterTts.stop();
    if (_count == _targetCount) {
      await _flutterTts
          .speak("Bravo ! Tu as atteint $_targetCount répétitions.");
    } else {
      await _flutterTts.speak("$_count");
    }
  }

  void _startTimer() {
    _workoutTimerService.start();
  }

  Future<void> initCamera() async {
    final cameras = await availableCameras();
    _controller = CameraController(
      cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
      ),
      ResolutionPreset.high,
    );
    await _controller?.initialize();

    _workoutAnalyzer.workoutCounts.addListener(() {
      final count = _workoutAnalyzer.workoutCounts.value[_workoutType];

      if (count != null && count > _count && count <= _targetCount) {
        setState(() {
          _count = count;

          if (_count == _targetCount && !_celebrationStarted) {
            _celebrationStarted = true;
            _showCelebration = true;
            _stopDetecting();
          }
        });
      }
    });

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _initializeSpeechRecognition() async {
    print('🔐 Checking permissions...');
    
    final available = await _speechToText.initialize(
      onStatus: _onSpeechStatus,
      onError: _onSpeechError,
      debugLogging: true,
    );

    print('🎙️ Speech available after initialize: $available');

    var micStatus = await Permission.microphone.status;
    print('🎤 Microphone status: $micStatus');
    
    if (!micStatus.isGranted) {
      micStatus = await Permission.microphone.request();
      print('🎤 Microphone after request: $micStatus');
    }
    
    // Check speech permission on iOS only
    PermissionStatus? speechStatus;
    if (Platform.isIOS) {
      speechStatus = await Permission.speech.status;
      print('🗣️ Speech status: $speechStatus');
      
      if (!speechStatus.isGranted && !speechStatus.isPermanentlyDenied) {
        speechStatus = await Permission.speech.request();
        print('🗣️ Speech after request: $speechStatus');
      }
    }

    final hasMic = micStatus.isGranted;
    final hasSpeechPermission = available;

    print('✅ Microphone granted: $hasMic');
    print('✅ Speech available: $hasSpeechPermission');
    print('📱 Platform: ${Platform.isAndroid ? "Android" : "iOS"}');

    if (mounted) {
      setState(() {
        _speechAvailable = available;
        _speechPermissionDenied = !hasSpeechPermission || !hasMic;
        _speechErrorMessage = null;
      });
    }

    // Don't auto-start listening here anymore
    // Let the user see the card first before starting
    print('✅ Speech recognition initialized, waiting for user interaction');
  }

  Future<void> _startListeningForGo() async {
    if (!_speechAvailable || _goTriggered || !_showStartButton) {
      print('⚠️ Cannot listen: available=$_speechAvailable, triggered=$_goTriggered, showButton=$_showStartButton');
      return;
    }
    
    if (_speechToText.isListening) {
      print('⚠️ Already listening');
      return;
    }

    final locales = await _speechToText.locales();
    
    final frenchLocale = locales.firstWhere(
      (l) => l.localeId.startsWith('fr'),
      orElse: () => locales.first,
    );
    
    print('🌍 Locale chosen: ${frenchLocale.localeId}');
    
    _lastRecognizedPhrase = null;
    _speechErrorMessage = null;

    await _speechToText.listen(
      onResult: _onSpeechResult,
      listenFor: const Duration(seconds: 10),
      pauseFor: const Duration(seconds: 2),
      partialResults: true,
      localeId: frenchLocale.localeId,
      cancelOnError: false,
      listenMode: ListenMode.confirmation,
    );

    final isListening = _speechToText.isListening;
    print('🎙️ Listening started: $isListening');

    if (mounted) {
      setState(() {
        _isListeningForGo = isListening;
      });
    }

    if (!_isListeningForGo) {
      _scheduleGoListeningRestart();
    }
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    final rawText = result.recognizedWords;
    final sanitized = _sanitizeRecognizedText(rawText);

    print('🎤 Raw: "$rawText"');
    print('🧹 Sanitized: "$sanitized"');
    print('✓ Final: ${result.finalResult}');

    if (sanitized.isEmpty) {
      return;
    }

    if (mounted) {
      setState(() {
        _lastRecognizedPhrase = sanitized;
      });
    }

    if (_containsGoCommand(sanitized) && !_goTriggered) {
      print('🚀 GO TRIGGERED!');
      _goTriggered = true;
      _handleWorkoutStartTrigger();
    }
  }

  void _onSpeechStatus(String status) {
    print('📊 Status: $status');
    if (status == 'notListening') {
      if (mounted) {
        setState(() {
          _isListeningForGo = false;
        });
      }
      _scheduleGoListeningRestart();
    }
  }

  void _onSpeechError(SpeechRecognitionError error) {
    print('❌ Speech error: ${error.errorMsg}');
    if (_goTriggered || !_showStartButton) return;

    if (mounted) {
      setState(() {
        _speechErrorMessage = error.errorMsg;
        _isListeningForGo = false;
      });
    }

    // Restart listening after an error (except permanent errors)
    if (error.errorMsg != 'error_speech_timeout' && 
        error.errorMsg != 'error_no_match') {
      print('⚠️ Non-recoverable error, not restarting');
      return;
    }
    
    _scheduleGoListeningRestart();
  }

  Future<void> _stopListeningForGo() async {
    _speechRestartTimer?.cancel();
    if (_speechToText.isListening) {
      await _speechToText.stop();
    }
    _isListeningForGo = false;
  }

  void _scheduleGoListeningRestart() {
    if (_goTriggered || !_showStartButton || !_speechAvailable) {
      print('⚠️ Not restarting: goTriggered=$_goTriggered, showButton=$_showStartButton, available=$_speechAvailable');
      return;
    }
    _speechRestartTimer?.cancel();
    print('⏱️ Scheduling restart in 700ms...');
    _speechRestartTimer = Timer(const Duration(milliseconds: 700), () {
      if (mounted && _showStartButton && !_goTriggered) {
        print('🔄 Restarting listening...');
        unawaited(_startListeningForGo());
      }
    });
  }

  void _handleWorkoutStartTrigger() {
    print('🏋️ Starting workout...');
    if (!_showStartButton) {
      print('⚠️ Button already hidden, ignoring trigger');
      return;
    }
    if (!_goTriggered) {
      print('⚠️ GO not triggered, ignoring manual start');
      // Allow manual start via button press even without voice command
      _goTriggered = true;
    }
    setState(() {
      _showStartButton = false;
    });
    _speechErrorMessage = null;
    unawaited(_stopListeningForGo());
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _startDetecting();
      }
    });
  }

  void _startDetecting() async {
    if (_controller != null) {
      if (_controller!.value.isStreamingImages) return;
      if (mounted) {
        setState(() {
          _showStartButton = false;
        });
      }

      _startTimer();
      _controller!.startImageStream((image) async {
        if (_isDetecting) return;
        _isDetecting = true;

        try {
          final inputImage = ImageUtils.getInputImage(image, _controller);
          await _workoutAnalyzer.detectWorkout(inputImage, _workoutType);
        } catch (e) {
          print('❌ Detection error: $e');
        } finally {
          _isDetecting = false;
        }
      });
    }
  }

  void _stopDetecting() async {
    if (_controller != null && _controller!.value.isStreamingImages) {
      _workoutTimerService.stop();
      await _controller!.stopImageStream();
      _isDetecting = false;
    }

    _celebrationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _celebrationCountdown--;
      });
      if (_celebrationCountdown == 0) {
        _celebrationTimer?.cancel();
        _goToProgressionPage();
      }
    });
  }

  void _goToProgressionPage() {
    final Difficulty difficulty = widget.difficulty == "beginner"
        ? Difficulty.easy
        : widget.difficulty == "intermediate"
            ? Difficulty.medium
            : Difficulty.hard;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkoutProgressionPage(
          difficulty: difficulty,
          images: [
            "${dotenv.env['SERVER_BASE_URL']}${widget.characterImages['path']}",
            "${dotenv.env['SERVER_BASE_URL']}${widget.characterImages['building']}",
            "${dotenv.env['SERVER_BASE_URL']}${widget.characterImages['tree']}",
            "${dotenv.env['SERVER_BASE_URL']}${widget.landmarkImageUrl}",
          ],
          startingPoint: widget.currentExerciseIndex,
          workoutSessionExercises: widget.workoutSessionExercises,
          currentExerciseIndex: widget.currentExerciseIndex + 1,
          characterImages: widget.characterImages,
          boxType: widget.boxType,
          city: widget.city,
          level: widget.level,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF4FF),
      body: _controller != null && _controller!.value.isInitialized
          ? Stack(
              children: [
                Positioned(
                  top: 40,
                  left: 0,
                  right: 0,
                  child: Text(
                    _exerciseName.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 1, 1, 1),
                    ),
                  ),
                ),

                Center(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _controller!.value.previewSize!.height,
                      height: _controller!.value.previewSize!.width,
                      child: CameraPreview(_controller!),
                    ),
                  ),
                ),
                if (widget.boxType == BoxType.left && !_showStartButton)
                  LeftBoxWidget(
                      elapsedTime: _elapsedTime,
                      count: _count,
                      targetCount: _targetCount),
                if (widget.boxType == BoxType.bottom && !_showStartButton)
                  BottomBoxWidget(
                      elapsedTime: _elapsedTime,
                      count: _count,
                      targetCount: _targetCount),

                if (_showCelebration)
                  CelebrationOverlay(
                    finalTime: _workoutTimerService.elapsed,
                    city: widget.city,
                    level: widget.level,
                    characterImages: widget.characterImages,
                    difficulty: widget.difficulty,
                  ),
                if (_showCelebration && _celebrationCountdown > 0)
                  Positioned(
                    bottom: 40,
                    left: 0,
                    right: 0,
                    child: Text(
                      t.camera
                          .next_step_countdown(seconds: _celebrationCountdown),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 5.0,
                            color: Colors.black,
                            offset: Offset(1.5, 1.5),
                          ),
                        ],
                      ),
                    ),
                  ),

                if (_showStartButton)
                  Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                      ),
                      child: _VoiceStartCard(
                        onPressed: _handleWorkoutStartTrigger,
                        isListening: _isListeningForGo,
                        speechAvailable: _speechAvailable,
                        permissionDenied: _speechPermissionDenied,
                        errorMessage: _speechErrorMessage,
                        lastRecognizedPhrase: _lastRecognizedPhrase,
                      ),
                    ),
                  ),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  @override
  void dispose() {
    _workoutTimerService.onTick = null;
    _workoutTimerService.stop();
    _celebrationTimer?.cancel();
    _workoutAnalyzer.dispose();
    if (_controller != null) {
      if (_controller!.value.isStreamingImages) {
        _controller!.stopImageStream();
      }
      _controller!.dispose();
    }
    _flutterTts.stop();
    _speechRestartTimer?.cancel();
    if (_speechAvailable) {
      _speechToText.stop();
    }
    super.dispose();
  }

  String _sanitizeRecognizedText(String text) {
    final lower = text.toLowerCase();
    final cleaned = lower
        .replaceAll(RegExp(r"[^\p{L}\p{N}\s]", unicode: true), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    return cleaned;
  }

  bool _containsGoCommand(String text) {
    if (text.isEmpty) {
      return false;
    }

    print('🔍 Checking command in: "$text"');

    final normalized = text
        .toLowerCase()
        .replaceAll("'", ' ')
        .replaceAll('-', ' ')
        .replaceAll('é', 'e')
        .replaceAll('è', 'e')
        .replaceAll('ê', 'e')
        .trim();

    print('🧹 Normalized: "$normalized"');

    final goCommands = [
      'cest parti',
      'c est parti',
      'ces parti',
      'se parti',
      'lets go',
      'let go',
      'letsgo',
    ];

    for (final cmd in goCommands) {
      if (normalized.contains(cmd)) {
        print('✅ Command "$cmd" detected!');
        return true;
      }
    }

    final words = normalized.split(' ');
    for (final word in words) {
      if (word == 'go' || word == 'gau' || word == 'guo') {
        print('✅ Word "GO" detected!');
        return true;
      }
    }

    print('❌ No command detected');
    return false;
  }
}

class _VoiceStartCard extends StatefulWidget {
  const _VoiceStartCard({
    required this.onPressed,
    required this.isListening,
    required this.speechAvailable,
    required this.permissionDenied,
    required this.errorMessage,
    required this.lastRecognizedPhrase,
  });

  final VoidCallback onPressed;
  final bool isListening;
  final bool speechAvailable;
  final bool permissionDenied;
  final String? errorMessage;
  final String? lastRecognizedPhrase;

  @override
  State<_VoiceStartCard> createState() => _VoiceStartCardState();
}

class _VoiceStartCardState extends State<_VoiceStartCard> {
  @override
  void initState() {
    super.initState();
    // Start listening after a short delay to let the UI render
    if (widget.speechAvailable && !widget.permissionDenied) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          // Trigger listening through parent
          final cameraState = context.findAncestorStateOfType<_CameraViewState>();
          if (cameraState != null && cameraState._showStartButton && !cameraState._goTriggered) {
            print('🎯 Starting initial listening from card...');
            cameraState._startListeningForGo();
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cameraStrings = t.camera;

    final statusText = !widget.speechAvailable || widget.permissionDenied
        ? cameraStrings.voice_hint_permission
        : widget.errorMessage != null
            ? cameraStrings.voice_hint_error
            : widget.isListening
                ? cameraStrings.voice_hint_listening
                : cameraStrings.voice_hint_tap;

    const playfitOrange = Color(0xFFF8871F);
    const playfitOrangeDark = Color(0xFFE57207);
    const playfitBeige = Color(0xFFFFE9CA);

    return Container(
      decoration: BoxDecoration(
        color: playfitBeige,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: playfitOrangeDark.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: playfitOrange.withOpacity(0.2),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: playfitOrange.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: playfitOrange.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    widget.isListening ? Icons.graphic_eq_rounded : Icons.mic_rounded,
                    color: playfitOrangeDark,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cameraStrings.voice_hint_title,
                        style: GoogleFonts.amaranth(
                          color: AppStyles.grey,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        cameraStrings.voice_hint_body,
                        style: GoogleFonts.amaranth(
                          color: AppStyles.grey.withOpacity(0.85),
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: playfitOrange.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: widget.onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: playfitOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.play_arrow_rounded, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      cameraStrings.start_workout,
                      style: GoogleFonts.amaranth(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (widget.permissionDenied)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: TextButton.icon(
                  onPressed: () async {
                    await openAppSettings();
                  },
                  icon: const Icon(
                    Icons.settings_rounded,
                    color: playfitOrangeDark,
                    size: 20,
                  ),
                  label: Text(
                    'Ouvrir les Réglages',
                    style: GoogleFonts.amaranth(
                      color: playfitOrangeDark,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    backgroundColor: playfitOrange.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: playfitOrange.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: widget.isListening
                    ? playfitOrange.withOpacity(0.15)
                    : AppStyles.grey.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: widget.isListening
                      ? playfitOrange.withOpacity(0.4)
                      : AppStyles.grey.withOpacity(0.15),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: widget.isListening
                          ? playfitOrange.withOpacity(0.2)
                          : AppStyles.grey.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      widget.isListening ? Icons.hearing_rounded : Icons.mic_off_rounded,
                      color: widget.isListening ? playfitOrangeDark : AppStyles.grey,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      statusText,
                      style: GoogleFonts.amaranth(
                        color: AppStyles.grey,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (widget.lastRecognizedPhrase != null && widget.lastRecognizedPhrase!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: playfitOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: playfitOrange.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.chat_bubble_outline_rounded,
                        color: playfitOrangeDark,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          cameraStrings.voice_hint_last_heard(
                            phrase: widget.lastRecognizedPhrase!,
                          ),
                          style: GoogleFonts.amaranth(
                            color: AppStyles.grey.withOpacity(0.85),
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}