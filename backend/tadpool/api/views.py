from secrets import choice
from django.forms import model_to_dict
from django.http import JsonResponse
from api.util import MatchingProfile, ProfileUtility
from rest_framework.response import Response
from rest_framework import status, generics, permissions
from rest_framework.permissions import IsAuthenticated
from knox.models import AuthToken
from rest_framework.views import APIView
from django.db.models import Q
import boto3
from uuid import uuid4
from django.conf import settings
from .serializers import *
import geopy.distance
import requests
from firebase.fcm_services import send_push_notification
import environ
from rest_framework.decorators import api_view, permission_classes
from knox.auth import TokenAuthentication



class UserBioAPI(APIView):
    permission_classes = [
        permissions.IsAuthenticated,
    ]

    """
    User Bio API used for onboarding.
    Displays:
    Status, Beliefs, Appearance, Interests, Habits Personality, Travel
    and HobbiesCollecting Models.
    """

    def get(self, request):
        user = User.objects.get(id=request.user.id)
        print(user.profile.name)
        bio = {}
        try:
            bio['profile'] = ProfileSerializer(Profile.objects.get(user=user)).data
            bio['status'] = StatusSerializer(user.status).data;
            bio['beliefs'] = BeliefsSerializer(user.beliefs).data;
            bio['appearance'] = AppearanceSerializer(user.appearance).data;
            bio['interests'] = InterestsSerializer(user.interests).data;
            bio['habits'] = HabitsSerializer(user.habits).data;
            bio['personality'] = PersonalitySerializer(user.personality).data;
            bio['hobbies_collecting'] = HobbiesCollectingSerializer(user.hobbiescollecting).data;
            bio['travel'] = TravelSerializer(user.travel).data;
        except Exception as e:
            bio = None
            print(e)

        return JsonResponse({
            'user': UserSerializer(user).data,
            'bio': bio
        })

class OnboardingAPI(APIView):
    """
    Provides the view for the Onboarding API. Serializes User models
    and returns the:
        - User
        - Serialized data or errors
    """
    permission_classes = [
        permissions.IsAuthenticated,
    ]

    def post(self, request):
        user = User.objects.get(id=request.user.id)
        response = {
            "user": {
                "id": user.id,
                "username": user.username
            },
            "error": False
        }

        if 'name' in request.data:
            print("name being saved:", request.data['name'])
            user.profile.name = request.data['name']
            user.profile.save()
            response.update(ProfileSerializer(user.profile).data)


        fields = [
            "status",
            "beliefs",
            "appearance",
            "interests",
            "habits",
            "personality",
            "hobbies_collecting",
            "travel"
        ]

        serializers_map = {
            "status": StatusSerializer,
            "beliefs": BeliefsSerializer,
            "appearance": AppearanceSerializer,
            "interests": InterestsSerializer,
            "habits": HabitsSerializer,
            "personality": PersonalitySerializer,
            "hobbies_collecting": HobbiesCollectingSerializer,
            "travel": TravelSerializer,
        }

        serializer_list = []

        for field in fields:
            if field in request.data:
                request.data[field]["user"] = user.id
                serializer = serializers_map[field](data=request.data[field])
                serializer_list.append((field, serializer))

        for key, serializer in serializer_list:
            if not serializer.is_valid():
                response.update({key: serializer.errors})
                response["error"] = True
                break

        if not response["error"]:
            for key, serializer in serializer_list:
                serializer.save()
                response.update({key: serializer.data})
            return Response(response, status=status.HTTP_201_CREATED)
        else:
            return Response(response, status=status.HTTP_400_BAD_REQUEST)





class RegisterAPI(generics.GenericAPIView):
    serializer_class = RegisterSerializer

    def post(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.save()
        fcm_token = request.data.get("fcm_token")

        if fcm_token:
            user.profile.fcm_token = fcm_token
            user.profile.save()
            
        return Response({
            "user": UserSerializer(user,
                                   context=self.get_serializer_context()).data,
            "token": AuthToken.objects.create(user)[1]
        })

class LoginAPI(generics.GenericAPIView):
    serializer_class = LoginSerializer

    def post(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.validated_data

        fcm_token = request.data.get("fcm_token")
        if fcm_token:
            user.profile.fcm_token = fcm_token
            user.profile.save()

        return Response({
            "user": UserWithProfileSerializer(user, context=self.get_serializer_context()).data,
            "token": AuthToken.objects.create(user)[1]
        })


class UserAPI(generics.RetrieveAPIView):
    permission_classes = [
        permissions.IsAuthenticated,
    ]
    serializer_class = UserSerializer

    def get_object(self):
        return self.request.user

class LocationAPI(generics.GenericAPIView):
    permission_classes = [
        permissions.IsAuthenticated,
    ]
    
    def post(self, request):
        user = User.objects.get(id=request.user.id)
        lat = request.data.get("latitude")
        lon = request.data.get("longitude")
        if lat is None or lon is None:
            return Response({"error": "Latitude and Longitude are required"}, status=status.HTTP_400_BAD_REQUEST)
        user.profile.latitude = lat
        user.profile.longitude = lon
        user.profile.save()
        return Response({"data": {
            "latitude": user.profile.latitude,
            "longitude": user.profile.longitude
        }})

class MatchAPI(generics.GenericAPIView):
    permission_classes = [
        permissions.IsAuthenticated,
    ]
    def get(self, request):
        user = User.objects.get(id=request.user.id)
        matches = Match.objects.filter(owner=user)
        matches_without_rejects = []
        for match in matches:
            if match.owner_accepted == True:
                matches_without_rejects.append(match)
        matches_serializer = MatchSerializer(matches_without_rejects, many=True)
        return Response(matches_serializer.data)

class RejectMatchAPI(generics.GenericAPIView):
    permission_classes = [
        permissions.IsAuthenticated,
    ]
    def post(self, request):
        user = User.objects.get(id=request.user.id)
        partner = User.objects.filter(id=request.data.get("partner"))
        if user.id == request.data.get("partner"):
            return Response({"error": "You cannot match with yourself"}, status=status.HTTP_400_BAD_REQUEST)
        if not partner.exists():
            return Response({"error": "Partner does not exist"}, status=status.HTTP_400_BAD_REQUEST)

        #first check is there is room already
        match = Match.objects.filter(owner=partner.get(), partner=user)
        if match.exists():
            match.update(partner_accepted=False)
            return Response(MatchSerializer(match.get()).data)

        try:
            match = Match.objects.create(owner=user, partner=partner.get(), owner_accepted=False)
            match_serializer = MatchSerializer(match)
            return Response(match_serializer.data)
        except:
            return Response({"error": "Something went wrong"}, status=status.HTTP_400_BAD_REQUEST)


class AcceptMatchAPI(generics.GenericAPIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        user = User.objects.get(id=request.user.id)
        partner_id = request.data.get("partner")

        if not partner_id:
            return Response({"error": "Partner ID is required"}, status=status.HTTP_400_BAD_REQUEST)

        if user.id == partner_id:
            return Response({"error": "You cannot match with yourself"}, status=status.HTTP_400_BAD_REQUEST)

        try:
            partner_user = User.objects.get(id=partner_id)
        except User.DoesNotExist:
            return Response({"error": "Partner does not exist"}, status=status.HTTP_400_BAD_REQUEST)

        # Check if match already exists in either direction
        match = Match.objects.filter(
            Q(owner=user, partner=partner_user) |
            Q(owner=partner_user, partner=user)
        ).first()

        if match:
            # Update acceptance flags based on who owns the match
            if match.owner == user:
                match.owner_accepted = True
            else:
                match.partner_accepted = True

            match.save()

            if match.owner_accepted and match.partner_accepted:
                print("THIS IS A MATCH!!!!!!!!!!")
                print("SEND NOTIFICATION HERE")

            return Response(MatchSerializer(match).data)

        # No existing match, create new
        try:
            new_match = Match.objects.create(
                owner=user,
                partner=partner_user,
                owner_accepted=True
            )
            return Response(MatchSerializer(new_match).data)
        except Exception as e:
            return Response({"error": f"Something went wrong: {str(e)}"}, status=status.HTTP_400_BAD_REQUEST)


class MatchingListAPI(generics.GenericAPIView):
    permission_classes = [
        permissions.IsAuthenticated
    ]
    
    def get(self, request):
        user = User.objects.get(id=request.user.id)
        lat = request.GET.get("latitude")
        lng = request.GET.get("longitude")
        radius = request.GET.get("radius")
        try:
            coords_1 = (float(lat), float(lng))
        except:
            return Response({"error": "Invalid coordinates"}, status=status.HTTP_400_BAD_REQUEST)

        # location filtering
        userList = []
        distances = {}
        for profile in Profile.objects.all():
            if user.id == profile.user.id:
                continue
            coords_2 = (profile.latitude, profile.longitude)
            distance = geopy.distance.geodesic(coords_1, coords_2).km
            if distance <= float(radius):
                userList.append(profile.user)
                distances[profile.user.id] = distance
        
        # 85% criteria filtering
        matchingProfile = MatchingProfile(user=user, list=userList)
        matches = matchingProfile.get_matches(user, average_threshold=0.85)

        ProfileUtility.compare(user, user)

        for match in matches:
            match["distance"] = distances[match["id"]]

            # If the user is verified
            match["is_verified"] = User.objects.get(id=match["id"]).profile.is_verified

        return Response({"data": matches})

class ImageUploader(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        try:
            files = request.FILES.getlist('files')
            if len(files) != 2:
                return JsonResponse({"error": "Please upload exactly 2 images."}, status=400)

            user_id = str(request.user.id)
            face_file = files[0]
            body_file = files[1]

            face_ext = face_file.name.split('.')[-1]
            body_ext = body_file.name.split('.')[-1]

            face_name = f"face.{face_ext}"
            body_name = f"body.{body_ext}"

            s3 = boto3.resource(
                's3',
                aws_access_key_id=settings.AWS_ACCESS_KEY,
                aws_secret_access_key=settings.AWS_SECRET_KEY
            )

            bucket = settings.AWS_STORAGE_BUCKET_NAME
            acl = settings.AWS_DEFAULT_ACL
            domain = settings.AWS_S3_CUSTOM_DOMAIN

            s3.Bucket(bucket).put_object(
                Key=f"{user_id}/{face_name}",
                Body=face_file,
                ContentType=face_file.content_type,
                ACL=acl
            )
            s3.Bucket(bucket).put_object(
                Key=f"{user_id}/{body_name}",
                Body=body_file,
                ContentType=body_file.content_type,
                ACL=acl
            )

            profile = Profile.objects.get(user=request.user)
            profile.face_picture_URL = f"{domain}/{user_id}/{face_name}"
            profile.body_picture_URL = f"{domain}/{user_id}/{body_name}"
            

            profile.save()

            return JsonResponse({
                "message": "SUCCESS",
                "face_picture_URL": profile.face_picture_URL,
                "body_picture_URL": profile.body_picture_URL
            })


        except Exception as e :
            return JsonResponse({"ERROR" : str(e)})
        

# Face verification API
@api_view(['POST'])
@permission_classes([IsAuthenticated])
def face_verification(request):
    user = request.user
    face_photo = request.FILES.get('image')

    if not face_photo:
        return Response({"error": "No image uploaded."}, status=400)

    session = boto3.Session(
    aws_access_key_id=settings.AWS_ACCESS_KEY,
    aws_secret_access_key=settings.AWS_SECRET_KEY,
    region_name=settings.AWS_REGION,
    )
    s3 = session.client('s3')
    rekognition = session.client('rekognition')
    bucket = settings.AWS_STORAGE_BUCKET_NAME
    temp_key = f"{user.id}/temp_face_verification.jpg"

    print(f"Uploading temp file to: {bucket}/{temp_key}")

    try:
        s3.upload_fileobj(
            face_photo,
            bucket,
            temp_key,
            ExtraArgs={"ACL": "public-read", "ContentType": face_photo.content_type}
        )
    except Exception as e:
        return Response({"error": f"Failed to upload temporary image: {str(e)}"}, status=500)


    try:
        profile = user.profile
        if not profile.face_picture_URL:
            raise ValueError("No face picture found in profile")
            
        print(f"Profile face picture URL: {profile.face_picture_URL}")
        
        from urllib.parse import urlparse
        parsed_url = urlparse(profile.face_picture_URL)
        original_key = parsed_url.path.lstrip('/')
        
        print(f"Extracted original key: {original_key}")
        
        if not original_key:
            raise ValueError("Failed to extract a valid S3 key from URL")
            
        try:
            s3.head_object(Bucket=bucket, Key=original_key)
            print(f"Successfully verified object exists: {bucket}/{original_key}")
        except Exception as s3_err:
            print(f"Error checking original image: {str(s3_err)}")
            raise ValueError(f"Original face image not found in S3: {str(s3_err)}")
            
    except Profile.DoesNotExist:
        s3.delete_object(Bucket=bucket, Key=temp_key)
        return Response({"error": "User profile not found."}, status=404)
    except Exception as e:
        s3.delete_object(Bucket=bucket, Key=temp_key)
        return Response({"error": f"Profile or face picture error: {str(e)}"}, status=404)
    
    try:
        print(f"Comparing faces: source={temp_key}, target={original_key}")
        
        response = rekognition.compare_faces(
            SourceImage={'S3Object': {'Bucket': bucket, 'Name': temp_key}},
            TargetImage={'S3Object': {'Bucket': bucket, 'Name': original_key}},
            SimilarityThreshold=80
        )
        
        s3.delete_object(Bucket=bucket, Key=temp_key)
        
        if 'FaceMatches' in response and response['FaceMatches']:
            similarity = response['FaceMatches'][0]['Similarity']
            profile.is_verified = True
            profile.save()
            return Response({
                "matched": True,
                "similarity": round(similarity, 2),
                "message": "Thank you, face verified successfully!"
            })
        else:
            return Response({
                "matched": False,
                "similarity": 0,
                "message": "Sorry, face does not match."
            })
    except Exception as e:
        error_message = str(e)
        print(f"Face verification error: {error_message}")
        
        return Response({
            "error": f"Face verification failed: {error_message}"
        }, status=500)
               
# Notification API
class SendNotificationAPI(APIView):
    permission_classes = [permissions.IsAuthenticated]
    def post(self, request):
        token = request.data.get("receiver_token")
        title = request.data.get("title", "No Title")
        body = request.data.get("body", "No Body")

        if not token:
            return Response({"error": "FCM token is required"}, status=status.HTTP_400_BAD_REQUEST)

        result = send_push_notification(token, title, body)

        if result['success']:
            return Response({"message": "Notification sent", "id": result['response']})
        else:
            return Response({"error": result['error']}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
        

# Map testing API
class GoogleDirectionsAPI(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        origin = request.GET.get('origin')
        destination = request.GET.get('destination')

        env = environ.Env()
        env.read_env()
        key = env('GOOGLE_MAPS_API_KEY', default=getattr(settings, 'GOOGLE_MAPS_API_KEY', None))

        print("origin:", origin)
        print("destination:", destination)
        print("key:", key)

        if not origin or not destination or not key:
            return Response({"error": "Missing required parameters"}, status=status.HTTP_400_BAD_REQUEST)

        url = (
            f"https://maps.googleapis.com/maps/api/directions/json"
            f"?origin={origin}&destination={destination}&mode=walking&key={key}"
        )

        try:
            res = requests.get(url)
            return Response(res.json(), status=res.status_code)
        except Exception as e:
            return Response({"error": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
        
class GoogleNearbySearchAPI(APIView):
    authentication_classes = [TokenAuthentication]
    permission_classes = [IsAuthenticated]

    def get(self, request):
        location = request.GET.get('location')
        locationType = request.GET.get('locationType')

        env = environ.Env()
        env.read_env()
        key = env('GOOGLE_MAPS_API_KEY', default=getattr(settings, 'GOOGLE_MAPS_API_KEY', None))

        print("location:", location)
        print("locationType:", locationType)
        print("key:", key)

        if not location or not locationType:
            return Response({"error": "Missing location and loaction type"}, status=status.HTTP_400_BAD_REQUEST)

        url = (
            f"https://maps.googleapis.com/maps/api/place/nearbysearch/json"
            f"?location={location}&radius=1500&type={locationType}&key={key}"
        )

        try:
            res = requests.get(url)
            return Response(res.json(), status=res.status_code)
        except Exception as e:
            return Response({"error": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
        
class GoogleFindPlaceFromTextAPI(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        # origin = request.GET.get('origin')
        # destination = request.GET.get('destination')
        _selectedNearbyPlace = request.GET.get('selectedNearbyPlace')

        env = environ.Env()
        env.read_env()
        key = env('GOOGLE_MAPS_API_KEY', default=getattr(settings, 'GOOGLE_MAPS_API_KEY', None))

        # print("origin:", origin)
        # print("destination:", destination)
        print("selectedNearbyPlace:", _selectedNearbyPlace)

        if not _selectedNearbyPlace:
            return Response({"error": "Missing required parameters"}, status=status.HTTP_400_BAD_REQUEST)

        url = (
            f"https://maps.googleapis.com/maps/api/place/findplacefromtext/json"
            f"?input={_selectedNearbyPlace}&inputtype=textquery&fields=geometry&key{key}"
        )

        try:
            res = requests.get(url)
            return Response(res.json(), status=res.status_code)
        except Exception as e:
            return Response({"error": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)