CREATE TABLE IF NOT EXISTS sos_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  emergency_type TEXT NOT NULL DEFAULT 'Emergency SOS',
  description TEXT,
  location TEXT,
  latitude DOUBLE PRECISION,
  longitude DOUBLE PRECISION,
  contact_number TEXT DEFAULT '1122',
  status TEXT NOT NULL DEFAULT 'Pending' CHECK (status IN ('Pending', 'In Progress', 'Resolved', 'Cancelled')),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_sos_requests_user_id ON sos_requests(user_id);
CREATE INDEX IF NOT EXISTS idx_sos_requests_status ON sos_requests(status);
CREATE INDEX IF NOT EXISTS idx_sos_requests_created_at ON sos_requests(created_at DESC);

ALTER TABLE sos_requests ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own SOS requests"
  ON sos_requests
  FOR SELECT
  USING (auth.uid() = user_id OR user_id IS NULL);

CREATE POLICY "Users can insert their own SOS requests"
  ON sos_requests
  FOR INSERT
  WITH CHECK (auth.uid() = user_id OR user_id IS NULL);

CREATE POLICY "Users can update their own SOS requests"
  ON sos_requests
  FOR UPDATE
  USING (auth.uid() = user_id OR user_id IS NULL);

CREATE POLICY "Users can delete their own SOS requests"
  ON sos_requests
  FOR DELETE
  USING (auth.uid() = user_id OR user_id IS NULL);
