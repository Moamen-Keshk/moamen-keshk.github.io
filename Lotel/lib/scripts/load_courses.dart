import 'package:cloud_firestore/cloud_firestore.dart';

final courses = [
  {
    "title": "Flutter Beginners",
    "description":
        "Awesome course for Flutter beginners to learn the basics of Flutter framework",
    "image": "https://www.linkpicture.com/q/course.png",
    "status": "published",
    "published_date": FieldValue.serverTimestamp(),
  },
  {
    "title": "Flutter Juniors",
    "description":
        "Awesome course for Flutter beginners to learn the basics of Flutter framework",
    "image": "https://www.linkpicture.com/q/course.png",
    "status": "published",
    "published_date": FieldValue.serverTimestamp(),
  },
  {
    "title": "Flutter Seniors",
    "description":
        "Awesome course for Flutter beginners to learn the basics of Flutter framework",
    "image": "https://www.linkpicture.com/q/course.png",
    "status": "published",
    "published_date": FieldValue.serverTimestamp(),
  },
  {
    "title": "Flutter Advanced",
    "description":
        "Awesome course for Flutter beginners to learn the basics of Flutter framework",
    "image": "https://www.linkpicture.com/q/course.png",
    "status": "draft",
    "published_date": FieldValue.serverTimestamp(),
  }
];

Future loadCourses() async {
  final db = FirebaseFirestore.instance;
  for (final course in courses) {
    db.collection('courses').add(course);
  }
}
