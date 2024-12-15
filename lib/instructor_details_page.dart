import 'package:flutter/material.dart';

class InstructorDetailsPage extends StatelessWidget {
  final Map<dynamic, dynamic> instructor;

  const InstructorDetailsPage({required this.instructor, super.key});

  @override
  Widget build(BuildContext context) {
    // Extracting individual average ratings from the instructor map
    final double avgAttendeesFlexibility =
        instructor['avgAttendeesFlexibility'] ?? 0.0;
    final double avgVoiceVolumeAccent =
        instructor['avgVoiceVolumeAccent'] ?? 0.0;
    final double avgTeachingSkills = instructor['avgTeachingSkills'] ?? 0.0;
    final double avgExams = instructor['avgExams'] ?? 0.0;

    // Calculate the overall average
    final double averageRating = (avgAttendeesFlexibility +
            avgVoiceVolumeAccent +
            avgTeachingSkills +
            avgExams) /
        4.0;

    final List<String> comments =
        List<String>.from(instructor['comments'] ?? []);

    return Scaffold(
      appBar: AppBar(
        title: Text(instructor['name']),
        backgroundColor: const Color(0xFF058A4A),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display the individual ratings
            Text(
              'Attendees Flexibility: ${avgAttendeesFlexibility.toStringAsFixed(1)}/5',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Voice Volume & Accent: ${avgVoiceVolumeAccent.toStringAsFixed(1)}/5',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Teaching Skills: ${avgTeachingSkills.toStringAsFixed(1)}/5',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Exams: ${avgExams.toStringAsFixed(1)}/5',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            // Display the overall average rating
            Text(
              'Overall Average Rating: ${averageRating.toStringAsFixed(1)}/5',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            // Button to navigate to the comments page
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CommentsPage(comments: comments),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF058A4A),
              ),
              child: const Text('View Comments'),
            ),
          ],
        ),
      ),
    );
  }
}

class CommentsPage extends StatelessWidget {
  final List<String> comments;

  const CommentsPage({required this.comments, super.key});

  @override
  Widget build(BuildContext context) {
    // Filter out empty or null comments
    final filteredComments =
        comments.where((comment) => comment.trim().isNotEmpty).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Instructor Comments'),
        backgroundColor: const Color(0xFF058A4A),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: filteredComments.isEmpty
            ? const Center(
                child: Text(
                  'No comments available',
                  style: TextStyle(fontSize: 16),
                ),
              )
            : ListView.builder(
                itemCount: filteredComments.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      leading: const Icon(Icons.comment),
                      title: Text(filteredComments[index]),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
