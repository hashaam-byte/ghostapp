// lib/core/services/voice_service.dart
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';

class VoiceService extends ChangeNotifier {
  late stt.SpeechToText _speech;
  late FlutterTts _tts;
  
  bool _isListening = false;
  bool _isInitialized = false;
  String _lastWords = '';
  double _confidence = 0.0;
  
  bool get isListening => _isListening;
  bool get isInitialized => _isInitialized;
  String get lastWords => _lastWords;
  double get confidence => _confidence;
  
  Future<void> initialize() async {
    try {
      _speech = stt.SpeechToText();
      _tts = FlutterTts();
      
      // Request microphone permission
      final status = await Permission.microphone.request();
      if (!status.isGranted) {
        debugPrint('Microphone permission denied');
        return;
      }
      
      // Initialize speech recognition
      _isInitialized = await _speech.initialize(
        onStatus: (status) => debugPrint('Speech status: $status'),
        onError: (error) => debugPrint('Speech error: $error'),
      );
      
      // Configure TTS
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.5);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
      
      debugPrint('Voice service initialized: $_isInitialized');
      notifyListeners();
    } catch (e) {
      debugPrint('Voice service init error: $e');
      _isInitialized = false;
    }
  }
  
  Future<void> startListening({
    required Function(String) onResult,
    Function(String)? onPartial,
  }) async {
    if (!_isInitialized) {
      debugPrint('Voice service not initialized');
      return;
    }
    
    if (_isListening) {
      debugPrint('Already listening');
      return;
    }
    
    _isListening = true;
    _lastWords = '';
    notifyListeners();
    
    await _speech.listen(
      onResult: (result) {
        _lastWords = result.recognizedWords;
        _confidence = result.confidence;
        
        if (result.finalResult) {
          onResult(_lastWords);
          stopListening();
        } else if (onPartial != null) {
          onPartial(_lastWords);
        }
        
        notifyListeners();
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
      localeId: 'en_US',
      cancelOnError: true,
    );
  }
  
  Future<void> stopListening() async {
    if (_isListening) {
      await _speech.stop();
      _isListening = false;
      notifyListeners();
    }
  }
  
  Future<void> speak(String text, {String? mood}) async {
    try {
      // Adjust voice based on mood
      if (mood == 'excited') {
        await _tts.setSpeechRate(0.6);
        await _tts.setPitch(1.2);
      } else if (mood == 'calm') {
        await _tts.setSpeechRate(0.4);
        await _tts.setPitch(0.9);
      } else {
        await _tts.setSpeechRate(0.5);
        await _tts.setPitch(1.0);
      }
      
      await _tts.speak(text);
    } catch (e) {
      debugPrint('TTS error: $e');
    }
  }
  
  Future<void> stop() async {
    await _tts.stop();
  }
  
  // Voice command parsing
  VoiceCommand? parseCommand(String text) {
    final lower = text.toLowerCase().trim();
    
    // Focus commands
    if (lower.contains('focus') || lower.contains('study')) {
      return VoiceCommand(
        type: VoiceCommandType.startFocus,
        parameters: {'duration': 25},
      );
    }
    
    // Lock apps
    if (lower.contains('lock') && (lower.contains('app') || lower.contains('apps'))) {
      return VoiceCommand(type: VoiceCommandType.lockApps);
    }
    
    // Check XP
    if (lower.contains('xp') || lower.contains('level')) {
      return VoiceCommand(type: VoiceCommandType.checkXP);
    }
    
    // Check tasks
    if (lower.contains('task') || lower.contains('todo')) {
      return VoiceCommand(type: VoiceCommandType.viewTasks);
    }
    
    // Sleep mode
    if (lower.contains('sleep') || lower.contains('night')) {
      return VoiceCommand(type: VoiceCommandType.sleepMode);
    }
    
    // General chat
    return VoiceCommand(
      type: VoiceCommandType.chat,
      parameters: {'message': text},
    );
  }
  
  @override
  void dispose() {
    _speech.stop();
    _tts.stop();
    super.dispose();
  }
}

enum VoiceCommandType {
  startFocus,
  lockApps,
  checkXP,
  viewTasks,
  sleepMode,
  chat,
}

class VoiceCommand {
  final VoiceCommandType type;
  final Map<String, dynamic>? parameters;
  
  VoiceCommand({
    required this.type,
    this.parameters,
  });
}