-- 012_update_profiles_and_tables.sql

-- 1. Ensure profiles table has email and bio columns
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS email TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS bio TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS location TEXT DEFAULT 'Gilgit-Baltistan';

-- 2. Ensure network_reports table has unified column names
ALTER TABLE public.network_reports ADD COLUMN IF NOT EXISTS location TEXT;
ALTER TABLE public.network_reports ADD COLUMN IF NOT EXISTS network_status TEXT;
ALTER TABLE public.network_reports ADD COLUMN IF NOT EXISTS network_type TEXT;
ALTER TABLE public.network_reports ADD COLUMN IF NOT EXISTS description TEXT;

-- 3. RLS Policies for weather_reports
ALTER TABLE public.weather_reports ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow public delete weather reports" ON public.weather_reports;
CREATE POLICY "Allow public delete weather reports"
  ON public.weather_reports
  FOR DELETE
  USING (true);

DROP POLICY IF EXISTS "Allow public read access to weather reports" ON public.weather_reports;
CREATE POLICY "Allow public read access to weather reports"
  ON public.weather_reports
  FOR SELECT
  USING (true);

DROP POLICY IF EXISTS "Allow users to insert weather reports" ON public.weather_reports;
CREATE POLICY "Allow users to insert weather reports"
  ON public.weather_reports
  FOR INSERT
  WITH CHECK (true);

-- 4. RLS Policies for network_reports
ALTER TABLE public.network_reports ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow public read access to network reports" ON public.network_reports;
CREATE POLICY "Allow public read access to network reports"
  ON public.network_reports
  FOR SELECT
  USING (true);

DROP POLICY IF EXISTS "Allow public insert network reports" ON public.network_reports;
CREATE POLICY "Allow public insert network reports"
  ON public.network_reports
  FOR INSERT
  WITH CHECK (true);

-- 5. RLS Policies for alerts
ALTER TABLE public.alerts ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow public read access to alerts" ON public.alerts;
CREATE POLICY "Allow public read access to alerts"
  ON public.alerts
  FOR SELECT
  USING (true);

DROP POLICY IF EXISTS "Allow public insert alerts" ON public.alerts;
CREATE POLICY "Allow public insert alerts"
  ON public.alerts
  FOR INSERT
  WITH CHECK (true);

-- 6. RLS Policies for sos_requests
ALTER TABLE public.sos_requests ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow public read access to SOS requests" ON public.sos_requests;
CREATE POLICY "Allow public read access to SOS requests"
  ON public.sos_requests
  FOR SELECT
  USING (auth.uid() = user_id OR user_id IS NULL OR true);

DROP POLICY IF EXISTS "Allow public insert SOS requests" ON public.sos_requests;
CREATE POLICY "Allow public insert SOS requests"
  ON public.sos_requests
  FOR INSERT
  WITH CHECK (true);

-- 7. RLS Policies for profiles
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow public read access to profiles" ON public.profiles;
CREATE POLICY "Allow public read access to profiles"
  ON public.profiles
  FOR SELECT
  USING (true);

DROP POLICY IF EXISTS "Allow users to insert their own profile" ON public.profiles;
CREATE POLICY "Allow users to insert their own profile"
  ON public.profiles
  FOR INSERT
  WITH CHECK (auth.uid() = id);

DROP POLICY IF EXISTS "Allow users to update their own profile" ON public.profiles;
CREATE POLICY "Allow users to update their own profile"
  ON public.profiles
  FOR UPDATE
  USING (auth.uid() = id);
