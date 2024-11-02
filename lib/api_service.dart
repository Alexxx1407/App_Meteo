import 'dart:convert';
import 'package:http/http.dart' as http;

var apiKey = '420f70f10e32375f1a81fd10072cb3b8';

// Function to fetch weather data
Future<Map<String, dynamic>?> fetchWeatherData(String city) async {
  var url = 'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey';
  var forecastUrl = 'https://api.openweathermap.org/data/2.5/forecast?q=$city&appid=$apiKey';
  try {
    final response = await http.get(Uri.parse(url));
    final forecastResponse = await http.get(Uri.parse(forecastUrl));

    if (response.statusCode == 200 && forecastResponse.statusCode == 200) {
      var data = json.decode(response.body);
      var forecastData = json.decode(forecastResponse.body);

      // Extract relevant data
      double tempK = data['main']['temp'];
      double tempC = tempK - 273.15;
      List hourlyData = forecastData['list'].take(8).toList();
      List<double> temperatures = hourlyData.map((item) {
        double tempK = item['main']['temp'];
        return tempK - 273.15;
      }).toList();

      // Return data in a map
      return {
        'temperatureCelsius': tempC,
        'weatherInfo': 'The weather in ${data['name']} is: ${data['weather'][0]['main']}, Temperature: ${tempC.toStringAsFixed(2)}°C',
        'weatherDescription': data['weather'][0]['main'],
        'weatherImage': getWeatherImage(data['weather'][0]['main']),
        'temperatures': temperatures,
        'location': data['name'],
      };
    } else {
      return null; // Error occurred
    }
  } catch (error) {
    print('Error fetching weather data: $error');
    return null;
  }
}

// Function to map weather description to image
String getWeatherImage(String description) {
  if (description.contains('Clear')) {
    return 'assets/sunny.jpg';
  } else if (description.contains('Cloud')) {
    return 'assets/cloudy.png';
  } else if (description.contains('Rain')) {
    return 'assets/rain.png';
  } else if (description.contains('Snow')) {
    return 'assets/snowy.png';
  } else if (description.contains('Storm')) {
    return 'assets/stormy.jpg';
  } else {
    return 'assets/unknown.png'; // Fallback image
  }
}

// Function to fetch the 5-day forecast for a city using the free plan
Future<List<double>?> fetchFiveDayForecast(String city) async {
  var url = 'https://api.openweathermap.org/data/2.5/forecast?q=$city&appid=$apiKey';
  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      print('5-Day Forecast Data: $data');  // Log the response for debugging

      List forecastData = data['list'];
      Map<String, List<double>> dailyTemperatures = {};

      // Aggregate temperatures by day (each 3-hour interval)
      for (var entry in forecastData) {
        String date = entry['dt_txt'].substring(0, 10); // Get the date (YYYY-MM-DD)
        double tempK = entry['main']['temp']; // Get temperature in Kelvin
        double tempC = tempK - 273.15; // Convert to Celsius

        if (dailyTemperatures.containsKey(date)) {
          dailyTemperatures[date]!.add(tempC);
        } else {
          dailyTemperatures[date] = [tempC];
        }
      }

      // Average daily temperatures for each day
      List<double> dailyAverages = dailyTemperatures.entries.take(5).map((entry) {
        List<double> temps = entry.value;
        double avgTemp = temps.reduce((a, b) => a + b) / temps.length; // Calculate average temperature
        return avgTemp;
      }).toList();

      return dailyAverages; // Return a list of average temperatures for 5 days
    } else {
      print('Error: Could not fetch 5-day forecast. Status code: ${response.statusCode}');
      return null;
    }
  } catch (error) {
    print('Error fetching 5-day forecast: $error');
    return null;
  }
}