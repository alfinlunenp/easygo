import 'dart:convert';
import 'package:easygonww/APIs/apis.dart';
import 'package:easygonww/model/models.dart';
import 'package:easygonww/model/models.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BikeController {
  List<BikeModel> bikeList = [];
  List<BikeModel> topRatedBikes = []; // ✅ List to hold top 4 rated bikes

  Future<String?> _getAuthToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  Future<void> fetchBikes() async {
    final url = Uri.parse(AllBikesAPI);
    final token = await _getAuthToken();

    try {
      print(url);
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
        },
      );

      print("sts code : ${response.statusCode}");

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        print("Response : $response");
        print(decodedData);

        if (decodedData['result'] == true && decodedData['list'] != null) {
          final List<dynamic> dataList = decodedData['list'];
          bikeList = dataList.map((bike) => BikeModel.fromJson(bike)).toList();

          // ✅ Sort bikeList by rating (descending) and take top 4
          bikeList.sort((a, b) {
            final bRating = b.bRatings ?? 0.0;
            final aRating = a.bRatings ?? 0.0;
            return bRating.compareTo(aRating);
          });
          topRatedBikes = bikeList.take(4).toList();

          print("Top Rated Bikes:");
          for (var bike in topRatedBikes) {
            print("${bike.bName} - Rating: ${bike.bRatings}");
          }

          print(topRatedBikes);
        } else {
          bikeList = [];
          topRatedBikes = [];
        }
      } else {
        print("Failed to load bikes: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching bikes: $e");
    }
  }
}

class MyBookingController {
  List<BookingModel> mybookingList = [];

  Future<String?> _getAuthToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  Future<void> fetchBikes() async {
    final url = Uri.parse(MybookingAPI);
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final token = await _getAuthToken();

    print("object 1");

    try {
      print(url);
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
        },
      );

      print("sts code : ${response.statusCode}");

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        print("Response ::::::::::::::::::::::::::: $response");
        print("data ::::::::::::::::::::::::::::::: $decodedData");

        if (decodedData['result'] == true && decodedData['list'] != null) {
          final List<dynamic> dataList = decodedData['list'];
          mybookingList = dataList
              .map((bike) => BookingModel.fromJson(bike))
              .toList();
        } else {
          mybookingList = [];
        }
      } else {
        print("Failed to load bikes: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching bikes: $e");
    }
  }
}

class BikesearchhController {
  List<BikeModel> searchlist = [];

  Future<String?> _getAuthToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  Future<void> fetchBikes(String search) async {
    final url = Uri.parse(AllBikesAPI);
    final token = await _getAuthToken();

    var data = {"search": search};

    try {
      print(url);
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );

      print("sts code : ${response.statusCode}");

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        print("Response : $response");
        print(decodedData);

        if (decodedData['result'] == true && decodedData['list'] != null) {
          final List<dynamic> dataList = decodedData['list'];
          searchlist = dataList
              .map((bike) => BikeModel.fromJson(bike))
              .toList();
        } else {
          searchlist = [];
        }
      } else {
        print("Failed to load bikes: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching bikes: $e");
    }
  }
}

class NotificationController {
  List<NotificationModel> notificationList = [];

  Future<String?> _getAuthToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  Future<void> fetchNotifications() async {
    final url = Uri.parse(NotificationAPI);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? user_id = prefs.getString("user_id");
    final token = await _getAuthToken();

    var data = {"user_id": user_id};

    try {
      print(url);
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );

      print("Status code : ${response.statusCode}");

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        print("Response body: ${response.body}");

        if (decodedData['result'] == true && decodedData['list'] != null) {
          final List<dynamic> dataList = decodedData['list'];
          notificationList = dataList
              .map((item) => NotificationModel.fromJson(item))
              .toList();
        } else {
          notificationList = [];
        }
      } else {
        print("Failed to load notifications: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching notifications: $e");
    }
  }
}

class UserController {
  List<UserModel> userList = [];

  Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  Future<void> fetchUser(String role) async {
    final token = await _getAuthToken();
    late Uri url;

    if (role == "admin") {
      url = Uri.parse(GetAdminDetialsAPI);
    } else {
      url = Uri.parse(GetUserAPI);
    }

    if (token == null || token.isEmpty) {
      print("Token not found");
      userList = [];
      return;
    }

    try {
      print("API URL: $url");
      print(token);
      final response = await http.post(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      print("Status code: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);

        if (decodedData['result'] == true && decodedData['list'] is List) {
          userList = (decodedData['list'] as List)
              .map((e) => UserModel.fromJson(e))
              .toList();
        } else {
          userList = [];
        }
      } else {
        print("Failed to load users");
        userList = [];
      }
    } catch (e) {
      print("Error fetching users: $e");
      userList = [];
    }
  }
}

class BikeCentersLocationController {
  List<BikeCenterLocationModel> bikeCenterLocationList = [];

  Future<String?> _getAuthToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  Future<void> fetchBikeCentersLocation() async {
    final url = Uri.parse(BikeCenterLocationAPI);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? user_id = prefs.getString("user_id");
    final token = await _getAuthToken();

    var data = {"user_id": user_id};

    try {
      print(url);
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );

      print("Status code : ${response.body}");

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        print("Response body: ${response.body}");

        if (decodedData['result'] == true && decodedData['list'] != null) {
          final List<dynamic> dataList = decodedData['list'];
          bikeCenterLocationList = dataList
              .map((item) => BikeCenterLocationModel.fromJson(item))
              .toList();
        } else {
          bikeCenterLocationList = [];
        }
      } else {
        print("Failed to load : ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching : $e");
    }
  }
}

class RentController {
  List<RentModel> rentList = [];

  Future<String?> _getAuthToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  Future<void> fetchRent() async {
    final url = Uri.parse(RentAPI);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? user_id = prefs.getString("user_id");
    final token = await _getAuthToken();

    var data = {"user_id": user_id};

    try {
      print(url);
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );

      print("Status code : ${response.statusCode}");

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        print("Response body: ${response.body}");

        if (decodedData['result'] == true && decodedData['list'] != null) {
          final List<dynamic> dataList = decodedData['list'];
          rentList = dataList.map((item) => RentModel.fromJson(item)).toList();
        } else {
          rentList = [];
        }
      } else {
        print("Failed to load rent: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching rent: $e");
    }
  }
}
