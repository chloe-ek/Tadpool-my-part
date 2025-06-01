# from turtle import distance
from math import dist
from unicodedata import name
from django.db import models
from django.contrib.auth.models import User
from django.db.models.signals import post_save
from django.dispatch import receiver
from django.db.models import UniqueConstraint
from geopy.geocoders import Nominatim
from django.contrib.postgres.fields import ArrayField
import uuid

class Profile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    uuid = models.UUIDField(default=uuid.uuid4, editable=False, unique=True)
    fcm_token = models.CharField(max_length=512, null=True)
    name = models.CharField(max_length=50, null=True)
    face_picture_URL = models.CharField(max_length=128, null=True)
    body_picture_URL = models.CharField(max_length=128, null=True)
    latitude = models.FloatField(blank=True, null=True)
    longitude = models.FloatField(blank=True, null=True)
    is_verified = models.BooleanField(default=False)
    
    @property
    def location(self):
        try:
            geolocator = Nominatim(user_agent="tadpool")
            location = geolocator.reverse(f"{self.latitude}, {self.longitude}")
            return ", ".join(location.address.split(",")[:3])
        except:
            return "Unknown"
    
    @property
    def birthday(self):
        try:
            return self.user.status.birthday_mine
        except:
            return "Unknown"
        
    def __str__(self):
        return self.user.username


@receiver(post_save, sender=User)
def create_user_profile(sender, instance, created, **kwargs):
    if created:
        Profile.objects.create(user=instance)

@receiver(post_save, sender=User)
def save_user_profile(sender, instance, **kwargs):
    instance.profile.save()


class Match(models.Model):
    owner = models.ForeignKey(User, on_delete=models.CASCADE, related_name='user1')
    partner = models.ForeignKey(User, on_delete=models.CASCADE, related_name='user2')
    created_at = models.DateTimeField(auto_now_add=True)
    partner_accepted = models.BooleanField(default=False)
    owner_accepted = models.BooleanField(default=True)

    class Meta:
        constraints = [
            UniqueConstraint(
                name='unique_match_room',
                fields=['owner', 'partner'],
            )
        ]

    def save(self, *args, **kwargs):
        # Always ensure (lower_id, higher_id) ordering
        if self.owner.id > self.partner.id:
            self.owner, self.partner = self.partner, self.owner
            self.owner_accepted, self.partner_accepted = self.partner_accepted, self.owner_accepted
        super().save(*args, **kwargs)

class Status(models.Model):
    relationship_status_mine = models.CharField(max_length=128)
    relationship_status_partner = ArrayField(models.CharField(max_length=128))
    num_of_kids_mine = models.IntegerField()
    num_of_kids_partner = ArrayField(models.IntegerField(), blank=True, default=list)
    type_of_kids_mine = ArrayField(models.CharField(max_length=128), blank=True, default=list)
    type_of_kids_partner = ArrayField(models.CharField(max_length=128), blank=True, default=["Any"])
    sexual_orientation_mine = ArrayField(models.CharField(max_length=128), blank=True, default=list)
    sexual_orientation_partner = ArrayField(models.CharField(max_length=128), blank=True, default=list)
    edu_level_mine = ArrayField(models.CharField(max_length=128), blank=True, default=list)
    edu_level_partner = ArrayField(models.CharField(max_length=128), blank=True, default=["Any"])
    ethnicity_mine = models.CharField(max_length=128, blank=True, null=True, default='African-American')
    ethnicity_partner = ArrayField(models.CharField(max_length=128), blank=True, default=["Any"])
    pets_mine = ArrayField(models.CharField(max_length=128), blank=True, default=list)
    birthday_mine = models.DateField()
    age_range_seeking_partner = ArrayField(models.IntegerField(), size=2)
    car_mine = models.BooleanField(default=False)
    willing_to_relocate = models.CharField(max_length=128)
    distance_mine = models.FloatField(blank=True, null=True)
    current_job_mine = models.CharField(max_length=128, blank=True)
    languages_mine = models.CharField(max_length=128, blank=True)
    user = models.OneToOneField(User, on_delete=models.CASCADE)



class Beliefs(models.Model):
    religion_mine = models.CharField(max_length=128, blank=True, null=True, default='Agnostic')
    religion_partner = ArrayField(models.CharField(max_length=128), blank=True, default=["Any"])
    politics_mine = models.CharField(max_length=128, blank=True, null=True, default='Absolutist')
    politics_partner = ArrayField(models.CharField(max_length=128), blank=True, default=["Any"])
    user = models.OneToOneField(User, on_delete=models.CASCADE)



class Appearance(models.Model):
    facial_hair_mine = ArrayField(models.CharField(max_length=128), blank=True, default=list)
    facial_hair_partner = ArrayField(models.CharField(max_length=128), blank=True, default=["Any"])
    tattoos_mine = ArrayField(models.CharField(max_length=128), blank=True, default=list)
    tattoos_partner = ArrayField(models.CharField(max_length=128), blank=True, default=["Any"])
    piercings_mine = ArrayField(models.CharField(max_length=128), blank=True, default=list)
    piercings_partner = ArrayField(models.CharField(max_length=128), blank=True, default=["Any"])
    body_type_mine = ArrayField(models.CharField(max_length=128), blank=True, default=list)
    body_type_partner = ArrayField(models.CharField(max_length=128), blank=True, default=["Any"])
    height_mine = models.IntegerField(blank=True, null=True)
    height_partner = ArrayField(models.IntegerField(), size=2, blank=True, default=list)
    eyes_mine = models.CharField(max_length=128, blank=True, null=True, default='Amber')
    eyes_partner = ArrayField(models.CharField(max_length=128), blank=True, default=["Any"])
    hair_colour_mine = models.CharField(max_length=128, blank=True, null=True, default='Auburn')
    hair_colour_partner = ArrayField(models.CharField(max_length=128), blank=True, default=list)
    hair_type_mine = ArrayField(models.CharField(max_length=128), blank=True, default=list)
    hair_type_partner = ArrayField(models.CharField(max_length=128), blank=True, default=["Any"])
    clothing_style_mine = ArrayField(models.CharField(max_length=128), blank=True, default=list)
    user = models.OneToOneField(User, on_delete=models.CASCADE)


class Interests(models.Model):
    music_mine = ArrayField(models.CharField(max_length=128), blank=True, default=list)
    movies_mine = ArrayField(models.CharField(max_length=128), blank=True, default=list)
    books_mine = ArrayField(models.CharField(max_length=128), blank=True, default=list)
    sexual_preference_mine = ArrayField(models.CharField(max_length=128), blank=True, default=list)
    food_mine = ArrayField(models.CharField(max_length=128), blank=True, default=list)
    sports_mine = ArrayField(models.CharField(max_length=128), blank=True, default=list)
    favorite_food_mine = models.CharField(max_length=128, blank=True, default='')
    favorite_hot_drink_mine = models.CharField(max_length=128, blank=True, default='')
    favorite_cold_drink_mine = models.CharField(max_length=128, blank=True, default='')
    favorite_dessert_mine = models.CharField(max_length=128, blank=True, default='')
    user = models.OneToOneField(User, on_delete=models.CASCADE)


class Habits(models.Model):
    smoking_mine = ArrayField(models.CharField(max_length=128), blank=True, default=list)
    smoking_partner = ArrayField(models.CharField(max_length=128), blank=True, default=list)
    weed_mine = ArrayField(models.CharField(max_length=128), blank=True, default=list)
    weed_partner = ArrayField(models.CharField(max_length=128), blank=True, default=list)
    drinking_mine = ArrayField(models.CharField(max_length=128), blank=True, default=list)
    drinking_partner = ArrayField(models.CharField(max_length=128), blank=True, default=list)
    user = models.OneToOneField(User, on_delete=models.CASCADE)


class Personality(models.Model):
    personality_type_mine = ArrayField(models.CharField(max_length=128), blank=True, default=list)
    personality_type_partner = ArrayField(models.CharField(max_length=128), blank=True, default=list)
    myer_briggs_mine = models.CharField(max_length=128, blank=True, default='')
    myer_briggs_partner = ArrayField(models.CharField(max_length=128), blank=True, default=list)
    user = models.OneToOneField(User, on_delete=models.CASCADE)


class Travel(models.Model):
    travel_type_mine = ArrayField(models.CharField(max_length=128), blank=True, default=list)
    fav_destination_mine = ArrayField(models.CharField(max_length=128), blank=True, default=list)
    international_travel_mine = models.CharField(max_length=128, blank=True, default='')
    user = models.OneToOneField(User, on_delete=models.CASCADE)


class HobbiesCollecting(models.Model):
    indoor_hobbies_mine = ArrayField(models.CharField(max_length=128), blank=True, default=list)
    outdoor_hobbies_mine = ArrayField(models.CharField(max_length=128), blank=True, default=list)
    indoor_collecting_mine = ArrayField(models.CharField(max_length=128), blank=True, default=list)
    outdoor_collecting_mine = ArrayField(models.CharField(max_length=128), blank=True, default=list)
    competitive_hobbies_mine = ArrayField(models.CharField(max_length=128), blank=True, default=list)
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    user = models.OneToOneField(User, on_delete=models.CASCADE)
