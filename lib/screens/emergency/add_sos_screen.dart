import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/utils/helpers.dart';
import '../../widgets/custom_button.dart';
import '../../services/mock_database_service.dart';

class AddSOSScreen extends StatefulWidget {
  const AddSOSScreen({super.key});

  @override
  State<AddSOSScreen> createState() => _AddSOSScreenState();
}

class _AddSOSScreenState extends State<AddSOSScreen> {
  final messageController = TextEditingController();

  bool isLoading = false;

  String selectedType = "Medical Emergency";
  String selectedLocation = "Gilgit";

  final List<String> emergencyTypes = [
    "Medical Emergency",
    "Road Accident",
    "Fire Emergency",
    "Flood Emergency",
    "Security Threat",
  ];

  final List<String> locations = [
    "Gilgit",
    "Skardu",
    "Hunza",
    "Nagar",
    "Ghizer",
    "Diamer",
    "Astore",
  ];

  Future<void> submitSOS() async {
    final message = messageController.text.trim();

    if (message.isEmpty) {
      Helpers.showSnackBar(context, "Enter emergency details");
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await Supabase.instance.client.from('sos_alerts').insert({
        'emergency_type': selectedType,
        'location': selectedLocation,
        'message': message,
      });

      if (mounted) {
        Helpers.showSnackBar(context, "SOS Alert Sent");
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint("Supabase SOS insert failed, saving locally: $e");
      MockDatabaseService.addSOS({
        'emergency_type': selectedType,
        'location': selectedLocation,
        'message': message,
      });

      if (mounted) {
        Helpers.showSnackBar(context, "Offline Mode: SOS saved locally!");
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

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Send SOS Alert"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              initialValue: selectedType,
              decoration: const InputDecoration(
                labelText: "Emergency Type",
              ),
              items: emergencyTypes.map((e) {
                return DropdownMenuItem(
                  value: e,
                  child: Text(e),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedType = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: selectedLocation,
              decoration: const InputDecoration(
                labelText: "Location",
              ),
              items: locations.map((e) {
                return DropdownMenuItem(
                  value: e,
                  child: Text(e),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedLocation = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: messageController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: "Emergency Details",
                prefixIcon: Icon(Icons.description_outlined),
              ),
            ),
            const SizedBox(height: 32),
            CustomButton(
              text: "Send SOS",
              onPressed: submitSOS,
              isLoading: isLoading,
              color: Colors.red.shade700,
            ),
          ],
        ),
      ),
    );
  }
}