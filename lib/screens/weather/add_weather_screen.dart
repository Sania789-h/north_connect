import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/utils/helpers.dart';
import '../../widgets/custom_button.dart';
import '../../services/mock_database_service.dart';

class AddWeatherScreen extends StatefulWidget {
  const AddWeatherScreen({super.key});

  @override
  State<AddWeatherScreen> createState() =>
      _AddWeatherScreenState();
}

class _AddWeatherScreenState
    extends State<AddWeatherScreen> {
  final temperatureController =
  TextEditingController();

  final descriptionController =
  TextEditingController();

  bool isLoading = false;

  String selectedLocation = "Gilgit";
  String selectedWeather = "Sunny";

  final locations = [
    "Gilgit",
    "Skardu",
    "Hunza",
    "Nagar",
    "Ghizer",
    "Diamer",
    "Astore"
  ];

  final weatherTypes = [
    "Sunny",
    "Cloudy",
    "Rainy",
    "Snowfall",
    "Thunderstorm",
    "Windy",
    "Fog"
  ];

  Future<void> addWeather() async {
    final temp = temperatureController.text.trim();
    final desc = descriptionController.text.trim();

    if (temp.isEmpty || desc.isEmpty) {
      Helpers.showSnackBar(context, "Fill all fields");
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await Supabase.instance.client
          .from('weather_reports')
          .insert({
        'location': selectedLocation,
        'weather_type': selectedWeather,
        'temperature': temp,
        'description': desc,
      });

      if (mounted) {
        Helpers.showSnackBar(context, "Weather report added successfully");
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint("Supabase weather insert failed, saving locally: $e");
      MockDatabaseService.addWeather({
        'location': selectedLocation,
        'weather_type': selectedWeather,
        'temperature': temp,
        'description': desc,
      });

      if (mounted) {
        Helpers.showSnackBar(context, "Offline Mode: Weather report saved locally!");
        Navigator.pop(context);
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Widget buildDropdown(
      String value,
      List<String> items,
      String label,
      Function(String?) onChanged,
      ) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
      ),
      items: items.map((e) {
        return DropdownMenuItem(
          value: e,
          child: Text(e),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  @override
  void dispose() {
    temperatureController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Weather"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            buildDropdown(
              selectedLocation,
              locations,
              "Location",
                  (value) {
                setState(() {
                  selectedLocation = value!;
                });
              },
            ),

            const SizedBox(height: 16),

            buildDropdown(
              selectedWeather,
              weatherTypes,
              "Weather Type",
                  (value) {
                setState(() {
                  selectedWeather = value!;
                });
              },
            ),

            const SizedBox(height: 16),

            TextField(
              controller: temperatureController,
              decoration: const InputDecoration(
                labelText: "Temperature",
                hintText: "15°C",
                prefixIcon: Icon(Icons.thermostat_outlined),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: "Description",
                prefixIcon: Icon(Icons.description_outlined),
              ),
            ),

            const SizedBox(height: 32),

            CustomButton(
              text: "Add Weather Report",
              onPressed: addWeather,
              isLoading: isLoading,
            ),
          ],
        ),
      ),
    );
  }
}