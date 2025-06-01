"""tadpool URL Configuration

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/3.1/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import path, include
from api import views
from knox import views as knox_views


urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/auth', include('knox.urls')),
    path('api/auth/register', views.RegisterAPI.as_view()),
    path('api/auth/login', views.LoginAPI.as_view()),
    path('api/auth/user', views.UserAPI.as_view()),
    path('api/auth/logout', knox_views.LogoutView.as_view()),
    path('api/userbio/get', views.UserBioAPI.as_view()),
    path('api/onboarding/post', views.OnboardingAPI.as_view()),
    path('api/matches', views.MatchingListAPI.as_view()),
    path('api/myMatches', views.MatchAPI.as_view()),
    path('api/myMatches/accept', views.AcceptMatchAPI.as_view()),
    path('api/myMatches/reject', views.RejectMatchAPI.as_view()),
    path('api/location', views.LocationAPI.as_view()),
    path('api/imgUpload/post', views.ImageUploader.as_view()),

    #notification url
    path("api/send-notification", views.SendNotificationAPI.as_view(), name="send-notification"),
    #google map url
    path('api/google-directions/', views.GoogleDirectionsAPI.as_view()),
    #face verification url
    path('api/face-verification/', views.face_verification),

    path('api/google-nearby-search/', views.GoogleNearbySearchAPI.as_view()),
    path('api/google-find-place-from-text/', views.GoogleFindPlaceFromTextAPI.as_view())
]
