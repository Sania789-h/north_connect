import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/colors.dart';
import '../../core/utils/helpers.dart';
import '../../widgets/destination_card.dart';
import '../alerts/alerts_screen.dart';
import '../network/network_screen.dart';
import '../emergency/sos_screen.dart';
import '../weather/weather_screen.dart';
import '../notifications/notifications_screen.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback? onExploreTap;

  const HomeScreen({super.key, this.onExploreTap});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Premium Hero Section
          SliverAppBar(
            expandedHeight: 300,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: 'https://images.unsplash.com/photo-1624555130581-1d9cca783bc0?w=1000',
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      child: const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: AppColors.primary,
                      child: const Icon(Icons.image, color: Colors.white, size: 48),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.4),
                          Colors.transparent,
                          AppColors.primary.withValues(alpha: 0.95),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Welcome to",
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 16,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const Text(
                          "Gilgit-Baltistan",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: CircleAvatar(
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  child: IconButton(
                    icon: const Icon(Icons.notifications_none_rounded, color: Colors.white),
                    onPressed: () {
                      Helpers.push(context, const NotificationsScreen());
                    },
                  ),
                ),
              ),
            ],
          ),
          
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        hintText: "Search destinations, hotels...",
                        prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                        contentPadding: EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Featured Destinations",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          if (onExploreTap != null) {
                            onExploreTap!();
                          } else {
                            Helpers.showSnackBar(context, "Navigating to Explore");
                          }
                        },
                        child: const Text("See All", style: TextStyle(color: AppColors.secondary)),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Horizontal List of Destinations
                  SizedBox(
                    height: 280,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        DestinationCard(
                          title: "Hunza Valley",
                          location: "Gilgit-Baltistan",
                          imageUrl: "https://picsum.photos/id/1036/800/600",
                          rating: 4.9,
                          onTap: () {
                            Helpers.showSnackBar(context, "Viewing Hunza Valley details");
                          },
                        ),
                        DestinationCard(
                          title: "Skardu",
                          location: "Baltistan Region",
                          imageUrl: "https://picsum.photos/id/1043/800/600",
                          rating: 4.8,
                          onTap: () {
                            Helpers.showSnackBar(context, "Viewing Skardu details");
                          },
                        ),
                        DestinationCard(
                          title: "Fairy Meadows",
                          location: "Nanga Parbat",
                          imageUrl: "https://picsum.photos/id/1044/800/600",
                          rating: 4.7,
                          onTap: () {
                            Helpers.showSnackBar(context, "Viewing Fairy Meadows details");
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  const Text(
                    "Quick Services",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Grid for legacy safety features
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 4,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    children: [
                      _buildServiceItem(
                        context,
                        icon: Icons.emergency_outlined,
                        label: "SOS",
                        color: AppColors.error,
                        onTap: () => Helpers.push(context, const SOSScreen()),
                      ),
                      _buildServiceItem(
                        context,
                        icon: Icons.warning_amber_rounded,
                        label: "Alerts",
                        color: AppColors.warning,
                        onTap: () => Helpers.push(context, const AlertsScreen()),
                      ),
                      _buildServiceItem(
                        context,
                        icon: Icons.cloud_outlined,
                        label: "Weather",
                        color: Colors.blue,
                        onTap: () => Helpers.push(context, const WeatherScreen()),
                      ),
                      _buildServiceItem(
                        context,
                        icon: Icons.wifi_rounded,
                        label: "Network",
                        color: Colors.purple,
                        onTap: () => Helpers.push(context, const NetworkScreen()),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 100), // Padding for bottom nav
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceItem(BuildContext context, {required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}