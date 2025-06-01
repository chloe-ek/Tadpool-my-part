import 'package:mobx/mobx.dart';
import 'package:tadpool_app/utils/date_utils.dart';

part 'user_status.g.dart';

class UserStatus extends _UserStatus with _$UserStatus {}

abstract class _UserStatus with Store {
  @observable
  String? relationshipStatusMine;
  
  @observable
  ObservableList<String>? relationshipStatusPartner;
  
  @observable
  double numOfKidsMine = 0;
  
  @observable
  ObservableList<double> numOfKidsPartner = [0.0, 3.0].asObservable();
  
  @observable
  ObservableList<String>? typeOfKidsMine;
  
  @observable
  ObservableList<String>? typeOfKidsPartner;
  
  @observable
  ObservableList<String> sexualOrientationMine = ["Prefer not to say"].asObservable();
  
  @observable
  ObservableList<String> sexualOrientationPartner = ["Any"].asObservable();
  
  @observable
  ObservableList<String>? eduLevelMine;
  
  @observable
  ObservableList<String>? eduLevelPartner;
  
  @observable
  String? ethnicityMine;
  
  @observable
  ObservableList<String>? ethnicityPartner;
  
  @observable
  ObservableList<String> pets = ["None"].asObservable();
  
  @observable
  DateTime? birthDate;
  
  @computed
  int? get age => birthDate != null ? DateUtils.calculateAge(birthDate!) : null;
  
  @observable
  ObservableList<double>? ageRangeSeeking = [18.0, 80.0].asObservable();
  
  @observable
  double distance = 25.0;
  
  @observable
  String? isWillingToRelocate;
  @observable
  bool? isOwnsCar;
  
  @observable
  String? job;
  
  @observable
  String? languages;

  @action
  loadFromJson(Map<String, dynamic> json) {
    relationshipStatusMine = json['relationship_status_mine'];

    relationshipStatusPartner = ObservableList();
    json['relationship_status_partner']?.forEach((e) => relationshipStatusPartner!.add("${e}"));

    numOfKidsMine = double.parse("${json['num_of_kids_mine']}");

    numOfKidsPartner = ObservableList();
    json['num_of_kids_partner']?.forEach((e) => numOfKidsPartner!.add(double.parse("${e}")));

    typeOfKidsMine = ObservableList();
    json['type_of_kids_mine']?.forEach((e) => typeOfKidsMine!.add("${e}"));

    typeOfKidsPartner = ObservableList();
    json['type_of_kids_partner']?.forEach((e) => typeOfKidsPartner!.add("${e}"));

    sexualOrientationMine = ObservableList();
    json['sexual_orientation_mine']?.forEach((e) => sexualOrientationMine!.add("${e}"));

    sexualOrientationPartner = ObservableList();
    json['sexual_orientation_partner']?.forEach((e) => sexualOrientationPartner!.add("${e}"));

    eduLevelMine = ObservableList();
    json['edu_level_mine']?.forEach((e) => eduLevelMine!.add("${e}"));

    eduLevelPartner = ObservableList();
    json['edu_level_partner']?.forEach((e) => eduLevelPartner!.add("${e}"));

    ethnicityMine = json['ethnicity_mine'];

    ethnicityPartner = ObservableList();
    json['ethnicity_partner']?.forEach((e) => ethnicityPartner!.add("${e}"));

    pets = ObservableList();
    json['pets_mine']?.forEach((e) => pets!.add("${e}"));

    birthDate = DateTime.parse(json["birthday_mine"]);
  
    ageRangeSeeking = ObservableList();
    json['age_range_seeking_partner']?.forEach((e) => ageRangeSeeking!.add(double.parse("${e}")));

    distance = double.parse("${json['distance_mine']}");

    isWillingToRelocate = json['willing_to_relocate'];

    isOwnsCar = json['car_mine'];

    job = json['current_job_mine'];

    languages = json['languages_mine'];
  }

  Map<String, dynamic> toJson(){
    return {
      "relationship_status_mine": relationshipStatusMine,
      "relationship_status_partner": relationshipStatusPartner == null ? null : List<dynamic>.from(relationshipStatusPartner!.map((e) => e)),
      "num_of_kids_mine": numOfKidsMine.toInt(),
      "num_of_kids_partner": List<dynamic>.from(numOfKidsPartner!.map((e) => e.toInt())),
      "type_of_kids_mine": typeOfKidsMine == null ? [] : List<dynamic>.from(typeOfKidsMine!.map((e) => e)),
      "type_of_kids_partner": typeOfKidsPartner == null ? [] : List<dynamic>.from(typeOfKidsPartner!.map((e) => e)),
      "sexual_orientation_mine": sexualOrientationMine == null ? [] : List<dynamic>.from(sexualOrientationMine!.map((e) => e)),
      "sexual_orientation_partner": sexualOrientationPartner == null ? [] : List<dynamic>.from(sexualOrientationPartner!.map((e) => e)),
      "edu_level_mine": eduLevelMine == null ? [] : List<dynamic>.from(eduLevelMine!.map((e) => e)),
      "edu_level_partner": eduLevelPartner == null ? [] : List<dynamic>.from(eduLevelPartner!.map((e) => e)),
      "ethnicity_mine": ethnicityMine ?? "",
      "ethnicity_partner": ethnicityPartner == null ? [] : List<dynamic>.from(ethnicityPartner!.map((e) => e)),
      "pets_mine": List<dynamic>.from(pets.map((e) => e)),
      "age_range_seeking_partner": ageRangeSeeking == null? []: ageRangeSeeking!.map((e) => int.parse(e.toString())).toList(),
      "distance_mine": distance.toInt(),
      "willing_to_relocate": isWillingToRelocate,
      "car_mine": isOwnsCar == true ? true : false,
      "current_job_mine": job ?? "",
      "languages_mine": languages ?? "",
      "birthday_mine": birthDate == null ? DateUtils.convertDateTimeToString(DateTime.now()) : DateUtils.convertDateTimeToString(birthDate!)
    };
  }
}
