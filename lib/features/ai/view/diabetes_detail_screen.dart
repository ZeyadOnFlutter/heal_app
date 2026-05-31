import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../data/model/text_prediction_response.dart';
import '../../chat/rating_widget.dart';
import 'upload_screen.dart';

class DiabetesDetailScreen extends StatelessWidget {
  final DiseaseDetail detail;
  const DiabetesDetailScreen({Key? key, required this.detail}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Diabetes Details'), backgroundColor: Colors.blueAccent),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Colors.blueAccent, Colors.blue], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(children: [
              const Icon(Icons.water_drop, size: 60, color: Colors.white),
              const SizedBox(height: 12),
              const Text('DIABETES', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 8),
              Text('Match: ${detail.percentage.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 18, color: Colors.white70)),
            ]),
          ),
          const SizedBox(height: 24),
          _buildSection('Matched Symptoms', detail.matchedSymptoms.map((s) => '• $s').join('\n'), Icons.check_circle, Colors.blueAccent),
          const SizedBox(height: 16),
          _buildSection('What is Diabetes?', 'Diabetes is a chronic condition that affects how your body turns food into energy.', Icons.info, Colors.blueAccent),
          const SizedBox(height: 16),
          _buildSection('Common Symptoms', '• Increased thirst\n• Frequent urination\n• Fatigue\n• Blurred vision\n• Slow-healing sores', Icons.list, Colors.blueAccent),
          const SizedBox(height: 16),
          _buildSection('Recommendation', 'Consult with a healthcare provider for proper diagnosis.', Icons.medical_services, Colors.blueAccent),
          const SizedBox(height: 16),
          const _DoctorFeedbackSection(disease: 'diabetes', accentColor: Colors.blueAccent),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const UploadScreen(category: 'Diabetes', icon: '🔬', color: Colors.blueAccent, sampleImagePath: 'assets/images/tounge.png'))),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, padding: const EdgeInsets.symmetric(vertical: 16)),
              child: const Text('Continue to Upload Image', style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Icon(icon, color: color, size: 24), const SizedBox(width: 8), Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color))]),
          const SizedBox(height: 12),
          Text(content, style: const TextStyle(fontSize: 14, height: 1.5)),
        ]),
      ),
    );
  }
}

class _DoctorFeedbackSection extends StatelessWidget {
  final String disease;
  final Color accentColor;
  const _DoctorFeedbackSection({required this.disease, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const SizedBox();
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
      builder: (context, snap) {
        if (!snap.hasData || !snap.data!.exists) return const SizedBox();
        final raw = (snap.data!.data() as Map<String, dynamic>?)?['combinedResults'] as List<dynamic>? ?? [];
        final results = raw
            .map((e) => Map<String, dynamic>.from(e))
            .where((r) => (r['disease'] as String? ?? '').toLowerCase() == disease.toLowerCase() && (r['doctorFeedback'] as String? ?? '').isNotEmpty)
            .toList()
          ..sort((a, b) => (b['timestamp'] as String).compareTo(a['timestamp'] as String));
        if (results.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(children: [Icon(Icons.medical_services, color: Colors.grey[400], size: 24), const SizedBox(width: 8), const Text('No doctor feedback yet', style: TextStyle(fontSize: 14, color: Colors.grey))]),
            ),
          );
        }
        final latest = results.first;
        final feedback = latest['doctorFeedback'] as String;
        final doctorId = latest['doctorId'] as String? ?? '';
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [Icon(Icons.medical_services, color: accentColor, size: 24), const SizedBox(width: 8), Text('Doctor Feedback', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: accentColor))]),
              const SizedBox(height: 12),
              Text(feedback, style: const TextStyle(fontSize: 14, height: 1.6)),
              const SizedBox(height: 14),
              const Divider(),
              const SizedBox(height: 8),
              Row(children: [
                const Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 16),
                const SizedBox(width: 6),
                const Text('Doctor Rating:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(width: 8),
                if (doctorId.isNotEmpty) RatingWidget(userId: doctorId) else _FallbackDoctorRating(),
              ]),
            ]),
          ),
        );
      },
    );
  }
}

class _FallbackDoctorRating extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'doctor').limit(1).get(),
      builder: (context, snap) {
        if (!snap.hasData || snap.data!.docs.isEmpty) return const Text('No ratings yet', style: TextStyle(fontSize: 12, color: Colors.grey));
        return RatingWidget(userId: snap.data!.docs.first.id);
      },
    );
  }
}
