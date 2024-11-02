import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

var apiKey = 'your-api-key-here';

// Initialize the notification plugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// Function to initialize the notification settings
Future<void> initializeNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

// Function to show a local notification
Future<void> showNotification(String title, String body) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'weather_channel', // channel ID
    'Weather Notifications', // channel name
    channelDescription: 'Notifications for local weather updates',
    importance: Importance.max,
    priority: Priority.high,
    showWhen: false,
  );
  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.show(
    0,
    title,
    body,
    platformChannelSpecifics,
  );
}

// Function to get the current location of the user
Future<Position?> getCurrentLocation() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Check if location services are enabled
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    print('Location services are disabled.');
    return null;
  }

  // Check for location permissions
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      print('Location permissions are denied');
      return null;
    }
  }

  if (permission == LocationPermission.deniedForever) {
    print('Location permissions are permanently denied');
    return null;
  }

  // Get the current location
  return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high);
}

// Function to fetch weather data based on location
Future<void> fetchWeatherForLocation(Position position) async {
  final lat = position.latitude;
  final lon = position.longitude;
  final url =
      'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey';

  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      String location = data['name'];
      String weatherDescription = data['weather'][0]['description'];
      double tempK = data['main']['temp'];
      double tempC = tempK - 273.15;

      // Prepare the notification content
      String title = "Weather Update for $location";
      String body =
          "Current weather: $weatherDescription, Temperature: ${tempC.toStringAsFixed(1)}°C";

      // Show the notification
      await showNotification(title, body);
    } else {
      print('Failed to fetch weather data');
    }
  } catch (error) {
    print('Error fetching weather data: $error');
  }
}

// Function to request location and send a weather notification
Future<void> sendLocationWeatherNotification() async {
  Position? position = await getCurrentLocation();
  if (position != null) {
    await fetchWeatherForLocation(position);
  }
}
