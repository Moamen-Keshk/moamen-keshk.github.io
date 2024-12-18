import 'package:dart_appwrite/dart_appwrite.dart';
import 'config.dart' as config;

final client = Client()
    .setEndpoint('http://localhost/v1')
    .setProject('64816d699f9ed552d22f')
    .setKey(config.API_KEY);

void main(List<String> arguments) async {
  await createDatabase();
  await createCollection();
  await addCourses();
  await createWatchlistCollection();
}

Future<void> createDatabase() async {
  final db = Databases(client);
  await db.create(databaseId: 'flutter_academy_db', name: 'Flutter Academy DB');
}

Future<void> createWatchlistCollection() async {
  final db = Databases(client);
  await db.createCollection(
    databaseId: 'flutter_academy_db',
    collectionId: 'watchlist',
    name: "Watchlist",
    documentSecurity: true,
    permissions: [
      Permission.create(Role.users()),
    ],
  );
  await db.createStringAttribute(
    databaseId: 'flutter_academy_db',
    collectionId: 'watchlist',
    key: 'userId',
    size: 36,
    xrequired: true,
  );
  await db.createStringAttribute(
    databaseId: 'flutter_academy_db',
    collectionId: 'watchlist',
    key: 'courseId',
    size: 36,
    xrequired: true,
  );
  await Future.delayed(const Duration(seconds: 5));
  await db.createIndex(
    databaseId: 'flutter_academy_db',
    collectionId: 'watchlist',
    key: 'course_id_index',
    type: 'key',
    attributes: ['courseId'],
  );
}

final courses = [
  {
    "title": "Flutter Beginners",
    "description":
        "Awesome course for Flutter beginners to learn the basics of Flutter framework",
    "image": "https://www.linkpicture.com/q/course.png",
    "status": "published",
    "published_date": DateTime.now().millisecondsSinceEpoch,
  },
  {
    "title": "Flutter Junior",
    "description":
        "Awesome course for Flutter beginners to learn the basics of Flutter framework",
    "image": "https://www.linkpicture.com/q/course.png",
    "status": "published",
    "published_date": DateTime.now().millisecondsSinceEpoch,
  },
  {
    "title": "Flutter Senior",
    "description":
        "Awesome course for Flutter beginners to learn the basics of Flutter framework",
    "image": "https://www.linkpicture.com/q/course.png",
    "status": "published",
    "published_date": DateTime.now().millisecondsSinceEpoch,
  },
  {
    "title": "Flutter Advanced",
    "description":
        "Awesome course for Flutter beginners to learn the basics of Flutter framework",
    "image": "https://www.linkpicture.com/q/course.png",
    "status": "draft",
    "published_date": DateTime.now().millisecondsSinceEpoch,
  },
];

Future<void> addCourses() async {
  final db = Databases(client);
  for (final course in courses) {
    await db.createDocument(
      databaseId: 'flutter_academy_db',
      collectionId: 'courses',
      documentId: 'unique()',
      data: course,
    );
  }
}

Future<void> createCollection() async {
  final db = Databases(client);
  await db.createCollection(
      databaseId: 'flutter_academy_db',
      collectionId: 'courses',
      name: 'Courses',
      documentSecurity: true,
      permissions: [
        Permission.create(Role.users()),
      ]);
  await db.createStringAttribute(
      databaseId: 'flutter_academy_db',
      collectionId: 'courses',
      key: 'title',
      size: 255,
      xrequired: true);
  await db.createStringAttribute(
      databaseId: 'flutter_academy_db',
      collectionId: 'courses',
      key: 'description',
      size: 1000,
      xrequired: false);
  await db.createStringAttribute(
      databaseId: 'flutter_academy_db',
      collectionId: 'courses',
      key: 'image',
      size: 255,
      xrequired: false);
  await db.createStringAttribute(
      databaseId: 'flutter_academy_db',
      collectionId: 'courses',
      key: 'status',
      size: 20,
      xrequired: false,
      xdefault: 'Draft');
  await db.createIntegerAttribute(
      databaseId: 'flutter_academy_db',
      collectionId: 'courses',
      key: 'published_date',
      xrequired: true);
  await Future.delayed(const Duration(seconds: 5));
  await db.createIndex(
      databaseId: 'flutter_academy_db',
      collectionId: 'courses',
      key: 'status_index',
      type: 'key',
      attributes: ['status']);
}
