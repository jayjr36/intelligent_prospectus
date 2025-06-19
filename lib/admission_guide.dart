import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DITAdmissionsScreen extends StatelessWidget {
  const DITAdmissionsScreen({super.key});

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $uri');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      appBar: AppBar(
        title: const Text(
          'DIT Admission Requirements',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 6,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildIntroCard(),
            const SizedBox(height: 30),
            _buildSectionHeader(context, 'Important Admission Resources'),
            _buildResourcesCard(context),
            const SizedBox(height: 30),
            _buildSectionHeader(context, 'Admission Requirements for NVA Programmes (Level 1-3)'),
            _buildNvaRequirementsCard(context),
            const SizedBox(height: 30),
            _buildSectionHeader(context, 'Admission Requirements for Ordinary Diploma (NTA Level 4-6)'),
            _buildNtaRequirementsCard(context),
            const SizedBox(height: 30),
            _buildSectionHeader(context, 'DIT Vision & Mission'),
            _buildVisionMissionCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildIntroCard() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: const Color(0xFF1E88E5),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Welcome to DIT Admissions!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 15),
            Text(
              "DIT ensures a transparent admission process across Certificate, Diploma, Degree, and Postgraduate levels. We're here to support your academic journey.",
              style: TextStyle(color: Colors.white70, height: 1.5),
            ),
            SizedBox(height: 10),
            Text(
              "We collaborate with TCU, NACTVET, and other agencies to maintain high standards and seamless transitions for all students.",
              style: TextStyle(color: Colors.white70, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResourcesCard(BuildContext context) {
    return _styledCard(
      context,
      backgroundColor: Colors.blue.shade50,
      children: [
        Text(
          "Access up-to-date admission resources here:",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 15),
        _buildLinkButton(
          context,
          'TCU (Undergraduate & Postgraduate Guidebooks)',
          'www.tcu.go.tz',
          'https://www.tcu.go.tz',
        ),
        const SizedBox(height: 10),
        _buildLinkButton(
          context,
          'NACTVET (Diploma Programmes Guidebooks)',
          'www.nacte.go.tz',
          'https://www.nacte.go.tz',
        ),
      ],
    );
  }

  Widget _buildNvaRequirementsCard(BuildContext context) {
    return _styledCard(
      context,
      backgroundColor: Colors.lightGreen.shade50,
      children: [
        Text(
          "DIT is accredited by VETA to offer NVA programs at all campuses:",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 10),
        _buildBulletPoint(context, 'Dar es Salaam Main Campus: ICT'),
        _buildBulletPoint(context, 'Myunga Campus: ICT and Plumbing'),
        _buildBulletPoint(context, 'Mwanza Campus: ICT, Laboratory, Leather Tech'),
        const SizedBox(height: 20),
        _buildRequirementEntry(
          context,
          'NVA Level 1',
          'CSEE, Primary Education Certificate, or equivalent (per VETA).',
        ),
        _buildRequirementEntry(
          context,
          'NVA Level 2',
          'NVA Level 1 or equivalent qualification.',
        ),
        _buildRequirementEntry(
          context,
          'NVA Level 3',
          'NVA Level 2 or equivalent qualification.',
        ),
      ],
    );
  }

  Widget _buildNtaRequirementsCard(BuildContext context) {
    return _styledCard(
      context,
      backgroundColor: Colors.orange.shade50,
      children: [
        Text(
          "General qualifications for NTA Level 4-6 (Ordinary Diploma):",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 15),
        _buildRequirementEntry(
          context,
          'Basic Technician Certificate (NTA Level 4)',
          'CSEE with at least four (4) passes in the following:',
          points: [
            'Physics / Engineering Science',
            'Mathematics',
            'Chemistry',
            'Any other subject',
          ],
        ),
      ],
    );
  }

  Widget _buildVisionMissionCard(BuildContext context) {
    return _styledCard(
      context,
      backgroundColor: Colors.grey.shade100,
      children: [
        const Text(
          'Vision Statement:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 8),
        Text(
          'To become the leading technical education Institution in addressing societal needs.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 20),
        const Text(
          'Mission Statement:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 8),
        Text(
          'To provide competence-based technical education through training, research, innovation, and appropriate technology development.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }

  // 🔧 Utility Methods

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: const Color(0xFF1A237E)),
        ),
        const Divider(color: Color(0xFF1A237E), thickness: 2, height: 20),
      ],
    );
  }

  Widget _buildLinkButton(BuildContext context, String title, String urlText, String url) {
    return ElevatedButton.icon(
      onPressed: () => _launchUrl(url),
      icon: const Icon(Icons.open_in_new, color: Colors.white),
      label: Text(
        '$title ($urlText)',
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1976D2),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 6,
      ),
    );
  }

  Widget _buildRequirementEntry(BuildContext context, String title, String description, {List<String>? points}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(description, style: Theme.of(context).textTheme.bodyLarge),
          if (points != null && points.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: points
                    .map((point) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: Row(
                            children: [
                              const Icon(Icons.circle, size: 6, color: Colors.black87),
                              const SizedBox(width: 8),
                              Expanded(child: Text(point, style: Theme.of(context).textTheme.bodyLarge)),
                            ],
                          ),
                        ))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5.0),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 6, color: Colors.black54),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyLarge)),
        ],
      ),
    );
  }

  Widget _styledCard(BuildContext context, {required Color backgroundColor, required List<Widget> children}) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
      ),
    );
  }
}
