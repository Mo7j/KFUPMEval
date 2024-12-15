import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditFeedbackPage extends StatefulWidget {
  final String instructorName;
  final Map<String, dynamic> feedback;

  const EditFeedbackPage({
    super.key,
    required this.instructorName,
    required this.feedback,
  });

  @override
  _EditFeedbackPageState createState() => _EditFeedbackPageState();
}

class _EditFeedbackPageState extends State<EditFeedbackPage> {
  final TextEditingController _commentController = TextEditingController();
  late int _attendeesFlexibility;
  late int _voiceVolumeAccent;
  late int _teachingSkills;
  late int _exams;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    // Initialize fields with existing feedback data
    _commentController.text = widget.feedback['comment'] ?? '';
    _attendeesFlexibility = widget.feedback['attendees_flexibility'] ?? 3;
    _voiceVolumeAccent = widget.feedback['voice_volume_accent'] ?? 3;
    _teachingSkills = widget.feedback['teaching_skills'] ?? 3;
    _exams = widget.feedback['exams'] ?? 3;
  }

  /// Update the feedback in Firebase
  Future<void> _updateFeedback() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        // Retrieve the phone number from SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? phoneNumber = prefs.getString('userPhoneNumber');

        if (phoneNumber == null) {
          throw Exception('Phone number not found. Please log in again.');
        }

        // Prepare updated feedback data
        final updatedFeedback = {
          'phone_number': phoneNumber,
          'attendees_flexibility': _attendeesFlexibility,
          'voice_volume_accent': _voiceVolumeAccent,
          'teaching_skills': _teachingSkills,
          'exams': _exams,
          'comment': _commentController.text.trim(),
        };

        // Reference to the instructor's feedbacks in Firebase
        DatabaseReference dbRef = FirebaseDatabase.instance
            .refFromURL(
                "https://kfupmeval-default-rtdb.firebaseio.com/instructors")
            .child(widget.instructorName)
            .child('feedbacks');

        // Get the current feedbacks
        final snapshot = await dbRef.get();

        if (snapshot.exists && snapshot.value != null) {
          List<dynamic> feedbacks = List<dynamic>.from(snapshot.value as List);

          // Find the index of the feedback to update
          int index = feedbacks.indexWhere((feedback) =>
              feedback is Map &&
              feedback['phone_number'] == phoneNumber &&
              feedback['comment'] == widget.feedback['comment']);

          if (index != -1) {
            feedbacks[index] = updatedFeedback; // Update the feedback
            await dbRef.set(feedbacks); // Save back to the database

            // Show success message and navigate back
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Feedback updated successfully")),
            );
            Navigator.pop(context);
          } else {
            throw Exception("Feedback not found.");
          }
        } else {
          throw Exception("No feedbacks found.");
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update feedback: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Feedback for ${widget.instructorName}'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRatingField('Attendees Flexibility', _attendeesFlexibility,
                  (value) {
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
              _buildRatingField('Teaching Skills', _teachingSkills, (value) {
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
              TextFormField(
                controller: _commentController,
                decoration: const InputDecoration(
                  labelText: 'Comment (Optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 40),
              Center(
                child: ElevatedButton(
                  onPressed: _updateFeedback,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF058A4A),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(200, 50),
                  ),
                  child: const Text('Update Feedback'),
                ),
              ),
            ],
          ),
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
