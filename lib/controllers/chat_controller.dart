import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import '../services/gemini_service.dart';

class ChatController extends GetxController {
  final GeminiService _geminiService = GeminiService();
  
  // Reaktif Değişkenler
  var history = <Map<String, String>>[].obs;
  var isLoading = false.obs;
  var isListening = false.obs;
  var isSpeaking = false.obs;
  
  final textController = TextEditingController();
  final scrollController = ScrollController();

  // --- DÜZELTME: 'late' KALDIRILDI, '?' EKLENDİ ---
  // Bu sayede başlatılmamışsa bile uygulama çökmez.
  stt.SpeechToText? _speech;
  FlutterTts? _flutterTts;
  
  List<dynamic> _availableVoices = [];
  int _currentVoiceIndex = 0;

  @override
  void onInit() {
    super.onInit();
    // Nesneleri hemen oluşturuyoruz (Hata almamak için)
    _speech = stt.SpeechToText();
    _flutterTts = FlutterTts();
    
    _initializeAll();
  }

  Future<void> _initializeAll() async {
    // 1. Servisi Başlat
    await _geminiService.init();
    
    // 2. Geçmişi Yükle
    await _loadHistory();
    
    // 3. Ses Özelliklerini Ayarla
    _initVoiceFeatures();
    
    // 4. Geçmişi Gemini formatına çevir
    List<Content> geminiHistory = [];
    for (var msg in history) {
      if (msg['role'] == 'user') {
        geminiHistory.add(Content.text(msg['text']!));
      } else {
        geminiHistory.add(Content.model([TextPart(msg['text']!)]));
      }
    }
    
    // 5. Sohbeti Başlat
    _geminiService.startChat(geminiHistory);
  }

  void _initVoiceFeatures() async {
    // Güvenlik kontrolü
    if (_flutterTts == null) _flutterTts = FlutterTts();

    try {
      await _flutterTts!.setLanguage("tr-TR");
      await _flutterTts!.setPitch(1.0);
      await _flutterTts!.setSpeechRate(0.5);
      
      // Android 11+ için bekleme (Try-catch içinde olması daha güvenli)
      try {
        await _flutterTts!.awaitSpeakCompletion(true);
      } catch (e) {
        // Eski Android sürümlerinde bu hata verebilir, yoksay.
      }

      dynamic voices = await _flutterTts!.getVoices;
      if (voices != null && voices is List) {
        _availableVoices = voices.where((v) => v.toString().contains('tr')).toList();
        if (_availableVoices.isNotEmpty) {
           var first = _availableVoices[0];
           if(first is Map) await _flutterTts!.setVoice({"name": first["name"], "locale": "tr-TR"});
        }
      }
    } catch (e) {
      debugPrint("Ses ayarları hatası: $e");
    }

    _flutterTts!.setStartHandler(() => isSpeaking.value = true);
    _flutterTts!.setCompletionHandler(() => isSpeaking.value = false);
    _flutterTts!.setCancelHandler(() => isSpeaking.value = false);
  }

  Future<void> sendMessage() async {
    if (textController.text.isEmpty) return;
    
    // Konuşuyorsa sustur
    if (isSpeaking.value) await stopSpeaking();

    final userMsg = textController.text;
    history.add({'role': 'user', 'text': userMsg});
    isLoading.value = true;
    textController.clear();
    
    // Klavye açıksa kapat
    FocusManager.instance.primaryFocus?.unfocus();
    
    _scrollToBottom();

    try {
      final protectedPrompt = '''
      GÖREVİN: Sen nazik bir Diyabet Asistanısın. 
      KULLANICI MESAJI: $userMsg
      Duruma göre:
      1. Selamlaşma ise sıcak karşıla.
      2. Diyabet/Sağlık sorusu ise cevapla.
      3. Konu dışı ise reddet.
      ''';

      final responseText = await _geminiService.sendMessage(protectedPrompt);
      final botMsg = responseText ?? "Hata oluştu.";

      history.add({'role': 'model', 'text': botMsg});
      _saveHistory();
      
      // Cevabı sesli oku
      speak(botMsg);

    } catch (e) {
      history.add({'role': 'model', 'text': "Bağlantı hatası: $e"});
    } finally {
      isLoading.value = false;
      _scrollToBottom();
    }
  }

  // --- SES FONKSİYONLARI ---
  Future<void> listen() async {
    if (_speech == null) return; // Güvenlik

    if (!isListening.value) {
      bool available = await _speech!.initialize();
      if (available) {
        isListening.value = true;
        _speech!.listen(
          onResult: (val) => textController.text = val.recognizedWords,
          localeId: "tr_TR",
        );
      }
    } else {
      isListening.value = false;
      _speech!.stop();
    }
  }

  Future<void> speak(String text) async {
    // Eğer TTS başlatılmadıysa (null ise) işlemi iptal et, çökme!
    if (_flutterTts == null || text.isEmpty) return;

    await _flutterTts!.stop();
    await _flutterTts!.speak(text);
  }

  Future<void> stopSpeaking() async {
    if (_flutterTts != null) {
      await _flutterTts!.stop();
    }
    isSpeaking.value = false;
  }

  Future<void> changeVoice() async {
    if (_availableVoices.isEmpty || _flutterTts == null) return;
    
    _currentVoiceIndex = (_currentVoiceIndex + 1) % _availableVoices.length;
    var voice = _availableVoices[_currentVoiceIndex];
    
    await _flutterTts!.setVoice({"name": voice["name"], "locale": "tr-TR"});
    
    Get.snackbar(
      "Ses Değişti", 
      "Ses ${_currentVoiceIndex + 1}", 
      duration: const Duration(seconds: 1),
      snackPosition: SnackPosition.TOP
    );
    
    speak("Ses deneme bir iki");
  }

  // --- YARDIMCILAR ---
  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? saved = prefs.getString('chat_history');
    if (saved != null) {
      history.value = List<Map<String, String>>.from(json.decode(saved));
    }
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('chat_history', json.encode(history));
  }

  Future<void> clearChat() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('chat_history');
    await stopSpeaking();
    history.clear();
    // Oturumu sıfırla
    _geminiService.startChat([]);
  }

  void _scrollToBottom() {
    // Liste doluyken en alta kaydır
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
}