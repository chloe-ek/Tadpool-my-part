from rest_framework import serializers
from django.contrib.auth.models import User
from django.contrib.auth import authenticate
from .models import *

class MatchSerializer(serializers.ModelSerializer):
    class Meta:
        model = Match
        fields = '__all__'
    def create(self, validated_data):
        return Match.objects.create(**validated_data)

class ProfileSerializer(serializers.ModelSerializer):
    location = serializers.ReadOnlyField()
    birthday = serializers.ReadOnlyField()
    is_verified = serializers.BooleanField(read_only=True)
    class Meta:
        model = Profile
        fields = "__all__"

    def create(self, validated_data):
        print("validated_data during create:", validated_data)
        return Profile.objects.create(**validated_data)
    
class UserWithProfileSerializer(serializers.ModelSerializer):
    profile = ProfileSerializer(read_only=True)

    class Meta:
        model = User
        fields = ('id', 'username', 'email', 'profile')

class StatusSerializer(serializers.ModelSerializer):
    type_of_kids_partner = serializers.ListField(child=serializers.CharField(), required=False, default=["Any"])
    edu_level_mine = serializers.ListField(child=serializers.CharField(), required=False, default=list)
    edu_level_partner = serializers.ListField(child=serializers.CharField(), required=False, default=["Any"])
    ethnicity_mine = serializers.CharField(required=False, allow_blank=True, default='African-American')
    ethnicity_partner = serializers.ListField(child=serializers.CharField(), required=False, default=["Any"])

    class Meta:
        model = Status
        fields = "__all__"


class BeliefsSerializer(serializers.ModelSerializer):
    religion_mine = serializers.CharField(required=False, allow_blank=True, default='Agnostic')
    religion_partner = serializers.ListField(child=serializers.CharField(), required=False, default=["Any"])
    politics_mine = serializers.CharField(required=False, allow_blank=True, default='Absolutist')
    politics_partner = serializers.ListField(child=serializers.CharField(), required=False, default=["Any"])

    class Meta:
        model = Beliefs
        fields = "__all__"



class AppearanceSerializer(serializers.ModelSerializer):
    body_type_partner = serializers.ListField(child=serializers.CharField(), required=False, default=["Any"])
    facial_hair_mine = serializers.ListField(child=serializers.CharField(), required=False, default=list)
    facial_hair_partner = serializers.ListField(child=serializers.CharField(), required=False, default=["Any"])
    tattoos_mine = serializers.ListField(child=serializers.CharField(), required=False, default=list)
    tattoos_partner = serializers.ListField(child=serializers.CharField(), required=False, default=["Any"])
    piercings_mine = serializers.ListField(child=serializers.CharField(), required=False, default=list)
    piercings_partner = serializers.ListField(child=serializers.CharField(), required=False, default=["Any"])
    body_type_mine = serializers.ListField(child=serializers.CharField(), required=False, default=list)
    body_type_partner = serializers.ListField(child=serializers.CharField(), required=False, default=["Any"])
    height_mine = serializers.IntegerField(required=False, allow_null=True)
    height_partner = serializers.ListField(child=serializers.IntegerField(), required=False, default=list)
    eyes_mine = serializers.CharField(required=False, allow_blank=True, default='Amber')
    eyes_partner = serializers.ListField(child=serializers.CharField(), required=False, default=["Any"])
    hair_colour_mine = serializers.CharField(required=False, allow_blank=True, default='Auburn')
    hair_colour_partner = serializers.ListField(child=serializers.CharField(), required=False, default=list)
    hair_type_mine = serializers.ListField(child=serializers.CharField(), required=False, default=list)
    hair_type_partner = serializers.ListField(child=serializers.CharField(), required=False, default=["Any"])
    clothing_style_mine = serializers.ListField(child=serializers.CharField(), required=False, default=list)

    class Meta:
        model = Appearance
        fields = "__all__"

class InterestsSerializer(serializers.ModelSerializer):
    music_mine = serializers.ListField(child=serializers.CharField(), required=False, default=list)
    movies_mine = serializers.ListField(child=serializers.CharField(), required=False, default=list)
    books_mine = serializers.ListField(child=serializers.CharField(), required=False, default=list)
    sexual_preference_mine = serializers.ListField(child=serializers.CharField(), required=False, default=list)
    food_mine = serializers.ListField(child=serializers.CharField(), required=False, default=list)
    sports_mine = serializers.ListField(child=serializers.CharField(), required=False, default=list)
    favorite_food_mine = serializers.CharField(required=False, allow_blank=True, default='')
    favorite_hot_drink_mine = serializers.CharField(required=False, allow_blank=True, default='')
    favorite_cold_drink_mine = serializers.CharField(required=False, allow_blank=True, default='')
    favorite_dessert_mine = serializers.CharField(required=False, allow_blank=True, default='')

    class Meta:
        model = Interests
        fields = '__all__'



class HabitsSerializer(serializers.ModelSerializer):
    smoking_mine = serializers.ListField(child=serializers.CharField(), required=False, default=list)
    smoking_partner = serializers.ListField(child=serializers.CharField(), required=False, default=list)
    weed_mine = serializers.ListField(child=serializers.CharField(), required=False, default=list)
    weed_partner = serializers.ListField(child=serializers.CharField(), required=False, default=list)
    drinking_mine = serializers.ListField(child=serializers.CharField(), required=False, default=list)
    drinking_partner = serializers.ListField(child=serializers.CharField(), required=False, default=list)

    class Meta:
        model = Habits
        fields = '__all__'



class PersonalitySerializer(serializers.ModelSerializer):
    personality_type_mine = serializers.ListField(child=serializers.CharField(), required=False, default=list)
    personality_type_partner = serializers.ListField(child=serializers.CharField(), required=False, default=list)
    myer_briggs_mine = serializers.CharField(required=False, allow_blank=True, default='')
    myer_briggs_partner = serializers.ListField(child=serializers.CharField(), required=False, default=list)

    class Meta:
        model = Personality
        fields = '__all__'


class HobbiesCollectingSerializer(serializers.ModelSerializer):
    indoor_hobbies_mine = serializers.ListField(child=serializers.CharField(), required=False, default=list)
    outdoor_hobbies_mine = serializers.ListField(child=serializers.CharField(), required=False, default=list)
    indoor_collecting_mine = serializers.ListField(child=serializers.CharField(), required=False, default=list)
    outdoor_collecting_mine = serializers.ListField(child=serializers.CharField(), required=False, default=list)
    competitive_hobbies_mine = serializers.ListField(child=serializers.CharField(), required=False, default=list)

    class Meta:
        model = HobbiesCollecting
        fields = '__all__'



class TravelSerializer(serializers.ModelSerializer):
    travel_type_mine = serializers.ListField(child=serializers.CharField(), required=False, default=list)
    fav_destination_mine = serializers.ListField(child=serializers.CharField(), required=False, default=list)
    international_travel_mine = serializers.CharField(required=False, allow_blank=True, default='')

    class Meta:
        model = Travel
        fields = '__all__'


class UserSerializer(serializers.ModelSerializer):
    is_verified = serializers.SerializerMethodField()
    profile = ProfileSerializer(read_only=True)
    class Meta:
        model = User
        fields = ('id', 'username', 'email', 'is_verified', 'profile')

    def get_is_verified(self, obj):
        try:
            return obj.profile.is_verified
        except Profile.DoesNotExist:
            return False


class RegisterSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ('id', 'username', 'email', 'password')
        extra_kwargs = {'password': {'write_only': True}}

    def create(self, validated_data):
        user = User.objects.create_user(
            username=validated_data['username'],
            email=validated_data['email'],
            password=validated_data['password']
        )
        return user


class LoginSerializer(serializers.Serializer):
    email = serializers.EmailField()
    password = serializers.CharField()

    def validate(self, data):
        email = data.get("email")
        password = data.get("password")

        try:
            user = User.objects.get(email=email)
        except User.DoesNotExist:
            raise serializers.ValidationError("User with this email does not exist")

        user = authenticate(request=self.context.get('request'), email=email, password=password)


        if user and user.is_active:
            return user
        raise serializers.ValidationError("Incorrect Credentials")



def update_validated_data(validated_data, multiple_value_columns):
    choice_model_objects = {key: validated_data[key] for key in
                            validated_data if key in multiple_value_columns}

    for key in choice_model_objects:
        queryset = multiple_value_columns[key].objects.filter(
            value__in=choice_model_objects[key])
        validated_data[key] = list(queryset)

    column_names = multiple_value_columns.keys()
    column_container = dict()
    for name in column_names:
        column_container[name] = validated_data[name]

    for name in column_names:
        if name in validated_data:
            del validated_data[name]

    return validated_data, column_container


def add_set_items_to_db_instance(db_object, set_objects):
    for name in set_objects:
        getattr(db_object, name).set(set_objects[name])

    return db_object
