import 'package:flutter/material.dart';
import 'EditFeedbackPage.dart';

class EditInstructorDetailsPage extends StatelessWidget {
  final Map<String, dynamic> instructor;

  const EditInstructorDetailsPage({super.key, required this.instructor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit ${instructor['name']}'),
      ),
      body: ListView.builder(
        itemCount: instructor['feedbacks'].length,
        itemBuilder: (context, index) {
          final feedback = instructor['feedbacks'][index];
          return Card(
            margin: const EdgeInsets.all(10),
            child: ListTile(
              title: Text('Feedback ${index + 1}'),
              subtitle: Text(
                'Comment: ${feedback['comment']}\n'
                'Attendees Flexibility: ${feedback['attendees_flexibility']}\n'
                'Voice Volume & Accent: ${feedback['voice_volume_accent']}\n'
                'Teaching Skills: ${feedback['teaching_skills']}\n'
                'Exams: ${feedback['exams']}',
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditFeedbackPage(
                      instructorName: instructor['name'],
                      feedback: Map<String, dynamic>.from(feedback),
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
