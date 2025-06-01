from django.contrib import admin
from .models import *
from .admin_actions import duplicate_objects

# Adding the duplicate_objects action to the admin interface
# This allows the admin to duplicate selected objects in the admin interface.
# Also make the fields of the models visible in the admin interface list view.

class FullDisplayAdmin(admin.ModelAdmin):
    actions = [duplicate_objects]

    def get_list_display(self, request):
        if self.list_display != ('__str__',):
            return self.list_display
        
        # Get all fields from the model
        fields = [field.name for field in self.model._meta.fields]

        # Add properties that should show up in the list (like 'location', 'birthday')
        extra = []
        for attr in dir(self.model):
            if (
                attr not in fields and  
                not attr.startswith('_') and  
                isinstance(getattr(self.model, attr, None), property)
            ):
                extra.append(attr + "_display")

        return tuple(fields + extra)

    def __getattr__(self, name):
        # Dynamic method for each @property field ending in _display
        if name.endswith('_display'):
            attr_name = name.replace('_display', '')

            def _property_display(obj):
                try:
                    value = getattr(obj, attr_name, None)
                    return value if value else '—'
                except Exception:
                    return '—'
                
            _property_display.short_description = attr_name.replace('_', ' ').capitalize()
            return _property_display
        
        raise AttributeError(f"{self.__class__.__name__} has no attribute {name}")


@admin.register(Status)
class StatusAdmin(FullDisplayAdmin): pass

@admin.register(Beliefs)
class BeliefsAdmin(FullDisplayAdmin): pass

@admin.register(Appearance)
class AppearanceAdmin(FullDisplayAdmin): pass

@admin.register(Interests)
class InterestsAdmin(FullDisplayAdmin): pass

@admin.register(Habits)
class HabitsAdmin(FullDisplayAdmin): pass

@admin.register(Personality)
class PersonalityAdmin(FullDisplayAdmin): pass

@admin.register(Travel)
class TravelAdmin(FullDisplayAdmin): pass

@admin.register(HobbiesCollecting)
class HobbiesCollectingAdmin(FullDisplayAdmin): pass


@admin.register(Profile)
class ProfileAdmin(FullDisplayAdmin):
    list_display = (
        'id',
        'user',
        'uuid',
        'fcm_token',
        'get_name', 
        'face_picture_URL',
        'body_picture_URL',
        'latitude',
        'longitude',
        'is_verified',
        'birthday',
        'pk',
    )
    list_filter = ('is_verified',)

    @admin.display(description='Name')
    def get_name(self, obj):
        return obj.name or 'No name'


    
class HobbiesCollectingAdmin(FullDisplayAdmin): pass


@admin.register(Match)
class MatchAdmin(FullDisplayAdmin):  pass

