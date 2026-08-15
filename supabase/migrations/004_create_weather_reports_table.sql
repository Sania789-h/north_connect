CREATE TABLE IF NOT EXISTS weather_reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  location TEXT NOT NULL,
  weather_type TEXT NOT NULL,
  temperature TEXT NOT NULL,
  description TEXT NOT NULL,
  report_type TEXT,
  forecast_date TEXT,
  forecast_time TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_weather_reports_created_at ON weather_reports(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_weather_reports_location ON weather_reports(location);
CREATE INDEX IF NOT EXISTS idx_weather_reports_report_type ON weather_reports(report_type);

ALTER TABLE weather_reports ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public read access to weather reports"
  ON weather_reports
  FOR SELECT
  USING (true);

CREATE POLICY "Allow users to insert their own weather reports"
  ON weather_reports
  FOR INSERT
  WITH CHECK (auth.uid() = user_id OR user_id IS NULL);
