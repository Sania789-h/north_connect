import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/utils/helpers.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../models/alert_model.dart';
import '../../services/mock_database_service.dart';

class AddAlertScreen extends StatefulWidget {
  const AddAlertScreen({super.key});

  @override
  State<AddAlertScreen> createState() => _AddAlertScreenState();
}

class _AddAlertScreenState extends State<AddAlertScreen> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  bool isLoading = false;

  String selectedType = "Road Alert";
  String selectedLocation = "Gilgit";
  String selectedSeverity = "Low";

  final List<String> alertTypes = [
    "Road Alert",
    "Weather Alert",
    "Emergency Alert",
    "Network Alert",
    "Utility Alert",
    "Public Alert",
  ];

  final List<String> locations = [
    "Gilgit",
    "Skardu",
    "Hunza",
    "Nagar",
    "Ghizer",
    "Diamer",
    "Gupis",
    "Astore",
  ];

  final List<String> severityLevels = [
    "Low",
    "Medium",
    "High",
    "Critical",
  ];

  Future<void> addAlert() async {
    final title = titleController.text.trim();
    final description = descriptionController.text.trim();

    if (title.isEmpty || description.isEmpty) {
      Helpers.showSnackBar(context, "Please fill all fields");
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await Supabase.instance.client.from('alerts').insert({
        'title': title,
        'description': description,
        'category': selectedType,
        'location': selectedLocation,
        'severity': selectedSeverity,
      });

      if (mounted) {
        Helpers.showSnackBar(context, "Alert Added Successfully");
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint("Supabase alert insert failed, saving locally: $e");
      final localAlert = AlertModel(
        id: "a_local_${DateTime.now().millisecondsSinceEpoch}",
        title: title,
        description: description,
        category: selectedType,
        location: selectedLocation,
        severity: selectedSeverity,
        createdAt: DateTime.now(),
      );
      MockDatabaseService.addAlert(localAlert);

      if (mounted) {
        Helpers.showSnackBar(context, "Offline Mode: Alert saved locally!");
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
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Alert"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomTextField(
              controller: titleController,
              hintText: "Alert Title",
              prefixIcon: Icons.warning_amber_rounded,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: "Alert Description",
                prefixIcon: Icon(Icons.description_outlined),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: selectedType,
              decoration: const InputDecoration(
                labelText: "Category",
              ),
              items: alertTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
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
              items: locations.map((location) {
                return DropdownMenuItem(
                  value: location,
                  child: Text(location),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedLocation = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: selectedSeverity,
              decoration: const InputDecoration(
                labelText: "Severity",
              ),
              items: severityLevels.map((severity) {
                return DropdownMenuItem(
                  value: severity,
                  child: Text(severity),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedSeverity = value!;
                });
              },
            ),
            const SizedBox(height: 32),
            CustomButton(
              text: "Submit Alert",
              onPressed: addAlert,
              isLoading: isLoading,
            ),
          ],
        ),
      ),
    );
  }
}