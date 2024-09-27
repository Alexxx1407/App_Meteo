import 'package:flutter/material.dart';
import 'api_service.dart'; // Import API service functions
import 'favorite_service.dart'; // Import favorite service functions
import 'graph_widget.dart'; // Import the graph widget
import 'weather_widget.dart'; // Import the weather display widget

void main() {
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
  bool citySearched = false; // Tracks if a city was searched
  bool isCelsius = true; // Tracks whether temperature is shown in Celsius or Fahrenheit (ADDED THIS)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDE7F6),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 242, 240, 243),
        title: Text(widget.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        elevation: 10,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite, color: Color(0xFF6A1B9A)),
            onPressed: () {
              showFavoritesDialog(context); // Show favorites from favorite_service.dart
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            // Search bar to search for city
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
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
                          hintText: 'Search for a city',
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.star_border, color: Color(0xFF6A1B9A)),
                      onPressed: () {
                        if (searchText.isNotEmpty) {
                          saveFavoriteCity(searchText); // Save favorite city from favorite_service.dart
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
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
                    });
                  }
                }
              },
              child: const Text('Get the Weather'),
            ),
            const SizedBox(height: 20),
            // Display the weather widget (extracted to weather_widget.dart)
            if (citySearched)
              WeatherWidget(
                weatherInfo: weatherInfo,
                weatherImage: weatherImage,
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (citySearched) {
                  showTemperatureGraphPopup(context, location, temperatures); // Show the graph in popup (from graph_widget.dart)
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
              child: const Text('Show Graph'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                toggleTemperatureUnit();
              },
              child: const Text('Toggle C°/F°'),
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
        isCelsius = !isCelsius; // Toggle the unit
      }
    });
  }
}
