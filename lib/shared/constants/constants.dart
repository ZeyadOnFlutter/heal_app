class Constants {
  Constants();

  // ── Notification backend (FastAPI local) ────────────────────────────────────
  // ⚠️  SWITCH THIS when changing between emulator and real device:
  //
  //   Android emulator  → 'http://10.0.2.2:8000'
  //   Real Android device on same WiFi → 'http://YOUR_PC_IP:8000'
  //     (find your PC IP by running `ipconfig` on Windows, look for IPv4)
  //     example: 'http://192.168.1.5:8000'
  static const String notificationBaseUrl = 'https://welcoming-abundance-production-76a3.up.railway.app';

  // ── Existing AI/prediction APIs (unchanged) ─────────────────────────────────
  final String devBaseUrl              = 'https://graduation-project-production-9a81.up.railway.app';
  final String predictBaseUrl          = 'https://questionnaire-diabetes-production.up.railway.app';
  final String skincancerBaseUrl       = 'https://graduation-project-production-82a6.up.railway.app';
  final String skincancerSurveyBaseUrl = 'https://web-production-b4aa.up.railway.app';
  final String textPredictBaseUrl      = 'https://exquisite-eagerness-production.up.railway.app';
}
