CREATE TABLE IF NOT EXISTS sos_alerts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  emergency_type TEXT NOT NULL,
  location TEXT NOT NULL,
  message TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'Active',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_sos_alerts_created_at ON sos_alerts(created_at DESC);

ALTER TABLE sos_alerts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public read access to SOS alerts"
  ON sos_alerts
  FOR SELECT
  USING (true);

CREATE POLICY "Allow users to insert their own SOS alerts"
  ON sos_alerts
  FOR INSERT
  WITH CHECK (auth.uid() = user_id OR user_id IS NULL);
