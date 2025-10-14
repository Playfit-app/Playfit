import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:playfit/i18n/strings.g.dart';
import 'package:playfit/components/level_cinematic/difficulty.dart';
import 'package:playfit/services/tts_service.dart';
import 'package:playfit/services/workout_timer_service.dart';
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

  /// Converts a workout name to a [WorkoutType].
  /// This method maps the name of the workout to its corresponding enum value.
  /// Throws an exception if the name is not recognized.
  ///
  /// `name` is the name of the workout as a string.
  ///
  /// Returns a [WorkoutType] corresponding to the name.
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
    _initializeSpeechRecognition();
    // Listen for changes in workout counts to update the count and trigger announcements
    _workoutAnalyzer.workoutCounts.addListener(() {
      final count = _workoutAnalyzer.workoutCounts.value[_workoutType];
      if (count != null && count > _count && count <= _targetCount) {
        setState(() {
          _count = count;
          _announceCount();
          if (_count == _targetCount && !_celebrationStarted) {
            _celebrationStarted = true;
            _showCelebration = true;
            _stopDetecting(); // Triggers the countdown
          }
        });
      }
    });
  }

  /// Announces the current count or target count using Text-to-Speech (TTS).
  /// This method stops any ongoing speech and speaks the current count.
  /// If the count matches the target count, it announces a congratulatory message.
  ///
  /// Returns a [Future] that completes when the speech is done.
  Future<void> _announceCount() async {
    await _flutterTts.stop();
    if (_count == _targetCount) {
      await _flutterTts
          .speak("Bravo ! Tu as atteint $_targetCount répétitions.");
    } else {
      await _flutterTts.speak("$_count");
    }
  }

  /// Starts a timer that updates the elapsed time every second.
  /// This method also checks if the target count has been reached
  /// and sets a flag to show the celebration overlay.
  ///
  /// Returns a [void] that completes when the timer is started.
  void _startTimer() {
    _workoutTimerService.start();
  }

  /// Initializes the camera and sets up the camera controller.
  /// This method retrieves the available cameras, selects the front camera,
  /// and initializes the camera controller with a high resolution preset.
  ///
  /// It also sets up a listener for workout counts to update the count
  /// and trigger the celebration overlay when the target count is reached.
  ///
  /// Returns a [Future] that completes when the camera is initialized.
  Future<void> initCamera() async {
    final cameras = await availableCameras();
    _controller = CameraController(
      cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
      ),
      ResolutionPreset.high,
    );
    await _controller?.initialize();

    // Listen for changes in workout counts to update the count and trigger announcements
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
    print('🔐 Vérification des permissions...');
    
    // Try to initialize speech recognition first (this will trigger the permission request on iOS)
    final available = await _speechToText.initialize(
      onStatus: _onSpeechStatus,
      onError: _onSpeechError,
      debugLogging: true,
    );

    print('🎙️ Speech disponible après initialize: $available');

    // Then check microphone permission
    var micStatus = await Permission.microphone.status;
    print('🎤 Microphone status: $micStatus');
    
    if (!micStatus.isGranted) {
      micStatus = await Permission.microphone.request();
      print('🎤 Microphone après request: $micStatus');
    }
    
    // Check speech permission on iOS
    PermissionStatus? speechStatus;
    if (Platform.isIOS) {
      speechStatus = await Permission.speech.status;
      print('🗣️ Speech status: $speechStatus');
      
      if (!speechStatus.isGranted && !speechStatus.isPermanentlyDenied) {
        speechStatus = await Permission.speech.request();
        print('🗣️ Speech après request: $speechStatus');
      }
    }

    final hasMic = micStatus.isGranted;
    final hasSpeechPermission = available; // Use speech_to_text's own check

    print('✅ Microphone accordé: $hasMic');
    print('✅ Speech disponible: $hasSpeechPermission');

    if (!hasMic || !hasSpeechPermission) {
      print('❌ Permissions insuffisantes !');
      print('💡 Speech Recognition disponible: $available');
      setState(() {
        _speechPermissionDenied = !hasSpeechPermission;
        _speechAvailable = available;
      });
      
      // If speech is available but permission_handler says no, trust speech_to_text
      if (available) {
        print('✅ Speech_to_text dit que c\'est OK, on continue !');
        if (mounted && _showStartButton) {
          await _startListeningForGo();
        }
        return;
      }
      return;
    }

    if (mounted) {
      setState(() {
        _speechAvailable = available;
        _speechPermissionDenied = false;
        _speechErrorMessage = null;
      });
    }

    if (_speechAvailable && mounted && _showStartButton) {
      await _startListeningForGo();
    }
  }

  Future<void> _startListeningForGo() async {
    if (!_speechAvailable || _goTriggered || !_showStartButton) {
      print('⚠️ Ne peut pas écouter: available=$_speechAvailable, triggered=$_goTriggered, showButton=$_showStartButton');
      return;
    }
    
    if (_speechToText.isListening) {
      print('⚠️ Déjà en écoute');
      return;
    }

    final locales = await _speechToText.locales();
    
    // Chercher la locale française, sinon prendre la première disponible
    final frenchLocale = locales.firstWhere(
      (l) => l.localeId.startsWith('fr'),
      orElse: () => locales.first,
    );
    
    print('🌍 Locale choisie: ${frenchLocale.localeId}');
    
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

    // Vérifier le statut réel après avoir lancé l'écoute
    final isListening = _speechToText.isListening;
    print('🎙️ Écoute démarrée: $isListening');

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

    print('🎤 Brut: "$rawText"');
    print('🧹 Nettoyé: "$sanitized"');
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
      print('🚀 GO TRIGGERED !');
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
    print('❌ Erreur speech: ${error.errorMsg}');
    if (_goTriggered || !_showStartButton) return;

    if (mounted) {
      setState(() {
        _speechErrorMessage = error.errorMsg;
        _isListeningForGo = false;
      });
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
      return;
    }
    _speechRestartTimer?.cancel();
    _speechRestartTimer = Timer(const Duration(milliseconds: 700), () {
      if (mounted) {
        unawaited(_startListeningForGo());
      }
    });
  }

  void _handleWorkoutStartTrigger() {
    print('🏋️ Démarrage du workout...');
    if (!_showStartButton) return;
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

  /// Starts the workout detection process.
  /// This method checks if the camera controller is initialized and not already streaming images.
  /// If the conditions are met, it starts the image stream and begins detecting workouts.
  ///
  /// Returns a [void] that completes when the detection starts.
  void _startDetecting() async {
    if (_controller != null) {
      if (_controller!.value.isStreamingImages) return;
      if (mounted) {
        setState(() {
          _showStartButton = false;
        });
      }

      _startTimer();
      // Start the camera image stream
      // This will call the detectWorkout method in WorkoutAnalyzer
      // with the input image from the camera
      _controller!.startImageStream((image) async {
        // Check if we are already detecting to avoid multiple detections
        if (_isDetecting) return;
        _isDetecting = true;

        try {
          final inputImage = ImageUtils.getInputImage(image, _controller);
          await _workoutAnalyzer.detectWorkout(inputImage, _workoutType);
        } catch (e) {
          print('❌ Erreur détection: $e');
        } finally {
          _isDetecting = false;
        }
      });
    }
  }

  /// Stops the workout detection process and starts a countdown for the celebration overlay.
  /// This method checks if the camera controller is initialized and streaming images.
  /// If so, it cancels the timer, stops the image stream,
  /// and sets a flag to show the celebration overlay.
  /// It also starts a countdown timer that updates the UI every second.
  ///
  /// Returns a [void] that completes when the detection is stopped.
  void _stopDetecting() async {
    if (_controller != null && _controller!.value.isStreamingImages) {
      // Stop the workout timer
      _workoutTimerService.stop();
      await _controller!.stopImageStream();
      _isDetecting = false;
    }

    // Démarrer le compte à rebours
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

  /// Navigates to the WorkoutProgressionPage with the current exercise index and difficulty.
  /// This method creates a new route and passes the necessary parameters,
  /// including the difficulty level, images, starting point, and character images.
  ///
  /// Returns a [void] that completes when the navigation is done.
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
                if (widget.boxType == BoxType.left)
                  LeftBoxWidget(
                      elapsedTime: _elapsedTime,
                      count: _count,
                      targetCount: _targetCount),
                if (widget.boxType == BoxType.bottom)
                  BottomBoxWidget(
                      elapsedTime: _elapsedTime,
                      count: _count,
                      targetCount: _targetCount),

                // Overlay when count hits the target
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
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 48,
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

    print('🔍 Vérification du mot "go" dans: "$text"');

    // Normaliser le texte
    final normalized = text
        .toLowerCase()
        .replaceAll("'", '')
        .replaceAll('-', ' ')
        .trim();

    print('🧹 Normalisé: "$normalized"');

    // Liste de toutes les variantes possibles
    final goCommands = [
      'go',
      'gau',
      'guo',
      'go ',
      ' go',
      'lets go',
      'let go',
      'allez',
      'allez go',
      'vas y',
      'vas-y',
      'vasy',
      'cest parti',
      'c est parti',
      'parti',
      'top',
      'top depart',
      'depart',
      'allons y',
      'on y va',
    ];

    // Vérifier si le texte contient une des commandes
    for (final cmd in goCommands) {
      if (normalized.contains(cmd)) {
        print('✅ Commande "$cmd" détectée !');
        return true;
      }
    }

    // Vérifier les mots individuels
    final words = normalized.split(' ');
    for (final word in words) {
      if (word == 'go' || word == 'gau' || word == 'allez' || word == 'parti') {
        print('✅ Mot "$word" détecté !');
        return true;
      }
    }

    print('❌ Aucune commande détectée');
    return false;
  }
}

class _VoiceStartCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final cameraStrings = t.camera;

    final statusText = !speechAvailable || permissionDenied
        ? cameraStrings.voice_hint_permission
        : errorMessage != null
            ? cameraStrings.voice_hint_error
            : isListening
                ? cameraStrings.voice_hint_listening
                : cameraStrings.voice_hint_tap;

    final statusColor = !speechAvailable || permissionDenied
        ? const Color(0xFFE57207)
        : errorMessage != null
            ? const Color(0xFFE57207)
            : const Color(0xFFF8871F);

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF8871F), Color(0xFFE57207)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF8871F).withOpacity(0.4),
            blurRadius: 24,
            offset: const Offset(0, 12),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.15),
                    Colors.white.withOpacity(0.05),
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(isListening ? 0.3 : 0.2),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: isListening
                                ? [
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.4),
                                      blurRadius: 12,
                                      spreadRadius: 2,
                                    )
                                  ]
                                : [],
                          ),
                          child: Icon(
                            isListening ? Icons.graphic_eq_rounded : Icons.mic_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cameraStrings.voice_hint_title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.5,
                                  shadows: [
                                    Shadow(
                                      color: Color(0x40000000),
                                      offset: Offset(0, 2),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                cameraStrings.voice_hint_body,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.95),
                                  fontSize: 15,
                                  height: 1.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: onPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFFE57207),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.play_arrow_rounded, size: 24),
                            const SizedBox(width: 8),
                            Text(cameraStrings.start_workout),
                          ],
                        ),
                      ),
                    ),
                    if (permissionDenied)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1.5,
                            ),
                          ),
                          child: TextButton.icon(
                            onPressed: () async {
                              await openAppSettings();
                            },
                            icon: const Icon(Icons.settings_rounded, color: Colors.white, size: 20),
                            label: const Text(
                              'Ouvrir les Réglages',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                              backgroundColor: Colors.white.withOpacity(0.15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 18),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: statusColor.withOpacity(0.4),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isListening ? Icons.hearing_rounded : Icons.mic_off_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              statusText,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (lastRecognizedPhrase != null && lastRecognizedPhrase!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFE9CA).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: const Color(0xFFFFE9CA).withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.chat_bubble_outline_rounded,
                                color: Color(0xFFFFE9CA),
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  cameraStrings.voice_hint_last_heard(
                                    phrase: lastRecognizedPhrase!,
                                  ),
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.95),
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
            ),
          ),
        ),
      ),
    );
  }
}