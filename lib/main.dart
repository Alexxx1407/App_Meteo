import 'package:flutter/material.dart';
import 'dart:async'; // Import Timer
import 'api_service.dart';
import 'favorite_service.dart';
import 'graph_widget.dart';
import 'weather_widget.dart';
import 'location_notification.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeNotifications(); // Initialize notifications when the app starts
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Weather App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6A1B9A)),
        scaffoldBackgroundColor: const Color(0xFFE1E8F3), // Softer background color
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Weather App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String searchText = ''; // Stores the text entered in the search box
  String weatherInfo = 'Search for a city to get weather data'; // Displays weather info
  double? temperatureCelsius; // Holds temperature in Celsius
  String location = ''; // Stores the location name
  String weatherDescription = ''; // Weather condition description
  String weatherImage = ''; // Image path for weather condition
  List<double> temperatures = []; // Hourly temperature data for the graph
  List<double> weeklyTemperatures = []; // Weekly temperature data for the graph
  bool citySearched = false; // Tracks if a city was searched
  bool isCelsius = true; // Tracks whether temperature is shown in Celsius or Fahrenheit
  bool showWeeklyButton = false; // Track whether to show "Get 5-Day Forecast" button

  Timer? notificationTimer; // Timer for periodic notifications

  @override
  void dispose() {
    notificationTimer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  // Start the notification timer
  void startNotificationTimer() {
    notificationTimer = Timer.periodic(Duration(seconds: 10), (timer) async {
      print('Sending periodic weather notification');
      await sendLocationWeatherNotification(); // Trigger location-based weather notification
    });
  }

  // Stop the notification timer
  void stopNotificationTimer() {
    notificationTimer?.cancel();
    print('Stopped periodic notifications');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Text(widget.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF6A1B9A))),
              actions: [
                IconButton(
                  icon: const Icon(Icons.favorite, color: Color(0xFF6A1B9A)),
                  onPressed: () {
                    showFavoritesDialog(context); // Show favorites from favorite_service.dart
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.notifications, color: Color(0xFF6A1B9A)),
                  onPressed: () {
                    sendLocationWeatherNotification(); // Trigger a one-time location-based weather notification
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Search bar to search for city
            Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              shadowColor: Colors.grey.withOpacity(0.5),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            searchText = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Enter city name',
                          prefixIcon: const Icon(Icons.search, color: Color(0xFF6A1B9A)),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.star_border, color: Color(0xFF6A1B9A)),
                      onPressed: () {
                        if (searchText.isNotEmpty) {
                          saveFavoriteCity(searchText); // Save favorite city
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Custom gradient button for "Get the Weather"
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF6A1B9A), Color(0xFF8E24AA)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                ),
                onPressed: () async {
                  if (searchText.isNotEmpty) {
                    var weatherData = await fetchWeatherData(searchText);
                    if (weatherData != null) {
                      setState(() {
                        weatherInfo = weatherData['weatherInfo'];
                        temperatureCelsius = weatherData['temperatureCelsius'];
                        weatherDescription = weatherData['weatherDescription'];
                        weatherImage = weatherData['weatherImage'];
                        temperatures = weatherData['temperatures'];
                        location = weatherData['location'];
                        citySearched = true;
                        showWeeklyButton = true; // Enable 5-day forecast button
                      });
                    }
                  }
                },
                child: const Text(
                  'Get the Weather',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Display the weather widget (extracted to weather_widget.dart)
            if (citySearched)
              Card(
                color: Colors.white,
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        weatherInfo,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6A1B9A),
                        ),
                      ),
                      const SizedBox(height: 15),
                      if (weatherImage.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(10),
                          child: Image.asset(
                            weatherImage,
                            height: 120, // Adjusted height for better layout
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (citySearched) {
                  showTemperatureGraphPopup(context, location, temperatures); // Show the hourly graph in a popup
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) => const AlertDialog(
                      title: Text("Error"),
                      content: Text("No city selected!"),
                    ),
                  );
                }
              },
              child: const Text('Show Hourly Graph'),
            ),
            const SizedBox(height: 20),
            // New button for the 5-day forecast
            if (showWeeklyButton)
              ElevatedButton(
                onPressed: () async {
                  print('Fetching 5-day forecast for city: $searchText');  // Debug log
                  var fiveDayData = await fetchFiveDayForecast(searchText); // Fetch 5-day forecast
                  if (fiveDayData != null) {
                    print('5-Day Temperatures: $fiveDayData'); // Debug log
                    setState(() {
                      weeklyTemperatures = fiveDayData; // Use the 5-day temperatures for the graph
                    });
                    showTemperatureGraphPopup(context, location, weeklyTemperatures); // Show 5-day data in the graph
                  } else {
                    print('Error: 5-day data not fetched'); // Debugging error
                  }
                },
                child: const Text('Get 5-Day Forecast'),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                toggleTemperatureUnit();
              },
              child: const Text('Toggle C°/F°'),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    startNotificationTimer(); // Start the notification timer
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Periodic notifications started")),
                    );
                  },
                  child: const Text('Start Notifications'),
                ),
                ElevatedButton(
                  onPressed: () {
                    stopNotificationTimer(); // Stop the notification timer
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Periodic notifications stopped")),
                    );
                  },
                  child: const Text('Stop Notifications'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Toggle between Celsius and Fahrenheit
  void toggleTemperatureUnit() {
    setState(() {
      if (temperatureCelsius != null) {
        if (isCelsius) {
          double tempFahrenheit = (temperatureCelsius! * 9 / 5) + 32;
          weatherInfo = 'The weather in $location is: $weatherDescription, Temperature: ${tempFahrenheit.toStringAsFixed(2)}°F';
        } else {
          weatherInfo = 'The weather in $location is: $weatherDescription, Temperature: ${temperatureCelsius?.toStringAsFixed(2)}°C';
        }
        isCelsius = !isCelsius;
      }
    });
  }
}