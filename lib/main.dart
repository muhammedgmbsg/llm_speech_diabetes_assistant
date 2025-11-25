import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Uygulamadan çıkış için gerekli
import 'package:get/get.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'views/tracker_view.dart';
import 'views/chat_view.dart';
import 'constants/app_constants.dart';

void main() {
  runApp(const DiabetesApp());
}

class DiabetesApp extends StatelessWidget {
  const DiabetesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Diyabet Asistanı',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppConstants.backgroundColor,
        colorSchemeSeed: AppConstants.primaryColor,
        fontFamily: 'Poppins', 
        
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: AppConstants.textDark, 
            fontSize: 22, 
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5
          ),
          iconTheme: IconThemeData(color: AppConstants.textDark),
        ),
        
        cardTheme: CardTheme(
          elevation: 4,
          shadowColor: Colors.black.withOpacity(0.05),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          //color: AppConstants.surfaceColor,
        ),
        
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
      home: const MainLayout(),
    );
  }
}

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;
  
  // Hangi sayfaların gösterileceği (Sadece 2 sayfamız var)
  final List<Widget> _pages = [
    TrackerView(),
    ChatView(),
  ];

  // Çıkış Onay Penceresi
  void _showExitDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.logout_rounded, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 20),
              const Text(
                "Çıkış Yap",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppConstants.textDark),
              ),
              const SizedBox(height: 10),
              const Text(
                "Uygulamadan çıkmak istediğinize emin misiniz?",
                textAlign: TextAlign.center,
                style: TextStyle(color: AppConstants.textLight),
              ),
              const SizedBox(height: 25),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(), // Pencereyi kapat
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: const BorderSide(color: Colors.grey),
                      ),
                      child: const Text("İptal", style: TextStyle(color: Colors.grey)),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Uygulamayı tamamen kapat
                        SystemNavigator.pop(); 
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Çıkış", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, 
      // Eğer index 2 (Çıkış) seçildiyse bile ekranda son kaldığı sayfayı göster
      body: _pages[_selectedIndex > 1 ? 0 : _selectedIndex],
      
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              blurRadius: 20, 
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(0, -5)
            )
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
            child: GNav(
              rippleColor: Colors.grey[300]!,
              hoverColor: Colors.grey[100]!,
              gap: 8,
              activeColor: Colors.white,
              iconSize: 24,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              duration: const Duration(milliseconds: 400),
              tabBackgroundColor: AppConstants.primaryColor,
              color: Colors.grey[600],
              
              tabs: [
                const GButton(
                  icon: Icons.show_chart_rounded,
                  text: 'Takip',
                  backgroundGradient: AppConstants.primaryGradient, 
                ),
                const GButton(
                  icon: Icons.bubble_chart_outlined,
                  text: 'Asistan',
                  backgroundGradient: AppConstants.primaryGradient,
                ),
                // --- ÇIKIŞ BUTONU ---
                GButton(
                  icon: Icons.logout_rounded,
                  text: 'Çıkış',
                  // Çıkış butonu için Kırmızı Gradient
                  backgroundGradient: AppConstants.primaryGradient, 
                ),
              ],
              selectedIndex: _selectedIndex,
              onTabChange: (index) {
                if (index == 2) {
                  // Eğer Çıkış butonuna (Index 2) basıldıysa Dialog göster
                  _showExitDialog();
                  // Sayfayı değiştirme, sadece dialog aç
                } else {
                  // Diğer sayfalara geçiş yap
                  setState(() {
                    _selectedIndex = index;
                  });
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}