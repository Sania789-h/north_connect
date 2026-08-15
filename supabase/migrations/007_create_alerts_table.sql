CREATE TABLE IF NOT EXISTS alerts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  category TEXT NOT NULL,
  location TEXT NOT NULL,
  severity TEXT NOT NULL,
  safety_tips TEXT[] NOT NULL DEFAULT '{}',
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_alerts_created_at ON alerts(created_at DESC);

ALTER TABLE alerts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public read access to alerts"
  ON alerts
  FOR SELECT
  USING (true);

CREATE POLICY "Allow authenticated users to insert alerts"
  ON alerts
  FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');
