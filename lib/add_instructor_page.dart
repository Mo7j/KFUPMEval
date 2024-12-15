import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';

class AddInstructorPage extends StatefulWidget {
  const AddInstructorPage({super.key});

  @override
  _AddInstructorPageState createState() => _AddInstructorPageState();
}

class _AddInstructorPageState extends State<AddInstructorPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();

  // Ratings as integers
  int _attendeesFlexibility = 3;
  int _voiceVolumeAccent = 3;
  int _teachingSkills = 3;
  int _exams = 3;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  /// Adds or updates the instructor data in Firebase
  Future<void> _addInstructor() async {
    if (_formKey.currentState?.validate() ?? false) {
      final instructorName = _nameController.text.trim();

      try {
        // Retrieve the phone number from SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? phoneNumber = prefs.getString('userPhoneNumber');

        if (phoneNumber == null) {
          throw Exception('Phone number not found. Please log in again.');
        }

        // Prepare the feedback data
        final feedbackData = {
          'phone_number': phoneNumber,
          'attendees_flexibility': _attendeesFlexibility,
          'voice_volume_accent': _voiceVolumeAccent,
          'teaching_skills': _teachingSkills,
          'exams': _exams,
          'comment': _commentController.text.trim(),
        };

        // Reference to the instructor's node in Firebase
        DatabaseReference dbRef = FirebaseDatabase.instance.refFromURL(
            "https://kfupmeval-default-rtdb.firebaseio.com/instructors");

        // Check if the instructor already exists in the database
        final instructorRef = dbRef.child(instructorName);
        final snapshot = await instructorRef.get();

        if (snapshot.exists && snapshot.value != null) {
          // Cast snapshot.value to Map for safe access
          final instructorData = snapshot.value as Map<dynamic, dynamic>;

          // Retrieve or initialize the feedbacks list
          List<dynamic> feedbacks =
              List<dynamic>.from(instructorData['feedbacks'] ?? []);

          // Add the new feedback
          feedbacks.add(feedbackData);

          // Update the feedbacks list in the database
          await instructorRef.update({'feedbacks': feedbacks});
        } else {
          // Instructor doesn't exist; create a new node
          await instructorRef.set({
            'name': instructorName,
            'feedbacks': [feedbackData],
          });
        }

        // Show success message and navigate back to the home page
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Instructor added successfully")),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to add instructor: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      backgroundColor: const Color(0xFFEFEFEF),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add New Instructor',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name field
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Instructor Name *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter the instructor\'s name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Rating fields
                  _buildRatingField(
                      'Attendees Flexibility', _attendeesFlexibility, (value) {
                    setState(() {
                      _attendeesFlexibility = value;
                    });
                  }),
                  _buildRatingField('Voice Volume & Accent', _voiceVolumeAccent,
                      (value) {
                    setState(() {
                      _voiceVolumeAccent = value;
                    });
                  }),
                  _buildRatingField('Teaching Skills', _teachingSkills,
                      (value) {
                    setState(() {
                      _teachingSkills = value;
                    });
                  }),
                  _buildRatingField('Exams', _exams, (value) {
                    setState(() {
                      _exams = value;
                    });
                  }),
                  const SizedBox(height: 20),

                  // Comment field
                  TextFormField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      labelText: 'Comment (Optional)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 40),

                  // Submit button
                  Center(
                    child: ElevatedButton(
                      onPressed: _addInstructor,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF058A4A),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(200, 50),
                      ),
                      child: const Text('Submit'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingField(String label, int rating, Function(int) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: rating > 0 ? () => onChanged(rating - 1) : null,
            ),
            Text('$rating / 5'),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: rating < 5 ? () => onChanged(rating + 1) : null,
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
