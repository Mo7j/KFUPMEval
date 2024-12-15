import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'add_instructor_page.dart';
import 'instructor_details_page.dart';
import 'edit_instructor_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseReference _database = FirebaseDatabase.instance
      .refFromURL("https://kfupmeval-default-rtdb.firebaseio.com/instructors");

  List<Map<String, dynamic>> _instructors = [];
  List<Map<String, dynamic>> _filteredInstructors = [];

  int _selectedIndex = 0; // Track current page index
  late PageController _pageController; // Controller to manage the PageView

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fetchInstructors();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Fetch instructors from the database
  Future<void> _fetchInstructors() async {
    try {
      final dataSnapshot = await _database.get();

      // Check if data exists
      if (!dataSnapshot.exists || dataSnapshot.value == null) {
        print("No data available");
        setState(() {
          _instructors = [];
          _filteredInstructors = [];
        });
        return;
      }

      final data = dataSnapshot.value as Map<dynamic, dynamic>?;

      if (data == null) {
        print("Data is null");
        setState(() {
          _instructors = [];
          _filteredInstructors = [];
        });
        return;
      }

      List<Map<String, dynamic>> instructors = [];

      // Iterate through the instructors
      data.forEach((instructorKey, instructorData) {
        if (instructorData is Map) {
          String name = instructorData['name']?.toString() ?? instructorKey;

          // Retrieve feedbacks safely as a list
          final feedbacks = List<Map<dynamic, dynamic>>.from(
              instructorData['feedbacks'] ?? []);

          double sumAttendeesFlexibility = 0;
          double sumVoiceVolumeAccent = 0;
          double sumTeachingSkills = 0;
          double sumExams = 0;
          int feedbackCount = feedbacks.length;

          List<String> comments = [];

          for (var feedback in feedbacks) {
            if (feedback is Map) {
              // Safely parse values
              double attendeesFlexibility =
                  _parseDouble(feedback['attendees_flexibility']);
              double voiceVolumeAccent =
                  _parseDouble(feedback['voice_volume_accent']);
              double teachingSkills = _parseDouble(feedback['teaching_skills']);
              double exams = _parseDouble(feedback['exams']);

              sumAttendeesFlexibility += attendeesFlexibility;
              sumVoiceVolumeAccent += voiceVolumeAccent;
              sumTeachingSkills += teachingSkills;
              sumExams += exams;

              comments.add(feedback['comment']?.toString() ?? '');
            }
          }

          double avgAttendeesFlexibility =
              feedbackCount > 0 ? sumAttendeesFlexibility / feedbackCount : 0.0;
          double avgVoiceVolumeAccent =
              feedbackCount > 0 ? sumVoiceVolumeAccent / feedbackCount : 0.0;
          double avgTeachingSkills =
              feedbackCount > 0 ? sumTeachingSkills / feedbackCount : 0.0;
          double avgExams = feedbackCount > 0 ? sumExams / feedbackCount : 0.0;

          // Calculate overall average
          double overallAvg = (avgAttendeesFlexibility +
                  avgVoiceVolumeAccent +
                  avgTeachingSkills +
                  avgExams) /
              4.0;

          instructors.add({
            'name': name,
            'avgAttendeesFlexibility': avgAttendeesFlexibility,
            'avgVoiceVolumeAccent': avgVoiceVolumeAccent,
            'avgTeachingSkills': avgTeachingSkills,
            'avgExams': avgExams,
            'overallAvg': overallAvg,
            'comments': comments,
          });
        }
      });

      setState(() {
        _instructors = instructors;
        _filteredInstructors = instructors;
      });

      print("Instructors fetched successfully: ${_instructors.length}");
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  /// Helper function to safely parse double values
  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    try {
      return double.tryParse(value.toString()) ?? 0.0;
    } catch (_) {
      return 0.0;
    }
  }

  void _filterInstructors(String query) {
    final filtered = _instructors.where((instructor) {
      final name = instructor['name']?.toString().toLowerCase() ?? '';
      return name.contains(query.toLowerCase());
    }).toList();

    setState(() {
      _filteredInstructors = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search...',
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                    ),
                    onChanged: _filterInstructors,
                  ),
                ),
              ),
              Expanded(
                child: _filteredInstructors.isEmpty
                    ? const Center(child: Text('No instructors found'))
                    : ListView.builder(
                        itemCount: _filteredInstructors.length,
                        itemBuilder: (context, index) {
                          final instructor = _filteredInstructors[index];

                          return Card(
                            margin: const EdgeInsets.all(10),
                            elevation: 5,
                            child: ListTile(
                              title: Text(instructor['name']),
                              subtitle: Text(
                                'Overall Avg Rating: ${instructor['overallAvg'].toStringAsFixed(1)}/5',
                                style: const TextStyle(fontSize: 14),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => InstructorDetailsPage(
                                      instructor: instructor,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
          const EditInstructorPage(),
          const AddInstructorPage(),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25.0),
          child: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.edit),
                label: 'Edit',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.add),
                label: 'Add',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.grey,
            backgroundColor: const Color(0xFF058A4A),
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
          ),
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }
}
