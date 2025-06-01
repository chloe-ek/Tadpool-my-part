import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:mobx/mobx.dart';
import 'package:tadpool_app/services/user_profile_service.dart';
import 'package:tadpool_app/store/user_profile/appearance.dart';
import 'package:tadpool_app/store/user_profile/beliefs.dart';
import 'package:tadpool_app/store/user_profile/habits.dart';
import 'package:tadpool_app/store/user_profile/hobbies_collecting.dart';
import 'package:tadpool_app/store/user_profile/interests.dart';
import 'package:tadpool_app/store/user_profile/personality.dart';
import 'package:tadpool_app/store/user_profile/travel.dart';
import 'package:tadpool_app/store/user_profile/user_status.dart';

part 'user_profile.g.dart';

class UserProfile extends _UserProfile with _$UserProfile {
  UserProfile();
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final instance = UserProfile();
    instance.loadFromJson(json);
    return instance;
  }
}

abstract class _UserProfile with Store {
  @observable
  String? name;
  @observable
  String? facePictureUrl;
  @observable
  String? bodyPictureUrl;
  @observable
  String? location;
  @observable
  UserStatus status = UserStatus();
  @observable
  HobbiesCollecting hobbiesCollecting = HobbiesCollecting();
  @observable
  Beliefs beliefs = Beliefs();
  @observable
  Appearance appearance = Appearance();
  @observable
  Interests interests = Interests();
  @observable
  Habits habits = Habits();
  @observable
  Personality personality = Personality();
  @observable
  Travel travel = Travel();
  @observable
  bool isVerified = false;

  @action
  loadFromJson(Map<String, dynamic> json) {
    
    if (json == null) {
      print("Profile is null in loadFromJson");
      return;
    }

    name = json['name'] is Map ? json['name']['value'] ?? '' : json['name'];
    facePictureUrl = json['face_picture_URL'];
    bodyPictureUrl = json['body_picture_URL'];
    location = json['location'];
    isVerified = json['is_verified'] ?? false;


    status = UserStatus();
    if (json['status'] != null) status.loadFromJson(json['status']);

    hobbiesCollecting = HobbiesCollecting();
    if (json['hobbies_collecting'] != null) hobbiesCollecting.loadFromJson(json['hobbies_collecting']);

    beliefs = Beliefs();
    if (json['beliefs'] != null) beliefs.loadFromJson(json['beliefs']);

    appearance = Appearance();
    if (json['appearance'] != null) appearance.loadFromJson(json['appearance']);

    interests = Interests();
    if (json['interests'] != null) interests.loadFromJson(json['interests']);

    habits = Habits();
    if (json['habits'] != null) habits.loadFromJson(json['habits']);

    personality = Personality();
    if (json['personality'] != null) personality.loadFromJson(json['personality']);

    travel = Travel();
    if (json['travel'] != null) travel.loadFromJson(json['travel']);
  }


  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'face_picture_URL': facePictureUrl,
      'body_picture_URL': bodyPictureUrl,
      'location': location,
      'is_verified': isVerified,
      'status': status.toJson(),
      'beliefs': beliefs.toJson(),
      'appearance': appearance.toJson(),
      'interests': interests.toJson(),
      'habits': habits.toJson(),
      'personality': personality.toJson(),
      'hobbies_collecting': hobbiesCollecting.toJson(),
      'travel': travel.toJson()
    };
}

}
