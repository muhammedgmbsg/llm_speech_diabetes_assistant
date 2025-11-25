import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../constants/app_constants.dart';
import '../controllers/tracker_controller.dart';

class TrackerView extends StatelessWidget {
  TrackerView({super.key});
  final TrackerController controller = Get.put(TrackerController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Diyabet Takip"),
        actions: [
        
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 100), // Alt menü için boşluk bırak
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. BÜYÜK GRAFİK KARTI (Gradient Background) ---
              Container(
                height: 300,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppConstants.primaryGradient, // <-- Gradient Arkaplan
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: AppConstants.primaryColor.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    
                    const Text("Dairelere tıklayarak değerleri görebilirsiniz.", style: TextStyle(color: Colors.white70, fontSize: 12)),
                    const SizedBox(height: 5),
                    const Text("Kan Şekeri Grafiği", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    Expanded(
                      child: Obx(() {
                        if (controller.records.isEmpty) {
                          return const Center(child: Text("Veri yok", style: TextStyle(color: Colors.white70)));
                        }
                        
                        // Grafik verisi (Son 20)
                        final data = controller.records.length > 20 
                            ? controller.records.sublist(controller.records.length - 20)
                            : controller.records;

                        return LineChart(
                          LineChartData(
                            clipData: const FlClipData.all(),
                            minY: -100, maxY: 500,
                            gridData: FlGridData(
                              show: true, 
                              drawVerticalLine: false,
                              getDrawingHorizontalLine: (value) => FlLine(color: Colors.white.withOpacity(0.1), strokeWidth: 1),
                            ),
                            titlesData: const FlTitlesData(show: false),
                            borderData: FlBorderData(show: false),
                            lineBarsData: [
                              LineChartBarData(
                                spots: data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value['value'].toDouble())).toList(),
                                isCurved: true,
                                color: Colors.white, // Çizgi rengi beyaz
                                barWidth: 3,
                                isStrokeCapRound: true,
                                dotData: FlDotData(
                                  show: true,
                                  getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                                    radius: 4, color: Colors.white, strokeWidth: 2, strokeColor: AppConstants.primaryColor
                                  )
                                ),
                                belowBarData: BarAreaData(
                                  show: true,
                                  gradient: LinearGradient(
                                    colors: [Colors.white.withOpacity(0.3), Colors.transparent],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),
              
              // --- 2. HIZLI GİRİŞ ALANI ---
              Row(
                children: [
                  Expanded(
                    child: Container(
                      
                      height: 45,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(200),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                      ),
                      child: TextField(
                        controller: controller.sugarInputController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                          
                          hintText: "Değer gir (mg/dL)",
                          hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  GestureDetector(
                    onTap: controller.addRecord,
                    child: Container(
                      height: 60,
                      width: 60,
                      decoration: BoxDecoration(
                        gradient: AppConstants.primaryGradient,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: AppConstants.primaryColor.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
                      ),
                      child: const Icon(Icons.add_rounded, color: Colors.white, size: 32),
                    ),
                  ),
                  SizedBox(width: 15,),
                   GestureDetector(
                    onTap: controller.clearRecords,
                    child: Container(
                      
                      height: 60,
                      width: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
                      ),
                      child: IconButton(
              onPressed: controller.clearRecords, 
              icon: const Icon(Icons.delete_forever, color: AppConstants.dangerRed, size: 30)
            ),
                    ),
                  ),
                 
                ],
              ),

              const SizedBox(height: 30),
              const Text("Son Kayıtlar", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppConstants.textDark)),
              const SizedBox(height: 15),

              // --- 3. LİSTE ---
              Obx(() => ListView.builder(
                itemCount: controller.records.length,
                shrinkWrap: true, // ScrollView içinde olduğu için gerekli
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final record = controller.records[controller.records.length - 1 - index];
                  final val = record['value'];
                  final date = DateTime.parse(record['date']);
                  
                  Color color = val < 70 || val > 180 ? AppConstants.dangerRed : (val > 140 ? AppConstants.warningYellow : AppConstants.safeGreen);
                  String status = val < 70 ? "Düşük" : (val > 180 ? "Yüksek" : (val > 140 ? "Sınırda" : "İdeal"));

                  return Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 10, offset: const Offset(0, 5))],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.water_drop_rounded, color: color, size: 24),
                            ),
                            const SizedBox(width: 15),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("$val mg/dL", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppConstants.textDark)),
                                Text(DateFormat('dd MMM, HH:mm').format(date), style: const TextStyle(fontSize: 12, color: AppConstants.textLight)),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(status, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                  );
                },
              )),
            ],
          ),
        ),
      ),
    );
  }
}