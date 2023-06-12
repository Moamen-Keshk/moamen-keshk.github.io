import 'package:appwrite/appwrite.dart';

class AppwriteService {
  static AppwriteService instance = appwriteService;
  final Client client;
  AppwriteService() : client = Client() {
    client
        .setEndpoint('http://localhost/v1')
        .setProject('64816d699f9ed552d22f');
  }
}

final appwriteService = AppwriteService();
