import 'package:flutter/material.dart';
import '../services/weather_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();

  Map<String, dynamic>? weatherData;
  bool isLoading = false;
  String? error;

  void getWeather() async {
  if (_controller.text.isEmpty) {
    setState(() {
      error = "Please enter a city name";
    });
    return;
  }

  setState(() {
    isLoading = true;
    error = null;
    weatherData = null;
  });

  try {
    final data = await WeatherService.fetchWeather(_controller.text);

    if (!mounted) return;

    setState(() {
      weatherData = data;
    });

    checkForAlert(data);
  } catch (e) {
    if (!mounted) return;

    setState(() {
      error = e.toString();
    });
  } finally {
    // ✅ FIX — no return inside finally
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }
}

  // Disaster Color Logic
  Color getDisasterColor(String type) {
    switch (type) {
      case "Cyclone":
        return Colors.red.shade200;
      case "Storm":
        return Colors.orange.shade200;
      case "Flood":
        return Colors.blue.shade200;
      case "Heatwave":
        return Colors.deepOrange.shade200;
      default:
        return Colors.green.shade200;
    }
  }

  void openChat() {
    Navigator.pushNamed(context, '/chat');
  }

  void checkForAlert(Map<String, dynamic> data) {
    final risk = data['risk_score'] ?? 0;
    final disasterType = data['disaster_type'] ?? "Disaster";

    if (risk >= 70 && mounted) {
      Future.microtask(() {
        if (!mounted) return; // ✅ extra safety

        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("🚨 High Risk Alert"),
            content: Text(
              "High $disasterType risk detected in your area. Please stay safe!",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SkyCast 🌦️'),
        centerTitle: true,
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: openChat,
        child: const Icon(Icons.chat),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  labelText: 'Enter city name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: getWeather,
                child: const Text('Get Weather'),
              ),
              const SizedBox(height: 20),

              if (isLoading) const CircularProgressIndicator(),

              if (error != null)
                Text(
                  error!,
                  style: const TextStyle(color: Colors.red),
                ),

              if (weatherData != null)
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          weatherData!['city'] ?? "Unknown City",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                            'Temperature: ${weatherData!['temperature'] ?? "-"} °C'),
                        Text(
                            'Feels like: ${weatherData!['feels_like'] ?? "-"} °C'),
                        Text('Humidity: ${weatherData!['humidity'] ?? "-"}%'),
                        Text('Weather: ${weatherData!['weather'] ?? "-"}'),
                        Text(
                            'Wind Speed: ${weatherData!['wind_speed'] ?? "-"} m/s'),
                        const SizedBox(height: 20),

                        if (weatherData!['disaster_type'] != null)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: getDisasterColor(
                                  weatherData!['disaster_type']),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Disaster Prediction: ${weatherData!['disaster_type']}",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                    "Severity: ${weatherData!['severity'] ?? "-"}"),
                                const SizedBox(height: 10),
                                const Text(
                                  "Safety Tips:",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                if (weatherData!['safety_tips'] != null)
                                  ...List.generate(
                                    weatherData!['safety_tips'].length,
                                    (index) => Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 4),
                                      child: Text(
                                        "• ${weatherData!['safety_tips'][index]}",
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 10),
                                Text(
                                  "Recommendation: ${weatherData!['recommendation'] ?? "-"}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "Risk Score: ${weatherData!['risk_score'] ?? "-"}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}