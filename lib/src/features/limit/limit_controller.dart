class LimitController {
  double currentValue = 0;

  void init() {
    currentValue = 0;
  }

  void updateUsage(double value) {
    currentValue = value;

    if (value >= 100) {
      print("❌ KUOTA HABIS");
    } else if (value >= 90) {
      print("🚨 KUOTA KRITIS");
    } else if (value >= 75) {
      print("⚠️ KUOTA HAMPIR HABIS");
    } else {
      print("🟢 KUOTA AMAN");
    }
  }

  String getStatus() {
    if (currentValue >= 100) return "Habis ❌";
    if (currentValue >= 90) return "Kritis 🔴";
    if (currentValue >= 75) return "Hampir Habis 🟡";
    return "Aman 🟢";
  }
}