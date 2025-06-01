import json
from django.contrib.auth.models import User

from api.serializers import ProfileSerializer

'''
Class for profile utility
'''
class ProfileUtility:

    @staticmethod
    def __insertIntoGreenRedTable(greenRedTable, myValue, partnerValue, description):
        if (type(myValue) != list and type(partnerValue) != list):
            if (myValue == partnerValue):
                column = "green"
            else:
                column = "red"
            element = list(filter(lambda x: x['description'] == description, greenRedTable[column]))
            if (element == []):
                greenRedTable[column].append({'description': description, 'value': [partnerValue]})
            else:
                element[0]['value'].append(partnerValue)
            return
        elif (type(myValue) != list and type(partnerValue) == list):
            for value in partnerValue:
                ProfileUtility.__insertIntoGreenRedTable(greenRedTable, myValue, value, description)
        elif (type(myValue) == list and type(partnerValue) != list):
            if (partnerValue in myValue):
                column = "green"
            else:
                column = "red"
            element = list(filter(lambda x: x['description'] == description, greenRedTable[column]))
            if (element == []):
                greenRedTable[column].append({'description': description, 'value': [partnerValue]})
            else:
                element[0]['value'].append(partnerValue)
        else:
            for partnerValue in partnerValue:
                ProfileUtility.__insertIntoGreenRedTable(greenRedTable, myValue, partnerValue, description)

    @staticmethod
    def compare(user: User, partner: User):
        greenRedTable = {
            'green': [],
            'red': []
        }
        myPersonality = user.personality
        partnerPersonality = partner.personality
        ProfileUtility.__insertIntoGreenRedTable(
            greenRedTable, 
            myPersonality.personality_type_partner,
            partnerPersonality.personality_type_mine,
            "Personality Type"
        )
        ProfileUtility.__insertIntoGreenRedTable(
            greenRedTable, 
            myPersonality.myer_briggs_partner, 
            partnerPersonality.myer_briggs_mine, 
            "MBTI"
        )


        myHobbiesCollecting = user.hobbiescollecting
        partnerHobbiesCollecting = partner.hobbiescollecting
        ProfileUtility.__insertIntoGreenRedTable(
            greenRedTable,
            myHobbiesCollecting.indoor_collecting_mine,
            partnerHobbiesCollecting.indoor_collecting_mine,
            "Indoor Collecting"
        )
        ProfileUtility.__insertIntoGreenRedTable(
            greenRedTable,
            myHobbiesCollecting.outdoor_collecting_mine,
            partnerHobbiesCollecting.outdoor_collecting_mine,
            "Outdoor Collecting"
        )
        ProfileUtility.__insertIntoGreenRedTable(
            greenRedTable,
            myHobbiesCollecting.indoor_hobbies_mine,
            partnerHobbiesCollecting.indoor_hobbies_mine,
            "Indoor Hobbies"
        )
        ProfileUtility.__insertIntoGreenRedTable(
            greenRedTable,
            myHobbiesCollecting.outdoor_hobbies_mine,
            partnerHobbiesCollecting.outdoor_hobbies_mine,
            "Outdoor Hobbies"
        )
        ProfileUtility.__insertIntoGreenRedTable(
            greenRedTable,
            myHobbiesCollecting.competitive_hobbies_mine,
            partnerHobbiesCollecting.competitive_hobbies_mine,
            "Competitive Hobbies"
        )

        myInterests = user.interests
        partnerInterests = partner.interests
        ProfileUtility.__insertIntoGreenRedTable(
            greenRedTable,
            myInterests.sports_mine,
            partnerInterests.sports_mine,
            "Sports Hobbies"
        )

        myTravel = user.travel
        partnerTravel = partner.travel
        ProfileUtility.__insertIntoGreenRedTable(
            greenRedTable,
            myTravel.travel_type_mine,
            partnerTravel.travel_type_mine,
            "Travel Type"
        )
        ProfileUtility.__insertIntoGreenRedTable(
            greenRedTable,
            myTravel.international_travel_mine,
            partnerTravel.international_travel_mine,
            "International Travel"
        )
        ProfileUtility.__insertIntoGreenRedTable(
            greenRedTable,
            myTravel.fav_destination_mine,
            partnerTravel.fav_destination_mine,
            "Favorite Travel Destination"
        )

        ProfileUtility.__insertIntoGreenRedTable(
            greenRedTable,
            myInterests.music_mine,
            partnerInterests.music_mine,
            "Musics"
        )
        ProfileUtility.__insertIntoGreenRedTable(
            greenRedTable,
            myInterests.movies_mine,
            partnerInterests.movies_mine,
            "Movies"
        )
        ProfileUtility.__insertIntoGreenRedTable(
            greenRedTable,
            myInterests.books_mine,
            partnerInterests.books_mine,
            "Books"
        )

        myStatus = user.status
        partnerStatus = partner.status
        ProfileUtility.__insertIntoGreenRedTable(
            greenRedTable,
            myStatus.languages_mine,
            partnerStatus.languages_mine,
            "Language"
        )

        myStatus = user.status
        partnerStatus = partner.status
        ProfileUtility.__insertIntoGreenRedTable(
            greenRedTable, 
            myStatus.pets_mine,
            partnerStatus.pets_mine,
            "Pet"
        )

        myAppearance = user.appearance
        partnerAppearance = partner.appearance
        ProfileUtility.__insertIntoGreenRedTable(
            greenRedTable,
            myAppearance.clothing_style_mine,
            partnerAppearance.clothing_style_mine,
            "Clothing"
        )

        myHabbits = user.habits
        partnerHabbits = partner.habits
        ProfileUtility.__insertIntoGreenRedTable(
            greenRedTable,
            myHabbits.smoking_partner,
            partnerHabbits.smoking_mine,
            "Smoking Habits"
        )
        ProfileUtility.__insertIntoGreenRedTable(
            greenRedTable,
            myHabbits.weed_partner,
            partnerHabbits.weed_mine,
            "420 Habits"
        )
        ProfileUtility.__insertIntoGreenRedTable(
            greenRedTable,
            myHabbits.drinking_partner,
            partnerHabbits.drinking_mine,
            "Drinking Habits"
        )

        ProfileUtility.__insertIntoGreenRedTable(
            greenRedTable,
            myInterests.food_mine,
            partnerInterests.food_mine,
            "Food"
        )

        greenRedTableString = {
            'green': "",
            'red': ""
        }

        for element in greenRedTable["green"]:
            greenRedTableString["green"] += element["description"] + ": "
            for value in element["value"]:
                greenRedTableString["green"] += value + " "
            greenRedTableString["green"] += "\n"
        
        for element in greenRedTable["red"]:
            greenRedTableString["red"] += element["description"] + ": "
            for value in element["value"]:
                greenRedTableString["red"] += value + " "
            greenRedTableString["red"] += "\n"

        return greenRedTableString

'''
Profile is a util class to find 85% matching users
'''
class MatchingProfile:
    __user: User = None
    __list = None
    def __init__(self, user: User, list):
        self.__user = user
        self.__list = list
    
    def __get_all_users(self):
        return self.__list
    
    def get_matches(self, me: User, average_threshold: float = 0.85):
        users = self.__get_all_users()
        myProfile = Profile(self.__user).load_profile_lookingFor()
        matches = []
        for user in users:
            if user.id == self.__user.id:
                continue
            profile = Profile(user).load_profile_myself()
            description = {}
            for group in profile.criteriaGroup:
                groupName = group.get_group_name()
                group_possible_max_score = group.get_possible_max_score()
                score = 0
                for criteria in group.get_criteria():
                    criteriaName = criteria.get_name()
                    weight = criteria.get_weight()
                    desired = myProfile.get_criteria_group_by_name(groupName).get_criteria_by_name(criteriaName).get_value()
                    actual = profile.get_criteria_group_by_name(groupName).get_criteria_by_name(criteriaName).get_value()

                    # need to use different evaluation for criteria with range (ie, height preference is range)
                    range_criteria = [
                        "num_of_kids",
                        "height",
                    ]
                    if criteriaName in range_criteria and len(desired) == 2:
                        eval = self.__evaluate_range_criteria(desired[0], desired[1], actual)
                    eval = self.__evaluate_criteria(desired, actual)
                    score = score + (weight * eval)
                if group_possible_max_score == 0:
                    description[groupName] = 0
                else:
                    description[groupName] = score / group_possible_max_score
            average = sum([v for k, v in description.items()])/len(description)

            descriptionArray = ""
            for k, v in description.items():
                descriptionArray += (str(k) + ": " + str(round(v * 100)) + "%") + "\n"
            if average > average_threshold:
                matches.append(
                    {
                        "id": user.id,
                        "email": user.email,
                        "user": ProfileSerializer(user.profile).data,
                        "average": average,
                        "85%Criteria": descriptionArray,
                        "table": ProfileUtility.compare(me, user)
                    }
                )
        return matches

    def __evaluate_range_criteria(self, min, max, actual):
        if actual >= min and actual <= max:
            return 1
        return 0
    
    #this returns value of 0 - 1. 1 being the perfect match
    def __evaluate_criteria(self, desired, actual):
        if type(desired) == list and len(desired) == 1:
            desired = desired[0]
        if type(actual) == list and len(actual) == 1:
            actual = actual[0]

        # if desired is a list and actual is not a list, 
        # then is is perfect match if the actual is in the desired list
        if type(desired) == list and type(actual) != list:
            desired = map(lambda x: str(x).lower(), desired)
            if str(actual).lower() in desired:
                return 1
            else:
                return 0
        
        # if desired is not a list and actual is a list,
        # then is is perfect match if the desired is in the actual list
        if type(desired) != list and type(actual) == list:
            if str(desired).lower() == "any":
                return 1

            actual = map(lambda x: str(x).lower(), actual)
            if str(desired).lower() in actual:
                return 1
            else:
                return 0
        
        # if desired and actual are both not a list,
        if type(desired) != list and type(actual) != list:
            # if values are string, then we can compare them directly
            if type(desired) == str and type(actual) == str:
                if str(desired).lower() == "any":
                    return 1
                if str(desired).lower() == str(actual).lower():
                    return 1
                else:
                    return 0
            # if values are numbers, then we can compare how close they are
            if isinstance(desired, (int, float)) and isinstance(actual, (int, float)):
                denom = max(desired, actual)
                if denom == 0:
                    return abs(1 - abs(desired - actual))
                else:
                    return 1 - abs(desired - actual) / denom
        
        # if desired and actual are both lists,
        # then we need to evaluate each element in the list
        if type(desired) == list and type(actual) == list:
            eval = 0
            for actual_element in actual:
                eval += self.__evaluate_criteria(desired, actual_element)
            return eval / len(desired)

class Profile:
    __user: User = None

    def __init__(self, user: User):
        self.__user = user
        self.criteriaGroup = [
            self.Group("status"), 
            self.Group("beliefs"), 
            self.Group("appearance"), 
            self.Group("interests"), 
        ]
    
    def load_profile_lookingFor(self):
        try: 
            self.criteriaGroup[0].add_criteria("willing_to_relocate", self.__user.status.willing_to_relocate)
            self.criteriaGroup[0].add_criteria("car", self.__user.status.car_mine)
            self.criteriaGroup[0].add_criteria("relationship_status", self.__user.status.relationship_status_partner)
            self.criteriaGroup[0].add_criteria("num_of_kids", self.__user.status.num_of_kids_partner)
            self.criteriaGroup[0].add_criteria("type_of_kids", self.__user.status.type_of_kids_partner)
            self.criteriaGroup[0].add_criteria("ethnicity", self.__user.status.ethnicity_partner)
            self.criteriaGroup[0].add_criteria("edu_level", self.__user.status.edu_level_partner)
        except:
            pass
        try:
            self.criteriaGroup[1].add_criteria("religion", self.__user.beliefs.religion_partner)
            self.criteriaGroup[1].add_criteria("politics", self.__user.beliefs.politics_partner)
        except:
            pass
        try:
            self.criteriaGroup[2].add_criteria("height", self.__user.appearance.height_partner)
            self.criteriaGroup[2].add_criteria("body_type", self.__user.appearance.body_type_partner)
            self.criteriaGroup[2].add_criteria("eyes", self.__user.appearance.eyes_partner)
            self.criteriaGroup[2].add_criteria("hair_colour", self.__user.appearance.hair_colour_partner)
            self.criteriaGroup[2].add_criteria("hair_type", self.__user.appearance.hair_type_partner)
            self.criteriaGroup[2].add_criteria("facial_hair", self.__user.appearance.facial_hair_partner)
            self.criteriaGroup[2].add_criteria("tattoos", self.__user.appearance.tattoos_partner)
            self.criteriaGroup[2].add_criteria("piercings", self.__user.appearance.piercings_partner)
        except:
            pass
        try:
            self.criteriaGroup[3].add_criteria("sexual_preference", self.__user.interests.sexual_preference_mine)
        except:
            pass
        return self

    def load_profile_myself(self):
        try: 
            self.criteriaGroup[0].add_criteria("willing_to_relocate", self.__user.status.willing_to_relocate)
            self.criteriaGroup[0].add_criteria("car", self.__user.status.car_mine)
            self.criteriaGroup[0].add_criteria("relationship_status", self.__user.status.relationship_status_mine)
            self.criteriaGroup[0].add_criteria("num_of_kids", self.__user.status.num_of_kids_mine)
            self.criteriaGroup[0].add_criteria("type_of_kids", self.__user.status.type_of_kids_mine)
            self.criteriaGroup[0].add_criteria("ethnicity", self.__user.status.ethnicity_mine)
            self.criteriaGroup[0].add_criteria("edu_level", self.__user.status.edu_level_mine)
        except:
            pass
        try:
            self.criteriaGroup[1].add_criteria("religion", self.__user.beliefs.religion_mine)
            self.criteriaGroup[1].add_criteria("politics", self.__user.beliefs.politics_mine)
        except:
            pass
        try:
            self.criteriaGroup[2].add_criteria("height", self.__user.appearance.height_mine)
            self.criteriaGroup[2].add_criteria("body_type", self.__user.appearance.body_type_mine)
            self.criteriaGroup[2].add_criteria("eyes", self.__user.appearance.eyes_mine)
            self.criteriaGroup[2].add_criteria("hair_colour", self.__user.appearance.hair_colour_mine)
            self.criteriaGroup[2].add_criteria("hair_type", self.__user.appearance.hair_type_mine)
            self.criteriaGroup[2].add_criteria("facial_hair", self.__user.appearance.facial_hair_mine)
            self.criteriaGroup[2].add_criteria("tattoos", self.__user.appearance.tattoos_mine)
            self.criteriaGroup[2].add_criteria("piercings", self.__user.appearance.piercings_mine)
        except:
            pass
        try:
            self.criteriaGroup[3].add_criteria("sexual_preference", self.__user.interests.sexual_preference_mine)
        except:
            pass
        return self
    
    def get_criteria_group_by_name(self, name):
        for group in self.criteriaGroup:
            if group.get_group_name() == name:
                return group
        return None

    class Group:
        __group: str = None
        __criteria = None

        def __init__(self, group: str):
            self.__group = group
            self.__criteria = []
            self.__weight_list = json.load(open("85percentCriteria.json"))

        def add_criteria(self, name, value):
            try:
                weight = self.__weight_list[self.__group][name]
            except:
                weight = 1
            self.__criteria.append(self.Criteria(name=name, weight=weight, value=value))
        
        def get_criteria(self):
            return self.__criteria
        
        def get_criteria_by_name(self, name):
            for criteria in self.__criteria:
                if criteria.get_name() == name:
                    return criteria
            return None
        
        def get_group_name(self):
            return self.__group
        
        def get_possible_max_score(self):
            return sum([criteria.get_weight() for criteria in self.__criteria])

        class Criteria:
            __name: str = None
            __weight: float = 0
            __value = None
            def __init__(self, name:str, weight: float, value):
                self.__name = name
                self.__weight = weight
                self.__value = value
            def get_weight(self):
                return self.__weight
            def get_value(self):
                return self.__value
            def get_name(self):
                return self.__name
