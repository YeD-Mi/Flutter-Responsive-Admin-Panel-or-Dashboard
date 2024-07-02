import 'package:admin/constants.dart';
import 'package:admin/models/UsersModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginService {
  Future<UsersModel?> connectWithMail(String email, String password) async {
    try {
      var user = await getPersonalByEmail(email);
      if (user?.password == password) {
        currentUser = user;
        return user;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<UsersModel?> getPersonalByEmail(String userEmail) async {
    final personalRef = FirebaseFirestore.instance.collection('users');
    final querySnapshot =
        await personalRef.where('email', isEqualTo: userEmail).get();

    if (querySnapshot.docs.isEmpty) {
      return null;
    } else {
      final personalDoc = querySnapshot.docs.first;
      currentUser = UsersModel.fromJson(personalDoc.data());
      return currentUser;
    }
  }
}
