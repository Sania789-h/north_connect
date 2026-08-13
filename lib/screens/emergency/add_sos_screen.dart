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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0B1120) : const Color(0xFFF8FAFC);
    final inputFill = isDark ? const Color(0xFF111827) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1E293B);
    final textSecondary = isDark ? const Color(0xFFCBD5E1) : const Color(0xFF64748B);
    final inputBorder = isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFE2E8F0);
    final dropdownIconColor = isDark ? Colors.white : const Color(0xFF1E293B);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        foregroundColor: textPrimary,
        title: Text("Send SOS Alert", style: TextStyle(color: textPrimary)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              value: selectedType,
              style: TextStyle(color: textPrimary),
              dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
              iconEnabledColor: dropdownIconColor,
              decoration: InputDecoration(
                labelText: "Emergency Type",
                labelStyle: TextStyle(color: textSecondary),
                filled: true,
                fillColor: inputFill,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: inputBorder),
                  borderRadius: BorderRadius.circular(16),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xFF067A46)),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              items: emergencyTypes.map((e) {
                return DropdownMenuItem(
                  value: e,
                  child: Text(e, style: TextStyle(color: textPrimary)),
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
              value: selectedLocation,
              style: TextStyle(color: textPrimary),
              dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
              iconEnabledColor: dropdownIconColor,
              decoration: InputDecoration(
                labelText: "Location",
                labelStyle: TextStyle(color: textSecondary),
                filled: true,
                fillColor: inputFill,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: inputBorder),
                  borderRadius: BorderRadius.circular(16),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xFF067A46)),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              items: locations.map((e) {
                return DropdownMenuItem(
                  value: e,
                  child: Text(e, style: TextStyle(color: textPrimary)),
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
              style: TextStyle(color: textPrimary),
              decoration: InputDecoration(
                labelText: "Emergency Details",
                labelStyle: TextStyle(color: textSecondary),
                prefixIcon: Icon(Icons.description_outlined, color: textSecondary),
                filled: true,
                fillColor: inputFill,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: inputBorder),
                  borderRadius: BorderRadius.circular(16),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xFF067A46)),
                  borderRadius: BorderRadius.circular(16),
                ),
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