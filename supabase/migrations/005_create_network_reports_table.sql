CREATE TABLE IF NOT EXISTS network_reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  area TEXT NOT NULL,
  network_name TEXT NOT NULL,
  signal_strength TEXT NOT NULL,
  status TEXT NOT NULL,
  issue TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_network_reports_created_at ON network_reports(created_at DESC);

ALTER TABLE network_reports ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public read access to network reports"
  ON network_reports
  FOR SELECT
  USING (true);

CREATE POLICY "Allow users to insert their own network reports"
  ON network_reports
  FOR INSERT
  WITH CHECK (auth.uid() = user_id OR user_id IS NULL);
