import 'package:mobx/mobx.dart';
import 'package:tadpool_app/store/user_profile.dart';

part 'user.g.dart';

class User extends _User with _$User {}

abstract class _User with Store {
  @observable
  int? id;
  @observable
  String? email;
  @observable
  UserProfile? profile;
  @computed
  bool get hasProfile {
    return profile != null &&
          profile?.name != null &&
          profile?.name!.isNotEmpty == true &&
          profile?.facePictureUrl != null &&
          profile?.facePictureUrl!.isNotEmpty == true &&
          profile?.bodyPictureUrl != null &&
          profile?.bodyPictureUrl!.isNotEmpty == true;
}

  @computed
  bool get isVerified => profile?.isVerified ?? false;

  @action
  loadFromJson(Map<String, dynamic> json) {
    id = json['id'];
    email = json['email'];
    profile = json['profile'] != null
        ? UserProfile.fromJson(json['profile'])
        : null;
  }
}
