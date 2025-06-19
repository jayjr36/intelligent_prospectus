import 'package:flutter/material.dart';


// --- Data Model ---
class Course {
  final String name;
  final String level;
  final String campus;
  final String department;
  final String description;

  Course({
    required this.name,
    required this.level,
    required this.campus,
    required this.department,
    required this.description,
  });
}

// --- Sample Data ---
final List<Course> ditCourses = [
  // Ordinary Diploma Programs - Dar es Salaam Main Campus
  Course(
    name: 'Ordinary Diploma Programs (Various Disciplines)',
    level: 'Ordinary Diploma',
    campus: 'Dar es Salaam Main Campus',
    department: 'Various Engineering & Applied Science Departments',
    description: 'A comprehensive range of Ordinary Diploma programs designed to provide foundational knowledge and practical skills in various applied science and engineering disciplines.',
  ),
  Course(
    name: 'Diploma in Biotechnology',
    level: 'Ordinary Diploma',
    campus: 'Dar es Salaam Main Campus',
    department: 'Laboratory Science & Technology Department',
    description: 'Focuses on the application of biological processes and organisms for industrial, medical, and environmental purposes, including genetic engineering and bioprocess technology.',
  ),
  Course(
    name: 'Diploma in Food Science and Technology',
    level: 'Ordinary Diploma',
    campus: 'Dar es Salaam Main Campus',
    department: 'Laboratory Science & Technology Department',
    description: 'Covers the scientific principles of food processing, preservation, quality control, and safety, preparing students for careers in the food industry.',
  ),
  Course(
    name: 'Diploma in Multimedia and Film Technology',
    level: 'Ordinary Diploma',
    campus: 'Dar es Salaam Main Campus',
    department: 'Computer Studies Department',
    description: 'Explores concepts and techniques in multimedia production, digital storytelling, animation, and film technology, equipping students with creative and technical skills.',
  ),
  Course(
    name: 'Diploma in Information Communication Technology (ICT)',
    level: 'Ordinary Diploma',
    campus: 'Dar es Salaam Main Campus',
    department: 'Computer Studies Department',
    description: 'Provides foundational knowledge and practical skills in information systems, networking, software development, and digital communication technologies.',
  ),
  Course(
    name: 'Diploma in Communication Systems Technology',
    level: 'Ordinary Diploma',
    campus: 'Dar es Salaam Main Campus',
    department: 'Electronics & Telecommunications Department',
    description: 'Focuses on the principles, design, and applications of various communication systems, including wireless, optical, and satellite communications.',
  ),

  // Bachelor Degree Programs - Dar es Salaam Main Campus
  Course(
    name: 'Bachelor of Engineering Programs (Various Disciplines)',
    level: 'Bachelor Degree',
    campus: 'Dar es Salaam Main Campus',
    department: 'Civil, Electrical, Electronics & Telecommunications, Mechanical, Computer Studies, Mining, Oil and Gas',
    description: 'Comprehensive Bachelor of Engineering programs across various traditional and modern engineering disciplines, designed to produce highly skilled engineers. These programs have replaced the former Advanced Diploma in Engineering (ADE) courses.',
  ),
  Course(
    name: 'Bachelor of Technology in Laboratory Sciences',
    level: 'Bachelor Degree',
    campus: 'Dar es Salaam Main Campus',
    department: 'Laboratory Science & Technology Department',
    description: 'An advanced program focusing on scientific principles and practical applications in laboratory settings, emphasizing research methodologies and advanced analytical techniques.',
  ),
  Course(
    name: 'Bachelor of Mining Engineering',
    level: 'Bachelor Degree',
    campus: 'Dar es Salaam Main Campus',
    department: 'Civil Department',
    description: 'Prepares students for professional careers in the mining industry, covering geological exploration, mineral extraction, processing, and environmental management.',
  ),
  Course(
    name: 'Bachelor of Oil and Gas Engineering',
    level: 'Bachelor Degree',
    campus: 'Dar es Salaam Main Campus',
    department: 'Mechanical Department',
    description: 'Focuses on the upstream (exploration and production) and downstream (refining and distribution) aspects of the oil and gas industry, including petroleum geology and reservoir engineering.',
  ),

  // Master Degree Programs - Dar es Salaam Main Campus
  Course(
    name: 'Master in Computational Science and Engineering',
    level: 'Master Degree',
    campus: 'Dar es Salaam Main Campus',
    department: 'Computer Studies Department',
    description: 'An advanced program combining computational methods with scientific and engineering problems, focusing on numerical simulations, data analysis, and high-performance computing.',
  ),
  Course(
    name: 'Master of Technology in Computing and Communications',
    level: 'Master Degree',
    campus: 'Dar es Salaam Main Campus',
    department: 'Computer Studies & Electronics & Telecommunications Departments',
    description: 'Focuses on advanced topics in computing, network architectures, and communication systems, preparing students for cutting-edge roles in the IT and telecommunications sectors.',
  ),
  Course(
    name: 'Master of Engineering in Maintenance Management',
    level: 'Master Degree',
    campus: 'Dar es Salaam Main Campus',
    department: 'Mechanical Department',
    description: 'Develops expertise in strategic maintenance operations, asset management, and reliability engineering to optimize industrial productivity and efficiency.',
  ),
  Course(
    name: 'Master of Engineering in Sustainable Energy Engineering',
    level: 'Master Degree',
    campus: 'Dar es Salaam Main Campus',
    department: 'Electrical Department',
    description: 'Addresses the design, implementation, and management of sustainable energy systems, including renewable energy technologies, energy efficiency, and policy.',
  ),

  // Mwanza Campus Programs
  Course(
    name: 'Ordinary Diploma in Science and Laboratory Technology',
    level: 'Ordinary Diploma',
    campus: 'Mwanza Campus',
    department: 'Science & Laboratory Technology Department',
    description: 'Provides foundational skills and knowledge for laboratory operations in various scientific fields, including chemical, biological, and physical sciences.',
  ),
  Course(
    name: 'Ordinary Diploma in Leather Products Technology',
    level: 'Ordinary Diploma',
    campus: 'Mwanza Campus',
    department: 'Leather Products Technology Department',
    description: 'Covers the processes and techniques involved in leather production, tanning, and product design, preparing students for the leather industry.',
  ),

  // Myunga Campus (Songwe) Programs
  Course(
    name: 'Vocational Training - Plumbing and Pipe Fitting (PL)',
    level: 'Vocational Training',
    campus: 'Myunga Campus (Songwe)',
    department: 'Vocational Training',
    description: 'Practical, hands-on training in plumbing installation, maintenance, and pipe fitting techniques for various construction and industrial applications.',
  ),
  Course(
    name: 'Vocational Training - Information Communication Technology (ICT)',
    level: 'Vocational Training',
    campus: 'Myunga Campus (Songwe)',
    department: 'Vocational Training',
    description: 'Hands-on training in essential information and communication technologies, including computer literacy, software applications, and basic networking.',
  ),
];

class DITProgramsScreen extends StatelessWidget {
  const DITProgramsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      appBar: AppBar(
        title: const Text(
          'DIT Programs',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        elevation: 6,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1976D2), Color(0xFF64B5F6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeCard(),
            const SizedBox(height: 30),
            _buildSectionTitle('A Rich Legacy in Technical Education'),
            _buildDivider(),
            _buildHistoryText(),
            const SizedBox(height: 30),
            _buildProgramSection(
              context,
              'Programs at Dar es Salaam Main Campus',
              ditCourses.where((c) => c.campus == 'Dar es Salaam Main Campus').toList(),
            ),
            const SizedBox(height: 30),
            _buildProgramSection(
              context,
              'Programs at Mwanza Campus',
              ditCourses.where((c) => c.campus == 'Mwanza Campus').toList(),
            ),
            const SizedBox(height: 30),
            _buildProgramSection(
              context,
              'Programs at Myunga Campus (Songwe)',
              ditCourses.where((c) => c.campus == 'Myunga Campus (Songwe)').toList(),
            ),
            const SizedBox(height: 30),
            Center(
              child: Text(
                'For more details, visit the DIT website or refer to the prospectus.',
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Discover Your Future at DIT!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.4,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Explore a wide range of academic and vocational programs offered at Dar es Salaam Institute of Technology (DIT).',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1565C0),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      color: Color(0xFF1565C0),
      thickness: 2,
      height: 20,
    );
  }

  Widget _buildHistoryText() {
    return Text(
      "The Dar es Salaam Institute of Technology (DIT) has a proud history that began in 1957. Originally established as the Dar es Salaam Technical Institute, it evolved into a college and ultimately became DIT in 1997 to address the modern demands of technology and innovation.\n\nToday, DIT is a fully accredited institution offering a comprehensive range of full-time, part-time, and professional programs from Diplomas to Master's Degrees across multiple campuses.",
      style: TextStyle(
        fontSize: 16,
        height: 1.6,
        color: Colors.blueGrey.shade800,
      ),
    );
  }

  Widget _buildProgramSection(BuildContext context, String title, List<Course> courses) {
    final Map<String, List<Course>> coursesByLevel = {};
    for (var course in courses) {
      coursesByLevel.putIfAbsent(course.level, () => []).add(course);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(title),
        _buildDivider(),
        ...coursesByLevel.entries.map((entry) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text(
                entry.key,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D47A1),
                ),
              ),
              const SizedBox(height: 10),
              ...entry.value.map((course) => _buildCourseCard(course)).toList(),
            ],
          );
        }).toList(),
      ],
    );
  }

  Widget _buildCourseCard(Course course) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              course.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1976D2),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Department: ${course.department}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              course.description,
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
                color: Colors.blueGrey.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
