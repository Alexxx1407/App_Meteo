import 'package:flutter/material.dart';

List<String> favoriteCities = []; // List to store favorite cities

// Function to add a city to favorites
void saveFavoriteCity(String city) {
  if (!favoriteCities.contains(city)) {
    favoriteCities.add(city);
  }
}

// Function to show a dialog with favorite cities
void showFavoritesDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Favorite Cities"),
        content: favoriteCities.isEmpty
            ? const Text("No favorite cities added.")
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: favoriteCities.map((city) {
                  return ListTile(
                    title: Text(city),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        removeFavoriteCity(city);
                        Navigator.pop(context);
                        showFavoritesDialog(context); // Refresh dialog
                      },
                    ),
                  );
                }).toList(),
              ),
        actions: <Widget>[
          ElevatedButton(
            child: const Text("Close"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

// Function to remove a city from favorites
void removeFavoriteCity(String city) {
  favoriteCities.remove(city);
}
