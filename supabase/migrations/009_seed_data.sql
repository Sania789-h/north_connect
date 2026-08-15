-- Seed Data for alerts
INSERT INTO alerts (id, title, description, category, location, severity, safety_tips, is_read, created_at)
VALUES
  ('a1000000-0000-0000-0000-000000000001', 'Landslide Warning', 'Landslide risk is high in the above mentioned areas due to continuous rainfall. Avoid unnecessary travel and stay safe.', 'Safety', 'Hunza, Gilgit-Baltistan', 'High', ARRAY['Avoid steep areas', 'Stay away from mountain slopes', 'Follow local authorities'], false, NOW() - INTERVAL '2 hours'),
  ('a1000000-0000-0000-0000-000000000002', 'Flood Advisory', 'Water levels are rising in local rivers due to glacial melt. Avoid low-lying areas and river banks.', 'Weather', 'Ghizer, Gilgit-Baltistan', 'High', ARRAY['Move to higher ground', 'Do not cross flowing water', 'Keep emergency supplies ready'], false, NOW() - INTERVAL '5 hours'),
  ('a1000000-0000-0000-0000-000000000003', 'Road Closed', 'Road is temporarily closed due to maintenance work. Alternative routes are available via Kaghan Valley.', 'Road', 'Babusar Top, Naran Road', 'High', ARRAY['Use alternative route via Kaghan', 'Check road updates before travel', 'Carry extra food and water'], false, NOW() - INTERVAL '1 day'),
  ('a1000000-0000-0000-0000-000000000004', 'Heavy Rain Alert', 'Moderate to heavy rainfall expected in the region over the next 24 hours. Drivers should exercise caution.', 'Weather', 'Skardu, Gilgit-Baltistan', 'Medium', ARRAY['Drive slowly, roads may be slippery', 'Keep headlights on in low visibility', 'Avoid areas prone to flooding'], false, NOW() - INTERVAL '2 days'),
  ('a1000000-0000-0000-0000-000000000005', 'Snowfall Warning', 'Moderate to heavy snowfall expected in high altitude regions. Travelers should carry tire chains.', 'Weather', 'Astore, Gilgit-Baltistan', 'Medium', ARRAY['Install tire chains on 4x4 vehicles', 'Keep warm clothes and blankets', 'Check weather before heading out'], false, NOW() - INTERVAL '2 days'),
  ('a1000000-0000-0000-0000-000000000006', 'High Wind Alert', 'Strong winds expected across the region. Secure loose objects and be cautious while driving high-sided vehicles.', 'Safety', 'Ghanche, Gilgit-Baltistan', 'Medium', ARRAY['Secure all outdoor objects', 'Drive carefully on exposed roads', 'Stay away from tall trees and power lines'], false, NOW() - INTERVAL '3 days')
ON CONFLICT (id) DO NOTHING;

-- Seed Data for weather_reports
INSERT INTO weather_reports (id, location, weather_type, temperature, description, created_at)
VALUES
  ('c1000000-0000-0000-0000-000000000001', 'Skardu', 'Snowfall', '-2°C', 'Light snow showers, visibility is low. Roads are slippery.', NOW() - INTERVAL '30 minutes'),
  ('c1000000-0000-0000-0000-000000000002', 'Hunza', 'Sunny', '12°C', 'Clear blue skies with chilly winds. Great weather for travel.', NOW() - INTERVAL '4 hours'),
  ('c1000000-0000-0000-0000-000000000003', 'Gilgit', 'Cloudy', '16°C', 'Overcast clouds, temperature is dropping gradually.', NOW() - INTERVAL '6 hours')
ON CONFLICT (id) DO NOTHING;

-- Seed Data for network_reports
INSERT INTO network_reports (id, area, status, network_name, signal_strength, issue, created_at)
VALUES
  ('e1000000-0000-0000-0000-000000000001', 'Hunza Valley (Aliabad)', 'Online', 'SCOM', 'Strong (4G)', 'Working smoothly without any interruptions.', NOW() - INTERVAL '15 minutes'),
  ('e1000000-0000-0000-0000-000000000002', 'Deosai Plains', 'Offline', 'Telenor', 'No Signal', 'Temporary blackout due to severe weather in the region.', NOW() - INTERVAL '2 hours'),
  ('e1000000-0000-0000-0000-000000000003', 'Skardu City', 'Online', 'Zong', 'Moderate (3G)', 'Slight congestion during evening hours.', NOW() - INTERVAL '8 hours')
ON CONFLICT (id) DO NOTHING;

-- Seed Data for sos_alerts
INSERT INTO sos_alerts (id, emergency_type, status, message, location, created_at)
VALUES
  ('f1000000-0000-0000-0000-000000000001', 'Vehicle Breakdown', 'Resolved', 'Tyre burst on the highway, requested support for replacement tools.', 'Nagar Valley', NOW() - INTERVAL '3 hours'),
  ('f1000000-0000-0000-0000-000000000002', 'Medical Help Needed', 'Active', 'Severe breathing difficulty due to high altitude sickness near Skardu Pass.', 'Skardu', NOW() - INTERVAL '45 minutes')
ON CONFLICT (id) DO NOTHING;

-- Seed Data for notifications (global)
INSERT INTO notifications (id, title, description, category, is_read, created_at)
VALUES
  ('b1000000-0000-0000-0000-000000000001', 'Emergency Alert: Landslide Warning', 'A minor landslide has been reported near Attabad Lake, Hunza. Travelers are advised to avoid the Karakoram Highway section between Aliabad and Gulmit until further notice. Local rescue teams are on-site.', 'Emergency Alert', false, NOW() - INTERVAL '2 hours'),
  ('b1000000-0000-0000-0000-000000000002', 'Heavy Snowfall Expected in Skardu', 'Meteorological department has issued an alert for moderate to heavy snowfall in Skardu and surrounding high-altitude regions over the next 24 hours. Temperature may drop to -8°C.', 'Weather', false, NOW() - INTERVAL '5 hours'),
  ('b1000000-0000-0000-0000-000000000003', 'Road Construction: Babusar Top', 'Maintenance work is in progress on N-15 at Babusar Top. Expect delays of 2-3 hours. Work scheduled from 8 AM to 5 PM daily until completion. Alternative route via Kaghan Valley is open.', 'Road Alert', false, NOW() - INTERVAL '8 hours'),
  ('b1000000-0000-0000-0000-000000000004', 'SCOM Network Restored in Deosai', 'SCOM mobile network services have been fully restored in Deosai Plains and surrounding areas after a 12-hour outage caused by a damaged fiber optic cable.', 'Network', true, NOW() - INTERVAL '1 day'),
  ('b1000000-0000-0000-0000-000000000005', 'SOS Alert Acknowledged', 'Your SOS alert from Nagar Valley has been received by local emergency response team. Rescue vehicle dispatched with medical supplies. Estimated arrival: 45 minutes.', 'SOS', true, NOW() - INTERVAL '27 hours'),
  ('b1000000-0000-0000-0000-000000000006', 'Rainfall Advisory: Gilgit Region', 'Light to moderate rainfall expected in Gilgit city and adjoining areas this evening. Drivers are advised to exercise caution due to slippery roads and reduced visibility.', 'Weather', true, NOW() - INTERVAL '2 days'),
  ('b1000000-0000-0000-0000-000000000007', 'Road Clearance Complete: KKH', 'The Karakoram Highway section near Gilgit city that was blocked due to a rockslide has been cleared. Normal traffic flow has resumed.', 'Road Alert', true, NOW() - INTERVAL '3 days'),
  ('b1000000-0000-0000-0000-000000000008', 'Jazz Network Maintenance Tonight', 'Scheduled network maintenance for Jazz subscribers in the Skardu region tonight from 2 AM to 4 AM. Brief service interruptions may occur during this window.', 'Network', false, NOW() - INTERVAL '12 hours')
ON CONFLICT (id) DO NOTHING;
