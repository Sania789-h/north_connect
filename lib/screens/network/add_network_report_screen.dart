import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/utils/helpers.dart';
import '../../widgets/custom_button.dart';
import '../../services/mock_database_service.dart';

class AddNetworkReportScreen extends StatefulWidget {
  const AddNetworkReportScreen({super.key});

  @override
  State<AddNetworkReportScreen> createState() =>
      _AddNetworkReportScreenState();
}

class _AddNetworkReportScreenState
    extends State<AddNetworkReportScreen> {
  final issueController = TextEditingController();

  String selectedArea = "Gilgit";
  String selectedProvider = "SCOM";
  String selectedSignal = "Strong";
  String selectedStatus = "Online";

  bool isLoading = false;

  final areas = [
    "Gilgit",
    "Skardu",
    "Hunza",
    "Nagar",
    "Ghizer",
    "Diamer"
  ];

  final providers = [
    "SCOM",
    "Jazz",
    "Zong",
    "Telenor"
  ];

  final signals = [
    "Strong",
    "Medium",
    "Weak"
  ];

  final statuses = [
    "Online",
    "Offline"
  ];

  Future<void> submitReport() async {
    final issue = issueController.text.trim();

    if (issue.isEmpty) {
      Helpers.showSnackBar(context, "Enter issue details");
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      await Supabase.instance.client
          .from('network_reports')
          .insert({
        if (userId != null) 'user_id': userId,
        'area': selectedArea,
        'network_name': selectedProvider,
        'signal_strength': selectedSignal,
        'status': selectedStatus,
        'issue': issue,
      });

      if (mounted) {
        Helpers.showSnackBar(context, "Network report submitted successfully!");
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint("Supabase network insert failed: $e");
      // Save locally as offline fallback
      MockDatabaseService.addNetwork({
        'area': selectedArea,
        'network_name': selectedProvider,
        'signal_strength': selectedSignal,
        'status': selectedStatus,
        'issue': issue,
      });

      if (mounted) {
        Helpers.showSnackBar(context, "Offline: Report saved locally!");
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
      Function(String?) onChanged) {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Network Report"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            buildDropdown(
              selectedArea,
              areas,
              "Area",
                  (value) {
                setState(() {
                  selectedArea = value!;
                });
              },
            ),

            const SizedBox(height: 16),

            buildDropdown(
              selectedProvider,
              providers,
              "Network Provider",
                  (value) {
                setState(() {
                  selectedProvider = value!;
                });
              },
            ),

            const SizedBox(height: 16),

            buildDropdown(
              selectedSignal,
              signals,
              "Signal Strength",
                  (value) {
                setState(() {
                  selectedSignal = value!;
                });
              },
            ),

            const SizedBox(height: 16),

            buildDropdown(
              selectedStatus,
              statuses,
              "Status",
                  (value) {
                setState(() {
                  selectedStatus = value!;
                });
              },
            ),

            const SizedBox(height: 16),

            TextField(
              controller: issueController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: "Issue Details",
                prefixIcon: Icon(Icons.error_outline_rounded),
              ),
            ),

            const SizedBox(height: 32),

            CustomButton(
              text: "Submit Report",
              onPressed: submitReport,
              isLoading: isLoading,
            ),
          ],
        ),
      ),
    );
  }
}