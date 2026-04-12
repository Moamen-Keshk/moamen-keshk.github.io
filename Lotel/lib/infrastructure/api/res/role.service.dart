import 'package:firebase_auth/firebase_auth.dart';
import 'package:lotel_pms/app/req/request.dart';
import 'package:lotel_pms/infrastructure/api/model/role.model.dart';

class RoleService {
  final _auth = FirebaseAuth.instance;

  Future<List<Role>> getAssignableRoles(int propertyId) async {
    final token = await _auth.currentUser?.getIdToken();
    final response = await sendGetRequestOrThrow(
      token,
      "/api/v1/properties/$propertyId/assignable-roles",
      fallbackMessage: 'Failed to load assignable roles.',
    );

    if (response is! Map<String, dynamic> || response['status'] != 'success') {
      throw ApiRequestException('Failed to load assignable roles.');
    }

    final data = response['data'];
    if (data is! List) {
      throw ApiRequestException('Invalid role response from server.');
    }

    return data.map((e) => Role.fromResMap(e)).toList();
  }
}
