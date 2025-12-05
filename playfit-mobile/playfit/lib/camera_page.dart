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
import 'package:wakelock_plus/wakelock_plus.dart';
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
import 'package:playfit/services/log_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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
  final LogService _logService = LogService.instance;
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
  Future<void>? _cameraShutdown;
  late final SpeechToText _speechToText;
  bool _speechAvailable = false;
  bool _isListeningForGo = false;
  bool _goTriggered = false;
  Timer? _speechRestartTimer;
  bool _speechPermissionDenied = false;
  String? _speechErrorMessage;
  String? _lastRecognizedPhrase;
  String? _selectedLocaleId;

  WorkoutType workoutTypeFromName(String name) {
    switch (name.toLowerCase().replaceAll('-', '')) {
      case 'squat':
        return WorkoutType.squat;
      case 'jumpingjack':
        return WorkoutType.jumpingJack;
      case 'pushup':
        return WorkoutType.pushUp;
      case 'glutebridge':
        return WorkoutType.gluteBridge;
      case 'pullup':
        return WorkoutType.pullUp;
      case 'highknees':
        return WorkoutType.highKnees;
      default:
        throw Exception('Workout type not recognized: $name');
    }
  }

  @override
  void initState() {
    super.initState();

    unawaited(_enableWakelock());

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

  // Method for activating wakelock
  Future<void> _enableWakelock() async {
    try {
      await WakelockPlus.enable();
      debugPrint('Wakelock enabled - screen will not turn off');
    } catch (e) {
      debugPrint('Error enabling wakelock: $e');
    }
  }

  // Method for disabling wakelock
  Future<void> _disableWakelock() async {
    try {
      await WakelockPlus.disable();
      debugPrint('Wakelock disabled - screen can turn off normally');
    } catch (e) {
      debugPrint('Error disabling wakelock: $e');
    }
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
    final frontCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
    );
    _controller = CameraController(
      frontCamera,
      ResolutionPreset.high,
      enableAudio: false,
    );
    await _controller?.initialize();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _initializeSpeechRecognition() async {
    bool available = false;
    
    try {
      available = await _speechToText.initialize(
        onStatus: _onSpeechStatus,
        onError: _onSpeechError,
        debugLogging: true,
      );
    } catch (e) {
      debugPrint('Speech recognition initialization error: $e');
      available = false;
    }

    var micStatus = await Permission.microphone.status;

    if (!micStatus.isGranted) {
      micStatus = await Permission.microphone.request();
    }

    PermissionStatus? speechStatus;
    if (Platform.isIOS) {
      speechStatus = await Permission.speech.status;
      if (!speechStatus.isGranted && !speechStatus.isPermanentlyDenied) {
        speechStatus = await Permission.speech.request();
      }
    }

    final hasMic = micStatus.isGranted;
    final hasSpeechPermission = available;

    // Pre-select the locale based on the user's language preference
    if (available) {
      try {
        final locales = await _speechToText.locales();
        debugPrint('Available locales: ${locales.map((l) => l.localeId).join(", ")}');
        
        // Get the user's selected language from settings
        const storage = FlutterSecureStorage();
        final userLocale = await storage.read(key: 'selected_locale');
        debugPrint('User selected locale from settings: $userLocale');
        
        // Extract the language code (e.g., "fr" from "fr-FR" or "fr_FR")
        String? userLangCode;
        if (userLocale != null) {
          userLangCode = userLocale.split(RegExp(r'[-_]')).first.toLowerCase();
        }
        
        // Find the locale matching the user's language
        if (userLangCode != null) {
          final userPreferredLocale = locales
              .where((l) => l.localeId.toLowerCase().startsWith(userLangCode!))
              .toList();
          
          if (userPreferredLocale.isNotEmpty) {
            _selectedLocaleId = userPreferredLocale.first.localeId;
            debugPrint('Using user preferred locale: $_selectedLocaleId');
          }
        }
        
        // Fallback: French, then English, then first available
        if (_selectedLocaleId == null) {
          final frenchLocale = locales.where((l) => l.localeId.startsWith('fr')).toList();
          final englishLocale = locales.where((l) => l.localeId.startsWith('en')).toList();
          
          if (frenchLocale.isNotEmpty) {
            _selectedLocaleId = frenchLocale.first.localeId;
          } else if (englishLocale.isNotEmpty) {
            _selectedLocaleId = englishLocale.first.localeId;
          } else if (locales.isNotEmpty) {
            _selectedLocaleId = locales.first.localeId;
          }
          debugPrint('Using fallback locale: $_selectedLocaleId');
        }
      } catch (e) {
        debugPrint('Error getting locales: $e');
      }
    }

    debugPrint('Platform: ${Platform.isAndroid ? "Android" : "iOS"}');
    debugPrint('Speech available: $available, Mic granted: $hasMic');

    if (mounted) {
      setState(() {
        _speechAvailable = available;
        _speechPermissionDenied = !hasSpeechPermission || !hasMic;
        _speechErrorMessage = null;
      });
    }
  }

  Future<void> _startListeningForGo() async {
    if (!_speechAvailable || _goTriggered || !_showStartButton) {
      debugPrint(
          'Cannot listen: available=$_speechAvailable, triggered=$_goTriggered, showButton=$_showStartButton');
      return;
    }

    if (_speechToText.isListening) {
      debugPrint('Already listening');
      return;
    }

    _lastRecognizedPhrase = null;
    _speechErrorMessage = null;

    try {
      // Use the pre-selected locale or find one based on user preferences
      String? localeId = _selectedLocaleId;
      
      if (localeId == null) {
        final locales = await _speechToText.locales();
        if (locales.isNotEmpty) {
          // Get the user's selected language
          const storage = FlutterSecureStorage();
          final userLocale = await storage.read(key: 'selected_locale');
          String? userLangCode;
          if (userLocale != null) {
            userLangCode = userLocale.split(RegExp(r'[-_]')).first.toLowerCase();
          }
          
          // Find the locale matching the user's language
          if (userLangCode != null) {
            final userPreferredLocale = locales
                .where((l) => l.localeId.toLowerCase().startsWith(userLangCode!))
                .toList();
            if (userPreferredLocale.isNotEmpty) {
              localeId = userPreferredLocale.first.localeId;
            }
          }
          
          // Fallback
          if (localeId == null) {
            final frenchLocale = locales.where((l) => l.localeId.startsWith('fr')).toList();
            final englishLocale = locales.where((l) => l.localeId.startsWith('en')).toList();
            
            if (frenchLocale.isNotEmpty) {
              localeId = frenchLocale.first.localeId;
            } else if (englishLocale.isNotEmpty) {
              localeId = englishLocale.first.localeId;
            } else {
              localeId = locales.first.localeId;
            }
          }
        }
      }

      debugPrint('Starting speech recognition with locale: $localeId');

      await _speechToText.listen(
        onResult: _onSpeechResult,
        listenFor: const Duration(seconds: 60),
        pauseFor: const Duration(seconds: 5),
        partialResults: true,
        localeId: localeId,
        cancelOnError: false,
        listenMode: ListenMode.dictation,
      );

      // Small delay to let the listening start
      await Future.delayed(const Duration(milliseconds: 100));

      final isListening = _speechToText.isListening;
      debugPrint('Speech recognition started: $isListening');
      
      if (mounted) {
        setState(() {
          _isListeningForGo = isListening;
        });
      }

      if (!isListening) {
        _scheduleGoListeningRestart();
      }
    } catch (e) {
      debugPrint('Error starting speech recognition: $e');
      if (mounted) {
        setState(() {
          _isListeningForGo = false;
          _speechErrorMessage = e.toString();
        });
      }
      _scheduleGoListeningRestart();
    }
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    final rawText = result.recognizedWords;
    final sanitized = _sanitizeRecognizedText(rawText);

    debugPrint('Speech recognized - Raw: "$rawText" | Sanitized: "$sanitized" | Final: ${result.finalResult}');

    if (mounted) {
      setState(() {
        _lastRecognizedPhrase = rawText.isNotEmpty ? rawText : null;
      });
    }

    if (sanitized.isEmpty) {
      return;
    }

    if (_containsGoCommand(sanitized) && !_goTriggered) {
      _goTriggered = true;
      _handleWorkoutStartTrigger();
    }
  }

  void _onSpeechStatus(String status) {
    debugPrint('Speech status changed: $status');
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
    if (_goTriggered || !_showStartButton) return;

    if (mounted) {
      setState(() {
        _speechErrorMessage = error.errorMsg;
        _isListeningForGo = false;
      });
    }

    if (error.errorMsg != 'error_speech_timeout' &&
        error.errorMsg != 'error_no_match') {
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
      debugPrint(
          'Not restarting: goTriggered=$_goTriggered, showButton=$_showStartButton, available=$_speechAvailable');
      return;
    }
    _speechRestartTimer?.cancel();
    // Redémarre rapidement pour une écoute quasi continue
    _speechRestartTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted && _showStartButton && !_goTriggered && !_speechToText.isListening) {
        debugPrint('Restarting speech recognition (continuous mode)...');
        unawaited(_startListeningForGo());
      }
    });
  }

  void _handleWorkoutStartTrigger() {
    if (!_showStartButton) {
      return;
    }
    if (!_goTriggered) {
      _goTriggered = true;
    }
    setState(() {
      _showStartButton = false;
    });
    _speechErrorMessage = null;
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _startDetecting();
      }
    });
  }

  void _startDetecting() async {
    if (_controller == null) {
      return;
    }
    if (!_controller!.value.isInitialized) {
      return;
    }
    if (_controller!.value.isStreamingImages) {
      return;
    }

    setState(() {
      _showStartButton = false;
    });
    _startTimer();

    try {
      await _controller!.startImageStream((image) async {
        if (_isDetecting) return;
        _isDetecting = true;

        try {
          final inputImage = ImageUtils.getInputImage(image, _controller);
          await _workoutAnalyzer.detectWorkout(inputImage, _workoutType);
        } catch (e, st) {
          _logService.log(
            'Error while processing camera frame for ${_workoutType.name}',
            level: LogLevel.error,
            error: e,
            stackTrace: st,
          );
        } finally {
          _isDetecting = false;
        }
      });
    } on CameraException catch (e) {
      _logService.log(
        'Camera exception on StartImageStream: ${e.code} - ${e.description}',
        level: LogLevel.error,
        error: e,
      );
    } catch (e, st) {
      _logService.log(
        'Unexpected error starting image stream',
        level: LogLevel.error,
        error: e,
        stackTrace: st,
      );
    }
  }

  void _stopDetecting() async {
    if (_controller != null && _controller!.value.isStreamingImages) {
      _workoutTimerService.stop();
      await _controller!.stopImageStream();
      _isDetecting = false;
      _logService.log(
        'Workout detection stream stopped',
        level: LogLevel.info,
      );
    }

    _celebrationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _celebrationCountdown--;
      });
      if (_celebrationCountdown == 0) {
        _celebrationTimer?.cancel();
        unawaited(_goToProgressionPage());
      }
    });
  }

  /// Navigates to the WorkoutProgressionPage with the current exercise index and difficulty.
  /// This method creates a new route and passes the necessary parameters,
  /// including the difficulty level, images, starting point, and character images.
  ///
  /// Returns a [void] that completes when the navigation is done.
  Future<void> _goToProgressionPage() async {
    await _shutdownCamera();
    if (!mounted) {
      return;
    }

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
    _disableWakelock();

    _workoutTimerService.onTick = null;
    _workoutTimerService.stop();
    _celebrationTimer?.cancel();
    _workoutAnalyzer.dispose();
    unawaited(_shutdownCamera());
    _flutterTts.stop();
    _speechRestartTimer?.cancel();
    if (_speechAvailable) {
      _speechToText.stop();
    }
    super.dispose();
  }

  Future<void> _shutdownCamera() {
    if (_cameraShutdown != null) {
      return _cameraShutdown!;
    }
    final controller = _controller;
    if (controller == null) {
      return Future<void>.value();
    }

    _cameraShutdown = _disposeCameraController(controller).whenComplete(() {
      _cameraShutdown = null;
    });
    return _cameraShutdown!;
  }

  Future<void> _disposeCameraController(CameraController controller) async {
    _controller = null;
    try {
      if (controller.value.isStreamingImages) {
        try {
          await controller.stopImageStream();
          _isDetecting = false;
        } catch (e, st) {
          _logService.log(
            'Camera exception while stopping image stream during shutdown',
            level: LogLevel.warning,
            error: e,
            stackTrace: st,
          );
        }
      }
      await controller.dispose();
    } catch (e, st) {
      _logService.log(
        'Camera exception while disposing controller',
        level: LogLevel.warning,
        error: e,
        stackTrace: st,
      );
    }
  }

  String _sanitizeRecognizedText(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '') // Remove punctuation
        .replaceAll(RegExp(r'\s+'), ' ') // Normalize spaces
        .trim();
  }

  bool _containsGoCommand(String text) {
    final goKeywords = [
      // English
      'go', 'start', 'begin', 'ready', 'let\'s go', 'lets go', 'let go',
      // French
      'vas-y', 'vasy', 'va si', 'démarre', 'demarre', 'commence', 'prêt', 'pret',
      'allons-y', 'allonsy', 'allez', 'départ', 'depart', 'cest parti', 'c\'est parti',
      'partez', 'parti', 'top', 'hop', 'ok', 'oui', 'yes', 'yeah',
      // Common phonetic variations
      'gaux', 'gauche', 'beau', 'gow',
    ];
    
    // Check exact keywords and variations
    final words = text.split(' ');
    for (final keyword in goKeywords) {
      if (text.contains(keyword)) {
        debugPrint('Go command detected: "$keyword" in "$text"');
        return true;
      }
    }
    
    // Check if an individual word matches approximately
    for (final word in words) {
      if (word.length >= 2 && goKeywords.any((k) => k.startsWith(word) || word.startsWith(k))) {
        debugPrint('Partial go command detected: "$word" in "$text"');
        return true;
      }
    }
    
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
    if (widget.speechAvailable && !widget.permissionDenied) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          final cameraState =
              context.findAncestorStateOfType<_CameraViewState>();
          if (cameraState != null &&
              cameraState._showStartButton &&
              !cameraState._goTriggered) {
            cameraState._startListeningForGo();
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cameraStrings = t.camera;

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
                    widget.isListening
                        ? Icons.graphic_eq_rounded
                        : Icons.mic_rounded,
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
                    cameraStrings.open_settings,
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
            // Affichage de ce que le téléphone a détecté
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: widget.lastRecognizedPhrase != null && widget.lastRecognizedPhrase!.isNotEmpty
                    ? playfitOrange.withOpacity(0.15)
                    : AppStyles.grey.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: widget.lastRecognizedPhrase != null && widget.lastRecognizedPhrase!.isNotEmpty
                      ? playfitOrange.withOpacity(0.4)
                      : AppStyles.grey.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  // Indicateur d'écoute animé
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: widget.isListening
                          ? Colors.green.withOpacity(0.2)
                          : AppStyles.grey.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      widget.isListening ? Icons.hearing_rounded : Icons.mic_rounded,
                      color: widget.isListening ? Colors.green : AppStyles.grey.withOpacity(0.5),
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.lastRecognizedPhrase != null && widget.lastRecognizedPhrase!.isNotEmpty
                          ? '"${widget.lastRecognizedPhrase}"'
                          : widget.isListening ? 'À l\'écoute...' : 'Aucun mot détecté',
                      style: GoogleFonts.amaranth(
                        color: widget.lastRecognizedPhrase != null && widget.lastRecognizedPhrase!.isNotEmpty
                            ? AppStyles.grey
                            : AppStyles.grey.withOpacity(0.5),
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
