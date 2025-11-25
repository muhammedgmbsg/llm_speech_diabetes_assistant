import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/app_constants.dart';
import '../controllers/chat_controller.dart';

class ChatView extends StatelessWidget {
  ChatView({super.key});
  final ChatController controller = Get.put(ChatController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor, // Arka plan
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.health_and_safety, color: AppConstants.primaryColor),
            SizedBox(width: 8),
            Text("Diyabet Asistanı"),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.record_voice_over),
            onPressed: controller.changeVoice,
            tooltip: "Sesi Değiştir",
          ),
          Obx(() => controller.isSpeaking.value 
            ? IconButton(icon: const Icon(Icons.graphic_eq, color: AppConstants.primaryColor), onPressed: controller.stopSpeaking)
            : const SizedBox()
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: controller.clearChat,
            tooltip: "Sohbeti Temizle",
          )
        ],
      ),
      body: Column(
        children: [
          // --- MESAJ LİSTESİ ---
          Expanded(
            child: Obx(() {
              if (controller.history.isEmpty) {
                return _buildEmptyState();
              }
              return ListView.builder(
                controller: controller.scrollController,
                itemCount: controller.history.length,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 160),
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  final msg = controller.history[index];
                  final isUser = msg['role'] == 'user';
                  return _buildMessageBubble(msg['text']!, isUser, context);
                },
              );
            }),
          ),
          
          // Yükleniyor Göstergesi (Animasyonlu)
          Obx(() => controller.isLoading.value 
            ? Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                     SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                     SizedBox(width: 10),
                     Text("Asistanız yazıyor...", style: TextStyle(color: AppConstants.textLight)),
                  ],
                ),
              ) 
            : const SizedBox()
          ),

          // --- GİRİŞ ALANI (MODERN PANEL) ---
          Container(
           padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Row(
                children: [
                  // Mikrofon Butonu (Animasyonlu)
                  GestureDetector(
                    onLongPressStart: (_) => controller.listen(),
                    onLongPressEnd: (_) => controller.listen(),
                    child: Obx(() => AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: controller.isListening.value ? AppConstants.dangerRed : Colors.grey[100],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        controller.isListening.value ? Icons.mic : Icons.mic_none, 
                        color: controller.isListening.value ? Colors.white : AppConstants.textDark
                      ),
                    )),
                  ),
                  
                  const SizedBox(width: 12),
              
                  // Yazı Alanı
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 234, 232, 232),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: controller.textController,
                        decoration: const InputDecoration(
                          fillColor: const Color.fromARGB(255, 234, 232, 232),
                          hintText: "Bir şeyler sorun...",
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 14),
                        ),
                        onSubmitted: (_) => controller.sendMessage(),
                      ),
                    ),
                  ),
              
                  const SizedBox(width: 12),
              
                  // Gönder Butonu
                  Container(
                    decoration: const BoxDecoration(
                      color: AppConstants.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_upward, color: Colors.white),
                      onPressed: controller.sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
        ],
      ),
    );
  }

  // Boş Durum (Karşılama Ekranı)
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppConstants.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.assistant, size: 60, color: AppConstants.primaryColor),
          ),
          const SizedBox(height: 20),
          const Text(
            "Merhaba! Ben Diyabet Asistanın.",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppConstants.textDark),
          ),
          const SizedBox(height: 8),
          const Text(
            "Bana beslenme veya ölçümlerinle\nilgili sorular sorabilirsin.",
            textAlign: TextAlign.center,
            style: TextStyle(color: AppConstants.textLight),
          ),
        ],
      ),
    );
  }

  // Mesaj Balonu Tasarımı
  Widget _buildMessageBubble(String text, bool isUser, BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isUser ? AppConstants.primaryColor : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: isUser ? const Radius.circular(20) : Radius.zero,
            bottomRight: isUser ? Radius.zero : const Radius.circular(20),
          ),
          boxShadow: [
            if (!isUser) 
              BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, 2))
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                text,
                style: TextStyle(
                  color: isUser ? Colors.white : AppConstants.textDark,
                  fontSize: 15,
                  height: 1.4, // Satır arası boşluk (okunabilirlik için)
                ),
              ),
            ),
            if (!isUser)
              Positioned(
                right: 5,
                bottom: 5,
                child: InkWell(
                  onTap: () => controller.speak(text),
                  child: Icon(Icons.volume_up, size: 16, color: Colors.grey[400]),
                ),
              )
          ],
        ),
      ),
    );
  }
}