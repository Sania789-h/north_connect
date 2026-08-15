-- Migration: Create Avatars Storage Bucket and RLS Policies

-- 1. Create public storage bucket for user avatars if it doesn't exist
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'avatars',
  'avatars',
  true,
  5242880, -- 5MB limit
  ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/gif']
)
ON CONFLICT (id) DO UPDATE SET public = true;

-- 2. Allow public access to view profile images
CREATE POLICY "Public Read Avatars Access"
  ON storage.objects
  FOR SELECT
  USING (bucket_id = 'avatars');

-- 3. Allow authenticated users to upload avatar images
CREATE POLICY "Authenticated Users Upload Avatar"
  ON storage.objects
  FOR INSERT
  WITH CHECK (
    bucket_id = 'avatars' 
    AND auth.role() = 'authenticated'
  );

-- 4. Allow users to update their own avatar images
CREATE POLICY "Authenticated Users Update Avatar"
  ON storage.objects
  FOR UPDATE
  USING (
    bucket_id = 'avatars' 
    AND auth.role() = 'authenticated'
  );

-- 5. Allow users to delete their avatar images
CREATE POLICY "Authenticated Users Delete Avatar"
  ON storage.objects
  FOR DELETE
  USING (
    bucket_id = 'avatars' 
    AND auth.role() = 'authenticated'
  );
