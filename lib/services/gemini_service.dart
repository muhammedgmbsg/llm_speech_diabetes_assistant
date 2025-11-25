import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../constants/app_constants.dart';

class GeminiService {
  late final GenerativeModel _model;
  ChatSession? _chatSession;

  Future<void> init() async {
    debugPrint("📢 GEMINI SERVICE BAŞLATILIYOR...");
      debugPrint("🔑 Okunan API Key (İlk 5 hane): ${AppConstants.apiKey.substring(0, 5)}...");
    _model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: AppConstants.apiKey,
     systemInstruction: Content.text(
        '''ROLÜN: Sen SADECE bir Diyabet ve Sağlık Koçusun. Genel bir yapay zeka asistanı DEĞİLSİN.
        KESİN KURALLAR:
        1. SADECE şu konulara cevap verebilirsin: Diyabet (Tip 1, Tip 2), Kan Şekeri, İnsülin Direnci, Beslenme, Diyet, Egzersiz ve Sağlıklı Yaşam.
        2. Tıbbi teşhis koyma, sadece rehberlik et ve gerekirse doktora yönlendir.
        3. Cevapların kısa, samimi ve Türkçe olsun.
        '''
      ),
    );
  }

  void startChat(List<Content> history) {
    _chatSession = _model.startChat(history: history);
  }

  Future<String?> sendMessage(String prompt) async {
    if (_chatSession == null) return null;
    try {
      final response = await _chatSession!.sendMessage(Content.text(prompt));
      return response.text;
    } catch (e) {
      throw e;
    }
  }
}