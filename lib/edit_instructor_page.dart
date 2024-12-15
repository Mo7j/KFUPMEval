import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'EditInstructorDetailsPage.dart';

class EditInstructorPage extends StatefulWidget {
  const EditInstructorPage({super.key});

  @override
  _EditInstructorPageState createState() => _EditInstructorPageState();
}

class _EditInstructorPageState extends State<EditInstructorPage> {
  final DatabaseReference _database = FirebaseDatabase.instance
      .refFromURL("https://kfupmeval-default-rtdb.firebaseio.com/instructors");

  List<Map<String, dynamic>> _userInstructors = [];
  String _userPhoneNumber = '';

  @override
  void initState() {
    super.initState();
    _loadUserPhoneNumber();
  }

  /// Load the user's phone number from SharedPreferences
  Future<void> _loadUserPhoneNumber() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? phoneNumber = prefs.getString('userPhoneNumber');

    if (phoneNumber != null) {
      setState(() {
        _userPhoneNumber = phoneNumber;
      });
      _fetchUserInstructors(phoneNumber);
    } else {
      // Show an error message if the phone number is missing
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User phone number not found.')),
      );
    }
  }

  /// Fetch instructors added by the logged-in user
  Future<void> _fetchUserInstructors(String phoneNumber) async {
    try {
      final dataSnapshot = await _database.get();

      if (!dataSnapshot.exists || dataSnapshot.value == null) {
        setState(() {
          _userInstructors = [];
        });
        return;
      }

      final data = dataSnapshot.value as Map<dynamic, dynamic>;
      List<Map<String, dynamic>> userInstructors = [];

      // Iterate through instructors and filter feedbacks
      data.forEach((instructorKey, instructorData) {
        if (instructorData is Map) {
          String name = instructorData['name']?.toString() ?? instructorKey;
          final feedbacks =
              List<dynamic>.from(instructorData['feedbacks'] ?? []);

          // Check if the user has added feedbacks for this instructor
          List<dynamic> userFeedbacks = feedbacks
              .where((feedback) =>
                  feedback is Map && feedback['phone_number'] == phoneNumber)
              .toList();

          if (userFeedbacks.isNotEmpty) {
            userInstructors.add({
              'name': name,
              'feedbacks': userFeedbacks,
            });
          }
        }
      });

      setState(() {
        _userInstructors = userInstructors;
      });
    } catch (e) {
      print("Error fetching user instructors: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load instructors: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Instructor'),
      ),
      body: _userInstructors.isEmpty
          ? const Center(
              child: Text(
                'No instructors found for your account.',
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              itemCount: _userInstructors.length,
              itemBuilder: (context, index) {
                final instructor = _userInstructors[index];
                return Card(
                  margin: const EdgeInsets.all(10),
                  elevation: 5,
                  child: ListTile(
                    title: Text(instructor['name']),
                    subtitle: Text(
                      'Feedbacks: ${instructor['feedbacks'].length}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditInstructorDetailsPage(
                            instructor: instructor,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
