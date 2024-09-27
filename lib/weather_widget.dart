// File that manage the widget for the weather 


import 'package:flutter/material.dart';

class WeatherWidget extends StatelessWidget {
  final String weatherInfo;
  final String weatherImage;

  const WeatherWidget({
    Key? key,
    required this.weatherInfo,
    required this.weatherImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              weatherInfo,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
            if (weatherImage.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(10),
                child: Image.asset(
                  weatherImage,
                  height: 150,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
