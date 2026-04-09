import 'package:firebase_auth/firebase_auth.dart';
import 'package:lotel_pms/app/req/request.dart';
import 'package:lotel_pms/infrastructure/api/model/role.model.dart';

class RoleService {
  final _auth = FirebaseAuth.instance;

  Future<List<Role>> getAssignableRoles(int propertyId) async {
    try {
      final token = await _auth.currentUser?.getIdToken();
      final response = await sendGetRequest(
        token,
        "/api/v1/properties/$propertyId/assignable-roles",
      );

      if (response['status'] == 'success') {
        return (response['data'] as List)
            .map((e) => Role.fromResMap(e))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
