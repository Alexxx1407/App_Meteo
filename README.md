## 📚 Table of Contents
- [Features](#-features)
- [Project Structure](#-project-structure)
- [Explanation of Files](#-Explanation-of-Files)
- [Usage Instructions](#-Usage-Instructions)
- [License](#-license)

---



## **🌦️ Flutter Weather App** 
This Flutter-based Weather App provides weather information for a specific city using the OpenWeatherMap API. The app features real-time weather updates, a graph displaying the temperature trend for the next 24 hours, and the ability to save favorite cities for quick access.


## **📋 Features**
**Search for Cities:** Get weather information for any city in the world.
**Temperature Units:** Toggle between Celsius and Fahrenheit.
**Hourly Temperature Graph:** Visualize temperature trends for the next 24 hours in a smooth, interactive graph.
**Favorite Cities:** Save and manage a list of favorite cities.
**Weather Icons:** Dynamic weather icons corresponding to weather conditions (e.g., sunny, rainy, cloudy).


## **🎨 Project Structure:**
The project is modularized into several files to maintain code organization and reusability:

lib/
│
├── api_service.dart       # Handles all API requests to OpenWeatherMap
├── favorite_service.dart  # Manages the favorites list (add, remove, display)
├── graph_widget.dart      # Contains the logic and UI for the temperature graph
├── weather_widget.dart    # Displays the weather info (icon, description, temperature)
└── main.dart              # Main entry point for the app, orchestrates the above components

## Explanation of Files
**api_service.dart:**

Handles the API calls to OpenWeatherMap to fetch current weather data and hourly forecasts.
Processes the JSON response and provides weather information and temperature data to the main app.
**favorite_service.dart:**

Manages favorite cities, allowing the user to save, remove, and display their favorite locations.
Uses dialog boxes to show the list of favorite cities with the ability to delete them.
**graph_widget.dart:**

Displays the temperature trend for the next 24 hours using the FLChart library.
Shows a smooth, curved graph with dynamic data from the OpenWeatherMap API.
**weather_widget.dart:**

Displays the weather information such as temperature, description, and corresponding weather icons (sunny, cloudy, rainy, etc.).
Uses dynamic content based on the API response.
**main.dart:**

The main UI structure of the app. Handles city searches, and interaction between the user and the weather API.
Orchestrates the other components like graph display, weather display, and favorites management.


## **💡 Usage Instructions**
**Search for a City:**

Enter the name of a city in the search bar and press Get the Weather. The app will fetch and display the current weather.
**View Temperature Graph:**

After searching for a city, press Show Graph to view the temperature forecast for the next 24 hours.
**Toggle Temperature Units:**

You can toggle between Celsius and Fahrenheit by pressing Convert to F° or Convert to C°.
**Manage Favorite Cities:**

Press the star icon next to the search bar to add a city to your favorite list.
Press the favorite icon in the top-right corner of the app to view and manage your favorite cities.

## **🧰 Dependencies**
**The app uses the following dependencies:**

fl_chart: For rendering temperature graphs.
http: For making network requests to OpenWeatherMap API.
flutter: The main framework for building the UI.

**📝 License**
This project is licensed under the MIT License - see the LICENSE file for details.
