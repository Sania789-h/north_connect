import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/colors.dart';
import 'destination_detail_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String _selectedFilter = "All";

  final List<Map<String, dynamic>> _destinations = [
    {
      'title': 'Hunza Valley',
      'location': 'Gilgit-Baltistan',
      'image': 'https://images.unsplash.com/photo-1580651315530-69c8e0026377?w=800',
      'rating': 4.9,
      'description': 'Hunza Valley is a mountainous valley in the Gilgit-Baltistan region of Pakistan. Known for its stunning landscapes, ancient forts, and the friendly hospitality of its people, it is one of the most popular tourist destinations in Pakistan.',
      'details': [
        'Home to the famous Karakoram Highway',
        'Visit the ancient Baltit and Altit Forts',
        'Stunning views of Rakaposhi and Ultar Sar peaks',
        'Rich cultural heritage and festivals',
        'Best time to visit: April to October',
      ],
      'category': 'Valleys',
    },
    {
      'title': 'Skardu Valley',
      'location': 'Baltistan Region',
      'image': 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800',
      'rating': 4.8,
      'description': 'Skardu is a beautiful valley located at the confluence of the Indus and Shigar rivers. It serves as the gateway to some of the world\'s highest peaks including K2, and is famous for its breathtaking landscapes, cold desert, and serene lakes.',
      'details': [
        'Gateway to K2 and Central Karakoram',
        'Visit the magnificent Shangrila Resort',
        'Explore the unique Cold Desert',
        'Katpana and Sarfaranga lakes',
        'Best time to visit: May to September',
      ],
      'category': 'Valleys',
    },
    {
      'title': 'Attabad Lake',
      'location': 'Hunza Valley',
      'image': 'https://images.unsplash.com/photo-1626621341517-bbf3d9990a23?w=800',
      'rating': 4.7,
      'description': 'Attabad Lake, also known as Gojal Lake, was created in January 2010 following a massive landslide that blocked the Hunza River. The stunning turquoise waters and surrounding mountains make it a must-visit destination in Gilgit-Baltistan.',
      'details': [
        'Stunning turquoise blue water',
        'Boating, jet skiing, and fishing activities',
        'Surrounded by majestic mountains',
        'Drive along the famous Karakoram Highway',
        'Best time to visit: May to October',
      ],
      'category': 'Lakes',
    },
    {
      'title': 'Fairy Meadows',
      'location': 'Nanga Parbat Region',
      'image': 'https://images.unsplash.com/photo-1501785888041-af3ef285b470?w=800',
      'rating': 4.9,
      'description': 'Fairy Meadows, locally known as Joot, is a lush green plateau near the base of Nanga Parbat, the ninth highest mountain in the world. The name was given by German explorers and it truly feels like a magical paradise.',
      'details': [
        'Base camp for Nanga Parbat trekkers',
        'Lush green meadows with wildflowers',
        'Spectacular views of the Fairy Meadows peak',
        'Bonfire and camping under the stars',
        'Best time to visit: June to August',
      ],
      'category': 'Valleys',
    },
    {
      'title': 'Deosai Plains',
      'location': 'Skardu Region',
      'image': 'https://images.unsplash.com/photo-1519681393784-d120267933ba?w=800',
      'rating': 4.8,
      'description': 'Deosai National Park is a high-altitude alpine plain in the Karakoram range. It is the second highest plateau in the world, known for its unique ecosystem, wildflowers, and the Himalayan brown bear.',
      'details': [
        'Second highest plateau in the world at 4,114m',
        'Home to the Himalayan brown bear',
        'Stunning wildflower meadows in spring',
        'Sheosar Lake and its crystal clear waters',
        'Best time to visit: July to September',
      ],
      'category': 'Valleys',
    },
    {
      'title': 'Khaplu Palace',
      'location': 'Khaplu, Ghanche District',
      'image': 'https://images.unsplash.com/photo-1599661046289-e31897846e41?w=800',
      'rating': 4.6,
      'description': 'Khaplu Palace, also known as Yabgo Khar, is a historic fort-palace in the town of Khaplu. Built in the 19th century, it has been beautifully restored and now serves as a museum and luxury heritage hotel.',
      'details': [
        '19th century Tibetan-style architecture',
        'Restored as a heritage museum and hotel',
        'Stunning views of the surrounding valley',
        'Rich Balti culture and history',
        'Best time to visit: April to October',
      ],
      'category': 'Forts',
    },
  ];

  List<Map<String, dynamic>> get _filteredDestinations {
    if (_selectedFilter == "All") return _destinations;
    return _destinations.where((d) => d['category'] == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0B1120) : const Color(0xFFF8FAFC);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textPrimary = isDark ? Colors.white : (AppColors.textPrimary);
    final textSecondary = isDark ? const Color(0xFFCBD5E1) : AppColors.textSecondary;
    final shadowColor = isDark ? Colors.black.withValues(alpha: 0.35) : Colors.black.withValues(alpha: 0.04);
    final filterBorder = isDark ? Colors.white.withValues(alpha: 0.12) : Colors.grey.shade300;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        foregroundColor: textPrimary,
        title: Text('Explore GB', style: TextStyle(color: textPrimary)),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: textPrimary),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Search coming soon"),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Discover\nGilgit-Baltistan",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                height: 1.2,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ["All", "Valleys", "Lakes", "Forts"].map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedFilter = filter),
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : cardBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : filterBorder,
                        ),
                      ),
                      child: Text(
                        filter,
                        style: TextStyle(
                          color: isSelected ? Colors.white : textPrimary,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _filteredDestinations.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final dest = _filteredDestinations[index];
                return _buildDestinationCard(context, dest, cardBg: cardBg, textPrimary: textPrimary, textSecondary: textSecondary, shadowColor: shadowColor);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDestinationCard(
    BuildContext context,
    Map<String, dynamic> dest, {
    required Color cardBg,
    required Color textPrimary,
    required Color textSecondary,
    required Color shadowColor,
  }) {
    final placeholderColor = isDarkColor(cardBg) ? const Color(0xFF334155) : Colors.grey[200]!;
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: cardBg,
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                bottomLeft: Radius.circular(24),
              ),
              child: CachedNetworkImage(
                imageUrl: dest['image'],
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                placeholder: (_, __) => Container(
                  color: placeholderColor,
                  child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                ),
                errorWidget: (_, __, ___) => Container(
                  color: placeholderColor,
                  child: Icon(Icons.image, color: textSecondary),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: AppColors.secondary, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        dest['rating'].toString(),
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textPrimary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dest['title'],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dest['location'],
                    style: TextStyle(
                      fontSize: 13,
                      color: textSecondary,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 36,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DestinationDetailScreen(destination: dest),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      child: const Text("View Details"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool isDarkColor(Color color) {
    final double luminance = color.computeLuminance();
    return luminance < 0.5;
  }
}
