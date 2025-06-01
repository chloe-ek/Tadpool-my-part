class URL {
  // for local dev server
  // static String baseUrl = 'http://127.0.0.1:8000/api';

  // for hosted server

  static String baseUrl =
      'http://ec2-18-144-24-31.us-west-1.compute.amazonaws.com:8000/api';

  static String registerUrl = '$baseUrl/auth/register';
  static String loginUrl = '$baseUrl/auth/login';
  static String userUrl = '$baseUrl/auth/user';
  static String matchingUrl = '$baseUrl/matches';
  static String createProfileUrl = '$baseUrl/onboarding/post';
  static String userBioUrl = '$baseUrl/userbio/get';
  static String locationUrl = '$baseUrl/location';
  static String myMatchesUrl = '$baseUrl/myMatches';
}
